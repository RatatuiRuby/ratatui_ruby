# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestOverlay < Minitest::Test
  include RatatuiRuby::TestHelper
  def test_overlay_creation
    l1 = RatatuiRuby::Paragraph.new(text: "L1")
    l2 = RatatuiRuby::Paragraph.new(text: "L2")
    overlay = RatatuiRuby::Overlay.new(layers: [l1, l2])
    assert_equal [l1, l2], overlay.layers
  end

  def test_render
    with_test_terminal(20, 5) do
      l1 = RatatuiRuby::Paragraph.new(text: "Back")
      l2 = RatatuiRuby::Paragraph.new(text: "Fore")
      overlay = RatatuiRuby::Overlay.new(layers: [l1, l2])
      RatatuiRuby.draw(overlay)
      assert_equal "Fore                ", buffer_content[0]
      assert_equal "                    ", buffer_content[1]
      assert_equal "                    ", buffer_content[2]
      assert_equal "                    ", buffer_content[3]
      assert_equal "                    ", buffer_content[4]
    end
  end
end
