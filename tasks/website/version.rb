# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

require "rubygems"
require "fileutils"

class Version
  def self.all
    tags = `git tag`.split.grep(/^v\d/)
    sorted_versions = tags.map { |t| Tagged.new(t) }
      .sort_by(&:semver)
      .reverse

    # Keep only the latest patch for each minor version
    # e.g., if we have v0.6.0, v0.6.1, v0.6.2, only keep v0.6.2
    latest_per_minor = sorted_versions
      .group_by { |v| v.semver.segments[0..1] } # group by [major, minor]
      .values
      .map(&:first) # take the first (highest patch) from each group

    [Edge.new] + latest_per_minor
  end

  def slug
    raise NotImplementedError
  end

  def name
    raise NotImplementedError
  end

  def type
    raise NotImplementedError
  end

  def ref
    raise NotImplementedError
  end

  def checkout(globs:, &block)
    Dir.mktmpdir do |path|
      # Use git archive to export the version at the specified ref
      # Pipe to tar to extract into the temporary directory
      system("git archive #{ref} | tar -x -C #{path}")

      # Remove the native extension directory as we don't need it for builds
      # and it can cause issues if not meant to be compiled in this context
      FileUtils.rm_rf("#{path}/ext")

      yield path
    end
  end

  def latest?
    false
  end

  def edge?
    false
  end
end

class Edge < Version
  def slug
    "trunk"
  end

  def name
    "trunk"
  end

  def type
    :edge
  end

  def ref
    "trunk"
  end

  def edge?
    true
  end
end

class Tagged < Version
  attr_reader :tag

  def initialize(tag)
    @tag = tag
  end

  def slug
    segments = semver.segments
    "v#{segments[0]}.#{segments[1]}"
  end

  def name
    @tag
  end

  def type
    :version
  end

  def ref
    @tag
  end

  def semver
    Gem::Version.new(@tag.sub(/^v/, ""))
  end

  attr_accessor :is_latest

  def latest?
    @is_latest
  end
end
