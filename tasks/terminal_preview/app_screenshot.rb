# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "tmpdir"
require_relative "launcher_script"
require_relative "terminal_window"

class AppScreenshot < Data.define(:app, :output_path)
  def capture
    print "  📸 #{app}..."

    begin
      launcher = LauncherScript.new(app.app_path, Dir.pwd)
      window = TerminalWindow.open(launcher.path)
      sleep 0.8

      take_snapshot(window.window_id) if window.window_id.valid?

      window.close
      puts " done."
      sleep 0.2
    rescue => e
      puts " FAILED: #{e.message}"
    end
  end

  private

  def take_snapshot(window_id)
    system("screencapture -l #{window_id} -o -x '#{output_path}'")
  end
end
