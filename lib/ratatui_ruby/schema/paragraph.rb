# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # A widget that displays a block of text.
  #
  # [text] the text to display.
  # [fg] the foreground color (e.g., "red", "blue", "#ffffff").
  # [bg] the background color.
  class Paragraph < Data.define(:text, :fg, :bg)
    # Creates a new Paragraph.
    #
    # [text] the text to display.
    # [fg] the foreground color.
    # [bg] the background color.
    def initialize(text:, fg: nil, bg: nil)
      super
    end
  end
end
