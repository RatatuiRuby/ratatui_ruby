# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # A widget that displays a progress bar.
  #
  # [ratio] A value between 0.0 and 1.0 representing the progress.
  # [label] An optional string to display on the gauge.
  # [style] The Style object to apply to the gauge.
  # [block] An optional Block widget to wrap the gauge.
  class Gauge < Data.define(:ratio, :label, :style, :block)
    # Creates a new Gauge.
    #
    # [ratio] A value between 0.0 and 1.0 representing the progress.
    # [label] An optional string to display on the gauge.
    # [style] The Style object to apply to the gauge.
    # [block] An optional Block widget to wrap the gauge.
    def initialize(ratio: 0.0, label: nil, style: Style.default, block: nil)
      super
    end
  end
end
