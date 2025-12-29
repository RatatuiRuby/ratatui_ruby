# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"

# Rich Text Example
# Demonstrates the Span and Line objects for styling individual words
# within a block of text.
class RichTextApp
  def initialize
    @scroll_pos = 0
  end

  def run
    RatatuiRuby.init_terminal
    begin
      loop do
        render
        event = handle_input
        break if event == :quit
        sleep 0.05
      end
    ensure
      RatatuiRuby.restore_terminal
    end
  end

  private

  def render
    RatatuiRuby.draw(
      RatatuiRuby::Layout.new(
        direction: :vertical,
        constraints: [
          RatatuiRuby::Constraint.percentage(50),
          RatatuiRuby::Constraint.percentage(50)
        ],
        children: [
          simple_text_line_example,
          complex_example
        ]
      )
    )
  end

  def simple_text_line_example
    # Example 1: A line with mixed styles
    RatatuiRuby::Paragraph.new(
      text: RatatuiRuby::Text::Line.new(
        spans: [
          RatatuiRuby::Text::Span.new(
            content: "Normal text, ",
            style: nil
          ),
          RatatuiRuby::Text::Span.new(
             content: "Bold Text",
             style: RatatuiRuby::Style.new(modifiers: [:bold])
           ),
           RatatuiRuby::Text::Span.new(
             content: ", ",
             style: nil
           ),
           RatatuiRuby::Text::Span.new(
             content: "Italic Text",
             style: RatatuiRuby::Style.new(modifiers: [:italic])
           ),
           RatatuiRuby::Text::Span.new(
             content: ", ",
             style: nil
           ),
           RatatuiRuby::Text::Span.new(
             content: "Red Text",
             style: RatatuiRuby::Style.new(fg: :red)
           ),
           RatatuiRuby::Text::Span.new(
            content: ".",
            style: nil
          )
        ]
      ),
      block: RatatuiRuby::Block.new(
        title: "Simple Rich Text",
        borders: [:all]
      )
    )
  end

  def complex_example
    # Example 2: Multiple lines with different styles
    RatatuiRuby::Paragraph.new(
      text: [
        RatatuiRuby::Text::Line.new(
          spans: [
            RatatuiRuby::Text::Span.new(content: "✓ ", style: RatatuiRuby::Style.new(fg: :green, modifiers: [:bold])),
            RatatuiRuby::Text::Span.new(content: "Feature Complete", style: nil),
            RatatuiRuby::Text::Span.new(content: " - All tests passing", style: RatatuiRuby::Style.new(fg: :gray))
          ]
        ),
        RatatuiRuby::Text::Line.new(
          spans: [
            RatatuiRuby::Text::Span.new(content: "⚠ ", style: RatatuiRuby::Style.new(fg: :yellow, modifiers: [:bold])),
            RatatuiRuby::Text::Span.new(content: "Warning", style: nil),
            RatatuiRuby::Text::Span.new(content: " - Documentation pending", style: RatatuiRuby::Style.new(fg: :gray))
          ]
        ),
        RatatuiRuby::Text::Line.new(
          spans: [
            RatatuiRuby::Text::Span.new(content: "✗ ", style: RatatuiRuby::Style.new(fg: :red, modifiers: [:bold])),
            RatatuiRuby::Text::Span.new(content: "Not Started", style: nil),
            RatatuiRuby::Text::Span.new(content: " - Performance benchmarks", style: RatatuiRuby::Style.new(fg: :gray))
          ]
        ),
        RatatuiRuby::Text::Line.new(spans: []),
        RatatuiRuby::Text::Line.new(
          spans: [
            RatatuiRuby::Text::Span.new(content: "Press ", style: nil),
            RatatuiRuby::Text::Span.new(content: "Q", style: RatatuiRuby::Style.new(modifiers: [:bold])),
            RatatuiRuby::Text::Span.new(content: " to quit", style: nil)
          ]
        )
      ],
      block: RatatuiRuby::Block.new(
        title: "Status Report",
        borders: [:all]
      )
    )
  end

  def handle_input
    event = RatatuiRuby.poll_event
    return nil unless event

    return :quit if event == "q" || event == :esc || event == :ctrl_c

    nil
  end
end

if __FILE__ == $0
  RichTextApp.new.run
end
