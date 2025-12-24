# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

# See https://semver.org/spec/v2.0.0.html
class SemVer
  SEGMENTS = [:major, :minor, :patch].freeze

  def initialize(segments)
    @segments = segments
  end

  def next(segment)
    index = SEGMENTS.index(segment)
    raise ArgumentError, "Invalid segment: #{segment}" unless index

    new_segments = @segments.dup
    new_segments[index] += 1
    new_segments.fill(0, (index + 1)..2)

    SemVer.new(new_segments)
  end

  def to_s
    @segments.join(".")
  end
end
