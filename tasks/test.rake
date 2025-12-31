# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "minitest/test_task"

namespace :cargo do
  desc "Run cargo tests"
  task :test do
    sh "cd ext/ratatui_ruby && cargo test"
  end
end

# Clear the default test task created by Minitest::TestTask if it exists
Rake::Task["test"].clear if Rake::Task.task_defined?("test")

desc "Run all tests (Ruby and Rust)"
task test: %w[compile test:ruby test:rust]

namespace :test do
  desc "Run Rust tests"
  task :rust do
    Rake::Task["cargo:test"].invoke
  end

  # Create a specific Minitest task for Ruby tests
  Minitest::TestTask.create(:ruby) do |t|
    t.test_globs = ["test/**/*.rb", "examples/**/test_*.rb"]
  end
end
