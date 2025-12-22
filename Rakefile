# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "bundler/gem_tasks"
require "minitest/test_task"

Minitest::TestTask.create

require "rubocop/rake_task"

RuboCop::RakeTask.new

require "rdoc/task"

RDoc::Task.new do |rdoc|
  rdoc.rdoc_dir = "doc"
  rdoc.main = "README.md"
  rdoc.rdoc_files.include("**/*.md", "**/*.rdoc", "lib/**/*.rb", "exe/**/*")
end

require "rubycritic/rake_task"

RubyCritic::RakeTask.new do |task|
  task.options = "--no-browser"
  task.paths = FileList.new.include("exe/**/*.rb", "lib/**/*.rb", "sig/**/*.rbs")
end

require "inch/rake"

Inch::Rake::Suggest.new("doc:suggest", "exe/**/*.rb", "lib/**/*.rb", "sig/**/*.rbs") do |suggest|
  suggest.args << ""
end

namespace :reuse do
  desc "Run the REUSE Tool to confirm REUSE compliance"
  task :lint do
    sh "pipx run reuse lint"
  end
end
task(:reuse) { Rake::Task["reuse:lint"].invoke }

namespace :lint do
  multitask docs: %i[rubycritic rdoc:coverage reuse:lint]
  multitask code: %i[rubocop rubycritic]
  multitask licenses: %i[reuse:lint]
  multitask all: %i[docs code licenses]
end
task(:lint) { Rake::Task["lint:all"].invoke }

multitask default: %i[test lint]
