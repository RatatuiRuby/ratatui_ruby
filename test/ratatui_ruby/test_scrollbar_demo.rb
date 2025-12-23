# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"
require_relative "../../examples/scrollbar_demo"

class TestScrollbarDemo < Minitest::Test
  def setup
    @demo = ScrollbarDemo.new
  end

  def test_initial_render
    with_test_terminal(20, 5) do
      # We need to access private methods to test without running the full loop
      @demo.__send__(:draw)
      content = buffer_content

      # Top border with title
      assert_includes content[0], "Scroll with Mouse"
      # First line of content
      assert_includes content[1], "Line 1"
      # Scrollbar area (far right)
      assert_equal "█", content[1][-1]
    end
  end

  def test_scroll_down
    with_test_terminal(20, 5) do
      # Simulate scroll down event
      # ScrollbarDemo#handle_event expects a hash from poll_event
      @demo.__send__(:handle_event, { type: :mouse, kind: :scroll_down, x: 0, y: 0 })

      @demo.__send__(:draw)
      content = buffer_content

      # Now it should start from Line 2
      assert_includes content[1], "Line 2"
      refute_includes content[1], "Line 1"
    end
  end

  def test_scroll_up
    with_test_terminal(20, 5) do
      # Scroll down then up
      @demo.__send__(:handle_event, { type: :mouse, kind: :scroll_down, x: 0, y: 0 })
      @demo.__send__(:handle_event, { type: :mouse, kind: :scroll_up, x: 0, y: 0 })

      @demo.__send__(:draw)
      content = buffer_content

      assert_includes content[1], "Line 1"
    end
  end
end
