# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Simple Scrollbar Demo
class ScrollbarDemoApp
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
      :horizontal_top
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
        end_symbol: nil
      },
      {
        name: "Rounded",
        track_symbol: "│",
        thumb_symbol: "┃",
        track_style: { fg: "dark_gray" },
        thumb_style: { fg: "cyan" },
        begin_symbol: "▲",
        end_symbol: "▼"
      },
      {
        name: "ASCII",
        track_symbol: "|",
        thumb_symbol: "#",
        track_style: { fg: "white" },
        thumb_style: { fg: "red" },
        begin_symbol: "^",
        end_symbol: "v"
      },
      {
        name: "Minimal",
        track_symbol: " ",
        thumb_symbol: "▐",
        track_style: nil,
        thumb_style: { fg: "yellow" },
        begin_symbol: nil,
        end_symbol: nil
      }
    ]
  end

  def run
    RatatuiRuby.run do
      loop do
        draw
        event = RatatuiRuby.poll_event
        break if event == "q" || event == :ctrl_c

        handle_event(event)
      end
    end
  end

  private def handle_event(event)
    return unless event

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
    # Calculate visible lines based on scroll position
    # In a real app, you'd want to know the height of the available area.
    # For this demo, we'll just show all lines but offset the text.
    visible_lines = @lines[@scroll_position..-1] || []

    # Paragraph with content
    theme = @themes[@theme_index]
    orientation = @orientations[@orientation_index]

    p = RatatuiRuby::Paragraph.new(
      text: visible_lines.join("\n"),
      block: RatatuiRuby::Block.new(
        titles: [
          { content: "Scroll with Mouse Wheel | Theme: #{theme[:name]} | Orientation: #{orientation}" },
          { content: "Press 's' to cycle theme, 'o' to cycle orientation", position: :bottom, alignment: :center }
        ],
        borders: [:all]
      )
    )

    # Scrollbar
    s = RatatuiRuby::Scrollbar.new(
      content_length: @content_length,
      position: @scroll_position,
      orientation: orientation,
      track_symbol: theme[:track_symbol],
      thumb_symbol: theme[:thumb_symbol],
      track_style: theme[:track_style],
      thumb_style: theme[:thumb_style],
      begin_symbol: theme[:begin_symbol],
      end_symbol: theme[:end_symbol]
    )

    # Use Overlay to stack Scrollbar on top of Paragraph.
    # The Scrollbar will position itself on the correct edge (top/bottom/left/right)
    # based on its orientation, demonstrating that the property works independently of layout.
    overlay = RatatuiRuby::Overlay.new(
      layers: [p, s]
    )

    RatatuiRuby.draw(overlay)
  end
end

ScrollbarDemoApp.new.run if __FILE__ == $PROGRAM_NAME
