# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "fileutils"
require "tmpdir"

class LauncherScript < Data.define(:app_path, :repo_root)
  def initialize(app_path:, repo_root:)
    super
    write
  end

  def run
    yield self
  ensure
    cleanup
  end

  def path
    File.join(Dir.tmpdir, "preview_launcher.sh")
  end

  def pid_file
    File.join(Dir.tmpdir, "preview_launcher.pid")
  end

  private

  def cleanup
    File.delete(path) if File.exist?(path)
    File.delete(pid_file) if File.exist?(pid_file)
  rescue Errno::ENOENT
    # Already deleted
  end

  def write
    File.open(path, "w") do |f|
      f.puts "#!/bin/zsh"
      f.puts "cd '#{repo_root}'"
      f.puts "clear"
      f.puts "echo $$ > '#{pid_file}'"
      f.puts "exec bundle exec ruby '#{app_path}'"
    end
    FileUtils.chmod(0o755, path)
  end
end
