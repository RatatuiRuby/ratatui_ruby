# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # Manages the terminal lifecycle and provides a concise API for the render loop.
  #
  # Writing a TUI loop involves repetitive boilerplate. You constantly instantiate widgets
  # (<tt>RatatuiRuby::Widgets::Paragraph.new</tt>) and call global methods (<tt>RatatuiRuby.draw</tt>).
  # This is verbose and hard to read.
  #
  # The Session object simplifies this. It acts as a factory and a facade. It provides short helper
  # methods for every widget and delegates core commands to the main module.
  #
  # Use it within <tt>RatatuiRuby.run</tt> to build your interface cleanly.
  #
  # == Thread/Ractor Safety
  #
  # Session is an *I/O handle*, not a data object. It has side effects (draw,
  # poll_event) and is intentionally *not* Ractor-shareable. Caching it in
  # instance variables (<tt>@tui = tui</tt>) during your application's run loop
  # is fine. However, do not include it in immutable TEA Models/Messages or
  # pass it to other Ractors.
  #
  # === Examples
  #
  # ==== Basic Usage (Recommended)
  #
  #   RatatuiRuby.run do |tui|
  #     loop do
  #       tui.draw \
  #         tui.paragraph \
  #             text: "Hello, Ratatui! Press 'q' to quit.",
  #             alignment: :center,
  #             block: tui.block(
  #               title: "My Ruby TUI App",
  #               borders: [:all],
  #               border_color: "cyan"
  #             )
  #       event = tui.poll_event
  #       break if event == "q" || event == :ctrl_c
  #     end
  #   end
  class Session
    # -------------------------------------------------------------------
    # Core Module Methods (delegated to RatatuiRuby)
    # -------------------------------------------------------------------

    # Draws the given UI node tree to the terminal.
    # @see RatatuiRuby.draw
    def draw(tree = nil, &)
      RatatuiRuby.draw(tree, &)
    end

    # Checks for user input.
    # @see RatatuiRuby.poll_event
    def poll_event(timeout: 0.016)
      RatatuiRuby.poll_event(timeout:)
    end

    # Inspects the terminal buffer at specific coordinates.
    # @see RatatuiRuby.get_cell_at
    def get_cell_at(x, y)
      RatatuiRuby.get_cell_at(x, y)
    end

    # Creates a Draw::CellCmd for placing a cell at coordinates.
    # @return [Draw::CellCmd]
    def draw_cell(x, y, cell)
      Draw.cell(x, y, cell)
    end

    # -------------------------------------------------------------------
    # Layout Module Factories (RatatuiRuby::Layout::*)
    # -------------------------------------------------------------------

    # Creates a Layout::Rect.
    # @return [Layout::Rect]
    def rect(...)
      Layout::Rect.new(...)
    end

    # Creates a Layout::Constraint.
    # @return [Layout::Constraint]
    def constraint(...)
      Layout::Constraint.new(...)
    end

    # Creates a Layout::Constraint.length.
    # @return [Layout::Constraint]
    def constraint_length(n)
      Layout::Constraint.length(n)
    end

    # Creates a Layout::Constraint.percentage.
    # @return [Layout::Constraint]
    def constraint_percentage(n)
      Layout::Constraint.percentage(n)
    end

    # Creates a Layout::Constraint.min.
    # @return [Layout::Constraint]
    def constraint_min(n)
      Layout::Constraint.min(n)
    end

    # Creates a Layout::Constraint.max.
    # @return [Layout::Constraint]
    def constraint_max(n)
      Layout::Constraint.max(n)
    end

    # Creates a Layout::Constraint.fill.
    # @return [Layout::Constraint]
    def constraint_fill(n = 1)
      Layout::Constraint.fill(n)
    end

    # Creates a Layout::Constraint.ratio.
    # @return [Layout::Constraint]
    def constraint_ratio(numerator, denominator)
      Layout::Constraint.ratio(numerator, denominator)
    end

    # Creates a Layout::Layout.
    # @return [Layout::Layout]
    def layout(...)
      Layout::Layout.new(...)
    end

    # Splits an area using Layout::Layout.split.
    # @return [Array<Layout::Rect>]
    def layout_split(area, direction: :vertical, constraints:, flex: :legacy)
      Layout::Layout.split(area, direction:, constraints:, flex:)
    end

    # -------------------------------------------------------------------
    # Style Module Factories (RatatuiRuby::Style::*)
    # -------------------------------------------------------------------

    # Creates a Style::Style.
    # @return [Style::Style]
    def style(...)
      Style::Style.new(...)
    end

    # -------------------------------------------------------------------
    # Widgets Module Factories (RatatuiRuby::Widgets::*)
    # -------------------------------------------------------------------

    # Creates a Widgets::Block.
    # @return [Widgets::Block]
    def block(...)
      Widgets::Block.new(...)
    end

    # Creates a Widgets::Paragraph.
    # @return [Widgets::Paragraph]
    def paragraph(...)
      Widgets::Paragraph.new(...)
    end

    # Creates a Widgets::List.
    # @return [Widgets::List]
    def list(...)
      Widgets::List.new(...)
    end

    # Creates a Widgets::ListItem.
    # @return [Widgets::ListItem]
    def list_item(...)
      Widgets::ListItem.new(...)
    end

    # Creates a Widgets::Table.
    # @return [Widgets::Table]
    def table(...)
      Widgets::Table.new(...)
    end

    # Creates a Widgets::Row (for Table rows).
    # @return [Widgets::Row]
    def row(...)
      Widgets::Row.new(...)
    end

    # Creates a Widgets::Row (alias for table row).
    # @return [Widgets::Row]
    def table_row(...)
      Widgets::Row.new(...)
    end

    # Creates a Widgets::Cell (for Table cells).
    # @return [Widgets::Cell]
    def table_cell(...)
      Widgets::Cell.new(...)
    end

    # Creates a Widgets::Tabs.
    # @return [Widgets::Tabs]
    def tabs(...)
      Widgets::Tabs.new(...)
    end

    # Creates a Widgets::Gauge.
    # @return [Widgets::Gauge]
    def gauge(...)
      Widgets::Gauge.new(...)
    end

    # Creates a Widgets::LineGauge.
    # @return [Widgets::LineGauge]
    def line_gauge(...)
      Widgets::LineGauge.new(...)
    end

    # Creates a Widgets::Sparkline.
    # @return [Widgets::Sparkline]
    def sparkline(...)
      Widgets::Sparkline.new(...)
    end

    # Creates a Widgets::BarChart.
    # @return [Widgets::BarChart]
    def bar_chart(...)
      Widgets::BarChart.new(...)
    end

    # Creates a Widgets::BarChart::Bar.
    # @return [Widgets::BarChart::Bar]
    def bar(...)
      Widgets::BarChart::Bar.new(...)
    end

    # Creates a Widgets::BarChart::BarGroup.
    # @return [Widgets::BarChart::BarGroup]
    def bar_group(...)
      Widgets::BarChart::BarGroup.new(...)
    end

    # Creates a Widgets::Chart.
    # @return [Widgets::Chart]
    def chart(...)
      Widgets::Chart.new(...)
    end

    # Creates a Widgets::Scrollbar.
    # @return [Widgets::Scrollbar]
    def scrollbar(...)
      Widgets::Scrollbar.new(...)
    end

    # Creates a Widgets::Calendar.
    # @return [Widgets::Calendar]
    def calendar(...)
      Widgets::Calendar.new(...)
    end

    # Creates a Widgets::Canvas.
    # @return [Widgets::Canvas]
    def canvas(...)
      Widgets::Canvas.new(...)
    end

    # Creates a Widgets::Clear.
    # @return [Widgets::Clear]
    def clear(...)
      Widgets::Clear.new(...)
    end

    # Creates a Widgets::Cursor.
    # @return [Widgets::Cursor]
    def cursor(...)
      Widgets::Cursor.new(...)
    end

    # Creates a Widgets::Overlay.
    # @return [Widgets::Overlay]
    def overlay(...)
      Widgets::Overlay.new(...)
    end

    # Creates a Widgets::Center.
    # @return [Widgets::Center]
    def center(...)
      Widgets::Center.new(...)
    end

    # Creates a Widgets::RatatuiLogo.
    # @return [Widgets::RatatuiLogo]
    def ratatui_logo(...)
      Widgets::RatatuiLogo.new(...)
    end

    # Creates a Widgets::RatatuiMascot.
    # @return [Widgets::RatatuiMascot]
    def ratatui_mascot(...)
      Widgets::RatatuiMascot.new(...)
    end

    # Creates a Widgets::Shape::Label.
    # @return [Widgets::Shape::Label]
    def shape_label(...)
      Widgets::Shape::Label.new(...)
    end

    # -------------------------------------------------------------------
    # Text Module Factories (RatatuiRuby::Text::*)
    # -------------------------------------------------------------------

    # Creates a Text::Span.
    # @return [Text::Span]
    def text_span(...)
      Text::Span.new(...)
    end

    # Creates a Text::Span (alias).
    # @return [Text::Span]
    def span(...)
      Text::Span.new(...)
    end

    # Creates a Text::Line.
    # @return [Text::Line]
    def text_line(...)
      Text::Line.new(...)
    end

    # Creates a Text::Line (alias).
    # @return [Text::Line]
    def line(...)
      Text::Line.new(...)
    end

    # Calculates the display width of a string.
    # @return [Integer]
    def text_width(string)
      Text.width(string)
    end

    # -------------------------------------------------------------------
    # State Objects
    # -------------------------------------------------------------------

    # Creates a ListState.
    # @return [ListState]
    def list_state(...)
      ListState.new(...)
    end

    # Creates a TableState.
    # @return [TableState]
    def table_state(...)
      TableState.new(...)
    end

    # Creates a ScrollbarState.
    # @return [ScrollbarState]
    def scrollbar_state(...)
      ScrollbarState.new(...)
    end

    # -------------------------------------------------------------------
    # Chart Components (RatatuiRuby::Widgets::*)
    # -------------------------------------------------------------------

    # Creates a Widgets::Dataset.
    # @return [Widgets::Dataset]
    def dataset(...)
      Widgets::Dataset.new(...)
    end

    # Creates a Widgets::Axis.
    # @return [Widgets::Axis]
    def axis(...)
      Widgets::Axis.new(...)
    end

    # -------------------------------------------------------------------
    # Canvas Shape Factories (RatatuiRuby::Widgets::Shape::*)
    # These are not widgets but canvas shapes for custom drawings
    # -------------------------------------------------------------------

    # Creates a map shape for Canvas.
    # @return [Widgets::Shape::Map]
    def shape_map(...)
      Widgets::Shape::Map.new(...)
    end

    # Creates a line shape for Canvas.
    # @return [Widgets::Shape::Line]
    def shape_line(...)
      Widgets::Shape::Line.new(...)
    end

    # Creates a point (single pixel) shape for Canvas.
    # @return [Widgets::Shape::Point]
    def shape_point(...)
      Widgets::Shape::Point.new(...)
    end

    # Creates a circle shape for Canvas.
    # @return [Widgets::Shape::Circle]
    def shape_circle(...)
      Widgets::Shape::Circle.new(...)
    end

    # Creates a rectangle shape for Canvas.
    # @return [Widgets::Shape::Rectangle]
    def shape_rectangle(...)
      Widgets::Shape::Rectangle.new(...)
    end

    # -------------------------------------------------------------------
    # Buffer Inspection (RatatuiRuby::Buffer::*)
    # -------------------------------------------------------------------

    # Creates a Buffer::Cell (for testing).
    # @return [Buffer::Cell]
    def cell(...)
      Buffer::Cell.new(...)
    end

    # -------------------------------------------------------------------
    # BarChart Components
    # -------------------------------------------------------------------

    # Creates a Widgets::BarChart::Bar (alias).
    # @return [Widgets::BarChart::Bar]
    def bar_chart_bar(...)
      Widgets::BarChart::Bar.new(...)
    end

    # Creates a Widgets::BarChart::BarGroup (alias).
    # @return [Widgets::BarChart::BarGroup]
    def bar_chart_bar_group(...)
      Widgets::BarChart::BarGroup.new(...)
    end
  end
end
