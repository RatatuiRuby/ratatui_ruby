# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "time"

class SavedScreenshot < Data.define(:app, :path)
  def self.for(app, output_dir)
    new(app, File.join(output_dir, app.screenshot_filename))
  end

  def stale?
    return true unless exists?

    app_last_modified > mtime
  end

  private

  def exists?
    File.exist?(path)
  end

  def mtime
    File.mtime(path).to_i
  end

  def app_last_modified
    # If the file has unstaged changes, it's definitely stale
    return Time.now.to_i if has_unstaged_changes?

    # Otherwise, compare against the last git commit time
    app_last_commit_time
  end

  def has_unstaged_changes?
    system("git diff --quiet #{app.app_path} 2>/dev/null")
    !$?.success?
  end

  def app_last_commit_time
    output = `git log -1 --format=%cI "#{app.app_path}" 2>/dev/null`.strip
    return 0 if output.empty?

    Time.iso8601(output).to_i
  rescue StandardError
    0
  end
end
