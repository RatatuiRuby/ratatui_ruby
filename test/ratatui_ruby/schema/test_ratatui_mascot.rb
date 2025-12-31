# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

module RatatuiRuby
  class TestRatatuiMascot < Minitest::Test
    include TestHelper

    def test_default
      widget = RatatuiMascot.new
      with_test_terminal do
        RatatuiRuby.draw(widget)
        # Verify mascot is drawn (should contain some mascot characters)
        # The mascot uses block characters (pseudo-pixels)
        content = buffer_content.join("\n")
        
        # Check for block characters "▀" (upper half block) or "▄" (lower half block) or "█" (full block)
        # We can just check for any of these to ensure it's rendering blocks.
        assert_match(/[▀▄█]/, content, "Mascot should be rendered with block characters")
      end
    end



    def test_block
      # Test wrapping in a block
      block = Block.new(borders: [:all], title: "Ratatui")
      widget = RatatuiMascot.new(block: block)

      with_test_terminal do
        RatatuiRuby.draw(widget)
        
        content = buffer_content.join("\n")
        assert_includes content, "Ratatui" # Title
        assert_includes content, "┌"       # Border
        assert_includes content, "┐"
      end
    end
  end
end
