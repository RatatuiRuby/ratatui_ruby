# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  # Namespace for rich text components (Span, Line) and text utilities.
  # Distinct from canvas shapes and other Line usages.
  #
  # == Text Measurement
  #
  # The Text module provides a utility method for calculating the display width
  # of strings in terminal cells. This accounts for unicode complexity:
  #
  # - ASCII characters: 1 cell each
  # - CJK (Chinese, Japanese, Korean) characters: 2 cells each (full-width)
  # - Emoji: typically 2 cells each (varies by terminal)
  # - Combining marks: 0 cells (zero-width)
  #
  # This is essential for layout calculations in TUI applications, where you need to know
  # how much space a string will occupy on the screen, not just its byte or character length.
  #
  # === Use Cases
  #
  # - Auto-sizing widgets (Button, Badge) that fit their content
  # - Calculating padding or centering for text alignment
  # - Building responsive layouts that adapt to content width
  # - Measuring text for scrolling or truncation logic
  #
  # === Examples
  #
  #--
  # SPDX-SnippetBegin
  # SPDX-FileCopyrightText: 2026 Kerrick Long
  # SPDX-License-Identifier: MIT-0
  #++
  #   # Simple ASCII text
  #   RatatuiRuby::Text.width("Hello")        # => 5
  #
  #   # With emoji
  #   RatatuiRuby::Text.width("Hello 👍")     # => 8 (5 + space + 2-width emoji)
  #
  #   # With CJK characters
  #   RatatuiRuby::Text.width("你好")         # => 4 (each CJK char is 2 cells)
  #
  #   # Mixed content
  #   RatatuiRuby::Text.width("Hi 你好 👍")   # => 11 (2 + space + 4 + space + 2)
  #--
  # SPDX-SnippetEnd
  #++
  module Text
    ##
    # :method: width
    # :call-seq: width(string) -> Integer
    #
    # Calculates the display width of a string in terminal cells.
    #
    # Layout demands precision. Terminals measure space in cells, not characters. An ASCII letter occupies one cell. A Chinese character occupies two. An emoji occupies two. Combining marks occupy zero.
    #
    # Measuring width manually is error-prone. You can count <tt>string.length</tt>, but that counts characters, not cells. A string with one emoji counts as 1 character but occupies 2 cells.
    #
    # This method returns the true display width. Use it to auto-size widgets, calculate padding, center text, or build responsive layouts.
    #
    # === Examples
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   RatatuiRuby::Text.width("Hello")        # => 5 (5 ASCII chars × 1 cell)
    #
    #   RatatuiRuby::Text.width("你好")         # => 4 (2 CJK chars × 2 cells)
    #
    #   RatatuiRuby::Text.width("Hello 👍")     # => 8 (5 ASCII + 1 space + 1 emoji × 2)
    #
    #   # In the Session DSL (easier)
    #   RatatuiRuby.run do |tui|
    #     width = tui.text_width("Hello 👍")
    #   end
    #
    #--
    # SPDX-SnippetEnd
    #++
    # [string] String to measure (String or object convertible to String)
    # Returns: Integer (number of terminal cells the string occupies)
    # Raises: TypeError if the argument is not a String
    #
    # (Native method implemented in Rust)
    def self.width(string)
      RatatuiRuby._text_width(string)
    end
  end
end

require_relative "text/span"
require_relative "text/line"
