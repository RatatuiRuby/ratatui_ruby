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
  end
end
