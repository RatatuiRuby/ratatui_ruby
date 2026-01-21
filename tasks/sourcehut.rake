# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

desc "Generate SourceHut build manifests from template"
task sourcehut: "sourcehut:build"

namespace :sourcehut do
  desc "Build SourceHut manifests"
  task build: "sourcehut:build:manifest"

  namespace :build do
    desc "Generate SourceHut build manifests from template"
    task :manifest do
      require "erb"
      require "yaml"

      spec = Gem::Specification.load("ratatui_ruby.gemspec")

      # Read version directly from file to ensure we get the latest version
      # even if it was just bumped in the same Rake execution
      version_content = File.read("lib/ratatui_ruby/version.rb")
      version = version_content.match(/VERSION = "(.+?)"/)[1]

      # Normalize version using Gem::Version - RubyGems converts hyphens
      # (e.g., "1.0.0-beta.1" -> "1.0.0.pre.beta.1")
      normalized_version = Gem::Version.new(version).to_s

      gem_filename = "#{spec.name}-#{normalized_version}.gem"

      rubies = YAML.load_file("tasks/resources/rubies.yml")

      bundler_version = File.read("Gemfile.lock").match(/BUNDLED WITH\n\s+([\d.]+)/)[1]

      template = File.read("tasks/resources/build.yml.erb")
      erb = ERB.new(template, trim_mode: "-")

      FileUtils.mkdir_p ".builds"

      # Remove old generated files to ensure a clean state
      Dir.glob(".builds/*.yml").each { |f| File.delete(f) }

      rubies.each do |ruby_version|
        filename = ".builds/ruby-#{ruby_version}.yml"
        puts "Generating #{filename}..."
        gem_name = spec.name
        has_rust = File.exist?("ext/#{gem_name}/Cargo.toml")
        content = erb.result_with_hash(ruby_version:, gem_name:, gem_filename:, bundler_version:, has_rust:)
        File.write(filename, content)
      end
    end
  end

  desc "Update stable branch to match release and set as default"
  task :update_stable do
    # Read version to determine tag
    version_content = File.read("lib/ratatui_ruby/version.rb")
    version = version_content.match(/VERSION = "(.+?)"/)[1]
    tag_name = "v#{version}"

    # Verify that the version file matches the actual git tag
    # This prevents updating stable to the wrong version if the release failed
    latest_tag = `git describe --tags --abbrev=0`.strip
    if latest_tag != tag_name
      abort "Fatal: Version mismatch! 'lib/ratatui_ruby/version.rb' says #{tag_name}, but the latest git tag is #{latest_tag}."
    end

    puts "Updating stable branch to point to #{tag_name}..."
    # Resolve the tag to a commit hash (peel annotated tags)
    # This renders a commit SHA that can be pushed to a branch head
    commit_sha = `git rev-parse #{tag_name}^{}`.strip

    # Update local stable branch to match
    sh "git branch -f stable #{commit_sha}"

    # Push the commit to remote stable branch
    # This creates 'stable' if it doesn't exist, or fast-forwards it.
    sh "git push origin #{commit_sha}:stable"
  end
end

if Rake::Task.task_defined?("release")
  Rake::Task["release"].enhance do
    # Replace Bundler's normalized tag with semver-style for prerelease versions.
    # Bundler creates tags using normalized Gem::Version (e.g., v1.0.0.pre.beta.1).
    # Semver uses hyphens (e.g., v1.0.0-beta.1). We want only the semver tag.
    version_content = File.read("lib/ratatui_ruby/version.rb")
    version = version_content.match(/VERSION = "(.+?)"/)[1]

    if version.include?("-")
      normalized_tag = "v#{Gem::Version.new(version)}"
      semver_tag = "v#{version}"

      if normalized_tag != semver_tag
        puts "Replacing normalized tag #{normalized_tag} with semver tag #{semver_tag}..."
        # Delete the normalized tag locally and remotely
        sh "git tag -d #{normalized_tag}"
        sh "git push origin :refs/tags/#{normalized_tag}"
        # Create the semver tag pointing to the same commit
        sh "git tag #{semver_tag} HEAD"
        sh "git push origin #{semver_tag}"
      end
    end

    Rake::Task["sourcehut:update_stable"].invoke
  end
end
