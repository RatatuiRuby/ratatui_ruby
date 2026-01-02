# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # Represents a single cell in the terminal buffer.
  #
  # A terminal grid is made of cells. Each cell contains a character (symbol) and styling (colors, modifiers).
  # When testing, you often need to verify that a specific cell renders correctly.
  #
  # This object encapsulates that state. It provides predicate methods for modifiers, making assertions readable.
  #
  # Use it to inspect the visual state of your application in tests.
  #
  # === Examples
  #
  #   cell = RatatuiRuby.get_cell_at(0, 0)
  #   cell.char   # => "H"
  #   cell.fg     # => :red
  #   cell.bold?  # => true
  #
  class Cell
    # The character displayed in the cell.
    #
    # Named to match Ratatui's Cell::symbol() method.
    attr_reader :symbol

    # Alias for Rubyists who prefer a shorter name.
    alias char symbol

    # The foreground color of the cell (e.g., :red, :blue, "#ff0000").
    attr_reader :fg

    # The background color of the cell (e.g., :black, nil).
    attr_reader :bg

    # The list of active modifiers (e.g., ["bold", "italic"]).
    attr_reader :modifiers

    # Returns an empty cell (space character, no styles).
    #
    # === Example
    #
    #   Cell.empty # => #<RatatuiRuby::Cell char=" ">
    #
    def self.empty
      new(symbol: " ", fg: nil, bg: nil, modifiers: [])
    end

    # Returns a default cell (alias for empty).
    #
    # === Example
    #
    #   Cell.default # => #<RatatuiRuby::Cell char=" ">
    #
    def self.default
      empty
    end

    # Returns a cell with a specific character and no styles.
    #
    # [symbol] String (single character).
    #
    # === Example
    #
    #   Cell.symbol("X") # => #<RatatuiRuby::Cell symbol="X">
    #
    def self.symbol(symbol)
      new(symbol:, fg: nil, bg: nil, modifiers: [])
    end

    # Alias for Rubyists who prefer a shorter name.
    def self.char(char)
      symbol(char)
    end

    # Creates a new Cell.
    #
    # [symbol] String (single character). Aliased as <tt>char:</tt>.
    # [fg] Symbol or String (nullable).
    # [bg] Symbol or String (nullable).
    # [modifiers] Array of Strings.
    def initialize(symbol: nil, char: nil, fg: nil, bg: nil, modifiers: [])
      @symbol = (symbol || char || " ").freeze
      @fg = fg&.freeze
      @bg = bg&.freeze
      @modifiers = modifiers.map(&:freeze).freeze
      freeze
    end

    # Returns true if the cell has the bold modifier.
    def bold?
      modifiers.include?("bold")
    end

    # Returns true if the cell has the dim modifier.
    def dim?
      modifiers.include?("dim")
    end

    # Returns true if the cell has the italic modifier.
    def italic?
      modifiers.include?("italic")
    end

    # Returns true if the cell has the underlined modifier.
    def underlined?
      modifiers.include?("underlined")
    end

    # Returns true if the cell has the slow_blink modifier.
    def slow_blink?
      modifiers.include?("slow_blink")
    end

    # Returns true if the cell has the rapid_blink modifier.
    def rapid_blink?
      modifiers.include?("rapid_blink")
    end

    # Returns true if the cell has the reversed modifier.
    def reversed?
      modifiers.include?("reversed")
    end

    # Returns true if the cell has the hidden modifier.
    def hidden?
      modifiers.include?("hidden")
    end

    # Returns true if the cell has the crossed_out modifier.
    def crossed_out?
      modifiers.include?("crossed_out")
    end

    # Checks equality with another Cell.
    def ==(other)
      other.is_a?(Cell) &&
        char == other.char &&
        fg == other.fg &&
        bg == other.bg &&
        modifiers == other.modifiers
    end

    # Returns a string representation of the cell.
    def inspect
      parts = ["symbol=#{symbol.inspect}"]
      parts << "fg=#{fg.inspect}" if fg
      parts << "bg=#{bg.inspect}" if bg
      parts << "modifiers=#{modifiers.inspect}" unless modifiers.empty?
      "#<#{self.class} #{parts.join(' ')}>"
    end

    # Returns the cell's character.
    def to_s
      symbol
    end

    # Support for pattern matching.
    # Supports both <tt>:symbol</tt> and <tt>:char</tt> keys.
    def deconstruct_keys(keys)
      { symbol:, char: symbol, fg:, bg:, modifiers: }
    end
  end
end
