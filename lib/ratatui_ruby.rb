# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "ratatui_ruby/version"
require_relative "ratatui_ruby/schema/rect"
require_relative "ratatui_ruby/schema/paragraph"
require_relative "ratatui_ruby/schema/layout"
require_relative "ratatui_ruby/schema/block"
require_relative "ratatui_ruby/schema/constraint"
require_relative "ratatui_ruby/schema/list"
require_relative "ratatui_ruby/schema/style"
require_relative "ratatui_ruby/schema/gauge"
require_relative "ratatui_ruby/schema/line_gauge"
require_relative "ratatui_ruby/schema/table"
require_relative "ratatui_ruby/schema/tabs"
require_relative "ratatui_ruby/schema/bar_chart"
require_relative "ratatui_ruby/schema/bar_chart/bar"
require_relative "ratatui_ruby/schema/bar_chart/bar_group"
require_relative "ratatui_ruby/schema/sparkline"
require_relative "ratatui_ruby/schema/chart"
require_relative "ratatui_ruby/schema/clear"
require_relative "ratatui_ruby/schema/cursor"
require_relative "ratatui_ruby/schema/overlay"
require_relative "ratatui_ruby/schema/center"
require_relative "ratatui_ruby/schema/scrollbar"
require_relative "ratatui_ruby/schema/canvas"
require_relative "ratatui_ruby/schema/shape/label"
require_relative "ratatui_ruby/schema/calendar"
require_relative "ratatui_ruby/schema/ratatui_logo"
require_relative "ratatui_ruby/schema/ratatui_mascot"
require_relative "ratatui_ruby/schema/text"
require_relative "ratatui_ruby/schema/draw"
require_relative "ratatui_ruby/event"
require_relative "ratatui_ruby/cell"
require_relative "ratatui_ruby/frame"

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
  # Generic error class for RatatuiRuby.
  class Error < StandardError
    # Raised when a terminal operation fails (e.g., I/O error, backend failure).
    class Terminal < Error; end

    # Raised when an API safety contract is violated (e.g., accessing a Frame outside its valid scope).
    class Safety < Error; end
  end

  ##
  # Initializes the terminal for TUI mode.
  # Enters alternate screen and enables raw mode.
  #
  # [focus_events] whether to enable focus gain/loss events (default: true).
  # [bracketed_paste] whether to enable bracketed paste mode (default: true).
  def self.init_terminal(focus_events: true, bracketed_paste: true)
    _init_terminal(focus_events, bracketed_paste)
  end

  @experimental_warnings = true
  class << self
    ##
    # :attr_accessor: experimental_warnings
    # Whether to show warnings when using experimental features (default: true).
    attr_accessor :experimental_warnings
  end

  ##
  # :singleton-method: restore_terminal
  # Restores the terminal to its original state.
  # Leaves alternate screen and disables raw mode.
  #
  # (Native method implemented in Rust)

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

    warn "WARNING: #{feature_name} is an experimental feature and may change in future versions. Disable this warning with RatatuiRuby.experimental_warnings = false."
    @warned_features[feature_name] = true
  end

  # (Native method _init_terminal implemented in Rust)
  private_class_method :_init_terminal

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
  # [tree] A widget tree (Paragraph, Layout, etc.) to render. Optional if
  #        a block is given.
  #
  # === Examples
  #
  # Legacy declarative style (tree-based):
  #
  #   RatatuiRuby.draw(Paragraph.new(text: "Hello"))
  #
  # New imperative style (block-based):
  #
  #   RatatuiRuby.draw do |frame|
  #     frame.render_widget(Paragraph.new(text: "Hello"), frame.area)
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
    return Event::None.new if raw.nil?

    case raw[:type]
    when :key
      Event::Key.new(code: raw[:code], modifiers: raw[:modifiers] || [])
    when :mouse
      Event::Mouse.new(
        kind: raw[:kind].to_s,
        x: raw[:x],
        y: raw[:y],
        button: raw[:button].to_s,
        modifiers: raw[:modifiers] || []
      )
    when :resize
      Event::Resize.new(width: raw[:width], height: raw[:height])
    when :paste
      Event::Paste.new(content: raw[:content])
    when :focus_gained
      Event::FocusGained.new
    when :focus_lost
      Event::FocusLost.new
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
  # Managing generic setup/teardown (raw mode, alternate screen) manualy is error-prone. If your app crashes, the terminal might be left in a broken state.
  #
  # This method handles the safety net. It initializes the terminal, yields a {Session}, and ensures the terminal state is restored even if exceptions occur.
  #
  # === Example
  #
  #   RatatuiRuby.run(focus_events: false) do |tui|
  #     tui.draw(tui.paragraph(text: "Hi"))
  #     sleep 1
  #   end
  def self.run(focus_events: true, bracketed_paste: true)
    require_relative "ratatui_ruby/session"
    init_terminal(focus_events:, bracketed_paste:)
    yield Session.new
  ensure
    restore_terminal
  end

  ##
  # Inspects the terminal buffer at specific coordinates.
  #
  # When writing tests, you need to verify that your widget drew the correct characters and styles.
  # This method provides deep inspection of the cell's state (symbol, colors, modifiers).
  #
  # Returns a {Cell} object.
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
    Cell.new(
      char: raw["char"],
      fg: raw["fg"],
      bg: raw["bg"],
      modifiers: raw["modifiers"] || []
    )
  end

  # (Native method _get_cell_at implemented in Rust)
  private_class_method :_get_cell_at

  # Hide native Layout._split helper
  Layout.singleton_class.__send__(:private, :_split)
end
