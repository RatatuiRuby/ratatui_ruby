# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "rubocop/rake_task"
require "rubycritic/rake_task"
require "inch/rake"

RuboCop::RakeTask.new

RubyCritic::RakeTask.new do |task|
  task.options = "--no-browser"
  task.paths = FileList.new.include("exe/**/*.rb", "lib/**/*.rb", "sig/**/*.rbs")
end

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
end

namespace :reuse do
  desc "Run the REUSE Tool to confirm REUSE compliance"
  task :lint do
    sh "reuse lint"
  end
end
task(:reuse) { Rake::Task["reuse:lint"].invoke }

namespace :lint do
  task docs: %w[rubycritic rdoc:coverage reuse:lint]
  task code: %w[rubocop rubycritic cargo:fmt cargo:clippy cargo:test]
  task licenses: %w[reuse:lint]
  task all: %w[docs code licenses]
end

desc "Run all lint tasks"
task(:lint) { Rake::Task["lint:all"].invoke }
