# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# A demo application for the Calendar widget.
class CalendarDemoApp
  def run
    RatatuiRuby.run do |tui|
      show_header = true
      show_weekdays = true
      show_surrounding = false
      show_events = true
      hotkey_style = tui.style(modifiers: [:bold])

      loop do
        now = Time.now
        surrounding_style = show_surrounding ? tui.style(fg: "gray", modifiers: [:dim]) : nil

        events_map = if show_events
          {
            now => tui.style(fg: "green", modifiers: [:bold]),
            (now + (86400 * 2)) => tui.style(fg: "red", modifiers: [:underlined]),
            (now - (86400 * 5)) => tui.style(fg: "blue", bg: "white"),
          }
        else
          {}
        end

        calendar = tui.calendar(
          year: now.year,
          month: now.month,
          events: events_map,
          header_style: tui.style(fg: "yellow", modifiers: [:bold]),
          show_month_header: show_header,
          show_weekdays_header: show_weekdays,
          show_surrounding: surrounding_style,
          block: tui.block(borders: [:top, :left, :right])
        )

        controls = tui.paragraph(
          text: [
            tui.text_line(spans: [
              tui.text_span(content: " h/w/s/e", style: hotkey_style),
              tui.text_span(content: ": Toggle Header/Weekdays/Surrounding/Events  "),
              tui.text_span(content: "q", style: hotkey_style),
              tui.text_span(content: ": Quit"),
            ]),
            tui.text_line(spans: [
              tui.text_span(content: " Events: ", style: hotkey_style),
              tui.text_span(content: "Today (Green), +2d (Red), -5d (Blue) (#{show_events ? 'On' : 'Off'})"),
            ]),
          ],
          block: tui.block(title: " Controls ", borders: [:all])
        )

        tui.draw do |frame|
          calendar_area, controls_area = tui.layout_split(
            frame.area,
            direction: :vertical,
            constraints: [
              tui.constraint_min(0),
              tui.constraint_length(4),
            ]
          )
          frame.render_widget(calendar, calendar_area)
          frame.render_widget(controls, controls_area)
        end

        case tui.poll_event
        in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
          break
        in type: :key, code: "h"
          show_header = !show_header
        in type: :key, code: "w"
          show_weekdays = !show_weekdays
        in type: :key, code: "s"
          show_surrounding = !show_surrounding
        in type: :key, code: "e"
          show_events = !show_events
        else
          nil
        end

        sleep 0.05
      end
    end
  end
end

CalendarDemoApp.new.run if __FILE__ == $PROGRAM_NAME
