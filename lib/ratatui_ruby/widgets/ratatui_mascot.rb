# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

module RatatuiRuby
  module Widgets
    # Displays the Ratatui mascot.
    #
    # Interfaces without personality feel clinical and dry. Users appreciate a friendly face in their terminal.
    #
    # This widget renders the Ratatui mascot (a mouse).
    #
    # Use it to add charm to your application, greet users on startup, or as a decorative element in sidebars.
    #
    # {rdoc-image:/doc/images/widget_ratatui_mascot.png}[link:/examples/widget_ratatui_mascot/app_rb.html]
    #
    # === Example
    #
    # Run the interactive demo from the terminal:
    #
    #   ruby examples/widget_ratatui_mascot/app.rb
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
end
