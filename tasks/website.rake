# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "erb"
require "fileutils"
require "tmpdir"
require_relative "rdoc_config"

namespace :website do
  desc "Build documentation for main (current dir) and all git tags"
  task :build do
    require_relative "website/website"

    spec = Gem::Specification.load(Dir["*.gemspec"].first)
    globs = RDocConfig::RDOC_FILES + ["*.gemspec", "doc/images/**/*"]

    Website.new(
      at: "www",
      project_name: spec.name,
      globs:,
      assets: ["doc/images"] # directories to copy
    ).build
  end
end
