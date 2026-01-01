# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Custom widget that draws a diagonal line.
#
# Demonstrates absolute coordinate rendering respecting the given area bounds.
# This pattern is essential when custom widgets need to coexist with bordered blocks.
class DiagonalWidget
  def render(area)
    # Draw a diagonal line within the area's bounds.
    # The area parameter respects parent block borders and padding automatically.
    (0..10).filter_map do |i|
      next if i >= area.width || i >= area.height

      RatatuiRuby::Draw.string(
        area.x + i,
        area.y + i,
        "\\",
        RatatuiRuby::Style.new(fg: :red, modifiers: [:bold])
      )
    end
  end
end

# Custom widget that draws a checkerboard pattern.
#
# This pattern shows using the area's x, y offset correctly when rendering
# absolute coordinates. The area parameter may have x, y > 0 when rendered
# inside a positioned block. Always use area.x and area.y as offsets.
class CheckerboardWidget
  def initialize(char = "□")
    @char = char
  end

  def render(area)
    result = []
    (0...area.height).each do |row| # rubocop:disable Lint/AmbiguousRange
      (0...area.width).each do |col| # rubocop:disable Lint/AmbiguousRange
        next if (row + col).even?

        result << RatatuiRuby::Draw.string(
          area.x + col,
          area.y + row,
          @char,
          RatatuiRuby::Style.new(fg: :cyan)
        )
      end
    end
    result
  end
end

# Custom widget that draws a border inside the area.
#
# Demonstrates that custom widgets can compose complex shapes using the area's bounds.
# Here we draw a complete box (corners and edges) that fits within the area,
# respecting width and height constraints automatically.
class BorderWidget
  def render(area)
    result = []
    style = RatatuiRuby::Style.new(fg: :green)

    # Top and bottom
    (0...area.width).each do |x| # rubocop:disable Lint/AmbiguousRange
      result << RatatuiRuby::Draw.string(area.x + x, area.y, "─", style)
      result << RatatuiRuby::Draw.string(area.x + x, area.y + area.height - 1, "─", style)
    end

    # Left and right
    (0...area.height).each do |y| # rubocop:disable Lint/AmbiguousRange
      result << RatatuiRuby::Draw.string(area.x, area.y + y, "│", style)
      result << RatatuiRuby::Draw.string(area.x + area.width - 1, area.y + y, "│", style)
    end

    # Corners
    result << RatatuiRuby::Draw.string(area.x, area.y, "┌", style)
    result << RatatuiRuby::Draw.string(area.x + area.width - 1, area.y, "┐", style)
    result << RatatuiRuby::Draw.string(area.x, area.y + area.height - 1, "└", style)
    result << RatatuiRuby::Draw.string(area.x + area.width - 1, area.y + area.height - 1, "┘", style)

    result
  end
end

class WidgetRender
  def initialize
    @widget_index = 0
    @widgets = [
      { name: "Diagonal", widget: DiagonalWidget.new },
      { name: "Checkerboard", widget: CheckerboardWidget.new("□") },
      { name: "Border", widget: BorderWidget.new },
    ]
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
          @tui.constraint_length(4),
        ]
      )

      # Render a border block to frame widget area
      current_name = @widgets[@widget_index][:name]
      widget_block = @tui.block(
        title: "Custom Widget: #{current_name}",
        borders: [:all]
      )
      frame.render_widget(widget_block, layout[0])

      # Calculate the inner area, accounting for the block's 1-character border on all sides.
      # This is the key pattern: compute the available space INSIDE the block before
      # passing it to the custom widget's render method.
      # When the custom widget receives this area, all its absolute coordinates will
      # respect the block's boundaries automatically.
      inner_area = @tui.rect(
        x: layout[0].x + 1,
        y: layout[0].y + 1,
        width: [layout[0].width - 2, 0].max,
        height: [layout[0].height - 2, 0].max
      )

      # Render the custom widget inside the bordered area.
      # The widget's render method receives the inner_area and draws within it.
      frame.render_widget(@widgets[@widget_index][:widget], inner_area)

      # Render control panel with current widget info
      control_lines = [
        @tui.text_line(
          spans: [
            @tui.text_span(content: "n", style: @tui.style(modifiers: [:bold, :underlined])),
            @tui.text_span(content: ": Next  "),
            @tui.text_span(content: "p", style: @tui.style(modifiers: [:bold, :underlined])),
            @tui.text_span(content: ": Previous  "),
            @tui.text_span(content: "q", style: @tui.style(modifiers: [:bold, :underlined])),
            @tui.text_span(content: ": Quit"),
          ]
        ),
      ]
      controls = @tui.paragraph(
        text: control_lines,
        block: @tui.block(
          title: "Controls",
          borders: [:all]
        )
      )
      frame.render_widget(controls, layout[1])
    end
  end

  private def handle_input
    event = @tui.poll_event
    case event
    in { type: :key, code: "q" }
      :quit
    in { type: :key, code: "n" }
      @widget_index = (@widget_index + 1) % @widgets.length
    in { type: :key, code: "p" }
      @widget_index = (@widget_index - 1) % @widgets.length
    else
      # Ignore other events
    end
  end
end

WidgetRender.new.run if __FILE__ == $PROGRAM_NAME
