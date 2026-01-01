# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Demonstrates view segregation with interactive tab navigation.
#
# Screen real estate is limited. You cannot show everything at once. Segregating content into views is necessary for complex apps.
#
# This demo showcases the <tt>Tabs</tt> widget. It provides an interactive playground where you can select tabs, cycle through dividers and styles, and adjust padding in real-time.
#
# Use it to understand how to build major mode switches or context navigation for your interface.
#
# === Example
#
# Run the demo from the terminal:
#
#   ruby examples/widget_tabs_demo/app.rb
#
# rdoc-image:/doc/images/widget_tabs_demo.png
class WidgetTabsDemo
  def initialize
    @selected_tab = 0
    @tabs = ["Revenue", "Traffic", "Errors", "Quarterly"]
    @highlight_styles = nil
    @highlight_style_index = 0
    @divider_index = 0
    @dividers = [" | ", " • ", " > ", " / "]
    @base_styles = nil
    @base_style_index = 0
    @padding_left = 0
    @padding_right = 0
    @width_constraint_index = 0
    @hotkey_style = nil
  end

  def run
    RatatuiRuby.run do |tui|
      @tui = tui
      init_styles

      loop do
        render
        break if handle_input == :quit
      end
    end
  end

  private def init_styles
    @highlight_styles = [
      { name: "Yellow Bold", style: @tui.style(fg: :yellow, modifiers: [:bold]) },
      { name: "Italic Blue on White", style: @tui.style(fg: :blue, bg: :white, modifiers: [:italic]) },
      { name: "Underlined Red", style: @tui.style(fg: :red, modifiers: [:underlined]) },
      { name: "Reversed", style: @tui.style(modifiers: [:reversed]) },
    ]
    @base_styles = [
      { name: "Default", style: nil },
      { name: "White on Gray", style: @tui.style(fg: :white, bg: :dark_gray) },
      { name: "White on Blue", style: @tui.style(fg: :white, bg: :blue) },
      { name: "Italic", style: @tui.style(modifiers: [:italic]) },
    ]
    @hotkey_style = @tui.style(modifiers: [:bold, :underlined])
  end

  private def render
    @tui.draw do |frame|
      main_area, controls_area = @tui.layout_split(
        frame.area,
        direction: :vertical,
        constraints: [
          @tui.constraint_fill(1),
          @tui.constraint_length(5),
        ]
      )

      # Center the tabs vertically in the main area
      tabs_area, = @tui.layout_split(
        main_area,
        direction: :vertical,
        constraints: [
          @tui.constraint_length(3),
        ]
      )

      tabs = @tui.tabs(
        titles: @tabs,
        selected_index: @selected_tab,
        block: @tui.block(title: "Tabs Demo", borders: [:all]),
        divider: @dividers[@divider_index],
        highlight_style: @highlight_styles[@highlight_style_index][:style],
        style: @base_styles[@base_style_index][:style],
        padding_left: @padding_left,
        padding_right: @padding_right
      )
      frame.render_widget(tabs, tabs_area)

      render_controls(frame, controls_area, tabs.width)
    end
  end

  private def render_controls(frame, area, current_width)
    controls = @tui.block(
      title: "Controls",
      borders: [:all],
      children: [
        @tui.paragraph(
          text: [
            @tui.text_line(spans: [
              @tui.text_span(content: "←/→", style: @hotkey_style),
              @tui.text_span(content: ": Select Tab  "),
              @tui.text_span(content: "h/l", style: @hotkey_style),
              @tui.text_span(content: ": Pad Left (#{@padding_left})  "),
              @tui.text_span(content: "j/k", style: @hotkey_style),
              @tui.text_span(content: ": Pad Right (#{@padding_right})  "),
              @tui.text_span(content: "q", style: @hotkey_style),
              @tui.text_span(content: ": Quit"),
            ]),
            @tui.text_line(spans: [
              @tui.text_span(content: "d", style: @hotkey_style),
              @tui.text_span(content: ": Divider (#{@dividers[@divider_index]})  "),
              @tui.text_span(content: "s", style: @hotkey_style),
              @tui.text_span(content: ": Highlight (#{@highlight_styles[@highlight_style_index][:name]})  "),
              @tui.text_span(content: "b", style: @hotkey_style),
              @tui.text_span(content: ": Base Style (#{@base_styles[@base_style_index][:name]})  "),
            ]),
            @tui.text_line(spans: [
              @tui.text_span(content: "Width: #{current_width}"),
            ]),
          ]
        ),
      ]
    )
    frame.render_widget(controls, area)
  end

  private def handle_input
    case @tui.poll_event
    in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
      :quit
    in type: :key, code: "right"
      @selected_tab = (@selected_tab + 1) % @tabs.size
    in type: :key, code: "left"
      @selected_tab = (@selected_tab - 1) % @tabs.size
    in type: :key, code: "d"
      @divider_index = (@divider_index + 1) % @dividers.size
    in type: :key, code: "s"
      @highlight_style_index = (@highlight_style_index + 1) % @highlight_styles.size
    in type: :key, code: "b"
      @base_style_index = (@base_style_index + 1) % @base_styles.size
    in type: :key, code: "h"
      @padding_left = [@padding_left - 1, 0].max
    in type: :key, code: "l"
      @padding_left += 1
    in type: :key, code: "j"
      @padding_right = [@padding_right - 1, 0].max
    in type: :key, code: "k"
      @padding_right += 1
    else
      # Ignore other events
    end
  end
end

WidgetTabsDemo.new.run if __FILE__ == $0
