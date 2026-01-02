# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

# Manages the version comparison links at the botton of the changelog.
#
# Release automation needs to update links. Manually calculating git diff URLs
# for every release is tedious and error-prone. SourceHut does not have
# standard comparison views, complicating matters further.
#
# This class manages the collection of links. It parses them from the markdown.
# It generates the correct tree links for SourceHut. It properly shifts the
# "Unreleased" pointer.
#
# Use it to update the changelog during a release.
class Links
  PATTERN = /^(\[Unreleased\]: .*)$/m
  UNRELEASED_PATTERN = %r{^\[Unreleased\]: (.*?/refs/)HEAD$}

  # Creates a Links object from the full markdown content.
  #
  # [content] String. The full text of the changelog.
  def self.from_markdown(content)
    match = content.match(PATTERN)
    return unless match

    new(match[1].strip)
  end

  # Returns the raw text of the links.
  attr_reader :text

  # Creates a new Links object.
  #
  # [text] String. The raw text of the links section.
  def initialize(text)
    @text = text.dup
  end

  # Releases a new version.
  #
  # Updates the "Unreleased" link to point to the new head. Adds a new link for
  # the just-released version pointing to its specific tag.
  #
  # [version] String. The new version number (e.g., <tt>"0.5.0"</tt>).
  def release(version)
    return unless base_url

    new_unreleased = "[Unreleased]: #{base_url}HEAD" # .../HEAD
    new_version_link = "[#{version}]: #{base_url}v#{version}" # .../v1.0.0

    @text.sub!(UNRELEASED_PATTERN, "#{new_unreleased}\n#{new_version_link}")
    self
  end

  # Returns the string representation of the links.
  def to_s
    @text
  end

  # The base URL for the repository's references.
  private def base_url
    match = @text.match(UNRELEASED_PATTERN)
    match[1] if match
  end
end
