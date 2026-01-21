# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

require "rubocop/rake_task"
require "rubycritic/rake_task"
require "inch/rake"

RuboCop::RakeTask.new

# Run rubycritic in a shell to prevent it from exiting the rake process
task :rubycritic do
  sh "bundle exec rubycritic --no-browser exe lib sig"
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

  desc "Add SPDX headers to files missing them (per AGENTS.md standards)"
  task :fix do
    copyright = "Kerrick Long <me@kerricklong.com>"

    # Code files: AGPL-3.0-or-later
    code_extensions = %w[rb rs rake gemspec rbs toml yml yaml json lock].freeze
    code_license = "AGPL-3.0-or-later"

    # Documentation files: CC-BY-SA-4.0
    doc_extensions = %w[md txt].freeze
    doc_license = "CC-BY-SA-4.0"

    # Find files missing headers (listed after "no copyright and licensing" message)
    puts "Checking for files missing REUSE headers..."
    output = `reuse lint 2>&1`
    in_missing_section = false
    missing_files = output.lines.filter_map do |line|
      in_missing_section = true if line.include?("no copyright and licensing")
      in_missing_section = false if line.start_with?("# ") && !line.include?("copyright")
      next unless in_missing_section

      line.match(/^\* (.+)/)&.[](1)
    end

    if missing_files.empty?
      puts "All files have REUSE headers!"
    else
      missing_files.each do |file|
        ext = File.extname(file).delete(".")
        license = if code_extensions.include?(ext)
          code_license
        elsif doc_extensions.include?(ext)
          doc_license
        else
          puts "  Skipping #{file} (unknown extension: .#{ext})"
          next
        end

        puts "  Annotating #{file} with #{license}"
        sh "reuse annotate --license #{license} --copyright '#{copyright}' --skip-existing '#{file}'", verbose: false
      end
    end
  end

  desc "Normalize Ruby files: frozen_string_literal at top, SPDX in #--/#++ block"
  task :normalize_ruby do
    ruby_extensions = %w[rb rake gemspec].freeze
    # Exclude intentionally-formatted files
    excluded_files = %w[examples/verify_website_menu/app.rb].freeze
    ruby_files = Dir.glob("**/*.{#{ruby_extensions.join(',')}}")
      .reject { |f| f.start_with?("vendor/", "tmp/", ".") || excluded_files.include?(f) }

    fixed_count = 0
    ruby_files.each do |file|
      content = File.read(file)
      original = content.dup

      # Skip if no SPDX header
      next unless content.match?(/# SPDX-/)

      # Extract components
      frozen = content.match?(/^# frozen_string_literal: true/)
      spdx_match = content.match(/(# SPDX-FileCopyrightText:[^\n]+\n(?:#[^\n]*\n)*# SPDX-License-Identifier:[^\n]+\n)/m)
      next unless spdx_match

      spdx_block = spdx_match[1]

      # Remove existing frozen_string_literal and SPDX block (and any #--/#+++)
      cleaned = content
        .sub(/^# frozen_string_literal: true\n+/, "")
        .sub(/^#--\s*\n/, "")
        .sub(spdx_block, "")
        .sub(/^#\+\+\s*\n/, "")
        .sub(/\A\n+/, "") # Remove leading blank lines

      # Rebuild file in correct order: frozen, blank, #--, SPDX, #++, rest
      new_content = ""
      new_content += "# frozen_string_literal: true\n\n" if frozen
      new_content += "#--\n#{spdx_block}#++\n\n"
      new_content += cleaned.sub(/\A\n+/, "") # Ensure no double blank lines

      if new_content != original
        File.write(file, new_content)
        puts "  Normalized #{file}"
        fixed_count += 1
      end
    end

    puts fixed_count.zero? ? "All Ruby files properly normalized!" : "Fixed #{fixed_count} files."
  end
end
task(:reuse) { Rake::Task["reuse:lint"].invoke }

namespace :lint do
  task :safe_rdoc_coverage do
    sh "bundle exec rake rdoc:coverage"
  end

  task docs: %w[autodoc rubycritic safe_rdoc_coverage reuse:lint]
  task code: %w[rubocop rubycritic cargo:fmt cargo:clippy cargo:test]
  task licenses: %w[reuse:lint]
  task all: %w[docs code licenses]

  namespace :fix do
    desc "Auto-fix RuboCop offenses (most aggressive)"
    task :rubocop do
      sh "bundle exec rubocop --autocorrect-all"
    end

    desc "Auto-fix Clippy warnings (most aggressive: --fix --allow-dirty --allow-staged)"
    task :clippy do
      sh "cd ext/ratatui_ruby && cargo clippy --fix --allow-dirty --allow-staged"
    end

    desc "Add SPDX headers and normalize Ruby file structure"
    task reuse: %w[reuse:fix reuse:normalize_ruby]

    desc "Run all auto-fix tasks"
    task all: %w[lint:fix:rubocop lint:fix:clippy lint:fix:reuse]
  end
end

desc "Run all lint auto-fix tasks"
task("lint:fix") { Rake::Task["lint:fix:all"].invoke }

# Aliases for convenience
task "rubocop:autocorrect_all" => "lint:fix:rubocop"

desc "Run all lint tasks"
task(:lint) { Rake::Task["lint:all"].invoke }
