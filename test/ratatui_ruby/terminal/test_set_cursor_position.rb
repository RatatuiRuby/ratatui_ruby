# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

require "test_helper"

module RatatuiRuby
  class Terminal
    class TestSetCursorPosition < Minitest::Test
      include TestHelper::Terminal

      def test_set_cursor_position_sets_cursor_to_specified_coordinates
        with_test_terminal do
          RatatuiRuby.set_cursor_position(5, 10)

          x, y = RatatuiRuby.get_cursor_position
          assert_equal 5, x
          assert_equal 10, y
        end
      end

      def test_cursor_position_getter_and_setter_aliases
        with_test_terminal do
          RatatuiRuby.cursor_position = RatatuiRuby::Layout::Position.new(x: 5, y: 10)

          pos = RatatuiRuby.cursor_position
          assert_instance_of RatatuiRuby::Layout::Position, pos
          assert_equal 5, pos.x
          assert_equal 10, pos.y
        end
      end

      def test_cursor_position_getter_and_setter_shorthand
        with_test_terminal do
          RatatuiRuby.cursor_position = 5, 10

          x, y = RatatuiRuby.cursor_position
          assert_equal 5, x
          assert_equal 10, y
        end
      end
    end
  end
end
