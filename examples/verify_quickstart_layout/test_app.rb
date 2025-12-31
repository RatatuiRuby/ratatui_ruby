# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "app"

class TestQuickstartLayout < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = VerifyQuickstartLayout.new
  end

  def test_render
    with_test_terminal do
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      # Check for content in top block
      assert_includes content, "Hello, Ratatui!"
      # Check for content in bottom block
      assert_includes content, "Press 'q' to quit."
      # Check for block titles
      assert_includes content, "Content"
      assert_includes content, "Controls"
    end
  end
end
