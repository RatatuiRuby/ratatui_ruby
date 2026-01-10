<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
  SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Debugging Guide

TUI applications are harder to debug than typical Ruby programs. The terminal is in raw mode. Standard output corrupts the display. Debuggers that rely on REPL input conflict with the event loop. Rust panics produce cryptic stack traces without symbols.

This guide covers what RatatuiRuby offers and what works (and what does not) when debugging TUI apps.

## Debug Mode

RatatuiRuby ships with debug symbols in release builds. Call `RatatuiRuby::Debug.enable!` to get Rust backtraces with meaningful stack frames.

### Activation Methods

You can turn on debug features in three ways.

1. **Environment variable (Rust only):** `RUST_BACKTRACE=1` turns on Rust backtraces without Ruby-side debug features.

2. **Environment variable (full):** `RR_DEBUG=1` turns on full debug mode at process startup.

3. **Programmatic:** Call `RatatuiRuby.debug_mode!` or `RatatuiRuby::Debug.enable!`.

> [!WARNING]
> Debug mode opens a remote debugging socket. This is a **security vulnerability**. Do not use it in production. See [Remote Debugging](#remote-debugging) for details.

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

### Panics vs. Exceptions

Rust backtraces only appear for **panics** (unrecoverable crashes). When Rust code raises a Ruby exception (like `TypeError`), Ruby handles the backtrace. Rust provides the error message.

| Error Type | Backtrace | When It Happens |
|------------|-----------|-----------------|
| **Panic** | Rust stack trace | Internal Rust bug, `Debug.test_panic!` |
| **Exception** | Ruby stack trace | Type mismatch, invalid arguments |

The `RUST_BACKTRACE=1` environment variable and `Debug.enable!` affect panic backtraces. Exceptions always show Ruby backtraces, but RatatuiRuby includes **contextual error messages** showing the actual value that caused the error:

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```
# Without context (generic):
expected array for rows

# With context (RatatuiRuby):
expected array for rows, got 42
```
<!-- SPDX-SnippetEnd -->

## Inspecting the Buffer

The following methods help you debug rendering issues from tests or scripts.

### print_buffer

Outputs the current terminal buffer to STDOUT with full ANSI colors. Call it inside `with_test_terminal` to see exactly what would render.

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

Returns the terminal buffer as an array of strings (one per row). Use it for programmatic inspection.

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

Returns a `Buffer::Cell` with the character, foreground color, background color, and modifiers at specific coordinates.

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

## Remote Debugging

Debug mode uses [Ruby's `debug` gem](https://rubygems.org/gems/debug) for [remote debugging](https://github.com/ruby/debug?tab=readme-ov-file#readme). Attach from another terminal (or IDE or Chrome DevTools) while the TUI runs.

![Debugging Showcase](../images/app_debugging_showcase.gif)

For a hands-on demo, see the [Debugging Showcase](../../examples/app_debugging_showcase/README.md) example.

Debug mode loads the `debug` gem and creates a UNIX domain socket. Debuggers attach from another terminal. This works well for TUI apps since the main terminal is in raw mode.

### How It Works

- **`RR_DEBUG=1`**: Loads `debug/open`. The app stops at startup and waits for a debugger to attach.
- **`RatatuiRuby.debug_mode!`**: Loads `debug/open_nonstop`. The app continues running. Attach whenever you want.

Attach from another terminal with `rdbg --attach`.

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```sh
$ rdbg --attach
```
<!-- SPDX-SnippetEnd -->

> [!CAUTION]
> Remote debugging opens a backdoor to your application. This is a **security vulnerability**. The `debug/open_nonstop` mode is particularly dangerous because it allows attachment at any time. Do not run debug mode in production. Anyone who can access the socket can execute arbitrary code.

### Example: Debugging a Running TUI

Terminal 1 (your app):
<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```sh
$ ruby my_tui_app.rb
# App starts, TUI is running
# In your code: RatatuiRuby.debug_mode!
# Console shows: DEBUGGER: Debugger can attach via UNIX domain socket (...)
```
<!-- SPDX-SnippetEnd -->

Terminal 2 (debugger):
<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```sh
$ rdbg --attach
# Now you have a full debugger REPL
(rdbg) info locals
(rdbg) break MyApp#handle_key
(rdbg) continue
```
<!-- SPDX-SnippetEnd -->

### Requirements

Add the `debug` gem to your Gemfile:

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
gem "debug", ">= 1.0"
```
<!-- SPDX-SnippetEnd -->

If `RR_DEBUG=1` is set but the debug gem is missing, RatatuiRuby raises a `LoadError` with installation instructions.

## File Logging

You can write debug output to a log file instead of stdout.

### Basic Logging

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

Then tail the log in a separate terminal.

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```bash
tail -f debug.log
```
<!-- SPDX-SnippetEnd -->

### Timestamped Logging

For high-frequency logging (like inside a render loop), use timestamped files to avoid overwrites:

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
FileUtils.mkdir_p(File.join(Dir.tmpdir, "my_debug"))
timestamp = Time.now.strftime('%Y%m%d_%H%M%S_%N')
File.write(
  File.join(Dir.tmpdir, "my_debug", "#{timestamp}.log"),
  "variable=#{value.inspect}\n"
)
```
<!-- SPDX-SnippetEnd -->

Then tail the directory.

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```bash
watch -n 0.5 'ls -la /tmp/my_debug/ && cat /tmp/my_debug/*.log'
```
<!-- SPDX-SnippetEnd -->

## REPL Without the TUI

Unit tests verify correctness, but sometimes you want to poke at objects interactively. Wrap your main execution in a guard:

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
if __FILE__ == $PROGRAM_NAME
  MyApp.new.run
end
```
<!-- SPDX-SnippetEnd -->

Then load the file without entering raw mode.

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```bash
ruby -e 'load "./bin/my_tui"; obj = MyClass.new; puts obj.result'
```
<!-- SPDX-SnippetEnd -->

This exercises domain logic without the terminal conflict. Use it for exploration. Write tests with [TestHelper](application_testing.md) for regression coverage.

## Isolating Terminal Issues

Sometimes code works in a `ruby -e` script but fails in the TUI. Here are common causes.

1. **Thread context.** Ruby threads share the process's terminal state.
2. **Raw mode.** External commands fail when stdin/stdout are reconfigured.
3. **SSH/Git auth.** Commands that prompt for credentials hang or return empty.

See [Async Operations](./async.md) for solutions.

## Error Classes

RatatuiRuby has semantic exception classes for different failure modes:

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
- [RatatuiRuby::Debug](../../lib/ratatui_ruby/debug.rb) — Debug module source
