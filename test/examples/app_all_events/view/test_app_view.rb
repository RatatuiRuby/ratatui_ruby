# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../../examples/app_all_events/app"
require_relative "../../../../examples/app_all_events/view/app_view"
require_relative "../../../../examples/app_all_events/model/app_model"
require_relative "../../../../examples/app_all_events/update"

class TestAppView < Minitest::Test
  def setup
    @tui = RatatuiRuby::Session.new
    @frame = RatatuiRuby::TestHelper::MockFrame.new
    @area = RatatuiRuby::TestHelper::StubRect.new(width: 80, height: 24)
  end

  def build_model(focused: true)
    AppModel.initial.with(focused:)
  end

  def test_renders_four_subview_widgets
    model = build_model
    View::App.new.call(model, @tui, @frame, @area)

    assert_equal 4, @frame.rendered_widgets.length
  end

  def test_renders_event_counts_widget
    model = build_model
    View::App.new.call(model, @tui, @frame, @area)

    titles = @frame.rendered_widgets.map { |r| r[:widget].block&.title }
    assert_includes titles, "Event Counts"
  end

  def test_renders_live_display_widget
    model = build_model
    View::App.new.call(model, @tui, @frame, @area)

    titles = @frame.rendered_widgets.map { |r| r[:widget].block&.title }
    assert_includes titles, "Live Display"
  end

  def test_renders_event_log_widget
    model = build_model
    View::App.new.call(model, @tui, @frame, @area)

    titles = @frame.rendered_widgets.map { |r| r[:widget].block&.title }
    assert_includes titles, "Event Log"
  end

  def test_renders_controls_widget
    model = build_model
    View::App.new.call(model, @tui, @frame, @area)

    titles = @frame.rendered_widgets.map { |r| r[:widget].block&.title }
    assert_includes titles, "Controls"
  end

  def test_all_widgets_receive_areas
    model = build_model
    View::App.new.call(model, @tui, @frame, @area)

    @frame.rendered_widgets.each do |rendered|
      refute_nil rendered[:area], "Expected all widgets to receive an area"
    end
  end

  def test_subviews_share_model
    # Record a key event via Update
    model = AppModel.initial
    msg = Msg::Input.new(event: RatatuiRuby::Event::Key.new(code: "a"))
    model = Update.call(msg, model)

    View::App.new.call(model, @tui, @frame, @area)

    # The live display should contain the event data
    live_widget = @frame.rendered_widgets.find { |r| r[:widget].block&.title == "Live Display" }
    refute_nil live_widget
    text_content = live_widget[:widget].text.flat_map { |l| l.spans.map(&:content) }.join
    assert_includes text_content, 'code="a"'
  end

  def test_focus_state_affects_border_colors
    focused_model = build_model(focused: true)
    View::App.new.call(focused_model, @tui, @frame, @area)

    # Check a widget's border color
    live_widget = @frame.rendered_widgets.find { |r| r[:widget].block&.title == "Live Display" }
    assert_equal :green, live_widget[:widget].block.border_style.fg

    # Try unfocused
    @frame = RatatuiRuby::TestHelper::MockFrame.new
    unfocused_model = build_model(focused: false)
    View::App.new.call(unfocused_model, @tui, @frame, @area)

    live_widget = @frame.rendered_widgets.find { |r| r[:widget].block&.title == "Live Display" }
    assert_equal :gray, live_widget[:widget].block.border_style.fg
  end
end
