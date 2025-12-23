# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # Defines an Axis for a Chart
  # [title] String
  # [bounds] Array<Float> [min, max]
  # [labels] Array<String>
  # [style] Style
  class Axis < Data.define(:title, :bounds, :labels, :style)
    # Creates a new Axis.
    def initialize(title: "", bounds: [0.0, 10.0], labels: [], style: nil)
      super
    end
  end

  # Defines a Dataset for a Chart.
  # [name] The name of the dataset.
  # [data] Array of arrays [[x, y], [x, y]] (Floats).
  # [color] The color of the line.
  # [marker] Symbol (:dot, :braille, :block, :bar)
  # [graph_type] Symbol (:line, :scatter)
  class Dataset < Data.define(:name, :data, :color, :marker, :graph_type)
    # Creates a new Dataset.
    def initialize(name:, data:, color: "reset", marker: :dot, graph_type: :line)
      super
    end
  end

  # A generic Cartesian chart.
  # [datasets] Array<Dataset>
  # [x_axis] Axis
  # [y_axis] Axis
  # [block] Block
  # [style] Style (base style)
  class Chart < Data.define(:datasets, :x_axis, :y_axis, :block, :style)
    # Creates a new Chart widget.
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
    def initialize(datasets:, x_labels: [], y_labels: [], y_bounds: [0.0, 100.0], block: nil)
      super
    end
  end
end
