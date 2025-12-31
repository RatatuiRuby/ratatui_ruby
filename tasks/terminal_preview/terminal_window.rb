# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "window_id"
require_relative "preview_timing"

class TerminalWindow
  CTRL_C = "ASCII character 3"

  def initialize(launcher_script_path, pid_file)
    @launcher_script_path = launcher_script_path
    @pid_file = pid_file
    @window_id = nil
  end

  def open
    setup_script = <<~APPLESCRIPT
      tell application "Terminal"
        set newTab to do script "#{@launcher_script_path}"
        set currentWindow to window 1
        
        set number of rows of currentWindow to 24
        set number of columns of currentWindow to 80
        set position of currentWindow to {100, 100}
        set frontmost of currentWindow to true
        
        return id of currentWindow
      end tell
    APPLESCRIPT

    @window_id = WindowID.new(`osascript -e '#{setup_script}'`.strip)
    wait_for_startup
    yield self
  ensure
    close if @window_id
  end

  def window_id
    @window_id
  end

  private def close
    try_graceful_shutdown
    kill_process if process_still_alive?

    delay_script = <<~APPLESCRIPT
      tell application "Terminal"
        delay #{PreviewTiming.close_delay}
        
        try
          close window id #{@window_id}
        end try
      end tell
    APPLESCRIPT

    system("osascript", "-e", delay_script, out: File::NULL, err: File::NULL)
  end

  private def wait_for_startup
    sleep PreviewTiming.window_startup

    unless @window_id.valid?
      raise "Failed to open terminal window"
    end

    unless process_running?
      error_output = contents
      raise error_output
    end
  end

  private def try_graceful_shutdown
    shutdown_script = <<~APPLESCRIPT
      tell application "Terminal"
        try
          do script (#{CTRL_C}) in window id #{@window_id}
        end try
      end tell
    APPLESCRIPT

    system("osascript", "-e", shutdown_script, out: File::NULL, err: File::NULL)
    sleep 0.2
  end

  private def process_still_alive?
    return false unless @pid_file && File.exist?(@pid_file)

    pid = File.read(@pid_file).strip.to_i
    Process.kill(0, pid)
    true
  rescue Errno::ESRCH, Errno::ENOENT
    false
  end

  private def kill_process
    return unless @pid_file && File.exist?(@pid_file)

    pid = File.read(@pid_file).strip.to_i
    Process.kill("TERM", pid)
  rescue Errno::ESRCH, Errno::ENOENT
    # Process already gone or PID file doesn't exist
  end

  private def process_running?
    check_script = <<~APPLESCRIPT
      tell application "Terminal"
        try
          set theWindow to window id #{@window_id}
          return busy of theWindow
        on error
          return false
        end try
      end tell
    APPLESCRIPT

    result = `osascript -e '#{check_script}'`.strip
    result == "true"
  end

  private def contents
    read_script = <<~APPLESCRIPT
      tell application "Terminal"
        try
          set theWindow to window id #{@window_id}
          return contents of selected tab of theWindow
        on error
          return ""
        end try
      end tell
    APPLESCRIPT

    `osascript -e '#{read_script}'`
  end
end
