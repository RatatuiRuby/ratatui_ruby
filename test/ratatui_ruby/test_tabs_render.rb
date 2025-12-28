# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

module RatatuiRuby
  class TestTabsRender < Minitest::Test
    include TestHelper

    def test_render_tabs_with_divider_and_highlight
      tabs = Tabs.new(
        titles: ["Tab1", "Tab2"],
        selected_index: 0,
        divider: "|",
        highlight_style: Style.new(fg: :red, modifiers: [:bold])
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
      end
    end
  end
end
