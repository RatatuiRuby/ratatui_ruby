# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
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
      def draw(tree = nil, &block)
        if tree && block
          raise ArgumentError, "Cannot provide both a tree and a block to draw"
        end
        unless tree || block
          raise ArgumentError, "Must provide either a tree or a block to draw"
        end

        if block
          RatatuiRuby.draw(&block)
        else
          RatatuiRuby.draw(tree)
        end
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

      # Inserts content above an inline viewport.
      # @see RatatuiRuby.insert_before
      def insert_before(height, widget = nil, &)
        RatatuiRuby.insert_before(height, widget, &)
      end

      # Gets the Rect of the entire terminal, regardless of viewport
      def terminal_area
        RatatuiRuby.terminal_area
      end

      # Gets the Rect of the viewport
      def viewport_area
        RatatuiRuby.viewport_area
      end
    end
  end
end
