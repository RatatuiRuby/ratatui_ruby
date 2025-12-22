# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # Renders children on top of each other (Painter's Algorithm).
  #
  # [layers] Array of Widgets.
  class Overlay < Data.define(:layers)
    # Creates a new Overlay.
    #
    # [layers] Array of Widgets.
  end
end
