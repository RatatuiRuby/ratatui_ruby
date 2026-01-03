# frozen_string_literal: true

require "fileutils"
require_relative "test_helper/terminal"
require_relative "test_helper/snapshot"
require_relative "test_helper/event_injection"
require_relative "test_helper/style_assertions"
require_relative "test_helper/test_doubles"

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  ##
  # Helpers for testing RatatuiRuby applications.
  #
  # Writing TUI tests by hand is tedious. You need a headless terminal, event
  # injection, snapshot comparisons, and style assertions. Wiring all that up
  # yourself is error-prone.
  #
  # This module bundles everything you need. Include it in your test class and
  # start writing tests immediately.
  #
  # == Included Mixins
  #
  # [Terminal] Sets up a headless terminal and queries its buffer.
  # [Snapshot] Compares the screen against stored reference files.
  # [EventInjection] Simulates keypresses, mouse clicks, and resize events.
  # [StyleAssertions] Checks foreground color, background color, and text modifiers.
  # [TestDoubles] Provides mocks and stubs for testing views in isolation.
  #
  # == Example
  #
  #   require "ratatui_ruby/test_helper"
  #
  #   class TestMyApp < Minitest::Test
  #     include RatatuiRuby::TestHelper
  #
  #     def test_initial_render
  #       with_test_terminal(80, 24) do
  #         MyApp.new.run_once
  #         assert_snapshot("initial")
  #       end
  #     end
  #
  #     def test_themes
  #       with_test_terminal do
  #         app = ThemeDemo.new
  #         app.run_once
  #         assert_rich_snapshot("default_theme")
  #
  #         inject_key("t", modifiers: [:ctrl])
  #         app.run_once
  #         assert_rich_snapshot("dark_theme")
  #
  #         inject_key("t", modifiers: [:ctrl])
  #         app.run_once
  #         assert_rich_snapshot("high_contrast_theme")
  #       end
  #     end
  #
  #     def test_highlighter_applies_selection_style
  #       with_test_terminal(40, 5) do
  #         RatatuiRuby.draw do |frame|
  #           highlighter = MyApp::UI::Highlighter.new(:yellow)
  #           highlighter.render_at(frame, 0, 2, "Selected Item")
  #         end
  #
  #         assert_fg_color(:yellow, 0, 2)
  #         assert_bold(0, 2)
  #       end
  #     end
  #
  #     def test_view_in_isolation
  #       frame = MockFrame.new
  #       area = StubRect.new(width: 60, height: 20)
  #
  #       MyView.new.call(state, tui, frame, area)
  #
  #       widget = frame.rendered_widgets.first[:widget]
  #       assert_equal "Dashboard", widget.block.title
  #     end
  #   end
  module TestHelper
    include Terminal
    include Snapshot
    include EventInjection
    include StyleAssertions
    include TestDoubles
  end
end
