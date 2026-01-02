# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "time"

class SavedScreenshot < Data.define(:app, :path)
  def self.for(app, output_dir)
    new(app, File.join(output_dir, app.screenshot_filename))
  end

  def stale?
    return true unless valid?

    app_last_modified > screenshot_last_commit_time
  end

  private def valid?
    # File must exist and have content (not 0 bytes)
    File.size?(path) || false
  end

  private def app_last_modified
    # If the file has staged or unstaged changes, it's definitely stale
    return Time.now.to_i if changed?

    # Otherwise, compare against the last git commit time
    app_last_commit_time
  end

  private def changed?
    system("git diff HEAD --quiet #{app.app_path} 2>/dev/null")
    !$?.success?
  end

  private def app_last_commit_time
    output = `git log -1 --format=%cI "#{app.app_path}" 2>/dev/null`.strip
    return 0 if output.empty?

    Time.iso8601(output).to_i
  rescue
    0
  end

  private def screenshot_last_commit_time
    output = `git log -1 --format=%cI "#{path}" 2>/dev/null`.strip
    return Time.now.to_i if output.empty?

    Time.iso8601(output).to_i
  rescue
    Time.now.to_i
  end
end
