# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "preview_timing"
require_relative "system_appearance"

class SafetyConfirmation
  def initialize(stale_count, total_count)
    @stale_count = stale_count
    @total_count = total_count
  end

  def request
    print_warning
    wait_for_user
  end

  private def print_warning
    unchanged_count = @total_count - @stale_count
    puts "\n#{'=' * 60}"
    puts "  📸  NATIVE TERMINAL CAPTURE  📸"
    puts "=" * 60
    puts "This task will:"
    puts "  1. Take control of your mouse/keyboard focus"
    puts "  2. Rapidly open and close Terminal windows"
    puts "  3. Capture #{@stale_count} screenshots (#{unchanged_count} unchanged)"
    puts
    puts "Before starting, be sure Terminal.app has the following permissions"
    puts "in System Settings.app -> Privacy & Security:"
    puts "  - Screen & System Audio Recording"
    puts "  - Automation -> System Events"
    puts
    puts "⚠️  PLEASE DO NOT TOUCH YOUR COMPUTER WHILE THIS RUNS."
    min_time = (@stale_count * PreviewTiming.total).to_i
    max_time = (@stale_count * (PreviewTiming.total + PreviewTiming.close_delay)).to_i
    puts "   (Estimated time: #{min_time}-#{max_time} seconds)"
    puts
  end

  private def wait_for_user
    loop do
      print "Continue? [Y/n]: "
      response = $stdin.gets.strip.downcase

      if response.empty? || response == "y"
        return if SystemAppearance.dark?
        puts "⚠️  Dark Mode is not enabled. Please enable it in System Settings or Control Center before proceeding."
        puts
      elsif response == "n"
        abort "Cancelled."
      end
    end
  end
end
