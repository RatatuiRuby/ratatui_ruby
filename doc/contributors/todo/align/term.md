<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# TERM Environment Variable Respect

Expose terminal capability detection so applications can degrade gracefully.

---

## Crossterm Audit (2026-01-17)

What crossterm actually exposes that we can wrap:

### Available Public APIs

| Function | Location | Notes |
|----------|----------|-------|
| `available_color_count()` | `src/style.rs:163` | Returns `u16`: 8, 256, or `u16::MAX` (truecolor). Checks `COLORTERM`, `TERM` env vars. |
| `force_color_output(bool)` | `src/style.rs:191` | Override `NO_COLOR` check globally. |
| `supports_keyboard_enhancement()` | `src/terminal/sys/unix.rs:188` | Requires `events` feature. Queries terminal via escape sequence. |
| `window_size()` | `src/terminal.rs:148` | Returns `WindowSize { columns, rows, width, height }` including **pixel dimensions**. |
| `supports_ansi()` | `src/ansi_support.rs:33` | **Windows only**. Checks VT processing + `TERM != "dumb"`. |

### Internal Logic (Not Exposed, But Informs Design)

From `src/style.rs:174-180`:
<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```rust
env::var("COLORTERM")
    .or_else(|_| env::var("TERM"))
    .map_or(DEFAULT, |x| match x {
        _ if x.contains("24bit") || x.contains("truecolor") => u16::MAX,
        _ if x.contains("256") => 256,
        _ => DEFAULT,  // 8 colors
    })
```
<!-- SPDX-SnippetEnd -->

From `src/ansi_support.rs:39-40` (Windows):
<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```rust
let supported = enable_vt_processing().is_ok()
    || std::env::var("TERM").map_or(false, |term| term != "dumb");
```
<!-- SPDX-SnippetEnd -->

### What Ratatui Exposes

The `Backend` trait in `ratatui-core/src/backend.rs` exposes:
- `size()` → `Result<Size>` (columns/rows)
- `window_size()` → `Result<WindowSize>` (columns/rows + pixels)

**No capability detection is exposed through ratatui itself.** We must call crossterm directly.

### Audit Summary

| Proposed API | Implementation | Source |
|--------------|----------------|--------|
| `tty?` | Pure Ruby | `$stdout.tty?` |
| `dumb?` | Pure Ruby | `ENV["TERM"]` |
| `no_color?` | Pure Ruby | `ENV.key?("NO_COLOR")` |
| `force_color?` | Pure Ruby | `ENV.key?("FORCE_COLOR")` |
| `color_support` | **Wrap crossterm** | `crossterm::style::available_color_count()` |
| `supports_keyboard_enhancement?` | **Wrap crossterm** | `crossterm::terminal::supports_keyboard_enhancement()` |
| `size_pixels` | **Wrap crossterm** | `crossterm::terminal::window_size().{width,height}` |
| `interactive?` | Pure Ruby | Combines `tty?` + `dumb?` |
| `suggested_style` | Pure Ruby | Derives from `color_support` |

---

## Problem Statement

Rust-based CLI libraries often ignore the `TERM` environment variable and assume modern terminal features. This causes issues in:

- **CI environments** — `TERM=dumb` or missing entirely
- **Piped output** — stdout isn't a TTY
- **Legacy terminals** — SSH to old systems, embedded devices
- **Accessibility** — Screen readers need simpler output
- **`NO_COLOR` movement** — Users explicitly disable color

RatatuiRuby currently provides no capability detection APIs. Applications cannot query terminal support before rendering.

---

## Proposed API

> [!NOTE]
> These capability detection methods integrate with the `Terminal` class design from [terminal.md](terminal.md).
> They are **class methods** on `RatatuiRuby::Terminal`, not a separate module.

### Phase 1: Environment Detection (Ruby-side)

Pure Ruby class methods using environment variables and standard library.

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
# lib/ratatui_ruby/terminal.rb (additions to existing Terminal class)
module RatatuiRuby
  class Terminal
    class << self
      # Is stdout connected to a terminal?
      def tty? = $stdout.tty?

      # Is this a dumb terminal with no capabilities?
      def dumb? = ENV["TERM"] == "dumb" || ENV["TERM"].to_s.empty?

      # Should color be disabled? (NO_COLOR standard)
      def no_color? = ENV.key?("NO_COLOR")

      # Should color be forced? (overrides tty? check)
      def force_color? = ENV.key?("FORCE_COLOR")

      # Detected color support level
      # :none    - No color (dumb terminal, NO_COLOR set, not a tty)
      # :basic   - 16 colors (standard ANSI)
      # :ansi256 - 256 colors
      # :truecolor - 24-bit RGB
      def color_support
        return :none if no_color? || dumb?
        return detect_color_level if tty? || force_color?
        :none
      end

      private

      def detect_color_level
        colorterm = ENV["COLORTERM"]
        return :truecolor if colorterm == "truecolor" || colorterm == "24bit"

        term = ENV["TERM"].to_s
        return :truecolor if term.include?("truecolor") || term.include?("24bit")
        return :ansi256 if term.include?("256color")
        return :basic if term.start_with?("xterm", "screen", "vt100", "linux")

        :basic # Conservative default for unknown terminals
      end
    end
  end
end
```
<!-- SPDX-SnippetEnd -->

### Phase 2: Crossterm Capability Queries (Rust-side)

Expose crossterm's runtime detection through Magnus bindings.

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```rust
// ext/ratatui_ruby/src/terminal_capabilities.rs

