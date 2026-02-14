# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

class TestSnapshotNormalizerComposition < Minitest::Test
  include RatatuiRuby::TestHelper

  def test_multiple_normalizers_compose_in_order
    with_test_terminal(30, 1) do
      RatatuiRuby.draw do |f|
        f.render_widget(RatatuiRuby::Widgets::Paragraph.new(text: "PID: 99 at 12:30"), f.area)
      end

      snapshot_dir = Dir.mktmpdir
      assert_plain_snapshot("composed", snapshot_dir:)

      content = File.read(File.join(snapshot_dir, "composed.txt"))
      assert_includes content, "PID: XXXXX"
      assert_includes content, "XX:XX"
      refute_includes content, "PID: 99"
      refute_includes content, "12:30"
    ensure
      FileUtils.remove_entry(snapshot_dir)
    end
  end

  def test_block_composes_with_hook
    with_test_terminal(30, 1) do
      RatatuiRuby.draw do |f|
        f.render_widget(RatatuiRuby::Widgets::Paragraph.new(text: "PID: 42 v2.1"), f.area)
      end

      snapshot_dir = Dir.mktmpdir
      # Hook masks PID; block masks version
      assert_plain_snapshot("hook_plus_block", snapshot_dir:) do |lines|
        lines.map { |l| l.gsub(/v\d+\.\d+/, "vX.X") }
      end

      content = File.read(File.join(snapshot_dir, "hook_plus_block.txt"))
      assert_includes content, "PID: XXXXX", "Hook normalizer should have run"
      assert_includes content, "vX.X", "Block normalizer should have run"
      refute_includes content, "PID: 42"
      refute_includes content, "v2.1"
    ensure
      FileUtils.remove_entry(snapshot_dir)
    end
  end

  private def normalize_snapshots(lines)
    lines
      .map { |l| l.gsub(/PID: \d+/, "PID: XXXXX") }
      .map { |l| l.gsub(/\d{2}:\d{2}/, "XX:XX") }
  end
end
