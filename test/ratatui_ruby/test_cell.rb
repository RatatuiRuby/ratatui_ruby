# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "minitest/autorun"
require "ratatui_ruby"
require "ratatui_ruby/test_helper"

module RatatuiRuby
  class TestCell < Minitest::Test
    include RatatuiRuby::TestHelper
    include TestHelper

    def test_cell_properties
      cell = Cell.new(char: "X", fg: :red, bg: :blue, modifiers: ["bold", "italic"])

      assert_equal "X", cell.char
      assert_equal :red, cell.fg
      assert_equal :blue, cell.bg
      assert_equal ["bold", "italic"], cell.modifiers

      assert_predicate cell, :bold?
      assert_predicate cell, :italic?
      refute_predicate cell, :dim?
    end

    def test_cell_empty
      cell = Cell.empty
      assert_equal " ", cell.char
      assert_nil cell.fg
      assert_nil cell.bg
      assert_empty cell.modifiers
    end

    def test_cell_default
      cell = Cell.default
      assert_equal Cell.empty, cell
    end

    def test_cell_char
      cell = Cell.char("Z")
      assert_equal "Z", cell.char
      assert_equal "Z", cell.symbol # alias works too
      assert_nil cell.fg
      assert_nil cell.bg
      assert_empty cell.modifiers
    end

    def test_cell_symbol
      cell = Cell.symbol("Y")
      assert_equal "Y", cell.symbol
      assert_equal "Y", cell.char # alias works too
      assert_nil cell.fg
      assert_nil cell.bg
      assert_empty cell.modifiers
    end

    def test_initialize_accepts_both_symbol_and_char
      # Using symbol: (primary)
      c1 = Cell.new(symbol: "A", fg: :red)
      assert_equal "A", c1.symbol
      assert_equal "A", c1.char

      # Using char: (alias)
      c2 = Cell.new(char: "B", fg: :blue)
      assert_equal "B", c2.symbol
      assert_equal "B", c2.char
    end

    def test_equality
      c1 = Cell.new(char: "A", fg: :green)
      c2 = Cell.new(char: "A", fg: :green)
      c3 = Cell.new(char: "B", fg: :green)

      assert_equal c1, c2
      refute_equal c1, c3
    end

    def test_inspect
      c1 = Cell.new(char: "X", fg: :red, modifiers: ["bold"])
      assert_equal '#<RatatuiRuby::Cell symbol="X" fg=:red modifiers=["bold"]>', c1.inspect

      c2 = Cell.empty
      assert_equal '#<RatatuiRuby::Cell symbol=" ">', c2.inspect
    end

    def test_to_s
      c = Cell.new(char: "X", fg: :red)
      assert_equal "X", c.to_s
      assert_equal " ", Cell.empty.to_s
    end

    def test_pattern_matching
      cell = Cell.new(char: "X", fg: :red)

      matched = case cell
      in { char: "X", fg: :red }
        true
      else
        false
      end

      assert matched, "Cell should match pattern { char: 'X', fg: :red }"

      matched_partial = case cell
      in { char: "X" }
        true
      else
        false
      end

      assert matched_partial, "Cell should match partial pattern { char: 'X' }"
    end

    def test_get_cell_at_integration
      with_test_terminal(10, 5) do
        RatatuiRuby.draw do |f|
          f.render_widget(Block.new(title: "Hi", borders: :all), f.area)
        end

        # Title at (1, 0): "H"
        cell = RatatuiRuby.get_cell_at(1, 0)
        assert_instance_of Cell, cell
        assert_equal "H", cell.char

        # Checking underlying helper usage too
        assert_cell_style(1, 0, char: "H")
      end
    end

    def test_cell_is_ractor_shareable
      cell = Cell.new(char: "X", fg: :red, bg: "blue", modifiers: ["bold", "italic"])
      assert Ractor.shareable?(cell), "Cell should be Ractor.shareable? for thread/Ractor safety"
    end
  end
end
