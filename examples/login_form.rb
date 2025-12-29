# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"

class LoginFormApp
  PREFIX = "Enter Username: [ "
  SUFFIX = " ]"

  def initialize
    @username = ""
    @show_popup = false
  end

  def run
    RatatuiRuby.init_terminal
    begin
      loop do
        render
        break if handle_input == :quit
      end
    ensure
      RatatuiRuby.restore_terminal
    end
  end

  def render
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
    form_content = RatatuiRuby::Overlay.new(layers: [
      RatatuiRuby::Paragraph.new(
        text: "#{PREFIX}#{@username}#{SUFFIX}",
        block: RatatuiRuby::Block.new(borders: :all, title: "Login Form"),
        align: :left
      ),
      RatatuiRuby::Cursor.new(x: cursor_x, y: cursor_y),
    ])

    # Center the form on screen
    base_layer = RatatuiRuby::Center.new(
      child: form_content,
      width_percent: 50,
      height_percent: 20
    )

    # 2. Popup Layer Construction
    final_view = if @show_popup
      popup_message = RatatuiRuby::Center.new(
        child: RatatuiRuby::Paragraph.new(
          text: "Login Successful!\nPress 'q' to quit.",
          style: RatatuiRuby::Style.new(fg: :green, bg: :black),
          block: RatatuiRuby::Block.new(borders: :all),
          align: :center,
          wrap: true
        ),
        width_percent: 30,
        height_percent: 20
      )

      # Render Base Layer (background) THEN Popup Layer
      RatatuiRuby::Overlay.new(layers: [base_layer, popup_message])
    else
      base_layer
    end

    # 3. Draw
    RatatuiRuby.draw(final_view)
  end

  def handle_input
    # 4. Event Handling
    event = RatatuiRuby.poll_event
    return unless event

    if event.key?
      if @show_popup
        return :quit if event == "q" || event == :ctrl_c
      else
        # Login Form Input
        case event.code
        when "enter"
          @show_popup = true
        when "backspace"
          @username.chop!
        when "esc"
          :quit
        else
          # Simple text input
          if event.text? && !event.ctrl? && !event.alt?
            @username += event.code
          end
        end
      end
    end
  end
end

LoginFormApp.new.run if __FILE__ == $0
