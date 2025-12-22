# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "ratatui_ruby/version"
require_relative "ratatui_ruby/schema/paragraph"
require_relative "ratatui_ruby/schema/layout"

begin
  require_relative "ratatui_ruby/ratatui_ruby"
rescue LoadError
  # Fallback for development if the bundle is in the root
  require_relative "../ratatui_ruby.bundle"
end

# The RatatuiRuby module acts as a namespace for the entire gem.
# It provides the main entry points for initializing the terminal and drawing the UI.
module RatatuiRuby
  # Generic error class for RatatuiRuby.
  class Error < StandardError; end

  ##
  # :method: init_terminal
  # :call-seq: init_terminal() -> nil
  #
  # Initializes the terminal for TUI mode.
  # Enters alternate screen and enables raw mode.
  #
  # (Native method implemented in Rust)

  ##
  # :method: restore_terminal
  # :call-seq: restore_terminal() -> nil
  #
  # Restores the terminal to its original state.
  # Leaves alternate screen and disables raw mode.
  #
  # (Native method implemented in Rust)

  ##
  # :method: draw
  # :call-seq: draw(node) -> nil
  #
  # Draws the given UI node tree to the terminal.
  # [node] the root node of the UI tree (Paragraph, Layout).
  #
  # (Native method implemented in Rust)

  ##
  # :method: poll_event
  # :call-seq: poll_event() -> String, nil
  #
  # Polls for a keyboard event.
  # Returns the character pressed (String), or nil if no event.
  #
  # (Native method implemented in Rust)
end
