# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "app"

class TestRatatuiMascotDemoApp < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = RatatuiMascotDemoApp.new
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Ratatui Mascot" # Title implying block is on
      assert_includes content, "Toggle Block (On)"
      # Mascot contains block characters
      assert_includes content, "█"
    end
  end

  def test_toggle_block
    with_test_terminal do
      inject_key("b")
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")
      assert_includes content, "Toggle Block (Off)"
      # Title should be gone if block is gone (unless internal rendering keeps it, but our logic removes the block)
      # Wait, if block is nil, no border/title.
      refute_includes content, "Ratatui Mascot"
      # Mascot should still be there
      assert_includes content, "█"
    end
  end
end
