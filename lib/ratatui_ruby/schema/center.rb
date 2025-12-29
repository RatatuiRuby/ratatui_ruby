# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
    # Centers content within available space.
    #
    # Layouts often require alignment. Manually calculating offsets for centering is error-prone and brittle.
    #
    # This widget handles the math. It centers a child widget within the current area, resizing the child
    # according to optional percentage modifiers.
    #
    # Use it to position modals, splash screens, or floating dialogue boxes.
    #
    # === Examples
    #
    #   # Center a paragraph using 50% of width and height
    #   Center.new(
    #     child: Paragraph.new(text: "Hello"),
    #     width_percent: 50,
    #     height_percent: 50
    #   )
    class Center < Data.define(:child, :width_percent, :height_percent)
      ##
      # :attr_reader: child
      # The widget to be centered.

      ##
      # :attr_reader: width_percent
      # Width of the centered area as a percentage (0-100).
      #
      # If 50, the child occupies half the available width.

      ##
      # :attr_reader: height_percent
      # Height of the centered area as a percentage (0-100).
      #
      # If 50, the child occupies half the available height.

      # Creates a new Center widget.
      #
      # [child]
      #   Widget to render.
      # [width_percent]
      #   Target width percentage (Integer, default: 100).
      # [height_percent]
      #   Target height percentage (Integer, default: 100).
      def initialize(child:, width_percent: 100, height_percent: 100)
        super
      end
    end
end
