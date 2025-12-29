# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestTabs < Minitest::Test
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
      RatatuiRuby.draw(tabs)
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
      RatatuiRuby.draw(tabs)

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
end
