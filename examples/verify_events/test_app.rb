# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "app"

class TestVerifyEvents < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = VerifyEventsApp.new
  end

  def test_run_and_quit
    # This example prints to stdout using puts, which is tricky to capture in these tests
    # but we can at least verify it runs and quits correctly.
    with_test_terminal do
      inject_key(:q)
      @app.run
      # Success if it returns
    end
  end
end
