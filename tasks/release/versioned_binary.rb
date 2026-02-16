# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

require_relative "../bump/sem_ver"

# A compiled native extension binary for a specific Ruby version.
class VersionedBinary < Data.define(:path)
  def self.scan(lib_dir)
    Dir.glob("#{lib_dir}/*/ratatui_ruby.*")
      .reject { |p| p.end_with?(".rb") }
      .map { |p| new(path: p) }
      .sort
  end

  def ruby_version = File.basename(File.dirname(path))

  def api_version
    semver = SemVer.parse(ruby_version)
    "#{semver.major}.#{semver.minor}"
  end

  def <=>(other) = api_version <=> other.api_version
end
