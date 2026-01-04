# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: CC-BY-SA-4.0

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Demonstrates personality and charm with the project mascot.
#
# Interfaces without personality feel clinical and dry. Users appreciate a friendly face in their terminal.
#
# This demo showcases the <tt>RatatuiMascot</tt> widget. It provides an interactive playground where you can toggle the surrounding block.
#
# Use it to understand how to add a playful touch to your terminal dashboards or about screens.
#
# === Example
#
# Run the demo from the terminal:
#
#   ruby examples/widget_ratatui_mascot/app.rb
#
# rdoc-image:/doc/images/widget_ratatui_mascot.png
class WidgetRatatuiMascot
  def initialize
    @show_block = true
  end

  def run
    RatatuiRuby.run do |tui|
      loop do
        tui.draw do |frame|
          # Layout: Top (Mascot), Bottom (Controls)
          layout = tui.layout_split(
            frame.area,
            direction: :vertical,
            constraints: [
              tui.constraint_fill(1),
              tui.constraint_length(4),
            ]
          )

          mascot_area = layout[0]
          controls_area = layout[1]

          # Mascot Widget
          block = if @show_block
            tui.block(
              title: "Ratatui Mascot",
              borders: [:all],
              border_type: :rounded,
              border_style: { fg: :green }
            )
          end

          mascot = tui.ratatui_mascot(block:)
          frame.render_widget(mascot, mascot_area)

          # Controls
          controls_text = [
            tui.text_span(content: "q", style: tui.style(modifiers: [:bold, :underlined])),
            tui.text_span(content: " Quit"),
            tui.text_span(content: "   "),
            tui.text_span(content: "b", style: tui.style(modifiers: [:bold, :underlined])),
            tui.text_span(content: " Toggle Block #{@show_block ? '(On)' : '(Off)'}"),
          ]

          controls_paragraph = tui.paragraph(
            text: tui.text_line(spans: controls_text),
            block: tui.block(borders: [:top], title: "Controls")
          )
          frame.render_widget(controls_paragraph, controls_area)
        end
        break if handle_input(tui) == :quit
      end
    end
  end

  private def handle_input(tui)
    event = tui.poll_event

    if event.key?
      case event.char
      when "q" then :quit
      when "b" then @show_block = !@show_block
      end
    elsif event.ctrl_c?
      :quit
    end
  end
end

WidgetRatatuiMascot.new.run if __FILE__ == $PROGRAM_NAME
