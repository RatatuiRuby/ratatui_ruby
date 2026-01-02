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

      content = buffer_content.join("\n")
      assert_includes content, "Color Input"
      assert_includes content, "Main"
    end
  end

  def test_renders_input_section
    with_test_terminal do
      inject_key(:q)
      app = AppColorPicker.new
      app.run

      content = buffer_content.join("\n")
      assert_includes content, "Color Input"
    end
  end

  def test_cursor_position_is_set
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

  def test_renders_controls
    with_test_terminal do
      inject_key(:q)
      app = AppColorPicker.new
      app.run

      content = buffer_content.join("\n")
      assert_includes content, "Controls"
    end
  end

  def test_color_grid_renders_with_valid_color
    with_test_terminal do
      inject_key(:backspace, :backspace, :backspace, :backspace, :backspace, :backspace, :backspace)
      inject_key("#", "f", "f", "0", "0", "0", "0", :enter)
      inject_key(:q)
      app = AppColorPicker.new
      app.run

      content = buffer_content.join("\n")
      assert_includes content, "Main"
      assert_includes content, "Shade"
      assert_includes content, "Tint"
      assert_includes content, "Comp"
      assert_includes content, "#FF0000"
    end
  end

  def test_esc_quits_application
    with_test_terminal do
      inject_key(:esc)
      app = AppColorPicker.new
      app.run

      content = buffer_content.join("\n")
      assert_includes content, "Color Input"
    end
  end

  def test_paste_input_color
    with_test_terminal do
      inject_key(:backspace, :backspace, :backspace, :backspace, :backspace, :backspace, :backspace)
      inject_event(RatatuiRuby::Event::Paste.new(content: "#ff0000"))
      inject_key(:q)
      app = AppColorPicker.new
      app.run

      content = buffer_content.join("\n")
      assert_includes content, "#FF0000"
    end
  end

  def test_hex_codes_display_uppercase
    with_test_terminal do
      inject_key(:backspace, :backspace, :backspace, :backspace, :backspace, :backspace, :backspace)
      inject_key("#", "f", "f", "0", "0", "0", "0", :enter)
      inject_key(:q)
      app = AppColorPicker.new
      app.run

      content = buffer_content.join("\n")
      assert_includes content, "HEX: #FF0000"
      assert_includes content, "#FF0000"
    end
  end

  def test_click_hex_opens_copy_dialog
    stub_popen = proc do |*args, **kwargs, &block|
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

        content = buffer_content.join("\n")
        assert_includes content, "Copy to Clipboard"
        assert_includes content, "#FF0000"
      end
    end
  end

  def test_copy_dialog_yes_copies_to_clipboard
    stub_popen = proc do |*args, **kwargs, &block|
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

        content = buffer_content.join("\n")
        assert_includes content, "Copied!"
      end
    end
  end

  def test_copy_dialog_navigation
    with_test_terminal do
      inject_key(:backspace, :backspace, :backspace, :backspace, :backspace, :backspace, :backspace)
      inject_key("#", "f", "f", "0", "0", "0", "0", :enter)
      inject_event(RatatuiRuby::Event::Mouse.new(kind: "down", button: "left", x: 30, y: 11))
      inject_key(:right)
      inject_key(:enter)
      inject_key(:q)
      app = AppColorPicker.new
      app.run

      content = buffer_content.join("\n")
      refute_includes content, "Copy to Clipboard"
    end
  end
end
