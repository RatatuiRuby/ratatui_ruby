# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"

class BoxDemoApp
  def initialize
    @color = "green"
    @border_type = :plain
    @text = "Press Arrow Keys (q to quit)\nSpace to switch border type\nEnter to cycle Title Alignment"
    @title_alignment = :left
  end

  def run
    RatatuiRuby.init_terminal
    begin
      loop do
        render
        break if handle_input == :quit
      end
    ensure
      RatatuiRuby.restore_terminal
    end
  end

  def render
    # 1. State/View
    block = RatatuiRuby::Block.new(
      title: "Box Demo - #{@border_type}",
      title_alignment: @title_alignment,
      borders: [:all],
      border_color: @color,
      border_type: @border_type
    )

    view_tree = RatatuiRuby::Paragraph.new(
      text: @text,
      fg: @color,
      block:
    )

    # 2. Render
    RatatuiRuby.draw(view_tree)
  end

  def next_border_type
    types = [:plain, :rounded, :double, :thick, :quadrant_inside, :quadrant_outside]
    current_index = types.index(@border_type) || 0
    @border_type = types[(current_index + 1) % types.length]
  end

  def next_title_alignment
    alignments = [:left, :center, :right]
    current_index = alignments.index(@title_alignment) || 0
    @title_alignment = alignments[(current_index + 1) % alignments.length]
  end

  def handle_input
    # 3. Events
    event = RatatuiRuby.poll_event
    return unless event

    if event[:type] == :key
      case event[:code]
      when "q"
        :quit
      when "up"
        @color = "red"
        @text = "Up Pressed!"
      when "down"
        @color = "blue"
        @text = "Down Pressed!"
      when "left"
        @color = "yellow"
        @text = "Left Pressed!"
      when "right"
        @color = "magenta"
        @text = "Right Pressed!"
      when " "
        next_border_type
        @text = "Switched to #{@border_type}"
      when "enter"
        next_title_alignment
        @text = "Aligned #{@title_alignment}"
      end
    end
  end
end

BoxDemoApp.new.run if __FILE__ == $0
