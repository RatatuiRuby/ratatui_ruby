# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # A widget that displays a block of text.
  #
  # [text] the text to display.
  # [fg] the foreground color (e.g., "red", "blue", "#ffffff").
  # [bg] the background color.
  # [block] an optional Block widget to wrap the paragraph.
  class Paragraph < Data.define(:text, :fg, :bg, :block)
    # Creates a new Paragraph.
    #
    # [text] the text to display.
    # [fg] the foreground color.
    # [bg] the background color.
    # [block] the block to wrap the paragraph.
    def initialize(text:, fg: :reset, bg: :reset, block: nil)
      super
    end
  end
end
