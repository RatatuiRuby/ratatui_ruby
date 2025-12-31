# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "color"

# Manages text input and color parsing with error feedback.
#
# Users type color values. They make mistakes—typos, invalid formats. The app
# needs to validate their input and show helpful error messages. Manually
# tracking input state, validation, and error messages across renders is
# cumbersome and error-prone.
#
# This object holds the current input string. It validates by parsing. It stores
# errors and clears them when appropriate. It provides methods to manipulate
# the input (append, delete).
#
# Use it to build text input forms where validation feedback matters.
#
# === Example
#
#   input = Input.new
#   input.append_char("#")
#   input.append_char("f")
#   input.append_char("f")
#   color = input.parse  # => Color or nil
#   puts input.error     # => error message if parse failed
class Input
  PRINTABLE_PATTERN = /[\w#,().\s%]/

  # Creates a new Input with an optional initial value.
  #
  # [initial_value] String initial color input (default: <tt>"#F96302"</tt>)
  def initialize(initial_value = "#F96302")
    @value = initial_value
    @error = ""
  end

  # Current input string.
  #
  # === Example
  #
  #   input = Input.new
  #   input.value  # => "#F96302"
  def value
    @value
  end

  # Error message from the last failed parse, or empty string.
  #
  # === Example
  #
  #   input.parse  # => nil (invalid)
  #   input.error  # => "Invalid color format. Try: #ff0000, rgb(255,0,0), red"
  def error
    @error
  end

  # Clears the current error message.
  def clear_error
    @error = ""
  end

  # Appends a character to the input if it matches the printable pattern.
  #
  # Silently ignores non-printable characters. Valid characters include
  # letters, digits, hash, comma, parentheses, dot, space, and percent.
  #
  # [char] String single character
  def append_char(char)
    @value += char if char.length == 1 && char.match?(PRINTABLE_PATTERN)
  end

  # Removes the last character from the input.
  def delete_char
    @value = @value[0...-1]
  end

  # Replaces the entire input string.
  #
  # [text] String new input value
  def set(text)
    @value = text
  end

  # Parses the current input as a Color.
  #
  # Returns a Color if valid; nil otherwise. Sets the error message on failure.
  # Clears the error message on success.
  #
  # === Example
  #
  #   input = Input.new("#FF0000")
  #   color = input.parse  # => Color
  #   input.error          # => ""
  def parse
    color = Color.parse(@value)
    if color
      clear_error
      color
    else
      @error = "Invalid color format. Try: #ff0000, rgb(255,0,0), red"
      nil
    end
  end

  # Renders the input widget for display in a TUI frame.
  #
  # Shows the current input value with a cursor. Displays the error message
  # in red if one is set.
  #
  # [tui] Session or TUI factory object
  #
  # === Example
  #
  #   input = Input.new
  #   widget = input.render(tui)
  #   frame.render_widget(widget, area)
  def render(tui)
    input_lines = [
      tui.text_line(spans: [
        tui.text_span(content: @value),
        tui.text_span(content: "_", style: tui.style(modifiers: [:reversed])),
      ]),
    ]

    unless @error.empty?
      input_lines << tui.text_line(spans: [
        tui.text_span(content: @error, style: tui.style(fg: :red)),
      ])
    end

    tui.block(
      title: "Color Input",
      borders: [:all],
      children: [
        tui.paragraph(text: input_lines),
      ]
    )
  end
end
