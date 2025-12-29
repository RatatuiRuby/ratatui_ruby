# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"

# An example of the Canvas widget showing a world map and animated shapes.
module MapDemo
  include RatatuiRuby

  COLORS = [:black, :blue, :white, nil].freeze
  MARKERS = [:braille, :half_block, :dot, :block, :bar, :quadrant, :sextant, :octant].freeze

  # Returns a Canvas view for the map demo with the given circle radius.
  #
  # +radius+:: The radius of the animated circle.
  # +marker+:: The marker type.
  # +background_color+:: The background color of the canvas.
  def self.view(radius, marker = :braille, background_color = nil)
    Canvas.new(
      shapes: [
        Shape::Map.new(color: :green, resolution: :high),
        Shape::Circle.new(x: 0.0, y: 0.0, radius:, color: :red),
        Shape::Line.new(x1: 0.0, y1: 0.0, x2: 50.0, y2: 25.0, color: :yellow),
      ],
      x_bounds: [-180.0, 180.0],
      y_bounds: [-90.0, 90.0],
      marker: marker,
      block: Block.new(title: "World Map ['b' background, 'm' marker: #{marker}]", borders: :all),
      background_color: background_color
    )
  end

  # Runs the map demo loop.
  def self.run
    RatatuiRuby.run do
      radius = 0.0
      direction = 1
      bg_index = 0
      marker_index = 0

      loop do
        # Animate the circle radius
        radius += 0.5 * direction
        if radius > 10.0 || radius < 0.0
          direction *= -1
        end

        # Define the view
        view = view(radius, MARKERS[marker_index], COLORS[bg_index])

        RatatuiRuby.draw(view)

        event = RatatuiRuby.poll_event
        break if event == "q" || event == :ctrl_c

        if event == "b"
          bg_index = (bg_index + 1) % COLORS.size
        elsif event == "m"
          marker_index = (marker_index + 1) % MARKERS.size
        end

        sleep 0.05
      end
    end
  end
end

MapDemo.run if __FILE__ == $PROGRAM_NAME
