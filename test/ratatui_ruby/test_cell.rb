# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "minitest/autorun"
require "ratatui_ruby"
require "ratatui_ruby/test_helper"

module RatatuiRuby
  class TestCell < Minitest::Test
    include RatatuiRuby::TestHelper
    include TestHelper

    def test_cell_properties
      cell = Buffer::Cell.new(char: "X", fg: :red, bg: :blue, modifiers: ["bold", "italic"])

      assert_equal "X", cell.char
      assert_equal :red, cell.fg
      assert_equal :blue, cell.bg
      assert_equal [:bold, :italic], cell.modifiers

      assert_predicate cell, :bold?
      assert_predicate cell, :italic?
      refute_predicate cell, :dim?
    end

    def test_cell_empty
      cell = Buffer::Cell.empty
      assert_equal " ", cell.char
      assert_nil cell.fg
      assert_nil cell.bg
      assert_empty cell.modifiers
    end

    def test_cell_default
      cell = Buffer::Cell.default
      assert_equal Buffer::Cell.empty, cell
    end

    def test_cell_char
      cell = Buffer::Cell.char("Z")
      assert_equal "Z", cell.char
      assert_equal "Z", cell.symbol # alias works too
      assert_nil cell.fg
      assert_nil cell.bg
      assert_empty cell.modifiers
    end

    def test_cell_symbol
      cell = Buffer::Cell.symbol("Y")
      assert_equal "Y", cell.symbol
      assert_equal "Y", cell.char # alias works too
      assert_nil cell.fg
      assert_nil cell.bg
      assert_empty cell.modifiers
    end

    def test_initialize_accepts_both_symbol_and_char
      # Using symbol: (primary)
      c1 = Buffer::Cell.new(symbol: "A", fg: :red)
      assert_equal "A", c1.symbol
      assert_equal "A", c1.char

      # Using char: (alias)
      c2 = Buffer::Cell.new(char: "B", fg: :blue)
      assert_equal "B", c2.symbol
      assert_equal "B", c2.char
    end

    def test_equality
      c1 = Buffer::Cell.new(char: "A", fg: :green)
      c2 = Buffer::Cell.new(char: "A", fg: :green)
      c3 = Buffer::Cell.new(char: "B", fg: :green)

      assert_equal c1, c2
      refute_equal c1, c3
    end

    def test_inspect
      c1 = Buffer::Cell.new(char: "X", fg: :red, modifiers: ["bold"])
      assert_equal '#<RatatuiRuby::Buffer::Cell symbol="X" fg=:red modifiers=[:bold]>', c1.inspect

      c2 = Buffer::Cell.empty
      assert_equal '#<RatatuiRuby::Buffer::Cell symbol=" ">', c2.inspect
    end

    def test_to_s
      c = Buffer::Cell.new(char: "X", fg: :red)
      assert_equal "X", c.to_s
      assert_equal " ", Buffer::Cell.empty.to_s
    end

    def test_pattern_matching
      cell = Buffer::Cell.new(char: "X", fg: :red)

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
          f.render_widget(Widgets::Block.new(title: "Hi", borders: :all), f.area)
        end

        # Title at (1, 0): "H"
        cell = RatatuiRuby.get_cell_at(1, 0)
        assert_instance_of Buffer::Cell, cell
        assert_equal "H", cell.char

        # Checking underlying helper usage too
        assert_cell_style(1, 0, char: "H")
      end
    end

    def test_cell_is_ractor_shareable
      cell = Buffer::Cell.new(char: "X", fg: :red, bg: "blue", modifiers: ["bold", "italic"])
      assert Ractor.shareable?(cell), "Cell should be Ractor.shareable? for thread/Ractor safety"
    end

    # DWIM: modifiers accept strings, symbols, or anything with to_sym/to_s
    # and normalize to symbols for consistent output
    def test_modifiers_normalize_strings_to_symbols
      cell = Buffer::Cell.new(char: "X", modifiers: ["bold", "italic"])
      assert_equal [:bold, :italic], cell.modifiers
      assert_predicate cell, :bold?
      assert_predicate cell, :italic?
    end

    def test_modifiers_normalize_symbols_to_symbols
      cell = Buffer::Cell.new(char: "X", modifiers: [:bold, :dim])
      assert_equal [:bold, :dim], cell.modifiers
      assert_predicate cell, :bold?
      assert_predicate cell, :dim?
    end

    def test_modifiers_normalize_mixed_input
      cell = Buffer::Cell.new(char: "X", modifiers: ["bold", :italic, "underlined"])
      assert_equal [:bold, :italic, :underlined], cell.modifiers
      assert_predicate cell, :bold?
      assert_predicate cell, :italic?
      assert_predicate cell, :underlined?
    end

    def test_modifiers_normalize_custom_to_sym_object
      # Any object responding to to_sym should work
      custom = Object.new
      def custom.to_sym = :reversed
      cell = Buffer::Cell.new(char: "X", modifiers: [custom])
      assert_equal [:reversed], cell.modifiers
      assert_predicate cell, :reversed?
    end

    def test_modifiers_normalize_custom_to_s_object
      # Fallback: object without to_sym but with to_s
      custom = Object.new
      custom.define_singleton_method(:to_s) { "hidden" }
      custom.define_singleton_method(:respond_to?) { |m| m == :to_s }
      cell = Buffer::Cell.new(char: "X", modifiers: [custom])
      assert_equal [:hidden], cell.modifiers
      assert_predicate cell, :hidden?
    end
  end
end
