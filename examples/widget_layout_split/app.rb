# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Demonstrates Layout.split with interactive attribute cycling.
#
# This widget showcase lets you explore all Layout.split parameters:
# - Direction: vertical/horizontal
# - Flex mode: legacy, start, center, end, space_between, space_around, space_evenly
# - Constraint types: Fill, Length, Percentage, Min, Ratio
class WidgetLayoutSplit
  DIRECTIONS = [
    { name: "Vertical", value: :vertical },
    { name: "Horizontal", value: :horizontal },
  ].freeze

  FLEX_MODES = [
    { name: "Legacy", value: :legacy },
    { name: "Start", value: :start },
    { name: "Center", value: :center },
    { name: "End", value: :end },
    { name: "Space Between", value: :space_between },
    { name: "Space Around", value: :space_around },
    { name: "Space Evenly", value: :space_evenly },
  ].freeze

  BLOCK_COLORS = %i[red green blue].freeze

  def initialize
    @direction_index = 0
    @flex_index = 0
    @constraint_index = 0
    @hotkey_style = nil
  end

  def run
    RatatuiRuby.run do |tui|
      @tui = tui
      @hotkey_style = tui.style(modifiers: [:bold, :underlined])
      @constraint_demos = build_constraint_demos

      loop do
        render
        break if handle_input == :quit
      end
    end
  end

  private def build_constraint_demos
    [
      {
        name: "Fill (1:2:1)",
        constraints: -> (dir) {
          [
            @tui.constraint_fill(1),
            @tui.constraint_fill(2),
            @tui.constraint_fill(1),
          ]
        },
      },
      {
        name: "Length (10/15/10)",
        constraints: -> (dir) {
          [
            @tui.constraint_length(10),
            @tui.constraint_length(15),
            @tui.constraint_length(10),
          ]
        },
      },
      {
        name: "Percentage (25/50/25)",
        constraints: -> (dir) {
          [
            @tui.constraint_percentage(25),
            @tui.constraint_percentage(50),
            @tui.constraint_percentage(25),
          ]
        },
      },
      {
        name: "Min (5/10/5)",
        constraints: -> (dir) {
          [
            @tui.constraint_min(5),
            @tui.constraint_min(10),
            @tui.constraint_min(5),
          ]
        },
      },
      {
        name: "Ratio (1:4, 2:4, 1:4)",
        constraints: -> (dir) {
          [
            @tui.constraint_ratio(1, 4),
            @tui.constraint_ratio(2, 4),
            @tui.constraint_ratio(1, 4),
          ]
        },
      },
      {
        name: -> (dir) { (dir == :vertical) ? "Mixed (Len 3, Fill, Pct 25)" : "Mixed (Len 20, Fill, Pct 25)" },
        constraints: -> (dir) {
          fixed = (dir == :vertical) ? 3 : 20
          [
            @tui.constraint_length(fixed),
            @tui.constraint_fill(1),
            @tui.constraint_percentage(25),
          ]
        },
      },
    ]
  end

  private def current_direction
    DIRECTIONS[@direction_index][:value]
  end

  private def current_flex
    FLEX_MODES[@flex_index][:value]
  end

  private def current_constraints
    demo = @constraint_demos[@constraint_index]
    demo[:constraints].call(current_direction)
  end

  private def current_constraint_name
    demo = @constraint_demos[@constraint_index]
    name = demo[:name]
    name.respond_to?(:call) ? name.call(current_direction) : name
  end

  private def render
    @tui.draw do |frame|
      # Split into main content and control panel
      main_area, controls_area = @tui.layout_split(
        frame.area,
        direction: :vertical,
        constraints: [
          @tui.constraint_fill(1),
          @tui.constraint_length(6),
        ]
      )

      render_demo_area(frame, main_area)
      render_controls(frame, controls_area)
    end
  end

  private def render_demo_area(frame, area)
    # Split demo area into title and content
    title_area, content_area = @tui.layout_split(
      area,
      direction: :vertical,
      constraints: [
        @tui.constraint_length(1),
        @tui.constraint_fill(1),
      ]
    )

    # Render title
    title = @tui.paragraph(
      text: "Layout.split Demo",
      style: @tui.style(modifiers: [:bold])
    )
    frame.render_widget(title, title_area)

    # Apply current layout settings to 3 colored blocks
    block_areas = @tui.layout_split(
      content_area,
      direction: current_direction,
      flex: current_flex,
      constraints: current_constraints
    )

    block_areas.each_with_index do |block_area, i|
      block = @tui.block(
        title: "Block #{i + 1}",
        borders: [:all],
        border_color: BLOCK_COLORS[i % BLOCK_COLORS.length]
      )
      frame.render_widget(block, block_area)
    end
  end

  private def render_controls(frame, area)
    controls = @tui.block(
      title: "Controls",
      borders: [:all],
      children: [
        @tui.paragraph(
          text: [
            # Row 1: Direction and Flex
            @tui.text_line(spans: [
              @tui.text_span(content: "d", style: @hotkey_style),
              @tui.text_span(content: ": Direction (#{DIRECTIONS[@direction_index][:name]})  "),
              @tui.text_span(content: "f", style: @hotkey_style),
              @tui.text_span(content: ": Flex (#{FLEX_MODES[@flex_index][:name]})"),
            ]),
            @tui.text_line(spans: [
              @tui.text_span(content: "c", style: @hotkey_style),
              @tui.text_span(content: ": Constraints (#{current_constraint_name})"),
            ]),
            # Row 3: Quit
            @tui.text_line(spans: [
              @tui.text_span(content: "q", style: @hotkey_style),
              @tui.text_span(content: ": Quit"),
            ]),
          ]
        ),
      ]
    )
    frame.render_widget(controls, area)
  end

  private def handle_input
    case @tui.poll_event
    in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
      :quit
    in type: :key, code: "d"
      @direction_index = (@direction_index + 1) % DIRECTIONS.length
    in type: :key, code: "f"
      @flex_index = (@flex_index + 1) % FLEX_MODES.length
    in type: :key, code: "c"
      @constraint_index = (@constraint_index + 1) % @constraint_demos.length
    else
      nil
    end
  end
end

WidgetLayoutSplit.new.run if __FILE__ == $PROGRAM_NAME
