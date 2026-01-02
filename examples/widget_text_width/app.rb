# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

class WidgetTextWidth
  def initialize
    @text_samples = [
      { label: "ASCII", text: "Hello, World!", desc: "Simple English text" },
      { label: "CJK", text: "你好世界", desc: "Chinese (full-width characters)" },
      { label: "Emoji", text: "Hello 👍 World 🌍", desc: "Mixed text with emoji (2 cells each)" },
      { label: "Mixed", text: "Hi 你好 👍", desc: "ASCII + CJK + emoji" },
      { label: "Empty", text: "", desc: "Empty string" },
    ]
    @selected_index = 0
  end

  def run
    RatatuiRuby.run do |tui|
      @tui = tui
      loop do
        render
        break if handle_input == :quit
      end
    end
  end

  private def render
    @tui.draw do |frame|
      # Layout: main content above, controls below
      areas = @tui.layout_split(
        frame.area,
        direction: :vertical,
        constraints: [@tui.constraint_fill(1), @tui.constraint_length(7)]
      )

      # Main content area with sample text
      render_content(frame, areas[0])

      # Controls footer
      render_controls(frame, areas[1])
    end
  end

  private def render_content(frame, area)
    sample = @text_samples[@selected_index]
    measured_width = @tui.text_width(sample[:text])

    # Build content text with newlines
    content = []
    content << "Sample: #{sample[:text]}"
    content << ""
    content << "Display Width: #{measured_width} cells"
    content << "Character Count: #{sample[:text].length}"
    content << ""
    content << sample[:desc]
    text = content.join("\n")

    widget = @tui.paragraph(
      text:,
      block: @tui.block(
        title: "Text Width Calculator",
        borders: [:all],
        border_color: "cyan"
      ),
      alignment: :left
    )

    frame.render_widget(widget, area)
  end

  private def render_controls(frame, area)
    info = "Sample #{@selected_index + 1}/#{@text_samples.length}: #{@text_samples[@selected_index][:label]}"
    controls = "↑/↓ Select   q Quit"
    text = "#{info}\n#{controls}"

    widget = @tui.paragraph(
      text:,
      block: @tui.block(borders: [:top], border_color: "gray"),
      alignment: :center
    )

    frame.render_widget(widget, area)
  end

  private def handle_input
    event = @tui.poll_event
    case event
    in { type: :key, code: "q" }
      :quit
    in { type: :key, code: "up" }
      @selected_index = (@selected_index - 1) % @text_samples.length
      nil
    in { type: :key, code: "down" }
      @selected_index = (@selected_index + 1) % @text_samples.length
      nil
    else
      nil
    end
  end
end

WidgetTextWidth.new.run if __FILE__ == $PROGRAM_NAME
