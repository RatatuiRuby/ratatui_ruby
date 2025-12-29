# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Demonstrates hit testing using Layout.split.
#
# This example shows how to calculate layout regions BEFORE drawing
# and use those regions to determine which panel was clicked.
#
# Controls:
#   - Left/Right arrows: Adjust split ratio
#   - Click: Detect which panel was clicked
#   - q: Quit
class HitTestApp
  def initialize
    @left_ratio = 50
    @message = "Click a panel or adjust ratio with ←/→"
    @last_click = nil
  end

  def run
    RatatuiRuby.run do
      loop do
        render
        break if handle_input == :quit
      end
    end
  end

  private

  def render
    # Calculate layout BEFORE drawing
    main_area = RatatuiRuby::Rect.new(x: 0, y: 0, width: 80, height: 24)
    @left_rect, @right_rect = RatatuiRuby::Layout.split(
      main_area,
      direction: :horizontal,
      constraints: [
        RatatuiRuby::Constraint.percentage(@left_ratio),
        RatatuiRuby::Constraint.percentage(100 - @left_ratio)
      ]
    )

    # Build UI with the calculated regions
    left_panel = build_panel("Left Panel", @left_rect, @last_click == :left)
    right_panel = build_panel("Right Panel", @right_rect, @last_click == :right)

    layout = RatatuiRuby::Layout.new(
      direction: :horizontal,
      constraints: [
        RatatuiRuby::Constraint.percentage(@left_ratio),
        RatatuiRuby::Constraint.percentage(100 - @left_ratio)
      ],
      children: [left_panel, right_panel]
    )

    RatatuiRuby.draw(layout)
  end

  def build_panel(title, rect, active)
    content = "#{title}\n\n" \
              "Width: #{rect.width}, Height: #{rect.height}\n" \
              "Position: (#{rect.x}, #{rect.y})\n\n" \
              "#{@message}"

    RatatuiRuby::Paragraph.new(
      text: content,
      align: :center,
      block: RatatuiRuby::Block.new(
        title: "#{title} (#{active ? 'CLICKED' : 'idle'})",
        borders: [:all],
        border_color: active ? "green" : "white"
      )
    )
  end

  def handle_input
    event = RatatuiRuby.poll_event
    return unless event

    case event
    in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
      return :quit
    in type: :key, code: "left"
      @left_ratio = [@left_ratio - 10, 10].max
      @message = "Ratio: #{@left_ratio}% / #{100 - @left_ratio}%"
      @last_click = nil
    in type: :key, code: "right"
      @left_ratio = [@left_ratio + 10, 90].min
      @message = "Ratio: #{@left_ratio}% / #{100 - @left_ratio}%"
      @last_click = nil
    in type: :mouse, kind: "down", x: click_x, y: click_y
      handle_click(click_x, click_y)
    else
      nil
    end
    nil
  end

  def handle_click(x, y)
    if @left_rect.contains?(x, y)
      @last_click = :left
      @message = "Left Panel clicked at (#{x}, #{y})"
    elsif @right_rect.contains?(x, y)
      @last_click = :right
      @message = "Right Panel clicked at (#{x}, #{y})"
    else
      @last_click = nil
      @message = "Clicked outside panels at (#{x}, #{y})"
    end
  end
end

HitTestApp.new.run if __FILE__ == $0
