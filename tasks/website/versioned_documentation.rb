# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "../rdoc_config"

class VersionedDocumentation
  def initialize(version)
    @version = version
  end

  def publish_to(path, project_name:, globs:, assets: [])
    puts "Building documentation for #{@version.name}..."

    absolute_path = File.absolute_path(path)
    gemfile_path = File.absolute_path("Gemfile")
    custom_css_path = File.absolute_path("doc/custom.css")
    rakefile_path = File.absolute_path("Rakefile")
    tasks_dir_path = File.absolute_path("tasks")

    @version.checkout(globs:) do |source_path|
      # Copy current Rakefile and tasks into the temp directory
      # This ensures all versions use the latest example generation logic
      FileUtils.cp(rakefile_path, File.join(source_path, "Rakefile"))
      FileUtils.cp_r(tasks_dir_path, File.join(source_path, "tasks"))

      Dir.chdir(source_path) do
        title = "#{project_name} #{@version.name}"
        title = "#{project_name} (main)" if @version.edge?

        # Use rake rerdoc to ensure copy_examples runs
        # Set environment variables to override rdoc settings
        success = system(
          {
            "BUNDLE_GEMFILE" => gemfile_path,
            "RDOC_OUTPUT" => absolute_path,
            "RDOC_TITLE" => title,
            "RDOC_CUSTOM_CSS" => custom_css_path,
          },
          "bundle exec rake rerdoc"
        )

        # Fall back to direct rdoc call if rake fails for any reason
        unless success
          puts "  Rake task failed, falling back to direct rdoc call..."
          files = globs.flat_map { |glob| Dir[glob] }.uniq
          system(
            { "BUNDLE_GEMFILE" => gemfile_path },
            "bundle exec rdoc -o #{absolute_path} --main #{RDocConfig::MAIN} --title '#{title}' --template-stylesheets \"#{custom_css_path}\" #{files.join(' ')}"
          )
        end

        # Copy generated documentation to target path if it was generated elsewhere
        # This handles cases where RDOC_OUTPUT wasn't respected (evaluated at load time)
        temp_output_paths = ["tmp/rdoc", "doc"]
        temp_output_paths.each do |temp_path|
          # Check if this looks like generated rdoc (has index.html)
          if Dir.exist?(temp_path) && !Dir.empty?(temp_path) && File.exist?(File.join(temp_path, "index.html"))
            puts "  Copying generated docs from #{temp_path} to #{absolute_path}..."
            FileUtils.mkdir_p(absolute_path)
            FileUtils.cp_r Dir["#{temp_path}/*"], absolute_path
            break
          end
        end

        copy_assets_to(absolute_path, assets)
      end
    end
  end

  private def copy_assets_to(path, assets)
    assets.each do |asset_dir|
      if Dir.exist?(asset_dir)
        destination = File.join(path, asset_dir)
        FileUtils.mkdir_p(destination)
        FileUtils.cp_r Dir["#{asset_dir}/*"], destination
      end
    end
  end
end
