# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # Stacks widgets on top of each other.
  #
  # Terminal interfaces are 2D grids, but complex UIs require depth. You need to float modals over text,
  # or place a status bar on top of a map.
  #
  # This widget manages the Z-axis. It renders a list of widgets sequentially into the same area.
  # Later widgets draw over earlier ones (Painter's Algorithm).
  #
  # Use overlays to compose complex scenes. Combine backgrounds, main content, and floating elements.
  #
  # === Examples
  #
  #   Overlay.new(
  #     layers: [
  #       BackgroundMap.new,
  #       StatusBar.new,   # Draws over map
  #       ModalDialog.new  # Draws over everything
  #     ]
  #   )
  class Overlay < Data.define(:layers)
    ##
    # :attr_reader: layers
    # The stack of widgets to render.
    #
    # Rendered from index 0 to N. Index N is the top-most layer.

    # Creates a new Overlay.
    #
    # [layers]
    #   Array of widgets.
    def initialize(layers: [])
      super
    end
  end
end
