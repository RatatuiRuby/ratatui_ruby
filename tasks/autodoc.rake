# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "autodoc/examples"

namespace :autodoc do
  desc "Update all automatically generated documentation"
  task all: [:examples]

  desc "Sync code snippets in example READMEs with source files"
  task :examples do
    Autodoc::Examples.sync
  end
end

desc "Update all automatically generated documentation"
task autodoc: "autodoc:all"
