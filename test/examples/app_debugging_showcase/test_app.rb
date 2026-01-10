# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/app_debugging_showcase/app"

class TestDebuggingShowcase < Minitest::Test
  include RatatuiRuby::TestHelper

  # Time pattern matches HH:MM:SS format
  TIME_PATTERN = /\d{2}:\d{2}:\d{2}/

  def setup
    @app = VerifyDebuggingUsage.new
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run

      assert_normalized_snapshots("initial")
      assert_normalized_rich_snapshot("initial")
    end
  end

  def test_refresh_status
    with_test_terminal do
      inject_key(:b) # Refresh status
      inject_key(:q)
      @app.run

      assert_normalized_snapshots("after_refresh")
    end
  end

  private def normalize_line(line)
    line = line.gsub(TIME_PATTERN, "XX:XX:XX")

    # Normalize socket path: replace with X's padded to match original length
    # Handles both real socket paths and "(socket not available)" fallback
    if line.include?("Socket: ")
      line = line.gsub(/Socket: .*│/) do |match|
        "Socket: #{'X' * 70}│"
      end
    end

    line
  end

  private def assert_normalized_snapshots(snapshot_name)
    normalizer = proc { |lines| lines.map { |l| normalize_line(l) } }
    assert_snapshots(snapshot_name, &normalizer)
  end

  private def assert_normalized_rich_snapshot(snapshot_name)
    assert_rich_snapshot(snapshot_name) { |lines| lines.map { |l| normalize_line(l) } }
  end
end
