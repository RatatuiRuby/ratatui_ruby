# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "rubygems"
require "fileutils"

class Version
  def self.all
    tags = `git tag`.split.grep(/^v\d/)
    sorted_versions = tags.map { |t| Tagged.new(t) }
      .sort_by(&:semver)
      .reverse

    [Edge.new] + sorted_versions
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

  def checkout(globs:, &block)
    raise NotImplementedError
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
    "main"
  end

  def name
    "main"
  end

  def type
    :edge
  end

  def edge?
    true
  end

  def checkout(globs:, &block)
    Dir.mktmpdir do |path|
      # Use git ls-files for accurate source list
      files = `git ls-files`.split("\n").select do |f|
        globs.any? { |glob| File.fnmatch(glob, f, File::FNM_PATHNAME) }
      end

      files.each do |file|
        dest = File.join(path, file)
        next unless File.exist?(file) # Skip files that are in the index but deleted in the working tree
        FileUtils.mkdir_p(File.dirname(dest))
        FileUtils.cp(file, dest)
      end

      yield path
    end
  end
end

class Tagged < Version
  attr_reader :tag

  def initialize(tag)
    @tag = tag
  end

  def slug
    @tag
  end

  def name
    @tag
  end

  def type
    :version
  end

  def semver
    Gem::Version.new(@tag.sub(/^v/, ""))
  end

  attr_accessor :is_latest

  def latest?
    @is_latest
  end

  def checkout(globs:, &block)
    Dir.mktmpdir do |path|
      system("git archive #{@tag} | tar -x -C #{path}")
      # We could enforce globs here too, but git archive is usually sufficient.
      FileUtils.rm_rf("#{path}/ext")
      yield path
    end
  end
end
