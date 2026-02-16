# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

require_relative "release/native_gem_version"

namespace :release do
  desc "Update stable branch to match release and set as default"
  task :update_stable do
    # Read version to determine tag
    version_content = File.read("lib/ratatui_ruby/version.rb")
    version = version_content.match(/VERSION = "(.+?)"/)[1]
    tag_name = "v#{version}"

    # Verify that the version file matches the actual git tag
    # This prevents updating stable to the wrong version if the release failed
    latest_tag = `git describe --tags --abbrev=0`.strip
    if latest_tag != tag_name
      abort "Fatal: Version mismatch! 'lib/ratatui_ruby/version.rb' says #{tag_name}, but the latest git tag is #{latest_tag}."
    end

    # Get current stable version (if stable branch exists)
    stable_version_str = `git show stable:lib/ratatui_ruby/version.rb 2>/dev/null`.match(/VERSION = "(.+?)"/)&.[](1)
    if stable_version_str
      stable_version = Gem::Version.new(stable_version_str)
      new_version = Gem::Version.new(version)

      if new_version <= stable_version
        puts "Skipping stable update: #{version} is not newer than current stable #{stable_version_str}"
        next
      end
    end

    puts "Updating stable branch to point to #{tag_name}..."
    # Resolve the tag to a commit hash (peel annotated tags)
    # This renders a commit SHA that can be pushed to a branch head
    commit_sha = `git rev-parse #{tag_name}^{}`.strip

    # Update local stable branch to match
    sh "git branch -f stable #{commit_sha}"

    # Push the commit to remote stable branch
    # Force-push because stable is reset to each release, not fast-forwarded.
    sh "git push --force origin #{commit_sha}:stable"
  end
end

if Rake::Task.task_defined?("release")
  Rake::Task["release"].enhance do
    # Replace Bundler's normalized tag with semver-style for prerelease versions.
    # Bundler creates tags using normalized Gem::Version (e.g., v1.0.0.pre.beta.1).
    # Semver uses hyphens (e.g., v1.0.0-beta.1). We want only the semver tag.
    version_content = File.read("lib/ratatui_ruby/version.rb")
    version = version_content.match(/VERSION = "(.+?)"/)[1]

    if version.include?("-")
      normalized_tag = "v#{Gem::Version.new(version)}"
      semver_tag = "v#{version}"

      if normalized_tag != semver_tag
        puts "Replacing normalized tag #{normalized_tag} with semver tag #{semver_tag}..."
        # Delete the normalized tag locally and remotely
        sh "git tag -d #{normalized_tag}"
        sh "git push origin :refs/tags/#{normalized_tag}"
        # Create the semver tag pointing to the same commit
        sh "git tag #{semver_tag} HEAD"
        sh "git push origin #{semver_tag}"
      end
    end

    release_sha = `git rev-parse v#{version}^{}`.strip
    NativeGemVersion.new(version:, sha: release_sha).release

    Rake::Task["release:update_stable"].invoke
  end
end
