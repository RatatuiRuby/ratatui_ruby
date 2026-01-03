# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestTestHelper < Minitest::Test
  include RatatuiRuby::TestHelper

  def test_assert_color
    with_test_terminal(20, 3) do
      # Render red text
      style = RatatuiRuby::Style.new(fg: :red)
      widget = RatatuiRuby::Block.new(borders: [:all], style:)
      RatatuiRuby.draw { |f| f.render_widget(widget, f.area) }

      # Should pass
      assert_color(:red, x: 0, y: 0)

      # Should fail (expecting blue)
      assert_raises(Minitest::Assertion) do
        assert_color(:blue, x: 0, y: 0)
      end
    end
  end

  def test_assert_color_indexed
    with_test_terminal(20, 3) do
      style = RatatuiRuby::Style.new(fg: 5)
      widget = RatatuiRuby::Block.new(borders: [:all], style:)
      RatatuiRuby.draw { |f| f.render_widget(widget, f.area) }

      # Should pass for Integer 5
      assert_color(5, x: 0, y: 0)

      # Should pass for Symbol :indexed_5
      assert_color(:indexed_5, x: 0, y: 0)
    end
  end

  def test_assert_area_style
    with_test_terminal(20, 3) do
      # Render blue background everywhere
      style = RatatuiRuby::Style.new(bg: :blue)
      widget = RatatuiRuby::Block.new(borders: [:all], style:)
      RatatuiRuby.draw { |f| f.render_widget(widget, f.area) }

      header_area = RatatuiRuby::Rect.new(x: 0, y: 0, width: 20, height: 1)
      assert_area_style(header_area, bg: :blue)

      # Should fail if we check for red
      assert_raises(Minitest::Assertion) do
        assert_area_style(header_area, bg: :red)
      end
    end
  end

  def test_assert_rich_snapshot
    with_test_terminal(20, 3) do
      # A colorful scene
      style = RatatuiRuby::Style.new(fg: :red, bg: :blue, modifiers: [:bold])
      widget = RatatuiRuby::Paragraph.new(text: "Hi", block: RatatuiRuby::Block.new(borders: [:all], style:))
      RatatuiRuby.draw { |f| f.render_widget(widget, f.area) }

      # This should create snapshots/test_rich_snapshot.ansi on first run
      ENV["UPDATE_SNAPSHOTS"] = "1"
      assert_rich_snapshot("test_rich_snapshot")
      ENV.delete("UPDATE_SNAPSHOTS")

      # Second run should pass against file
      assert_rich_snapshot("test_rich_snapshot")
    end
  end

  def test_assert_rich_snapshot_with_normalization
    with_test_terminal(20, 3) do
      # Render text with a changing value (like a timestamp or ID)
      # We simulate this by drawing something "Random: 123" then in the assertion masking it
      RatatuiRuby.draw do |f|
        f.render_widget(RatatuiRuby::Paragraph.new(text: "Random ID: 12345"), f.area)
      end

      # Create snapshot with masked value
      ENV["UPDATE_SNAPSHOTS"] = "1"
      assert_rich_snapshot("test_rich_snapshot_normalized") do |lines|
        lines.map { |l| l.gsub(/ID: \d+/, "ID: XXXXX") }
      end
      ENV.delete("UPDATE_SNAPSHOTS")

      # Now change the rendered value
      RatatuiRuby.draw do |f|
        f.render_widget(RatatuiRuby::Paragraph.new(text: "Random ID: 67890"), f.area)
      end

      # Assertion should still pass because of normalization
      assert_rich_snapshot("test_rich_snapshot_normalized") do |lines|
        lines.map { |l| l.gsub(/ID: \d+/, "ID: XXXXX") }
      end
    end
  end
end
