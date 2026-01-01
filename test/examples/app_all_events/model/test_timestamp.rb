# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "minitest/autorun"
require_relative "../../../../examples/app_all_events/model/timestamp"

class TestTimestamp < Minitest::Test
  def test_now_returns_timestamp_instance
    timestamp = Timestamp.now

    assert_instance_of Timestamp, timestamp
  end

  def test_now_returns_positive_milliseconds
    timestamp = Timestamp.now

    assert_operator timestamp.milliseconds, :>, 0
  end

  def test_now_returns_increasing_values
    timestamp1 = Timestamp.now
    timestamp2 = Timestamp.now

    assert_operator timestamp2.milliseconds, :>=, timestamp1.milliseconds
  end

  def test_current_returns_integer
    current = Timestamp.current

    assert_instance_of Integer, current
  end

  def test_current_equals_now_milliseconds
    # Within a small tolerance due to timing
    now = Timestamp.now.milliseconds
    current = Timestamp.current

    assert_in_delta now, current, 10
  end

  def test_elapsed_returns_false_immediately
    timestamp = Timestamp.now

    refute timestamp.elapsed?(1000)
  end

  def test_elapsed_returns_true_for_zero_duration
    timestamp = Timestamp.now

    # With 0 duration, elapsed? returns true since now >= now + 0
    assert timestamp.elapsed?(0)
  end

  def test_elapsed_returns_true_after_duration_passes
    timestamp = Timestamp.now
    sleep 0.05 # 50ms

    assert timestamp.elapsed?(40)
  end

  def test_elapsed_returns_false_if_duration_not_yet_passed
    timestamp = Timestamp.now
    sleep 0.01 # 10ms

    refute timestamp.elapsed?(100)
  end

  def test_manual_construction
    timestamp = Timestamp.new(milliseconds: 5000)

    assert_equal 5000, timestamp.milliseconds
  end

  def test_elapsed_with_manual_timestamp
    # Create a timestamp 200ms in the past
    past_ms = (Time.now.to_f * 1000).to_i - 200
    timestamp = Timestamp.new(milliseconds: past_ms)

    assert timestamp.elapsed?(100)
    refute timestamp.elapsed?(300)
  end

  def test_milliseconds_precision
    # Verify we're getting millisecond precision, not seconds
    timestamp = Timestamp.now

    # Should be well over 1_000_000 (since epoch in ms)
    assert_operator timestamp.milliseconds, :>, 1_000_000_000_000
  end

  def test_timestamp_is_data_class
    assert Timestamp < Data
  end

  def test_timestamps_with_same_value_are_equal
    ts1 = Timestamp.new(milliseconds: 12345)
    ts2 = Timestamp.new(milliseconds: 12345)

    assert_equal ts1, ts2
  end

  def test_timestamps_with_different_values_are_not_equal
    ts1 = Timestamp.new(milliseconds: 12345)
    ts2 = Timestamp.new(milliseconds: 12346)

    refute_equal ts1, ts2
  end
end
