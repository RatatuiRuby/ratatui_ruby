# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "rdoc/task"

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = "doc"
  rdoc.main = "README.md"
  rdoc.rdoc_files.include("**/*.md", "**/*.rdoc", "lib/**/*.rb", "exe/**/*")
end

Rake::Task[:rdoc].enhance do
  FileUtils.mkdir_p "doc/docs/images"
  FileUtils.cp_r FileList["docs/images/*.png"], "doc/docs/images"
end

Rake::Task[:rerdoc].enhance do
  FileUtils.mkdir_p "doc/docs/images"
  FileUtils.cp_r FileList["docs/images/*.png"], "doc/docs/images"
end
