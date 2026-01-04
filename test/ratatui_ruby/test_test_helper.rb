# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestTestHelper < Minitest::Test
  include RatatuiRuby::TestHelper

  def test_assert_color
    with_test_terminal(20, 3) do
      # Render red text
      style = RatatuiRuby::Style::Style.new(fg: :red)
      widget = RatatuiRuby::Widgets::Block.new(borders: [:all], style:)
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
      style = RatatuiRuby::Style::Style.new(fg: 5)
      widget = RatatuiRuby::Widgets::Block.new(borders: [:all], style:)
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
      style = RatatuiRuby::Style::Style.new(bg: :blue)
      widget = RatatuiRuby::Widgets::Block.new(borders: [:all], style:)
      RatatuiRuby.draw { |f| f.render_widget(widget, f.area) }

      header_area = RatatuiRuby::Layout::Rect.new(x: 0, y: 0, width: 20, height: 1)
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
      style = RatatuiRuby::Style::Style.new(fg: :red, bg: :blue, modifiers: [:bold])
      widget = RatatuiRuby::Widgets::Paragraph.new(text: "Hi", block: RatatuiRuby::Widgets::Block.new(borders: [:all], style:))
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
        f.render_widget(RatatuiRuby::Widgets::Paragraph.new(text: "Random ID: 12345"), f.area)
      end

      # Create snapshot with masked value
      ENV["UPDATE_SNAPSHOTS"] = "1"
      assert_rich_snapshot("test_rich_snapshot_normalized") do |lines|
        lines.map { |l| l.gsub(/ID: \d+/, "ID: XXXXX") }
      end
      ENV.delete("UPDATE_SNAPSHOTS")

      # Now change the rendered value
      RatatuiRuby.draw do |f|
        f.render_widget(RatatuiRuby::Widgets::Paragraph.new(text: "Random ID: 67890"), f.area)
      end

      # Assertion should still pass because of normalization
      assert_rich_snapshot("test_rich_snapshot_normalized") do |lines|
        lines.map { |l| l.gsub(/ID: \d+/, "ID: XXXXX") }
      end
    end
  end

  def test_update_snapshots_updates_stale_file
    # Verify that UPDATE_SNAPSHOTS=1 properly updates a pre-existing snapshot
    # with outdated content. This is the scenario that broke the calendar demo tests.
    Dir.mktmpdir do |tmpdir|
      snapshot_path = File.join(tmpdir, "stale_snapshot.txt")

      # Create a stale snapshot with old content
      File.write(snapshot_path, "OLD CONTENT LINE 1\nOLD CONTENT LINE 2\n")

      with_test_terminal(20, 2) do
        # Render new content that differs from the stale snapshot
        RatatuiRuby.draw do |f|
          f.render_widget(RatatuiRuby::Widgets::Paragraph.new(text: "NEW CONTENT"), f.area)
        end

        # With UPDATE_SNAPSHOTS=1, the assertion should:
        # 1. Overwrite the stale file with new content
        # 2. Pass (not fail) because expected now equals actual
        ENV["UPDATE_SNAPSHOTS"] = "1"
        begin
          assert_screen_matches(snapshot_path)
        ensure
          ENV.delete("UPDATE_SNAPSHOTS")
        end

        # Verify the file was actually updated
        updated_content = File.read(snapshot_path)
        assert_includes updated_content, "NEW CONTENT",
          "Snapshot file should contain new content after UPDATE_SNAPSHOTS"
        refute_includes updated_content, "OLD CONTENT",
          "Snapshot file should not contain old content after UPDATE_SNAPSHOTS"
      end
    end
  end

  def test_render_rich_buffer_returns_ansi_string
    with_test_terminal(20, 3) do
      style = RatatuiRuby::Style::Style.new(fg: :red, modifiers: [:bold])
      widget = RatatuiRuby::Widgets::Paragraph.new(
        text: "Hi",
        block: RatatuiRuby::Widgets::Block.new(borders: [:all], style:)
      )
      RatatuiRuby.draw { |f| f.render_widget(widget, f.area) }

      ansi_output = render_rich_buffer

      # Should be a string with ANSI escape codes
      assert_kind_of String, ansi_output
      assert_includes ansi_output, "\e[", "Output should contain ANSI escape codes"
      assert_includes ansi_output, "Hi", "Output should contain rendered text"
    end
  end

  def test_render_rich_buffer_includes_colors
    with_test_terminal(20, 3) do
      style = RatatuiRuby::Style::Style.new(fg: :red)
      widget = RatatuiRuby::Widgets::Block.new(borders: [:all], style:)
      RatatuiRuby.draw { |f| f.render_widget(widget, f.area) }

      ansi_output = render_rich_buffer

      # Red foreground uses ANSI code 31
      assert_includes ansi_output, "\e[31m", "Output should contain red foreground code"
    end
  end
end
