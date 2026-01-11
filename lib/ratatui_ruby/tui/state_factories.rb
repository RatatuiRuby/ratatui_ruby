# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  class TUI
    # State object factory methods for Session.
    #
    # Provides convenient access to stateful widget state objects
    # (ListState, TableState, ScrollbarState) without fully
    # qualifying the class names.
    module StateFactories
      # Creates a ListState.
      # @return [ListState]
      def list_state(...)
        ListState.new(...)
      end

      # Creates a TableState.
      # @return [TableState]
      def table_state(...)
        TableState.new(...)
      end

      # Creates a ScrollbarState.
      # @return [ScrollbarState]
      def scrollbar_state(...)
        ScrollbarState.new(...)
      end

      # =====================================
      # State Dispatcher (TIMTOWTDI)
      # =====================================

      # Creates a state object by type symbol.
      #
      # Stateful widgets need companion state objects. When building dynamic UIs,
      # the state type must be determined at runtime.
      #
      # This dispatcher routes state creation through a single entry point.
      # Pass the type as a symbol and the remaining parameters.
      #
      # Use it for generic list/table factories or config-driven components.
      #
      # Also available as: <tt>tui.list_state</tt>, <tt>tui.table_state</tt>
      #
      # === Examples
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   tui.state(:list, nil)           # => ListState with no selection
      #   tui.state(:table, 0)            # => TableState with row 0 selected
      #   tui.state(:scrollbar, 100)      # => ScrollbarState with 100 content length
      #--
      # SPDX-SnippetEnd
      #++
      #
      # @param type [Symbol] State type: :list, :table, :scrollbar
      # @return [ListState, TableState, ScrollbarState]
      def state(type, arg = nil)
        case type
        when :list then list_state(arg)
        when :table then table_state(arg)
        when :scrollbar then scrollbar_state(arg || 0)
        else
          raise ArgumentError, "Unknown state type: :#{type}. Valid types: :list, :table, :scrollbar"
        end
      end
    end
  end
end
