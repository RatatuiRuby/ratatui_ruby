# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"

# An example of the Canvas widget showing a world map and animated shapes.
module MapDemo
  include RatatuiRuby

  # Returns a Canvas view for the map demo with the given circle radius.
  #
  # +radius+:: The radius of the animated circle.
  def self.view(radius)
    Canvas.new(
      shapes: [
        Shape::Map.new(color: :green, resolution: :high),
        Shape::Circle.new(x: 0.0, y: 0.0, radius:, color: :red),
        Shape::Line.new(x1: 0.0, y1: 0.0, x2: 50.0, y2: 25.0, color: :yellow),
      ],
      x_bounds: [-180.0, 180.0],
      y_bounds: [-90.0, 90.0],
      marker: :braille,
      block: Block.new(title: "World Map Canvas", borders: :all)
    )
  end

  # Runs the map demo loop.
  def self.run
    RatatuiRuby.init_terminal
    radius = 0.0
    direction = 1

    loop do
      # Animate the circle radius
      radius += 0.5 * direction
      if radius > 10.0 || radius < 0.0
        direction *= -1
      end

      # Define the view
      view = view(radius)

      RatatuiRuby.draw(view)

      event = RatatuiRuby.poll_event
      break if event && event[:type] == :key && event[:code] == "q"

      sleep 0.05
    end
  ensure
    RatatuiRuby.restore_terminal
  end
end

MapDemo.run if __FILE__ == $PROGRAM_NAME
