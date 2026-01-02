# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "color"

# A self-contained text input component for color entry.
#
# Users type color values. They make mistakes—typos, invalid formats. The app
# needs to validate their input and show helpful error messages.
#
# This component encapsulates rendering, state, and event handling. It draws
# itself into the provided area, caches that area for hit testing, and handles
# keyboard events internally.
#
# === Component Contract
#
# - `render(tui, frame, area)`: Draws the input field; stores `area` for hit testing
# - `handle_event(event) -> Symbol | nil`: Returns `:consumed`, `:submitted`, or `nil`
#
# === Example
#
#   input = Input.new
#   input.render(tui, frame, area)
#
#   result = input.handle_event(event)
#   case result
#   when :submitted
#     palette.update_color(input.parsed_color)
#   end
class Input
  PRINTABLE_PATTERN = /[\w#,().\s%]/

  # Creates a new Input with an optional initial value.
  #
  # [initial_value] String initial color input (default: <tt>"#F96302"</tt>)
  def initialize(initial_value = "#F96302")
    @value = initial_value
    @error = ""
    @parsed_color = nil
    @area = nil
  end

  # Current input string.
  attr_reader :value

  # Error message from the last failed parse, or empty string.
  attr_reader :error

  # The last successfully parsed Color, or nil.
  attr_reader :parsed_color

  # The cached render area, for hit testing.
  attr_reader :area

  # Clears the current error message.
  def clear_error
    @error = ""
  end

  # Renders the input widget into the given area.
  #
  # Caches `area` for hit testing. Shows the current input value and positions
  # the terminal's blinking cursor at the end of the text using
  # `frame.set_cursor_position`. Displays the error message in red if set.
  #
  # [tui] Session or TUI factory object
  # [frame] Frame object from RatatuiRuby.draw block
  # [area] Rect area to draw into
  #
  # === Example
  #
  #   input.render(tui, frame, input_area)
  def render(tui, frame, area)
    @area = area
    widget = build_widget(tui)
    frame.render_widget(widget, area)

    # Position real blinking cursor at end of input text
    cursor_x, cursor_y = cursor_position_in(area)
    frame.set_cursor_position(cursor_x, cursor_y)
  end

  # Processes a keyboard event and updates internal state.
  #
  # Returns:
  # - `:submitted` when Enter is pressed (caller should read `parsed_color`)
  # - `:consumed` when the event was handled (typing, backspace)
  # - `nil` when the event was ignored
  #
  # [event] Event from RatatuiRuby.poll_event
  #
  # === Example
  #
  #   result = input.handle_event(event)
  #   if result == :submitted
  #     palette.update_color(input.parsed_color)
  #   end
  def handle_event(event)
    case event
    in { type: :key, code: "enter" }
      parse
      :submitted
    in { type: :key, code: "backspace" }
      delete_char
      :consumed
    in { type: :paste, content: }
      set(content)
      parse
      :submitted
    in { type: :key, code: code }
      append_char(code)
      :consumed
    else
      nil
    end
  end

  private def append_char(char)
    @value += char if char.length == 1 && char.match?(PRINTABLE_PATTERN)
  end

  private def delete_char
    @value = @value[0...-1]
  end

  private def set(text)
    @value = text
  end

  private def parse
    color = Color.parse(@value)
    if color
      clear_error
      @parsed_color = color
    else
      @error = "Invalid color format. Try: #ff0000, rgb(255,0,0), red"
      @parsed_color = nil
    end
  end

  private def build_widget(tui)
    input_lines = [
      tui.text_line(spans: [
        tui.text_span(content: @value),
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

  # Calculates cursor position within the input area.
  #
  # Accounts for block border (1 cell) and current text length.
  private def cursor_position_in(area)
    # Border takes 1 cell on left, cursor goes after last character
    x = area.x + 1 + @value.length
    y = area.y + 1 # First line inside border
    [x, y]
  end
end
