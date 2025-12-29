# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "app"

class TestBlockPadding < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = BlockPaddingApp.new
  end

  def test_render
    with_test_terminal(80, 24) do
      inject_key(:q)
      @app.run
      
      content = buffer_content.join("\n")
      assert_includes content, "Uniform Padding (2)"
      assert_includes content, "This text is padded by 2 on all sides."
      assert_includes content, "Directional Padding [Left: 4, Right: 0, Top: 2, Bottom: 0]"
      assert_includes content, "Left: 4, Top: 2."
    end
  end
end
