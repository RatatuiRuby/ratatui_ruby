# frozen_string_literal: true

require "timeout"
require "minitest/mock"
require "fileutils"

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  ##
  # Helpers for testing RatatuiRuby applications.
  #
  # This module provides methods to set up a test terminal, capture buffer content,
  # and inject events, making it easier to write unit tests for your TUI apps.
  #
  # == Usage
  #
  #   require "ratatui_ruby/test_helper"
  #
  #   class MyTest < Minitest::Test
  #     include RatatuiRuby::TestHelper
  #
  #     def test_rendering
  #       with_test_terminal(80, 24) do
  #         # ... render your app ...
  #         assert_includes buffer_content, "Hello World"
  #       end
  #     end
  #
  #     def test_key_handling
  #       inject_event(RatatuiRuby::Event::Key.new(code: "q"))
  #       result = @app.handle_input
  #       assert_equal :quit, result
  #     end
  #   end
  module TestHelper
    ##
    # Initializes a test terminal context with specified dimensions.
    # Restores the original terminal state after the block executes.
    #
    # +width+:: width of the test terminal (default: 80)
    # +height+:: height of the test terminal (default: 24)
    #
    # +timeout+:: maximum execution time in seconds (default: 2). Pass nil to disable.
    #
    # If a block is given, it is executed within the test terminal context.
    def with_test_terminal(width = 80, height = 24, **opts)
      RatatuiRuby.init_test_terminal(width, height)
      # Flush any lingering events from previous tests
      while (event = RatatuiRuby.poll_event) && !event.none?; end

      RatatuiRuby.stub :init_terminal, nil do
        RatatuiRuby.stub :restore_terminal, nil do
          @_ratatui_test_terminal_active = true
          timeout = opts.fetch(:timeout, 2)
          if timeout
            Timeout.timeout(timeout) do
              yield
            end
          else
            yield
          end
        ensure
          @_ratatui_test_terminal_active = false
        end
      end
    ensure
      RatatuiRuby.restore_terminal
    end

    ##
    # Returns the current content of the terminal buffer as an array of strings.
    # Each string represents a row in the terminal.
    #
    #   buffer_content
    #   # => ["Row 1 text", "Row 2 text", ...]
    def buffer_content
      RatatuiRuby.get_buffer_content.split("\n")
    end

    ##
    # Returns the current cursor position as a hash with +:x+ and +:y+ keys.
    #
    #   cursor_position
    #   # => { x: 0, y: 0 }
    def cursor_position
      x, y = RatatuiRuby.get_cursor_position
      { x:, y: }
    end

    ##
    # Injects an event into the event queue for testing.
    #
    # Pass any RatatuiRuby::Event object. The event will be returned by
    # the next call to RatatuiRuby.poll_event.
    #
    # Raises a +RuntimeError+ if called outside of a +with_test_terminal+ block.
    #
    # == Examples
    #
    #   with_test_terminal do
    #     # Key events
    #     inject_event(RatatuiRuby::Event::Key.new(code: "q"))
    #     inject_event(RatatuiRuby::Event::Key.new(code: "s", modifiers: ["ctrl"]))
    #
    #     # Mouse events
    #     inject_event(RatatuiRuby::Event::Mouse.new(kind: "down", button: "left", x: 10, y: 5))
    #
    #     # Resize events
    #     inject_event(RatatuiRuby::Event::Resize.new(width: 120, height: 40))
    #
    #     # Paste events
    #     inject_event(RatatuiRuby::Event::Paste.new(content: "Hello"))
    #
    #     # Focus events
    #     inject_event(RatatuiRuby::Event::FocusGained.new)
    #     inject_event(RatatuiRuby::Event::FocusLost.new)
    #   end
    def inject_event(event)
      unless @_ratatui_test_terminal_active
        raise "Events must be injected inside a `with_test_terminal` block. " \
          "Calling this method outside the block causes a race condition where the event " \
          "is flushed before the application starts."
      end

      case event
      when RatatuiRuby::Event::Key
        RatatuiRuby.inject_test_event("key", { code: event.code, modifiers: event.modifiers })
      when RatatuiRuby::Event::Mouse
        RatatuiRuby.inject_test_event("mouse", {
          kind: event.kind,
          button: event.button,
          x: event.x,
          y: event.y,
          modifiers: event.modifiers,
        })
      when RatatuiRuby::Event::Resize
        RatatuiRuby.inject_test_event("resize", { width: event.width, height: event.height })
      when RatatuiRuby::Event::Paste
        RatatuiRuby.inject_test_event("paste", { content: event.content })
      when RatatuiRuby::Event::FocusGained
        RatatuiRuby.inject_test_event("focus_gained", {})
      when RatatuiRuby::Event::FocusLost
        RatatuiRuby.inject_test_event("focus_lost", {})
      else
        raise ArgumentError, "Unknown event type: #{event.class}"
      end
    end

    ##
    # Injects a mouse event.
    #
    #   inject_mouse(x: 10, y: 5, kind: :down, button: :left)
    def inject_mouse(x:, y:, kind: :down, modifiers: [], button: :left)
      event = RatatuiRuby::Event::Mouse.new(
        kind: kind.to_s,
        x:,
        y:,
        button: button.to_s,
        modifiers:
      )
      inject_event(event)
    end

    ##
    # Injects a mouse left click (down) event.
    #
    #   inject_click(x: 10, y: 5)
    def inject_click(x:, y:, modifiers: [])
      inject_mouse(x:, y:, kind: :down, modifiers:, button: :left)
    end

    ##
    # Injects a mouse right click (down) event.
    #
    #   inject_right_click(x: 10, y: 5)
    def inject_right_click(x:, y:, modifiers: [])
      inject_mouse(x:, y:, kind: :down, modifiers:, button: :right)
    end

    ##
    # Injects a mouse drag event.
    #
    #   inject_drag(x: 10, y: 5)
    def inject_drag(x:, y:, modifiers: [], button: :left)
      inject_mouse(x:, y:, kind: :drag, modifiers:, button:)
    end

    ##
    # Injects multiple Key events into the queue.
    #
    # Supports multiple formats for convenience:
    #
    # * String: Converted to a Key event with that code.
    # * Symbol: Parsed as modifier_code (e.g., <tt>:ctrl_c</tt>, <tt>:enter</tt>).
    # * Hash: Passed to Key.new constructor.
    # * Key: Passed directly.
    #
    # == Examples
    #
    #   with_test_terminal do
    #     inject_keys("a", "b", "c")
    #     inject_keys(:enter, :esc)
    #     inject_keys(:ctrl_c, :alt_shift_left)
    #     inject_keys("j", { code: "k", modifiers: ["ctrl"] })
    #   end
    def inject_keys(*args)
      args.each do |arg|
        event = case arg
                when String
                  RatatuiRuby::Event::Key.new(code: arg)
                when Symbol
                  parts = arg.to_s.split("_")
                  code = parts.pop
                  modifiers = parts
                  RatatuiRuby::Event::Key.new(code:, modifiers:)
                when Hash
                  RatatuiRuby::Event::Key.new(**arg)
                when RatatuiRuby::Event::Key
                  arg
                else
                  raise ArgumentError, "Invalid key argument: #{arg.inspect}. Expected String, Symbol, Hash, or Key event."
        end
        inject_event(event)
      end
    end
    alias inject_key inject_keys

    ##
    # Returns the cell attributes at the given coordinates.
    #
    #   get_cell(0, 0)
    #   # => { "symbol" => "H", "fg" => :red, "bg" => nil }
    def get_cell(x, y)
      RatatuiRuby.get_cell_at(x, y)
    end

    ##
    # Asserts that the cell at the given coordinates has the expected attributes.
    #
    #   assert_cell_style(0, 0, char: "H", fg: :red)
    def assert_cell_style(x, y, **expected_attributes)
      cell = get_cell(x, y)
      expected_attributes.each do |key, value|
        actual_value = cell.public_send(key)
        if value.nil?
          assert_nil actual_value, "Expected cell at (#{x}, #{y}) to have #{key}=nil, but got #{actual_value.inspect}"
        else
          assert_equal value, actual_value, "Expected cell at (#{x}, #{y}) to have #{key}=#{value.inspect}, but got #{actual_value.inspect}"
        end
      end
    end

    ##
    # Mock frame for unit testing views.
    #
    # Captures widgets passed to +render_widget+ for inspection.
    # Does not render anything—purely captures the output.
    #
    # == Examples
    #
    #   frame = MockFrame.new
    #   View::Log.new.call(state, tui, frame, area)
    #   widget = frame.rendered_widgets.first[:widget]
    #   assert_equal "Event Log", widget.block.title
    MockFrame = Data.define(:rendered_widgets) do
      def initialize(rendered_widgets: [])
        super
      end

      def render_widget(widget, area)
        rendered_widgets << { widget:, area: }
      end
    end

    ##
    # Stub area for unit testing views.
    #
    # Provides the minimal interface views expect (+width+, +height+).
    #
    # == Examples
    #
    #   area = StubRect.new(width: 60, height: 20)
    StubRect = Data.define(:x, :y, :width, :height) do
      def initialize(x: 0, y: 0, width: 80, height: 24)
        super
      end
    end

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
          File.write(snapshot_path, "#{actual_lines.join("\n")}\n")
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
    # Asserts that the color at a specific coordinate matches the expected value.
    #
    #   assert_color(:red, x: 10, y: 5)
    #   assert_color(5, x: 10, y: 5, layer: :bg)
    #   assert_color("#ff00ff", x: 10, y: 5)
    #
    # [expected] Symbol, Integer, or String (Hex) color.
    # [x] Integer x-coordinate.
    # [y] Integer y-coordinate.
    # [layer] Symbol :fg (default) or :bg.
    def assert_color(expected, x:, y:, layer: :fg)
      cell = get_cell(x, y)
      actual = cell.public_send(layer)

      # Normalize expected integer to symbol if needed (RatatuiRuby returns :indexed_N)
      expected_normalized = if expected.is_a?(Integer)
        :"indexed_#{expected}"
      else
        expected
      end

      assert_equal expected_normalized, actual,
        "Expected #{layer} at (#{x}, #{y}) to be #{expected.inspect}, but got #{actual.inspect}"
    end

    ##
    # Asserts that an entire area matches the specified style attributes.
    #
    #   header = RatatuiRuby::Rect.new(x: 0, y: 0, width: 80, height: 1)
    #   assert_area_style(header, bg: :blue, modifiers: [:bold])
    #
    #   # Also accepts x, y, width, height hash or object
    #   assert_area_style({x:0, y:0, w:10, h:1}, fg: :red)
    #
    # [area] Rect-like object (must respond to x, y, width, height) or Hash.
    # [attributes] Style attributes to verify (fg, bg, modifiers).
    def assert_area_style(area, **attributes)
      # Normalize area to something with x,y,width,height
      if area.is_a?(Hash)
        x = area[:x] || 0
        y = area[:y] || 0
        w = area[:width] || area[:w] || 0
        h = area[:height] || area[:h] || 0
      else
        x = area.x
        y = area.y
        w = area.width
        h = area.height
      end

      (y...(y + h)).each do |row|
        (x...(x + w)).each do |col|
          assert_cell_style(col, row, **attributes)
        end
      end
    end

    ##
    # Prints the current buffer to STDOUT with full ANSI colors.
    # useful for debugging ("YESSSSS").
    def print_buffer
      puts _render_buffer_with_ansi
    end

    ##
    # Asserts that the current screen content (including colors!) matches a stored ANSI snapshot.
    #
    # Generates/Compares against a file with `.ansi` extension.
    # You can `cat` this file to see exactly what the screen looked like.
    #
    #   assert_rich_snapshot("login_screen")
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
        File.write(snapshot_path, actual_content)
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
      when :black   then "\e[#{offset}m"
      when :red     then "\e[#{offset + 1}m"
      when :green   then "\e[#{offset + 2}m"
      when :yellow  then "\e[#{offset + 3}m"
      when :blue    then "\e[#{offset + 4}m"
      when :magenta then "\e[#{offset + 5}m"
      when :cyan    then "\e[#{offset + 6}m"
      when :gray    then is_fg ? "\e[90m" : "\e[100m" # Dark gray usually
      when :dark_gray then is_fg ? "\e[90m" : "\e[100m"
      when :light_red     then "\e[#{offset + 60 + 1}m"
      when :light_green   then "\e[#{offset + 60 + 2}m"
      when :light_yellow  then "\e[#{offset + 60 + 3}m"
      when :light_blue    then "\e[#{offset + 60 + 4}m"
      when :light_magenta then "\e[#{offset + 60 + 5}m"
      when :light_cyan    then "\e[#{offset + 60 + 6}m"
      when :white         then "\e[#{offset + 60 + 7}m"
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
