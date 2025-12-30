# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "fileutils"
require "tmpdir"

namespace :terminal_preview do
  def self.class_name_for(dir_name)
    dir_name.split("_").map(&:capitalize).join + "App"
  end

  class MacCapturer
    def self.capture(app_path, output_path)
      repo_root = Dir.pwd
      
      # 1. CREATE LAUNCHER SCRIPT
      launcher_path = File.join(Dir.tmpdir, "preview_launcher.sh")
      
      File.open(launcher_path, "w") do |f|
        f.puts "#!/bin/zsh"
        f.puts "cd '#{repo_root}'"
        f.puts "clear"
        f.puts "exec bundle exec ruby '#{app_path}'"
      end
      FileUtils.chmod(0755, launcher_path)

      # 2. OPEN WINDOW (AppleScript)
      setup_script = <<~APPLESCRIPT
        tell application "Terminal"
          set newTab to do script "#{launcher_path}"
          set currentWindow to window 1
          
          set number of rows of currentWindow to 24
          set number of columns of currentWindow to 80
          set position of currentWindow to {100, 100}
          set frontmost of currentWindow to true
          
          return id of currentWindow
        end tell
      APPLESCRIPT

      window_id = `osascript -e '#{setup_script}'`.strip

      # Wait for app to boot (0.8s is usually enough for local Ruby)
      sleep 0.8 

      # 3. CAPTURE
      if !window_id.empty? && window_id.match?(/^\d+$/)
        system("screencapture -l #{window_id} -o -x '#{output_path}'")
      else
        puts "    Error: Invalid Window ID '#{window_id}'"
      end

      # 4. CLEAN QUIT (Ctrl+C)
      cleanup_script = <<~APPLESCRIPT
        tell application "Terminal"
          try
            -- Send ASCII 3 (Ctrl+C) to force-quit the process cleanly.
            do script (ASCII character 3) in window id #{window_id}
          end try
          
          -- Tiny pause to let the signal process
          delay 0.1
          
          close window id #{window_id}
        end tell
      APPLESCRIPT
      
      system("osascript", "-e", cleanup_script)
    end
  end

  def self.example_directories
    examples_dir = File.expand_path("../examples", __dir__)
    Dir.glob("#{examples_dir}/*/app.rb").map do |path|
      File.basename(File.dirname(path))
    end.sort
  end

  desc "Generate native PNG screenshots using Terminal.app"
  task generate: :compile do
    unless RUBY_PLATFORM =~ /darwin/
      abort "Error: This task requires macOS."
    end

    img_dir = File.expand_path("../doc/images", __dir__)
    FileUtils.mkdir_p(img_dir)
    
    # --- SAFETY CHECK ---
    puts "\n" + "="*60
    puts "  📸  NATIVE TERMINAL CAPTURE  📸"
    puts "="*60
    puts "This task will:"
    puts "  1. Take control of your mouse/keyboard focus"
    puts "  2. Rapidly open and close Terminal windows"
    puts "  3. Capture #{example_directories.count} screenshots"
    puts "\n⚠️  PLEASE DO NOT TOUCH YOUR COMPUTER WHILE THIS RUNS."
    puts "   (Estimated time: ~#{example_directories.count * 1.5} seconds)"
    puts
    print "Press [ENTER] to start... "
    $stdin.gets
    puts "\nHere we go!"

    example_directories.each do |dir_name|
      print "  📸 #{dir_name}..."
      
      app_path = "examples/#{dir_name}/app.rb"
      out_path = File.join(img_dir, "#{dir_name}.png")
      
      begin
        MacCapturer.capture(app_path, out_path)
        puts " done."
        # Minimal cooldown to ensure window focus switches correctly
        sleep 0.2
      rescue => e
        puts " FAILED: #{e.message}"
      end
    end
    
    puts "\n✨ All captures complete. Check doc/images/."
  end

  desc "Update markdown docs to link to the new PNGs"
  task update_docs: :generate do
    quickstart_path = File.expand_path("../doc/quickstart.md", __dir__)
    content = File.read(quickstart_path)
    
    example_directories.each do |name|
      # MATCHES:
      # 1. <pre class="..." data-example="name">...</pre> (Current state)
      # 2. <div class="..." data-example="name">...</div> (Previous intermediate state)
      # 3. ![...](...name.png) (Future state / idempotency)
      block_pattern = /(<(pre|div)[^>]*data-example="#{Regexp.escape(name)}"[^>]*>.*?<\/\2>|!\[.*?\]\(.*?#{Regexp.escape(name)}\.(svg|png)\))/m
      
      replacement = "![#{name} example](images/#{name}.png)"
      
      if content.match?(block_pattern)
        content.gsub!(block_pattern, replacement)
        puts "Linked Native PNG for: #{name}"
      end
    end
    
    File.write(quickstart_path, content)
    puts "Docs updated."
  end
end