<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Debugging TUI Applications

Debugging TUI applications is challenging because stderr output interferes with the raw terminal mode. This guide covers techniques for debugging ratatui_ruby applications.

## File-Based Logging

Since you can't use `puts` or `warn` in raw terminal mode, write debug output to files:

```ruby
# Write to a timestamped log file
FileUtils.mkdir_p(File.join(Dir.tmpdir, "my_debug"))
File.write(
  File.join(Dir.tmpdir, "my_debug", "#{Time.now.strftime('%Y%m%d_%H%M%S_%N')}.log"),
  "variable=#{value.inspect}\n"
)

# Or append to a single log file
File.write("/tmp/debug.log", "#{Time.now}: #{message}\n", mode: "a")
```

Then tail the logs in a separate terminal:

```bash
tail -f /tmp/debug.log
# Or watch a directory of timestamped files:
watch -n 0.5 'ls -la /tmp/my_debug/ && cat /tmp/my_debug/*.log'
```

## Using `__FILE__` Guards for REPL Testing

Wrap your main execution in a guard so you can `load` the file and test domain objects interactively:

```ruby
# At the end of your script:
if __FILE__ == $PROGRAM_NAME
  MyApp.new.run
end
```

Now you can test individual classes:

```bash
ruby -e 'load "./bin/my_tui"; obj = MyClass.new; sleep 1; puts obj.result'
```

This lets you exercise domain logic without entering raw terminal mode.

## Isolating Terminal Issues

If something works in a `ruby -e` script but fails in the TUI:

1. **Thread context** - Ruby threads share the process's terminal state
2. **Raw mode** - External commands may fail when stdin/stdout are in raw mode
3. **SSH/Git auth** - Commands that need terminal prompts will hang or fail

See [Async Operations](async.md) for solutions to these issues.
