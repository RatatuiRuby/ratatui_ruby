# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "date"
require "rdoc"

# UnreleasedSection manages the [Unreleased] section of the changelog.
class UnreleasedSection
  PATTERN = /^(## \[Unreleased\].*?)(?=## \[\d)/m

  # Extracts the unreleased section from the given content.
  def self.parse(content)
    match = content.match(PATTERN)
    new(match[1].strip) if match
  end

  # Creates a new UnreleasedSection from the given unreleased content.
  def initialize(content)
    @content = content.dup
  end

  # Returns the unreleased content as a versioned section.
  def as_version(new_version)
    date = Date.today.iso8601
    @content.sub(/^## \[Unreleased\]/, "## [#{new_version}] - #{date}")
  end

  # Returns a fresh unreleased section.
  def self.fresh
    new("## [Unreleased]\n\n### Added\n\n### Changed\n\n### Fixed\n\n### Removed")
  end

  # Returns the current state of the section as a string.
  def to_s
    @content
  end

  def commit_body
    formatter = Class.new { include RDoc::Text }.new
    @content
      .sub(/^## \[Unreleased\].*$/, "")
      .gsub(/^### (Added|Changed|Fixed|Removed)\n*$/, "")
      .gsub(/^- \*\*([^*]+)\*\*:/, '\1:')
      .gsub(/`([^`]+)`/, '\1')
      .strip
      .lines
      .map { |line| line.gsub(/^- /, "").strip }
      .reject(&:empty?)
      .map { |line| formatter.wrap(line, 72) }
      .join("\n\n")
  end
end
