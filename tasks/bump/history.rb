# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

# History manages the versioned history of the changelog.
class History
  # Extracts the history section from the given content, between unreleased and links.
  def self.parse(content, header_length, unreleased_length, links_text)
    start = header_length + unreleased_length
    text = content[start...content.index(links_text)].strip + "\n"
    new(text)
  end

  # Creates a new History from the given content.
  def initialize(content)
    @content = content.dup
  end

  # Adds a new versioned section to the history.
  def add(section)
    @content = "#{section}\n\n#{@content}".strip + "\n"
    nil
  end

  # Returns the current state of the history as a string.
  def to_s
    @content
  end
end
