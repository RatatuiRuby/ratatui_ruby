# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "bundler/gem_tasks"
require "minitest/test_task"

# Ruby tests are handled by test:ruby
# Cargo tests are handled by test:rust

require "rake/extensiontask"

spec = Gem::Specification.load("ratatui_ruby.gemspec")
Rake::ExtensionTask.new("ratatui_ruby", spec) do |ext|
  ext.lib_dir = "lib/ratatui_ruby"
  ext.ext_dir = "ext/ratatui_ruby"
end

# The :compile task is now provided by rake-compiler

require "rubocop/rake_task"

RuboCop::RakeTask.new

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

require "rubycritic/rake_task"

RubyCritic::RakeTask.new do |task|
  task.options = "--no-browser"
  task.paths = FileList.new.include("exe/**/*.rb", "lib/**/*.rb", "sig/**/*.rbs")
end

require "inch/rake"

Inch::Rake::Suggest.new("doc:suggest", "exe/**/*.rb", "lib/**/*.rb", "sig/**/*.rbs") do |suggest|
  suggest.args << ""
end

namespace :cargo do
  desc "Run cargo fmt"
  task :fmt do
    sh "cd ext/ratatui_ruby && cargo fmt --all -- --check"
  end

  desc "Run cargo clippy"
  task :clippy do
    sh "cd ext/ratatui_ruby && cargo clippy -- -D warnings"
  end

  desc "Run cargo tests"
  task :test do
    sh "cd ext/ratatui_ruby && cargo test"
  end
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
  multitask code: %i[rubocop rubycritic cargo:fmt cargo:clippy cargo:test]
  multitask licenses: %i[reuse:lint]
  multitask all: %i[docs code licenses]
end
task(:lint) { Rake::Task["lint:all"].invoke }

# Clear the default test task created by Minitest::TestTask
Rake::Task["test"].clear

desc "Run all tests (Ruby and Rust)"
task test: %w[test:ruby test:rust]

namespace :test do
  desc "Run Rust tests"
  task :rust do
    Rake::Task["cargo:test"].invoke
  end

  # Create a specific Minitest task for Ruby tests
  Minitest::TestTask.create(:ruby) do |t|
    t.test_globs = ["test/**/test_*.rb", "examples/**/test_*.rb"]
  end
end

multitask default: %i[test lint]
