# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "bundler/gem_tasks"
require "minitest/test_task"

# Ruby tests are handled by test:ruby
# Cargo tests are handled by test:rust

desc "Compile the Rust extension"
task :compile do
  Dir.chdir("ext/ratatui_ruby") do
    sh "cargo build --release"
    ext = OS.mac? ? "bundle" : "so"
    src_ext = OS.mac? ? "dylib" : "so"
    lib_path = "target/release/libratatui_ruby.#{src_ext}"
    if File.exist?(lib_path)
      mkdir_p "../../lib/ratatui_ruby"
      cp lib_path, "../../lib/ratatui_ruby/ratatui_ruby.#{ext}"
    end
  end
end

module OS
  def self.mac?
    (/darwin/ =~ RUBY_PLATFORM) != nil
  end
end

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
  Minitest::TestTask.create(:ruby)
end

multitask default: %i[test lint]
