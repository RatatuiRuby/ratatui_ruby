# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Demonstrates hit testing using Layout.split with the Cached Layout Pattern.
#
# This example shows how to calculate layout regions *once per frame* and reuse
# those regions for both rendering and hit testing. This is essential for
# immediate-mode UI development where the same layout is used by multiple
# subsystems (render, event handling, etc.).
#
# Controls:
#   - Left/Right arrows: Adjust split ratio
#   - Click: Detect which panel was clicked
#   - q: Quit
class HitTestApp
  def initialize
    @left_ratio = 50
    @message = "Click a panel or adjust ratio"
    @last_click = nil
    @hotkey_style = RatatuiRuby::Style.new(modifiers: [:bold, :underlined])
  end

  def run
    RatatuiRuby.run do
      loop do
        calculate_layout  # Phase 1: Layout calculation (once per frame)
        render            # Phase 2: Draw to terminal
        break if handle_input == :quit  # Phase 3: Consume input using cached rects
      end
    end
  end

  private

  def calculate_layout
    # Single source of truth for layout geometry.
    # Calculated once per frame, then reused by render() and handle_input().
    full_area = RatatuiRuby::Rect.new(x: 0, y: 0, width: 80, height: 24)

    # First split: main content vs bottom controls.
    @main_area, @control_area = RatatuiRuby::Layout.split(
      full_area,
      direction: :vertical,
      constraints: [
        RatatuiRuby::Constraint.fill(1),
        RatatuiRuby::Constraint.length(7),
      ]
    )

    # Second split: within main content, left vs right panels.
    @left_rect, @right_rect = RatatuiRuby::Layout.split(
      @main_area,
      direction: :horizontal,
      constraints: [
        RatatuiRuby::Constraint.percentage(@left_ratio),
        RatatuiRuby::Constraint.percentage(100 - @left_ratio)
      ]
    )
  end

  def render
    # Build UI with the pre-calculated regions
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

    # Bottom control panel
    control_panel = RatatuiRuby::Block.new(
      title: "Controls",
      borders: [:all],
      children: [
        RatatuiRuby::Paragraph.new(
          text: [
            RatatuiRuby::Text::Line.new(spans: [
              RatatuiRuby::Text::Span.new(content: "RATIO", style: RatatuiRuby::Style.new(modifiers: [:bold]))
            ]),
            RatatuiRuby::Text::Line.new(spans: [
              RatatuiRuby::Text::Span.new(content: "←", style: @hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Decrease (#{@left_ratio}%)  "),
              RatatuiRuby::Text::Span.new(content: "→", style: @hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Increase (#{@left_ratio}%)  "),
              RatatuiRuby::Text::Span.new(content: "q", style: @hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Quit")
            ]),
            RatatuiRuby::Text::Line.new(spans: [
              RatatuiRuby::Text::Span.new(content: "HIT TESTING", style: RatatuiRuby::Style.new(modifiers: [:bold]))
            ]),
            "Click panels above to detect hits.",
            "Last Click: #{@last_click || 'None'} - #{@message}"
          ]
        )
      ]
    )

    # Full layout with bottom controls
    full_layout = RatatuiRuby::Layout.new(
      direction: :vertical,
      constraints: [
        RatatuiRuby::Constraint.fill(1),
        RatatuiRuby::Constraint.length(7),
      ],
      children: [layout, control_panel]
    )

    RatatuiRuby.draw(full_layout)
  end

  def build_panel(title, rect, active)
    content = "#{title}\n\n" \
              "Width: #{rect.width}, Height: #{rect.height}\n" \
              "Position: (#{rect.x}, #{rect.y})"

    RatatuiRuby::Paragraph.new(
      text: content,
      alignment: :center,
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
      @message = "Unhandled: #{event.class} #{event.inspect}"
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
