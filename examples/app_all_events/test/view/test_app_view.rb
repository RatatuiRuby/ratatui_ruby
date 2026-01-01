# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../app"
require_relative "../../view/app_view"
require_relative "../../view_state"
require_relative "../../model/events"

class TestAppView < Minitest::Test
  def setup
    @tui = RatatuiRuby::Session.new
    @frame = RatatuiRuby::TestHelper::MockFrame.new
    @area = RatatuiRuby::TestHelper::StubRect.new(width: 80, height: 24)
  end

  def build_state(events: Events.new, focused: true)
    ViewState.build(events, focused, @tui, nil)
  end

  def test_renders_four_subview_widgets
    state = build_state
    View::App.new.call(state, @tui, @frame, @area)

    assert_equal 4, @frame.rendered_widgets.length
  end

  def test_renders_event_counts_widget
    state = build_state
    View::App.new.call(state, @tui, @frame, @area)

    titles = @frame.rendered_widgets.map { |r| r[:widget].block&.title }
    assert_includes titles, "Event Counts"
  end

  def test_renders_live_display_widget
    state = build_state
    View::App.new.call(state, @tui, @frame, @area)

    titles = @frame.rendered_widgets.map { |r| r[:widget].block&.title }
    assert_includes titles, "Live Display"
  end

  def test_renders_event_log_widget
    state = build_state
    View::App.new.call(state, @tui, @frame, @area)

    titles = @frame.rendered_widgets.map { |r| r[:widget].block&.title }
    assert_includes titles, "Event Log"
  end

  def test_renders_controls_widget
    state = build_state
    View::App.new.call(state, @tui, @frame, @area)

    titles = @frame.rendered_widgets.map { |r| r[:widget].block&.title }
    assert_includes titles, "Controls"
  end

  def test_all_widgets_receive_areas
    state = build_state
    View::App.new.call(state, @tui, @frame, @area)

    @frame.rendered_widgets.each do |rendered|
      refute_nil rendered[:area], "Expected all widgets to receive an area"
    end
  end

  def test_subviews_share_state
    # When we pass a specific state, all subviews should reflect it
    events = Events.new
    events.record(RatatuiRuby::Event::Key.new(code: "a"))
    state = build_state(events:)

    View::App.new.call(state, @tui, @frame, @area)

    # The live display should contain the event data
    live_widget = @frame.rendered_widgets.find { |r| r[:widget].block&.title == "Live Display" }
    refute_nil live_widget
    text_content = live_widget[:widget].text.flat_map { |l| l.spans.map(&:content) }.join
    assert_includes text_content, 'code="a"'
  end

  def test_focus_state_affects_border_colors
    focused_state = build_state(focused: true)
    View::App.new.call(focused_state, @tui, @frame, @area)

    # Check a widget's border color
    live_widget = @frame.rendered_widgets.find { |r| r[:widget].block&.title == "Live Display" }
    assert_equal :green, live_widget[:widget].block.border_style.fg

    # Try unfocused
    @frame = RatatuiRuby::TestHelper::MockFrame.new
    unfocused_state = build_state(focused: false)
    View::App.new.call(unfocused_state, @tui, @frame, @area)

    live_widget = @frame.rendered_widgets.find { |r| r[:widget].block&.title == "Live Display" }
    assert_equal :gray, live_widget[:widget].block.border_style.fg
  end
end
