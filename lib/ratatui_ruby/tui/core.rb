# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

module RatatuiRuby
  class TUI
    # Core terminal methods delegated to RatatuiRuby module.
    #
    # These are the fundamental operations for the render loop:
    # drawing UI, polling events, and inspecting the buffer.
    module Core
      # Draws the given UI node tree to the terminal.
      # @see RatatuiRuby.draw
      def draw(tree = nil, &)
        RatatuiRuby.draw(tree, &)
      end

      # Checks for user input.
      # @see RatatuiRuby.poll_event
      def poll_event(timeout: 0.016)
        RatatuiRuby.poll_event(timeout:)
      end

      # Inspects the terminal buffer at specific coordinates.
      # @see RatatuiRuby.get_cell_at
      def get_cell_at(x, y)
        RatatuiRuby.get_cell_at(x, y)
      end

      # Creates a Draw::CellCmd for placing a cell at coordinates.
      # @return [Draw::CellCmd]
      def draw_cell(x, y, cell)
        Draw.cell(x, y, cell)
      end
    end
  end
end
