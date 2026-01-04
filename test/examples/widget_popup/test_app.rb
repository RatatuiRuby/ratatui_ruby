# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/widget_popup/app"

class TestWidgetPopupDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetPopup.new
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run

      assert_snapshot("initial_render")
      assert_rich_snapshot("initial_render")
    end
  end

  def test_toggle_clear
    with_test_terminal do
      inject_keys(" ", :q)
      @app.run

      assert_snapshot("after_toggle_clear")
      assert_rich_snapshot("after_toggle_clear")
    end
  end
end
