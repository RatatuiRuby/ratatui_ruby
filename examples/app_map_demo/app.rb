# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# An example of the Canvas widget showing a world map and animated shapes.
class AppMapDemo
  include RatatuiRuby

  COLORS = [:black, :blue, :white, nil].freeze
  MARKERS = [:braille, :half_block, :dot, :block, :bar, :quadrant, :sextant, :octant].freeze

  # Returns a Canvas view for the map demo with the given circle radius.
  #
  # +tui+:: The RatatuiRuby::Session instance.
  # +radius+:: The radius of the animated circle.
  # +marker+:: The marker type.
  # +background_color+:: The background color of the canvas.
  # +show_labels+:: Whether to show city labels.
  def view(tui, radius, marker = :braille, background_color = nil, show_labels: true)
    shapes = [
      tui.shape_map(color: :green, resolution: :high),
      tui.shape_circle(x: 0.0, y: 0.0, radius:, color: :red),
      tui.shape_line(x1: 0.0, y1: 0.0, x2: 50.0, y2: 25.0, color: :yellow),
    ]

    if show_labels
      shapes += [
        tui.shape_label(x: -0.1, y: 51.5, text: "London", style: tui.style(fg: :cyan)),
        tui.shape_label(x: 139.7, y: 35.7, text: "Tokyo", style: tui.style(fg: :magenta)),
        tui.shape_label(x: -74.0, y: 40.7, text: "New York", style: tui.style(fg: :yellow)),
        tui.shape_label(x: -122.4, y: 37.8, text: "San Francisco", style: tui.style(fg: :blue)),
        tui.shape_label(x: 151.2, y: -33.9, text: "Sydney", style: tui.style(fg: :green)),
      ]
    end

    tui.canvas(
      shapes:,
      x_bounds: [-180.0, 180.0],
      y_bounds: [-90.0, 90.0],
      marker:,
      block: tui.block(title: "World Map ['b' bg, 'm' marker: #{marker}, 'l' labels: #{show_labels ? 'on' : 'off'}]", borders: :all),
      background_color:
    )
  end

  # Runs the map demo loop.
  def run
    RatatuiRuby.run do |tui|
      radius = 0.0
      direction = 1
      bg_index = 0
      marker_index = 0
      show_labels = true

      loop do
        # Animate the circle radius
        radius += 0.5 * direction
        if radius > 10.0 || radius < 0.0
          direction *= -1
        end

        # Define the view
        canvas = view(tui, radius, MARKERS[marker_index], COLORS[bg_index], show_labels:)

        tui.draw do |frame|
          frame.render_widget(canvas, frame.area)
        end

        event = tui.poll_event
        case event
        in { type: :key, code: "q" } | { type: :key, code: :ctrl_c }
          break
        in type: :key, code: "b"
          bg_index = (bg_index + 1) % COLORS.size
        in type: :key, code: "m"
          marker_index = (marker_index + 1) % MARKERS.size
        in type: :key, code: "l"
          show_labels = !show_labels
        else
          # Ignore other events
        end

        sleep 0.05
      end
    end
  end
end

AppMapDemo.new.run if __FILE__ == $PROGRAM_NAME
