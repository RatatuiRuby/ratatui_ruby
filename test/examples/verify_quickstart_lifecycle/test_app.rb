# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/verify_quickstart_lifecycle/app"

class TestQuickstartLifecycle < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = VerifyQuickstartLifecycle.new
  end

  def test_render
    with_test_terminal do
      inject_key(:q)
      @app.run

      assert_snapshots("render")
      assert_rich_snapshot("render")
    end
  end
end
