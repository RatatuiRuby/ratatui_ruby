# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

# Timeout Demo: Non-Blocking Event Polling
#
# This demo shows how to use poll_event with a timeout for game loops
# and animation systems that need to update at a fixed frame rate
# regardless of user input.
#
# Run: bundle exec ruby examples/timeout_demo.rb
#
# Expected behavior:
# - "Tick..." prints every 100ms continuously
# - Pressing a key prints "Key Pressed: [key]" immediately
# - Press 'q' to quit

require "bundler/setup"
require "ratatui_ruby"

puts "Timeout Demo - Press 'q' to quit"
puts "Watch: continuous ticks with responsive key handling"
puts

tick_count = 0
running = true

while running
  # Poll with 100ms timeout (~10 FPS tick rate)
  event = RatatuiRuby.poll_event(timeout: 0.1)

  if event.none?
    # No input, just tick
    tick_count += 1
    puts "Tick #{tick_count}..."
  elsif event.key?
    puts "Key Pressed: #{event.code}"
    running = false if event.code == "q"
  end
end

puts "\nGoodbye!"
