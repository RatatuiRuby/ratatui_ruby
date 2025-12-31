# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # Displays the Ratatui mascot.
  #
  # A widget that renders the Ratatui mascot (a rat).
  #
  # === Examples
  #
  #   RatatuiMascot.new(
  #     block: Block.new(title: "Mascot")
  #   )
  #
  class RatatuiMascot < Data.define(:block)
    ##
    # :method: new
    # :call-seq: new(block: nil) -> RatatuiMascot
    #
    # Creates a new RatatuiMascot.
    #
    # @param block [Block, nil] A block to wrap the widget in.
    def initialize(block: nil)
      super
    end
  end
end
