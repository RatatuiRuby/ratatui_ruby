# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # A widget that displays a compact data row.
  #
  # [data] Array of Integers.
  # [max] Optional maximum value.
  # [style] Optional style for the sparkline.
  # [block] Optional block widget to wrap the sparkline.
  class Sparkline < Data.define(:data, :max, :style, :block)
    # Creates a new Sparkline widget.
    #
    # [data] Array of Integers.
    # [max] Optional maximum value.
    # [style] Optional style for the sparkline.
    # [block] Optional block widget to wrap the sparkline.
    def initialize(data:, max: nil, style: nil, block: nil)
      super
    end
  end
end
