# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"

# Styled List Example
# Demonstrates advanced styling options for the List widget.
class ListStylesApp
  attr_reader :selected_index

  def initialize
    @items = ["Item 1", "Item 2", "Item 3"]
    @selected_index = 0
    @direction = :top_to_bottom
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
    RatatuiRuby.draw(
      RatatuiRuby::List.new(
        items: @items,
        selected_index: @selected_index,
        style: RatatuiRuby::Style.new(fg: :white, bg: :black),
        highlight_style: RatatuiRuby::Style.new(fg: :blue, bg: :white, modifiers: [:bold]),
        highlight_symbol: ">> ",
        direction: @direction,
        block: RatatuiRuby::Block.new(
          title: "Styled List (Up/Down move, D direction, Q quit) - #{@direction}",
          borders: [:all]
        )
      )
    )
  end

  def handle_input
    case RatatuiRuby.poll_event
    in RatatuiRuby::Event::Key(code: "q") | RatatuiRuby::Event::Key(code: "c", modifiers: ["ctrl"])
      :quit
    in RatatuiRuby::Event::Key(code: "up")
      @selected_index = (@selected_index - 1) % @items.size
    in RatatuiRuby::Event::Key(code: "down")
      @selected_index = (@selected_index + 1) % @items.size
    in RatatuiRuby::Event::Key(code: "d")
      @direction = (@direction == :top_to_bottom) ? :bottom_to_top : :top_to_bottom
    else
      nil
    end
  end
end

ListStylesApp.new.run if __FILE__ == $PROGRAM_NAME
