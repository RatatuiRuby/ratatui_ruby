# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

class RubyGem
  def initialize(manifests:, lockfile:)
    raise ArgumentError, "Must have exactly one primary manifest" unless manifests.count(&:primary) == 1
    @manifests = manifests
    @lockfile = lockfile
  end

  def version
    source = @manifests.find(&:primary)
    content = source.read
    match = content.match(source.pattern)
    raise "Version missing in manifest #{source.path}" unless match

    segments = Gem::Version.new(match[0]).segments
    SemVer.new(segments.fill(0, 3).first(3))
  end

  def bump(segment)
    target = version.next(segment)

    puts "Bumping #{segment}: #{version} -> #{target}"
    @manifests.each { |manifest| manifest.write(target) }
    @lockfile.refresh
  end

  def set(version_string)
    segments = Gem::Version.new(version_string).segments.fill(0, 3).first(3)
    target = SemVer.new(segments)

    puts "Setting version: #{version} -> #{target}"
    @manifests.each { |manifest| manifest.write(target) }
    @lockfile.refresh
  end
end
