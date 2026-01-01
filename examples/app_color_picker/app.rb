# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
$LOAD_PATH.unshift File.expand_path(__dir__)

require "ratatui_ruby"
require_relative "input"
require_relative "palette"
require_relative "clipboard"
require_relative "copy_dialog"
require_relative "scene"

# A terminal-based color picker application.
#
# Terminal users often need to select colors for themes or UI components.
# Manually typing hex codes and guessing how they will look is slow and error-prone.
#
# This application solves the problem by providing an interactive interface. It parses hex strings,
# generates palettes, and displays them visually in the terminal.
#
# Use it to experiment with color combinations and quickly find the right hex codes.
#
# === Examples
#
#   AppColorPicker.new.run
#
class AppColorPicker
  # Creates a new <tt>AppColorPicker</tt> instance with a default palette and clipboard.
  def initialize
    @input = Input.new
    @palette = Palette.new(@input.parse)
    @clipboard = Clipboard.new
    @dialog = CopyDialog.new(@clipboard)
    @scene = nil
  end

  # Starts the terminal session and enters the main event loop.
  #
  # This method initializes the terminal, renders the initial scene, and polls for
  # input until the user quits.
  #
  # === Example
  #
  #   app = AppColorPicker.new
  #   app.run
  #
  def run
    RatatuiRuby.run do |tui|
      @scene = Scene.new(tui)
      loop do
        render(tui)
        result = handle_input(tui)
        break if result == :quit
      end
    end
  end

  private def render(tui)
    @clipboard.tick
    tui.draw do |frame|
      @scene.render(frame, input: @input, palette: @palette, clipboard: @clipboard, dialog: @dialog)
    end
  end

  private def handle_input(tui)
    event = tui.poll_event
    @input.clear_error unless @dialog.active?

    if @dialog.active?
      handle_dialog_input(event)
    else
      handle_main_input(event)
    end
  end

  private def handle_dialog_input(event)
    result = @dialog.handle_input(event)
    case event
    in { type: :key, code: "q" } | { type: :key, code: "esc" } | { type: :key, code: "c", modifiers: ["ctrl"] }
      :quit
    else
      result
    end
  end

  private def handle_main_input(event)
    case event
    in { type: :key, code: "q" } | { type: :key, code: "esc" } | { type: :key, code: "c", modifiers: ["ctrl"] }
      :quit
    in { type: :key, code: "enter" }
      @palette = Palette.new(@input.parse)
    in { type: :key, code: "backspace" }
      @input.delete_char
    in { type: :paste, content: }
      @input.set(content)
      @palette = Palette.new(@input.parse)
    in { type: :key, code: code }
      @input.append_char(code)
    in { type: :mouse, kind: "down", button: "left", x:, y: }
      if @scene && @scene.export_rect&.contains?(x, y) && @palette.main
        @dialog.open(@palette.main.hex)
      end
    else
      nil
    end
  end
end

AppColorPicker.new.run if __FILE__ == $PROGRAM_NAME
