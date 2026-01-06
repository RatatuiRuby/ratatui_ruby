# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

$LOAD_PATH.unshift File.expand_path("../../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/widget_overlay/app"

class TestWidgetOverlayDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetOverlay.new
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run
      assert_snapshots("initial_render")
    end
  end

  def test_toggle_modal
    with_test_terminal do
      # Toggle modal off
      inject_key(" ")
      inject_key(:q)

      @app.run

      assert_snapshots("modal_hidden")
    end
  end
end
