# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

module RatatuiRuby
  # Resets the terminal buffer for a specific area.
  #
  # Painting in a terminal is additive. New content draws over old content. If the new content has transparency
  # or empty spaces, the old content "bleeds" through. This ruins popups and modals.
  #
  # This widget wipes the slate clean. It resets all cells in its area to their default state (spaces with default background).
  #
  # Use it as the first layer in an Overlay stack when building popups. Ensure your floating windows are truly opaque.
  #
  # === Examples
  #
  #   # Opaque Popup Construction
  #   Overlay.new(
  #     layers: [
  #       MainUI.new,
  #       Center.new(
  #         child: Overlay.new(
  #           layers: [
  #             Clear.new, # Wipe the area first
  #             Block.new(title: "Modal", borders: [:all])
  #           ]
  #         ),
  #         width_percent: 50,
  #         height_percent: 50
  #       )
  #     ]
  #   )
  #
  #   # Shortcut: rendering a block directly
  #   Clear.new(block: Block.new(title: "Cleared area", borders: [:all]))
  class Clear < Data.define(:block)
    ##
    # :attr_reader: block
    # Optional Block to render after clearing.
    #
    # If provided, the borders/title of this block are drawn on top of the cleared area.

    # Creates a new Clear widget.
    #
    # [block]
    #   Block widget to render (optional).
    def initialize(block: nil)
      super
    end
  end
end
