# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

namespace :license do
  namespace :headers do
    desc "Ensure markdown files have correct CC-BY-SA-4.0 headers"
    task :md, [:files] do |_t, args|
      files = args[:files] || ""
      ruby "tasks/license/headers_md.rb #{files}"
    end

    desc "Ensure Ruby files have correct AGPL-3.0-or-later headers"
    task :rb, [:files] do |_t, args|
      files = args[:files] || ""
      ruby "tasks/license/headers_rb.rb #{files}"
    end

    desc "Ensure all files have correct license headers"
    task :all do
      Rake::Task["license:headers:md"].invoke
      Rake::Task["license:headers:rb"].invoke
    end
  end

  namespace :snippets do
    desc "Add MIT-0 SPDX snippet headers to markdown fenced code blocks"
    task :md, [:files] do |_t, args|
      files = args[:files] || ""
      ruby "tasks/license/snippets_md.rb #{files}"
    end

    desc "Add MIT-0 SPDX snippet headers to RDoc code examples in Ruby files"
    task :rdoc, [:files] do |_t, args|
      files = args[:files] || "lib/"
      ruby "tasks/license/snippets_rdoc.rb #{files}"
    end

    desc "Add MIT-0 SPDX snippet headers to all code examples"
    task :all do
      Rake::Task["license:snippets:md"].invoke
      Rake::Task["license:snippets:rdoc"].invoke
    end
  end

  desc "Run all license tasks (headers + snippets)"
  task all: ["headers:all", "snippets:all"]

  desc "Run license tasks on changed files only (staged + unstaged)"
  task :new do
    # Get changed .md and .rb files (staged and unstaged)
    changed_md = `git diff --name-only --diff-filter=ACMR HEAD -- '*.md' 2>/dev/null`.split("\n")
    staged_md = `git diff --name-only --cached --diff-filter=ACMR -- '*.md' 2>/dev/null`.split("\n")
    changed_rb = `git diff --name-only --diff-filter=ACMR HEAD -- '*.rb' 2>/dev/null`.split("\n")
    staged_rb = `git diff --name-only --cached --diff-filter=ACMR -- '*.rb' 2>/dev/null`.split("\n")

    # Also get untracked new files
    untracked = `git ls-files --others --exclude-standard`.split("\n")
    untracked_md = untracked.select { |f| f.end_with?(".md") }
    untracked_rb = untracked.select { |f| f.end_with?(".rb") }

    md_files = (changed_md + staged_md + untracked_md).uniq.join(" ")
    rb_files = (changed_rb + staged_rb + untracked_rb).uniq

    # Filter rb files to only lib/
    lib_rb_files = rb_files.select { |f| f.start_with?("lib/") }.join(" ")

    if md_files.empty? && lib_rb_files.empty?
      puts "No changed .md or lib/*.rb files to process"
    else
      unless md_files.empty?
        puts "Processing #{md_files.split.count} changed .md file(s)..."
        Rake::Task["license:headers:md"].invoke(md_files)
        Rake::Task["license:headers:md"].reenable
        Rake::Task["license:snippets:md"].invoke(md_files)
        Rake::Task["license:snippets:md"].reenable
      end

      unless lib_rb_files.empty?
        puts "Processing #{lib_rb_files.split.count} changed lib/*.rb file(s)..."
        Rake::Task["license:headers:rb"].invoke(lib_rb_files)
        Rake::Task["license:headers:rb"].reenable
        Rake::Task["license:snippets:rdoc"].invoke(lib_rb_files)
        Rake::Task["license:snippets:rdoc"].reenable
      end
    end
  end
end
