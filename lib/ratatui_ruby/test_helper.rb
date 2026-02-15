# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "fileutils"
require_relative "test_helper/terminal"
require_relative "test_helper/snapshot"
require_relative "test_helper/event_injection"
require_relative "test_helper/style_assertions"
require_relative "test_helper/test_doubles"
require_relative "test_helper/global_state"
require_relative "test_helper/subprocess_timeout"

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
  # [GlobalState] Provides with_argv and with_env helpers for testing global state access.
  #
  # == Example
  #
  #--
  # SPDX-SnippetBegin
  # SPDX-FileCopyrightText: 2026 Kerrick Long
  # SPDX-License-Identifier: MIT-0
  #++
  #   require "ratatui_ruby/test_helper"
  #
  #   class TestMyApp < Minitest::Test
  #     include RatatuiRuby::TestHelper
  #
  #     def test_initial_render
  #       with_test_terminal(80, 24) do
  #         MyApp.new.run_once
  #         assert_snapshots("initial")
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
  #--
  # SPDX-SnippetEnd
  #++
  module TestHelper
    ##
    # Auto-enables debug mode when TestHelper is included.
    #
    # This ensures Rust backtraces are available in tests.
    # Skips remote debugging since tests don't need it.
    def self.included(base)
      RatatuiRuby::Debug.enable!(source: :test)
    end

    include Terminal
    include Snapshot
    include EventInjection
    include StyleAssertions
    include TestDoubles
    include GlobalState
    include SubprocessTimeout
  end
end
