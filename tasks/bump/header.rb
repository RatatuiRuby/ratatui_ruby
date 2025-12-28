# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

# Header manages the header section of the changelog.
class Header
  PATTERN = /^(.*?)(?=## \[Unreleased\])/m

  # Extracts the header section from the given content.
  def self.parse(content)
    match = content.match(PATTERN)
    new(match[1]) if match
  end

  # Creates a new Header from the given content.
  def initialize(content)
    @content = content.dup
  end

  # Returns the length of the header content.
  def length
    @content.length
  end

  # Returns the current state of the header as a string.
  def to_s
    @content
  end
end
