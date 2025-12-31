# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "erb"

class IndexPage
  def initialize(versions)
    @versions = versions

    latest_version = @versions.find { |v| v.is_a?(Tagged) }
    latest_version.is_latest = true if latest_version
  end

  def publish_to(path, project_name:)
    puts "Generating index page..."

    template_path = File.expand_path("../resources/index.html.erb", __dir__)
    template = File.read(template_path)

    versions = @versions
    # project_name is used in the ERB
    html_content = ERB.new(template).result(binding)

    File.write(path, html_content)
  end
end
