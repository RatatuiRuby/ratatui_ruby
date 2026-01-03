# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Demo: Scrollable Paragraph
# Shows how to scroll through long text content using arrow keys
#
# Helper: Disable experimental warnings since we use line_count/line_width
RatatuiRuby.experimental_warnings = false

class WidgetScrollText
  def run
    RatatuiRuby.run do |tui|
      @tui = tui
      @scroll_x = 0
      @scroll_y = 0

      @lines = (1..100).map do |i|
        "Line #{i}: " + ("This is a long line of text that can be scrolled horizontally. " * 3) + "End of line #{i}"
      end
      @hotkey_style = @tui.style(modifiers: [:bold, :underlined])

      loop do
        draw
        break if handle_input == :quit
      end
    end
  end

  def render
    # No-op for compatibility if needed, or alias to draw, but draw now uses @tui
    draw
  end

  def handle_input
    case @tui.poll_event
    in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
      :quit
    in type: :key, code: "up"
      @scroll_y = [@scroll_y - 1, 0].max
    in type: :key, code: "down"
      @scroll_y = [@scroll_y + 1, @lines.length].min
    in type: :key, code: "left"
      @scroll_x = [@scroll_x - 1, 0].max
    in type: :key, code: "right"
      @scroll_x = [@scroll_x + 1, 100].min
    else
      nil
    end
  end

  private def draw
    @tui.draw do |frame|
      layout = @tui.layout_split(
        frame.area,
        direction: :vertical,
        constraints: [
          @tui.constraint_fill(1),
          @tui.constraint_length(5),
        ]
      )

      text = @lines.join("\n")

      # Main content
      main_paragraph = @tui.paragraph(
        text:,
        scroll: [@scroll_y, @scroll_x],
        block: @tui.block(
          title: "Scrollable Text (#{text.lines.count} lines)",
          borders: [:all]
        )
      )
      frame.render_widget(main_paragraph, layout[0])

      # Bottom control panel
      control_text = [
        @tui.text_line(spans: [
          @tui.text_span(content: "NAVIGATION (Size: #{main_paragraph.line_count(65535)}x#{main_paragraph.line_width})", style: @tui.style(modifiers: [:bold])),
        ]),
        @tui.text_line(spans: [
          @tui.text_span(content: "↑/↓", style: @hotkey_style),
          @tui.text_span(content: ": Vert Scroll (#{@scroll_y}/#{main_paragraph.line_count(65535)})  "),
          @tui.text_span(content: "←/→", style: @hotkey_style),
          @tui.text_span(content: ": Horz Scroll (#{@scroll_x}/#{main_paragraph.line_width})  "),
          @tui.text_span(content: "q", style: @hotkey_style),
          @tui.text_span(content: ": Quit"),
        ]),
      ]

      control_paragraph = @tui.paragraph(
        text: control_text,
        block: @tui.block(
          title: "Controls",
          borders: [:all]
        )
      )
      frame.render_widget(control_paragraph, layout[1])
    end
  end
end

WidgetScrollText.new.run if __FILE__ == $PROGRAM_NAME
