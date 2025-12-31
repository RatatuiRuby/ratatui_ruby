# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Demonstrates Fill & Flex layout constraints with various flex modes.
class AppFlexLayout
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
    header = @tui.paragraph(
      text: "Fill & Flex Layout Demo (press 'q' to quit)",
      block: @tui.block(title: "Header", borders: [:all])
    )

    fill_blocks = build_fill_blocks
    space_between_blocks = build_space_between_blocks
    space_evenly_blocks = build_space_evenly_blocks
    ratio_blocks = build_ratio_blocks

    @tui.draw do |frame|
      header_area, fill_area, space_between_area, space_evenly_area, ratio_area = @tui.layout_split(
        frame.area,
        direction: :vertical,
        constraints: [
          @tui.constraint_length(3),
          @tui.constraint_fill(1),
          @tui.constraint_fill(1),
          @tui.constraint_fill(1),
          @tui.constraint_fill(1),
        ]
      )

      frame.render_widget(header, header_area)

      # Fill demo row: 1:3 ratio
      fill_1_area, fill_3_area = @tui.layout_split(
        fill_area,
        direction: :horizontal,
        constraints: [
          @tui.constraint_fill(1),
          @tui.constraint_fill(3),
        ]
      )
      frame.render_widget(fill_blocks[0], fill_1_area)
      frame.render_widget(fill_blocks[1], fill_3_area)

      # Space between demo row
      block_a_area, block_b_area, block_c_area = @tui.layout_split(
        space_between_area,
        direction: :horizontal,
        flex: :space_between,
        constraints: [
          @tui.constraint_length(12),
          @tui.constraint_length(12),
          @tui.constraint_length(12),
        ]
      )
      frame.render_widget(space_between_blocks[0], block_a_area)
      frame.render_widget(space_between_blocks[1], block_b_area)
      frame.render_widget(space_between_blocks[2], block_c_area)

      # Space evenly demo row
      even_a_area, even_b_area, even_c_area = @tui.layout_split(
        space_evenly_area,
        direction: :horizontal,
        flex: :space_evenly,
        constraints: [
          @tui.constraint_length(12),
          @tui.constraint_length(12),
          @tui.constraint_length(12),
        ]
      )
      frame.render_widget(space_evenly_blocks[0], even_a_area)
      frame.render_widget(space_evenly_blocks[1], even_b_area)
      frame.render_widget(space_evenly_blocks[2], even_c_area)

      # Ratio demo row: 1:4 and 3:4
      ratio_1_area, ratio_3_area = @tui.layout_split(
        ratio_area,
        direction: :horizontal,
        constraints: [
          @tui.constraint_ratio(1, 4),
          @tui.constraint_ratio(3, 4),
        ]
      )
      frame.render_widget(ratio_blocks[0], ratio_1_area)
      frame.render_widget(ratio_blocks[1], ratio_3_area)
    end
  end

  private def build_fill_blocks
    [
      @tui.block(title: "Fill(1)", borders: [:all], border_color: "red"),
      @tui.block(title: "Fill(3)", borders: [:all], border_color: "blue"),
    ]
  end

  private def build_space_between_blocks
    [
      @tui.block(title: "Block A", borders: [:all], border_color: "green"),
      @tui.block(title: "Block B", borders: [:all], border_color: "yellow"),
      @tui.block(title: "Block C", borders: [:all], border_color: "magenta"),
    ]
  end

  private def build_space_evenly_blocks
    [
      @tui.block(title: "Even A", borders: [:all], border_color: "cyan"),
      @tui.block(title: "Even B", borders: [:all], border_color: "blue"),
      @tui.block(title: "Even C", borders: [:all], border_color: "red"),
    ]
  end

  private def build_ratio_blocks
    [
      @tui.block(title: "Ratio(1, 4)", borders: [:all], border_color: "green"),
      @tui.block(title: "Ratio(3, 4)", borders: [:all], border_color: "magenta"),
    ]
  end

  private def handle_input
    event = @tui.poll_event

    case event
    in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
      :quit
    else
      nil
    end
  end
end

AppFlexLayout.new.run if __FILE__ == $PROGRAM_NAME
