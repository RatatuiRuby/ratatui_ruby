<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Website Spinner Verification

Verifies the inline spinner example on the [RatatuiRuby website](https://ratatui-ruby.dev).

This example exists as a documentation regression test. It ensures the website's inline viewport spinner demo remains functional.

## Usage

```ruby
class Spinner
  def main
    RatatuiRuby.run(viewport: :inline, height: 1) do |tui|
      until connected?
        status = tui.paragraph(text: "#{spin} Connecting...")
        tui.draw { |frame| frame.render_widget(status, frame.area) }
        return ending(tui, "Canceled!", :red) if tui.poll_event.ctrl_c?
      end
      ending(tui, "Connected!", :green)
    end
  end

  def ending(tui, message, color) = tui.draw do |frame|
    frame.render_widget(tui.paragraph(text: message, fg: color), frame.area)
  end

  def initialize = (@i, @end = 0, Time.now + 2)
  def connected? = Time.now >= @end
  def spin = SPINNER[(@i += 1) % SPINNER.length]
  SPINNER = %w[⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏]
end
Spinner.new.main; puts
```

## Features Demonstrated

- **Inline viewport**: 1-line viewport that preserves terminal scrollback
- **Ctrl+C handling**: Graceful cancellation with `poll_event.ctrl_c?`
- **Colored output**: Status messages with `:red` and `:green` colors
- **Timeout pattern**: Uses `Time.now` for connection simulation
