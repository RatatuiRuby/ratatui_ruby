# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # A widget that clears (resets) the terminal buffer in the area it is rendered into.
  #
  # The Clear widget is essential for creating opaque popups and modals. Without it,
  # background content or styles (like background colors) will "bleed through"
  # empty spaces or transparent widgets.
  #
  # > [!TIP]
  # > Use `Clear` to prevent "Style Bleed". If a widget rendered behind the popup
  # > has a background color, widgets rendered on top with `Style.default` will
  # > inherit that background color unless you `Clear` the area first.
  #
  # == Usage with Overlay
  #
  # Because RatatuiRuby uses an immediate-mode UI pattern, you must use {Overlay} to
  # layer widgets properly. The typical pattern for creating an opaque popup is:
  #
  #   background = Paragraph.new(text: "Background content...")
  #   popup = Paragraph.new(
  #     text: "Popup content",
  #     block: Block.new(title: "Popup", borders: [:all])
  #   )
  #
  #   # Create an opaque popup by layering: background -> Clear -> popup
  #   ui = Overlay.new(
  #     layers: [
  #       background,
  #       Center.new(
  #         child: Overlay.new(
  #           layers: [
  #             Clear.new,  # Erases background in this area
  #             popup       # Draws on top of cleared area
  #           ]
  #         ),
  #         width_percent: 50,
  #         height_percent: 40
  #       )
  #     ]
  #   )
  #
  # Without the Clear widget, the background text would be visible through the
  # empty spaces in the popup.
  #
  # == Optional Block Parameter
  #
  # You can optionally provide a {Block} to draw borders around the cleared area:
  #
  #   Clear.new(block: Block.new(title: "Cleared Area", borders: [:all]))
  #
  # This is equivalent to:
  #
  #   Overlay.new(
  #     layers: [
  #       Clear.new,
  #       Block.new(title: "Cleared Area", borders: [:all])
  #     ]
  #   )
  #
  # [block] Optional {Block} widget to render on top of the cleared area.
  #
  # @see Overlay
  # @see Center
  # @see Block
  class Clear < Data.define(:block)
    # Creates a new Clear widget.
    #
    # @param block [Block, nil] Optional block widget to render on top of the cleared area.
    #
    # @example Basic usage
    #   Clear.new
    #
    # @example With a border
    #   Clear.new(block: Block.new(title: "Modal", borders: [:all]))
    def initialize(block: nil)
      super
    end
  end
end
