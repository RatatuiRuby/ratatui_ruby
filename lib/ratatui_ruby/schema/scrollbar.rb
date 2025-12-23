# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  ##
  # Visual scroll indicator.
  #
  # A Scrollbar widget that can be oriented vertically or horizontally.
  # It displays a track and a thumb to indicate the current scroll position
  # relative to the total content length.
  #
  # == Fields
  #
  # [+content_length+] Total length of the content (Integer).
  # [+position+] Current scroll position (Integer).
  # [+orientation+] +:vertical+ or +:horizontal+ (Symbol, default: +:vertical+).
  # [+thumb_symbol+] The character used for the scrollbar thumb (String, default: "█").
  # [+block+] An optional Block to wrap the scrollbar.
  class Scrollbar < Data.define(:content_length, :position, :orientation, :thumb_symbol, :block)
    # Creates a new Scrollbar.
    #
    # [+content_length+] Total length of the content (Integer).
    # [+position+] Current scroll position (Integer).
    # [+orientation+] +:vertical+ or +:horizontal+ (Symbol, default: +:vertical+).
    # [+thumb_symbol+] The character used for the scrollbar thumb (String, default: "█").
    # [+block+] An optional Block to wrap the scrollbar.
    def initialize(content_length:, position:, orientation: :vertical, thumb_symbol: "█", block: nil)
      super
    end
  end
end
