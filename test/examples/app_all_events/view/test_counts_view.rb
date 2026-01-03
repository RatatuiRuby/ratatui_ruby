# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../../examples/app_all_events/app"
require_relative "../../../../examples/app_all_events/view/counts_view"
require_relative "../../../../examples/app_all_events/model/app_model"
require_relative "../../../../examples/app_all_events/update"

class TestCountsView < Minitest::Test
  def setup
    @tui = RatatuiRuby::TUI.new
    @frame = RatatuiRuby::TestHelper::MockFrame.new
    @area = RatatuiRuby::TestHelper::StubRect.new
  end

  def build_model(focused: true)
    AppModel.initial.with(focused:)
  end

  def record_event(model, event)
    msg = Msg::Input.new(event:)
    Update.call(msg, model)
  end

  def test_renders_single_widget
    model = build_model
    View::Counts.new.call(model, @tui, @frame, @area)

    assert_equal 1, @frame.rendered_widgets.length
  end

  def test_block_has_event_counts_title
    model = build_model
    View::Counts.new.call(model, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    assert_equal "Event Counts", widget.block.title
  end

  def test_renders_all_event_types
    model = build_model
    View::Counts.new.call(model, @tui, @frame, @area)

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
    model = build_model
    View::Counts.new.call(model, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    text_content = extract_all_content(widget)

    # Ensure capitalized forms exist
    assert_includes text_content, "Key:"
    refute_includes text_content, "key:"
  end

  def test_displays_zero_counts_initially
    model = build_model
    View::Counts.new.call(model, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    text_content = extract_all_content(widget)
    # Find spans with count values
    count_spans = widget.text.flat_map(&:spans).select { |s| s.content.strip =~ /^\d+$/ }
    all_zeros = count_spans.all? { |s| s.content.strip == "0" }
    assert all_zeros, "Expected all counts to be 0 initially"

    # Ensure sub-counts are visible
    assert_includes text_content, "Standard:"
    assert_includes text_content, "Down:"
    assert_includes text_content, "Gained:"
  end

  def test_displays_incremented_counts
    model = build_model
    model = record_event(model, RatatuiRuby::Event::Key.new(code: "a"))
    model = record_event(model, RatatuiRuby::Event::Key.new(code: "b"))
    model = record_event(model, RatatuiRuby::Event::Mouse.new(kind: "down", button: "left", x: 0, y: 0))

    View::Counts.new.call(model, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    text_content = extract_all_content(widget)

    assert_includes text_content, "Key: 2"
    assert_includes text_content, "Mouse: 1"
  end

  def test_renders_mouse_sub_counts
    model = build_model
    model = record_event(model, RatatuiRuby::Event::Mouse.new(kind: "down", button: "left", x: 0, y: 0))

    View::Counts.new.call(model, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    text_content = extract_all_content(widget)

    assert_includes text_content, "Down: 1"
  end

  def test_renders_key_sub_counts
    model = build_model
    model = record_event(model, RatatuiRuby::Event::Key.new(code: "a"))

    View::Counts.new.call(model, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    text_content = extract_all_content(widget)

    assert_includes text_content, "Standard: 1"
  end

  def test_renders_focus_sub_counts
    model = build_model
    model = Update.call(Msg::Focus.new(gained: true), model)
    model = Update.call(Msg::Focus.new(gained: false), model)

    View::Counts.new.call(model, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    text_content = extract_all_content(widget)

    assert_includes text_content, "Gained: 1"
    assert_includes text_content, "Lost: 1"
  end

  def test_lit_style_when_event_type_is_lit
    model = build_model
    model = record_event(model, RatatuiRuby::Event::Key.new(code: "a"))

    View::Counts.new.call(model, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    key_line = widget.text.find { |line| line.spans.first.content.include?("Key:") }
    key_label_style = key_line.spans.first.style

    # lit_style has fg: :green and bold
    assert_equal :green, key_label_style.fg
    assert_includes key_label_style.modifiers, :bold
  end

  def test_border_color_matches_focus_state
    focused_model = build_model(focused: true)
    View::Counts.new.call(focused_model, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    assert_equal :green, widget.block.border_style.fg

    @frame = RatatuiRuby::TestHelper::MockFrame.new
    unfocused_model = build_model(focused: false)
    View::Counts.new.call(unfocused_model, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    assert_equal :gray, widget.block.border_style.fg
  end

  private def extract_all_content(widget)
    widget.text.flat_map { |line| line.spans.map(&:content) }.join
  end
end
