# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

require "rubygems"

require_relative "bump/sem_ver"
require_relative "bump/manifest"
require_relative "bump/cargo_lockfile"
require_relative "bump/ruby_gem"
require_relative "bump/release_from_trunk"
require_relative "bump/patch_release"

namespace :bump do
  gem = RubyGem.new(
    manifests: [
      Manifest.new(
        path: "lib/ratatui_ruby/version.rb",
        pattern: /(?<=VERSION = ")[^"]+(?=")/,
        primary: true
      ),
      Manifest.new(
        path: "ext/ratatui_ruby/Cargo.toml",
        pattern: /(?<=^version = ")[^"]+(?=")/,
        primary: false
      ),
    ],
    lockfile: CargoLockfile.new(
      path: "ext/ratatui_ruby/Cargo.lock",
      dir: "ext/ratatui_ruby",
      name: "ratatui_ruby"
    )
  )

  desc "Bump major version"
  task :major do
    ReleaseFromTrunk.new(gem:).call(:major)
  end

  desc "Bump minor version"
  task :minor do
    ReleaseFromTrunk.new(gem:).call(:minor)
  end

  desc "Bump patch version"
  task :patch do
    PatchRelease.new(gem:).call(:patch)
  end

  desc "Set exact version (e.g. rake bump:exact[0.1.0])"
  task :exact, [:version] do |_, args|
    target = SemVer.parse(args[:version])
    changelog = Changelog.new
    changelog.release(target)
    gem.update_version(target)
  end
end
