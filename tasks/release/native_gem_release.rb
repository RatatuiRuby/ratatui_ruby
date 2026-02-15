# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

require "open3"
require "json"
require "tmpdir"
require "fileutils"

# NativeGemRelease downloads CI-built native gem artifacts from GitHub Actions
# and pushes them to RubyGems.org.
class NativeGemRelease < Data.define(:version, :sha)
  WORKFLOW_NAME = "Build Gems"

  def call
    unless gh_available?
      warn "\n⚠  'gh' CLI not found — skipping native gem push."
      warn "   Install: https://cli.github.com\n\n"
      return
    end

    unless gh_authenticated?
      warn "\n⚠  'gh' is not authenticated — skipping native gem push."
      warn "   Run: gh auth login\n\n"
      return
    end

    run_id = find_completed_run(sha)

    unless run_id
      warn "\n⚠  No completed '#{WORKFLOW_NAME}' run found for v#{version} (#{sha[0, 7]})."
      warn "   Native gems were not pushed to RubyGems.org.\n\n"
      return
    end

    Dir.mktmpdir("native-gems") do |dir|
      download_artifacts(run_id, dir)
      gems = Dir.glob("#{dir}/**/*.gem")

      if gems.empty?
        warn "\n⚠  No .gem files found in artifacts for run #{run_id}."
        warn "   Native gems were not pushed to RubyGems.org.\n\n"
      else
        verify_versions!(gems)
        push_gems(gems)
      end
    end
  end

  private def gh_available?
    system("command", "-v", "gh", out: File::NULL, err: File::NULL)
  end

  private def gh_authenticated?
    system("gh", "auth", "status", out: File::NULL, err: File::NULL)
  end

  private def find_completed_run(sha)
    out, status = Open3.capture2(
      "gh", "run", "list",
      "--workflow", WORKFLOW_NAME,
      "--commit", sha,
      "--status", "completed",
      "--json", "databaseId,conclusion",
      "--limit", "1"
    )
    return nil unless status.success?

    runs = JSON.parse(out)
    run = runs.first
    return nil unless run
    return nil unless run.fetch("conclusion") == "success"

    run.fetch("databaseId")
  end

  private def verify_versions!(gems)
    expected = Gem::Version.new(version).to_s
    mismatched = gems.reject { |path| File.basename(path).include?(expected) }
    return if mismatched.empty?

    names = mismatched.map { |path| "  - #{File.basename(path)}" }.join("\n")
    abort "Fatal: Version mismatch in downloaded artifacts!\n" \
      "Expected version #{expected} but found:\n#{names}"
  end

  private def download_artifacts(run_id, dir)
    puts "Downloading native gem artifacts from run #{run_id}..."
    system("gh", "run", "download", run_id.to_s, "--dir", dir, exception: true)
  end

  private def push_gems(gems)
    gems.each do |gem_path|
      name = File.basename(gem_path)
      puts "Pushing #{name} to RubyGems.org..."
      system("gem", "push", gem_path, exception: true)
    end
    puts "\n✓ Pushed #{gems.size} native gem#{'s' if gems.size != 1} to RubyGems.org."
  end
end
