# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

class SafetyConfirmation
  def initialize(stale_count, total_count)
    @stale_count = stale_count
    @total_count = total_count
  end

  def request
    print_warning
    wait_for_user
  end

  private

  def print_warning
    unchanged_count = @total_count - @stale_count
    puts "\n" + "=" * 60
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
    puts "   (Estimated time: ~#{(@stale_count * 1.5).to_i} seconds)"
    puts
  end

  def wait_for_user
    loop do
      print "Continue? [Y/n]: "
      response = $stdin.gets.strip.downcase
      return if response.empty? || response == "y"
      abort "Cancelled." if response == "n"
    end
  end
end
