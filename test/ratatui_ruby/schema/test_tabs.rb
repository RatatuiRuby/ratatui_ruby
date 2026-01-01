# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestTabs < Minitest::Test
  include RatatuiRuby::TestHelper
  def test_tabs_creation
    titles = ["A", "B"]
    tabs = RatatuiRuby::Tabs.new(titles:, selected_index: 0)
    assert_equal titles, tabs.titles
    assert_equal 0, tabs.selected_index
  end

  def test_tabs_defaults
    tabs = RatatuiRuby::Tabs.new
    assert_equal [], tabs.titles
    assert_equal 0, tabs.selected_index
    assert_nil tabs.block
  end

  def test_render
    with_test_terminal(20, 3) do
      tabs = RatatuiRuby::Tabs.new(titles: ["Tab 1", "Tab 2"], selected_index: 0)
      RatatuiRuby.draw { |f| f.render_widget(tabs, f.area) }
      assert_equal " Tab 1 │ Tab 2      ", buffer_content[0]
      assert_equal "                    ", buffer_content[1]
      assert_equal "                    ", buffer_content[2]
    end
  end

  def test_render_tabs_with_divider_and_highlight
    tabs = RatatuiRuby::Tabs.new(
      titles: ["Tab1", "Tab2"],
      selected_index: 0,
      divider: "|",
      highlight_style: RatatuiRuby::Style.new(fg: :red, modifiers: [:bold])
    )

    # Render to a buffer of width 50
    with_test_terminal(50, 3) do
      RatatuiRuby.draw { |f| f.render_widget(tabs, f.area) }

      # Verify content
      content = buffer_content
      line = content[0]

      # Check that the divider is present
      assert_includes line, "|"
      # Check that titles are present
      assert_includes line, "Tab1"
      assert_includes line, "Tab2"
      assert_includes line, "Tab2"
    end
  end

  def test_tabs_with_style
    tabs = RatatuiRuby::Tabs.new(
      titles: ["Tab"],
      style: RatatuiRuby::Style.new(fg: :red, bg: :blue)
    )
    assert_equal :red, tabs.style.fg
    assert_equal :blue, tabs.style.bg
  end

  def test_tabs_padding
    with_test_terminal(20, 1) do
      tabs = RatatuiRuby::Tabs.new(
        titles: ["A", "B"],
        padding_left: 3,
        padding_right: 2
      )
      RatatuiRuby.draw { |f| f.render_widget(tabs, f.area) }
      # Expected: 3 spaces + " A │ B " + 2 spaces + remaining
      line = buffer_content[0]
      assert_match(/^   /, line, "Expected 3 leading spaces for padding_left")
      assert_includes line, "A"
      assert_includes line, "B"
    end
  end

  def test_tabs_width
    # Basic width: "A" (1) + "|" (1) + "B" (1) = 3
    tabs = RatatuiRuby::Tabs.new(titles: ["A", "B"])
    assert_equal 3, tabs.width

    # Custom divider: "A" (1) + " - " (3) + "B" (1) = 5
    tabs = RatatuiRuby::Tabs.new(titles: ["A", "B"], divider: " - ")
    assert_equal 5, tabs.width

    # Padding: 2 + "A" (1) + "|" (1) + "B" (1) + 2 = 7
    tabs = RatatuiRuby::Tabs.new(titles: ["A", "B"], padding_left: 2, padding_right: 2)
    assert_equal 7, tabs.width

    # Line objects in titles
    line_title = RatatuiRuby::Text::Line.from_string("Foo") # width 3
    tabs = RatatuiRuby::Tabs.new(titles: [line_title, "Bar"]) # 3 + 1 + 3 = 7
    assert_equal 7, tabs.width
  end
end
