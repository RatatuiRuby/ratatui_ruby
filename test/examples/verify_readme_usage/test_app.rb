# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/verify_readme_usage/app"

class TestReadmeUsage < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = VerifyReadmeUsage.new
  end

  def test_render
    with_test_terminal do
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Hello, Ratatui!"
      assert_includes content, "My Ruby TUI App"
    end
  end
end
