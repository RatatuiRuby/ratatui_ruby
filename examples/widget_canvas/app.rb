# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Canvas Widget
# Demonstrates how to draw geometric shapes (Points, Lines, Rects, Circles)
# on a high-resolution canvas.
class WidgetCanvas
  def initialize
    @x_offset = 0.0
    @y_offset = 0.0
    @time = 0.0
  end

  def run
    RatatuiRuby.run do |tui|
      @tui = tui
      loop do
        # Animate
        @time += 0.1
        @x_offset = Math.sin(@time) * 20.0
        @y_offset = Math.cos(@time) * 20.0

        render
        break if handle_input == :quit

        sleep 0.05
      end
    end
  end

  private def render
    @tui.draw do |frame|
      # Define shapes
      shapes = []

      # 1. Static Grid (Lines)
      (-100..100).step(20) do |i|
        shapes << @tui.shape_line(x1: i.to_f, y1: -100.0, x2: i.to_f, y2: 100.0, color: :gray)
        shapes << @tui.shape_line(x1: -100.0, y1: i.to_f, x2: 100.0, y2: i.to_f, color: :gray)
      end

      # 2. Moving Circle (The "Player")
      shapes << @tui.shape_circle(
        x: @x_offset,
        y: @y_offset,
        radius: 10.0,
        color: :green
      )

      # 3. Static Rectangle (Target)
      shapes << @tui.shape_rectangle(
        x: 30.0,
        y: 30.0,
        width: 20.0,
        height: 20.0,
        color: :red
      )

      # 4. Points (Starfield)
      # Deterministic "random" points
      10.times do |i|
        shapes << @tui.shape_point(
          x: ((i * 37) % 200) - 100.0,
          y: ((i * 19) % 200) - 100.0
        )
      end

      # 5. Label
      shapes << @tui.shape_line(x1: 0.0, y1: 0.0, x2: @x_offset, y2: @y_offset, color: :yellow)

      canvas = @tui.canvas(
        shapes:,
        x_bounds: [-100.0, 100.0],
        y_bounds: [-100.0, 100.0],
        marker: :braille,
        block: @tui.block(title: "Canvas", borders: [:all])
      )

      # Main area for canvas
      layout = @tui.layout_split(
        frame.area,
        direction: :vertical,
        constraints: [
          @tui.constraint_fill(1),
          @tui.constraint_length(3),
        ]
      )

      frame.render_widget(canvas, layout[0])

      # Controls
      controls = @tui.paragraph(
        text: [
          @tui.text_line(spans: [
            @tui.text_span(content: "Canvas auto-animates.", style: @tui.style(fg: :yellow)),
          ]),
          @tui.text_line(spans: [
            @tui.text_span(content: "q", style: @tui.style(modifiers: [:bold, :underlined])),
            @tui.text_span(content: ": Quit"),
          ]),
        ],
        block: @tui.block(borders: [:top])
      )
      frame.render_widget(controls, layout[1])
    end
  end

  def handle_input
    case @tui.poll_event
    in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
      :quit
    else
      # Ignore other events
    end
  end
end

WidgetCanvas.new.run if __FILE__ == $0
