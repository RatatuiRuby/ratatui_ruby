# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

require_relative "ratatui_ruby/version"

# New modularized structure (mirrors ratatui Rust crate)
require_relative "ratatui_ruby/layout"   # Layout::Rect, Layout::Constraint, Layout::Layout
require_relative "ratatui_ruby/style"    # Style::Style
require_relative "ratatui_ruby/widgets"  # Widgets::Block, Widgets::Paragraph, etc.
require_relative "ratatui_ruby/buffer"   # Buffer::Cell (for inspection)
require_relative "ratatui_ruby/schema/text"  # Text::Span, Text::Line
require_relative "ratatui_ruby/schema/draw"  # Draw commands

# Event types
require_relative "ratatui_ruby/event"

# Frame and state objects
require_relative "ratatui_ruby/frame"
require_relative "ratatui_ruby/list_state"
require_relative "ratatui_ruby/table_state"
require_relative "ratatui_ruby/scrollbar_state"

# TUI facade (for external instantiation and caching)
require_relative "ratatui_ruby/tui"

begin
  require "ratatui_ruby/ratatui_ruby"
rescue LoadError
  # Fallback for development/CI if the bundle is not in the load path
  require_relative "ratatui_ruby/ratatui_ruby"
end

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
  #   begin
  #     RatatuiRuby.run { |tui| ... }
  #   rescue RatatuiRuby::Error => e
  #     puts "RatatuiRuby error: #{e.message}"
  #   end
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
    #   begin
    #     RatatuiRuby.init_terminal
    #   rescue RatatuiRuby::Error::Terminal => e
    #     puts "Terminal failed: #{e.message}"
    #   end
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
    #   stored_frame = nil
    #   RatatuiRuby.draw { |frame| stored_frame = frame }
    #   stored_frame.area  # => raises Error::Safety
    class Safety < Error; end

    # State invariant violation.
    #
    # The library has rules about valid state transitions.
    # Calling methods in the wrong order or state breaks invariants.
    #
    # This error signals you violated a state machine contract.
    # The program state doesn't allow this operation right now.
    #
    # To resolve, check `terminal_active?` or restructure the
    # code to ensure methods are called in the expected order.
    #
    # === Example
    #
    #   RatatuiRuby.init_terminal
    #   RatatuiRuby.init_terminal  # => raises Error::Invariant
    class Invariant < Error; end
  end

  # A null IO object that swallows all output.
  #
  # Used by {guard_io} to temporarily replace $stdout and $stderr.
  # Implements method_missing to accept any IO method and discard output.
  #
  # Returns self for method chaining (e.g., puts.flush).
  class NullIO
    # Accepts any method call and returns self, discarding all output.
    def method_missing(name, *args, &block)
      self
    end

    # Reports that all methods are supported.
    def respond_to_missing?(name, include_private = false)
      true
    end
  end

  ##
  # Initializes the terminal for TUI mode.
  # Enters alternate screen and enables raw mode.
  #
  # In headless mode ({headless!}), this method raises {Error::Invariant}.
  # Use headless mode for batch/CLI apps.
  #
  # [focus_events] whether to enable focus gain/loss events (default: true).
  # [bracketed_paste] whether to enable bracketed paste mode (default: true).
  #
  # @raise [Error::Invariant] if headless mode is enabled or a session is already active
  # @see headless!
  def self.init_terminal(focus_events: true, bracketed_paste: true)
    if @headless_mode
      raise Error::Invariant, "Cannot initialize terminal: headless mode is enabled"
    end
    if @tui_session_active
      raise Error::Invariant, "Cannot initialize terminal: TUI session already active"
    end
    @tui_session_active = true
    _init_terminal(focus_events, bracketed_paste)
  end

  @experimental_warnings = true
  @tui_session_active = false
  @headless_mode = false
  @deferred_warnings = []

  ##
  # Whether a TUI session is currently active.
  #
  # Writing to stdout/stderr during a TUI session corrupts the display.
  # Use this to defer logging, warnings, or debug output until
  # after the session ends.
  #
  # === Example
  #
  #   def log(message)
  #     if RatatuiRuby.terminal_active?
  #       @deferred_logs << message
  #     else
  #       puts message
  #     end
  #   end
  def self.terminal_active?
    @tui_session_active
  end

  ##
  # Whether headless (batch/CLI) mode is enabled.
  #
  # When headless mode is active:
  # - {guard_io} becomes a silent no-op (output is not swallowed)
  # - {init_terminal} and {run} raise {Error::Invariant}
  #
  # Use this when your app has a `--no-tui` or `--batch` flag and you want
  # the same code to work in both TUI and non-TUI modes.
  #
  # @see headless!
  def self.is_headless?
    @headless_mode
  end

  ##
  # Enables headless (batch/CLI) mode.
  #
  # Call this at app startup when running in batch/CLI mode (e.g., `--no-tui`).
  # This tells RatatuiRuby that you intentionally don't want a TUI session.
  #
  # When headless mode is active:
  # - {guard_io} becomes a silent no-op (output flows normally)
  # - {init_terminal} and {run} raise {Error::Invariant}
  #
  # Headless mode and TUI sessions are mutually exclusive. Calling this
  # while a TUI session is active raises {Error::Invariant}.
  #
  # === Why there is no exit_headless!
  #
  # Headless mode is a startup-time decision for the entire app run.
  # If you need to temporarily exit TUI mode for user interaction
  # (like lazygit does when editing a commit message), use
  # {restore_terminal} and {init_terminal} instead:
  #
  #   RatatuiRuby.restore_terminal
  #   puts "Press enter to continue..."
  #   gets
  #   RatatuiRuby.init_terminal
  #
  # === Example
  #
  #   if ARGV.include?("--no-tui")
  #     RatatuiRuby.headless!
  #     process_batch_work  # guard_io calls are silent no-ops
  #   else
  #     RatatuiRuby.run do |tui|  # This branch only runs in TUI mode
  #       # ... TUI code ...
  #     end
  #   end
  #
  # Note: Calling {run} or {init_terminal} after {headless!} raises
  # {Error::Invariant}. The block is never executed.
  #
  # @raise [Error::Invariant] if a TUI session is already active
  # @see is_headless?
  # @see restore_terminal
  def self.headless!
    if @tui_session_active
      raise Error::Invariant, "Cannot enable headless mode: TUI session already active"
    end
    @headless_mode = true
  end

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
  end

  ##
  # Restores the terminal to its original state.
  # Leaves alternate screen and disables raw mode.
  # Also flushes any deferred warnings that were queued during the session.
  #
  # In headless mode ({headless!}), this method is a silent no-op since
  # no terminal was ever initialized.
  #
  # @see headless!
  def self.restore_terminal
    return if @headless_mode

    _restore_terminal
  ensure
    @tui_session_active = false
    flush_warnings
  end

  ##
  # Guards a block from stdout/stderr output.
  #
  # During a TUI session, writes to $stdout or $stderr corrupt the display.
  # Wrap code that might produce output (e.g., chatty gems) in this block.
  #
  # This temporarily replaces $stdout and $stderr with a {NullIO} object
  # that discards all output. The original streams are restored when the
  # block exits, even if an exception occurs.
  #
  # === Behavior by mode
  #
  # - **TUI session active**: Output is swallowed (guarded)
  # - **Headless mode**: Silent no-op (output flows normally)
  # - **Neither**: Warns and yields (catches potential mistakes)
  #
  # === Example
  #
  #   RatatuiRuby.run do |tui|
  #     RatatuiRuby.guard_io do
  #       SomeChattyGem.do_something  # Any puts/warn calls are swallowed
  #     end
  #   end
  #
  # @see headless!
  def self.guard_io
    # TUI active: guard the output
    if terminal_active?
      $stdout = NullIO.new
      $stderr = NullIO.new
      begin
        return yield
      ensure
        $stdout = Object::STDOUT
        $stderr = Object::STDERR
      end
    end

    # Headless mode: silent no-op
    return yield if is_headless?

    # Neither: warn about potential mistake
    warn "guard_io called outside TUI session. If this is intentional (batch/CLI mode), call RatatuiRuby.headless! at startup to silence this warning."
    yield
  end

  ##
  # :singleton-method: inject_test_event
  # Injects a mock event into the event queue for testing purposes.
  # [event_type] "key" or "mouse"
  # [data] a Hash containing event data
  #
  #   inject_test_event("key", { code: "a" })
  #
  # (Native method implemented in Rust)

  ##
  # Warns about usage of an experimental feature unless warnings are suppressed.
  #
  # [feature_name] String name of the feature (e.g., "Paragraph#line_count")
  #
  # This warns only once per feature name per session.
  def self.warn_experimental_feature(feature_name)
    return unless experimental_warnings

    @warned_features ||= {}
    return if @warned_features[feature_name]

    message = "WARNING: #{feature_name} is an experimental feature and may change in future versions. Disable this warning with RatatuiRuby.experimental_warnings = false."
    if terminal_active?
      queue_warning(message)
    else
      warn message
    end
    @warned_features[feature_name] = true
  end

  ##
  # Initializes a test terminal for unit testing.
  # Sets session active state like init_terminal.
  #
  # [width] Integer width of the test terminal.
  # [height] Integer height of the test terminal.
  #
  # @raise [Error::Invariant] if headless mode is enabled or a session is already active
  def self.init_test_terminal(width, height)
    if @headless_mode
      raise Error::Invariant, "Cannot initialize terminal: headless mode is enabled"
    end
    if @tui_session_active
      raise Error::Invariant, "Cannot initialize terminal: TUI session already active"
    end
    @tui_session_active = true
    _init_test_terminal(width, height)
  end

  # (Native methods implemented in Rust)
  private_class_method :_init_terminal, :_restore_terminal, :_init_test_terminal

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
  #        a block is given.
  #
  # === Examples
  #
  # Legacy declarative style (tree-based):
  #
  #   RatatuiRuby.draw(Widgets::Paragraph.new(text: "Hello"))
  #
  # New imperative style (block-based):
  #
  #   RatatuiRuby.draw do |frame|
  #     frame.render_widget(Widgets::Paragraph.new(text: "Hello"), frame.area)
  #   end
  #
  def self.draw(tree = nil, &block)
    if tree && block
      raise ArgumentError, "Cannot provide both a tree and a block to draw"
    end
    unless tree || block
      raise ArgumentError, "Must provide either a tree or a block to draw"
    end

    if tree
      _draw(tree)
    else
      _draw(&block)
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
  #           Pass <tt>nil</tt> to block indefinitely (wait forever).
  #           Pass <tt>0.0</tt> for a non-blocking check.
  #
  # === Examples
  #
  #   # Standard loop (approx 60 FPS)
  #   event = RatatuiRuby.poll_event
  #
  #   # Block until event (pauses execution)
  #   event = RatatuiRuby.poll_event(timeout: nil)
  #
  #   # Non-blocking check (returns immediately)
  #   event = RatatuiRuby.poll_event(timeout: 0.0)
  #
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
      # Fallback for unknown events, though ideally we cover them all
      nil
    end
  end

  # (Native method _poll_event implemented in Rust)
  private_class_method :_poll_event

  ##
  # Starts the TUI application lifecycle.
  #
  # Managing generic setup/teardown (raw mode, alternate screen) manually is error-prone.
  # If your app crashes, the terminal might be left in a broken state.
  #
  # This method handles the safety net. It initializes the terminal, yields a {TUI},
  # and ensures the terminal state is restored even if exceptions occur.
  #
  # In headless mode ({headless!}), this method raises {Error::Invariant} immediately
  # and the block is never executed. Use headless mode for batch/CLI apps.
  #
  # === Example
  #
  #   RatatuiRuby.run(focus_events: false) do |tui|
  #     tui.draw(tui.paragraph(text: "Hi"))
  #     sleep 1
  #   end
  #
  # @raise [Error::Invariant] if headless mode is enabled
  # @see headless!
  def self.run(focus_events: true, bracketed_paste: true)
    init_terminal(focus_events:, bracketed_paste:)
    yield TUI.new
  ensure
    restore_terminal
  end

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
  #   cell = RatatuiRuby.get_cell_at(10, 5)
  #   expect(cell.symbol).to eq("X")
  #   expect(cell.fg).to eq(:red)
  #   expect(cell).to be_bold
  #
  def self.get_cell_at(x, y)
    raw = _get_cell_at(x, y)
    Buffer::Cell.new(
      char: raw["char"],
      fg: raw["fg"],
      bg: raw["bg"],
      modifiers: raw["modifiers"] || []
    )
  end

  # (Native method _get_cell_at implemented in Rust)
  private_class_method :_get_cell_at

  # Hide native Layout._split helper
  Layout::Layout.singleton_class.__send__(:private, :_split)

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
