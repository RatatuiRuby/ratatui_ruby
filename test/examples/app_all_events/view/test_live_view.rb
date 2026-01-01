# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../../examples/app_all_events/app"
require_relative "../../../../examples/app_all_events/view/live_view"
require_relative "../../../../examples/app_all_events/view_state"
require_relative "../../../../examples/app_all_events/model/events"

class TestLiveView < Minitest::Test
  def setup
    @tui = RatatuiRuby::Session.new
    @frame = RatatuiRuby::TestHelper::MockFrame.new
    @area = RatatuiRuby::TestHelper::StubRect.new
  end

  def build_state(events: Events.new, focused: true)
    ViewState.build(events, focused, @tui, nil)
  end

  def test_renders_single_widget
    state = build_state
    View::Live.new.call(state, @tui, @frame, @area)

    assert_equal 1, @frame.rendered_widgets.length
  end

  def test_block_has_live_display_title
    state = build_state
    View::Live.new.call(state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    assert_equal "Live Display", widget.block.title
  end

  def test_renders_header_row
    state = build_state
    View::Live.new.call(state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    header_spans = widget.text.first.spans
    header_content = header_spans.map(&:content).join

    assert_includes header_content, "Type"
    assert_includes header_content, "Time"
    assert_includes header_content, "Description"
  end

  def test_header_has_bold_modifier
    state = build_state
    View::Live.new.call(state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    header_spans = widget.text.first.spans

    header_spans.each do |span|
      assert_includes span.style.modifiers, :bold
    end
  end

  def test_renders_row_for_each_event_type_except_none
    state = build_state
    View::Live.new.call(state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    # 1 header row + 5 event types (key, mouse, resize, paste, focus - not none)
    assert_equal 6, widget.text.length
  end

  def test_displays_dash_placeholder_when_no_event
    state = build_state
    View::Live.new.call(state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    # Second row is Key event (first after header)
    key_row = widget.text[1]
    row_content = key_row.spans.map(&:content).join

    assert_includes row_content, "—"
  end

  def test_displays_event_type_capitalized
    state = build_state
    View::Live.new.call(state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    event_types_found = []

    widget.text[1..].each do |row|
      first_span_content = row.spans.first.content.strip
      event_types_found << first_span_content
    end

    assert_includes event_types_found, "Key"
    assert_includes event_types_found, "Mouse"
    assert_includes event_types_found, "Resize"
    assert_includes event_types_found, "Paste"
    assert_includes event_types_found, "Focus"
  end

  def test_lit_row_uses_highlighted_style
    events = Events.new
    events.record(RatatuiRuby::Event::Key.new(code: "a"))
    state = build_state(events:)

    View::Live.new.call(state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    key_row = widget.text[1]
    first_span_style = key_row.spans.first.style

    # When lit, should have bg: :green
    assert_equal :green, first_span_style.bg
    assert_equal :black, first_span_style.fg
  end

  def test_unlit_row_uses_cyan_for_type
    state = build_state
    View::Live.new.call(state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    # After some time, unlit rows have cyan type
    key_row = widget.text[1]
    first_span_style = key_row.spans.first.style

    assert_equal :cyan, first_span_style.fg
  end

  def test_border_color_matches_focus_state
    focused_state = build_state(focused: true)
    View::Live.new.call(focused_state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    assert_equal :green, widget.block.border_style.fg

    @frame = RatatuiRuby::TestHelper::MockFrame.new
    unfocused_state = build_state(focused: false)
    View::Live.new.call(unfocused_state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    assert_equal :gray, widget.block.border_style.fg
  end
end
