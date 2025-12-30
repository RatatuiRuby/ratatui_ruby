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

        calendar = RatatuiRuby::Calendar.new(
          year: now.year,
          month: now.month,
          header_style: RatatuiRuby::Style.new(fg: "yellow", modifiers: [:bold]),
          show_weekdays_header: show_weekdays,
          show_surrounding: surrounding_style,
          block: RatatuiRuby::Block.new(title: " Calendar (w=toggle weekdays, s=toggle surrounding, q=quit) ", borders: [:all])
        )

        # Constrain the calendar to 24x10 characters
        view = RatatuiRuby::Layout.new(
          direction: :vertical,
          constraints: [
            RatatuiRuby::Constraint.length(10),
            RatatuiRuby::Constraint.min(0),
          ],
          children: [
            RatatuiRuby::Layout.new(
              direction: :horizontal,
              constraints: [
                RatatuiRuby::Constraint.length(24),
                RatatuiRuby::Constraint.min(0),
              ],
              children: [calendar, nil],
            ),
            nil,
          ],
        )

        RatatuiRuby.draw(view)

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
