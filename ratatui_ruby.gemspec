# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "lib/ratatui_ruby/version"

Gem::Specification.new do |spec|
  spec.name = "ratatui_ruby"
  spec.version = RatatuiRuby::VERSION
  spec.authors = ["Kerrick Long"]
  spec.email = ["me@kerricklong.com"]

  spec.summary = "💎 Unofficial Ruby wrapper for the Ratatui 👨‍🍳🐀."
  spec.description = "ratatui_ruby is a wrapper for the Ratatui Rust crate <https://ratatui.rs>. It allows you to cook up Terminal User Interfaces in Ruby."
  spec.homepage = "https://sr.ht/~kerrick/ratatui_ruby/"
  spec.license = "AGPL-3.0-or-later"
  spec.required_ruby_version = "= 3.4.7"

  spec.metadata["allowed_push_host"] = "https://rubygems.org"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["bug_tracker_uri"] = "https://todo.sr.ht/~kerrick/ratatui_ruby"
  spec.metadata["changelog_uri"] = "https://git.sr.ht/~kerrick/ratatui_ruby/tree/main/item/CHANGELOG.md"
  spec.metadata["mailing_list_uri"] = "https://lists.sr.ht/~kerrick/ratatui_ruby-discuss"
  spec.metadata["source_code_uri"] = "https://git.sr.ht/~kerrick/ratatui_ruby"
  spec.metadata["documentation_uri"] = "https://man.sr.ht/~kerrick/ratatui_ruby/docs/"
  spec.metadata["wiki_uri"] = "https://man.sr.ht/~kerrick/ratatui_ruby/docs/contributors/"
  spec.metadata["funding_uri"] = "https://opencollective.com/ratatui" # Don't fund me, fund the upstream project.

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .github appveyor Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]
  spec.extensions = ["ext/ratatui_ruby/extconf.rb"]

  spec.add_dependency "rb_sys", "~> 0.9"
  spec.add_development_dependency "rake-compiler", "~> 1.2"
end
