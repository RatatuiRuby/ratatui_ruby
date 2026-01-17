<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Website Menu Verification

Verifies the inline menu example on the [RatatuiRuby website](https://ratatui-ruby.dev).

This example exists as a documentation regression test. It ensures the website's inline viewport menu demo remains functional.

## Usage

```ruby
choices = ["Production", "Staging", "Development"]
index = 0

RatatuiRuby.run(viewport: :inline, height: 5) do |tui|
  loop do
    tui.draw do |frame|
      items = choices.map.with_index do |c, i|
        prefix = i == index ? "● " : "○ "
        "#{prefix}#{c}"
      end
      widget = tui.paragraph(
        text: items.join("\n"),
        block: tui.block(
          borders: :all,
          title: "Select Environment",
          titles: [{ content: "↑/↓ Enter | Ctrl+C", position: :bottom, alignment: :right }]
        )
      )
      frame.render_widget(widget, frame.area)
    end

    case tui.poll_event
    in { type: :key, code: "up" }
      index = (index - 1) % choices.size
    in { type: :key, code: "down" }
      index = (index + 1) % choices.size
    in { type: :key, code: "enter" } | { type: :key, code: "c", modifiers: ["ctrl"] }
      area = tui.viewport_area
      RatatuiRuby.cursor_position = [0, area.y + area.height]
      break
    else nil
    end
  end
end

puts
puts "Deploying to #{choices[index]}..."
```

## Features Demonstrated

- **Inline viewport**: 5-line viewport with bordered menu
- **Keyboard navigation**: Arrow keys for selection, Enter to confirm
- **Ctrl+C handling**: Graceful exit on cancellation
- **Bottom title**: Key hints rendered on the bottom border
- **Cursor positioning**: Proper cursor placement after inline viewport exit
