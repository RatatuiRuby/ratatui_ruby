# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "../view"

# Renders the keyboard controls and shortcuts panel.
#
# Users need to know how to interact with the application and exit.
# Hardcoding control descriptions into the main layout makes the code hard to read.
#
# This component renders a formatted paragraph listing available global shortcuts.
#
# Use it to display help information in a sidebar or dedicated panel.
#
# === Examples
#
#   controls = View::Controls.new
#   controls.call(model, tui, frame, area)
class View::Controls
  # Renders the controls widget to the given area.
  #
  # [model] AppModel (unused, included for consistent interface).
  # [tui] RatatuiRuby instance.
  # [frame] RatatuiRuby::Frame being rendered.
  # [area] RatatuiRuby::Layout::Rect defining the widget's bounds.
  #
  # === Example
  #
  #   controls.call(model, tui, frame, area)
  def call(_model, tui, frame, area)
    hotkey_style = tui.style(modifiers: [:bold, :underlined])

    widget = tui.paragraph(
      text: [
        tui.text_line(spans: [
          tui.text_span(content: "q", style: hotkey_style),
          tui.text_span(content: ": Quit  "),
          tui.text_span(content: "Ctrl+C", style: hotkey_style),
          tui.text_span(content: ": Quit"),
        ]),
      ],
      block: tui.block(
        title: "Controls",
        borders: [:all],
        border_style: tui.style(fg: :white)
      )
    )
    frame.render_widget(widget, area)
  end
end
