# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

# ComparisonLinks manages the git comparison links at the bottom of the changelog.
class ComparisonLinks
  PATTERN = /^(\[Unreleased\]: .*)$/m

  # Extracts the comparison links from the given content.
  def self.parse(content)
    match = content.match(PATTERN)
    new(match[1].strip) if match
  end

  # Creates a new ComparisonLinks from the given links text.
  def initialize(links)
    @links = links.dup
  end

  # Updates the comparison links for the new version.
  def update(new_version)
    pattern = %r{^\[Unreleased\]: (.*?/compare/)v(.*)\.\.\.HEAD$}
    match = @links.match(pattern)
    return unless match

    base_url = match[1]
    prev_version = match[2]

    new_unreleased = "[Unreleased]: #{base_url}v#{new_version}...HEAD"
    new_version_link = "[#{new_version}]: #{base_url}v#{prev_version}...v#{new_version}"

    @links.sub!(pattern, "#{new_unreleased}\n#{new_version_link}")
    nil
  end

  # Returns the current state of the links as a string.
  def to_s
    @links
  end
end
