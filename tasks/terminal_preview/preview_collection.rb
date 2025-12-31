# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "fileutils"
require_relative "example_app"
require_relative "app_screenshot"
require_relative "crash_report"
require_relative "preview_timing"
require_relative "safety_confirmation"
require_relative "saved_screenshot"

class PreviewCollection
  def initialize(output_dir)
    @output_dir = output_dir
  end

  def generate
    abort "Error: This task requires macOS." unless RUBY_PLATFORM.match?(/darwin/)

    apps = ExampleApp.all
    stale_count = count_stale_apps(apps)

    if stale_count.zero?
      puts "\n✨ All #{apps.count} screenshots are up to date."
      return
    end

    SafetyConfirmation.new(stale_count, apps.count).request

    puts "\nHere we go!"
    failures = apps.count { |app| !capture_app(app) }

    if failures.zero?
      puts "\n✨ All captures complete. Check doc/images/."
    else
      abort "\n❌ #{failures} capture(s) failed."
    end
  end

  private def count_stale_apps(apps)
    apps.count { |app| SavedScreenshot.for(app, @output_dir).stale? }
  end

  private def capture_app(app)
    saved = SavedScreenshot.for(app, @output_dir)

    if saved.stale?
      success = AppScreenshot.new(app, saved.path).capture
      sleep PreviewTiming.between_captures
      success
    else
      puts "  ⏭️  #{app} (unchanged)"
      true
    end
  end
end
