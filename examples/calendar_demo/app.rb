# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# A demo application for the Calendar widget.
class CalendarDemoApp
  def run
    RatatuiRuby.run do
      show_header = true
      show_weekdays = true
      show_surrounding = false
      show_events = true

      loop do
        now = Time.now
        surrounding_style = if show_surrounding
          RatatuiRuby::Style.new(fg: "gray", modifiers: [:dim])
        else
          nil
        end

        events_map = if show_events
          {
            now => RatatuiRuby::Style.new(fg: "green", modifiers: [:bold]),
            (now + 86400 * 2) => RatatuiRuby::Style.new(fg: "red", modifiers: [:underlined]),
            (now - 86400 * 5) => RatatuiRuby::Style.new(fg: "blue", bg: "white"),
          }
        else
          {}
        end

        calendar = RatatuiRuby::Calendar.new(
          year: now.year,
          month: now.month,
          events: events_map,
          header_style: RatatuiRuby::Style.new(fg: "yellow", modifiers: [:bold]),
          show_month_header: show_header,
          show_weekdays_header: show_weekdays,
          show_surrounding: surrounding_style,
          block: RatatuiRuby::Block.new(borders: [:top, :left, :right])
        )

        controls_text = [
          RatatuiRuby::Text::Line.new(
            spans: [
              RatatuiRuby::Text::Span.new(content: " h/w/s/e", style: RatatuiRuby::Style.new(modifiers: [:bold])),
              RatatuiRuby::Text::Span.new(content: ": Toggle Header/Weekdays/Surrounding/Events  "),
              RatatuiRuby::Text::Span.new(content: "q", style: RatatuiRuby::Style.new(modifiers: [:bold])),
              RatatuiRuby::Text::Span.new(content: ": Quit"),
            ]
          ),
          RatatuiRuby::Text::Line.new(
            spans: [
              RatatuiRuby::Text::Span.new(content: " Events: ", style: RatatuiRuby::Style.new(modifiers: [:bold])),
              RatatuiRuby::Text::Span.new(content: "Today (Green), +2d (Red), -5d (Blue) (#{show_events ? "On" : "Off"})"),
            ]
          )
        ]
        controls = RatatuiRuby::Paragraph.new(
          text: controls_text,
          block: RatatuiRuby::Block.new(title: " Controls ", borders: [:all])
        )

        RatatuiRuby.draw(
          RatatuiRuby::Layout.new(
            direction: :vertical,
            constraints: [
              RatatuiRuby::Constraint.min(0),
              RatatuiRuby::Constraint.length(4),
            ],
            children: [calendar, controls]
          )
        )

        event = RatatuiRuby.poll_event
        case event
        in {type: :key, code: "q"} | {type: :key, code: "c", modifiers: ["ctrl"]}
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
