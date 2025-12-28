# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"
# Ensure Session is loaded
require "ratatui_ruby/session" rescue nil 
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "table_flex"

class Minitest::Test
  include RatatuiRuby::TestHelper
end

class TestTableFlexApp < Minitest::Test
  def setup
    @app = TableFlexApp.new
  end

  def test_render
    with_test_terminal(60, 20) do
      # Manually create a session to pass to render
      # In real execution, RatatuiRuby.run yields this.
      require "ratatui_ruby/session"
      session = RatatuiRuby::Session.new
      
      @app.render(session)
      
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
