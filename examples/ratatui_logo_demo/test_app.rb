# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "app"

class TestRatatuiLogoDemoApp < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = RatatuiLogoDemoApp.new
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run

      content = buffer_content.join("\n")

      # Verify the logo is rendered.
      # The Ratatui logo usually contains "ratatui" text or similar shapes.
      # Since we can't easily match the exact ASCII art in a cross-platform/version way without brittleness,
      # we verify that the center of the screen is NOT empty.

      # The logo is centered.
      center_x = 40
      center_y = 10
      RatatuiRuby.get_cell_at(center_x, center_y)

      # It might not be exactly at 40, 10, but the logo is large enough that checking a region is safe.
      # Or simpler: verify the buffer contains non-whitespace lines in the middle.

      # Checking for "Controls" proves the app rendered.
      assert_includes content, "Controls"
      assert_includes content, "Quit"

      # Capture the "visual" presence of the logo by ensuring the buffer isn't just known text + whitespace.
      # The logo uses unicode block characters or specific letters.
      # Let's check for a known character from the logo if possible, or just significant non-whitespace count.
      refute_empty content.gsub(/\s+/, ""), "Buffer should not be empty"

      # We know the controls text. Let's ensure there is MORE text than just controls.
      controls_length = "Controls".length + "q: Quit".length + 20 # aprox buffer
      non_whitespace_count = content.gsub(/\s/, "").length
      assert non_whitespace_count > controls_length, "Should render more than just controls (the logo)"
    end
  end
end
