#!/usr/bin/env ruby
# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "bundler/setup"
require "ratatui_ruby"

# Sample process data
PROCESSES = [
  { pid: 1234, name: "ruby", cpu: 15.2 },
  { pid: 5678, name: "postgres", cpu: 8.7 },
  { pid: 9012, name: "nginx", cpu: 3.1 },
  { pid: 3456, name: "redis", cpu: 12.4 },
  { pid: 7890, name: "sidekiq", cpu: 22.8 },
  { pid: 2345, name: "webpack", cpu: 45.3 },
  { pid: 6789, name: "node", cpu: 18.9 }
].freeze

selected_index = 0

RatatuiRuby.init_terminal

begin
  loop do
    # Create table rows from process data
    rows = PROCESSES.map { |p| [p[:pid].to_s, p[:name], "#{p[:cpu]}%"] }

    # Define column widths
    widths = [
      RatatuiRuby::Constraint.length(8),
      RatatuiRuby::Constraint.length(15),
      RatatuiRuby::Constraint.length(10)
    ]

    # Create highlight style (yellow text)
    highlight_style = RatatuiRuby::Style.new(fg: :yellow)

    # Create table with selection
    table = RatatuiRuby::Table.new(
      header: ["PID", "Name", "CPU"],
      rows: rows,
      widths: widths,
      selected_row: selected_index,
      highlight_style: highlight_style,
      highlight_symbol: "> ",
      block: RatatuiRuby::Block.new(title: "Process Monitor (↑/↓ to select, q to quit)", borders: :all),
      footer: ["Total: #{PROCESSES.length}", "Total CPU: #{PROCESSES.sum { |p| p[:cpu] }}%", ""]
    )

    # Draw the table
    RatatuiRuby.draw(table)

    # Handle events
    event = RatatuiRuby.poll_event
    next unless event

    case event
    in {type: :key, code: "q"} | {type: :key, code: "c", modifiers: ["ctrl"]}
      break
    in type: :key, code: "down" | "j"
      selected_index = (selected_index + 1) % PROCESSES.length
    in type: :key, code: "up" | "k"
      selected_index = (selected_index - 1) % PROCESSES.length
    else
      nil
    end
  end
ensure
  RatatuiRuby.restore_terminal
end
