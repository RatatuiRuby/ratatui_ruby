# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/widget_table_flex/app"

class TestWidgetTableFlex < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetTableFlex.new
  end

  def test_render
    with_test_terminal do
      # Queue quit
      inject_key(:q)

      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Table Flex Layout"
      assert_includes content, "Flex: :space_between"
      assert_includes content, "Flex: :space_around"

      # Verify some table content
      assert_includes content, "Legacy (Default)"
      assert_includes content, "Item 1"
    end
  end
end
