# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require_relative "ratatui_ruby/version"

# Core types (mirrors ratatui Rust crate)
require_relative "ratatui_ruby/layout"   # Layout::Rect, Layout::Constraint, Layout::Layout
require_relative "ratatui_ruby/style"    # Style::Style
require_relative "ratatui_ruby/widgets"  # Widgets::Block, Widgets::Paragraph, etc.
require_relative "ratatui_ruby/buffer"   # Buffer::Cell (for inspection)
require_relative "ratatui_ruby/text"    # Text::Span, Text::Line, Text.width
require_relative "ratatui_ruby/draw"    # Draw commands
require_relative "ratatui_ruby/symbols" # Symbols::Shade, etc.
require_relative "ratatui_ruby/backend" # Backend::WindowSize
require_relative "ratatui_ruby/terminal/viewport" # Terminal::Viewport
require_relative "ratatui_ruby/terminal" # Terminal class

# Event types
require_relative "ratatui_ruby/event"

# Frame and state objects
require_relative "ratatui_ruby/frame"
require_relative "ratatui_ruby/list_state"
require_relative "ratatui_ruby/table_state"
require_relative "ratatui_ruby/scrollbar_state"

# Behavioral mixins
require_relative "ratatui_ruby/output_guard"
require_relative "ratatui_ruby/terminal_lifecycle"

# TUI facade (for external instantiation and caching)
require_relative "ratatui_ruby/tui"

# Synthetic events queue (for async synchronization)
require_relative "ratatui_ruby/synthetic_events"

begin
  require "ratatui_ruby/ratatui_ruby"
rescue LoadError
  # Fallback for development/CI if the bundle is not in the load path
  require_relative "ratatui_ruby/ratatui_ruby"
end

# Debug mode (for Rust backtraces and diagnostic features)
# Loaded after native extension so _enable_rust_backtrace is defined
require_relative "ratatui_ruby/debug"

# Experimental lab features (RR_LABS env var)
require_relative "ratatui_ruby/labs"

