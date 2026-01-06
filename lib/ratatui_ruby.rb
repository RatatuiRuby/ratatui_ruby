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
require_relative "ratatui_ruby/schema/text"  # Text::Span, Text::Line
require_relative "ratatui_ruby/schema/draw"  # Draw commands

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
  end

  # Mix in terminal lifecycle and output protection methods
  extend OutputGuard
  extend TerminalLifecycle

  # Re-export NullIO at module root for backward compatibility
  NullIO = OutputGuard::NullIO

  @experimental_warnings = true
  @tui_session_active = false
  @headless_mode = false
  @deferred_warnings = []

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
      # Fallback for unknown events, though ideally we cover them all
      nil
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
