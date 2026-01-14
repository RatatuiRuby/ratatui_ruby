# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

require "test_helper"

module RatatuiRuby
  module Layout
    class TestPosition < Minitest::Test
      def test_deconstruct_returns_x_and_y_as_array
        pos = Position.new(x: 10, y: 5)
        x, y = pos

        assert_equal 10, x
        assert_equal 5, y
      end
    end
  end
end
