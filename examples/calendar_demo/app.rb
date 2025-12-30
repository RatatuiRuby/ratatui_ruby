# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# A demo application for the Calendar widget.
class CalendarDemoApp
  def run
    RatatuiRuby.run do
      show_weekdays = true
      show_surrounding = false

      loop do
        now = Time.now
        surrounding_style = if show_surrounding
          RatatuiRuby::Style.new(fg: "gray", modifiers: [:dim])
        else
          nil
        end

        layout = RatatuiRuby::Layout.new(
          direction: :vertical,
          constraints: [
            RatatuiRuby::Constraint.min(0),
            RatatuiRuby::Constraint.length(1),
          ],
        )

        calendar = RatatuiRuby::Calendar.new(
          year: now.year,
          month: now.month,
          header_style: RatatuiRuby::Style.new(fg: "yellow", modifiers: [:bold]),
          show_weekdays_header: show_weekdays,
          show_surrounding: surrounding_style,
          block: RatatuiRuby::Block.new(title: " Calendar ", borders: [:all])
        )

        controls_text = RatatuiRuby::Text::Line.new(
          spans: [
            RatatuiRuby::Text::Span.new(content: "w", style: RatatuiRuby::Style.new(modifiers: [:bold, :underlined])),
            RatatuiRuby::Text::Span.new(content: ": Weekdays (#{show_weekdays})  "),
            RatatuiRuby::Text::Span.new(content: "s", style: RatatuiRuby::Style.new(modifiers: [:bold, :underlined])),
            RatatuiRuby::Text::Span.new(content: ": Surrounding (#{show_surrounding ? "Dim" : "Hidden"})  "),
            RatatuiRuby::Text::Span.new(content: "q", style: RatatuiRuby::Style.new(modifiers: [:bold, :underlined])),
            RatatuiRuby::Text::Span.new(content: ": Quit"),
          ]
        )
        controls = RatatuiRuby::Paragraph.new(text: [controls_text])

        layout = RatatuiRuby::Layout.new(
          direction: :vertical,
          constraints: [
            RatatuiRuby::Constraint.min(0),
            RatatuiRuby::Constraint.length(1),
          ],
          children: [calendar, controls]
        )

        RatatuiRuby.draw(layout)

        event = RatatuiRuby.poll_event
        case event
        in {type: :key, code: "q"} | {type: :key, code: "c", modifiers: ["ctrl"]}
          break
        in type: :key, code: "w"
          show_weekdays = !show_weekdays
        in type: :key, code: "s"
          show_surrounding = !show_surrounding
        else
          nil
        end

        sleep 0.05
      end
    end
  end
end

CalendarDemoApp.new.run if __FILE__ == $PROGRAM_NAME
