# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "window_id"

class TerminalWindow < Data.define(:window_id)
  def self.open(launcher_script_path)
    setup_script = <<~APPLESCRIPT
      tell application "Terminal"
        set newTab to do script "#{launcher_script_path}"
        set currentWindow to window 1
        
        set number of rows of currentWindow to 24
        set number of columns of currentWindow to 80
        set position of currentWindow to {100, 100}
        set frontmost of currentWindow to true
        
        return id of currentWindow
      end tell
    APPLESCRIPT

    id = WindowID.new(`osascript -e '#{setup_script}'`.strip)
    new(id)
  end

  def close
    cleanup_script = <<~APPLESCRIPT
      tell application "Terminal"
        try
          -- Send ASCII 3 (Ctrl+C) to force-quit the process cleanly.
          do script (ASCII character 3) in window id #{window_id}
        end try
        
        -- Tiny pause to let the signal process
        delay 0.1
        
        close window id #{window_id}
      end tell
    APPLESCRIPT

    system("osascript", "-e", cleanup_script)
  end
end
