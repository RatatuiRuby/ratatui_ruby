# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "clipboard"

# A self-contained modal dialog component for copying text to the clipboard.
#
# Users click on content they want to copy. The app needs to confirm: "Are you
# sure?" This component owns dialog state, renders itself, and handles keyboard
# input.
#
# === Component Contract
#
# - `render(tui, frame, area)`: Draws the dialog; stores `area`
# - `handle_event(event) -> Symbol | nil`: Returns `:consumed` when handled
# - `open(text)`: Opens the dialog with the text to copy
# - `close`: Closes the dialog
# - `active?`: True if the dialog is visible
#
# === Example
#
#   dialog = CopyDialog.new(clipboard)
#   dialog.open("#FF0000")
#
#   result = dialog.handle_event(event)
#   # result == :consumed when dialog handled the event
#
#   dialog.render(tui, frame, center_area)
class CopyDialog
  def initialize(clipboard)
    @clipboard = clipboard
    @text = ""
    @selected = :yes
    @active = false
    @area = nil
  end

  # The cached render area.
  attr_reader :area

  # Opens the dialog with text to copy.
  #
  # Initializes selection to <tt>:yes</tt> and sets active to true.
  #
  # [text] String text to show and copy
  #
  # === Example
  #
  #   dialog.open("#FF0000")
  #   dialog.active?  # => true
  def open(text)
    @text = text
    @selected = :yes
    @active = true
  end

  # Closes the dialog and deactivates it.
  def close
    @active = false
  end

  # True if the dialog is currently open and visible.
  def active?
    @active
  end

  # Renders the dialog into the given area.
  #
  # Shows the text to copy, Yes/No buttons with current selection highlighted,
  # and keyboard instructions.
  #
  # [tui] Session or TUI factory object
  # [frame] Frame object from RatatuiRuby.draw block
  # [area] Rect area to draw into
  #
  # === Example
  #
  #   dialog.render(tui, frame, center_area)
  def render(tui, frame, area)
    @area = area
    widget = build_widget(tui)
    frame.render_widget(widget, area)
  end

  # Processes a keyboard event and updates selection or closes the dialog.
  #
  # Returns:
  # - `:consumed` when the event was handled
  # - `nil` when the event was ignored or dialog is inactive
  #
  # [event] Event from RatatuiRuby.poll_event
  #
  # === Example
  #
  #   result = dialog.handle_event(event)
  def handle_event(event)
    return nil unless @active

    case event
    in { type: :key, code: "left" } | { type: :key, code: "h" }
      @selected = :yes
      :consumed
    in { type: :key, code: "right" } | { type: :key, code: "l" }
      @selected = :no
      :consumed
    in { type: :key, code: "enter" }
      if @selected == :yes
        @clipboard.copy(@text)
      end
      @active = false
      :consumed
    in { type: :key, code: "y" }
      @clipboard.copy(@text)
      @active = false
      :consumed
    in { type: :key, code: "n" }
      @active = false
      :consumed
    else
      nil
    end
  end

  private def build_widget(tui)
    yes_style = if @selected == :yes
      tui.style(bg: :cyan, fg: :black, modifiers: [:bold])
    else
      tui.style(fg: :gray)
    end

    no_style = if @selected == :no
      tui.style(bg: :cyan, fg: :black, modifiers: [:bold])
    else
      tui.style(fg: :gray)
    end

    tui.block(
      title: "Copy to Clipboard",
      borders: [:all],
      border_type: :rounded,
      style: tui.style(bg: :black, fg: :white),
      children: [
        tui.paragraph(
          text: [
            tui.text_line(spans: [
              tui.text_span(content: "Copy #{@text}?", style: tui.style(fg: :white)),
            ]),
            tui.text_line(spans: []),
            tui.text_line(spans: [
              tui.text_span(content: "[", style: tui.style(fg: :white)),
              tui.text_span(content: "Yes", style: yes_style),
              tui.text_span(content: "]  [", style: tui.style(fg: :white)),
              tui.text_span(content: "No", style: no_style),
              tui.text_span(content: "]", style: tui.style(fg: :white)),
            ]),
            tui.text_line(spans: [
              tui.text_span(content: "Use ←/→ or h/l to select, Enter to confirm", style: tui.style(fg: :gray, modifiers: [:italic])),
            ]),
          ]
        ),
      ]
    )
  end
end
