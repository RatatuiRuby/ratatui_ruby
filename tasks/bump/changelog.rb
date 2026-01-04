# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "links"
require_relative "unreleased_section"
require_relative "history"
require_relative "header"

# Changelog manages the project's CHANGELOG.md file.
class Changelog
  # Creates a new Changelog for the file at the given path.
  def initialize(path: "CHANGELOG.md")
    @path = path
  end

  # Releases a new version in the changelog.
  # This moves the unreleased changes to a new version heading and resets the unreleased section.
  def release(new_version)
    content = File.read(@path)

    header = Header.parse(content)
    unreleased = UnreleasedSection.parse(content)
    links = Links.from_markdown(content)

    raise "Could not parse CHANGELOG.md" unless header && unreleased && links

    history = History.parse(content, header.length, unreleased.to_s.length, links.to_s)

    links.release(new_version)
    history.add(unreleased.as_version(new_version))

    File.write(@path, "#{header}#{UnreleasedSection.fresh}\n\n#{history}\n#{links}")
    nil
  end

  def commit_message(version)
    content = File.read(@path)
    unreleased = UnreleasedSection.parse(content)
    return nil unless unreleased

    "chore: release v#{version}\n\n#{unreleased.commit_body}"
  end
end
