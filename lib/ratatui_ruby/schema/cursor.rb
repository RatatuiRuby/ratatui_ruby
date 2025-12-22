# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # Sets the terminal cursor position (ghost widget).
  #
  # [x] the x coordinate.
  # [y] the y coordinate.
  class Cursor < Data.define(:x, :y)
    # Creates a new Cursor.
    #
    # [x] the x coordinate.
    # [y] the y coordinate.
  end
end
