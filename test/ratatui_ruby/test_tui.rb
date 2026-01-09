# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

class TestTUI < Minitest::Test
  include RatatuiRuby::TestHelper

  def test_can_be_outside_run_for_widget_caching
    # App developers cache TUI instances to pre-build layouts and constraint definitions
    # outside the run loop for performance. This must work.
    assert defined?(RatatuiRuby::TUI), "TUI should be defined after requiring ratatui_ruby"
    tui = RatatuiRuby::TUI.new
    assert_instance_of RatatuiRuby::TUI, tui
    paragraph = tui.paragraph(text: "Hello World")
    assert_instance_of RatatuiRuby::Widgets::Paragraph, paragraph
    assert_equal "Hello World", paragraph.text
  end

  def test_session_delegation
    with_test_terminal(20, 1) do
      RatatuiRuby.run do |tui|
        loop do
          p = tui.paragraph(text: "Builder Works")
          tui.draw(p)
          assert_equal "Builder Works       ", buffer_content[0]
          break
        end
      end
    end
  end

  def test_session_shape_methods
    tui = RatatuiRuby::TUI.new

    point = tui.shape_point(x: 1.0, y: 2.0)
    assert_instance_of RatatuiRuby::Widgets::Shape::Point, point
    assert_equal 1.0, point.x
    assert_equal 2.0, point.y

    line = tui.shape_line(x1: 0.0, y1: 0.0, x2: 10.0, y2: 10.0, color: :red)
    assert_instance_of RatatuiRuby::Widgets::Shape::Line, line
    assert_equal 0.0, line.x1
    assert_equal :red, line.color

    rect = tui.shape_rectangle(x: 0.0, y: 0.0, width: 5.0, height: 5.0, color: :blue)
    assert_instance_of RatatuiRuby::Widgets::Shape::Rectangle, rect

    circle = tui.shape_circle(x: 5.0, y: 5.0, radius: 2.5, color: :green)
    assert_instance_of RatatuiRuby::Widgets::Shape::Circle, circle

    map = tui.shape_map(color: :yellow, resolution: :high)
    assert_instance_of RatatuiRuby::Widgets::Shape::Map, map
  end

  def test_session_text_methods
    tui = RatatuiRuby::TUI.new

    span = tui.text_span(content: "hello")
    assert_instance_of RatatuiRuby::Text::Span, span
    assert_equal "hello", span.content

    line = tui.text_line(spans: [span])
    assert_instance_of RatatuiRuby::Text::Line, line
    assert_equal [span], line.spans
  end

  def test_session_class_method_wrapping
    tui = RatatuiRuby::TUI.new

    # Test Layout.split -> layout_split
    # We pass a mock or simple rect to avoid complex setup, just asserting delegation works
    area = RatatuiRuby::Layout::Rect.new(x: 0, y: 0, width: 10, height: 10)
    constraints = [RatatuiRuby::Layout::Constraint.percentage(50), RatatuiRuby::Layout::Constraint.percentage(50)]

    rects = tui.layout_split(area, direction: :horizontal, constraints:)
    assert_kind_of Array, rects
    assert_equal 2, rects.size
    expected_first = RatatuiRuby::Layout::Rect.new(x: 0, y: 0, width: 5, height: 10)
    assert_equal expected_first, rects.first

    expected_second = RatatuiRuby::Layout::Rect.new(x: 5, y: 0, width: 5, height: 10)
    assert_equal expected_second, rects.last

    # Test Constraint.percentage -> constraint_percentage
    constraint = tui.constraint_percentage(50)
    assert_equal RatatuiRuby::Layout::Constraint.percentage(50), constraint
  end

  def test_session_bar_chart_methods
    tui = RatatuiRuby::TUI.new

    bar = tui.bar_chart_bar(value: 10, label: "Bar 1")
    assert_equal RatatuiRuby::Widgets::BarChart::Bar.new(value: 10, label: "Bar 1"), bar

    group = tui.bar_chart_bar_group(label: "Group 1", bars: [bar])
    assert_equal RatatuiRuby::Widgets::BarChart::BarGroup.new(label: "Group 1", bars: [bar]), group

    chart = tui.bar_chart(data: [group], bar_width: 5)
    assert_equal RatatuiRuby::Widgets::BarChart.new(data: [group], bar_width: 5), chart
  end

  def test_session_is_not_ractor_shareable
    # Session is an I/O handle with side effects (draw, poll_event).
    # It is intentionally NOT Ractor-shareable. Do not cache it in immutable Models.
    tui = RatatuiRuby::TUI.new
    refute Ractor.shareable?(tui),
      "Session should NOT be Ractor.shareable? — it's an I/O handle, not data"
  end

  def test_session_works_when_cached_in_instance_variable
    # Caching session in @tui during the run loop is a valid pattern.
    # This is how examples like app_color_picker work.
    app = SessionCachingApp.new
    with_test_terminal(20, 3) do
      app.run
    end
    assert app.ran_successfully, "Session should work when cached in @tui"
  end

  # v0.7.0: table_row() and table_cell() factory methods
  def test_session_table_methods
    tui = RatatuiRuby::TUI.new

    # table_row() creates Widgets::Row
    row = tui.table_row(cells: ["A", "B", "C"])
    assert_instance_of RatatuiRuby::Widgets::Row, row
    assert_equal ["A", "B", "C"], row.cells

    # table_cell() creates Widgets::Cell
    cell = tui.table_cell(content: "X", style: RatatuiRuby::Style::Style.new(fg: :red))
    assert_instance_of RatatuiRuby::Widgets::Cell, cell
    assert_equal "X", cell.content
    assert_equal :red, cell.style.fg

    # row() is alias for table_row()
    row2 = tui.row(cells: ["D", "E"])
    assert_instance_of RatatuiRuby::Widgets::Row, row2
  end

  # DWIM DX: CSS-friendly constraint aliases
  def test_fixed_alias
    tui = RatatuiRuby::TUI.new
    assert_equal tui.constraint_length(10), tui.fixed(10)
  end

  def test_percent_alias
    tui = RatatuiRuby::TUI.new
    assert_equal tui.constraint_percentage(50), tui.percent(50)
  end

  def test_flex_alias
    tui = RatatuiRuby::TUI.new
    assert_equal tui.constraint_fill(1), tui.flex(1)
    assert_equal tui.constraint_fill(2), tui.flex(2)
  end

  def test_fr_alias
    tui = RatatuiRuby::TUI.new
    assert_equal tui.constraint_fill(1), tui.fr(1)
    assert_equal tui.constraint_fill(3), tui.fr(3)
  end

  def test_split_alias
    tui = RatatuiRuby::TUI.new
    area = RatatuiRuby::Layout::Rect.new(x: 0, y: 0, width: 10, height: 10)
    constraints = [tui.percent(50), tui.percent(50)]

    # split should be an alias for layout_split
    rects = tui.split(area, direction: :horizontal, constraints:)
    assert_equal 2, rects.size
    assert_equal 5, rects.first.width
  end

  # TUI::Core.draw argument validation
  def test_draw_raises_if_both_tree_and_block_provided
    with_test_terminal(10, 10) do
      RatatuiRuby.run do |tui|
        error = assert_raises(ArgumentError) do
          tui.draw(tui.paragraph(text: "x")) { |_f| puts "this will not run" }
        end
        assert_match(/Cannot provide both/, error.message)
        break
      end
    end
  end

  def test_draw_raises_if_neither_tree_nor_block_provided
    with_test_terminal(10, 10) do
      RatatuiRuby.run do |tui|
        error = assert_raises(ArgumentError) do
          tui.draw
        end
        assert_match(/Must provide either/, error.message)
        break
      end
    end
  end

  # DWIM: Factories accept bare Hash (auto-splatting)
  def test_factories_accept_bare_hash
    tui = RatatuiRuby::TUI.new

    # Core widgets
    assert_kind_of RatatuiRuby::Widgets::Table, tui.table({ rows: [], widths: [] })
    assert_kind_of RatatuiRuby::Widgets::List, tui.list({ items: [] })
    assert_kind_of RatatuiRuby::Widgets::Paragraph, tui.paragraph({ text: "hello" })
    assert_kind_of RatatuiRuby::Widgets::Block, tui.block({ title: "Test" })
    assert_kind_of RatatuiRuby::Widgets::Tabs, tui.tabs({ titles: ["A", "B"] })

    # Chart widgets
    assert_kind_of RatatuiRuby::Widgets::Chart, tui.chart({ datasets: [], x_axis: tui.axis({}), y_axis: tui.axis({}) })
    assert_kind_of RatatuiRuby::Widgets::BarChart, tui.bar_chart({ data: [] })
    assert_kind_of RatatuiRuby::Widgets::Axis, tui.axis({})
    assert_kind_of RatatuiRuby::Widgets::Dataset, tui.dataset({ name: "test", data: [] })

    # Gauge widgets
    assert_kind_of RatatuiRuby::Widgets::Gauge, tui.gauge({ ratio: 0.5 })
    assert_kind_of RatatuiRuby::Widgets::LineGauge, tui.line_gauge({ ratio: 0.5 })
    assert_kind_of RatatuiRuby::Widgets::Sparkline, tui.sparkline({ data: [] })

    # Other widgets
    assert_kind_of RatatuiRuby::Widgets::Scrollbar, tui.scrollbar({ content_length: 100, position: 0 })
    assert_kind_of RatatuiRuby::Widgets::Calendar, tui.calendar({ year: 2026, month: 1 })
    assert_kind_of RatatuiRuby::Widgets::Canvas, tui.canvas({})
    assert_kind_of RatatuiRuby::Widgets::Row, tui.row({ cells: [] })
    assert_kind_of RatatuiRuby::Widgets::Cell, tui.table_cell({ content: "X" })
    assert_kind_of RatatuiRuby::Widgets::ListItem, tui.list_item({ content: "X" })
    assert_kind_of RatatuiRuby::Widgets::Center, tui.center({ child: tui.paragraph({ text: "hi" }) })
    assert_kind_of RatatuiRuby::Widgets::Clear, tui.clear({})
    assert_kind_of RatatuiRuby::Widgets::Cursor, tui.cursor({ x: 0, y: 0 })
    assert_kind_of RatatuiRuby::Widgets::Overlay, tui.overlay({})
    assert_kind_of RatatuiRuby::Widgets::RatatuiLogo, tui.ratatui_logo({})
    assert_kind_of RatatuiRuby::Widgets::RatatuiMascot, tui.ratatui_mascot({})

    # Nested widgets
    assert_kind_of RatatuiRuby::Widgets::BarChart::Bar, tui.bar({ value: 10 })
    assert_kind_of RatatuiRuby::Widgets::BarChart::BarGroup, tui.bar_group({ label: "Q1", bars: [] })
    assert_kind_of RatatuiRuby::Widgets::Shape::Label, tui.shape_label({ x: 0, y: 0, text: "Hi" })
  end

  # DWIM: Unknown keys raise in debug mode (TestHelper enables debug mode)
  def test_unknown_keys_raise_in_debug_mode
    tui = RatatuiRuby::TUI.new

    # TestHelper enables debug mode, so unknown keys should raise ArgumentError
    error = assert_raises(ArgumentError) do
      tui.table({ rows: [], widths: [], fake_key: 1 })
    end
    assert_match(/unknown key.*fake_key/i, error.message)
  end

  # DWIM: Unknown keys are silently ignored outside debug mode
  def test_unknown_keys_ignored_outside_debug_mode
    tui = RatatuiRuby::TUI.new

    # Suppress debug mode to simulate production behavior
    RatatuiRuby::Debug.suppress_debug_mode do
      # Should NOT raise, just ignores the unknown key
      table = tui.table({ rows: [], widths: [], fake_key: 1 })
      assert_kind_of RatatuiRuby::Widgets::Table, table
    end
  end
end

# Helper class to test @tui = tui pattern
class SessionCachingApp
  attr_reader :ran_successfully

  def initialize
    @ran_successfully = false
  end

  def run
    RatatuiRuby.run do |tui|
      @tui = tui # Cache session in instance variable
      render
      @ran_successfully = true
    end
  end

  private def render
    # Use cached @tui from another method
    @tui.draw(@tui.paragraph(text: "Cached!"))
  end
end
