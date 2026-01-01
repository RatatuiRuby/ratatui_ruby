# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestCenter < Minitest::Test
  include RatatuiRuby::TestHelper
  def test_center_creation
    p = RatatuiRuby::Paragraph.new(text: "Hello")
    center = RatatuiRuby::Center.new(child: p, width_percent: 50, height_percent: 50)
    assert_equal p, center.child
    assert_equal 50, center.width_percent
    assert_equal 50, center.height_percent
  end

  def test_render
    with_test_terminal(20, 5) do
      p = RatatuiRuby::Paragraph.new(text: "Hello")
      center = RatatuiRuby::Center.new(child: p, width_percent: 50, height_percent: 50)
      RatatuiRuby.draw { |f| f.render_widget(center, f.area) }
      assert_equal "                    ", buffer_content[0]
      assert_equal "     Hello          ", buffer_content[1]
      assert_equal "                    ", buffer_content[2]
      assert_equal "                    ", buffer_content[3]
      assert_equal "                    ", buffer_content[4]
    end
  end
end
