<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Future Work

Ideas for post-v1.0.0 development. These do not block the initial release.

---

## Port Upstream Ratatui Examples

Ratatui ships [example applications](https://github.com/ratatui/ratatui/tree/main/examples) demonstrating real-world patterns. Porting these to RatatuiRuby would:

1. Validate API parity in realistic usage
2. Provide learning resources for Ruby developers
3. Surface gaps in the alignment audit

**Candidates for porting:**

- `demo2` — Kitchen sink showcasing all widgets
- `async` — Background task handling
- `user_input` — Text input patterns
- `popup` — Modal dialogs

---

## Cross-Platform Distribution

[CosmoRuby](https://github.com/igravious/cosmoruby) aims to build Ruby with [Cosmopolitan Libc](https://justine.lol/cosmopolitan/), producing single binaries that run on Linux, macOS, Windows, and BSD without recompilation.

**Gap:** RatatuiRuby is a native extension. CosmoRuby does not yet support native extensions.

**When this becomes viable:**

- CosmoRuby adds native extension support
- Demand emerges for single-binary TUI app distribution

---

## Terminal Graphics Protocols

Terminal graphics protocols (Sixel, Kitty graphics, iTerm2 inline images) bypass the character cell model. Supporting them requires extension points that do not exist today.

### What Third Parties Need

| Extension Point | Purpose | Status |
|-----------------|---------|--------|
| `Draw::RawCmd` | Write raw escape sequences, bypassing the cell buffer | Not available |
| Terminal capability queries | Detect if terminal supports Sixel, Kitty, etc. | Not available |
| Frame hooks | Run code before/after buffer flush | Not available |

### Why These Matter

The `ratatui-image` crate provides graphics support for Rust Ratatui apps. A `ratatui_ruby-sixels` gem could wrap it, but only if RatatuiRuby exposes:

1. **Raw output access** — Sixel data writes directly to stdout as escape sequences
2. **Capability detection** — Apps need to query terminal support before sending graphics
3. **Render coordination** — Graphics must be positioned after the cell buffer renders

### Implementation Sketch

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
# Proposed API (not implemented)

# 1. Raw draw command
class Draw
  RawCmd = Data.define(:bytes)
  def self.raw(bytes) = RawCmd.new(bytes:)
end

# 2. Terminal queries
RatatuiRuby.terminal_supports?(:sixel)      # => true/false
RatatuiRuby.terminal_supports?(:kitty)      # => true/false
RatatuiRuby.terminal_size_pixels             # => { width: 1920, height: 1080 }

# 3. Custom widget using raw output
class SixelImage
  def render(area)
    sixel_data = encode_image_as_sixel(@image, area)
    [RatatuiRuby::Draw.raw(sixel_data)]
  end
end
```
<!-- SPDX-SnippetEnd -->

---

## Custom Backends

Currently hardcoded to Crossterm. A third party might want:

- SSH backend (render to a remote terminal)
- Web backend (render to browser canvas)
- Recording backend (capture frames for replay)

**Gap:** No backend plugin architecture.

---

## Custom Event Sources

Currently hardcoded to Crossterm events. A third party might want:

- Network events (WebSocket messages as TUI events)
- File watcher events
- IPC events

**Gap:** No event source plugin architecture.

---

## Event Test Doubles

The TestHelper module provides `MockFrame` and `StubRect` for testing render logic in isolation. However, testing `handle_event` currently requires `init_test_terminal` and `inject_test_event`.

For pure unit tests of Kit components, stub event objects would be useful:

<!-- SPDX-SnippetBegin -->
<!--
  SPDX-FileCopyrightText: 2026 Kerrick Long
  SPDX-License-Identifier: MIT-0
-->
```ruby
# Proposed API (not implemented)
StubKeyEvent = Data.define(:code, :modifiers) do
  def initialize(code:, modifiers: [])
    super
  end

  def key? = true
  def mouse? = false
end

StubMouseEvent = Data.define(:kind, :button, :x, :y, :modifiers) do
  def initialize(kind:, button: "left", x:, y:, modifiers: [])
    super
  end

  def key? = false
  def mouse? = true
  def down? = kind == "down"
  def up? = kind == "up"
end

# Usage
event = StubKeyEvent.new(code: "a", modifiers: ["ctrl"])
result = component.handle_event(event)
assert_equal :consumed, result
```
<!-- SPDX-SnippetEnd -->

This would let developers test component event handling without terminal dependencies.

## Prioritization

When prioritizing post-1.0 work, consider:

1. **Port upstream examples** — Validates parity, provides learning resources
2. **`Draw::RawCmd`** — Lowest effort, highest impact for graphics support
3. **Terminal capability queries** — Required for any graphics work
4. **Backend plugins** — Large undertaking, defer until clear demand
5. **CosmoRuby** — Blocked on upstream; monitor progress
