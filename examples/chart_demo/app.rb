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
      { name: "Bar", marker: :bar },
    ]
    @marker_index = 0

    @dataset_styles = [
      { name: "Yellow", style: RatatuiRuby::Style.new(fg: :yellow) },
      { name: "Green", style: RatatuiRuby::Style.new(fg: :green) },
      { name: "Cyan", style: RatatuiRuby::Style.new(fg: :cyan) },
      { name: "Red", style: RatatuiRuby::Style.new(fg: :red) },
      { name: "Magenta", style: RatatuiRuby::Style.new(fg: :magenta) },
      { name: "Bold Blue", style: RatatuiRuby::Style.new(fg: :blue, modifiers: [:bold]) },
      { name: "Dim White", style: RatatuiRuby::Style.new(fg: :white, modifiers: [:dim]) },
      { name: "Italic Green", style: RatatuiRuby::Style.new(fg: :green, modifiers: [:italic]) },
      { name: "Alert (Red/White/Bar)", style: RatatuiRuby::Style.new(fg: :white, bg: :red, modifiers: [:bold]) },
    ]
    @dataset_style_index = 0

    @x_alignments = [
      { name: "Left", alignment: :left },
      { name: "Center", alignment: :center },
      { name: "Right", alignment: :right },
    ]
    @x_alignment_index = 1

    @y_alignments = [
      { name: "Left", alignment: :left },
      { name: "Center", alignment: :center },
      { name: "Right", alignment: :right },
    ]
    @y_alignment_index = 2

    @legend_positions = [
      { name: "Top Right", position: :top_right },
      { name: "Top Left", position: :top_left },
      { name: "Bottom Right", position: :bottom_right },
      { name: "Bottom Left", position: :bottom_left },
    ]
    @legend_position_index = 0

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

  private def render
    # Static sample data: sine wave with wider range for better visibility
    line_data = (0..50).map do |i|
      x = i / 5.0
      [x, Math.sin(x)]
    end

    # Scatter: Random points
    scatter_data = (0..20).map do |_|
      [rand(0.0..10.0), rand(-1.0..1.0)]
    end

    style = @dataset_styles[@dataset_style_index][:style]
    # Ensure the second dataset has a different style
    scatter_style = @dataset_styles[(@dataset_style_index + 2) % @dataset_styles.length][:style]

    datasets = [
      RatatuiRuby::Dataset.new(
        name: "Line",
        data: line_data,
        style:,
        marker: (style.modifiers.include?(:bold) && style.bg) ? :bar : @markers[@marker_index][:marker],
        graph_type: :line
      ),
      RatatuiRuby::Dataset.new(
        name: "Scatter",
        data: scatter_data,
        style: scatter_style,
        marker: (scatter_style.modifiers.include?(:bold) && scatter_style.bg) ? :bar : @markers[@marker_index][:marker],
        graph_type: :scatter
      ),
    ]

    x_alignment = @x_alignments[@x_alignment_index][:alignment]
    y_alignment = @y_alignments[@y_alignment_index][:alignment]
    legend_position = @legend_positions[@legend_position_index][:position]

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
      ),
      legend_position:,
      hidden_legend_constraints: [
        RatatuiRuby::Constraint.min(20),
        RatatuiRuby::Constraint.min(10),
      ]
    )

    layout = RatatuiRuby::Layout.new(
      direction: :vertical,
      constraints: [
        RatatuiRuby::Constraint.fill(1),
        RatatuiRuby::Constraint.length(5),
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
                  RatatuiRuby::Text::Span.new(content: "s", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": Style (#{@dataset_styles[@dataset_style_index][:name]})"),
                ]),
                # Line 2: Axis alignments
                RatatuiRuby::Text::Line.new(spans: [
                  RatatuiRuby::Text::Span.new(content: "x", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": X Align (#{@x_alignments[@x_alignment_index][:name]})  "),
                  RatatuiRuby::Text::Span.new(content: "y", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": Y Align (#{@y_alignments[@y_alignment_index][:name]})  "),
                  RatatuiRuby::Text::Span.new(content: "l", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": Legend (#{@legend_positions[@legend_position_index][:name]})"),
                ]),
                # Line 3: Quit
                RatatuiRuby::Text::Line.new(spans: [
                  RatatuiRuby::Text::Span.new(content: "q", style: @hotkey_style),
                  RatatuiRuby::Text::Span.new(content: ": Quit"),
                ]),
              ]
            ),
          ]
        ),
      ]
    )

    RatatuiRuby.draw(layout)
  end

  private def handle_input
    event = RatatuiRuby.poll_event
    return unless event

    case event
    in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
      :quit
    in type: :key, code: "m"
      @marker_index = (@marker_index + 1) % @markers.length
    in type: :key, code: "s"
      @dataset_style_index = (@dataset_style_index + 1) % @dataset_styles.length
    in type: :key, code: "x"
      @x_alignment_index = (@x_alignment_index + 1) % @x_alignments.length
    in type: :key, code: "y"
      @y_alignment_index = (@y_alignment_index + 1) % @y_alignments.length
    in type: :key, code: "l"
      @legend_position_index = (@legend_position_index + 1) % @legend_positions.length
    else
      nil
    end
  end
end

ChartDemoApp.new.run if __FILE__ == $PROGRAM_NAME
