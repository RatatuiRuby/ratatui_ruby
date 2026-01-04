# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

class RubyGem
  def initialize(manifests:, lockfile:, changelog:)
    raise ArgumentError, "Must have exactly one primary manifest" unless manifests.count(&:primary) == 1
    @manifests = manifests
    @lockfile = lockfile
    @changelog = changelog
  end

  def version
    @manifests.find(&:primary).version
  end

  def bump(segment)
    target = version.next(segment)
    commit_message = @changelog.commit_message(target)

    puts "Bumping #{segment}: #{version} -> #{target}"
    @changelog.release(target)
    @manifests.each { |manifest| manifest.write(target) }
    @lockfile.refresh

    puts_commit_message(commit_message)
  end

  def set(version_string)
    target = SemVer.parse(version_string)
    commit_message = @changelog.commit_message(target)

    puts "Setting version: #{version} -> #{target}"
    @changelog.release(target)
    @manifests.each { |manifest| manifest.write(target) }
    @lockfile.refresh

    puts_commit_message(commit_message)
  end

  private def puts_commit_message(message)
    puts "=" * 80
    puts message
    puts "=" * 80
  end
end
