# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "tmpdir"
require_relative "launcher_script"
require_relative "terminal_window"
require_relative "crash_report"

class AppScreenshot < Data.define(:app, :output_path)
  def capture
    print "  📸 #{app}..."

    LauncherScript.new(app.app_path, Dir.pwd).run do |launcher|
      TerminalWindow.new(launcher.path, launcher.pid_file).open do |window|
        take_snapshot(window.window_id)

        if File.size?(output_path)
          puts " done."
          true
        else
          FileUtils.rm_f(output_path)
          puts " FAILED"
          puts
          puts "  Window rendered nothing (app may have crashed before drawing)"
          puts
          false
        end
      end
    end
  rescue => e
    puts " FAILED"
    puts
    puts CrashReport.new(app, e, "Program crashed before screenshot could be taken:")
    puts
    false
  end

  private def take_snapshot(window_id)
    system("screencapture", "-l", window_id.to_s, "-o", "-x", output_path)
  end
end
