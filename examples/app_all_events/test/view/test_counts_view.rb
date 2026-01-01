# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../app"
require_relative "../../view/counts_view"
require_relative "../../view_state"
require_relative "../../model/events"

class TestCountsView < Minitest::Test
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
    View::Counts.new.call(state, @tui, @frame, @area)

    assert_equal 1, @frame.rendered_widgets.length
  end

  def test_block_has_event_counts_title
    state = build_state
    View::Counts.new.call(state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    assert_equal "Event Counts", widget.block.title
  end

  def test_renders_all_event_types
    state = build_state
    View::Counts.new.call(state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    text_content = extract_all_content(widget)

    assert_includes text_content, "Key:"
    assert_includes text_content, "Mouse:"
    assert_includes text_content, "Resize:"
    assert_includes text_content, "Paste:"
    assert_includes text_content, "Focus:"
    assert_includes text_content, "None:"
  end

  def test_type_labels_are_capitalized
    state = build_state
    View::Counts.new.call(state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    text_content = extract_all_content(widget)

    # Ensure capitalized forms exist
    assert_includes text_content, "Key:"
    refute_includes text_content, "key:"
  end

  def test_displays_zero_counts_initially
    state = build_state
    View::Counts.new.call(state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    text_content = extract_all_content(widget)
    # Find spans with count values
    count_spans = widget.text.flat_map(&:spans).select { |s| s.content.strip =~ /^\d+$/ }
    all_zeros = count_spans.all? { |s| s.content.strip == "0" }
    assert all_zeros, "Expected all counts to be 0 initially"

    # Ensure sub-counts are visible
    assert_includes text_content, "Unmodified:"
    assert_includes text_content, "Down:"
    assert_includes text_content, "Gained:"
  end

  def test_displays_incremented_counts
    events = Events.new
    events.record(RatatuiRuby::Event::Key.new(code: "a"))
    events.record(RatatuiRuby::Event::Key.new(code: "b"))
    events.record(RatatuiRuby::Event::Mouse.new(kind: "down", button: "left", x: 0, y: 0))
    state = build_state(events:)

    View::Counts.new.call(state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    text_content = extract_all_content(widget)

    assert_includes text_content, "Key: 2"
    assert_includes text_content, "Mouse: 1"
  end

  def test_renders_mouse_sub_counts
    events = Events.new
    events.record(RatatuiRuby::Event::Mouse.new(kind: "down", button: "left", x: 0, y: 0))
    state = build_state(events:)

    View::Counts.new.call(state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    text_content = extract_all_content(widget)

    assert_includes text_content, "Down: 1"
  end

  def test_renders_key_sub_counts
    events = Events.new
    events.record(RatatuiRuby::Event::Key.new(code: "a"))
    state = build_state(events:)

    View::Counts.new.call(state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    text_content = extract_all_content(widget)

    assert_includes text_content, "Unmodified: 1"
  end

  def test_renders_focus_sub_counts
    events = Events.new
    events.record(RatatuiRuby::Event::FocusGained.new)
    events.record(RatatuiRuby::Event::FocusLost.new)
    state = build_state(events:)

    View::Counts.new.call(state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    text_content = extract_all_content(widget)

    assert_includes text_content, "Gained: 1"
    assert_includes text_content, "Lost: 1"
  end

  def test_lit_style_when_event_type_is_lit
    events = Events.new
    events.record(RatatuiRuby::Event::Key.new(code: "a"))
    state = build_state(events:)

    View::Counts.new.call(state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    key_line = widget.text.find { |line| line.spans.first.content.include?("Key:") }
    key_label_style = key_line.spans.first.style

    # lit_style has fg: :green and bold
    assert_equal :green, key_label_style.fg
    assert_includes key_label_style.modifiers, :bold
  end

  def test_border_color_matches_focus_state
    focused_state = build_state(focused: true)
    View::Counts.new.call(focused_state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    assert_equal :green, widget.block.border_style.fg

    @frame = RatatuiRuby::TestHelper::MockFrame.new
    unfocused_state = build_state(focused: false)
    View::Counts.new.call(unfocused_state, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    assert_equal :gray, widget.block.border_style.fg
  end

  private def extract_all_content(widget)
    widget.text.flat_map { |line| line.spans.map(&:content) }.join
  end
end
