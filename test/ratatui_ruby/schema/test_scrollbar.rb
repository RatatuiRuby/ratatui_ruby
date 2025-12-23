# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

module RatatuiRuby
  class TestScrollbar < Minitest::Test
    def test_scrollbar_creation
      s = Scrollbar.new(content_length: 100, position: 10, orientation: :horizontal, thumb_symbol: "X")
      assert_equal 100, s.content_length
      assert_equal 10, s.position
      assert_equal :horizontal, s.orientation
      assert_equal "X", s.thumb_symbol
    end

    def test_scrollbar_defaults
      s = Scrollbar.new(content_length: 50, position: 5)
      assert_equal 50, s.content_length
      assert_equal 5, s.position
      assert_equal :vertical, s.orientation
      assert_equal "█", s.thumb_symbol
      assert_nil s.block
    end

    def test_render_vertical
      # Standard vertical scrollbar is on the right of the area
      with_test_terminal(1, 10) do
        s = Scrollbar.new(content_length: 10, position: 0)
        RatatuiRuby.draw(s)
        # Position 0 has thumb at row 1, 2, 3, 4
        assert_equal "▲", buffer_content[0]
        assert_equal "█", buffer_content[1]
        assert_equal "█", buffer_content[2]
        assert_equal "█", buffer_content[3]
        assert_equal "█", buffer_content[4]
        assert_equal "║", buffer_content[5]
        assert_equal "║", buffer_content[6]
        assert_equal "║", buffer_content[7]
        assert_equal "║", buffer_content[8]
        assert_equal "▼", buffer_content[9]
      end
    end

    def test_render_horizontal
      with_test_terminal(10, 1) do
        s = Scrollbar.new(content_length: 10, position: 0, orientation: :horizontal)
        RatatuiRuby.draw(s)
        # Position 0 has thumb at column 1-4
        assert_equal "◄████════►", buffer_content[0]
      end
    end
  end
end
