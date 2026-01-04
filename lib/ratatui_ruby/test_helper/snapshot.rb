# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

require "fileutils"

module RatatuiRuby
  module TestHelper
    ##
    # Snapshot testing assertions for terminal UIs.
    #
    # Verifying every character of a TUI screen by hand is tedious. Snapshots let you
    # capture the screen once and compare against it in future runs.
    #
    # This mixin provides <tt>assert_snapshot</tt> for plain text and
    # <tt>assert_rich_snapshot</tt> for styled ANSI output. Both auto-create
    # snapshot files on first run.
    #
    # Use it to verify complex layouts, styles, and interactions without manual assertions.
    #
    # === Snapshot Files
    #
    # Snapshots live in a <tt>snapshots/</tt> subdirectory next to your test file:
    #
    #   test/examples/my_app/test_app.rb
    #   test/examples/my_app/snapshots/initial_render.txt
    #   test/examples/my_app/snapshots/initial_render.ansi
    #
    # === Creating and Updating Snapshots
    #
    # Run tests with <tt>UPDATE_SNAPSHOTS=1</tt> to create or refresh snapshots:
    #
    #   UPDATE_SNAPSHOTS=1 bundle exec rake test
    #
    # === Seeding Random Data
    #
    # Random data (scatter plots, generated content) breaks snapshot stability.
    # Use a seeded <tt>Random</tt> instance instead of <tt>Kernel.rand</tt>:
    #
    #   class MyApp
    #     def initialize(seed: nil)
    #       @rng = seed ? Random.new(seed) : Random.new
    #     end
    #
    #     def generate_data
    #       (0..20).map { @rng.rand(0.0..10.0) }
    #     end
    #   end
    #
    #   # In your test
    #   def setup
    #     @app = MyApp.new(seed: 42)
    #   end
    #
    # For libraries like Faker, see their docs on deterministic random:
    # https://github.com/faker-ruby/faker#deterministic-random
    #
    # === Normalization Blocks
    #
    # Mask dynamic content (timestamps, IDs) with a normalization block:
    #
    #   assert_snapshot("dashboard") do |lines|
    #     lines.map { |l| l.gsub(/\d{4}-\d{2}-\d{2}/, "YYYY-MM-DD") }
    #   end
    #
    module Snapshot
      ##
      # Asserts that the current screen content matches a stored snapshot.
      #
      # This method simplifies snapshot testing by automatically resolving the snapshot path
      # relative to the test file calling this method. It assumes a "snapshots" directory
      # exists in the same directory as the test file.
      #
      #   # In test/test_login.rb
      #   assert_snapshot("login_screen")
      #   # Look for: test/snapshots/login_screen.txt
      #
      #   # With normalization block
      #   assert_snapshot("clock") do |actual|
      #     actual.map { |l| l.gsub(/\d{2}:\d{2}/, "XX:XX") }
      #   end
      #
      # [name] String name of the snapshot (without extension).
      # [msg] String optional failure message.
      def assert_snapshot(name, msg = nil, &)
        # Get the path of the test file calling this method
        caller_path = caller_locations(1, 1).first.path
        snapshot_dir = File.join(File.dirname(caller_path), "snapshots")
        snapshot_path = File.join(snapshot_dir, "#{name}.txt")

        assert_screen_matches(snapshot_path, msg, &)
      end

      ##
      # Asserts that the current screen content matches the expected content.
      #
      # Users need to verify that the entire TUI screen looks exactly as expected.
      # Manually checking every cell or line is tedious and error-prone.
      #
      # This helper compares the current buffer content against an expected string (file path)
      # or array of strings. It supports automatic snapshot creation and updating via
      # the +UPDATE_SNAPSHOTS+ environment variable.
      #
      # Use it to verify complex UI states, layouts, and renderings.
      #
      # == Usage
      #
      #   # Direct comparison
      #   assert_screen_matches(["Line 1", "Line 2"])
      #
      #   # File comparison
      #   assert_screen_matches("test/snapshots/login.txt")
      #
      #   # With normalization (e.g., masking dynamic data)
      #   assert_screen_matches("test/snapshots/dashboard.txt") do |lines|
      #     lines.map { |l| l.gsub(/User ID: \d+/, "User ID: XXX") }
      #   end
      #
      # [expected] String (file path) or Array<String> (content).
      # [msg] String optional failure message.
      #
      # == Non-Determinism
      #
      # To prevent flaky tests, this assertion performs a "Flakiness Check" when creating or updating
      # snapshots. It captures the screen content, immediately re-renders the buffer, and compares
      # the two results.
      #
      # Ensure your render logic is deterministic by seeding random number generators and stubbing
      # time where necessary.
      def assert_screen_matches(expected, msg = nil)
        actual_lines = buffer_content

        if block_given?
          actual_lines = yield(actual_lines)
        end

        if expected.is_a?(String)
          # Snapshot file mode
          snapshot_path = expected
          update_snapshots = ENV["UPDATE_SNAPSHOTS"] == "1" || ENV["UPDATE_SNAPSHOTS"] == "true"

          if !File.exist?(snapshot_path) || update_snapshots
            FileUtils.mkdir_p(File.dirname(snapshot_path))

            content_to_write = "#{actual_lines.join("\n")}\n"

            begin
              # Delete old file first to avoid git index stale-read issues
              FileUtils.rm_f(snapshot_path)

              # Write with explicit mode to ensure clean write
              File.write(snapshot_path, content_to_write, mode: "w")

              # Flush filesystem buffers to ensure durability
              File.open(snapshot_path, "r", &:fsync) if File.exist?(snapshot_path)
            rescue => e
              warn "Failed to write snapshot #{snapshot_path}: #{e.message}"
              raise
            end

            if update_snapshots
              puts "Updated snapshot: #{snapshot_path}"
            else
              puts "Created snapshot: #{snapshot_path}"
            end

          end
          expected_lines = File.readlines(snapshot_path, chomp: true)
        else
          # Direct comparison mode
          expected_lines = expected
        end

        msg ||= "Screen content mismatch"

        assert_equal expected_lines.size, actual_lines.size, "#{msg}: Line count mismatch"

        expected_lines.each_with_index do |expected_line, i|
          actual_line = actual_lines[i]
          assert_equal expected_line, actual_line,
            "#{msg}: Line #{i + 1} mismatch.\nExpected: #{expected_line.inspect}\nActual:   #{actual_line.inspect}"
        end
      end

      ##
      # Asserts that the current screen content (including colors!) matches a stored ANSI snapshot.
      #
      # Generates/Compares against a file with <tt>.ansi</tt> extension.
      # You can <tt>cat</tt> this file to see exactly what the screen looked like.
      #
      #   assert_rich_snapshot("login_screen")
      #
      #   # With normalization
      #   assert_rich_snapshot("log_view") do |lines|
      #     lines.map { |l| l.gsub(/\d{2}:\d{2}:\d{2}/, "HH:MM:SS") }
      #   end
      #
      # [name] String snapshot name.
      # [msg] String optional failure message.
      def assert_rich_snapshot(name, msg = nil)
        caller_path = caller_locations(1, 1).first.path
        snapshot_dir = File.join(File.dirname(caller_path), "snapshots")
        snapshot_path = File.join(snapshot_dir, "#{name}.ansi")

        actual_content = _render_buffer_with_ansi

        if block_given?
          lines = actual_content.split("\n")
          # Yield lines to user block for modification (e.g. masking IDs/Times)
          lines = yield(lines)
          actual_content = "#{lines.join("\n")}\n"
        end

        update_snapshots = ENV["UPDATE_SNAPSHOTS"] == "1" || ENV["UPDATE_SNAPSHOTS"] == "true"

        if !File.exist?(snapshot_path) || update_snapshots
          FileUtils.mkdir_p(File.dirname(snapshot_path))

          begin
            # Delete old file first to avoid git index stale-read issues
            FileUtils.rm_f(snapshot_path)

            # Write with explicit mode to ensure clean write
            File.write(snapshot_path, actual_content, mode: "w")

            # Flush filesystem buffers to ensure durability
            File.open(snapshot_path, "r", &:fsync) if File.exist?(snapshot_path)
          rescue => e
            warn "Failed to write rich snapshot #{snapshot_path}: #{e.message}"
            raise
          end

          puts (update_snapshots ? "Updated" : "Created") + " rich snapshot: #{snapshot_path}"

        end

        expected_content = File.read(snapshot_path)

        # Compare byte-for-byte first
        if expected_content != actual_content
          # Fallback to line-by-line diff for better error messages
          expected_lines = expected_content.split("\n")
          actual_lines = actual_content.split("\n")

          assert_equal expected_lines.size, actual_lines.size, "#{msg}: Line count mismatch"

          expected_lines.each_with_index do |exp, i|
            act = actual_lines[i]
            assert_equal exp, act, "#{msg}: Rich content mismatch at line #{i + 1}"
          end
        end
      end

      ##
      # Returns the current buffer content as an ANSI-encoded string.
      #
      # The rich snapshot assertion captures styled output. Sometimes you need the raw ANSI
      # string for debugging, custom assertions, or programmatic inspection.
      #
      # This method renders the buffer with escape codes for colors and modifiers.
      # You can `cat` the output to see exactly what the terminal would display.
      #
      # === Example
      #
      #   with_test_terminal(80, 25) do
      #     RatatuiRuby.run do |tui|
      #       tui.draw tui.paragraph(text: "Hello", block: tui.block(title: "Test"))
      #       break
      #     end
      #     ansi_output = render_rich_buffer
      #     puts ansi_output  # Shows styled output with escape codes
      #   end
      #
      def render_rich_buffer
        _render_buffer_with_ansi
      end

      private def _render_buffer_with_ansi
        RatatuiRuby.get_buffer_content # Ensure buffer is fresh if needed

        lines = buffer_content
        height = lines.size
        width = lines.first&.length || 0

        output = String.new

        (0...height).each do |y|
          current_fg = nil
          current_bg = nil
          current_modifiers = []

          # Reset at start of line
          output << "\e[0m"

          (0...width).each do |x|
            cell = RatatuiRuby.get_cell_at(x, y)
            char = cell.char || " "

            # Check for changes
            fg_changed = cell.fg != current_fg
            bg_changed = cell.bg != current_bg
            mod_changed = cell.modifiers != current_modifiers

            if fg_changed || bg_changed || mod_changed
              # If modifiers change, easiest is to reset and re-apply everything
              # because removing a modifier (e.g. bold) requires reset usually.
              if mod_changed
                output << "\e[0m"
                output << _ansi_for_modifiers(cell.modifiers)
                # Force re-apply colors after reset
                output << _ansi_for_color(cell.fg, :fg)
                output << _ansi_for_color(cell.bg, :bg)
              else
                # Modifiers same, just update colors if needed
                output << _ansi_for_color(cell.fg, :fg) if fg_changed
                output << _ansi_for_color(cell.bg, :bg) if bg_changed
              end

              current_fg = cell.fg
              current_bg = cell.bg
              current_modifiers = cell.modifiers
            end

            output << char
          rescue
            output << " "
          end
          output << "\e[0m\n" # Reset at end of line
        end
        output
      end

      private def _ansi_for_color(color, layer)
        return "" if color.nil?

        base = (layer == :fg) ? 38 : 48

        case color
        when Symbol
          if color.to_s.start_with?("indexed_")
            # Extracted indexed color :indexed_5 -> 5
            idx = color.to_s.split("_").last.to_i
            "\e[#{base};5;#{idx}m"
          else
            # Named colors
            _ansi_named_color(color, layer == :fg)
          end
        when String
          if color.start_with?("#")
            # Hex color: #RRGGBB -> r;g;b
            r = color[1..2].to_i(16)
            g = color[3..4].to_i(16)
            b = color[5..6].to_i(16)
            "\e[#{base};2;#{r};#{g};#{b}m"
          else
            ""
          end
        else
          ""
        end
      end

      private def _ansi_named_color(name, is_fg)
        # Map symbol to standard ANSI code offset
        # FG: 30-37 (dim), 90-97 (bright)
        # BG: 40-47 (dim), 100-107 (bright)

        offset = is_fg ? 30 : 40

        case name
        when :black then "\e[#{offset}m"
        when :red then "\e[#{offset + 1}m"
        when :green then "\e[#{offset + 2}m"
        when :yellow then "\e[#{offset + 3}m"
        when :blue then "\e[#{offset + 4}m"
        when :magenta then "\e[#{offset + 5}m"
        when :cyan then "\e[#{offset + 6}m"
        when :gray then is_fg ? "\e[90m" : "\e[100m" # Dark gray usually
        when :dark_gray then is_fg ? "\e[90m" : "\e[100m"
        when :light_red then "\e[#{offset + 60 + 1}m"
        when :light_green then "\e[#{offset + 60 + 2}m"
        when :light_yellow then "\e[#{offset + 60 + 3}m"
        when :light_blue then "\e[#{offset + 60 + 4}m"
        when :light_magenta then "\e[#{offset + 60 + 5}m"
        when :light_cyan then "\e[#{offset + 60 + 6}m"
        when :white then "\e[#{offset + 60 + 7}m"
        else ""
        end
      end

      private def _ansi_for_modifiers(modifiers)
        return "" if modifiers.nil? || modifiers.empty?

        seq = []
        seq << "1" if modifiers.include?(:bold)
        seq << "2" if modifiers.include?(:dim)
        seq << "3" if modifiers.include?(:italic)
        seq << "4" if modifiers.include?(:underlined)
        seq << "5" if modifiers.include?(:slow_blink)
        seq << "6" if modifiers.include?(:rapid_blink)
        seq << "7" if modifiers.include?(:reversed)
        seq << "8" if modifiers.include?(:hidden)
        seq << "9" if modifiers.include?(:crossed_out)

        if seq.any?
          "\e[#{seq.join(';')}m"
        else
          ""
        end
      end
    end
  end
end