# Main entry point for the library.
#
# Terminal UIs require low-level control using C/Rust and high-level abstraction in Ruby.
#
# This module bridges the gap. It provides the native methods to initialize the terminal, handle raw mode, and render the widget tree.
#
# Use `RatatuiRuby.run` to start your application.
module RatatuiRuby
  # Base error class for RatatuiRuby.
  #
  # All library-specific exceptions inherit from this class.
  # Catch this to handle any RatatuiRuby error generically.
  #
  # === Example
  #
  #--
  # SPDX-SnippetBegin
  # SPDX-FileCopyrightText: 2026 Kerrick Long
  # SPDX-License-Identifier: MIT-0
  #++
  #   begin
  #     RatatuiRuby.run { |tui| ... }
  #   rescue RatatuiRuby::Error => e
  #     puts "RatatuiRuby error: #{e.message}"
  #   end
  #--
  # SPDX-SnippetEnd
  #++
  class Error < StandardError
    # Operational failure during terminal I/O.
    #
    # Terminals are finnicky. I/O can fail. Backends can crash.
    # These are runtime problems outside your control.
    #
    # This error signals the terminal operation itself failed.
    # The library tried to do something with the terminal and couldn't.
    #
    # Catch this to handle terminal failures gracefully.
    #
    # === Example
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   begin
    #     RatatuiRuby.init_terminal
    #   rescue RatatuiRuby::Error::Terminal => e
    #     puts "Terminal failed: #{e.message}"
    #   end
    #--
    # SPDX-SnippetEnd
    #++
    class Terminal < Error; end

    # Object lifetime violation.
    #
    # Some objects are only valid during specific scopes.
    # Using them after their scope ends causes undefined behavior.
    #
    # This error prevents use-after-scope bugs.
    # The object you're accessing is no longer valid.
    #
    # To resolve, ensure scoped objects are used only within their
    # valid lifetime (e.g., inside the block where they're created).
    #
    # === Example
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   stored_frame = nil
    #   RatatuiRuby.draw { |frame| stored_frame = frame }
    #   stored_frame.area  # => raises Error::Safety
    #--
    # SPDX-SnippetEnd
    #++
    class Safety < Error; end

    # Invariant violation.
    #
    # The library enforces rules about valid states and contracts.
    # Breaking these rules raises this error.
    #
    # Common causes:
    # - Calling methods in the wrong order (e.g., <tt>init_terminal</tt> twice)
    # - Callable return type mismatch (e.g., view returns <tt>nil</tt> instead of a widget)
    #
    # To resolve, check the method's documented contract. Ensure
    # state preconditions are met and return types are correct.
    #
    # === Example
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   RatatuiRuby.init_terminal
    #   RatatuiRuby.init_terminal  # => raises Error::Invariant
    #--
    # SPDX-SnippetEnd
    #++
    class Invariant < Error; end

    # Framework bug.
    #
    # This error indicates a bug within the RatatuiRuby framework itself.
    # If you encounter this, the framework is broken — please report it.
    #
    # Normal application errors use standard exceptions like ArgumentError.
    # This exception class distinguishes "our bug" from "your bug".
    class Internal < Error; end
  end

  # Mix in terminal lifecycle and output protection methods
  extend OutputGuard
  extend TerminalLifecycle

  @experimental_warnings = true
  @tui_session_active = false
  @headless_mode = false
  @deferred_warnings = [] #: Array[String]

  class << self
    ##
    # :attr_accessor: experimental_warnings
    # Whether to show warnings when using experimental features (default: true).
    attr_accessor :experimental_warnings

    private def queue_warning(message)
      @deferred_warnings << message
    end

    private def flush_warnings
      return if @deferred_warnings.empty?
      @deferred_warnings.each { |msg| warn msg }
      @deferred_warnings.clear
    end

    private def flush_panic_info
      return unless Debug.rust_backtrace_enabled?
      panic_info = _get_last_panic
      return unless panic_info
      warn panic_info
    end
  end

  ##
  # :singleton-method: inject_test_event
  # Injects a mock event into the event queue for testing purposes.
  # [event_type] "key" or "mouse"
  # [data] a Hash containing event data
  #
  #--
  # SPDX-SnippetBegin
  # SPDX-FileCopyrightText: 2025 Kerrick Long
  # SPDX-License-Identifier: MIT-0
  #++
  #   inject_test_event("key", { code: "a" })
  #
  #--
  # SPDX-SnippetEnd
  #++
  # (Native method implemented in Rust)

  ##
  # Warns about usage of an experimental feature unless warnings are suppressed.
  #
  # [feature_name] String name of the feature (e.g., "Paragraph#line_count")
  #
  # This warns only once per feature name per session.
  def self.warn_experimental_feature(feature_name)
    return unless experimental_warnings

    @warned_features ||= {} #: Hash[String, bool]
    return if @warned_features[feature_name]

    message = "WARNING: #{feature_name} is an experimental feature and may change in future versions. Disable this warning with RatatuiRuby.experimental_warnings = false."
    if terminal_active?
      queue_warning(message)
    else
      warn message
    end
    @warned_features[feature_name] = true
  end

  # (Native methods implemented in Rust)
  private_class_method :_init_terminal, :_restore_terminal, :_init_test_terminal, :_enable_rust_backtrace, :_get_last_panic

  ##
  # Enables full debug mode.
  #
  # Convenience alias for Debug.enable!.
  #
  # === Example
  #
  #--
  # SPDX-SnippetBegin
  # SPDX-FileCopyrightText: 2026 Kerrick Long
  # SPDX-License-Identifier: MIT-0
  #++
  #   RatatuiRuby.debug_mode!
  #
  #--
  # SPDX-SnippetEnd
  #++
  def self.debug_mode!
    Debug.enable!
  end

  ##
  # Draws the given UI node tree to the terminal.
  #
  # TUI applications need to render widgets to the screen. Rendering could
  # happen all at once with a pre-built tree, or incrementally with direct
  # frame access.
  #
  # This method handles both. Pass a tree for declarative rendering, or
  # pass a block to manipulate the frame directly. The block receives a
  # {Frame} object for imperative drawing.
  #
  # [tree] A widget tree (Widgets::Paragraph, Layout::Layout, etc.) to render. Optional if
  #--
  # SPDX-SnippetBegin
  # SPDX-FileCopyrightText: 2025 Kerrick Long
  # SPDX-License-Identifier: MIT-0
  #++
  #        a block is given.
  #
  #--
  # SPDX-SnippetEnd
  #++
  # === Examples
  #
  # Legacy declarative style (tree-based):
  #
  #--
  # SPDX-SnippetBegin
  # SPDX-FileCopyrightText: 2026 Kerrick Long
  # SPDX-License-Identifier: MIT-0
  #++
  #   RatatuiRuby.draw(Widgets::Paragraph.new(text: "Hello"))
  #
  #--
  # SPDX-SnippetEnd
  #++
  # New imperative style (block-based):
  #
  #--
  # SPDX-SnippetBegin
  # SPDX-FileCopyrightText: 2026 Kerrick Long
  # SPDX-License-Identifier: MIT-0
  #++
  #   RatatuiRuby.draw do |frame|
  #     frame.render_widget(Widgets::Paragraph.new(text: "Hello"), frame.area)
  #   end
  #
  #--
  # SPDX-SnippetEnd
  #++
  def self.draw(tree = nil, &block)
    if tree && block
      raise ArgumentError, "Cannot provide both a tree and a block to draw"
    end
    unless tree || block
      raise ArgumentError, "Must provide either a tree or a block to draw"
    end

    if tree
      _draw(tree)
    elsif block
      # Wrap user block to flush A11Y capture after user code
      if Labs.enabled?(:a11y)
        _draw do |frame|
          block.call(frame)
          frame.flush_a11y_capture
        end
      else
        _draw(&block)
      end
    end
  end

  # (Native method _draw implemented in Rust)
  private_class_method :_draw

  ##
  # Checks for user input.
  #
  # Interactive apps must respond to input. Loops need to poll without burning CPU.
  #
  # This method checks for an event. It returns the event if one is found. It returns {RatatuiRuby::Event::None} if the timeout expires.
  #
  # [timeout] Float seconds to wait (default: 0.016).
  #--
  # SPDX-SnippetBegin
  # SPDX-FileCopyrightText: 2026 Kerrick Long
  # SPDX-License-Identifier: MIT-0
  #++
  #           Pass <tt>nil</tt> to block indefinitely (wait forever).
  #           Pass <tt>0.0</tt> for a non-blocking check.
  #
  #--
  # SPDX-SnippetEnd
  #++
  # === Examples
  #
  #--
  # SPDX-SnippetBegin
  # SPDX-FileCopyrightText: 2026 Kerrick Long
  # SPDX-License-Identifier: MIT-0
  #++
  #   # Standard loop (approx 60 FPS)
  #   event = RatatuiRuby.poll_event
  #
  #   # Block until event (pauses execution)
  #   event = RatatuiRuby.poll_event(timeout: nil)
  #
  #   # Non-blocking check (returns immediately)
  #   event = RatatuiRuby.poll_event(timeout: 0.0)
  #
  #--
  # SPDX-SnippetEnd
  #++
  def self.poll_event(timeout: 0.016)
    raise ArgumentError, "timeout must be non-negative" if timeout && timeout < 0

    raw = _poll_event(timeout)
    return Event::None.new.freeze if raw.nil?

    case raw[:type]
    when :key
      Event::Key.new(
        code: raw[:code],
        modifiers: (raw[:modifiers] || []).freeze,
        kind: raw[:kind] || :standard
      ).freeze
    when :mouse
      Event::Mouse.new(
        kind: raw[:kind].to_s,
        x: raw[:x],
        y: raw[:y],
        button: raw[:button].to_s,
        modifiers: (raw[:modifiers] || []).freeze
      ).freeze
    when :resize
      Event::Resize.new(width: raw[:width], height: raw[:height]).freeze
    when :paste
      Event::Paste.new(content: raw[:content]).freeze
    when :focus_gained
      Event::FocusGained.new.freeze
    when :focus_lost
      Event::FocusLost.new.freeze
    else
      # Return None for unknown event types
      Event::None.new.freeze
    end
  end

  # (Native method _poll_event implemented in Rust)
  private_class_method :_poll_event

  ##
  # Inspects the terminal buffer at specific coordinates.
  #
  # When writing tests, you need to verify that your widget drew the correct characters and styles.
  # This method provides deep inspection of the cell's state (symbol, colors, modifiers).
  #
  # Returns a {Buffer::Cell} object.
  #
  # Values depend on what the backend has rendered. If nothing has been rendered to a cell, it may contain defaults (empty symbol, nil colors).
  #
  # === Example
  #
  #--
  # SPDX-SnippetBegin
  # SPDX-FileCopyrightText: 2025 Kerrick Long
  # SPDX-License-Identifier: MIT-0
  #++
  #   cell = RatatuiRuby.get_cell_at(10, 5)
  #   expect(cell.symbol).to eq("X")
  #   expect(cell.fg).to eq(:red)
  #   expect(cell).to be_bold
  #
  #--
  # SPDX-SnippetEnd
  #++
  def self.get_cell_at(x, y)
    raw = _get_cell_at(x, y)
    Buffer::Cell.new(
      char: raw["char"],
      fg: raw["fg"],
      bg: raw["bg"],
      underline_color: raw["underline_color"],
      modifiers: raw["modifiers"] || []
    )
  end

  ##
  # Returns the current terminal viewport area.
  #
  # In inline viewports, this returns the viewport dimensions.
  # In fullscreen mode, this returns the full terminal size.
  #
  # @return [Layout::Rect] The rendering viewport area
  def self.get_viewport_area
    raw = _get_terminal_area
    Layout::Rect.new(
      x: raw["x"],
      y: raw["y"],
      width: raw["width"],
      height: raw["height"]
    )
  end

  ##
  # Returns the full terminal backend size.
  #
  # This is always the full terminal dimensions, regardless of viewport mode.
  #
  # === Example
  #
  #--
  # SPDX-SnippetBegin
  # SPDX-FileCopyrightText: 2026 Kerrick Long
  # SPDX-License-Identifier: MIT-0
  #++
  #   size = RatatuiRuby.get_terminal_size
  #   puts "Terminal: #{size.width}x#{size.height}"
  #
  #--
  # SPDX-SnippetEnd
  #++
  # @return [Layout::Rect] The full terminal size
  def self.get_terminal_size
    raw = _get_terminal_size
    Layout::Rect.new(
      x: raw["x"],
      y: raw["y"],
      width: raw["width"],
      height: raw["height"]
    )
  end

  # Ruby-idiomatic aliases (TIMTOWTDI)
  class << self
    # Aliases for get_terminal_size (full backend size)
    alias get_terminal_area get_terminal_size
    alias terminal_area get_terminal_size
    alias terminal_size get_terminal_size
    # Aliases for get_viewport_area (viewport rendering area)
    alias get_viewport_size get_viewport_area
    alias viewport_area get_viewport_area
    alias viewport_size get_viewport_area
  end

  ##
  # Number of frames drawn since terminal initialization.
  #
  # TUI applications track render cycles for animations, FPS counters, or
  # debugging. Manually counting draws is error-prone and clutters app logic.
  #
  # This method queries the terminal's internal frame counter. It starts at 0
  # when the terminal initializes and increments by 1 after each successful
  # draw. Restoring and re-initializing resets the counter.
  #
  # Raises RatatuiRuby::Error::Invariant if terminal not initialized.
  def self.frame_count
    _frame_count
  end

  # (Native methods implemented in Rust)
  private_class_method :_get_cell_at, :_get_terminal_size, :_frame_count

  # Hide native Layout._split helper
  Layout::Layout.singleton_class.__send__(:private, :_split)

  # Raw Terminal bindings - use public wrappers (they have timeout guards)
  Terminal.singleton_class.__send__(:private, :_available_color_count)
  Terminal.singleton_class.__send__(:private, :_supports_keyboard_enhancement)

  # --- Terminal Safety Hooks ---
  # These ensure the terminal is restored even on unexpected exits.

  at_exit do
    restore_terminal if terminal_active?
  end

  %i[INT TERM].each do |signal|
    trap(signal) do
      restore_terminal if terminal_active?
      exit(128 + Signal.list[signal.to_s])
    end
  end
end
