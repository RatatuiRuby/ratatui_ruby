# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # Mutable state object for Table widgets.
  #
  # When using {Frame#render_stateful_widget}, the State object is the
  # *single source of truth* for selection and scroll offset. Widget
  # properties (+selected_row+, +selected_column+, +offset+) are *ignored*
  # in stateful mode.
  #
  # == Example
  #
  #   @table_state = RatatuiRuby::TableState.new
  #   @table_state.select(1)        # Select second row
  #   @table_state.select_column(0) # Select first column
  #
  #   RatatuiRuby.draw do |frame|
  #     table = RatatuiRuby::Widgets::Table.new(rows: [...], widths: [...])
  #     frame.render_stateful_widget(table, frame.area, @table_state)
  #   end
  #
  class TableState
    ##
    # :method: new
    # :call-seq: new(selected = nil) -> TableState
    #
    # Creates a new TableState with optional initial row selection.
    #
    # (Native method implemented in Rust)

    ##
    # :method: select
    # :call-seq: select(index) -> nil
    #
    # Sets the selected row index. Pass +nil+ to deselect.
    #
    # (Native method implemented in Rust)

    ##
    # :method: selected
    # :call-seq: selected() -> Integer or nil
    #
    # Returns the currently selected row index.
    #
    # (Native method implemented in Rust)

    ##
    # :method: select_column
    # :call-seq: select_column(index) -> nil
    #
    # Sets the selected column index. Pass +nil+ to deselect.
    #
    # (Native method implemented in Rust)

    ##
    # :method: selected_column
    # :call-seq: selected_column() -> Integer or nil
    #
    # Returns the currently selected column index.
    #
    # (Native method implemented in Rust)

    ##
    # :method: offset
    # :call-seq: offset() -> Integer
    #
    # Returns the current scroll offset.
    #
    # (Native method implemented in Rust)

    ##
    # :method: scroll_down_by
    # :call-seq: scroll_down_by(n) -> nil
    #
    # Scrolls down by +n+ rows.
    #
    # (Native method implemented in Rust)

    ##
    # :method: scroll_up_by
    # :call-seq: scroll_up_by(n) -> nil
    #
    # Scrolls up by +n+ rows.
    #
    # (Native method implemented in Rust)
  end
end
