# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # A value object that defines colors and modifiers for text or widgets.
  #
  # [fg] The foreground color (e.g., +:red+, +"#ff0000"+).
  # [bg] The background color (e.g., +:black+, +"#000000"+).
  # [modifiers] An array of symbols representing text modifiers:
  #             [+:bold+, +:italic+, +:dim+, +:reversed+, +:underlined+, +:slow_blink+, +:rapid_blink+, +:crossed_out+, +:hidden+]
  class Style < Data.define(:fg, :bg, :modifiers)
    # Creates a new Style.
    #
    # [fg] The foreground color (e.g., "red", "#ff0000").
    # [bg] The background color (e.g., "black", "#000000").
    # [modifiers] An array of symbols representing text modifiers.
    def initialize(fg: nil, bg: nil, modifiers: [])
      super
    end

    # Returns a default style with no colors or modifiers.
    #
    #   Style.default
    #   # => #<RatatuiRuby::Style fg=nil, bg=nil, modifiers=[]>
    def self.default
      new
    end
  end
end
