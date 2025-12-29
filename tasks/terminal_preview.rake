# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "ratatui_ruby"
require "ratatui_ruby/test_helper"

namespace :terminal_preview do
  # Derives the class name from the directory name using convention.
  # e.g., "analytics" => "AnalyticsApp", "block_padding" => "BlockPaddingApp"
  def self.class_name_for(dir_name)
    dir_name.split("_").map(&:capitalize).join + "App"
  end

  # Helper class to capture terminal buffer
  class Capturer
    include RatatuiRuby::TestHelper

    def capture(dir_name, class_name)
      app_path = File.expand_path("../examples/#{dir_name}/app.rb", __dir__)
      require app_path

      app_class = Object.const_get(class_name)
      app = app_class.new

      result = nil
      with_test_terminal do
        # All examples should handle ctrl_c for quitting
        inject_key(:ctrl_c)
        # Run the app (it will quit immediately due to injected key)
        app.run
        result = buffer_content.join("\n")
      end
      result
    end
  end

  # Find all example directories that have an app.rb file
  def self.example_directories
    examples_dir = File.expand_path("../examples", __dir__)
    Dir.glob("#{examples_dir}/*/app.rb").map do |path|
      File.basename(File.dirname(path))
    end.sort
  end

  desc "Capture terminal buffer text for all examples"
  task capture: :compile do
    capturer = Capturer.new
    @captured_previews = {}

    example_directories.each do |dir_name|
      class_name = class_name_for(dir_name)
      print "Capturing #{dir_name} (#{class_name})..."
      begin
        @captured_previews[dir_name] = capturer.capture(dir_name, class_name)
        puts " done"
      rescue => e
        puts " FAILED: #{e.message}"
        @captured_previews[dir_name] = "[Capture failed: #{e.message}]"
      end
    end
  end

  desc "Output captured terminal previews to stdout"
  task stdout: :capture do
    @captured_previews.each do |name, content|
      puts "=" * 80
      puts "Example: #{name}"
      puts "=" * 80
      puts content
      puts
    end
  end

  desc "Update quickstart.md with terminal previews"
  task update: :capture do
    quickstart_path = File.expand_path("../doc/quickstart.md", __dir__)
    content = File.read(quickstart_path)

    @captured_previews.each do |name, preview|
      # Replace content in pre tags with data-example attribute
      marker_pattern = /<pre class="terminal-preview" data-example="#{Regexp.escape(name)}">\n.*?\n<\/pre>/m
      replacement = <<~HTML.chomp
        <pre class="terminal-preview" data-example="#{name}">
        #{preview}
        </pre>
      HTML

      if content.match?(marker_pattern)
        content.gsub!(marker_pattern, replacement)
        puts "Updated: #{name}"
      else
        puts "WARNING: Pre tag not found for #{name}"
      end
    end

    File.write(quickstart_path, content)
    puts "Wrote #{quickstart_path}"
  end
end
