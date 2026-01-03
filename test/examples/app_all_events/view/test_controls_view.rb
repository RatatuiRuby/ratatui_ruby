# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../../examples/app_all_events/view/controls_view"
require_relative "../../../../examples/app_all_events/model/app_model"

class TestControlsView < Minitest::Test
  def setup
    @tui = RatatuiRuby::TUI.new
    @frame = RatatuiRuby::TestHelper::MockFrame.new
    @area = RatatuiRuby::TestHelper::StubRect.new
  end

  def build_model(focused: true)
    AppModel.initial.with(focused:)
  end

  def test_renders_single_widget
    model = build_model
    View::Controls.new.call(model, @tui, @frame, @area)

    assert_equal 1, @frame.rendered_widgets.length
  end

  def test_block_has_controls_title
    model = build_model
    View::Controls.new.call(model, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    assert_equal "Controls", widget.block.title
  end

  def test_block_has_all_borders
    model = build_model
    View::Controls.new.call(model, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    assert_equal [:all], widget.block.borders
  end

  def test_contains_q_quit_text
    model = build_model
    View::Controls.new.call(model, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    text_content = extract_text_content(widget)
    assert_includes text_content, "q"
    assert_includes text_content, ": Quit"
  end

  def test_contains_ctrl_c_quit_text
    model = build_model
    View::Controls.new.call(model, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    text_content = extract_text_content(widget)
    assert_includes text_content, "Ctrl+C"
    assert_includes text_content, ": Quit"
  end

  def test_hotkey_style_applied_to_q
    model = build_model
    View::Controls.new.call(model, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    first_span = widget.text.first.spans.first
    assert_equal "q", first_span.content
    assert_includes first_span.style.modifiers, :bold
    assert_includes first_span.style.modifiers, :underlined
  end

  def test_hotkey_style_applied_to_ctrl_c
    model = build_model
    View::Controls.new.call(model, @tui, @frame, @area)

    widget = @frame.rendered_widgets.first[:widget]
    ctrl_c_span = widget.text.first.spans[2]
    assert_equal "Ctrl+C", ctrl_c_span.content
    assert_includes ctrl_c_span.style.modifiers, :bold
    assert_includes ctrl_c_span.style.modifiers, :underlined
  end

  def test_passes_area_to_frame
    model = build_model
    View::Controls.new.call(model, @tui, @frame, @area)

    rendered = @frame.rendered_widgets.first
    assert_equal @area, rendered[:area]
  end

  private def extract_text_content(widget)
    widget.text.flat_map { |line| line.spans.map(&:content) }.join
  end
end
