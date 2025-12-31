<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>

SPDX-License-Identifier: AGPL-3.0-or-later
-->

# Event Handling in RatatuiRuby

`ratatui_ruby` provides a rich, object-oriented event system that supports multiple coding styles, from simple boolean predicates to modern Ruby pattern matching.

Events are retrieved using `RatatuiRuby.poll_event`. This method returns an instance of a subclass of `RatatuiRuby::Event` (e.g., `RatatuiRuby::Event::Key`, `RatatuiRuby::Event::Mouse`). When no event is available, it returns `RatatuiRuby::Event::None`—a [null object](https://martinfowler.com/eaaCatalog/specialCase.html) that safely responds to all event predicates with `false`.

## 1. Symbol and String Comparison (Simplest)

For simple key events, `RatatuiRuby::Event::Key` objects can be compared directly to Symbols or Strings. This is often the quickest way to get started.

*   **String**: Matches the key character (e.g., "a", "q").
*   **Symbol**: Matches special keys (e.g., `:enter`, `:esc`) or modifier combinations (e.g., `:ctrl_c`).

> [!NOTE]
> On macOS, the **Option** key is mapped to `alt`. The **Command** key is typically intercepted by the terminal emulator and may not be sent to the application, or it may be mapped to Meta/Alt depending on your terminal settings.

For a complete list of supported keys, modifiers, and event types, please refer to the [API Documentation for RatatuiRuby::Event](file:///Users/kerrick/Developer/ratatui_ruby/lib/ratatui_ruby/event.rb).

```ruby
event = RatatuiRuby.poll_event

# 1. Check for quit keys
if event == "q" || event == :ctrl_c
  break
end

# 2. Check for special key
if event == :enter
  submit_form
end
```

## 2. Predicate Methods (Intermediate)

If you need more control or logic (e.g. `if/elsif`), or need to handle non-key events like Resize or Mouse, use the predicate methods.

### Polymorphic Predicates

Safe to call on *any* event object. They return `true` only for the matching event type.

Available: `key?`, `mouse?`, `resize?`, `paste?`, `focus_gained?`, `focus_lost?`.

```ruby
event = RatatuiRuby.poll_event

if event.key?
  handle_keypress(event)
elsif event.mouse?
  handle_click(event)
elsif event.resize?
  resize_layout(event.width, event.height)
end
```

### Helper Predicates

Specific to certain event classes to simplify checks.

#### `RatatuiRuby::Event::Key`
*   `ctrl?`, `alt?`, `shift?`: Check if modifier is held.
*   `text?`: Returns `true` if the event is a printable character (length == 1).

```ruby
if event.key? && event.ctrl? && event.code == "s"
  save_file
end
```

#### `RatatuiRuby::Event::Mouse`
*   `down?`, `up?`, `drag?`: Check mouse action.
*   `scroll_up?`, `scroll_down?`: Check scroll direction.

```ruby
if event.mouse? && event.scroll_up?
  scroll_view(-1)
end
```

## 3. Pattern Matching (Powerful)

For complex applications, Ruby 3.0+ Pattern Matching with the `type:` discriminator is the most idiomatic and concise approach.

```ruby
loop do
  case RatatuiRuby.poll_event
  
  # Match specific key code
  in type: :key, code: "q"
    break

  # Match complex combo
  in type: :key, code: "c", modifiers: ["ctrl"]
    break

  # Capture variables
  in type: :key, code: "up" | "down" => direction
    move_cursor(direction)

  # Match mouse events
  in type: :mouse, kind: "down", x:, y:
    handle_click(x, y)

  in type: :none
    # No event available, continue loop
  end
end
```

## Summary of Event Classes

| Event Class | Discriminator (`type:`) | Attributes | Predicate |
| :--- | :--- | :--- | :--- |
| `RatatuiRuby::Event::Key` | `:key` | `code`, `modifiers` | `key?` |
| `RatatuiRuby::Event::Mouse` | `:mouse` | `kind`, `x`, `y`, `button`, `modifiers` | `mouse?` |
| `RatatuiRuby::Event::Resize` | `:resize` | `width`, `height` | `resize?` |
| `RatatuiRuby::Event::Paste` | `:paste` | `content` | `paste?` |
| `RatatuiRuby::Event::FocusGained` | `:focus_gained` | (none) | `focus_gained?` |
| `RatatuiRuby::Event::FocusLost` | `:focus_lost` | (none) | `focus_lost?` |
| `RatatuiRuby::Event::None` | `:none` | (none) | `none?` |
