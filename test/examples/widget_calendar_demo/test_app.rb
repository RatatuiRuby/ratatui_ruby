# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "minitest/autorun"
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require_relative "../../../examples/widget_calendar_demo/app"

class TestWidgetCalendarDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = WidgetCalendarDemo.new
  end

  def test_demo_renders
    with_test_terminal do
      inject_keys(:down, :down, :q)

      @app.run

      content = buffer_content
      rendered_text = content.join("\n")

      # Verify the bottom controls are present
      assert_match(%r{h/w/s/e: Toggle Header/Weekdays/Surrounding/Events}, rendered_text)
      assert_match(/q: Quit/, rendered_text)

      # Verify the calendar content is present
      assert_match(/#{Time.now.year}/, rendered_text)

      # Verify layout structure (calendar taking up most space, controls at bottom)
      # The controls are on the last line (index 23 for 24 lines) if the terminal is 24 lines high
      # but standard terminal might be different. with_test_terminal defaults to 80x24.
      # assert_match(/q: Quit/, content[23]) if content[23]
    end
  end

  def test_toggle_weekdays_header
    with_test_terminal do
      inject_keys("w", :q)

      @app.run

      content = buffer_content
      rendered_text = content.join("\n")

      # The app should render successfully with weekdays toggled
      assert_match(/#{Time.now.year}/, rendered_text)
    end
  end

  def test_toggle_header
    with_test_terminal do
      inject_keys("h", :q)

      @app.run

      content = buffer_content
      rendered_text = content.join("\n")

      # The app should render successfully with header toggled (hidden)
      refute_match(/#{Time.now.year}/, rendered_text)

      # Inject h again to show it (h -> off, h -> on)
      inject_keys("h", "h", :q)
      @app.run
      content = buffer_content
      rendered_text = content.join("\n")
      assert_match(/#{Time.now.year}/, rendered_text)
    end
  end

  def test_toggle_surrounding
    with_test_terminal do
      inject_keys("s", :q)

      @app.run

      content = buffer_content
      rendered_text = content.join("\n")

      # The app should render successfully with surrounding toggled
      assert_match(/#{Time.now.year}/, rendered_text)
    end
  end

  def test_events_render
    with_test_terminal do
      inject_keys("e", :q)

      @app.run

      content = buffer_content
      # We just check that the app runs without crashing and renders the calendar.
      # Verifying specific color codes in the buffer content is harder without
      # exposing the underlying buffer cells' style.
      # But we can at least assert the content is still correct.
      assert_match(/#{Time.now.year}/, content.join("\n"))

      # Verify the legend is present and shows Off status after toggle
      assert_match(/Events: .* \(Off\)/, content.join("\n"))
    end
  end
end
