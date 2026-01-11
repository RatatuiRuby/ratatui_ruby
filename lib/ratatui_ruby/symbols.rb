# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  # Symbol constants from Ratatui's symbols module.
  #
  # Ratatui provides various character sets for rendering UI elements.
  # Hardcoding these characters is error-prone and makes code less readable.
  #
  # This module exposes those constants for Ruby apps to use directly.
  # Use them for gradients, fills, or custom widget styling.
  module Symbols
    # Shade characters for creating gradient or density effects.
    #
    # Terminal UIs often need to show density levels or create visual gradients.
    # Memorizing Unicode block characters is tedious and error-prone.
    #
    # These constants provide named access to the standard shade characters.
    # Use them to fill areas with varying visual densities.
    #
    # === Examples
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   # Create a density gradient
    #   gradient = [Shade::EMPTY, Shade::LIGHT, Shade::MEDIUM, Shade::DARK, Shade::FULL]
    #
    #   # Use in a progress indicator
    #   filled = Shade::FULL * progress
    #   empty = Shade::LIGHT * (total - progress)
    #--
    # SPDX-SnippetEnd
    #++
    module Shade
      # Empty space - 0% density.
      EMPTY = " "

      # Light shading - approximately 25% density.
      LIGHT = "░"

      # Medium shading - approximately 50% density.
      MEDIUM = "▒"

      # Dark shading - approximately 75% density.
      DARK = "▓"

      # Full block - 100% density.
      FULL = "█"
    end

    # Box-drawing characters for borders and lines.
    #
    # Terminal UIs need consistent box-drawing characters for borders and dividers.
    # Memorizing Unicode box-drawing characters is tedious and error-prone.
    #
    # This module exposes both individual characters and predefined sets.
    # Use the sets with widgets that accept a line_set parameter, or use
    # individual characters for custom drawing.
    #
    # === Examples
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   # Use a predefined set for drawing boxes
    #   line_set = Symbols::Line::ROUNDED
    #
    #   # Draw a simple frame
    #   top = "#{line_set[:top_left]}#{line_set[:horizontal] * 10}#{line_set[:top_right]}"
    #   mid = "#{line_set[:vertical]}#{' ' * 10}#{line_set[:vertical]}"
    #   bot = "#{line_set[:bottom_left]}#{line_set[:horizontal] * 10}#{line_set[:bottom_right]}"
    #
    #   # Use individual characters for custom drawing
    #   corner = Symbols::Line::ROUNDED_TOP_LEFT  # => "╭"
    #--
    # SPDX-SnippetEnd
    #++
    module Line
      # Standard vertical line.
      VERTICAL = "│"
      # Double vertical line.
      DOUBLE_VERTICAL = "║"
      # Thick (heavy) vertical line.
      THICK_VERTICAL = "┃"

      # Standard horizontal line.
      HORIZONTAL = "─"
      # Double horizontal line.
      DOUBLE_HORIZONTAL = "═"
      # Thick (heavy) horizontal line.
      THICK_HORIZONTAL = "━"

      # Standard top-right corner.
      TOP_RIGHT = "┐"
      # Rounded top-right corner.
      ROUNDED_TOP_RIGHT = "╮"
      # Double top-right corner.
      DOUBLE_TOP_RIGHT = "╗"
      # Thick top-right corner.
      THICK_TOP_RIGHT = "┓"

      # Standard top-left corner.
      TOP_LEFT = "┌"
      # Rounded top-left corner.
      ROUNDED_TOP_LEFT = "╭"
      # Double top-left corner.
      DOUBLE_TOP_LEFT = "╔"
      # Thick top-left corner.
      THICK_TOP_LEFT = "┏"

      # Standard bottom-right corner.
      BOTTOM_RIGHT = "┘"
      # Rounded bottom-right corner.
      ROUNDED_BOTTOM_RIGHT = "╯"
      # Double bottom-right corner.
      DOUBLE_BOTTOM_RIGHT = "╝"
      # Thick bottom-right corner.
      THICK_BOTTOM_RIGHT = "┛"

      # Standard bottom-left corner.
      BOTTOM_LEFT = "└"
      # Rounded bottom-left corner.
      ROUNDED_BOTTOM_LEFT = "╰"
      # Double bottom-left corner.
      DOUBLE_BOTTOM_LEFT = "╚"
      # Thick bottom-left corner.
      THICK_BOTTOM_LEFT = "┗"

      # Standard T-junction pointing left.
      VERTICAL_LEFT = "┤"
      # Double T-junction pointing left.
      DOUBLE_VERTICAL_LEFT = "╣"
      # Thick T-junction pointing left.
      THICK_VERTICAL_LEFT = "┫"

      # Standard T-junction pointing right.
      VERTICAL_RIGHT = "├"
      # Double T-junction pointing right.
      DOUBLE_VERTICAL_RIGHT = "╠"
      # Thick T-junction pointing right.
      THICK_VERTICAL_RIGHT = "┣"

      # Standard T-junction pointing down.
      HORIZONTAL_DOWN = "┬"
      # Double T-junction pointing down.
      DOUBLE_HORIZONTAL_DOWN = "╦"
      # Thick T-junction pointing down.
      THICK_HORIZONTAL_DOWN = "┳"

      # Standard T-junction pointing up.
      HORIZONTAL_UP = "┴"
      # Double T-junction pointing up.
      DOUBLE_HORIZONTAL_UP = "╩"
      # Thick T-junction pointing up.
      THICK_HORIZONTAL_UP = "┻"

      # Standard cross (4-way intersection).
      CROSS = "┼"
      # Double cross (4-way intersection).
      DOUBLE_CROSS = "╬"
      # Thick cross (4-way intersection).
      THICK_CROSS = "╋"

      # Standard box-drawing set with straight corners.
      NORMAL = {
        vertical: VERTICAL,
        horizontal: HORIZONTAL,
        top_right: TOP_RIGHT,
        top_left: TOP_LEFT,
        bottom_right: BOTTOM_RIGHT,
        bottom_left: BOTTOM_LEFT,
        vertical_left: VERTICAL_LEFT,
        vertical_right: VERTICAL_RIGHT,
        horizontal_down: HORIZONTAL_DOWN,
        horizontal_up: HORIZONTAL_UP,
        cross: CROSS,
      }.freeze

      # Box-drawing set with rounded corners.
      ROUNDED = {
        vertical: VERTICAL,
        horizontal: HORIZONTAL,
        top_right: ROUNDED_TOP_RIGHT,
        top_left: ROUNDED_TOP_LEFT,
        bottom_right: ROUNDED_BOTTOM_RIGHT,
        bottom_left: ROUNDED_BOTTOM_LEFT,
        vertical_left: VERTICAL_LEFT,
        vertical_right: VERTICAL_RIGHT,
        horizontal_down: HORIZONTAL_DOWN,
        horizontal_up: HORIZONTAL_UP,
        cross: CROSS,
      }.freeze

      # Double-line box-drawing set.
      DOUBLE = {
        vertical: DOUBLE_VERTICAL,
        horizontal: DOUBLE_HORIZONTAL,
        top_right: DOUBLE_TOP_RIGHT,
        top_left: DOUBLE_TOP_LEFT,
        bottom_right: DOUBLE_BOTTOM_RIGHT,
        bottom_left: DOUBLE_BOTTOM_LEFT,
        vertical_left: DOUBLE_VERTICAL_LEFT,
        vertical_right: DOUBLE_VERTICAL_RIGHT,
        horizontal_down: DOUBLE_HORIZONTAL_DOWN,
        horizontal_up: DOUBLE_HORIZONTAL_UP,
        cross: DOUBLE_CROSS,
      }.freeze

      # Thick (heavy) box-drawing set.
      THICK = {
        vertical: THICK_VERTICAL,
        horizontal: THICK_HORIZONTAL,
        top_right: THICK_TOP_RIGHT,
        top_left: THICK_TOP_LEFT,
        bottom_right: THICK_BOTTOM_RIGHT,
        bottom_left: THICK_BOTTOM_LEFT,
        vertical_left: THICK_VERTICAL_LEFT,
        vertical_right: THICK_VERTICAL_RIGHT,
        horizontal_down: THICK_HORIZONTAL_DOWN,
        horizontal_up: THICK_HORIZONTAL_UP,
        cross: THICK_CROSS,
      }.freeze
    end

    # Vertical bar characters for sparklines and bar charts.
    #
    # Sparklines and vertical bar charts need characters that show partial fill.
    # Memorizing Unicode lower block characters is tedious and error-prone.
    #
    # This module exposes both individual characters and predefined sets.
    # Use the sets with Sparkline widget, or use individual characters for
    # custom visualizations.
    #
    # === Examples
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   # Use NINE_LEVELS for high-resolution sparklines (default)
    #   sparkline = tui.sparkline(data: [1, 2, 3], bar_set: Symbols::Bar::NINE_LEVELS)
    #
    #   # Use THREE_LEVELS for simpler rendering
    #   sparkline = tui.sparkline(data: [1, 2, 3], bar_set: Symbols::Bar::THREE_LEVELS)
    #--
    # SPDX-SnippetEnd
    #++
    module Bar
      # Full height bar (8/8).
      FULL = "█"
      # 7/8 height bar.
      SEVEN_EIGHTHS = "▇"
      # 3/4 height bar (6/8).
      THREE_QUARTERS = "▆"
      # 5/8 height bar.
      FIVE_EIGHTHS = "▅"
      # Half height bar (4/8).
      HALF = "▄"
      # 3/8 height bar.
      THREE_EIGHTHS = "▃"
      # 1/4 height bar (2/8).
      ONE_QUARTER = "▂"
      # 1/8 height bar.
      ONE_EIGHTH = "▁"

      # High-resolution bar set with 9 distinct levels.
      NINE_LEVELS = {
        full: FULL,
        seven_eighths: SEVEN_EIGHTHS,
        three_quarters: THREE_QUARTERS,
        five_eighths: FIVE_EIGHTHS,
        half: HALF,
        three_eighths: THREE_EIGHTHS,
        one_quarter: ONE_QUARTER,
        one_eighth: ONE_EIGHTH,
        empty: " ",
      }.freeze

      # Low-resolution bar set with 3 levels (full, half, empty).
      THREE_LEVELS = {
        full: FULL,
        seven_eighths: FULL, # collapsed to full
        three_quarters: HALF, # collapsed to half
        five_eighths: HALF, # collapsed to half
        half: HALF,
        three_eighths: HALF, # collapsed to half
        one_quarter: HALF, # collapsed to half
        one_eighth: " ", # collapsed to empty
        empty: " ",
      }.freeze
    end

    # Horizontal block characters for gauges and progress indicators.
    #
    # Progress bars and gauges need characters that show partial fill from left to right.
    # Memorizing Unicode left block characters is tedious and error-prone.
    #
    # This module exposes both individual characters and predefined sets.
    # Use the sets with Gauge widget, or use individual characters for
    # custom progress indicators.
    #
    # Note: Block uses LEFT block characters (fill from left) while Bar uses
    # LOWER block characters (fill from bottom). They look similar but are different.
    #
    # === Examples
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   # Use NINE_LEVELS for high-resolution gauges (default)
    #   gauge = tui.gauge(percent: 50, block_set: Symbols::Block::NINE_LEVELS)
    #
    #   # Use THREE_LEVELS for simpler rendering
    #   gauge = tui.gauge(percent: 50, block_set: Symbols::Block::THREE_LEVELS)
    #--
    # SPDX-SnippetEnd
    #++
    module Block
      # Full width block (8/8).
      FULL = "█"
      # 7/8 width block.
      SEVEN_EIGHTHS = "▉"
      # 3/4 width block (6/8).
      THREE_QUARTERS = "▊"
      # 5/8 width block.
      FIVE_EIGHTHS = "▋"
      # Half width block (4/8).
      HALF = "▌"
      # 3/8 width block.
      THREE_EIGHTHS = "▍"
      # 1/4 width block (2/8).
      ONE_QUARTER = "▎"
      # 1/8 width block.
      ONE_EIGHTH = "▏"

      # High-resolution block set with 9 distinct levels.
      NINE_LEVELS = {
        full: FULL,
        seven_eighths: SEVEN_EIGHTHS,
        three_quarters: THREE_QUARTERS,
        five_eighths: FIVE_EIGHTHS,
        half: HALF,
        three_eighths: THREE_EIGHTHS,
        one_quarter: ONE_QUARTER,
        one_eighth: ONE_EIGHTH,
        empty: " ",
      }.freeze

      # Low-resolution block set with 3 levels (full, half, empty).
      THREE_LEVELS = {
        full: FULL,
        seven_eighths: FULL, # collapsed to full
        three_quarters: HALF, # collapsed to half
        five_eighths: HALF, # collapsed to half
        half: HALF,
        three_eighths: HALF, # collapsed to half
        one_quarter: HALF, # collapsed to half
        one_eighth: " ", # collapsed to empty
        empty: " ",
      }.freeze
    end

    # Scrollbar symbol sets for the Scrollbar widget.
    #
    # Scrollbars need consistent visual elements: a track, a thumb, and arrow indicators.
    # Memorizing Unicode scroll characters is tedious and error-prone.
    #
    # This module exposes predefined sets with different visual styles.
    # Use them with the Scrollbar widget to customize its appearance.
    #
    # Note: Uses <tt>begin_char</tt> and <tt>end_char</tt> instead of Rust's
    # <tt>begin</tt>/<tt>end</tt> to avoid Ruby reserved word conflicts.
    #
    # === Examples
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   # Use DOUBLE_VERTICAL for bold vertical scrollbars (default)
    #   scrollbar = tui.scrollbar(symbols: Symbols::Scrollbar::DOUBLE_VERTICAL)
    #
    #   # Use VERTICAL for lighter appearance
    #   scrollbar = tui.scrollbar(symbols: Symbols::Scrollbar::VERTICAL)
    #--
    # SPDX-SnippetEnd
    #++
    module Scrollbar
      # Double-line vertical scrollbar with triangle arrows.
      DOUBLE_VERTICAL = {
        track: Line::DOUBLE_VERTICAL,
        thumb: Block::FULL,
        begin_char: "▲",
        end_char: "▼",
      }.freeze

      # Double-line horizontal scrollbar with triangle arrows.
      DOUBLE_HORIZONTAL = {
        track: Line::DOUBLE_HORIZONTAL,
        thumb: Block::FULL,
        begin_char: "◄",
        end_char: "►",
      }.freeze

      # Single-line vertical scrollbar with arrow characters.
      VERTICAL = {
        track: Line::VERTICAL,
        thumb: Block::FULL,
        begin_char: "↑",
        end_char: "↓",
      }.freeze

      # Single-line horizontal scrollbar with arrow characters.
      HORIZONTAL = {
        track: Line::HORIZONTAL,
        thumb: Block::FULL,
        begin_char: "←",
        end_char: "→",
      }.freeze
    end
  end
end
