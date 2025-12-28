# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

# Manifests hold a copy of the version number and should be changed manually.
# Use Regexp lookarounds in `pattern` to match the version number.
class Manifest < Data.define(:path, :pattern, :primary)
  def read
    File.read(path)
  end

  def initialize(path:, pattern:, primary: false)
    super
  end

  def version
    content = read
    match = content.match(pattern)
    raise "Version missing in manifest #{path}" unless match

    SemVer.parse(match[0])
  end

  def write(version)
    return unless File.exist?(path)

    new_content = read.gsub(pattern, version.to_s)
    File.write(path, new_content)
  end
end
