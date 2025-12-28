# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

desc "Generate SourceHut build manifests from template"
task :sourcehut do
  require "erb"
  require "yaml"

  spec = Gem::Specification.load("ratatui_ruby.gemspec")
  
  # Read version directly from file to ensure we get the latest version
  # even if it was just bumped in the same Rake execution
  version_content = File.read("lib/ratatui_ruby/version.rb")
  version = version_content.match(/VERSION = "(.+?)"/)[1]
  
  gem_filename = "#{spec.name}-#{version}.gem"

  rubies = YAML.load_file("tasks/resources/rubies.yml")
  template = File.read("tasks/resources/build.yml.erb")
  erb = ERB.new(template, trim_mode: "-")

  FileUtils.mkdir_p ".builds"

  # Remove old generated files to ensure a clean state
  Dir.glob(".builds/*.yml").each { |f| File.delete(f) }

  rubies.each do |ruby_version|
    filename = ".builds/ruby-#{ruby_version}.yml"
    puts "Generating #{filename}..."
    content = erb.result_with_hash(ruby_version:, gem_filename:)
    File.write(filename, content)
  end
end
