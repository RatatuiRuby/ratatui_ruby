# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

# See https://semver.org/spec/v2.0.0.html
class SemVer
  SEGMENTS = [:major, :minor, :patch].freeze

  def self.parse(string)
    require "rubygems"
    # Extract prerelease suffix (e.g., "-beta.1", "-alpha.2", "-rc.1")
    base, prerelease = string.split("-", 2)
    segments = Gem::Version.new(base).segments.fill(0, 3).first(3)
    new(segments, prerelease:)
  end

  def initialize(segments, prerelease: nil)
    @segments = segments
    @prerelease = prerelease
  end

  def major = @segments[0]
  def minor = @segments[1]
  def patch = @segments[2]

  def next(segment)
    index = SEGMENTS.index(segment)
    raise ArgumentError, "Invalid segment: #{segment}" unless index

    new_segments = @segments.dup
    new_segments[index] += 1
    new_segments.fill(0, (index + 1)..2)

    SemVer.new(new_segments)
  end

  def to_s
    base = @segments.join(".")
    @prerelease ? "#{base}-#{@prerelease}" : base
  end
end
