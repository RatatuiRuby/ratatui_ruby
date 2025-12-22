# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"

class BoxDemoApp
  def initialize
    @color = "green"
    @text = "Press Arrow Keys (q to quit)"
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
      title: "Box Demo",
      borders: [:all],
      border_color: @color
    )

    view_tree = RatatuiRuby::Paragraph.new(
      text: @text,
      fg: @color,
      block:
    )

    # 2. Render
    RatatuiRuby.draw(view_tree)
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
      end
    end
  end
end

BoxDemoApp.new.run if __FILE__ == $0
