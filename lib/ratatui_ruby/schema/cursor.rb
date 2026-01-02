# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # Controls the terminal cursor position.
  #
  # Interfaces are not just output; they require input. Users need a visual cue—a blinking block or line—to know where their keystrokes will appear.
  #
  # This widget renders a ghost. It does not draw a character but instructs the terminal to place the hardware cursor at specific coordinates.
  #
  # Use it for text editors, input fields, or command prompts.
  #
  # === Examples
  #
  #   Cursor.new(x: 10, y: 5)
  #
  # See also:
  # - {Declarative implementation using Tree API}[link:/examples/app_login_form/app_rb.html]
  # - {Component-based implementation using Frame API}[link:/examples/app_color_picker/app_rb.html]
  # - RatatuiRuby::Frame#set_cursor_position (Frame API alternative)
  class Cursor < Data.define(:x, :y)
    ##
    # :attr_reader: x
    # X coordinate (column).

    ##
    # :attr_reader: y
    # Y coordinate (row).

    # Creates a new Cursor.
    #
    # [x] Integer.
    # [y] Integer.
    def initialize(x:, y:)
      super(x: Integer(x), y: Integer(y))
    end
  end
end
