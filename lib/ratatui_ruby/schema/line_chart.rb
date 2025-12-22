# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # A single line on a chart.
  #
  # [name] The name of the dataset.
  # [data] Array of arrays [[x, y], [x, y]] (Floats).
  # [color] The color of the line.
  class Dataset < Data.define(:name, :data, :color)
    # Creates a new Dataset.
    # [name] The name of the dataset.
    # [data] Array of arrays [[x, y], [x, y]] (Floats).
    # [color] The color of the line.
    def initialize(name:, data:, color: "white")
      super
    end
  end

  # A complex chart widget.
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
