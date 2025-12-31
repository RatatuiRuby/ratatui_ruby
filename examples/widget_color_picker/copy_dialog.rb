# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "clipboard"

# A confirmation dialog for copying text to the clipboard.
#
# Users click on content they want to copy. The app needs to confirm: "Are you
# sure?" Managing dialog state (visible, selection, active), rendering the
# dialog, and dispatching keyboard events manually is tedious.
#
# This object owns dialog state and lifecycle. It renders itself. It responds
# to keyboard input. It delegates clipboard operations to a Clipboard.
#
# Use it to build copy-on-click interactions with user confirmation.
#
# === Example
#
#   clipboard = Clipboard.new
#   dialog = CopyDialog.new(clipboard)
#
#   # Open the dialog
#   dialog.open("#FF0000")
#   dialog.active?  # => true
#
#   # Handle input
#   result = dialog.handle_input(event)  # Routes to :copied or :cancelled
#
#   # Render
#   widget = dialog.render(tui, area)
class CopyDialog
  def initialize(clipboard)
    @clipboard = clipboard
    @text = ""
    @selected = :yes
    @active = false
  end

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
  #   dialog.text     # => "#FF0000"
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
  #
  # === Example
  #
  #   dialog.open("text")
  #   dialog.active?  # => true
  #   dialog.close
  #   dialog.active?  # => false
  def active?
    @active
  end

  # Processes a keyboard event and updates selection or closes the dialog.
  #
  # Left/h moves selection to :yes. Right/l moves to :no. Enter confirms.
  # Y/N hotkeys also work (Y copies immediately, N cancels). Returns nil for
  # all handled events; does nothing if the dialog is inactive.
  #
  # [event] Hash event from RatatuiRuby.poll_event
  #
  # === Example
  #
  #   dialog.open("text")
  #   dialog.handle_input({ type: :key, code: "left" })
  #   dialog.handle_input({ type: :key, code: "enter" })
  #   dialog.active?  # => false
  def handle_input(event)
    return nil unless @active

    case event
    in { type: :key, code: "left" } | { type: :key, code: "h" }
      @selected = :yes
      nil
    in { type: :key, code: "right" } | { type: :key, code: "l" }
      @selected = :no
      nil
    in { type: :key, code: "enter" }
      if @selected == :yes
        @clipboard.copy(@text)
      end
      @active = false
      nil
    in { type: :key, code: "y" }
      @clipboard.copy(@text)
      @active = false
      nil
    in { type: :key, code: "n" }
      @active = false
      nil
    else
      nil
    end
  end

  # Renders the dialog widget for display in a TUI frame.
  #
  # Shows the text to copy, Yes/No buttons with current selection highlighted,
  # and keyboard instructions. Renders only when active.
  #
  # [tui] Session or TUI factory object
  # [area] Rect area for the dialog
  #
  # === Example
  #
  #   dialog.open("#FF0000")
  #   widget = dialog.render(tui, center_area)
  #   frame.render_widget(widget, center_area)
  def render(tui, area)
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
