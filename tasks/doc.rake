# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "rdoc/task"

require_relative "rdoc_config"

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = "tmp/rdoc"
  rdoc.main = RDocConfig::MAIN
  rdoc.rdoc_files.include(RDocConfig::RDOC_FILES)
  rdoc.options << "--template-stylesheets=doc/custom.css"
end

task :copy_doc_images do
  if Dir.exist?("doc/images")
    FileUtils.mkdir_p "tmp/rdoc/doc/images"
    FileUtils.cp_r Dir["doc/images/*.png"], "tmp/rdoc/doc/images"
    FileUtils.cp_r Dir["doc/images/*.gif"], "tmp/rdoc/doc/images"
  end
end

Rake::Task[:rdoc].enhance [:copy_doc_images]
Rake::Task[:rerdoc].enhance [:copy_doc_images]
