# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"

# Styled List Example
# Demonstrates advanced styling options for the List widget.
class ListStylesApp
  attr_reader :selected_index, :highlight_spacing

  HIGHLIGHT_SPACING_MODES = %i[when_selected always never].freeze

  def initialize
    @items = ["Item 1", "Item 2", "Item 3"]
    @selected_index = nil
    @direction = :top_to_bottom
    @highlight_spacing = :when_selected
  end

  def run
    RatatuiRuby.init_terminal
    begin
      loop do
        render
        break if handle_input == :quit
        sleep 0.05
      end
    ensure
      RatatuiRuby.restore_terminal
    end
  end

  def render
    selection_label = @selected_index.nil? ? "none" : @selected_index.to_s
    RatatuiRuby.draw(
      RatatuiRuby::List.new(
        items: @items,
        selected_index: @selected_index,
        style: RatatuiRuby::Style.new(fg: :white, bg: :black),
        highlight_style: RatatuiRuby::Style.new(fg: :blue, bg: :white, modifiers: [:bold]),
        highlight_symbol: ">> ",
        highlight_spacing: @highlight_spacing,
        direction: @direction,
        block: RatatuiRuby::Block.new(
          title: "(S)pacing: #{@highlight_spacing} | sel: #{selection_label} | (X) toggle | Q quit",
          borders: [:all]
        )
      )
    )
  end

  def handle_input
    case RatatuiRuby.poll_event
    in {type: :key, code: "q"} | {type: :key, code: "c", modifiers: ["ctrl"]}
      :quit
    in type: :key, code: "up"
      @selected_index = (@selected_index || 0) - 1
      @selected_index = @items.size - 1 if @selected_index.negative?
    in type: :key, code: "down"
      @selected_index = ((@selected_index || -1) + 1) % @items.size
    in type: :key, code: "d"
      @direction = (@direction == :top_to_bottom) ? :bottom_to_top : :top_to_bottom
    in type: :key, code: "s"
      current_idx = HIGHLIGHT_SPACING_MODES.index(@highlight_spacing)
      @highlight_spacing = HIGHLIGHT_SPACING_MODES[(current_idx + 1) % HIGHLIGHT_SPACING_MODES.size]
    in type: :key, code: "x"
      @selected_index = @selected_index.nil? ? 0 : nil
    else
      nil
    end
  end
end

ListStylesApp.new.run if __FILE__ == $PROGRAM_NAME
