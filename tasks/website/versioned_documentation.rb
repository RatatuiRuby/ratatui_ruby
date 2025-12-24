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

    @version.checkout(globs: globs) do |source_path|
      Dir.chdir(source_path) do
        title = "#{project_name} #{@version.name}"
        title = "#{project_name} (main)" if @version.edge?
        
        # We need to expand globs relative to the source path
        files = globs.flat_map { |glob| Dir[glob] }.uniq
        
        system(
          { "BUNDLE_GEMFILE" => gemfile_path },
          "bundle exec rdoc -o #{absolute_path} --main #{RDocConfig::MAIN} --title '#{title}' #{files.join(' ')}"
        )

        copy_assets_to(absolute_path, assets)
      end
    end
  end

  private

  def copy_assets_to(path, assets)
    assets.each do |asset_dir|
       if Dir.exist?(asset_dir)
         destination = File.join(path, asset_dir)
         FileUtils.mkdir_p(destination)
         FileUtils.cp_r Dir["#{asset_dir}/*"], destination
       end
    end
  end
end
