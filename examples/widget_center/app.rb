# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Center Widget
# Demonstrates how to center content horizontally and vertically
# with adjustable width/height percentages.
class WidgetCenter
  def initialize
    @width_percent = 50
    @height_percent = 50
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
      layout = @tui.layout_split(
        frame.area,
        direction: :vertical,
        constraints: [
          @tui.constraint_fill(1),
          @tui.constraint_length(3),
        ]
      )

      # 1. Main Area
      # Background block frames the centered content
      bg_block = @tui.block(
        title: "Center Widget",
        borders: [:all],
        style: @tui.style(fg: :gray)
      )
      frame.render_widget(bg_block, layout[0])

      # 2. Centered Content
      # The content itself is just a block with some text
      content = @tui.paragraph(
        text: [
          @tui.text_line(
            spans: [
              @tui.text_span(content: "Centered Area", style: @tui.style(modifiers: [:bold])),
            ],
            alignment: :center
          ),
          @tui.text_line(spans: []),
          @tui.text_line(spans: [@tui.text_span(content: "Width: #{@width_percent}%", style: @tui.style(fg: :cyan))], alignment: :center),
          @tui.text_line(spans: [@tui.text_span(content: "Height: #{@height_percent}%", style: @tui.style(fg: :magenta))], alignment: :center),
        ],
        block: @tui.block(
          title: "Child Widget",
          borders: [:all],
          style: @tui.style(fg: :white)
        ),
        alignment: :center
      )

      # Create the Center widget
      center_widget = @tui.center(
        child: content,
        width_percent: @width_percent,
        height_percent: @height_percent
      )

      # Render center widget into the main layout area
      frame.render_widget(center_widget, layout[0])

      # 3. Controls
      control_text = @tui.paragraph(
        text: [
          @tui.text_line(spans: [
            @tui.text_span(content: "←/→", style: @tui.style(modifiers: [:bold, :underlined])),
            @tui.text_span(content: ": Width  "),
            @tui.text_span(content: "↑/↓", style: @tui.style(modifiers: [:bold, :underlined])),
            @tui.text_span(content: ": Height  "),
            @tui.text_span(content: "q", style: @tui.style(modifiers: [:bold, :underlined])),
            @tui.text_span(content: ": Quit"),
          ]),
        ],
        block: @tui.block(borders: [:top], style: @tui.style(bg: :black))
      )
      frame.render_widget(control_text, layout[1])
    end
  end

  def handle_input
    case @tui.poll_event
    in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
      :quit
    in { type: :key, code: "left" }
      @width_percent = [@width_percent - 5, 5].max
    in { type: :key, code: "right" }
      @width_percent = [@width_percent + 5, 100].min
    in { type: :key, code: "up" }
      @height_percent = [@height_percent + 5, 100].min
    in { type: :key, code: "down" }
      @height_percent = [@height_percent - 5, 5].max
    else
      # Ignore other events
    end
  end
end

WidgetCenter.new.run if __FILE__ == $0
