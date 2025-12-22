# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # Progress Bar
  # [ratio] 0.0 to 1.0
  # [label] optional label string
  # [style] the style to apply (Style object)
  # [block] optional block widget
  Gauge = Data.define(:ratio, :label, :style, :block) do
    # Creates a new Gauge.
    # [ratio] the ratio to display.
    # [label] the label to display.
    # [style] the style to apply.
    # [block] the block to wrap the gauge.
    def initialize(ratio: 0.0, label: nil, style: Style.default, block: nil)
      super
    end
  end
end
