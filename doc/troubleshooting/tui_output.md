<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Terminal Output During TUI Sessions

## The Problem

Writing to stdout or stderr during a TUI session **corrupts the display**.

When your application is running inside `RatatuiRuby.run`, the terminal is in "raw mode" and RatatuiRuby has taken control of the display buffer. Any output via `puts`, `warn`, `p`, `print`, or direct writes to `$stdout`/`$stderr` will:

1. **Corrupt the screen layout** - Characters appear in random positions
2. **Mix with TUI output** - Text interleaves with your widgets unpredictably
3. **Trigger escape sequence errors** - Partial ANSI codes can break rendering

## Why This Happens

In raw mode:
- The terminal doesn't process newlines or carriage returns normally
- Output bypasses the TUI's controlled buffer
- Cursor position is undefined from the TUI's perspective

## Safe Patterns

### Use `guard_io` to swallow output from gems

If you're using a gem that might write to stdout/stderr, wrap its calls:

```ruby
RatatuiRuby.run do |tui|
  RatatuiRuby.guard_io do
    SomeChattyGem.do_something  # Any puts/warn calls are swallowed
  end

  # Outside guard_io, you can still debug intentionally:
  # Object::STDERR.puts "debug: something"  # Escape hatch (corrupts display!)
end
```

### Defer output until after the TUI exits

```ruby
messages = []

RatatuiRuby.run do |tui|
  # Collect messages instead of printing them
  messages << "Something happened"
  
  # ... TUI logic ...
end

# Now safe to print
messages.each { |msg| puts msg }
```

### Use Logger to write to a file

The `Logger` class from Ruby's standard library is the idiomatic solution:

```ruby
require "logger"
require "tmpdir"

LOG = Logger.new(File.join(Dir.tmpdir, "my_app.log"))
LOG.level = Logger::DEBUG

RatatuiRuby.run do |tui|
  LOG.info "Application started"
  LOG.debug "Processing event: #{event.inspect}"

  # ... TUI logic ...
end
```

### Display messages in the TUI itself

```ruby
RatatuiRuby.run do |tui|
  @status_message = "Something happened"
  
  tui.draw do |frame|
    # Show status in the UI
    frame.render_widget(
      tui.paragraph(text: @status_message),
      status_area
    )
  end
end
```

## Library Behavior

RatatuiRuby automatically defers its own warnings (like experimental feature notices) during TUI sessions. They are queued and printed after `restore_terminal` is called.

You don't need to do anything special for library warnings—they're handled automatically.

## Bypassing guard_io

If you need to write to stdout/stderr even when `guard_io` is active (e.g., for [pipeline integration](#headless-mode-batchpipelinecli) or IPC), use the original IO constants:

```ruby
RatatuiRuby.guard_io do
  SomeChattyGem.do_something  # This is swallowed

  # But this gets through:
  Object::STDOUT.puts "structured output for downstream tools"
end
```

This works regardless of whether `guard_io` is active. During a TUI session, the display will be corrupted—but the output will reach its destination.

## Headless Mode (Batch/Pipeline/CLI)

If your app supports both TUI and non-TUI modes (e.g., `my_app --no-tui`), call `headless!` at startup to silence `guard_io` warnings:

```ruby
if ARGV.include?("--no-tui")
  RatatuiRuby.headless!
  # guard_io calls are now silent no-ops
  process_batch_work
else
  RatatuiRuby.run do |tui|
    # TUI mode - guard_io works normally
  end
end
```

When headless, `guard_io` becomes a no-op (output flows normally), and calling `run` or `init_terminal` raises an error.

## Temporarily Exiting TUI Mode

Some apps need to temporarily leave TUI mode for user interaction—like lazygit does when opening an external editor for commit messages. Use `restore_terminal` and `init_terminal`:

```ruby
RatatuiRuby.run do |tui|
  # ... TUI is active ...
  
  if user_wants_external_editor
    RatatuiRuby.restore_terminal
    
    # Now in normal terminal mode
    system("$EDITOR", filename)
    puts "Press Enter to return to the TUI..."
    gets
    
    RatatuiRuby.init_terminal
  end
  
  # ... TUI is active again ...
end
```

This pattern lets you hand control back to the user or spawn external processes that need normal terminal access.
