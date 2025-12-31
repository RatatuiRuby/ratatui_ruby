# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Rich Text Example
# Demonstrates the Span and Line objects for styling individual words
# within a block of text.
class WidgetRichText
  def initialize
    @scroll_pos = 0
  end

  def run
    RatatuiRuby.run do |tui|
      @tui = tui
      loop do
        render
        event = handle_input
        break if event == :quit
        sleep 0.05
      end
    end
  end

  private def render
    @tui.draw do |frame|
      layout = @tui.layout_split(
        frame.area,
        direction: :vertical,
        constraints: [
          @tui.constraint_percentage(50),
          @tui.constraint_percentage(50),
        ]
      )
      frame.render_widget(simple_text_line_example, layout[0])
      frame.render_widget(complex_example, layout[1])
    end
  end

  private def simple_text_line_example
    # Example 1: A line with mixed styles
    @tui.paragraph(
      text: @tui.text_line(
        spans: [
          @tui.text_span(
            content: "Normal text, ",
            style: nil
          ),
          @tui.text_span(
            content: "Bold Text",
            style: @tui.style(modifiers: [:bold])
          ),
          @tui.text_span(
            content: ", ",
            style: nil
          ),
          @tui.text_span(
            content: "Italic Text",
            style: @tui.style(modifiers: [:italic])
          ),
          @tui.text_span(
            content: ", ",
            style: nil
          ),
          @tui.text_span(
            content: "Red Text",
            style: @tui.style(fg: :red)
          ),
          @tui.text_span(
            content: ".",
            style: nil
          ),
        ]
      ),
      block: @tui.block(
        title: "Simple Rich Text",
        borders: [:all]
      )
    )
  end

  private def complex_example
    # Example 2: Multiple lines with different styles
    @tui.paragraph(
      text: [
        @tui.text_line(
          spans: [
            @tui.text_span(content: "✓ ", style: @tui.style(fg: :green, modifiers: [:bold])),
            @tui.text_span(content: "Feature Complete", style: nil),
            @tui.text_span(content: " - All tests passing", style: @tui.style(fg: :gray)),
          ]
        ),
        @tui.text_line(
          spans: [
            @tui.text_span(content: "⚠ ", style: @tui.style(fg: :yellow, modifiers: [:bold])),
            @tui.text_span(content: "Warning", style: nil),
            @tui.text_span(content: " - Documentation pending", style: @tui.style(fg: :gray)),
          ]
        ),
        @tui.text_line(
          spans: [
            @tui.text_span(content: "✗ ", style: @tui.style(fg: :red, modifiers: [:bold])),
            @tui.text_span(content: "Not Started", style: nil),
            @tui.text_span(content: " - Performance benchmarks", style: @tui.style(fg: :gray)),
          ]
        ),
        @tui.text_line(spans: []),
        @tui.text_line(
          spans: [
            @tui.text_span(content: "Press ", style: nil),
            @tui.text_span(content: "Q", style: @tui.style(modifiers: [:bold])),
            @tui.text_span(content: " to quit", style: nil),
          ]
        ),
      ],
      block: @tui.block(
        title: "Status Report",
        borders: [:all]
      )
    )
  end

  private def handle_input
    event = @tui.poll_event
    return :quit if event == "q" || event == :esc || event == :ctrl_c

    nil
  end
end

if __FILE__ == $0
  WidgetRichText.new.run
end
