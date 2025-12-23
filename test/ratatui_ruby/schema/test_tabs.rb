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
end
