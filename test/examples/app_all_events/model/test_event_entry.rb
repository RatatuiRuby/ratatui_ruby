# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "minitest/autorun"
require_relative "../../../../examples/app_all_events/model/event_entry"

class TestEventEntry < Minitest::Test
  def setup
    @timestamp = Timestamp.new(milliseconds: 1000)
    @key_event = RatatuiRuby::Event::Key.new(code: "a", modifiers: [])
  end

  def test_create_creates_entry_with_all_fields
    entry = EventEntry.create(@key_event, :cyan, @timestamp)

    assert_equal @key_event, entry.event
    assert_equal :cyan, entry.color
    assert_equal @timestamp, entry.timestamp
  end

  def test_type_returns_correct_symbol
    entry = EventEntry.create(@key_event, :cyan, @timestamp)
    assert_equal :key, entry.type

    mouse_event = RatatuiRuby::Event::Mouse.new(kind: "down", x: 0, y: 0, button: "left", modifiers: [])
    entry_mouse = EventEntry.create(mouse_event, :yellow, @timestamp)
    assert_equal :mouse, entry_mouse.type
  end

  def test_description_uses_inspect
    entry = EventEntry.create(@key_event, :cyan, @timestamp)

    assert_equal @key_event.inspect, entry.description
  end

  def test_matches_type_returns_true_for_matching_type
    entry = EventEntry.create(@key_event, :cyan, @timestamp)

    assert entry.matches_type?(:key)
  end

  def test_matches_type_returns_false_for_non_matching_type
    entry = EventEntry.create(@key_event, :cyan, @timestamp)

    refute entry.matches_type?(:mouse)
  end

  def test_entry_is_immutable
    entry = EventEntry.create(@key_event, :cyan, @timestamp)

    assert_raises(FrozenError) { entry.instance_variable_set(:@color, :red) }
  end
end
