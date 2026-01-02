# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

# A display-only component showing keyboard shortcuts and clipboard feedback.
#
# Users need to know what keys are available. They also need feedback when
# they copy a color. This component renders the controls section.
#
# === Component Contract
#
# - `render(tui, frame, area, clipboard:)`: Draws the controls; stores `area`
# - `handle_event(event) -> nil`: Display-only, always returns nil
# - `tick`: Delegates to clipboard for time-based feedback updates
#
# === Example
#
#   controls = Controls.new
#   controls.render(tui, frame, area, clipboard: clipboard)
#   controls.tick(clipboard)
class Controls
  def initialize
    @area = nil
    @hotkey_style = nil
  end

  # The cached render area.
  attr_reader :area

  # Renders the controls section into the given area.
  #
  # Shows keyboard shortcuts and clipboard feedback message if one is active.
  #
  # [tui] Session or TUI factory object
  # [frame] Frame object from RatatuiRuby.draw block
  # [area] Rect area to draw into
  # [clipboard] Clipboard object for feedback message
  #
  # === Example
  #
  #   controls.render(tui, frame, control_area, clipboard: clipboard)
  def render(tui, frame, area, clipboard:)
    @area = area
    @hotkey_style ||= tui.style(modifiers: [:bold, :underlined])
    widget = build_widget(tui, clipboard)
    frame.render_widget(widget, area)
  end

  # Display-only component; always returns nil.
  def handle_event(_event)
    nil
  end

  # Delegates tick to the clipboard for time-based updates.
  #
  # [clipboard] Clipboard object to tick
  def tick(clipboard)
    clipboard.tick
  end

  private def build_widget(tui, clipboard)
    control_lines = [
      tui.text_line(spans: [
        tui.text_span(content: "a-z/0-9", style: @hotkey_style),
        tui.text_span(content: ": Type  "),
        tui.text_span(content: "enter", style: @hotkey_style),
        tui.text_span(content: ": Parse  "),
        tui.text_span(content: "bksp", style: @hotkey_style),
        tui.text_span(content: ": Erase  "),
        tui.text_span(content: "esc", style: @hotkey_style),
        tui.text_span(content: ": Quit"),
      ]),
    ]

    unless clipboard.message.empty?
      control_lines << tui.text_line(spans: [
        tui.text_span(content: clipboard.message, style: tui.style(fg: :green, modifiers: [:bold])),
      ])
    end

    tui.block(
      title: "Controls",
      borders: [:all],
      children: [
        tui.paragraph(text: control_lines),
      ]
    )
  end
end
