# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

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
        super
      end
    end

  # Defines a Dataset for a Chart.
  # [name] The name of the dataset.
  # [data] Array of arrays [[x, y], [x, y]] (Floats).
  # [color] The color of the line.
  # [marker] Symbol (<tt>:dot</tt>, <tt>:braille</tt>, <tt>:block</tt>, <tt>:bar</tt>)
  # [graph_type] Symbol (<tt>:line</tt>, <tt>:scatter</tt>)
    class Dataset < Data.define(:name, :data, :color, :marker, :graph_type)
      ##
      # :attr_reader: name
      # Name for logical identification or legend.

      ##
      # :attr_reader: data
      # list of [x, y] coordinates.

      ##
      # :attr_reader: color
      # Color of the line/marker (Symbol/String).

      ##
      # :attr_reader: marker
      # Marker type (<tt>:dot</tt>, <tt>:braille</tt>).

      ##
      # :attr_reader: graph_type
      # Type of graph (<tt>:line</tt>, <tt>:scatter</tt>).

      # Creates a new Dataset.
      #
      # [name] String.
      # [data] Array of [x, y].
      # [color] Symbol/String.
      # [marker] Symbol.
      # [graph_type] Symbol.
      def initialize(name:, data:, color: "reset", marker: :dot, graph_type: :line)
        super
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
    # === Examples
    #
    #   Chart.new(
    #     datasets: [
    #       Dataset.new(
    #         name: "Requests",
    #         data: [[0.0, 1.0], [1.0, 2.0], [2.0, 1.5]],
    #         color: :yellow
    #       )
    #     ],
    #     x_axis: Axis.new(title: "Time", bounds: [0.0, 5.0]),
    #     y_axis: Axis.new(title: "RPS", bounds: [0.0, 5.0])
    #   )
    class Chart < Data.define(:datasets, :x_axis, :y_axis, :block, :style)
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

      # Creates a new Chart widget.
      #
      # [datasets] Array of Datasets.
      # [x_axis] X Axis config.
      # [y_axis] Y Axis config.
      # [block] Wrapper (optional).
      # [style] Base style (optional).
      def initialize(datasets:, x_axis:, y_axis:, block: nil, style: nil)
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
      super
    end
  end
end
