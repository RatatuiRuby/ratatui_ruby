# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # A widget that displays a block of text.
  #
  # [text] the text to display.
  # [style] the style to apply (Style object).
  # [block] an optional Block widget to wrap the paragraph.
  # [scroll] scroll offset as (y, x) array matching ratatui convention.
  class Paragraph < Data.define(:text, :style, :block, :wrap, :align, :scroll)
    # Creates a new Paragraph.
    #
    # [text] the text to display.
    # [style] the style to apply.
    # [block] the block to wrap the paragraph.
    # [wrap] whether to wrap text at width.
    # [align] alignment (:left, :center, :right).
    # [scroll] scroll offset as (y, x) array (default: [0, 0]).
    def initialize(text:, style: Style.default, block: nil, wrap: false, align: :left, scroll: [0, 0])
      super
    end

    # Support for legacy fg/bg arguments.
    # [text] the text to display.
    # [style] the style to apply.
    # [fg] legacy foreground color.
    # [bg] legacy background color.
    # [block] the block to wrap the paragraph.
    # [wrap] whether to wrap text at width.
    # [align] alignment (:left, :center, :right).
    # [scroll] scroll offset as (y, x) array (default: [0, 0]).
    def self.new(text:, style: nil, fg: nil, bg: nil, block: nil, wrap: false, align: :left, scroll: [0, 0])
      style ||= Style.new(fg:, bg:)
      super(text:, style:, block:, wrap:, align:, scroll:)
    end
  end
end
