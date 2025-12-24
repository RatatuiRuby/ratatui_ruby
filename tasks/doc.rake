# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "rdoc/task"

require_relative "rdoc_config"

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = "doc"
  rdoc.main = RDocConfig::MAIN
  rdoc.rdoc_files.include(RDocConfig::RDOC_FILES)
  rdoc.options << "--template-stylesheets=docs/custom.css"
end

task :copy_doc_images do
  if Dir.exist?("docs/images")
    FileUtils.mkdir_p "doc/docs/images"
    FileUtils.cp_r Dir["docs/images/*.png"], "doc/docs/images"
  end
end

Rake::Task[:rdoc].enhance [:copy_doc_images]
Rake::Task[:rerdoc].enhance [:copy_doc_images]
