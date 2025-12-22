# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # A widget that displays a block of text.
  #
  # [text] the text to display.
  # [style] the style to apply (Style object).
  # [block] an optional Block widget to wrap the paragraph.
  class Paragraph < Data.define(:text, :style, :block)
    # Creates a new Paragraph.
    #
    # [text] the text to display.
    # [style] the style to apply.
    # [block] the block to wrap the paragraph.
    def initialize(text:, style: Style.default, block: nil)
      super
    end

    # Support for legacy fg/bg arguments.
    # [text] the text to display.
    # [style] the style to apply.
    # [fg] legacy foreground color.
    # [bg] legacy background color.
    # [block] the block to wrap the paragraph.
    def self.new(text:, style: nil, fg: nil, bg: nil, block: nil)
      style ||= Style.new(fg:, bg:)
      super(text:, style:, block:)
    end
  end
end
