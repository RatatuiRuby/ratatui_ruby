# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "../view"

# Renders a detailed, scrollable history of application events.
#
# Debugging complex event flows requires a chronological record of raw data.
# Interpreting raw event objects without formatting is difficult and slow.
#
# This component renders event history as a series of formatted, color-coded entries showing raw data.
#
# Use it to provide a detailed audit trail of all terminal interactions.
class View::Log
  # Renders the event log widget to the given area.
  #
  # [model] AppModel containing event data.
  # [tui] RatatuiRuby instance.
  # [frame] RatatuiRuby::Frame being rendered.
  # [area] RatatuiRuby::Layout::Rect defining the widget's bounds.
  def call(model, tui, frame, area)
    dimmed_style = tui.style(fg: :dark_gray)
    border_color = model.focused ? :green : :gray

    visible_entries_count = (area.height - 2) / 2
    display_entries = model.visible(visible_entries_count)

    log_lines = []
    if model.empty?
      log_lines << tui.text_line(spans: [tui.text_span(content: "No events yet...", style: dimmed_style)])
    else
      display_entries.each do |entry|
        entry_style = tui.style(fg: entry.color)
        description = entry.description

        log_lines << tui.text_line(spans: [tui.text_span(content: description, style: entry_style)])
        log_lines << tui.text_line(spans: [tui.text_span(content: "", style: entry_style)])
      end
    end

    widget = tui.paragraph(
      text: log_lines,
      scroll: [0, 0],
      wrap: { trim: true },
      block: tui.block(
        title: "Event Log",
        borders: [:all],
        border_style: tui.style(fg: border_color)
      )
    )
    frame.render_widget(widget, area)
  end
end
