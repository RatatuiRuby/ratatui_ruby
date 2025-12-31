# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Frame Demo App
# Demonstrates RatatuiRuby.draw block syntax, Layout.split, and explicit hit-testing.
class AppFrameDemo
  def initialize
    @selected_index = 0
    @items = ["Dashboard", "Analytics", "Settings", "Logs", "Help"]
    @sidebar_rect = nil
    @main_rect = nil
    @last_action = "Application Started"
    @click_count = 0
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
    # New Draw API: Receive the frame object
    RatatuiRuby.draw do |frame|
      # 1. Use Layout.split to divide the frame's area
      # This returns Array<Rect> which we can use for rendering AND hit-testing
      layout = RatatuiRuby::Layout.split(
        frame.area,
        direction: :horizontal,
        constraints: [
          RatatuiRuby::Constraint.length(20), # Fixed sidebar width
          RatatuiRuby::Constraint.fill(1), # Remaining space for main content
        ]
      )

      # Store rects for hit-testing in handle_input
      @sidebar_rect = layout[0]
      @main_rect = layout[1]

      # 2. Render Sidebar
      render_sidebar(frame, @sidebar_rect)

      # 3. Render Main Area
      render_main_area(frame, @main_rect)
    end
  end

  private def render_sidebar(frame, area)
    sidebar = RatatuiRuby::List.new(
      items: @items,
      selected_index: @selected_index,
      highlight_style: RatatuiRuby::Style.new(fg: :black, bg: :white, modifiers: [:bold]),
      block: RatatuiRuby::Block.new(title: "Menu", borders: [:all]),
      highlight_symbol: "> "
    )

    frame.render_widget(sidebar, area)
  end

  private def render_main_area(frame, area)
    text_content = [
      RatatuiRuby::Text::Line.new(spans: [
        RatatuiRuby::Text::Span.new(content: "Active View: ", style: RatatuiRuby::Style.new(modifiers: [:bold])),
        RatatuiRuby::Text::Span.new(content: @items[@selected_index], style: RatatuiRuby::Style.new(fg: :green)),
      ]),
      RatatuiRuby::Text::Line.new(spans: []),
      RatatuiRuby::Text::Line.new(spans: [
        RatatuiRuby::Text::Span.new(content: "Last Action: ", style: RatatuiRuby::Style.new(modifiers: [:bold])),
        RatatuiRuby::Text::Span.new(content: @last_action),
      ]),
      RatatuiRuby::Text::Line.new(spans: [
        RatatuiRuby::Text::Span.new(content: "Total Clicks: ", style: RatatuiRuby::Style.new(modifiers: [:bold])),
        RatatuiRuby::Text::Span.new(content: @click_count.to_s),
      ]),
      RatatuiRuby::Text::Line.new(spans: []),
      RatatuiRuby::Text::Line.new(spans: [
        RatatuiRuby::Text::Span.new(content: "Frame Dimensions: ", style: RatatuiRuby::Style.new(modifiers: [:bold])),
        RatatuiRuby::Text::Span.new(content: "#{frame.area.width}x#{frame.area.height}"),
      ]),
      RatatuiRuby::Text::Line.new(spans: [
        RatatuiRuby::Text::Span.new(content: "Sidebar Area: ", style: RatatuiRuby::Style.new(modifiers: [:bold])),
        RatatuiRuby::Text::Span.new(content: @sidebar_rect.inspect),
      ]),
      RatatuiRuby::Text::Line.new(spans: []),
      RatatuiRuby::Text::Line.new(spans: [
        RatatuiRuby::Text::Span.new(content: "Controls:", style: RatatuiRuby::Style.new(modifiers: [:underlined])),
      ]),
      RatatuiRuby::Text::Line.new(spans: [
        RatatuiRuby::Text::Span.new(content: "- Click sidebar items to select"),
      ]),
      RatatuiRuby::Text::Line.new(spans: [
        RatatuiRuby::Text::Span.new(content: "- Click main area to log coordinates"),
      ]),
      RatatuiRuby::Text::Line.new(spans: [
        RatatuiRuby::Text::Span.new(content: "- Press 'q' to quit"),
      ]),
    ]

    paragraph = RatatuiRuby::Paragraph.new(
      text: text_content,
      block: RatatuiRuby::Block.new(title: "Details", borders: [:all])
    )

    frame.render_widget(paragraph, area)
  end

  private def handle_input
    case RatatuiRuby.poll_event
    in type: :key, code: "q"
      :quit
    in type: :mouse, kind: "down", x: x, y: y
      @click_count += 1
      handle_click(x, y)
    else
      # Ignore other events
    end
  end

  private def handle_click(x, y)
    if @sidebar_rect&.contains?(x, y)
      # Calculate index based on relative Y position
      # Sidebar has a block with borders, so content starts at y+1
      relative_y = y - @sidebar_rect.y - 1

      if relative_y >= 0 && relative_y < @items.size
        old_selection = @items[@selected_index]
        @selected_index = relative_y
        new_selection = @items[@selected_index]
        @last_action = "Sidebar: #{old_selection} -> #{new_selection}"
      else
        @last_action = "Clicked Sidebar (Empty Area)"
      end
    elsif @main_rect&.contains?(x, y)
      @last_action = "Clicked Main Area at (#{x}, #{y})"
    end
  end
end

if __FILE__ == $0
  AppFrameDemo.new.run
end
