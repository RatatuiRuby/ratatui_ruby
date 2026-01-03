# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  module TestHelper
    ##
    # Assertions for verifying cell-level styling in terminal UIs.
    #
    # TUI styling is invisible to plain text comparisons. Colors, bold, italic,
    # and other modifiers define the visual hierarchy. Without style assertions,
    # you cannot verify that your highlight is actually highlighted.
    #
    # This mixin provides assertions to check foreground, background, and modifiers
    # at specific coordinates or across entire regions.
    #
    # Use it to verify selection highlights, error colors, or themed areas.
    #
    # === Examples
    #
    #   # Single cell
    #   assert_cell_style(0, 0, fg: :red, modifiers: [:bold])
    #
    #   # Foreground color at coordinate
    #   assert_color(:green, x: 5, y: 2)
    #
    #   # Entire header region
    #   assert_area_style({ x: 0, y: 0, w: 80, h: 1 }, bg: :blue)
    #
    module StyleAssertions
      ##
      # Asserts that a cell has the expected style attributes.
      #
      # === Example
      #
      #   assert_cell_style(0, 0, char: "H", fg: :red)
      #
      # [x] Integer x-coordinate.
      # [y] Integer y-coordinate.
      # [expected_attributes] Hash of attribute names to expected values.
      def assert_cell_style(x, y, **expected_attributes)
        cell = get_cell(x, y)
        expected_attributes.each do |key, value|
          actual_value = cell.public_send(key)
          if value.nil?
            assert_nil actual_value, "Expected cell at (#{x}, #{y}) to have #{key}=nil, but got #{actual_value.inspect}"
          else
            assert_equal value, actual_value, "Expected cell at (#{x}, #{y}) to have #{key}=#{value.inspect}, but got #{actual_value.inspect}"
          end
        end
      end

      ##
      # Asserts foreground or background color at a coordinate.
      #
      # Accepts symbols (<tt>:red</tt>), indexed colors (integers), or hex strings.
      #
      # === Examples
      #
      #   assert_color(:red, x: 10, y: 5)
      #   assert_color(5, x: 10, y: 5, layer: :bg)
      #   assert_color("#ff00ff", x: 10, y: 5)
      #
      # [expected] Symbol, Integer, or String (hex).
      # [x] Integer x-coordinate.
      # [y] Integer y-coordinate.
      # [layer] <tt>:fg</tt> (default) or <tt>:bg</tt>.
      def assert_color(expected, x:, y:, layer: :fg)
        cell = get_cell(x, y)
        actual = cell.public_send(layer)

        # Normalize expected integer to symbol if needed (RatatuiRuby returns :indexed_N)
        expected_normalized = if expected.is_a?(Integer)
          :"indexed_#{expected}"
        else
          expected
        end

        assert_equal expected_normalized, actual,
          "Expected #{layer} at (#{x}, #{y}) to be #{expected.inspect}, but got #{actual.inspect}"
      end

      ##
      # Asserts that all cells in an area have the expected style.
      #
      # === Examples
      #
      #   header = RatatuiRuby::Layout::Rect.new(x: 0, y: 0, width: 80, height: 1)
      #   assert_area_style(header, bg: :blue, modifiers: [:bold])
      #
      #   assert_area_style({ x: 0, y: 0, w: 10, h: 1 }, fg: :red)
      #
      # [area] Rect-like object or Hash with x, y, width/w, height/h.
      # [attributes] Style attributes to verify.
      def assert_area_style(area, **attributes)
        if area.is_a?(Hash)
          x = area[:x] || 0
          y = area[:y] || 0
          w = area[:width] || area[:w] || 0
          h = area[:height] || area[:h] || 0
        else
          x = area.x
          y = area.y
          w = area.width
          h = area.height
        end

        (y...(y + h)).each do |row|
          (x...(x + w)).each do |col|
            assert_cell_style(col, row, **attributes)
          end
        end
      end

      ##
      # Asserts the foreground color at a coordinate.
      #
      # Convenience alias for <tt>assert_color(expected, x:, y:, layer: :fg)</tt>.
      #
      # === Example
      #
      #   assert_fg_color(:yellow, 0, 2)
      #
      # [expected] Symbol, Integer, or String (hex).
      # [x] Integer x-coordinate.
      # [y] Integer y-coordinate.
      def assert_fg_color(expected, x, y)
        assert_color(expected, x:, y:, layer: :fg)
      end
      alias assert_fg assert_fg_color

      ##
      # Asserts the background color at a coordinate.
      #
      # Convenience alias for <tt>assert_color(expected, x:, y:, layer: :bg)</tt>.
      #
      # === Example
      #
      #   assert_bg_color(:blue, 0, 2)
      #
      # [expected] Symbol, Integer, or String (hex).
      # [x] Integer x-coordinate.
      # [y] Integer y-coordinate.
      def assert_bg_color(expected, x, y)
        assert_color(expected, x:, y:, layer: :bg)
      end
      alias assert_bg assert_bg_color

      ##
      # Asserts that a cell has the bold modifier.
      #
      # === Example
      #
      #   assert_bold(0, 2)
      #
      # [x] Integer x-coordinate.
      # [y] Integer y-coordinate.
      def assert_bold(x, y)
        cell = get_cell(x, y)
        modifiers = (cell.modifiers || []).map(&:to_sym)
        assert modifiers.include?(:bold),
          "Expected cell at (#{x}, #{y}) to be bold, but modifiers were #{modifiers.inspect}"
      end

      ##
      # Asserts that a cell has the italic modifier.
      #
      # === Example
      #
      #   assert_italic(0, 2)
      #
      # [x] Integer x-coordinate.
      # [y] Integer y-coordinate.
      def assert_italic(x, y)
        cell = get_cell(x, y)
        modifiers = (cell.modifiers || []).map(&:to_sym)
        assert modifiers.include?(:italic),
          "Expected cell at (#{x}, #{y}) to be italic, but modifiers were #{modifiers.inspect}"
      end

      ##
      # Asserts that a cell has the underlined modifier.
      #
      # === Example
      #
      #   assert_underlined(0, 2)
      #
      # [x] Integer x-coordinate.
      # [y] Integer y-coordinate.
      def assert_underlined(x, y)
        cell = get_cell(x, y)
        modifiers = (cell.modifiers || []).map(&:to_sym)
        assert modifiers.include?(:underlined),
          "Expected cell at (#{x}, #{y}) to be underlined, but modifiers were #{modifiers.inspect}"
      end
      alias assert_underline assert_underlined

      ##
      # Asserts that a cell has the dim modifier.
      #
      # === Example
      #
      #   assert_dim(0, 2)
      #
      # [x] Integer x-coordinate.
      # [y] Integer y-coordinate.
      def assert_dim(x, y)
        cell = get_cell(x, y)
        modifiers = (cell.modifiers || []).map(&:to_sym)
        assert modifiers.include?(:dim),
          "Expected cell at (#{x}, #{y}) to be dim, but modifiers were #{modifiers.inspect}"
      end

      ##
      # Asserts that a cell has the reversed (inverse video) modifier.
      #
      # === Example
      #
      #   assert_reversed(0, 2)
      #
      # [x] Integer x-coordinate.
      # [y] Integer y-coordinate.
      def assert_reversed(x, y)
        cell = get_cell(x, y)
        modifiers = (cell.modifiers || []).map(&:to_sym)
        assert modifiers.include?(:reversed),
          "Expected cell at (#{x}, #{y}) to be reversed, but modifiers were #{modifiers.inspect}"
      end
      alias assert_inverse assert_reversed
      alias assert_inverse_video assert_reversed

      ##
      # Asserts that a cell has the crossed_out (strikethrough) modifier.
      #
      # === Example
      #
      #   assert_crossed_out(0, 2)
      #
      # [x] Integer x-coordinate.
      # [y] Integer y-coordinate.
      def assert_crossed_out(x, y)
        cell = get_cell(x, y)
        modifiers = (cell.modifiers || []).map(&:to_sym)
        assert modifiers.include?(:crossed_out),
          "Expected cell at (#{x}, #{y}) to be crossed_out, but modifiers were #{modifiers.inspect}"
      end
      alias assert_strikethrough assert_crossed_out
      alias assert_strike assert_crossed_out

      ##
      # Asserts that a cell has the hidden modifier.
      #
      # [x] Integer x-coordinate.
      # [y] Integer y-coordinate.
      def assert_hidden(x, y)
        cell = get_cell(x, y)
        modifiers = (cell.modifiers || []).map(&:to_sym)
        assert modifiers.include?(:hidden),
          "Expected cell at (#{x}, #{y}) to be hidden, but modifiers were #{modifiers.inspect}"
      end

      ##
      # Asserts that a cell has the slow_blink modifier.
      #
      # [x] Integer x-coordinate.
      # [y] Integer y-coordinate.
      def assert_slow_blink(x, y)
        cell = get_cell(x, y)
        modifiers = (cell.modifiers || []).map(&:to_sym)
        assert modifiers.include?(:slow_blink),
          "Expected cell at (#{x}, #{y}) to have slow_blink, but modifiers were #{modifiers.inspect}"
      end
      alias assert_blink assert_slow_blink

      ##
      # Asserts that a cell has the rapid_blink modifier.
      #
      # [x] Integer x-coordinate.
      # [y] Integer y-coordinate.
      def assert_rapid_blink(x, y)
        cell = get_cell(x, y)
        modifiers = (cell.modifiers || []).map(&:to_sym)
        assert modifiers.include?(:rapid_blink),
          "Expected cell at (#{x}, #{y}) to have rapid_blink, but modifiers were #{modifiers.inspect}"
      end
      # Color-specific assertion helpers.
      #
      # Manually specifying <tt>:red</tt> or <tt>:blue</tt> in every <tt>assert_color</tt> call is repetitive.
      # It hides the intent of the test behind boilerplate arguments.
      #
      # These meta-programmed helpers provide a punchy, intent-focused API. Use them to
      # verify colors with minimal ceremony.
      #
      # === Standard Foreground Color Aliases
      #
      # - <tt>assert_black(x, y)</tt>
      # - <tt>assert_red(x, y)</tt>
      # - <tt>assert_green(x, y)</tt>
      # - <tt>assert_yellow(x, y)</tt>
      # - <tt>assert_blue(x, y)</tt>
      # - <tt>assert_magenta(x, y)</tt>
      # - <tt>assert_cyan(x, y)</tt>
      # - <tt>assert_gray(x, y)</tt>
      # - <tt>assert_dark_gray(x, y)</tt>
      # - <tt>assert_light_red(x, y)</tt>
      # - <tt>assert_light_green(x, y)</tt>
      # - <tt>assert_light_yellow(x, y)</tt>
      # - <tt>assert_light_blue(x, y)</tt>
      # - <tt>assert_light_magenta(x, y)</tt>
      # - <tt>assert_light_cyan(x, y)</tt>
      # - <tt>assert_white(x, y)</tt>
      #
      # === Standard Background Color Aliases
      #
      # - <tt>assert_bg_black(x, y)</tt>
      # - <tt>assert_bg_red(x, y)</tt>
      # - ...and so on for all standard colors.
      [
        :black,
        :red,
        :green,
        :yellow,
        :blue,
        :magenta,
        :cyan,
        :gray,
        :dark_gray,
        :light_red,
        :light_green,
        :light_yellow,
        :light_blue,
        :light_magenta,
        :light_cyan,
        :white,
      ].each do |color|
        # :method: assert_#{color}
        # Asserts the foreground color at (x, y) is <tt>:#{color}</tt>.
        define_method(:"assert_#{color}") do |x, y|
          assert_fg_color(color, x, y)
        end

        # :method: assert_bg_#{color}
        # Asserts the background color at (x, y) is <tt>:#{color}</tt>.
        define_method(:"assert_bg_#{color}") do |x, y|
          assert_bg_color(color, x, y)
        end
      end
    end
  end
end
