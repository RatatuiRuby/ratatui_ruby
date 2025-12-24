# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "version"
require_relative "versioned_documentation"
require_relative "index_page"
require_relative "version_menu"
require "fileutils"

class Website
  def initialize(at: "public", project_name:, globs:, assets: [])
    @destination = at
    @project_name = project_name
    @globs = globs
    @assets = assets
  end

  def build
    clean
    
    versions.each do |version|
      VersionedDocumentation.new(version).publish_to(
        join(version.slug), 
        project_name: @project_name, 
        globs: @globs,
        assets: @assets
      )
    end

    IndexPage.new(versions).publish_to(join("index.html"), project_name: @project_name)

    VersionMenu.new(root: @destination, versions: versions).run

    puts "Website built in #{@destination}/"
  end

  def versions
    @versions ||= Version.all
  end

  private

  def join(path)
    File.join(@destination, path)
  end

  def clean
    FileUtils.rm_rf(@destination)
    FileUtils.mkdir_p(@destination)
  end
end
