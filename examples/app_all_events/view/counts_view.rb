# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "../view"

# Renders the event statistics dashboard.
#
# Developers auditing input need to see real-time counts of various event types.
#
# This component displays a list of event types with their total counts.
#
# Use it to build an interactive dashboard of application activity.
class View::Counts
  # Renders the event counts widget to the given area.
  #
  # [model] AppModel containing event data.
  # [tui] RatatuiRuby instance.
  # [frame] RatatuiRuby::Frame being rendered.
  # [area] RatatuiRuby::Layout::Rect defining the widget's bounds.
  def call(model, tui, frame, area)
    dimmed_style = tui.style(fg: :dark_gray)
    lit_style = tui.style(fg: :green, modifiers: [:bold])
    border_color = model.focused ? :green : :gray

    count_lines = []

    AppAllEvents::EVENT_TYPES.each do |type|
      count = model.count(type)
      label = type.to_s.capitalize
      style = model.lit?(type) ? lit_style : nil

      count_lines << tui.text_line(spans: [
        tui.text_span(content: "#{label}: ", style:),
        tui.text_span(content: count.to_s, style: style || tui.style(fg: :yellow)),
      ])

      model.sub_counts(type).each do |sub_type, sub_count|
        sub_label = sub_type.to_s.capitalize
        count_lines << tui.text_line(spans: [
          tui.text_span(content: "  #{sub_label}: ", style: dimmed_style),
          tui.text_span(content: sub_count.to_s, style: dimmed_style),
        ])
      end
    end

    widget = tui.paragraph(
      text: count_lines,
      scroll: [0, 0],
      block: tui.block(
        title: "Event Counts",
        borders: [:all],
        border_style: tui.style(fg: border_color)
      )
    )
    frame.render_widget(widget, area)
  end
end
