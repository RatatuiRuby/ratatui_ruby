<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Website Managed Loop Verification

Verifies the full-screen managed loop example on the [RatatuiRuby website](https://ratatui-ruby.dev).

This example exists as a documentation regression test. It ensures the website's "Build Something Real" managed loop demo remains functional.

## Usage

```ruby
RatatuiRuby.run do |tui|
  loop do
    tui.draw do |frame|
      frame.render_widget(
        tui.paragraph(
          text: "Hello, RatatuiRuby!",
          alignment: :center,
          block: tui.block(
            title: "My App",
            titles: [{ content: "q: Quit", position: :bottom, alignment: :right }],
            borders: [:all],
            border_style: { fg: "cyan" }
          )
        ),
        frame.area
      )
    end

    case tui.poll_event
    in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
      break
    else nil
    end
  end
end
```

## Features Demonstrated

- **Full-screen mode**: Alternate screen with automatic terminal restoration
- **Managed lifecycle**: `RatatuiRuby.run` handles setup/teardown
- **Block with titles**: Top title and bottom key hints
- **Keyboard handling**: `q` and `Ctrl+C` to quit
- **Pattern matching**: Ruby 3.x pattern matching for event handling
