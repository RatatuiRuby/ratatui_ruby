# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: MIT-0
#++

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Rich Text Example
# Demonstrates the Span and Line objects for styling individual words
# within a block of text. Also demonstrates Line alignment methods.
class WidgetRichText
  def initialize
    @scroll_pos = 0
    @color_index = 0
    @alignment_index = 0
    @alignments = [:left, :center, :right]
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
    # Create a base line with spans, then apply alignment using the fluent methods
    alignment = @alignments[@alignment_index]
    aligned_line = case alignment
                   when :left then base_line.left_aligned
                   when :center then base_line.centered
                   when :right then base_line.right_aligned
    end

    @tui.paragraph(
      text: [
        aligned_line,
        @tui.text_line(spans: []),
        @tui.text_line(
          spans: [
            @tui.text_span(content: "Integer Color Test: "),
            @tui.text_span(content: "Color #{@color_index}", style: @tui.style(fg: @color_index)),
            @tui.text_span(content: " (Use "),
            @tui.text_span(content: "↑ ↓", style: @tui.style(modifiers: [:bold])),
            @tui.text_span(content: " for +/- 1, ", style: nil),
            @tui.text_span(content: "← →", style: @tui.style(modifiers: [:bold])),
            @tui.text_span(content: " for +/- 10)", style: nil),
          ]
        ),
        @tui.text_line(spans: []),
        @tui.text_line(
          spans: [
            @tui.text_span(content: "A", style: @tui.style(modifiers: [:bold, :underlined])),
            @tui.text_span(content: ": Alignment (#{alignment})", style: nil),
          ]
        ),
      ],
      block: @tui.block(
        title: "Simple Rich Text",
        borders: [:all]
      )
    )
  end

  private def base_line
    # Demonstrates creating a styled line with various modifiers and colors
    # Including: underline_color (distinct from fg) and remove_modifiers (to override inherited styles)
    @tui.text_line(
      spans: [
        @tui.text_span(content: "Normal, ", style: nil),
        @tui.text_span(content: "Bold", style: @tui.style(modifiers: [:bold])),
        @tui.text_span(content: ", ", style: nil),
        @tui.text_span(content: "Italic", style: @tui.style(modifiers: [:italic])),
        @tui.text_span(content: ", ", style: nil),
        @tui.text_span(content: "Red", style: @tui.style(fg: :red)),
        @tui.text_span(content: ", ", style: nil),
        # New: underline_color - underline in a different color than text
        @tui.text_span(
          content: "Red Underline",
          style: @tui.style(fg: :white, modifiers: [:underlined], underline_color: :red)
        ),
        @tui.text_span(content: ".", style: nil),
      ]
    )
  end

  private def complex_example
    # Example 2: Multiple lines with different styles
    # Includes Symbols::Shade constants for density gradients
    shade = RatatuiRuby::Symbols::Shade

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
        # Demonstrate Symbols::Shade constants for density gradients
        @tui.text_line(
          spans: [
            @tui.text_span(content: "Shade: ", style: @tui.style(fg: :cyan)),
            @tui.text_span(content: shade::EMPTY * 4, style: nil),
            @tui.text_span(content: shade::LIGHT * 4, style: @tui.style(fg: :dark_gray)),
            @tui.text_span(content: shade::MEDIUM * 4, style: @tui.style(fg: :gray)),
            @tui.text_span(content: shade::DARK * 4, style: @tui.style(fg: :white)),
            @tui.text_span(content: shade::FULL * 4, style: @tui.style(fg: :white)),
          ]
        ),
        @tui.text_line(spans: []),
        @tui.text_line(
          spans: [
            @tui.text_span(content: "Press ", style: nil),
            @tui.text_span(content: "Q", style: @tui.style(modifiers: [:bold])),
            @tui.text_span(content: " to quit, ", style: nil),
            @tui.text_span(content: "↑ ↓", style: @tui.style(modifiers: [:bold])),
            @tui.text_span(content: ": color by 1, ", style: nil),
            @tui.text_span(content: "← →", style: @tui.style(modifiers: [:bold])),
            @tui.text_span(content: ": color by 10.", style: nil),
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

    if event.left?
      @color_index = (@color_index - 10) % 256
    elsif event.right?
      @color_index = (@color_index + 10) % 256
    elsif event.up?
      @color_index = (@color_index + 1) % 256
    elsif event.down?
      @color_index = (@color_index - 1) % 256
    elsif event == "a"
      @alignment_index = (@alignment_index + 1) % @alignments.size
    end

    nil
  end
end

if __FILE__ == $0
  WidgetRichText.new.run
end
