# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../../examples/app_all_events/view/log_view"
require_relative "../../../../examples/app_all_events/view_state"
require_relative "../../../../examples/app_all_events/model/events"

class TestLogView < Minitest::Test
  def setup
    @tui = RatatuiRuby::Session.new
    @frame = RatatuiRuby::TestHelper::MockFrame.new
    @area = RatatuiRuby::TestHelper::StubRect.new(height: 24)
  end

  def build_state(events: Events.new, focused: true)
    ViewState.build(events, focused, @tui, nil)
  end

  def test_renders_single_widget
    state = build_state
    View::Log.new.call(state, @tui, @frame, @area)

    assert_equal 1, @frame.rendered_widgets.length
  end

  def test_block_has_event_log_title
    state = build_state
    View::Log.new.call(state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    assert_equal "Event Log", widget.block.title
  end

  def test_displays_no_events_message_when_empty
    state = build_state(events: Events.new)
    View::Log.new.call(state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    first_line_content = widget.text.first.spans.first.content
    assert_equal "No events yet...", first_line_content
  end

  def test_dimmed_style_on_empty_message
    state = build_state(events: Events.new)
    View::Log.new.call(state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    first_span_style = widget.text.first.spans.first.style
    assert_equal state.dimmed_style, first_span_style
  end

  def test_renders_key_event_format
    events = Events.new
    events.record(RatatuiRuby::Event::Key.new(code: "a"))
    state = build_state(events:)

    View::Log.new.call(state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    text_content = extract_all_content(widget)
    # Check for inspect format parts
    assert_includes text_content, "RatatuiRuby::Event::Key"
    assert_includes text_content, 'code="a"'
  end

  def test_renders_mouse_event_format
    events = Events.new
    events.record(RatatuiRuby::Event::Mouse.new(kind: "down", button: "left", x: 10, y: 5))
    state = build_state(events:)

    View::Log.new.call(state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    text_content = extract_all_content(widget)
    assert_includes text_content, "RatatuiRuby::Event::Mouse"
    assert_includes text_content, "kind=\"down\""
    assert_includes text_content, "x=10"
    assert_includes text_content, "y=5"
  end

  def test_renders_resize_event_format
    events = Events.new
    events.record(RatatuiRuby::Event::Resize.new(width: 100, height: 30))
    state = build_state(events:)

    View::Log.new.call(state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    text_content = extract_all_content(widget)
    assert_includes text_content, "RatatuiRuby::Event::Resize"
    assert_includes text_content, "width=100"
    assert_includes text_content, "height=30"
  end

  def test_renders_paste_event_format
    events = Events.new
    events.record(RatatuiRuby::Event::Paste.new(content: "Hello"))
    state = build_state(events:)

    View::Log.new.call(state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    text_content = extract_all_content(widget)
    assert_includes text_content, "RatatuiRuby::Event::Paste"
    assert_includes text_content, "content=\"Hello\""
  end

  def test_renders_focus_gained_event_format
    events = Events.new
    events.record(RatatuiRuby::Event::FocusGained.new)
    state = build_state(events:)

    View::Log.new.call(state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    text_content = extract_all_content(widget)
    assert_includes text_content, "RatatuiRuby::Event::FocusGained"
  end

  def test_renders_focus_lost_event_format
    events = Events.new
    events.record(RatatuiRuby::Event::FocusLost.new)
    state = build_state(events:)

    View::Log.new.call(state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    text_content = extract_all_content(widget)
    assert_includes text_content, "RatatuiRuby::Event::FocusLost"
  end

  def test_entry_color_cycles
    events = Events.new
    events.record(RatatuiRuby::Event::Key.new(code: "x"))
    state = build_state(events:)

    View::Log.new.call(state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    first_line_style = widget.text.first.spans.first.style
    refute_nil first_line_style.fg
  end

  def test_calculates_visible_entries_from_area_height
    # With height 24, visible_entries_count = (24 - 2) / 2 = 11
    events = Events.new
    15.times do |i|
      events.record(RatatuiRuby::Event::Key.new(code: i.to_s))
    end
    state = build_state(events:)

    View::Log.new.call(state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    # Each entry produces 2 lines, so 11 entries = 22 lines
    assert_equal 22, widget.text.length
  end

  private def extract_all_content(widget)
    widget.text.flat_map { |line| line.spans.map(&:content) }.join
  end
end
