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

class TableApp
  attr_reader :selected_index, :current_style_index, :column_spacing

  STYLES = [
    { name: "Cyan", style: RatatuiRuby::Style.new(fg: :cyan) },
    { name: "Red", style: RatatuiRuby::Style.new(fg: :red) },
    { name: "Green", style: RatatuiRuby::Style.new(fg: :green) },
    { name: "Blue on White", style: RatatuiRuby::Style.new(fg: :blue, bg: :white) },
    { name: "Magenta", style: RatatuiRuby::Style.new(fg: :magenta, modifiers: [:bold]) }
  ].freeze

  def initialize
    @selected_index = 0
    @current_style_index = 0
    @column_spacing = 1
  end

  def run
    RatatuiRuby.run do
      loop do
        render
        break if handle_input == :quit
      end
    end
  end

  def render
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

    current_style_entry = STYLES[@current_style_index]

    # Create table with selection and base style
    table = RatatuiRuby::Table.new(
      header: ["PID", "Name", "CPU"],
      rows: rows,
      widths: widths,
      selected_row: @selected_index,
      highlight_style: highlight_style,
      highlight_symbol: "> ",
      style: current_style_entry[:style],
      column_spacing: @column_spacing,
      block: RatatuiRuby::Block.new(
        title: "Process Monitor (↑/↓ select, 's' style: #{current_style_entry[:name]}, +/- spacing: #{@column_spacing}, q quit)",
        borders: :all
      ),
      footer: ["Total: #{PROCESSES.length}", "Total CPU: #{PROCESSES.sum { |p| p[:cpu] }}%", ""]
    )

    # Draw the table
    RatatuiRuby.draw(table)
  end

  def handle_input
    event = RatatuiRuby.poll_event
    return unless event

    case event
    in {type: :key, code: "q"} | {type: :key, code: "c", modifiers: ["ctrl"]}
      :quit
    in type: :key, code: "down" | "j"
      @selected_index = (@selected_index + 1) % PROCESSES.length
    in type: :key, code: "up" | "k"
      @selected_index = (@selected_index - 1) % PROCESSES.length
    in type: :key, code: "s"
      @current_style_index = (@current_style_index + 1) % STYLES.length
    in type: :key, code: "+"
      @column_spacing += 1
    in type: :key, code: "-"
      @column_spacing = [@column_spacing - 1, 0].max
    else
      nil
    end
  end
end

if __FILE__ == $0
  TableApp.new.run
end
