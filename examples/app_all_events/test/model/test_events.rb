# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "minitest/autorun"
require "ratatui_ruby"
require_relative "../../model/events"

class TestEvents < Minitest::Test
  def setup
    @events = Events.new
  end

  # empty? tests

  def test_empty_returns_true_initially
    assert @events.empty?
  end

  def test_empty_returns_false_after_recording_event
    @events.record(RatatuiRuby::Event::Key.new(code: "a"))

    refute @events.empty?
  end

  def test_empty_remains_true_after_none_event
    @events.record(:none)

    assert @events.empty?
  end

  # record and count tests

  def test_record_increments_count
    @events.record(RatatuiRuby::Event::Key.new(code: "a"))

    assert_equal 1, @events.count(:key)
  end

  def test_record_multiple_increments
    3.times { @events.record(RatatuiRuby::Event::Key.new(code: "a")) }

    assert_equal 3, @events.count(:key)
  end

  def test_record_none_does_not_create_entry
    @events.record(:none)

    assert @events.empty?
    assert_equal 1, @events.count(:none)
  end

  def test_record_none_multiple_times
    5.times { @events.record(:none) }

    assert_equal 5, @events.count(:none)
  end

  def test_count_returns_zero_for_unrecorded_type
    assert_equal 0, @events.count(:mouse)
  end

  def test_count_different_types_independently
    2.times { @events.record(RatatuiRuby::Event::Key.new(code: "k")) }
    3.times { @events.record(RatatuiRuby::Event::Mouse.new(kind: "down", x: 0, y: 0, button: "left")) }

    assert_equal 2, @events.count(:key)
    assert_equal 3, @events.count(:mouse)
    assert_equal 0, @events.count(:resize)
  end

  # visible tests

  def test_visible_returns_empty_array_initially
    assert_equal [], @events.visible(10)
  end

  def test_visible_returns_all_entries_when_less_than_max
    @events.record(RatatuiRuby::Event::Key.new(code: "a"))
    @events.record(RatatuiRuby::Event::Key.new(code: "b"))

    visible = @events.visible(10)

    assert_equal 2, visible.length
  end

  def test_visible_returns_last_n_entries
    5.times { |i| @events.record(RatatuiRuby::Event::Key.new(code: i.to_s)) }

    visible = @events.visible(3)

    assert_equal 3, visible.length
  end

  def test_visible_does_not_include_none_events
    @events.record(RatatuiRuby::Event::Key.new(code: "k"))
    @events.record(:none)
    @events.record(RatatuiRuby::Event::Mouse.new(kind: "down", x: 0, y: 0, button: "left"))

    visible = @events.visible(10)

    assert_equal 2, visible.length
  end

  # entries tests

  def test_entries_returns_all_entries
    @events.record(RatatuiRuby::Event::Key.new(code: "a"))
    @events.record(RatatuiRuby::Event::Mouse.new(kind: "down", x: 0, y: 0, button: "left"))

    assert_equal 2, @events.entries.length
  end

  def test_entries_returns_evententry_objects
    @events.record(RatatuiRuby::Event::Key.new(code: "a"))

    entry = @events.entries.first
    assert_instance_of EventEntry, entry
  end

  # live_event and live_events tests

  def test_live_event_returns_nil_initially
    assert_nil @events.live_event(:key)
  end

  def test_live_event_returns_recorded_data
    @events.record(RatatuiRuby::Event::Key.new(code: "a", modifiers: []))

    live = @events.live_event(:key)

    # description is now inspect
    assert_includes live[:description], 'code="a"'
    assert_includes live[:description], "RatatuiRuby::Event::Key"
  end

  def test_live_event_updates_on_new_record
    @events.record(RatatuiRuby::Event::Key.new(code: "a"))
    @events.record(RatatuiRuby::Event::Key.new(code: "b"))

    assert_includes @events.live_event(:key)[:description], 'code="b"'
  end

  def test_live_events_returns_all_live_data
    @events.record(RatatuiRuby::Event::Key.new(code: "a"))
    @events.record(RatatuiRuby::Event::Mouse.new(kind: "down", x: 0, y: 0, button: "left"))

    live = @events.live_events

    assert live.key?(:key)
    assert live.key?(:mouse)
  end

  def test_live_type_overrides_event_type
    @events.record(RatatuiRuby::Event::FocusGained.new)

    assert_nil @events.live_event(:focus_gained)
    refute_nil @events.live_event(:focus)
    assert_includes @events.live_event(:focus)[:description], "FocusGained"
  end

  # lit? tests

  def test_sub_counts_for_mouse_groups_by_kind
    @events.record(RatatuiRuby::Event::Mouse.new(kind: "down", x: 0, y: 0, button: "left"))
    @events.record(RatatuiRuby::Event::Mouse.new(kind: "up", x: 0, y: 0, button: "left"))
    @events.record(RatatuiRuby::Event::Mouse.new(kind: "down", x: 0, y: 0, button: "right"))

    sub_counts = @events.sub_counts(:mouse)

    assert_equal 2, sub_counts["down"]
    assert_equal 1, sub_counts["up"]
    assert_equal 0, sub_counts["drag"]
  end

  def test_sub_counts_for_key_groups_by_modifiers
    @events.record(RatatuiRuby::Event::Key.new(code: "a"))
    @events.record(RatatuiRuby::Event::Key.new(code: "b", modifiers: ["ctrl"]))

    sub_counts = @events.sub_counts(:key)

    assert_equal 1, sub_counts["unmodified"]
    assert_equal 1, sub_counts["modified"]
  end

  def test_sub_counts_for_focus_groups_by_type
    @events.record(RatatuiRuby::Event::FocusGained.new)
    @events.record(RatatuiRuby::Event::FocusLost.new)

    sub_counts = @events.sub_counts(:focus)

    assert_equal 1, sub_counts["gained"]
    assert_equal 1, sub_counts["lost"]
  end

  def test_sub_counts_returns_empty_hash_for_ungroupable_type
    @events.record(RatatuiRuby::Event::Resize.new(width: 10, height: 10))

    assert_equal({}, @events.sub_counts(:resize))
  end

  def test_lit_returns_true_immediately_after_recording
    @events.record(RatatuiRuby::Event::Key.new(code: "a"))

    assert @events.lit?(:key)
  end

  def test_lit_returns_false_for_different_type
    @events.record(RatatuiRuby::Event::Key.new(code: "a"))

    refute @events.lit?(:mouse)
  end

  def test_lit_returns_false_after_duration_expires
    @events.record(RatatuiRuby::Event::Key.new(code: "a"))
    sleep 0.35 # 350ms, longer than HIGHLIGHT_DURATION_MS (300ms)

    refute @events.lit?(:key)
  end

  def test_lit_returns_true_within_duration
    @events.record(RatatuiRuby::Event::Key.new(code: "a"))
    sleep 0.1 # 100ms, well within 300ms

    assert @events.lit?(:key)
  end

  def test_new_event_replaces_lit_key
    @events.record(RatatuiRuby::Event::Key.new(code: "a"))
    @events.record(RatatuiRuby::Event::Mouse.new(kind: "down", x: 0, y: 0, button: "left"))

    assert @events.lit?(:mouse)
    refute @events.lit?(:key)
  end

  # Color cycling tests

  def test_entries_have_different_colors
    3.times { |i| @events.record(RatatuiRuby::Event::Key.new(code: i.to_s)) }

    colors = @events.entries.map(&:color)

    assert_equal %i[cyan magenta yellow], colors
  end

  def test_colors_cycle
    6.times { |i| @events.record(RatatuiRuby::Event::Key.new(code: i.to_s)) }

    colors = @events.entries.map(&:color)

    assert_equal %i[cyan magenta yellow cyan magenta yellow], colors
  end

  # Constant tests

  def test_highlight_duration_constant
    assert_equal 300, Events::HIGHLIGHT_DURATION_MS
  end
end
