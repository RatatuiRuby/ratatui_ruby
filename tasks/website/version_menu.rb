# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

class VersionMenu
  def initialize(root:, versions:)
    @root = root
    @versions = versions
  end

  def run
    puts "Injecting version menu into generated HTML..."
    
    # Process all HTML files in the output directory
    Dir.glob(File.join(@root, "**/*.html")).each do |file|
      inject_menu(file)
    end
  end

  private

  def inject_menu(file)
    content = File.read(file)
    
    # Find the injection point (before the theme toggle button)
    pattern = /(<button[^>]*id="theme-toggle"[^>]*>)/mi
    
    unless content.match?(pattern)
      # warn "Could not find theme-toggle in #{file}"
      return
    end

    # Calculate relative path to root from this file
    file_dir = File.dirname(file)
    relative_path_to_root = Pathname.new(@root).relative_path_from(Pathname.new(file_dir)).to_s
    relative_path_to_root += "/" unless relative_path_to_root.end_with?("/")
    
    # Determine current version from file path
    relative_path_from_root = Pathname.new(file).relative_path_from(Pathname.new(@root)).to_s
    current_version_slug = relative_path_from_root.split("/").first
    
    # Build options
    options = @versions.map do |version|
      value = "#{relative_path_to_root}#{version.slug}/index.html"
      selected = (version.slug == current_version_slug) ? "selected" : ""
      display_name = version.name
      display_name += " (latest)" if version.respond_to?(:latest?) && version.latest?
      display_name += " (dev)" if version.edge?
      
      %Q{<option value="#{value}" #{selected}>#{display_name}</option>}
    end.join("\n")
    
    # margin-left: auto pushes it to the right
    # margin-right: 1rem spacing from the theme toggle
    switcher_html = <<~HTML
      <select class="version-menu" onchange="window.location.href=this.value" style="margin-left: auto; padding: 0.25rem; border-radius: 4px; border: 1px solid #ccc; margin-right: 1rem;">
        #{options}
        <option value="#{relative_path_to_root}index.html">All Versions</option>
      </select>
    HTML
    
    # Inject before the button
    new_content = content.sub(pattern, "#{switcher_html}\n\\1")
    
    File.write(file, new_content)
  end
end
