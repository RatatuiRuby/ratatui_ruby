# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class CustomWidget
  def render(area)
    [
      RatatuiRuby::Draw.string(area.x, area.y, "X", { fg: :red }),
      # Stay within the 2-row height of the test layout
      RatatuiRuby::Draw.string(area.x + 1, area.y, "Y", { fg: :blue }),
    ]
  end
end

class TestEscapeHatch < Minitest::Test
  include RatatuiRuby::TestHelper
  def test_custom_widget_render
    with_test_terminal(5, 5) do
      widget = CustomWidget.new
      RatatuiRuby.draw(widget)

      assert_equal "XY   ", buffer_content[0]
      assert_equal "     ", buffer_content[1]
      assert_equal "     ", buffer_content[2]
    end
  end

  def test_custom_widget_in_layout
    with_test_terminal(10, 2) do
      layout = RatatuiRuby::Layout.new(
        direction: :vertical,
        constraints: [
          RatatuiRuby::Constraint.length(1),
          RatatuiRuby::Constraint.length(1),
        ],
        children: [
          RatatuiRuby::Paragraph.new(text: "Hello"),
          CustomWidget.new,
        ]
      )
      RatatuiRuby.draw(layout)

      assert_equal "Hello     ", buffer_content[0]
      assert_equal "XY        ", buffer_content[1]
    end
  end
end
