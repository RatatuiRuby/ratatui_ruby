# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  module Layout
    # Horizontal content alignment within a layout area.
    #
    # Use these constants for discoverability, or pass symbols directly
    # (<tt>:left</tt>, <tt>:center</tt>, <tt>:right</tt>).
    #
    # Mirrors +ratatui::layout::HorizontalAlignment+ from upstream Ratatui.
    #
    # === Example
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   # Using constants (discoverable)
    #   paragraph = Paragraph.new(
    #     text: "Hello",
    #     alignment: HorizontalAlignment::CENTER
    #   )
    #
    #   # Using symbols directly (idiomatic Ruby)
    #   paragraph = Paragraph.new(text: "Hello", alignment: :center)
    #--
    # SPDX-SnippetEnd
    #++
    module HorizontalAlignment
      # Align content to the left edge.
      LEFT = :left

      # Align content to the center.
      CENTER = :center

      # Align content to the right edge.
      RIGHT = :right

      # All valid alignment values.
      ALL = [LEFT, CENTER, RIGHT].freeze
    end

    # Vertical content alignment within a layout area.
    #
    # Use these constants for discoverability, or pass symbols directly
    # (<tt>:top</tt>, <tt>:center</tt>, <tt>:bottom</tt>).
    #
    # Mirrors +ratatui::layout::VerticalAlignment+ from upstream Ratatui.
    #
    # === Example
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   # Using constants (discoverable)
    #   widget.vertical_alignment = VerticalAlignment::CENTER
    #
    #   # Using symbols directly (idiomatic Ruby)
    #   widget.vertical_alignment = :center
    #--
    # SPDX-SnippetEnd
    #++
    module VerticalAlignment
      # Align content to the top edge.
      TOP = :top

      # Align content to the center.
      CENTER = :center

      # Align content to the bottom edge.
      BOTTOM = :bottom

      # All valid alignment values.
      ALL = [TOP, CENTER, BOTTOM].freeze
    end

    # Type alias for HorizontalAlignment.
    #
    # Provided for upstream API parity. In Ratatui, +Alignment+ was the
    # original name before +HorizontalAlignment+ was introduced in v0.30.0.
    Alignment = HorizontalAlignment
  end
end
