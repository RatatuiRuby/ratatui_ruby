# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

require "tmpdir"

require_relative "github_cli"
require_relative "ci_run"

# A native gem version identified by its version string and commit SHA.
# Knows how to release itself by downloading CI artifacts and pushing to RubyGems.
class NativeGemVersion < Data.define(:version, :sha)
  def release
    cli = GitHubCli.new

    unless cli.available?
      cli.warn_unavailable
      return
    end

    unless cli.authenticated?
      cli.warn_unauthenticated
      return
    end

    run = CIRun.for_commit(sha)

    unless run
      warn "\n⚠  No completed '#{CIRun::WORKFLOW_NAME}' run found for v#{version} (#{sha[0, 7]})."
      warn "   Native gems were not pushed to RubyGems.org.\n\n"
      return
    end

    Dir.mktmpdir("native-gems") do |dir|
      gem_paths = run.download(dir)

      if gem_paths.empty?
        warn "\n⚠  No .gem files found in artifacts for run #{run.id}."
        warn "   Native gems were not pushed to RubyGems.org.\n\n"
      else
        verify_versions!(gem_paths)
        push(gem_paths)
      end
    end
  end

  private def verify_versions!(gem_paths)
    expected = Gem::Version.new(version).to_s
    mismatched = gem_paths.reject { |path| File.basename(path).include?(expected) }
    return if mismatched.empty?

    names = mismatched.map { |path| "  - #{File.basename(path)}" }.join("\n")
    abort "Fatal: Version mismatch in downloaded artifacts!\n" \
      "Expected version #{expected} but found:\n#{names}"
  end

  private def push(gem_paths)
    gem_paths.each do |gem_path|
      name = File.basename(gem_path)
      puts "Pushing #{name} to RubyGems.org..."
      system("gem", "push", gem_path, exception: true)
    end
    puts "\n✓ Pushed #{gem_paths.size} native gem#{'s' if gem_paths.size != 1} to RubyGems.org."
  end
end
