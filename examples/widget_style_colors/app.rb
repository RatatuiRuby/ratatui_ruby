# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: MIT-0
#++

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Demonstrates terminal color rendering and the Color module.
#
# Terminal apps need vibrant colors. Specifying colors as symbols or
# calculated hex strings works but limits expressiveness.
#
# This demo shows the Color module's constructors for creating colors
# from HSL values or hex integers, producing a full-spectrum gradient.
#
# Use it to understand color representation and the Color.hsl/Color.hex APIs.
class WidgetStyleColors
  def initialize
    @width = 80
    @height = 24
  end

  def run
    RatatuiRuby.run do |tui|
      loop do
        tui.draw do |frame|
          frame.render_widget(render(tui), frame.area)
        end
        event = tui.poll_event
        break if event.key? && (event.ctrl_c? || event == :q)
      end
    end
  end

  private def render(tui)
    lines = []

    (0...@height).each do |row|
      spans = []
      (0...@width).each do |col|
        hue = (col.to_f / @width) * 360.0
        lightness = 50.0 - ((row.to_f / @height) * 50.0)

        # Use Color.hsl for top half, Color.hsluv for bottom half
        # HSLuv provides perceptually uniform colors (same visual brightness)
        hex = if row < @height / 2
          RatatuiRuby::Style::Color.hsl(hue, 100.0, lightness)
        else
          # HSLuv: perceptually uniform - all colors appear equal brightness
          RatatuiRuby::Style::Color.hsluv(hue, 100.0, lightness)
        end

        # Demonstrate Style.with for concise inline styling
        span = tui.text_span(
          content: " ",
          style: RatatuiRuby::Style::Style.with(bg: hex)
        )
        spans << span
      end

      lines << tui.text_line(spans:)
    end

    # Also demonstrate Color.hex for the border
    border_color = RatatuiRuby::Style::Color.hex(0xFFD700) # Gold

    tui.paragraph(
      text: lines,
      block: tui.block(
        title: "HSL (top) vs HSLuv (bottom) - Style.with demo (Press 'q' to exit)",
        borders: [:all],
        border_type: :rounded,
        # Using Style.with for concise border styling
        border_style: RatatuiRuby::Style::Style.with(fg: border_color)
      )
    )
  end
end

WidgetStyleColors.new.run if __FILE__ == $PROGRAM_NAME