use crossterm::terminal;
use magnus::{function, Error, Module, Object};

/// Query if the terminal supports the Kitty keyboard protocol
pub fn supports_keyboard_enhancement() -> Result<bool, Error> {
    Ok(terminal::supports_keyboard_enhancement()
        .map_err(|e| Error::new(magnus::exception::runtime_error(), e.to_string()))?)
}

/// Query terminal size in pixels (if supported)
pub fn terminal_size_pixels() -> Result<Option<(u16, u16)>, Error> {
    match crossterm::terminal::window_size() {
        Ok(size) => Ok(Some((size.width, size.height))),
        Err(_) => Ok(None),
    }
}

pub fn register(ruby: &magnus::Ruby, module: &magnus::RModule) -> Result<(), Error> {
    module.define_module_function("_supports_keyboard_enhancement", 
        function!(supports_keyboard_enhancement, 0))?;
    module.define_module_function("_terminal_size_pixels",
        function!(terminal_size_pixels, 0))?;
    Ok(())
}
```
<!-- SPDX-SnippetEnd -->

Ruby wrapper (class methods on Terminal):

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
# lib/ratatui_ruby/terminal.rb (continued)
module RatatuiRuby
  class Terminal
    class << self
      # Does the terminal support the Kitty keyboard protocol?
      def supports_keyboard_enhancement?
        RatatuiRuby._supports_keyboard_enhancement
      rescue
        false
      end

      # Terminal size in pixels (for graphics protocols)
      # Returns { width:, height: } or nil if unsupported
      def size_pixels
        result = RatatuiRuby._terminal_size_pixels
        result ? { width: result[0], height: result[1] } : nil
      rescue
        nil
      end
    end
  end
end
```
<!-- SPDX-SnippetEnd -->

### Phase 3: Graceful Degradation Helpers

Convenience class methods for common patterns.

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
# lib/ratatui_ruby/terminal.rb (continued)
module RatatuiRuby
  class Terminal
    class << self
      # Should the application use TUI mode?
      # Returns false for dumb terminals, piped output, etc.
      def interactive?
        tty? && !dumb?
      end

      # Suggested style based on terminal capabilities
      def suggested_style
        case color_support
        when :none then :plain
        when :basic then :ansi16
        when :ansi256 then :ansi256
        when :truecolor then :truecolor
        end
      end
    end
  end
end
```
<!-- SPDX-SnippetEnd -->

---

## Implementation Plan

### Phase 1: Environment Detection

| File | Change |
|------|--------|
| [NEW] `lib/ratatui_ruby/terminal.rb` | `Terminal` module with `tty?`, `dumb?`, `no_color?`, `force_color?`, `color_support` |
| [NEW] `sig/ratatui_ruby/terminal.rbs` | RBS type declarations |
| [NEW] `test/test_terminal_capabilities.rb` | Unit tests with mocked ENV |
| [MODIFY] `lib/ratatui_ruby.rb` | Require the new module |

### Phase 2: Crossterm Queries

| File | Change |
|------|--------|
| [NEW] `ext/ratatui_ruby/src/terminal_capabilities.rs` | `supports_keyboard_enhancement`, `terminal_size_pixels` |
| [MODIFY] `ext/ratatui_ruby/src/lib.rs` | Register new module |
| [MODIFY] `lib/ratatui_ruby/terminal.rb` | Add `supports_keyboard_enhancement?`, `size_pixels` |
| [MODIFY] `sig/ratatui_ruby/terminal.rbs` | Add new method types |
| [MODIFY] `test/test_terminal_capabilities.rb` | Add integration tests |

### Phase 3: Convenience Methods

| File | Change |
|------|--------|
| [MODIFY] `lib/ratatui_ruby/terminal.rb` | Add `interactive?`, `suggested_style` |
| [MODIFY] `sig/ratatui_ruby/terminal.rbs` | Add new method types |
| [MODIFY] `test/test_terminal_capabilities.rb` | Add convenience method tests |

---

## Documentation Updates

| File | Change |
|------|--------|
| [NEW] `doc/concepts/terminal_capabilities.md` | Guide for capability detection |
| [MODIFY] `doc/troubleshooting/terminal_limitations.md` | Reference new detection APIs |
| [MODIFY] `CHANGELOG.md` | Document new feature |

---

## Verification Plan

### Automated Tests

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```bash
bundle exec rake test TEST=test/test_terminal_capabilities.rb
bundle exec steep check
```
<!-- SPDX-SnippetEnd -->

### Manual Verification

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```bash
# Test NO_COLOR respect
NO_COLOR=1 bundle exec ruby -e "require 'ratatui_ruby'; p RatatuiRuby::Terminal.color_support"
# Expected: :none

# Test dumb terminal
TERM=dumb bundle exec ruby -e "require 'ratatui_ruby'; p RatatuiRuby::Terminal.dumb?"
# Expected: true

# Test truecolor detection
COLORTERM=truecolor bundle exec ruby -e "require 'ratatui_ruby'; p RatatuiRuby::Terminal.color_support"
# Expected: :truecolor
```
<!-- SPDX-SnippetEnd -->

---

## References

- [NO_COLOR Standard](https://no-color.org/)
- [Crossterm Terminal Queries](https://docs.rs/crossterm/latest/crossterm/terminal/index.html)
- [Kitty Keyboard Protocol](https://sw.kovidgoyal.net/kitty/keyboard-protocol/)
- [terminfo(5)](https://man7.org/linux/man-pages/man5/terminfo.5.html)
