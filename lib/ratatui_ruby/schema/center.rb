# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # Centers a child widget within the current area.
  #
  # [child] the widget to center.
  # [width_percent] the width percentage of the centered area.
  # [height_percent] the height percentage of the centered area.
  class Center < Data.define(:child, :width_percent, :height_percent)
    # Creates a new Center.
    #
    # [child] the widget to center.
    # [width_percent] the width percentage of the centered area.
    # [height_percent] the height percentage of the centered area.
  end
end
