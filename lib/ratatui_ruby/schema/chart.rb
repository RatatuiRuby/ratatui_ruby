# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

module RatatuiRuby
  # Defines an Axis for a Chart
  # [title] String
  # [bounds] Array<Float> [min, max]
  # [labels] Array<String>
  # [style] Style
  # [labels_alignment] Symbol (<tt>:left</tt>, <tt>:center</tt>, <tt>:right</tt>)
  class Axis < Data.define(:title, :bounds, :labels, :style, :labels_alignment)
    ##
    # :attr_reader: title
    # Label for the axis (String).

    ##
    # :attr_reader: bounds
    # Range [min, max] (Array of Floats).

    ##
    # :attr_reader: labels
    # Explicit labels for ticks (Array of Strings).

    ##
    # :attr_reader: style
    # Style for axis lines/text.

    ##
    # :attr_reader: labels_alignment
    # Alignment of axis labels (:left, :center, :right).

    # Creates a new Axis.
    #
    # [title] String.
    # [bounds] Array [min, max].
    # [labels] Array of Strings.
    # [style] Style.
    # [labels_alignment] Symbol (:left, :center, :right).
    def initialize(title: "", bounds: [0.0, 10.0], labels: [], style: nil, labels_alignment: nil)
      super(
        title:,
        bounds: [Float(bounds[0]), Float(bounds[1])],
        labels:,
        style:,
        labels_alignment:
      )
    end
  end

  # Defines a Dataset for a Chart.
  # [name] The name of the dataset.
  # [data] Array of arrays [[x, y], [x, y]] (Floats).
  # [style] The style of the line.
  # [marker] Symbol (<tt>:dot</tt>, <tt>:braille</tt>, <tt>:block</tt>, <tt>:bar</tt>)
  # [graph_type] Symbol (<tt>:line</tt>, <tt>:scatter</tt>)
  class Dataset < Data.define(:name, :data, :style, :marker, :graph_type)
    ##
    # :attr_reader: name
    # Name for logical identification or legend.

    ##
    # :attr_reader: data
    # list of [x, y] coordinates.

    ##
    # :attr_reader: style
    # Style applied to the dataset (Style).
    #
    # **Note**: Due to Ratatui's Chart widget design, only the foreground color (<tt>fg</tt>) is applied to markers in the chart area.
    # The full style (including <tt>bg</tt> and <tt>modifiers</tt>) is displayed in the legend.
    #
    # Supports:
    # - +fg+: Foreground color of markers (Symbol/Hex) - _applied to chart_
    # - +bg+: Background color (Symbol/Hex) - _legend only_
    # - +modifiers+: Array of effects (<tt>:bold</tt>, <tt>:dim</tt>, <tt>:italic</tt>, <tt>:underlined</tt>, <tt>:slow_blink</tt>, <tt>:rapid_blink</tt>, <tt>:reversed</tt>, <tt>:hidden</tt>, <tt>:crossed_out</tt>) - _legend only_

    ##
    # :attr_reader: marker
    # Marker type (<tt>:dot</tt>, <tt>:braille</tt>).

    ##
    # :attr_reader: graph_type
    # Type of graph (<tt>:line</tt>, <tt>:scatter</tt>).

    # Creates a new Dataset.
    #
    # [name] String.
    # [data] Array of [x, y] (Numeric, duck-typed via +to_f+).
    # [style] Style.
    # [marker] Symbol.
    # [graph_type] Symbol.
    def initialize(name:, data:, style: nil, marker: :dot, graph_type: :line)
      coerced_data = data.map { |point| [Float(point[0]), Float(point[1])] }
      super(name:, data: coerced_data, style:, marker:, graph_type:)
    end
  end

  # Plots data points on a Cartesian coordinate system.
  #
  # Trends and patterns are invisible in raw logs. You need to see the shape of the data to understand the story it tells.
  #
  # This widget plots X/Y coordinates. It supports multiple datasets, custom axes, and different marker types.
  #
  # Use it for analytics, scientific data, or monitoring metrics over time.
  #
  # {rdoc-image:/doc/images/widget_chart.png}[link:/examples/widget_chart/app_rb.html]
  #
  # === Example
  #
  # Run the interactive demo from the terminal:
  #
  #   ruby examples/widget_chart/app.rb
  class Chart < Data.define(:datasets, :x_axis, :y_axis, :block, :style, :legend_position, :hidden_legend_constraints)
    ##
    # :attr_reader: datasets
    # Array of Dataset objects to plot.

    ##
    # :attr_reader: x_axis
    # Configuration for the X Axis.

    ##
    # :attr_reader: y_axis
    # Configuration for the Y Axis.

    ##
    # :attr_reader: block
    # Optional wrapping block.

    ##
    # :attr_reader: style
    # Base style for the chart area.

    ##
    # :attr_reader: legend_position
    # Position of the legend (<tt>:top_left</tt>, <tt>:top_right</tt>, <tt>:bottom_left</tt>, <tt>:bottom_right</tt>).

    ##
    # :attr_reader: hidden_legend_constraints
    # Constraints for hiding the legend when the chart is too small (Array of [width, height]).

    # Creates a new Chart widget.
    #
    # [datasets] Array of Datasets.
    # [x_axis] X Axis config.
    # [y_axis] Y Axis config.
    # [block] Wrapper (optional).
    # [style] Base style (optional).
    # [legend_position] Symbol (<tt>:top_left</tt>, <tt>:top_right</tt>, <tt>:bottom_left</tt>, <tt>:bottom_right</tt>).
    # [hidden_legend_constraints] Array of two Constraints [width, height] (optional).
    def initialize(datasets:, x_axis:, y_axis:, block: nil, style: nil, legend_position: nil, hidden_legend_constraints: [])
      super
    end
  end

  # A complex chart widget. (Legacy/Alias for Chart)
  #
  # [datasets] Array of Dataset objects.
  # [x_labels] Array of Strings for the X-axis labels.
  # [y_labels] Array of Strings for the Y-axis labels.
  # [y_bounds] Array of two Floats [min, max] for the Y-axis.
  # [block] Optional block widget to wrap the chart.
  class LineChart < Data.define(:datasets, :x_labels, :y_labels, :y_bounds, :block)
    # Creates a new LineChart widget.
    #
    # [datasets] Array of Dataset objects.
    # [x_labels] Array of Strings for the X-axis labels.
    # [y_labels] Array of Strings for the Y-axis labels.
    # [y_bounds] Array of two Floats [min, max] for the Y-axis.
    # [block] Optional block widget to wrap the chart.
    def initialize(datasets:, x_labels: [], y_labels: [], y_bounds: [0.0, 100.0], block: nil)
      super(
        datasets:,
        x_labels:,
        y_labels:,
        y_bounds: [Float(y_bounds[0]), Float(y_bounds[1])],
        block:
      )
    end
  end
end
