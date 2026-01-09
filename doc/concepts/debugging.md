<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Debugging Guide

TUI applications are harder to debug than typical Ruby programs. The terminal is in raw mode. Standard output corrupts the display. Debuggers that rely on REPL input conflict with the event loop. Rust panics produce cryptic stack traces without symbols.

This guide covers the tools RatatuiRuby provides and explains what works (and what does not) when debugging TUI apps.

## Debug Mode

RatatuiRuby ships with debug symbols in release builds. Call `RatatuiRuby::Debug.enable!` to activate Rust backtraces with meaningful stack frames.

### Activation Methods

Three ways to enable debug features:

1. **Environment variable (Rust only):** `RUST_BACKTRACE=1` enables Rust backtraces without Ruby-side debug features.

2. **Environment variable (full):** `RR_DEBUG=1` enables full debug mode at process startup.

3. **Programmatic:** Call `RatatuiRuby.debug_mode!` or `RatatuiRuby::Debug.enable!`.

Including `RatatuiRuby::TestHelper` auto-enables debug mode. Test authors get backtraces automatically.

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
# Option 1: Environment variable
# $ RR_DEBUG=1 ruby my_app.rb

# Option 2: Programmatic
RatatuiRuby.debug_mode!

# Now Rust panics show meaningful stack traces
```
<!-- SPDX-SnippetEnd -->

## Debugging Rendering Issues

### print_buffer

The `print_buffer` method outputs the current terminal buffer to STDOUT with full ANSI colors. Call it inside `with_test_terminal` to see exactly what would render.

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
with_test_terminal do
  MyApp.new.render
  print_buffer  # Outputs the screen with colors
end
```
<!-- SPDX-SnippetEnd -->

### buffer_content

The `buffer_content` method returns the terminal buffer as an array of strings (one per row). Use it for programmatic inspection.

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
with_test_terminal do
  MyApp.new.render
  pp buffer_content  # ["Line 1: ...", "Line 2: ...", ...]
end
```
<!-- SPDX-SnippetEnd -->

### get_cell

The `get_cell(x, y)` method returns a `Buffer::Cell` with the character, foreground color, background color, and modifiers at specific coordinates.

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
with_test_terminal do
  MyApp.new.render
  cell = get_cell(0, 0)
  pp cell.symbol  # "H"
  pp cell.fg      # :red
  pp cell.bold?   # true
end
```
<!-- SPDX-SnippetEnd -->

## Protecting Output

During a TUI session, writes to `$stdout` or `$stderr` corrupt the display. Third-party gems often print warnings or debug output unexpectedly.

Use `guard_io` to temporarily swallow output from chatty code.

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
RatatuiRuby.run do |tui|
  RatatuiRuby.guard_io do
    SomeChattyGem.process  # Any puts/warn calls are swallowed
  end
end
```
<!-- SPDX-SnippetEnd -->

## Interactive Debuggers

> [!WARNING]
> This section has not been verified by a human.

> [!CAUTION]
> Traditional interactive debuggers (Pry, IRB, debug.gem) do not work inside an active TUI session. They require terminal input and output, which conflicts with raw mode.

### Workarounds

**Temporarily exit TUI mode.** Restore the terminal, run your debugger, then re-initialize.

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
RatatuiRuby.restore_terminal
binding.pry  # Now Pry works normally
RatatuiRuby.init_terminal
```
<!-- SPDX-SnippetEnd -->

**Use test mode.** Debug rendering logic inside `with_test_terminal` where there is no real terminal conflict.

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
with_test_terminal do
  binding.pry  # Works fine in test mode
  MyApp.new.render
end
```
<!-- SPDX-SnippetEnd -->

**Log to a file.** Write debug output to a log file instead of stdout.

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
DEBUG_LOG = File.open("debug.log", "a")

def debug(msg)
  DEBUG_LOG.puts("[#{Time.now}] #{msg}")
  DEBUG_LOG.flush
end
```
<!-- SPDX-SnippetEnd -->

## Error Classes

RatatuiRuby provides semantic exception classes for different failure modes:

| Class | Meaning |
|-------|---------|
| `RatatuiRuby::Error::Terminal` | I/O failure (backend crashed, terminal unavailable) |
| `RatatuiRuby::Error::Safety` | Lifetime violation (using Frame after draw block exits) |
| `RatatuiRuby::Error::Invariant` | Contract violation (double init, headless mode conflict) |

Catch these specifically instead of rescuing `StandardError` broadly.

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
begin
  RatatuiRuby.run { |tui| ... }
rescue RatatuiRuby::Error::Terminal => e
  puts "Terminal I/O failed: #{e.message}"
rescue RatatuiRuby::Error::Safety => e
  puts "API misuse: #{e.message}"
end
```
<!-- SPDX-SnippetEnd -->

## Further Reading

- [Application Testing Guide](application_testing.md) — Test helpers, snapshots, event injection
- [RatatuiRuby::Debug](../lib/ratatui_ruby/debug.rb) — Debug module source
