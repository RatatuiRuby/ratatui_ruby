# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # Mutable state object for List widgets.
  #
  # When using {Frame#render_stateful_widget}, the State object is the
  # *single source of truth* for selection and scroll offset. Widget
  # properties (+selected_index+, +offset+) are *ignored* in stateful mode.
  #
  # State objects persist across frames, allowing you to:
  # - Track selection without manual index management
  # - Read back the scroll offset calculated by Ratatui
  # - Implement mouse click-to-row hit testing
  #
  # == Thread/Ractor Safety
  #
  # ListState is *not* Ractor-shareable. It contains mutable internal state.
  # Store it in instance variables, not in immutable TEA Models.
  #
  # == Example
  #
  #   @list_state = RatatuiRuby::ListState.new
  #   @list_state.select(2) # Select third item
  #
  #   RatatuiRuby.draw do |frame|
  #     list = RatatuiRuby::List.new(items: ["A", "B", "C", "D", "E"])
  #     frame.render_stateful_widget(list, frame.area, @list_state)
  #   end
  #
  #   puts @list_state.offset # Scroll position after render
  #
  class ListState
    ##
    # :method: new
    # :call-seq: new(selected = nil) -> ListState
    #
    # Creates a new ListState with optional initial selection.
    #
    # (Native method implemented in Rust)

    ##
    # :method: select
    # :call-seq: select(index) -> nil
    #
    # Sets the selected index. Pass +nil+ to deselect.
    #
    # (Native method implemented in Rust)

    ##
    # :method: selected
    # :call-seq: selected() -> Integer or nil
    #
    # Returns the currently selected index, or +nil+ if nothing is selected.
    #
    # (Native method implemented in Rust)

    ##
    # :method: offset
    # :call-seq: offset() -> Integer
    #
    # Returns the current scroll offset.
    #
    # This is the critical read-back method. After +render_stateful_widget+,
    # this returns the scroll position calculated by Ratatui to keep the
    # selection visible.
    #
    # (Native method implemented in Rust)

    ##
    # :method: scroll_down_by
    # :call-seq: scroll_down_by(n) -> nil
    #
    # Scrolls down by +n+ items.
    #
    # (Native method implemented in Rust)

    ##
    # :method: scroll_up_by
    # :call-seq: scroll_up_by(n) -> nil
    #
    # Scrolls up by +n+ items.
    #
    # (Native method implemented in Rust)
  end
end
