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
  # [state] ViewState containing event data and styles.
  # [tui] RatatuiRuby instance.
  # [frame] RatatuiRuby::Frame being rendered.
  # [area] RatatuiRuby::Rect defining the widget's bounds.
  def call(state, tui, frame, area)
    visible_entries_count = (area.height - 2) / 2
    display_entries = state.events.visible(visible_entries_count)

    log_lines = []
    if state.events.empty?
      log_lines << tui.text_line(spans: [tui.text_span(content: "No events yet...", style: state.dimmed_style)])
    else
      display_entries.each do |entry|
        entry_style = tui.style(fg: entry.color)

        # Split description into lines if it's too long, or just let it wrap conceptually (though paragraph wraps by character by default)
        # Using simple inspect output as requested.
        description = entry.description

        # We want to display it over potentially multiple lines if needed, but the original code did manual 2-line formatting.
        # Let's try to just dump the inspect string. If it's very long, it might be cut off.
        # But the User asked specifically to use inspect.

        log_lines << tui.text_line(spans: [tui.text_span(content: description, style: entry_style)])
        log_lines << tui.text_line(spans: [tui.text_span(content: "", style: entry_style)]) # Spacer line to match previous 2-line rhythm? Or just compact?
        # Previous view had 2 lines per entry. Let's keep a spacer to make it readable.
      end
    end

    widget = tui.paragraph(
      text: log_lines,
      scroll: [0, 0],
      wrap: { trim: true },
      block: tui.block(
        title: "Event Log",
        borders: [:all],
        border_style: tui.style(fg: state.border_color)
      )
    )
    frame.render_widget(widget, area)
  end
end
