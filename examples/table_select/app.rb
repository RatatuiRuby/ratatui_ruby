#!/usr/bin/env ruby
# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
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

class TableSelectApp
  attr_reader :selected_index, :selected_col, :current_style_index, :column_spacing, :highlight_spacing, :column_highlight_style, :cell_highlight_style

  STYLES = [
    { name: "Cyan", style: RatatuiRuby::Style.new(fg: :cyan) },
    { name: "Red", style: RatatuiRuby::Style.new(fg: :red) },
    { name: "Green", style: RatatuiRuby::Style.new(fg: :green) },
    { name: "Blue on White", style: RatatuiRuby::Style.new(fg: :blue, bg: :white) },
    { name: "Magenta", style: RatatuiRuby::Style.new(fg: :magenta, modifiers: [:bold]) }
  ].freeze

  HIGHLIGHT_SPACINGS = [
    { name: "When Selected", spacing: :when_selected },
    { name: "Always", spacing: :always },
    { name: "Never", spacing: :never }
  ].freeze

  def initialize
    @selected_index = 1
    @selected_col = 1
    @current_style_index = 0
    @column_spacing = 1
    @highlight_spacing_index = 0
    @column_highlight_style = RatatuiRuby::Style.new(fg: :magenta)
    @show_column_highlight = true
    @cell_highlight_style = RatatuiRuby::Style.new(fg: :white, bg: :red, modifiers: [:bold])
    @show_cell_highlight = true
    @hotkey_style = RatatuiRuby::Style.new(modifiers: [:bold, :underlined])
  end

  def run
    RatatuiRuby.run do
      loop do
        render
        break if handle_input == :quit
      end
    end
  end

  private

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
    current_spacing_entry = HIGHLIGHT_SPACINGS[@highlight_spacing_index]
    selection_label = @selected_index.nil? ? "none" : @selected_index.to_s

    # Main table
    table = RatatuiRuby::Table.new(
      header: ["PID", "Name", "CPU"],
      rows: rows,
      widths: widths,
      selected_row: @selected_index,
      selected_column: @selected_col,
      highlight_style: highlight_style,
      highlight_symbol: "> ",
      highlight_spacing: current_spacing_entry[:spacing],
      column_highlight_style: @show_column_highlight ? @column_highlight_style : nil,
      cell_highlight_style: @show_cell_highlight ? @cell_highlight_style : nil,
      style: current_style_entry[:style],
      column_spacing: @column_spacing,
      block: RatatuiRuby::Block.new(
        title: "Processes",
        borders: :all
      ),
      footer: ["Total: #{PROCESSES.length}", "Total CPU: #{PROCESSES.sum { |p| p[:cpu] }}%", ""]
    )

    # Bottom control panel
    control_panel = RatatuiRuby::Block.new(
      title: "Controls",
      borders: [:all],
      children: [
        RatatuiRuby::Paragraph.new(
          text: [
            # Line 1: Navigation
            RatatuiRuby::Text::Line.new(spans: [
              RatatuiRuby::Text::Span.new(content: "↑/↓", style: @hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Nav Row  "),
              RatatuiRuby::Text::Span.new(content: "←/→", style: @hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Nav Col  "),
              RatatuiRuby::Text::Span.new(content: "x", style: @hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Toggle Row (#{selection_label})  "),
              RatatuiRuby::Text::Span.new(content: "q", style: @hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Quit")
            ]),
            # Line 2: Table Controls
            RatatuiRuby::Text::Line.new(spans: [
              RatatuiRuby::Text::Span.new(content: "s", style: @hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Style (#{current_style_entry[:name]})  "),
              RatatuiRuby::Text::Span.new(content: "p", style: @hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Spacing (#{current_spacing_entry[:name]})  ")
            ]),
            # Line 3: More Controls
            RatatuiRuby::Text::Line.new(spans: [
              RatatuiRuby::Text::Span.new(content: ": Col Space (#{@column_spacing})  "),
              RatatuiRuby::Text::Span.new(content: "c", style: @hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Col Highlight (#{@show_column_highlight ? 'On' : 'Off'})  "),
              RatatuiRuby::Text::Span.new(content: "z", style: @hotkey_style),
              RatatuiRuby::Text::Span.new(content: ": Cell Highlight (#{@show_cell_highlight ? 'On' : 'Off'})")
            ])
          ]
        )
      ]
    )

    # Layout
    layout = RatatuiRuby::Layout.new(
      direction: :vertical,
      constraints: [
        RatatuiRuby::Constraint.fill(1),
        RatatuiRuby::Constraint.length(5),
      ],
      children: [table, control_panel]
    )

    # Draw the table
    RatatuiRuby.draw(layout)
  end

  def handle_input
    event = RatatuiRuby.poll_event
    return unless event

    case event
    in {type: :key, code: "q"} | {type: :key, code: "c", modifiers: ["ctrl"]}
      :quit
    in type: :key, code: "down" | "j"
      @selected_index = ((@selected_index || -1) + 1) % PROCESSES.length
    in type: :key, code: "up" | "k"
      @selected_index = (@selected_index || 0) - 1
      @selected_index = PROCESSES.length - 1 if @selected_index.negative?
    in type: :key, code: "right" | "l"
      @selected_col = ((@selected_col || -1) + 1) % 3 # 3 columns
    in type: :key, code: "left" | "h"
      # 'h' is already used for highlight spacing, but let's override it or ignore vim keys for left/right?
      # Actually 'h' is used for spacing in this demo. Let's just use arrows for cols.
      # Or map 'h' to left if user meant vim keys.
      # The demo uses 'h' for "Spacing". Let's change Spacing key to 'p' (property/padding?) or something else.
      # Or just stick to arrows for columns to avoid conflict.
      @selected_col = (@selected_col || 0) - 1
      @selected_col = 2 if @selected_col.negative?
    in type: :key, code: "s"
      @current_style_index = (@current_style_index + 1) % STYLES.length
    in type: :key, code: "+"
      @column_spacing += 1
    in type: :key, code: "-"
      @column_spacing = [@column_spacing - 1, 0].max
    in type: :key, code: "p"
      @highlight_spacing_index = (@highlight_spacing_index + 1) % HIGHLIGHT_SPACINGS.length
    in type: :key, code: "x"
      @selected_index = @selected_index.nil? ? 0 : nil
    in type: :key, code: "c"
      @show_column_highlight = !@show_column_highlight
    in type: :key, code: "z"
      @show_cell_highlight = !@show_cell_highlight
    else
      nil
    end
  end
end

if __FILE__ == $0
  TableSelectApp.new.run
end
