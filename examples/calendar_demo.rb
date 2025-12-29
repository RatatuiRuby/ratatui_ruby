# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"

# A demo application for the Calendar widget.
module CalendarDemo
  def self.run
    RatatuiRuby.init_terminal

    loop do
      now = Time.now
      calendar = RatatuiRuby::Calendar.new(
        year: now.year,
        month: now.month,
        header_style: RatatuiRuby::Style.new(fg: "yellow", modifiers: [:bold]),
        block: RatatuiRuby::Block.new(title: " Calendar (q = quit) ", borders: [:all])
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
      break if event == "q" || event == :ctrl_c

      sleep 0.1
    end
  ensure
    RatatuiRuby.restore_terminal
  end
end

CalendarDemo.run if __FILE__ == $PROGRAM_NAME
