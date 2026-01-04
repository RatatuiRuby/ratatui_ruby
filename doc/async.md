<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Async Operations in TUI Applications

When building TUI applications that need to perform long-running operations (network requests, git commands, API calls), you need async patterns that work with raw terminal mode.

## The Raw Terminal Problem

When `RatatuiRuby.run` enters raw terminal mode:

- **stdin** is reconfigured for character-by-character input
- **stdout** is used for terminal escape sequences
- **External commands** that expect normal terminal I/O may hang or fail

### What Breaks

```ruby
# These will NOT work correctly inside a Thread during raw mode:
`git ls-remote --tags origin`           # Returns empty or hangs
IO.popen(["git", "ls-remote", ...])     # Same issue
Open3.capture2("git", "ls-remote", ...) # Same issue
```

The commands work fine when called directly (synchronously before entering raw mode), but fail when called from a background Thread.

## Solutions

### 1. Pre-Check Before Raw Mode (Simple)

Run slow operations synchronously before entering the TUI:

```ruby
def initialize
  @data = fetch_data  # Runs before RatatuiRuby.run
end
```

**Downside**: Delays TUI startup.

### 2. Process.spawn with File Output (Recommended)

Spawn a separate process before entering raw mode. The process runs independently and writes results to a temp file:

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
    
    # Non-blocking poll for process completion
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
- `Process.spawn` returns immediately, command runs in background
- `Process::WNOHANG` polls without blocking
- Results communicated via temp file (avoids pipe issues with raw mode)

### 3. Thread for CPU-Bound Work (Limited)

Ruby threads work fine for CPU-bound operations that don't need external I/O:

```ruby
Thread.new { @result = expensive_computation }
```

But avoid threads for shell commands during raw mode.

## Why Threads Fail with Shell Commands

Ruby's GIL (Global Interpreter Lock) releases during I/O, but:

1. The subprocess inherits the parent's terminal state
2. Git/SSH may try to read from the raw-mode terminal for auth prompts
3. This causes hangs or empty output

`GIT_TERMINAL_PROMPT=0` prevents prompts but causes authentication failures.

## Ractors

Ractors provide true parallelism but have their own complexity:
- Can't share mutable state
- Limited to Ractor-safe values
- May still have terminal I/O issues

For TUI applications, `Process.spawn` is usually the right choice.

## Pattern Summary

| Approach | Use Case | Raw Mode Safe? |
|----------|----------|----------------|
| Sync before TUI | Fast checks (<100ms) | Yes |
| Process.spawn + file | Shell commands, network | Yes |
| Thread | CPU-bound Ruby code | Yes |
| Thread + shell | ❌ Shell commands | **No** |
