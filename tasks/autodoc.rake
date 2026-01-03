# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "autodoc/inventory"
require_relative "autodoc/notice"
require_relative "autodoc/rbs"
require_relative "autodoc/rdoc"
require_relative "autodoc/examples"

namespace :autodoc do
  desc "Update all automatically generated documentation"
  task all: [:rbs, :rdoc, :examples]

  desc "Update all automatically generated RBS signatures"
  task rbs: ["rbs:session"]

  desc "Update all automatically generated RDoc files"
  task rdoc: ["rdoc:session"]

  namespace :rbs do
    desc "Generate RBS for RatatuiRuby::Session"
    task :session do
      require_relative "../lib/ratatui_ruby"

      Autodoc::Rbs.new(
        path: File.expand_path("../sig/ratatui_ruby/session.rbs", __dir__),
        notice: Autodoc::Notice.new("autodoc:rbs:session")
      ).write(Autodoc::Inventory.new)
    end
  end

  namespace :rdoc do
    desc "Generate RDoc autodoc for RatatuiRuby::Session"
    task :session do
      require_relative "../lib/ratatui_ruby"

      Autodoc::Rdoc.new(
        path: File.expand_path("../lib/ratatui_ruby/session/autodoc.rb", __dir__),
        notice: Autodoc::Notice.new("autodoc:rdoc:session")
      ).write(Autodoc::Inventory.new)
    end
  end

  desc "Sync code snippets in example READMEs with source files"
  task :examples do
    Autodoc::Examples.sync
  end
end

desc "Update all automatically generated documentation"
task autodoc: "autodoc:all"
