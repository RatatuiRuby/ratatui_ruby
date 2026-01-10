# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: MIT-0
#++

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Rect Widget Showcase
#
# Demonstrates the Rect class and the Cached Layout Pattern.
#
# Rect is the fundamental geometry primitive for TUI layout. This example shows:
# - Rect attributes: x, y, width, height
# - Edge accessors: left, right, top, bottom
# - Geometry methods: area, empty?, union, inner, offset, clamp
# - Iterators: rows, columns, positions
# - Rect#contains? for hit testing mouse clicks
# - Layout.split returning cached rects for reuse
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
          @tui.constraint_length(5),
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
    r = @content_rect
    inner_r = r.inner(2)
    offset_r = r.offset(3, 2)
    bounds = RatatuiRuby::Layout::Rect.new(x: 0, y: 0, width: 50, height: 20)
    clamped = r.clamp(bounds)
    union_r = r.union(@sidebar_rect)

    # Extract position and size from rect
    pos = r.position # => Position(x:, y:)
    size = r.size    # => Size(width:, height:)

    text_content = [
      @tui.text_line(spans: [
        @tui.text_span(content: "Active View: ", style: @label_style),
        @tui.text_span(content: MENU_ITEMS[@selected_index], style: @tui.style(fg: :green)),
      ]),
      @tui.text_line(spans: [
        @tui.text_span(content: "Rect Attributes ", style: @label_style),
        @tui.text_span(content: "(from Layout.split):", style: @dim_style),
      ]),
      "  x:#{r.x} y:#{r.y} width:#{r.width} height:#{r.height}",
      @tui.text_line(spans: [
        @tui.text_span(content: "Edge Accessors:", style: @label_style),
      ]),
      "  left:#{r.left} right:#{r.right} top:#{r.top} bottom:#{r.bottom}",
      @tui.text_line(spans: [
        @tui.text_span(content: "Conversion Methods ", style: @label_style),
        @tui.text_span(content: "(as_position/as_size):", style: @dim_style),
      ]),
      "  Position: x=#{pos.x} y=#{pos.y}  Size: #{size.width}x#{size.height}",
      @tui.text_line(spans: [
        @tui.text_span(content: "Geometry Transformations:", style: @label_style),
      ]),
      "  inner(2): x:#{inner_r.x} y:#{inner_r.y} w:#{inner_r.width} h:#{inner_r.height}",
      "  offset(3,2): x:#{offset_r.x} y:#{offset_r.y}  clamp: x:#{clamped.x} y:#{clamped.y}",
      "  union(sidebar): w:#{union_r.width} h:#{union_r.height}",
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
              @tui.text_span(content: "←", style: @hotkey_style),
              @tui.text_span(content: "/"),
              @tui.text_span(content: "→", style: @hotkey_style),
              @tui.text_span(content: ": Sidebar width  "),
              @tui.text_span(content: "↑", style: @hotkey_style),
              @tui.text_span(content: "/"),
              @tui.text_span(content: "↓", style: @hotkey_style),
              @tui.text_span(content: ": Menu selection  "),
              @tui.text_span(content: "Click", style: @hotkey_style),
              @tui.text_span(content: ": Hit test  "),
              @tui.text_span(content: "q", style: @hotkey_style),
              @tui.text_span(content: ": Quit"),
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
