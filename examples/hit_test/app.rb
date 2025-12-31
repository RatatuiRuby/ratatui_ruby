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
        render
        break if handle_input == :quit
      end
    end
  end

  private def render
    RatatuiRuby.draw do |frame|
      # Phase 1: Layout calculation (using Frame API)
      # We calculate layout directly from the frame area and cache the rects
      # for use in hit-testing (handle_input).

      # First split: main content vs bottom controls.
      @main_area, @control_area = RatatuiRuby::Layout.split(
        frame.area,
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
          RatatuiRuby::Constraint.percentage(100 - @left_ratio),
        ]
      )

      # Phase 2: Render widgets using the calculated regions

      # Build and render left/right panels
      left_panel = build_panel("Left Panel", @left_rect, @last_click == :left)
      right_panel = build_panel("Right Panel", @right_rect, @last_click == :right)

      frame.render_widget(left_panel, @left_rect)
      frame.render_widget(right_panel, @right_rect)

      # Build and render control panel
      control_panel = RatatuiRuby::Block.new(
        title: "Controls",
        borders: [:all],
        children: [
          RatatuiRuby::Paragraph.new(
            text: [
              RatatuiRuby::Text::Line.new(spans: [
                RatatuiRuby::Text::Span.new(content: "RATIO", style: RatatuiRuby::Style.new(modifiers: [:bold])),
              ]),
              RatatuiRuby::Text::Line.new(spans: [
                RatatuiRuby::Text::Span.new(content: "←", style: @hotkey_style),
                RatatuiRuby::Text::Span.new(content: ": Decrease (#{@left_ratio}%)  "),
                RatatuiRuby::Text::Span.new(content: "→", style: @hotkey_style),
                RatatuiRuby::Text::Span.new(content: ": Increase (#{@left_ratio}%)  "),
                RatatuiRuby::Text::Span.new(content: "q", style: @hotkey_style),
                RatatuiRuby::Text::Span.new(content: ": Quit"),
              ]),
              RatatuiRuby::Text::Line.new(spans: [
                RatatuiRuby::Text::Span.new(content: "HIT TESTING", style: RatatuiRuby::Style.new(modifiers: [:bold])),
              ]),
              "Click panels above to detect hits.",
              "Last Click: #{@last_click || 'None'} - #{@message}",
            ]
          ),
        ]
      )

      frame.render_widget(control_panel, @control_area)
    end
  end

  private def build_panel(title, rect, active)
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

  private def handle_input
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

  private def handle_click(x, y)
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
