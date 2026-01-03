# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "minitest/autorun"
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require_relative "../../../examples/widget_cell_demo/app"

class TestWidgetCellDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def test_render
    with_test_terminal(timeout: 5) do
      inject_key("q")
      WidgetCellDemo.new.main

      assert_snapshot("render")
      assert_rich_snapshot("render")
    end
  end
end
