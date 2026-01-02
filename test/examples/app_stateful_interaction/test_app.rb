# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/app_stateful_interaction/app"

class TestAppStatefulInteraction < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    # Ensure deterministic data for snapshots
    ENV["RATA_SEED"] = "42"
    @app = AppStatefulInteraction.new
  end

  def teardown
    ENV.delete("RATA_SEED")
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run

      assert_snapshot("initial_render")
    end
  end

  def test_scroll_down
    with_test_terminal do
      # 1. Start App
      # 2. Key Down (List is active by default)
      # 3. Quit
      inject_key(:down)
      inject_key(:q)
      @app.run

      assert_snapshot("scroll_down")
    end
  end
end
