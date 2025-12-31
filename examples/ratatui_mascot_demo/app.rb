# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: CC-BY-SA-4.0

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

class RatatuiMascotDemoApp
  def initialize
    @show_block = true
  end

  def run
    RatatuiRuby.run do |tui|
      loop do
        render(tui)
        break if handle_input(tui) == :quit
      end
    end
  end

  private def render(tui)
    # Layout: Top (Mascot), Bottom (Controls)
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

    # Layout: Top (Mascot), Bottom (Controls)
    layout = tui.layout(
      direction: :vertical,
      constraints: [
        RatatuiRuby::Constraint.fill(1),
        RatatuiRuby::Constraint.length(4),
      ],
      children: [
        mascot,
        controls_paragraph,
      ]
    )

    tui.draw(layout)
  end

  private def handle_input(tui)
    event = tui.poll_event
    return unless event

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

RatatuiMascotDemoApp.new.run if __FILE__ == $PROGRAM_NAME
