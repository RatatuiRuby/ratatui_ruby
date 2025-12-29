# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
    # Visualizes the scroll state of a viewport.
    #
    # Content overflows. Users get lost in long lists without landmarks. They need to know where they are and how much is left.
    #
    # This widget maps your context. It draws a track and a thumb, representing your current position relative to the total length.
    #
    # Overlay it on top of lists, paragraphs, or tables to provide spatial awareness.
    #
    # === Examples
    #
    #   Scrollbar.new(
    #     content_length: 100,
    #     position: 25,
    #     orientation: :vertical
    #   )
    class Scrollbar < Data.define(:content_length, :position, :orientation, :thumb_symbol, :block)
      ##
      # :attr_reader: content_length
      # Total items or lines in the content.

      ##
      # :attr_reader: position
      # Current scroll offset (index).

      ##
      # :attr_reader: orientation
      # Orientation.
      #
      # <tt>:vertical</tt> or <tt>:horizontal</tt>.

      ##
      # :attr_reader: thumb_symbol
      # Character used for the thumb.

      ##
      # :attr_reader: block
      # Optional wrapping block.

      # Creates a new Scrollbar.
      #
      # [content_length] Integer.
      # [position] Integer.
      # [orientation] Symbol (default: <tt>:vertical</tt>).
      # [thumb_symbol] String (default: <tt>"█"</tt>).
      # [block] Block (optional).
      def initialize(content_length:, position:, orientation: :vertical, thumb_symbol: "█", block: nil)
        super
      end
    end
end
