# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "../view"

# Renders a real-time summary of the most recent events.
#
# Users need to see the immediate result of their actions without digging through a log.
# Identifying the specific details of the last key press or mouse move at a glance is difficult.
#
# This component displays a table showing the latest event of each type with its timestamp and description.
#
# Use it to provide instant feedback for user interactions.
#
# === Examples
#
#   live_view = View::Live.new
#   live_view.call(model, tui, frame, area)
class View::Live
  # Renders the live event table to the given area.
  #
  # [model] AppModel containing event data.
  # [tui] RatatuiRuby instance.
  # [frame] RatatuiRuby::Frame being rendered.
  # [area] RatatuiRuby::Layout::Rect defining the widget's bounds.
  #
  # === Example
  #
  #   live_view.call(model, tui, frame, area)
  def call(model, tui, frame, area)
    border_color = model.focused ? :green : :gray
    rows = []

    rows << tui.text_line(spans: [
      tui.text_span(content: "Type".ljust(9), style: tui.style(fg: :gray, modifiers: [:bold])),
      tui.text_span(content: "Time".ljust(10), style: tui.style(fg: :gray, modifiers: [:bold])),
      tui.text_span(content: "Description", style: tui.style(fg: :gray, modifiers: [:bold])),
    ])

    (AppAllEvents::EVENT_TYPES - [:none]).each do |type|
      event_data = model.live_event(type)

      class_str = type.to_s.capitalize
      time_str = event_data ? event_data[:time].strftime("%H:%M:%S") : "—"
      desc_str = event_data ? event_data[:description] : "—"

      is_lit = model.lit?(type)
      row_style = is_lit ? tui.style(fg: :black, bg: :green) : nil

      rows << tui.text_line(spans: [
        tui.text_span(content: class_str.ljust(9), style: row_style || tui.style(fg: :cyan)),
        tui.text_span(content: time_str.ljust(10), style: row_style || tui.style(fg: :white)),
        tui.text_span(content: desc_str, style: row_style),
      ])
    end

    widget = tui.paragraph(
      text: rows,
      scroll: [0, 0],
      block: tui.block(
        title: "Live Display",
        borders: [:all],
        border_style: tui.style(fg: border_color)
      )
    )
    frame.render_widget(widget, area)
  end
end
