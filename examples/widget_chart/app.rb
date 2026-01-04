# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Demonstrates Cartesian plotting attributes with interactive cycling.
#
# Trends and patterns are invisible in raw logs. You need to see the shape of the data to understand the story it tells.
#
# This demo showcases the <tt>Chart</tt> widget. It provides an interactive playground where you can toggle marker types, axis alignments, and legend positions in real-time.
#
# Use it to understand how to visualize complex X/Y datasets and trends efficiently.
#
# === Example
#
# Run the demo from the terminal:
#
#   ruby examples/widget_chart/app.rb
#
# rdoc-image:/doc/images/widget_chart.png
class WidgetChart
  MARKERS = [
    { name: "Dot (·)", marker: :dot },
    { name: "Braille", marker: :braille },
    { name: "Block (█)", marker: :block },
    { name: "Bar", marker: :bar },
  ].freeze

  X_ALIGNMENTS = [
    { name: "Left", alignment: :left },
    { name: "Center", alignment: :center },
    { name: "Right", alignment: :right },
  ].freeze

  Y_ALIGNMENTS = [
    { name: "Left", alignment: :left },
    { name: "Center", alignment: :center },
    { name: "Right", alignment: :right },
  ].freeze

  LEGEND_POSITIONS = [
    { name: "Top Right", position: :top_right },
    { name: "Top Left", position: :top_left },
    { name: "Bottom Right", position: :bottom_right },
    { name: "Bottom Left", position: :bottom_left },
  ].freeze

  def run
    RatatuiRuby.run do |tui|
      @tui = tui
      init_styles

      # Support seeded random for deterministic testing
      # Set RATA_SEED=42 for reproducible scatter plot data
      seed = ENV.fetch("RATA_SEED", nil)
      @rng = seed ? Random.new(seed.to_i) : Random.new

      @marker_index = 0
      @dataset_style_index = 0
      @x_alignment_index = 1
      @y_alignment_index = 2
      @legend_position_index = 0

      loop do
        render
        break if handle_input == :quit
        sleep 0.05
      end
    end
  end

  private def init_styles
    @hotkey_style = @tui.style(modifiers: [:bold, :underlined])
    @dataset_styles = [
      { name: "Yellow", style: @tui.style(fg: :yellow) },
      { name: "Green", style: @tui.style(fg: :green) },
      { name: "Cyan", style: @tui.style(fg: :cyan) },
      { name: "Red", style: @tui.style(fg: :red) },
      { name: "Magenta", style: @tui.style(fg: :magenta) },
      { name: "Bold Blue", style: @tui.style(fg: :blue, modifiers: [:bold]) },
      { name: "Dim White", style: @tui.style(fg: :white, modifiers: [:dim]) },
      { name: "Italic Green", style: @tui.style(fg: :green, modifiers: [:italic]) },
      { name: "Alert (Red/White/Bar)", style: @tui.style(fg: :white, bg: :red, modifiers: [:bold]) },
    ]
  end

  private def render
    # Static sample data: sine wave with wider range for better visibility
    line_data = (0..50).map do |i|
      x = i / 5.0
      [x, Math.sin(x)]
    end

    # Scatter: Random points (deterministic when RATA_SEED is set)
    scatter_data = (0..20).map do |_|
      [@rng.rand(0.0..10.0), @rng.rand(-1.0..1.0)]
    end

    style = @dataset_styles[@dataset_style_index][:style]
    # Ensure the second dataset has a different style
    scatter_style = @dataset_styles[(@dataset_style_index + 2) % @dataset_styles.length][:style]

    datasets = [
      @tui.dataset(
        name: "Line",
        data: line_data,
        style:,
        marker: (style.modifiers.include?(:bold) && style.bg) ? :bar : MARKERS[@marker_index][:marker],
        graph_type: :line
      ),
      @tui.dataset(
        name: "Scatter",
        data: scatter_data,
        style: scatter_style,
        marker: (scatter_style.modifiers.include?(:bold) && scatter_style.bg) ? :bar : MARKERS[@marker_index][:marker],
        graph_type: :scatter
      ),
    ]

    chart = @tui.chart(
      datasets:,
      x_axis: @tui.axis(
        title: "Time",
        bounds: [0.0, 10.0],
        labels: %w[0 5 10],
        style: @tui.style(fg: :yellow),
        labels_alignment: X_ALIGNMENTS[@x_alignment_index][:alignment]
      ),
      y_axis: @tui.axis(
        title: "Amplitude",
        bounds: [-1.0, 1.0],
        labels: %w[-1 0 1],
        style: @tui.style(fg: :cyan),
        labels_alignment: Y_ALIGNMENTS[@y_alignment_index][:alignment]
      ),
      block: @tui.block(
        title: "Chart Widget",
        borders: [:all]
      ),
      legend_position: LEGEND_POSITIONS[@legend_position_index][:position],
      hidden_legend_constraints: [
        @tui.constraint_min(20),
        @tui.constraint_min(10),
      ]
    )

    controls = @tui.block(
      title: "Controls",
      borders: [:all],
      children: [
        @tui.paragraph(
          text: [
            # Line 1: Markers & Colors
            @tui.text_line(spans: [
              @tui.text_span(content: "m", style: @hotkey_style),
              @tui.text_span(content: ": Marker (#{MARKERS[@marker_index][:name]})  "),
              @tui.text_span(content: "s", style: @hotkey_style),
              @tui.text_span(content: ": Style (#{@dataset_styles[@dataset_style_index][:name]})"),
            ]),
            # Line 2: Axis alignments
            @tui.text_line(spans: [
              @tui.text_span(content: "x", style: @hotkey_style),
              @tui.text_span(content: ": X Align (#{X_ALIGNMENTS[@x_alignment_index][:name]})  "),
              @tui.text_span(content: "y", style: @hotkey_style),
              @tui.text_span(content: ": Y Align (#{Y_ALIGNMENTS[@y_alignment_index][:name]})  "),
              @tui.text_span(content: "l", style: @hotkey_style),
              @tui.text_span(content: ": Legend (#{LEGEND_POSITIONS[@legend_position_index][:name]})"),
            ]),
            # Line 3: Quit
            @tui.text_line(spans: [
              @tui.text_span(content: "q", style: @hotkey_style),
              @tui.text_span(content: ": Quit"),
            ]),
          ]
        ),
      ]
    )

    @tui.draw do |frame|
      chart_area, controls_area = @tui.layout_split(
        frame.area,
        direction: :vertical,
        constraints: [
          @tui.constraint_fill(1),
          @tui.constraint_length(5),
        ]
      )
      frame.render_widget(chart, chart_area)
      frame.render_widget(controls, controls_area)
    end
  end

  private def handle_input
    event = @tui.poll_event

    case event
    in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
      :quit
    in type: :key, code: "m"
      @marker_index = (@marker_index + 1) % MARKERS.length
    in type: :key, code: "s"
      @dataset_style_index = (@dataset_style_index + 1) % @dataset_styles.length
    in type: :key, code: "x"
      @x_alignment_index = (@x_alignment_index + 1) % X_ALIGNMENTS.length
    in type: :key, code: "y"
      @y_alignment_index = (@y_alignment_index + 1) % Y_ALIGNMENTS.length
    in type: :key, code: "l"
      @legend_position_index = (@legend_position_index + 1) % LEGEND_POSITIONS.length
    else
      nil
    end
  end
end

WidgetChart.new.run if __FILE__ == $PROGRAM_NAME
