# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
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
    end
  end
end
