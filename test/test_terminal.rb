# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

class TestTerminal < Minitest::Test
  include RatatuiRuby::TestHelper

  # TDD CYCLE 1: Terminal instance creation
  def test_terminal_instance_creation
    with_test_terminal do
      terminal = RatatuiRuby::Terminal.new
      assert_instance_of RatatuiRuby::Terminal, terminal
    end
  end

  # TDD CYCLE 2: Multiple independent terminal instances
  def test_multiple_terminals_are_independent_in_rust
    with_test_terminal do
      terminal1 = RatatuiRuby::Terminal.new
      terminal2 = RatatuiRuby::Terminal.new

      # Each should have unique IDs
      refute_equal terminal1.instance_variable_get(:@terminal_id),
        terminal2.instance_variable_get(:@terminal_id)
    end
  end

  # TDD CYCLE 3: terminal.size returns Layout::Rect (Rust constructs object)
  def test_terminal_size_returns_rect
    with_test_terminal do
      terminal = RatatuiRuby::Terminal.new
      size = terminal.size

      assert_instance_of RatatuiRuby::Layout::Rect, size
      assert_equal 80, size.width
      assert_equal 24, size.height
    end
  end
end
