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
  { pid: 6789, name: "node", cpu: 18.9 },
].freeze

class WidgetTableDemo
  attr_reader :selected_index, :selected_col, :current_style_index, :column_spacing, :highlight_spacing, :column_highlight_style, :cell_highlight_style

  HIGHLIGHT_SPACINGS = [
    { name: "When Selected", spacing: :when_selected },
    { name: "Always", spacing: :always },
    { name: "Never", spacing: :never },
  ].freeze

  OFFSET_MODES = [
    { name: "Auto (No Offset)", offset: nil, allow_selection: true },
    { name: "Offset Only (row 3)", offset: 3, allow_selection: false },
    { name: "Selection + Offset (Conflict)", offset: 0, allow_selection: true },
  ].freeze

  FLEX_MODES = [
    { name: "Legacy (Default)", flex: :legacy },
    { name: "Start", flex: :start },
    { name: "Center", flex: :center },
    { name: "End", flex: :end },
    { name: "Space Between", flex: :space_between },
    { name: "Space Around", flex: :space_around },
    { name: "Space Evenly", flex: :space_evenly },
  ].freeze

  def initialize
    @selected_index = 1
    @selected_col = 1
    @current_style_index = 0
    @column_spacing = 1
    @highlight_spacing_index = 0
    @show_column_highlight = true
    @show_cell_highlight = true
    @offset_mode_index = 0
    @flex_mode_index = 0
  end

  def run
    RatatuiRuby.run do |tui|
      @tui = tui
      setup_styles
      loop do
        @tui.draw do |frame|
          render(frame)
        end
        break if handle_input == :quit
      end
    end
  end

  private def setup_styles
    @styles = [
      { name: "Cyan", style: @tui.style(fg: :cyan) },
      { name: "Red", style: @tui.style(fg: :red) },
      { name: "Green", style: @tui.style(fg: :green) },
      { name: "Blue on White", style: @tui.style(fg: :blue, bg: :white) },
      { name: "Magenta", style: @tui.style(fg: :magenta, modifiers: [:bold]) },
    ]
    @column_highlight_style = @tui.style(fg: :magenta)
    @cell_highlight_style = @tui.style(fg: :white, bg: :red, modifiers: [:bold])
    @hotkey_style = @tui.style(modifiers: [:bold, :underlined])
  end

  private def render(frame)
    # Create table rows from process data
    rows = PROCESSES.map { |p| [p[:pid].to_s, p[:name], "#{p[:cpu]}%"] }

    # Define column widths
    widths = [
      @tui.constraint_length(8),
      @tui.constraint_length(15),
      @tui.constraint_length(10),
    ]

    # Create highlight style (yellow text)
    highlight_style = @tui.style(fg: :yellow)

    current_style_entry = @styles[@current_style_index]
    current_spacing_entry = HIGHLIGHT_SPACINGS[@highlight_spacing_index]
    offset_mode_entry = OFFSET_MODES[@offset_mode_index]
    flex_mode_entry = FLEX_MODES[@flex_mode_index]

    # Determine selection/offset based on mode
    effective_selection = offset_mode_entry[:allow_selection] ? @selected_index : nil
    effective_offset = offset_mode_entry[:offset]
    selection_label = effective_selection.nil? ? "none" : effective_selection.to_s
    offset_label = effective_offset.nil? ? "auto" : effective_offset.to_s

    # Main table
    table = @tui.table(
      header: ["PID", "Name", "CPU"],
      rows:,
      widths:,
      selected_row: effective_selection,
      selected_column: @selected_col,
      offset: effective_offset,
      highlight_style:,
      highlight_symbol: "> ",
      highlight_spacing: current_spacing_entry[:spacing],
      column_highlight_style: @show_column_highlight ? @column_highlight_style : nil,
      cell_highlight_style: @show_cell_highlight ? @cell_highlight_style : nil,
      style: current_style_entry[:style],
      column_spacing: @column_spacing,
      flex: flex_mode_entry[:flex],
      block: @tui.block(
        title: "Processes | Sel: #{selection_label} | Offset: #{offset_label} | Flex: #{flex_mode_entry[:name]}",
        borders: :all
      ),
      footer: ["Total: #{PROCESSES.length}", "Total CPU: #{PROCESSES.sum { |p| p[:cpu] }}%", ""]
    )

    # Bottom control panel
    control_panel = @tui.block(
      title: "Controls",
      borders: [:all],
      children: [
        @tui.paragraph(
          text: [
            # Line 1: Navigation
            @tui.text_line(spans: [
              @tui.text_span(content: "↑/↓", style: @hotkey_style),
              @tui.text_span(content: ": Nav Row  "),
              @tui.text_span(content: "←/→", style: @hotkey_style),
              @tui.text_span(content: ": Nav Col  "),
              @tui.text_span(content: "x", style: @hotkey_style),
              @tui.text_span(content: ": Toggle Row (#{selection_label})  "),
              @tui.text_span(content: "q", style: @hotkey_style),
              @tui.text_span(content: ": Quit"),
            ]),
            # Line 2: Table Controls
            @tui.text_line(spans: [
              @tui.text_span(content: "s", style: @hotkey_style),
              @tui.text_span(content: ": Style (#{current_style_entry[:name]})  "),
              @tui.text_span(content: "p", style: @hotkey_style),
              @tui.text_span(content: ": Spacing (#{current_spacing_entry[:name]})  "),
            ]),
            # Line 3: More Controls
            @tui.text_line(spans: [
              @tui.text_span(content: "+/-", style: @hotkey_style),
              @tui.text_span(content: ": Col Space (#{@column_spacing})  "),
              @tui.text_span(content: "c", style: @hotkey_style),
              @tui.text_span(content: ": Col Highlight (#{@show_column_highlight ? 'On' : 'Off'})  "),
              @tui.text_span(content: "f", style: @hotkey_style),
              @tui.text_span(content: ": Flex Mode (#{flex_mode_entry[:name]})"),
            ]),
            # Line 4: Offset Mode
            @tui.text_line(spans: [
              @tui.text_span(content: "z", style: @hotkey_style),
              @tui.text_span(content: ": Cell Highlight (#{@show_cell_highlight ? 'On' : 'Off'})  "),
              @tui.text_span(content: "o", style: @hotkey_style),
              @tui.text_span(content: ": Offset Mode (#{offset_mode_entry[:name]})"),
            ]),
          ]
        ),
      ]
    )

    # Layout
    layout = @tui.layout_split(
      frame.area,
      direction: :vertical,
      constraints: [
        @tui.constraint_fill(1),
        @tui.constraint_length(6),
      ]
    )

    frame.render_widget(table, layout[0])
    frame.render_widget(control_panel, layout[1])
  end

  private def handle_input
    event = @tui.poll_event

    case event
    in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
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
      @current_style_index = (@current_style_index + 1) % @styles.length
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
    in type: :key, code: "o"
      @offset_mode_index = (@offset_mode_index + 1) % OFFSET_MODES.length
    in type: :key, code: "f"
      @flex_mode_index = (@flex_mode_index + 1) % FLEX_MODES.length
    else
      nil
    end
  end
end

if __FILE__ == $0
  WidgetTableDemo.new.run
end
