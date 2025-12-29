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
    class Scrollbar < Data.define(
      :content_length,
      :position,
      :orientation,
      :thumb_symbol,
      :thumb_style,
      :track_symbol,
      :track_style,
      :begin_symbol,
      :begin_style,
      :end_symbol,
      :end_style,
      :style,
      :block
    )
      ##
      # :attr_reader: content_length
      # Total items or lines in the content.

      ##
      # :attr_reader: position
      # Current scroll offset (index).

      ##
      # :attr_reader: orientation
      # Direction of the scrollbar.
      #
      # <tt>:vertical</tt> (default, alias for <tt>:vertical_right</tt>), <tt>:horizontal</tt> (alias for <tt>:horizontal_bottom</tt>),
      # <tt>:vertical_left</tt>, <tt>:vertical_right</tt>, <tt>:horizontal_top</tt>, or <tt>:horizontal_bottom</tt>.

      ##
      # :attr_reader: thumb_symbol
      # Symbol used to represent the current position indicator.

      ##
      # :attr_reader: thumb_style
      # Style of the position indicator (thumb).

      ##
      # :attr_reader: track_symbol
      # Symbol used to represent the empty space of the scrollbar.

      ##
      # :attr_reader: track_style
      # Style of the filled track area.

      ##
      # :attr_reader: begin_symbol
      # Symbol rendered at the start of the track (e.g., arrow).

      ##
      # :attr_reader: begin_style
      # Style of the start symbol.

      ##
      # :attr_reader: end_symbol
      # Symbol rendered at the end of the track (e.g., arrow).

      ##
      # :attr_reader: end_style
      # Style of the end symbol.

      ##
      # :attr_reader: style
      # Base style applied to the entire widget.

      ##
      # :attr_reader: block
      # Optional wrapping block.

      # Creates a new Scrollbar.
      #
      # [content_length] Integer.
      # [position] Integer.
      # [orientation] Symbol (default: <tt>:vertical</tt>).
      # [thumb_symbol] String (default: <tt>"█"</tt>).
      # [thumb_style] Style (optional).
      # [track_symbol] String (optional).
      # [track_style] Style (optional).
      # [begin_symbol] String (optional).
      # [begin_style] Style (optional).
      # [end_symbol] String (optional).
      # [end_style] Style (optional).
      # [style] Style (optional).
      # [block] Block (optional).
      def initialize(
        content_length:,
        position:,
        orientation: :vertical,
        thumb_symbol: "█",
        thumb_style: nil,
        track_symbol: nil,
        track_style: nil,
        begin_symbol: nil,
        begin_style: nil,
        end_symbol: nil,
        end_style: nil,
        style: nil,
        block: nil
      )
        super
      end
    end
end
