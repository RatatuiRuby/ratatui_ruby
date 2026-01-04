<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Debugging TUI Applications

TUI applications run in raw terminal mode. stderr and stdout carry terminal escape sequences. Using `puts` or `warn` inside the render loop corrupts the display.

This creates a problem: how do you inspect variables and trace execution?

Write debug output to files. Tail them in a separate terminal.

## File-Based Logging

Create timestamped log files to avoid overwrites:

```ruby
FileUtils.mkdir_p(File.join(Dir.tmpdir, "my_debug"))
timestamp = Time.now.strftime('%Y%m%d_%H%M%S_%N')
File.write(
  File.join(Dir.tmpdir, "my_debug", "#{timestamp}.log"),
  "variable=#{value.inspect}\n"
)
```

Or append to a single file:

```ruby
File.write("/tmp/debug.log", "#{Time.now}: #{message}\n", mode: "a")
```

Tail the logs in a separate terminal:

```bash
# Single file
tail -f /tmp/debug.log

# Directory of timestamped files
watch -n 0.5 'ls -la /tmp/my_debug/ && cat /tmp/my_debug/*.log'
```

## REPL Debugging with `__FILE__` Guards

Unit tests verify correctness. But during exploratory debugging, you want to poke at objects interactively. Loading the full TUI just to inspect one object is slow.

Wrap your main execution in a guard:

```ruby
if __FILE__ == $PROGRAM_NAME
  MyApp.new.run
end
```

Now load the file and interact with classes directly:

```bash
ruby -e 'load "./bin/my_tui"; obj = MyClass.new; sleep 1; puts obj.result'
```

This exercises domain logic without entering raw terminal mode. Use it for exploratory debugging. Write tests using the [TestHelper](application_testing.md) for regression coverage.

## Isolating Terminal Issues

Something works in a `ruby -e` script but fails in the TUI. Common causes:

1. **Thread context.** Ruby threads share the process's terminal state.
2. **Raw mode.** External commands fail when stdin/stdout are reconfigured.
3. **SSH/Git auth.** Commands that prompt for credentials hang or return empty.

See [Async Operations](async.md) for solutions.
