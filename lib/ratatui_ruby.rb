# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "ratatui_ruby/version"
require_relative "ratatui_ruby/schema/paragraph"
require_relative "ratatui_ruby/schema/layout"
require_relative "ratatui_ruby/schema/block"
require_relative "ratatui_ruby/schema/constraint"
require_relative "ratatui_ruby/schema/list"
require_relative "ratatui_ruby/schema/style"
require_relative "ratatui_ruby/schema/gauge"
require_relative "ratatui_ruby/schema/table"
require_relative "ratatui_ruby/schema/tabs"
require_relative "ratatui_ruby/schema/bar_chart"
require_relative "ratatui_ruby/schema/sparkline"
require_relative "ratatui_ruby/schema/line_chart"
require_relative "ratatui_ruby/schema/cursor"
require_relative "ratatui_ruby/schema/overlay"
require_relative "ratatui_ruby/schema/center"

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
  # :call-seq: poll_event() -> Hash, nil
  #
  # Polls for a keyboard event.
  # Returns a Hash containing event details (type, code, modifiers), or nil if no event.
  #
  # (Native method implemented in Rust)
end
