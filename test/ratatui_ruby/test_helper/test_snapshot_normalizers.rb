# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

class TestSnapshotNormalizers < Minitest::Test
  include RatatuiRuby::TestHelper

  def test_normalizer_applies_to_plain_snapshot
    with_test_terminal(30, 1) do
      RatatuiRuby.draw do |f|
        f.render_widget(RatatuiRuby::Widgets::Paragraph.new(text: "PID: 12345"), f.area)
      end

      snapshot_dir = Dir.mktmpdir
      assert_plain_snapshot("normalizer_plain", snapshot_dir:)

      # Verify the snapshot file contains the normalized text, not the raw PID
      content = File.read(File.join(snapshot_dir, "normalizer_plain.txt"))
      assert_includes content, "PID: XXXXX"
      refute_includes content, "PID: 12345"
    ensure
      FileUtils.remove_entry(snapshot_dir)
    end
  end

  def test_normalizer_applies_to_rich_snapshot
    with_test_terminal(30, 1) do
      RatatuiRuby.draw do |f|
        f.render_widget(RatatuiRuby::Widgets::Paragraph.new(text: "PID: 12345"), f.area)
      end

      snapshot_dir = Dir.mktmpdir
      assert_rich_snapshot("normalizer_rich", snapshot_dir:)

      content = File.read(File.join(snapshot_dir, "normalizer_rich.ansi"))
      assert_includes content, "PID: XXXXX"
      refute_includes content, "PID: 12345"
    ensure
      FileUtils.remove_entry(snapshot_dir)
    end
  end

  private def normalize_snapshots(lines)
    lines.map { |l| l.gsub(/PID: \d+/, "PID: XXXXX") }
  end
end
