# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "minitest/autorun"
require_relative "../../../examples/app_all_events/view_state"
require_relative "../../../examples/app_all_events/model/events"

class TestViewState < Minitest::Test
  def setup
    @events = Events.new
    @tui = MockTui.new
  end

  def test_build_creates_view_state_instance
    state = ViewState.build(@events, true, @tui, nil)

    assert_instance_of ViewState, state
  end

  def test_build_stores_events
    state = ViewState.build(@events, true, @tui, nil)

    assert_equal @events, state.events
  end

  def test_build_stores_focused_true
    state = ViewState.build(@events, true, @tui, nil)

    assert state.focused
  end

  def test_build_stores_focused_false
    state = ViewState.build(@events, false, @tui, nil)

    refute state.focused
  end

  def test_border_color_is_green_when_focused
    state = ViewState.build(@events, true, @tui, nil)

    assert_equal :green, state.border_color
  end

  def test_border_color_is_gray_when_not_focused
    state = ViewState.build(@events, false, @tui, nil)

    assert_equal :gray, state.border_color
  end

  def test_hotkey_style_is_set
    state = ViewState.build(@events, true, @tui, nil)

    refute_nil state.hotkey_style
    assert_instance_of MockStyle, state.hotkey_style
  end

  def test_hotkey_style_has_bold_and_underlined_modifiers
    state = ViewState.build(@events, true, @tui, nil)

    assert_includes state.hotkey_style.modifiers, :bold
    assert_includes state.hotkey_style.modifiers, :underlined
  end

  def test_dimmed_style_is_set
    state = ViewState.build(@events, true, @tui, nil)

    refute_nil state.dimmed_style
    assert_equal :dark_gray, state.dimmed_style.fg
  end

  def test_lit_style_is_set
    state = ViewState.build(@events, true, @tui, nil)

    refute_nil state.lit_style
    assert_equal :green, state.lit_style.fg
    assert_includes state.lit_style.modifiers, :bold
  end

  def test_area_is_nil
    state = ViewState.build(@events, true, @tui, nil)

    assert_nil state.area
  end

  def test_fourth_parameter_is_ignored
    # The resize_sub_counter parameter is reserved for future use
    state = ViewState.build(@events, true, @tui, "ignored value")

    # Should still build successfully
    assert_instance_of ViewState, state
  end

  def test_view_state_is_data_class
    assert ViewState < Data
  end

  def test_all_fields_accessible
    state = ViewState.build(@events, true, @tui, nil)

    # Access all fields to ensure they're defined
    state.events
    state.focused
    state.hotkey_style
    state.dimmed_style
    state.lit_style
    state.border_color
    state.area
  end

  # Mock classes

  class MockStyle
    attr_reader :fg, :modifiers

    def initialize(fg: nil, modifiers: [])
      @fg = fg
      @modifiers = modifiers
    end
  end

  class MockTui
    def style(fg: nil, modifiers: [])
      MockStyle.new(fg:, modifiers:)
    end
  end
end
