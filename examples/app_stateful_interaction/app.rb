# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "faker"

# A "Master Class" example demonstrating Stateful Widget Rendering and Interaction.
#
# This example shows how to:
# 1. Use mutable State objects (ListState, TableState) for selection and scrolling
# 2. Read back the calculated scroll offset from the backend (state.offset)
# 3. Implement precise mouse-click-to-row interaction using that offset
class AppStatefulInteraction
  def initialize
    # Data Models
    # Tables are the categories on the left
    @tables = ["Users", "Orders", "Products", "Invoices", "Audit Logs"]
    @headers = {
      "Users" => ["Name", "Email", "Role"],
      "Orders" => ["Order ID", "Status", "Amount"],
      "Products" => ["Product", "SKU", "Status"],
      "Invoices" => ["Invoice #", "Status", "Amount"],
      "Audit Logs" => ["Event", "Action", "IP Address"],
    }

    # Generate dummy data for each table
    # Use fixed seed for deterministic behavior in CI/Tests
    if ENV["CI"] == "true" || ENV["RATA_SEED"]
      seed = (ENV["RATA_SEED"] || 12345).to_i
      Faker::Config.random = Random.new(seed)
      # Also seed Kernel.rand/Array#sample just in case
      srand(seed)
    end
    rand_price = -> { "$#{Faker::Commerce.price(range: 10..500.0)}" }

    @data = {
      "Users" => Array.new(50) { [Faker::Name.name, Faker::Internet.email, %w[Admin Editor Viewer].sample] },
      "Orders" => Array.new(50) { [Faker::Commerce.promotion_code(digits: 4), ["Completed", "Pending", "Failed"].sample, rand_price.call] },
      "Products" => Array.new(50) { [Faker::Commerce.product_name, "SKU-#{Faker::Number.number(digits: 4)}", ["In Stock", "Low Stock"].sample] },
      "Invoices" => Array.new(50) { ["INV-#{Faker::Number.number(digits: 6)}", ["Paid", "Unpaid"].sample, rand_price.call] },
      "Audit Logs" => Array.new(50) { ["Log #{Faker::Number.unique.number(digits: 3)}", ["Login Success", "Login Failed", "Logout"].sample, Faker::Internet.ip_v4_address] },
    }

    # State Objects - These are mutable and persist across frames!
    @list_state = RatatuiRuby::ListState.new(nil)
    @table_state = RatatuiRuby::TableState.new(nil)

    # Initialize selection
    @list_state.select(0)
    @table_state.select(0)

    # Active Pane Focus (:list or :table)
    @active_pane = :list
  end

  def run
    RatatuiRuby.run do |tui|
      @tui = tui

      # Styles can only be created once TUI is initialized
      @style_active = @tui.style(fg: :yellow, modifiers: [:bold])
      @style_inactive = @tui.style(fg: :dark_gray)
      @style_highlight = @tui.style(bg: :blue, fg: :white, modifiers: [:bold])

      loop do
        render
        break if handle_input == :quit
      end
    end
  end

  private def render
    @tui.draw do |frame|
      # 1. Layout
      main_area, help_area = @tui.layout_split(
        frame.area,
        direction: :vertical,
        constraints: [
          @tui.constraint_fill(1),
          @tui.constraint_length(1),
        ]
      )

      list_area, table_area = @tui.layout_split(
        main_area,
        direction: :horizontal,
        constraints: [
          @tui.constraint_percentage(30),
          @tui.constraint_percentage(70),
        ]
      )

      # Save areas for hit testing
      @list_area = list_area
      @table_area = table_area

      # 2. Render List (Left Pane)
      render_list(frame, list_area)

      # 3. Render Table (Right Pane)
      render_table(frame, table_area)

      # 4. Render Help
      help_text = "q: Quit | Tab/Arrows: Nav | Mouse: Click rows (Try it!)"
      frame.render_widget(@tui.paragraph(text: help_text), help_area)
    end
  end

  private def render_list(frame, area)
    is_active = @active_pane == :list

    # Render main list
    list = @tui.list(
      items: @tables,
      block: @tui.block(
        title: " Tables ",
        borders: [:all],
        border_style: is_active ? @style_active : @style_inactive
      ),
      highlight_style: @style_highlight
    )
    # KEY STEP: Pass the state object!
    frame.render_stateful_widget(list, area, @list_state)

    # Render Scrollbar
    scrollbar = @tui.scrollbar(
      content_length: 0,
      position: 0,
      orientation: :vertical_right,
      track_symbol: nil,
      thumb_symbol: "▐"
    )
    scrollbar_state = RatatuiRuby::ScrollbarState.new(@tables.size)
    scrollbar_state.position = @list_state.offset
    scrollbar_state.viewport_content_length = area.height - 2

    frame.render_stateful_widget(scrollbar, area, scrollbar_state)
  end

  private def render_table(frame, area)
    is_active = @active_pane == :table

    # Get current data based on list selection
    current_table = @tables[@list_state.selected || 0]
    rows = @data[current_table]

    # Render table
    table = @tui.table(
      rows:,
      header: @headers[current_table],
      widths: [
        @tui.constraint_percentage(30),
        @tui.constraint_percentage(40),
        @tui.constraint_percentage(30),
      ],
      block: @tui.block(
        title: " #{current_table} Data ",
        borders: [:all],
        border_style: is_active ? @style_active : @style_inactive
      ),
      highlight_style: @style_highlight
    )

    frame.render_stateful_widget(table, area, @table_state)

    # Render Scrollbar
    scrollbar = @tui.scrollbar(
      content_length: 0,
      position: 0,
      orientation: :vertical_right,
      track_symbol: nil,
      thumb_symbol: "▐"
    )
    scrollbar_state = RatatuiRuby::ScrollbarState.new(rows.size)
    scrollbar_state.position = @table_state.offset
    scrollbar_state.viewport_content_length = area.height - 4 # borders + header + margin

    frame.render_stateful_widget(scrollbar, area, scrollbar_state)
  end

  private def handle_input
    case @tui.poll_event
    in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
      :quit

    # Navigation
    in { type: :key, code: "tab" } | { type: :key, code: "right" } | { type: :key, code: "left" }
      @active_pane = (@active_pane == :list) ? :table : :list

    in { type: :key, code: "down" }
      scroll_active(1)

    in { type: :key, code: "up" }
      scroll_active(-1)

    # Mouse Interaction
    in { type: :mouse, kind: "down", x:, y: }
      handle_click(x, y)

    else
      # no-op
    end
  end

  private def scroll_active(delta)
    if @active_pane == :list
      i = @list_state.selected || 0
      new_i = (i + delta).clamp(0, @tables.size - 1)
      @list_state.select(new_i)
      # Reset table selection when switching categories
      if i != new_i
        @table_state.select(0)
        @table_state.select_column(nil) # Ensure clean slate
      end
    else
      current_rows = @data[@tables[@list_state.selected || 0]].size
      i = @table_state.selected || 0
      new_i = (i + delta).clamp(0, current_rows - 1)
      @table_state.select(new_i)
    end
  end

  private def handle_click(x, y)
    if @list_area.contains?(x, y)
      handle_list_click(y)
    elsif @table_area.contains?(x, y)
      handle_table_click(y)
    end
  end

  private def handle_list_click(mouse_y)
    @active_pane = :list

    # CRITICAL: Read back the offset!
    # Formula: clicked_index = (mouse_y - list_top - border_width) + offset
    offset = @list_state.offset
    list_top = @list_area.y
    border_width = 1 # Top border

    clicked_row = (mouse_y - list_top - border_width) + offset

    if clicked_row >= 0 && clicked_row < @tables.size
      @list_state.select(clicked_row)
      @table_state.select(0) # Reset table when category changes
    end
  end

  private def handle_table_click(mouse_y)
    @active_pane = :table

    # CRITICAL: Read back the offset!
    # Formula: clicked_index = (mouse_y - table_top - border - header_height - margin) + offset
    offset = @table_state.offset
    table_top = @table_area.y
    border_width = 1
    header_height = 1
    # No header_margin without Row margin
    effective_top = table_top + border_width + header_height

    clicked_row = (mouse_y - effective_top) + offset

    current_table_data = @data[@tables[@list_state.selected || 0]]
    if clicked_row >= 0 && clicked_row < current_table_data.size
      @table_state.select(clicked_row)
    end
  end
end

AppStatefulInteraction.new.run if __FILE__ == $PROGRAM_NAME
