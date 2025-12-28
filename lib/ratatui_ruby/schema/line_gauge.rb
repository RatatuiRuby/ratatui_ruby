# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # A compact progress bar using line characters.
  #
  # [ratio] A value between 0.0 and 1.0 representing the progress.
  # [label] An optional string to display on the gauge.
  # [filled_style] The Style object to apply to the filled portion of the gauge.
  # [unfilled_style] The Style object to apply to the unfilled portion of the gauge.
  # [block] An optional Block widget to wrap the gauge.
  # [filled_symbol] The character to use for the filled portion (default: "█").
  # [unfilled_symbol] The character to use for the unfilled portion (default: "░").
  class LineGauge < Data.define(:ratio, :label, :filled_style, :unfilled_style, :block, :filled_symbol, :unfilled_symbol)
    # Creates a new LineGauge.
    #
    # [ratio] A value between 0.0 and 1.0 representing the progress.
    # [label] An optional string to display on the gauge.
    # [filled_style] The Style object to apply to the filled portion of the gauge.
    # [unfilled_style] The Style object to apply to the unfilled portion of the gauge.
    # [block] An optional Block widget to wrap the gauge.
    # [filled_symbol] The character to use for the filled portion (default: "█").
    # [unfilled_symbol] The character to use for the unfilled portion (default: "░").
    def initialize(ratio: 0.0, label: nil, filled_style: nil, unfilled_style: nil, block: nil, filled_symbol: "█", unfilled_symbol: "░")
      super
    end
  end
end
