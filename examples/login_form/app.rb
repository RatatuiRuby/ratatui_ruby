# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

class LoginFormApp
  PREFIX = "Enter Username: [ "
  SUFFIX = " ]"

  def initialize
    @username = ""
    @show_popup = false
  end

  def run
    RatatuiRuby.run do |tui|
      @tui = tui
      loop do
        render
        break if handle_input == :quit
      end
    end
  end

  private def render
    # 1. Base Layer Construction
    # We want a cursor relative to the paragraph.
    # So we wrap Paragraph and Cursor in an Overlay, and put that Overlay in a Center.

    # Calculate cursor position
    # Border takes 1 cell.
    # Cursor X = 1 (border) + PREFIX.length + username.length
    # Cursor Y = 1 (border + line 0)
    cursor_x = 1 + PREFIX.length + @username.length
    cursor_y = 1

    # The content of the base form
    form_content = @tui.overlay(layers: [
      @tui.paragraph(
        text: "#{PREFIX}#{@username}#{SUFFIX}",
        block: @tui.block(borders: :all, title: "Login Form"),
        alignment: :left
      ),
      @tui.cursor(x: cursor_x, y: cursor_y),
    ])

    # Center the form on screen
    base_layer = @tui.center(
      child: form_content,
      width_percent: 50,
      height_percent: 20
    )

    # 2. Popup Layer Construction
    final_view = if @show_popup
      popup_message = @tui.center(
        child: @tui.paragraph(
          text: "Login Successful!\nPress 'q' to quit.",
          style: @tui.style(fg: :green, bg: :black),
          block: @tui.block(borders: :all),
          alignment: :center,
          wrap: true
        ),
        width_percent: 30,
        height_percent: 20
      )

      # Render Base Layer (background) THEN Popup Layer
      @tui.overlay(layers: [base_layer, popup_message])
    else
      base_layer
    end

    # 3. Draw
    @tui.draw do |frame|
      frame.render_widget(final_view, frame.area)
    end
  end

  private def handle_input
    case @tui.poll_event
    in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
      return :quit if @show_popup
      nil
    in { type: :key, code: "c", modifiers: ["ctrl"] }
      :quit
    in { type: :key, code: "enter" }
      @show_popup ||= true
      nil
    in { type: :key, code: "backspace" }
      @username.chop! unless @show_popup
      nil
    in { type: :key, code: "esc" }
      :quit unless @show_popup
    in { type: :key, code:, modifiers: [] }
      # Simple text input (single character, no modifiers)
      @username += code if !@show_popup && code.length == 1
      nil
    else
      nil
    end
  end
end

LoginFormApp.new.run if __FILE__ == $0
