# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Demonstrates branding visualization with the official logo.
#
# Branding is important for identity. Users need to recognize the tools they use.
#
# This demo showcases the <tt>RatatuiLogo</tt> widget. It renders the logo in a centered layout.
#
# Use it to understand how to incorporate the project's visual identity into your terminal application.
#
# === Example
#
# Run the demo from the terminal:
#
#   ruby examples/widget_ratatui_logo_demo/app.rb
#
# rdoc-image:/doc/images/widget_ratatui_logo_demo.png
class WidgetRatatuiLogoDemo
  def run
    RatatuiRuby.run do |tui|
      loop do
        render(tui)
        break if handle_input(tui) == :quit
      end
    end
  end

  private def render(tui)
    tui.draw do |frame|
      # Layout
      layout = tui.layout_split(
        frame.area,
        direction: :vertical,
        constraints: [
          tui.constraint_fill(1), # Fill remaining space
          tui.constraint_length(3),
        ]
      )

      # Main Area
      main_area = layout[0]

      # Center the logo using nested Layouts
      # Logo is roughly 47x8
      # Vertical Center
      v_center_layout = tui.layout_split(
        main_area,
        direction: :vertical,
        flex: :center,
        constraints: [tui.constraint_length(10)] # Height + margin
      )

      # Horizontal Center
      h_center_layout = tui.layout_split(
        v_center_layout[0],
        direction: :horizontal,
        flex: :center,
        constraints: [tui.constraint_length(50)] # Width + margin
      )

      # Main content: The Logo
      logo = RatatuiRuby::Widgets::RatatuiLogo.new
      frame.render_widget(logo, h_center_layout[0])

      # Control Panel
      control_area = layout[1]

      control_text = tui.text_line(spans: [
        tui.text_span(content: "q", style: tui.style(modifiers: [:bold, :underlined])),
        tui.text_span(content: ": Quit"),
      ])

      control_panel = tui.paragraph(
        text: [control_text],
        block: tui.block(
          title: "Controls",
          borders: [:top],
          style: tui.style(fg: :dark_gray)
        )
      )

      frame.render_widget(control_panel, control_area)
    end
  end

  private def handle_input(tui)
    case tui.poll_event
    in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
      :quit
    else
      nil
    end
  end
end

WidgetRatatuiLogoDemo.new.run if __FILE__ == $0
