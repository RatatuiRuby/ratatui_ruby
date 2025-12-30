# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Demonstrates Chart widget with interactive attribute cycling.
class ChartDemoApp
  def initialize
    @markers = [
      { name: "Dot (·)", marker: :dot },
      { name: "Braille", marker: :braille },
      { name: "Block (█)", marker: :block },
      { name: "Bar", marker: :bar }
    ]
    @marker_index = 0

    @dataset_colors = [
      { name: "Yellow", color: :yellow },
      { name: "Green", color: :green },
      { name: "Cyan", color: :cyan },
      { name: "Red", color: :red },
      { name: "Magenta", color: :magenta }
    ]
    @dataset_color_index = 0

    @x_alignments = [
      { name: "Left", alignment: :left },
      { name: "Center", alignment: :center },
      { name: "Right", alignment: :right }
    ]
    @x_alignment_index = 1

    @y_alignments = [
      { name: "Left", alignment: :left },
      { name: "Center", alignment: :center },
      { name: "Right", alignment: :right }
    ]
    @y_alignment_index = 2

    @hotkey_style = RatatuiRuby::Style.new(modifiers: [:bold, :underlined])
  end

  def run
    RatatuiRuby.run do
      loop do
        render
        break if handle_input == :quit
        sleep 0.05
      end
    end
  end

  private

  def render
    # Static sample data: sine wave with wider range for better visibility
    line_data = (0..50).map do |i|
      x = i / 5.0
      [x, Math.sin(x)]
    end

    # Scatter: Random points
    scatter_data = (0..20).map do |_|
      [rand(0.0..10.0), rand(-1.0..1.0)]
    end

    color = @dataset_colors[@dataset_color_index][:color]

    datasets = [
      RatatuiRuby::Dataset.new(
        name: "Line",
        data: line_data,
        color:,
        marker: @markers[@marker_index][:marker],
        graph_type: :line
      ),
      RatatuiRuby::Dataset.new(
        name: "Scatter",
        data: scatter_data,
        color:,
        marker: @markers[@marker_index][:marker],
        graph_type: :scatter
      )
    ]

    x_alignment = @x_alignments[@x_alignment_index][:alignment]
    y_alignment = @y_alignments[@y_alignment_index][:alignment]

    chart = RatatuiRuby::Chart.new(
      datasets:,
      x_axis: RatatuiRuby::Axis.new(
        title: "Time",
        bounds: [0.0, 10.0],
        labels: %w[0 5 10],
        style: RatatuiRuby::Style.new(fg: :yellow),
        labels_alignment: x_alignment
      ),
      y_axis: RatatuiRuby::Axis.new(
        title: "Amplitude",
        bounds: [-1.0, 1.0],
        labels: %w[-1 0 1],
        style: RatatuiRuby::Style.new(fg: :cyan),
        labels_alignment: y_alignment
      ),
      block: RatatuiRuby::Block.new(
        title: "Chart Widget Demo",
        borders: [:all]
      )
    )

    layout = RatatuiRuby::Layout.new(
      direction: :vertical,
      constraints: [
        RatatuiRuby::Constraint.fill(1),
        RatatuiRuby::Constraint.length(5)
      ],
      children: [
        chart,
        # Bottom control panel
        RatatuiRuby::Block.new(
          title: "Controls",
          borders: [:all],
          children: [
            RatatuiRuby::Paragraph.new(
              text: [
                # Line 1: Markers & Colors
                RatatuiRuby::Text::Line.new(spans: [
                  RatatuiRuby::Text::Span.new(content: "m", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": Marker (#{@markers[@marker_index][:name]})  "),
                  RatatuiRuby::Text::Span.new(content: "c", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": Color (#{@dataset_colors[@dataset_color_index][:name]})")
                ]),
                # Line 2: Axis alignments
                RatatuiRuby::Text::Line.new(spans: [
                  RatatuiRuby::Text::Span.new(content: "x", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": X Align (#{@x_alignments[@x_alignment_index][:name]})  "),
                  RatatuiRuby::Text::Span.new(content: "y", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": Y Align (#{@y_alignments[@y_alignment_index][:name]})  "),
                  RatatuiRuby::Text::Span.new(content: "q", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": Quit")
                ])
              ]
            )
          ]
        )
      ]
    )

    RatatuiRuby.draw(layout)
  end

  def handle_input
    event = RatatuiRuby.poll_event
    return unless event

    case event
    in {type: :key, code: "q"} | {type: :key, code: "c", modifiers: ["ctrl"]}
      :quit
    in type: :key, code: "m"
      @marker_index = (@marker_index + 1) % @markers.length
    in type: :key, code: "c"
      @dataset_color_index = (@dataset_color_index + 1) % @dataset_colors.length
    in type: :key, code: "x"
      @x_alignment_index = (@x_alignment_index + 1) % @x_alignments.length
    in type: :key, code: "y"
      @y_alignment_index = (@y_alignment_index + 1) % @y_alignments.length
    else
      nil
    end
  end
end

ChartDemoApp.new.run if __FILE__ == $PROGRAM_NAME
