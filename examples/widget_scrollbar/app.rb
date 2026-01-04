# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Demonstrates viewport navigation with interactive theme and orientation cycling.
#
# Content overflows. Users get lost in long lists without landmarks. They need to know where they are and how much is left.
#
# This demo showcases the <tt>Scrollbar</tt> widget. It provides an interactive playground where you can toggle orientations and cycle through different themes (Standard, Rounded, ASCII, Minimal) in real-time.
#
# Use it to understand how to provide spatial awareness and navigation cues for overflowing content.
#
# === Example
#
# Run the demo from the terminal:
#
#   ruby examples/widget_scrollbar/app.rb
#
# rdoc-image:/doc/images/widget_scrollbar.png
class WidgetScrollbar
  def initialize
    @scroll_position = 0
    @content_length = 50
    @lines = (1..@content_length).map { |i| "Line #{i}" }
    @orientation_index = 0
    @orientations = [
      :vertical,
      :vertical_right,
      :vertical_left,
      :horizontal,
      :horizontal_bottom,
      :horizontal_top,
    ]
    @theme_index = 0
    @themes = [
      {
        name: "Standard",
        track_symbol: nil,
        thumb_symbol: "█",
        track_style: nil,
        thumb_style: nil,
        begin_symbol: nil,
        end_symbol: nil,
      },
      {
        name: "Rounded",
        track_symbol: "│",
        thumb_symbol: "┃",
        track_style: { fg: "dark_gray" },
        thumb_style: { fg: "cyan" },
        begin_symbol: "▲",
        end_symbol: "▼",
      },
      {
        name: "ASCII",
        track_symbol: "|",
        thumb_symbol: "#",
        track_style: { fg: "white" },
        thumb_style: { fg: "red" },
        begin_symbol: "^",
        end_symbol: "v",
      },
      {
        name: "Minimal",
        track_symbol: " ",
        thumb_symbol: "▐",
        track_style: nil,
        thumb_style: { fg: "yellow" },
        begin_symbol: nil,
        end_symbol: nil,
      },
    ]
  end

  def run
    RatatuiRuby.run do |tui|
      @tui = tui
      loop do
        draw
        event = @tui.poll_event
        break if event == "q" || event == :ctrl_c

        handle_event(event)
      end
    end
  end

  private def handle_event(event)
    if event.mouse?
      case event.kind
      when "scroll_up"
        @scroll_position = [@scroll_position - 1, 0].max
      when "scroll_down"
        @scroll_position = [@scroll_position + 1, @content_length].min
      end
    end

    if event.key? && event.to_s == "s"
      @theme_index = (@theme_index + 1) % @themes.length
    end

    if event.key? && event.to_s == "o"
      @orientation_index = (@orientation_index + 1) % @orientations.length
    end
  end

  private def draw
    @tui.draw do |frame|
      # Calculate visible lines based on scroll position
      # In a real app, you'd want to know the height of the available area.
      # For this demo, we'll just show all lines but offset the text.
      visible_lines = @lines[@scroll_position..-1] || []

      # Paragraph with content
      theme = @themes[@theme_index]
      orientation = @orientations[@orientation_index]

      p = @tui.paragraph(
        text: visible_lines.join("\n"),
        block: @tui.block(
          titles: [
            { content: "Scroll with Mouse Wheel | Theme: #{theme[:name]} | Orientation: #{orientation}" },
            { content: "Press 's' to cycle theme, 'o' to cycle orientation", position: :bottom, alignment: :center },
          ],
          borders: [:all]
        )
      )

      # Scrollbar
      s = @tui.scrollbar(
        content_length: @content_length,
        position: @scroll_position,
        orientation:,
        track_symbol: theme[:track_symbol],
        thumb_symbol: theme[:thumb_symbol],
        track_style: theme[:track_style],
        thumb_style: theme[:thumb_style],
        begin_symbol: theme[:begin_symbol],
        end_symbol: theme[:end_symbol]
      )

      # Render paragraph first, then scrollbar on top
      frame.render_widget(p, frame.area)
      frame.render_widget(s, frame.area)
    end
  end
end

WidgetScrollbar.new.run if __FILE__ == $PROGRAM_NAME
