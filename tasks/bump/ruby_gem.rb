# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

# RubyGem knows how to update its version: manifests, lockfiles.
class RubyGem
  def initialize(manifests:, lockfile:)
    raise ArgumentError, "Must have exactly one primary manifest" unless manifests.count(&:primary) == 1
    @manifests = manifests
    @lockfile = lockfile
  end

  def version
    @manifests.find(&:primary).version
  end

  def update_version(target)
    @manifests.each { |manifest| manifest.write(target) }
    @lockfile.refresh
    refresh_bundler_lockfile
  end

  private def refresh_bundler_lockfile
    system("bundle install", exception: true)
  end
end
