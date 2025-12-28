# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "rubygems"

require_relative "bump/sem_ver"
require_relative "bump/manifest"
require_relative "bump/cargo_lockfile"
require_relative "bump/ruby_gem"

namespace :bump do
  ratatuiRuby = RubyGem.new(
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

  SemVer::SEGMENTS.each do |segment|
    desc "Bump #{segment} version"
    task segment do
      ratatuiRuby.bump(segment)
      Rake::Task["sourcehut"].invoke
    end
  end

  desc "Set exact version (e.g. rake bump:exact[0.1.0])"
  task :exact, [:version] do |_, args|
    ratatuiRuby.set(args[:version])
    Rake::Task["sourcehut"].invoke
  end
end
