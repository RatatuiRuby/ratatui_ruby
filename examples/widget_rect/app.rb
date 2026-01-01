# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Rect Widget Showcase
#
# Demonstrates the Rect class and the Cached Layout Pattern.
#
# Rect is the fundamental geometry primitive for TUI layout. This example shows:
# - Rect attributes: x, y, width, height
# - Rect#contains? for hit testing mouse clicks
# - Layout.split returning cached rects for reuse
# - The layout caching pattern: compute in draw, reuse in handle_input
#
# Controls:
#   ←/→: Adjust sidebar width
#   ↑/↓: Navigate menu items
#   Mouse: Click panels to test Rect#contains?
#   q: Quit
class WidgetRect
  MENU_ITEMS = ["Dashboard", "Analytics", "Settings", "Logs", "Help"].freeze

  def initialize
    @sidebar_width = 20
    @selected_index = 0
    @last_action = "Click any panel to test Rect#contains?"
    @click_count = 0
    @sidebar_rect = nil
    @main_rect = nil
    @controls_rect = nil
  end

  def run
    RatatuiRuby.run do |tui|
      @tui = tui
      @hotkey_style = @tui.style(modifiers: [:bold, :underlined])
      @label_style = @tui.style(modifiers: [:bold])
      @dim_style = @tui.style(fg: :dark_gray)

      loop do
        render
        break if handle_input == :quit
      end
    end
  end

  private def render
    @tui.draw do |frame|
      @main_rect, @controls_rect = @tui.layout_split(
        frame.area,
        direction: :vertical,
        constraints: [
          @tui.constraint_fill(1),
          @tui.constraint_length(8),
        ]
      )

      @sidebar_rect, @content_rect = @tui.layout_split(
        @main_rect,
        direction: :horizontal,
        constraints: [
          @tui.constraint_length(@sidebar_width),
          @tui.constraint_fill(1),
        ]
      )

      render_sidebar(frame)
      render_content(frame)
      render_controls(frame)
    end
  end

  private def render_sidebar(frame)
    sidebar = @tui.list(
      items: MENU_ITEMS,
      selected_index: @selected_index,
      highlight_style: @tui.style(fg: :black, bg: :white, modifiers: [:bold]),
      highlight_symbol: "> ",
      block: @tui.block(title: "Menu", borders: [:all])
    )
    frame.render_widget(sidebar, @sidebar_rect)
  end

  private def render_content(frame)
    text_content = [
      @tui.text_line(spans: [
        @tui.text_span(content: "Active View: ", style: @label_style),
        @tui.text_span(content: MENU_ITEMS[@selected_index], style: @tui.style(fg: :green)),
      ]),
      "",
      @tui.text_line(spans: [
        @tui.text_span(content: "Rect Attributes ", style: @label_style),
        @tui.text_span(content: "(from Layout.split):", style: @dim_style),
      ]),
      "  Sidebar: Rect(x:#{@sidebar_rect.x}, y:#{@sidebar_rect.y}, " \
        "width:#{@sidebar_rect.width}, height:#{@sidebar_rect.height})",
      "  Content: Rect(x:#{@content_rect.x}, y:#{@content_rect.y}, " \
        "width:#{@content_rect.width}, height:#{@content_rect.height})",
      "",
      @tui.text_line(spans: [
        @tui.text_span(content: "Hit Testing ", style: @label_style),
        @tui.text_span(content: "(Rect#contains?):", style: @dim_style),
      ]),
      "  Clicks: #{@click_count}  |  #{@last_action}",
    ]

    paragraph = @tui.paragraph(
      text: text_content,
      block: @tui.block(title: "Content", borders: [:all])
    )
    frame.render_widget(paragraph, @content_rect)
  end

  private def render_controls(frame)
    controls = @tui.block(
      title: "Controls",
      borders: [:all],
      children: [
        @tui.paragraph(
          text: [
            @tui.text_line(spans: [
              @tui.text_span(content: "LAYOUT", style: @label_style),
              @tui.text_span(content: "  "),
              @tui.text_span(content: "←", style: @hotkey_style),
              @tui.text_span(content: ": Shrink sidebar  "),
              @tui.text_span(content: "→", style: @hotkey_style),
              @tui.text_span(content: ": Expand sidebar  "),
              @tui.text_span(content: "(width: #{@sidebar_width})"),
            ]),
            @tui.text_line(spans: [
              @tui.text_span(content: "NAVIGATION", style: @label_style),
              @tui.text_span(content: "  "),
              @tui.text_span(content: "↑↓", style: @hotkey_style),
              @tui.text_span(content: ": Select menu item  "),
              @tui.text_span(content: "q", style: @hotkey_style),
              @tui.text_span(content: ": Quit"),
            ]),
            "",
            @tui.text_line(spans: [
              @tui.text_span(content: "HIT TESTING", style: @label_style),
              @tui.text_span(content: "  Click any panel → Rect#contains?(x, y) determines which rect was hit."),
            ]),
          ]
        ),
      ]
    )
    frame.render_widget(controls, @controls_rect)
  end

  private def handle_input
    case @tui.poll_event
    in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
      :quit
    in type: :key, code: "left"
      @sidebar_width = [@sidebar_width - 2, 10].max
      @last_action = "Layout changed: sidebar_width=#{@sidebar_width}"
      nil
    in type: :key, code: "right"
      @sidebar_width = [@sidebar_width + 2, 40].min
      @last_action = "Layout changed: sidebar_width=#{@sidebar_width}"
      nil
    in type: :key, code: "up"
      @selected_index = (@selected_index - 1) % MENU_ITEMS.size
      @last_action = "Selected: #{MENU_ITEMS[@selected_index]}"
      nil
    in type: :key, code: "down"
      @selected_index = (@selected_index + 1) % MENU_ITEMS.size
      @last_action = "Selected: #{MENU_ITEMS[@selected_index]}"
      nil
    in type: :mouse, kind: "down", x: click_x, y: click_y
      handle_click(click_x, click_y)
      nil
    else
      nil
    end
  end

  private def handle_click(x, y)
    @click_count += 1

    if @sidebar_rect&.contains?(x, y)
      relative_y = y - @sidebar_rect.y - 1
      if relative_y >= 0 && relative_y < MENU_ITEMS.size
        old_item = MENU_ITEMS[@selected_index]
        @selected_index = relative_y
        new_item = MENU_ITEMS[@selected_index]
        @last_action = "sidebar.contains?(#{x},#{y})=true → #{old_item}→#{new_item}"
      else
        @last_action = "sidebar.contains?(#{x},#{y})=true (empty area)"
      end
    elsif @content_rect&.contains?(x, y)
      @last_action = "content.contains?(#{x},#{y})=true"
    elsif @controls_rect&.contains?(x, y)
      @last_action = "controls.contains?(#{x},#{y})=true"
    else
      @last_action = "No rect contains (#{x},#{y})"
    end
  end
end

WidgetRect.new.run if __FILE__ == $0
