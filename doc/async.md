<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Async Operations in TUI Applications

TUI applications fetch data from APIs, run shell commands, and query databases. These operations take time. Blocking the render loop freezes the interface.

You want responsive UIs. The checklist shows "Loading..." while data arrives. The interface never hangs.

This guide explains async patterns that work with raw terminal mode.

## The Raw Terminal Problem

`RatatuiRuby.run` enters raw terminal mode:

- stdin reconfigures for character-by-character input
- stdout carries terminal escape sequences
- External commands expecting normal terminal I/O fail

### What Breaks

```ruby
# These fail inside a Thread during raw mode:
`git ls-remote --tags origin`           # Returns empty or hangs
IO.popen(["git", "ls-remote", ...])     # Same
Open3.capture2("git", "ls-remote", ...) # Same
```

The commands succeed synchronously. They fail asynchronously. The difference: thread context inherits the parent's raw terminal state.

### Why Threads Fail

Ruby's GIL releases during I/O. But:

1. Subprocesses inherit the parent's terminal state.
2. Git/SSH try to read credentials from raw-mode stdin.
3. The read blocks forever. Or returns empty.

`GIT_TERMINAL_PROMPT=0` prevents prompts. Auth fails silently instead of hanging.

## Solutions

### Pre-Check Before Raw Mode

Run slow operations before entering the TUI:

```ruby
def initialize
  @data = fetch_data  # Runs before RatatuiRuby.run
end
```

**Trade-off**: Delays startup.

### Process.spawn with File Output

Spawn a separate process before entering raw mode. Write results to a temp file. Poll for completion:

```ruby
class AsyncChecker
  CACHE_FILE = File.join(Dir.tmpdir, "my_check_result.txt")

  def initialize
    @loading = true
    @result = nil
    @pid = Process.spawn("my-command > #{CACHE_FILE}")
  end

  def loading?
    return false unless @loading

    # Non-blocking poll
    _pid, status = Process.waitpid2(@pid, Process::WNOHANG)
    if status
      @result = File.read(CACHE_FILE).strip
      @loading = false
    end
    @loading
  end
end
```

**Key points**:

- `Process.spawn` returns immediately.
- The command runs in a separate process, not a thread.
- Results pass through a temp file. Avoids pipe/terminal issues.
- `Process::WNOHANG` polls without blocking.

### Thread for CPU-Bound Work

Ruby threads work for pure computation:

```ruby
Thread.new { @result = expensive_calculation }
```

Avoid threads for shell commands.

## Ractors

Ractors provide true parallelism. Trade-offs:

- No mutable shared state.
- Limited to Ractor-safe values.
- Terminal I/O issues remain.

For TUI async, `Process.spawn` solves the problem cleanly.

## Pattern Summary

| Approach | Use Case | Raw Mode Safe? |
|----------|----------|----------------|
| Sync before TUI | Fast checks (<100ms) | Yes |
| Process.spawn + file | Shell commands, network | Yes |
| Thread | CPU-bound Ruby code | Yes |
| Thread + shell | Shell commands | **No** |

## Real Example: Git Tag Check

Check if a tag exists on the remote:

```ruby
class GitRepo
  CACHE_FILE = File.join(Dir.tmpdir, "git_tag_pushed.txt")

  def initialize
    @version = `git describe --tags --abbrev=0`.strip
    @tag_pushed = nil
    @loading = true
    @pid = Process.spawn(
      "git ls-remote --tags origin | grep -q '#{@version}' " \
      "&& echo true > #{CACHE_FILE} || echo false > #{CACHE_FILE}"
    )
  end

  def loading?
    return false unless @loading

    _pid, status = Process.waitpid2(@pid, Process::WNOHANG)
    if status
      @tag_pushed = File.read(CACHE_FILE).strip == "true"
      @loading = false
    end
    @loading
  end

  def refresh
    # Sync version for manual refresh (user presses 'r')
    @loading = true
    remote_tags = `git ls-remote --tags origin`.strip
    @tag_pushed = remote_tags.include?(@version)
    @loading = false
  end
end
```

The TUI starts instantly. The tag check runs in the background. The checklist updates when the result arrives.
