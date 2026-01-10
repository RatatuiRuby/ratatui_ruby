# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: MIT-0
#++

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)

require "ratatui_ruby"

##
# Interactive demonstration of RatatuiRuby debugging features.
#
# This example lets you trigger each debugging feature with a hotkey to verify
# your setup works before encountering a real bug.
#
# == Hotkeys
#
# [d] Enable debug_mode! — Shows the debug socket path for remote attachment
# [p] Trigger test_panic! — Deliberately crashes to verify Rust backtrace visibility
# [t] Cause TypeError — Passes wrong type to widget factory to show Rust stack frames
# [b] Show backtrace status — Displays current debug configuration
# [q] Quit
#
# == Usage
#
#   # Normal mode (no backtraces):
#   ruby examples/verify_debugging_usage/app.rb
#
#   # With Rust backtraces only:
#   RUST_BACKTRACE=1 ruby examples/verify_debugging_usage/app.rb
#
#   # Full debug mode (stops at startup for debugger attachment):
#   RR_DEBUG=1 ruby examples/verify_debugging_usage/app.rb
#
# == Remote Debugging
#
# When you press [d] to enable debug_mode!, the app continues running but
# prints a socket path. From another terminal:
#
#   rdbg --attach
#
# This gives you a full debugger REPL while the TUI keeps running.
class VerifyDebuggingUsage
  def initialize
    @status_message = "Press a key to test debugging features"
    @show_debug_info = false
    @quit = false

    # If debug mode was enabled via RR_DEBUG=1 at startup, capture the socket path
    if RatatuiRuby::Debug.enabled?
      @socket_path = begin
        ::DEBUGGER__.create_unix_domain_socket_name
      rescue NameError
        nil
      end
      @show_debug_info = true
      @status_message = "RR_DEBUG=1 detected — debug mode active"
    end
  end

  def run
    RatatuiRuby.run do |tui|
      @tui = tui
      @loop_count = 0

      loop do
        @loop_count += 1

        # 🎯 Breakpoint every 250 loops. Try: p @status_message
        if RatatuiRuby::Debug.enabled? && (@loop_count % 250).zero?
          you_found_me = "🎉 You found me! Loop ##{@loop_count}"
          # rubocop:disable Lint/Debugger
          debugger
          # rubocop:enable Lint/Debugger
          _ = you_found_me # Suppress unused variable warning
        end

        render
        break if @quit || handle_input == :quit
      end
    end
  end

  private def render
    @tui.draw do |frame|
      constraints = [
        @tui.constraint_length(3),  # Status
        @tui.constraint_length(5),  # Config
        @tui.constraint_length(6),  # Actions
      ]

      if @show_debug_info
        constraints << @tui.constraint_length(6) # Debug info
      end

      constraints << @tui.constraint_fill(1)    # Spacer
      constraints << @tui.constraint_length(3)  # Help

      chunks = @tui.layout_split(frame.area, direction: :vertical, constraints:)

      idx = 0
      render_status(frame, chunks[idx])
      idx += 1
      render_config(frame, chunks[idx])
      idx += 1
      render_actions(frame, chunks[idx])
      idx += 1

      if @show_debug_info
        render_debug_info(frame, chunks[idx])
        idx += 1
      end

      # Skip spacer
      idx += 1
      render_help(frame, chunks[idx])
    end
  end

  private def render_status(frame, area)
    frame.render_widget(
      @tui.paragraph(
        text: @status_message,
        alignment: :center,
        block: @tui.block(
          title: " Status ",
          title_alignment: :center,
          borders: [:all],
          border_style: { fg: :yellow }
        )
      ),
      area
    )
  end

  private def render_config(frame, area)
    config_lines = [
      "Rust Backtraces:  #{flag(RatatuiRuby::Debug.rust_backtrace_enabled?)}",
      "Full Debug Mode:  #{flag(RatatuiRuby::Debug.enabled?)}",
      "Remote Debugging: #{remote_mode_description}",
    ].join("\n")

    frame.render_widget(
      @tui.paragraph(
        text: config_lines,
        block: @tui.block(
          title: " Current Debug Configuration ",
          borders: [:all],
          border_style: { fg: :cyan }
        )
      ),
      area
    )
  end

  private def render_actions(frame, area)
    actions_lines = [
      "[d] Enable debug_mode! and show socket info",
      "[p] Trigger test_panic! to verify backtrace visibility",
      "[t] Cause TypeError (pass wrong type to widget)",
      "[b] Refresh debug status",
    ].join("\n")

    frame.render_widget(
      @tui.paragraph(
        text: actions_lines,
        block: @tui.block(
          title: " Available Actions ",
          borders: [:all],
          border_style: { fg: :green }
        )
      ),
      area
    )
  end

  private def render_debug_info(frame, area)
    socket_display = @socket_path || "(socket not available)"
    info_lines = [
      "Socket: #{socket_display}",
      "Attach: rdbg --attach",
      "Hint: type 'continue' if you see SIGURG",
    ]

    frame.render_widget(
      @tui.paragraph(
        text: info_lines.join("\n"),
        block: @tui.block(
          title: " Remote Debugging ",
          borders: [:all],
          border_style: { fg: :magenta }
        )
      ),
      area
    )
  end

  private def render_help(frame, area)
    frame.render_widget(
      @tui.paragraph(
        text: "[d] debug_mode!  [p] test_panic!  [t] TypeError  [b] status  [q] quit",
        alignment: :center,
        block: @tui.block(
          borders: [:all],
          border_style: { fg: :dark_gray }
        )
      ),
      area
    )
  end

  private def flag(value)
    value ? "✓ enabled" : "✗ disabled"
  end

  private def remote_mode_description
    case RatatuiRuby::Debug.remote_debugging_mode
    when :open
      attached = debugger_attached? ? " — ATTACHED" : " — waiting"
      "✓ open#{attached}"
    when :open_nonstop
      attached = debugger_attached? ? " — ATTACHED" : ""
      "✓ open_nonstop#{attached}"
    else
      "✗ not configured"
    end
  end

  # ☣️  FRAGILE: This pokes at debug gem internals.
  #
  # Private instance variables can change between gem versions. This code
  # may silently break. We accept that risk here because this showcase
  # exists specifically to demonstrate debugger attachment status.
  #
  # For production apps, checking Debug.enabled? is sufficient — knowing
  # whether a client has attached rarely matters.
  private def debugger_attached?
    return false unless defined?(::DEBUGGER__::SESSION)

    ui = ::DEBUGGER__::SESSION.instance_variable_get(:@ui)
    return false unless ui

    # The @sock instance variable is set when a client connects
    sock = ui.instance_variable_get(:@sock)
    !sock.nil?
  rescue
    false
  end

  private def handle_input
    case @tui.poll_event
    in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
      :quit

    in { type: :key, code: "d" }
      enable_debug_mode!

    in { type: :key, code: "p" }
      trigger_test_panic!

    in { type: :key, code: "t" }
      trigger_type_error!

    in { type: :key, code: "b" }
      @status_message = "Debug status refreshed at #{Time.now.strftime('%H:%M:%S')}"

    else
      nil
    end
  end

  private def enable_debug_mode!
    if RatatuiRuby::Debug.enabled?
      @status_message = "Debug mode already enabled!"
    else
      # debug_mode! returns the socket path and suppresses the debug gem's output
      @socket_path = RatatuiRuby.debug_mode!
      @status_message = "debug_mode! enabled"
      @show_debug_info = true
    end
  end

  private def trigger_test_panic!
    if RatatuiRuby::Debug.rust_backtrace_enabled?
      @status_message = "Triggering test_panic! — check stderr for backtrace..."
    else
      @status_message = "Triggering test_panic! — backtrace hidden (set RUST_BACKTRACE=1)"
    end
    render # Show the message before crashing

    # Give a moment for the render to complete
    sleep 0.1

    # This will crash the app with a Rust panic. If RUST_BACKTRACE=1 or
    # debug mode is enabled, you'll see the full Rust stack trace after
    # the terminal is restored.
    RatatuiRuby::Debug.test_panic!
  end

  private def trigger_type_error!
    if RatatuiRuby::Debug.rust_backtrace_enabled?
      @status_message = "Triggering TypeError — check stderr for error message..."
    else
      @status_message = "Triggering TypeError — set RUST_BACKTRACE=1 for stack trace"
    end
    render # Show the message before crashing
    sleep 0.1

    # Bypass the factory's DWIM coercion to trigger a real Rust TypeError.
    # Uses Widgets::Table.new directly with invalid rows type.
    bad_table = RatatuiRuby::Widgets::Table.new(rows: 42, widths: [])
    @tui.draw { |f| f.render_widget(bad_table, f.area) }
  end
end

VerifyDebuggingUsage.new.run if __FILE__ == $PROGRAM_NAME
