# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
$LOAD_PATH.unshift File.expand_path(__dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "../../../examples/app_color_picker/app"

class TestAppColorPicker < Minitest::Test
  include RatatuiRuby::TestHelper

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      app = AppColorPicker.new
      app.run

      assert_snapshot("initial_render")
      assert_rich_snapshot("initial_render")
    end
  end

  def test_cursor_position
    with_test_terminal do
      inject_key(:q)
      app = AppColorPicker.new
      app.run

      # Default input is "#F96302" (7 chars)
      # Box border is 1 char wide.
      # Expected X = 1 (border) + 7 (text) = 8
      # Expected Y = 1 (border + line 0) = 1
      assert_equal({ x: 8, y: 1 }, cursor_position)
    end
  end

  def test_input_red
    with_test_terminal do
      inject_key(:backspace, :backspace, :backspace, :backspace, :backspace, :backspace, :backspace)
      inject_key("#", "f", "f", "0", "0", "0", "0", :enter)
      inject_key(:q)
      app = AppColorPicker.new
      app.run

      assert_snapshot("after_red_input")
      assert_rich_snapshot("after_red_input")
    end
  end

  def test_paste_input
    with_test_terminal do
      inject_key(:backspace, :backspace, :backspace, :backspace, :backspace, :backspace, :backspace)
      inject_event(RatatuiRuby::Event::Paste.new(content: "#ff0000"))
      inject_key(:q)
      app = AppColorPicker.new
      app.run

      assert_snapshot("after_paste")
      assert_rich_snapshot("after_paste")
    end
  end

  def test_click_hex_opens_copy_dialog
    stub_popen = proc do |*_args, **_kwargs, &block|
      mock_io = Object.new
      def mock_io.write(_); end
      block.call(mock_io)
    end
    IO.stub :popen, stub_popen do
      with_test_terminal do
        inject_key(:backspace, :backspace, :backspace, :backspace, :backspace, :backspace, :backspace)
        inject_key("#", "f", "f", "0", "0", "0", "0", :enter)
        inject_event(RatatuiRuby::Event::Mouse.new(kind: "down", button: "left", x: 30, y: 11))
        inject_key(:q)
        app = AppColorPicker.new
        app.run

        assert_snapshot("copy_dialog")
        assert_rich_snapshot("copy_dialog")
      end
    end
  end

  def test_copy_dialog_confirm
    stub_popen = proc do |*_args, **_kwargs, &block|
      mock_io = Object.new
      def mock_io.write(_); end
      block.call(mock_io)
    end
    IO.stub :popen, stub_popen do
      with_test_terminal do
        inject_key(:backspace, :backspace, :backspace, :backspace, :backspace, :backspace, :backspace)
        inject_key("#", "f", "f", "0", "0", "0", "0", :enter)
        inject_event(RatatuiRuby::Event::Mouse.new(kind: "down", button: "left", x: 30, y: 11))
        inject_key(:y)
        inject_key(:q)
        app = AppColorPicker.new
        app.run

        assert_snapshot("after_copy_confirm")
        assert_rich_snapshot("after_copy_confirm")
      end
    end
  end
end
