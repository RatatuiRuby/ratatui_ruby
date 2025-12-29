# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"

class BoxDemoApp
  def initialize
    @color = "green"
    @border_type = :plain
    @text = "Press Arrow Keys (q to quit)\nSpace: border type | Enter: title align | 's': style"
    @title_alignment = :left
    @style = nil
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
    effective_border_color = @style ? nil : @color

    block = RatatuiRuby::Block.new(
      title: "Box Demo - #{@border_type}",
      title_alignment: @title_alignment,
      borders: [:all],
      border_color: effective_border_color,
      border_type: @border_type,
      style: @style
    )

    # Paragraph supports style param, so we can pass the hash directly if present
    paragraph_params = { text: @text, block: block }
    if @style
      paragraph_params[:style] = @style
    else
      paragraph_params[:fg] = @color
    end

    view_tree = RatatuiRuby::Paragraph.new(**paragraph_params)

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

  def toggle_style
    @style = @style ? nil : { fg: "blue", bg: "white", modifiers: [:bold] }
  end

  def handle_input
    # 3. Events
    case RatatuiRuby.poll_event
    in RatatuiRuby::Event::Key(code: "q") | RatatuiRuby::Event::Key(code: "c", modifiers: ["ctrl"])
      :quit
    in RatatuiRuby::Event::Key(code: "up")
      @color = "red"
      @text = "Up Pressed!"
    in RatatuiRuby::Event::Key(code: "down")
      @color = "blue"
      @text = "Down Pressed!"
    in RatatuiRuby::Event::Key(code: "left")
      @color = "yellow"
      @text = "Left Pressed!"
    in RatatuiRuby::Event::Key(code: "right")
      @color = "magenta"
      @text = "Right Pressed!"
    in RatatuiRuby::Event::Key(code: " ")
      next_border_type
      @text = "Switched to #{@border_type}"
    in RatatuiRuby::Event::Key(code: "enter")
      next_title_alignment
      @text = "Aligned #{@title_alignment}"
    in RatatuiRuby::Event::Key(code: "s")
      toggle_style
      @text = "Style: #{@style ? 'Blue on White' : 'Default'}"
    else
      nil
    end
  end
end

BoxDemoApp.new.run if __FILE__ == $0
