# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

class ColorGradientDemo
  def initialize
    @width = 80
    @height = 24
  end

  def run
    RatatuiRuby.run do |tui|
      loop do
        render(tui)
        event = tui.poll_event
        break if event&.key? && (event.ctrl_c? || event == :q)
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

        rgb = hsl_to_rgb(hue, 100.0, lightness)
        hex = rgb_to_hex(rgb)

        span = tui.text_span(
          content: " ",
          style: tui.style(bg: hex)
        )
        spans << span
      end

      lines << tui.text_line(spans:)
    end

    paragraph = tui.paragraph(
      text: lines,
      block: tui.block(
        title: "Hex Color Gradient (Press 'q' or Ctrl+C to exit)",
        borders: [:all],
        border_type: :rounded
      )
    )

    tui.draw(paragraph)
  end

  private def hsl_to_rgb(hue, saturation, lightness)
    h = hue / 360.0
    s = saturation / 100.0
    l = lightness / 100.0

    if s == 0
      r = g = b = l
    else
      q = (l < 0.5) ? l * (1 + s) : l + s - (l * s)
      p = (2 * l) - q

      r = hue_to_rgb(p, q, h + (1.0 / 3.0))
      g = hue_to_rgb(p, q, h)
      b = hue_to_rgb(p, q, h - (1.0 / 3.0))
    end

    [
      (r * 255).round,
      (g * 255).round,
      (b * 255).round,
    ]
  end

  private def hue_to_rgb(p, q, t)
    t += 1 while t < 0
    t -= 1 while t > 1

    if t < 1.0 / 6.0
      p + ((q - p) * 6 * t)
    elsif t < 1.0 / 2.0
      q
    elsif t < 2.0 / 3.0
      p + ((q - p) * ((2.0 / 3.0) - t) * 6)
    else
      p
    end
  end

  private def rgb_to_hex(rgb)
    "##{rgb.map { |c| c.to_s(16).upcase.rjust(2, '0') }.join}"
  end
end

ColorGradientDemo.new.run if __FILE__ == $PROGRAM_NAME
