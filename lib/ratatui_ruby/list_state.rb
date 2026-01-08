# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

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
  # Store it in instance variables, not in immutable Models.
  #
  # == Example
  #
  #--
  # SPDX-SnippetBegin
  # SPDX-FileCopyrightText: 2026 Kerrick Long
  # SPDX-License-Identifier: MIT-0
  #++
  #   @list_state = RatatuiRuby::ListState.new
  #   @list_state.select(2) # Select third item
  #
  #   RatatuiRuby.draw do |frame|
  #     list = RatatuiRuby::Widgets::List.new(items: ["A", "B", "C", "D", "E"])
  #     frame.render_stateful_widget(list, frame.area, @list_state)
  #   end
  #
  #   puts @list_state.offset # Scroll position after render
  #
  #--
  # SPDX-SnippetEnd
  #++
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

    ##
    # :method: select_next
    # :call-seq: select_next() -> nil
    #
    # Moves selection to the next item. Selects first item if nothing selected.
    #
    # === Optimistic Indexing
    #
    # Increments the index immediately, even past list bounds. The renderer
    # clamps to valid range on draw. Reading <tt>selected</tt> between this
    # call and render may return an out-of-bounds value.
    #
    # Matches upstream Ratatui behavior. See
    # {ListState#select_next}[https://docs.rs/ratatui/0.30/ratatui/widgets/struct.ListState.html#method.select_next].
    #
    # To detect actual selection changes, check bounds first:
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   max_index = items.size - 1
    #   return if (state.selected || 0) >= max_index
    #   state.select_next
    #
    #--
    # SPDX-SnippetEnd
    #++
    # (Native method implemented in Rust)

    ##
    # :method: select_previous
    # :call-seq: select_previous() -> nil
    #
    # Moves selection to the previous item. Selects last item if nothing selected.
    #
    # === Optimistic Indexing
    #
    # At index 0, does nothing. With no selection, sets index to maximum value;
    # the renderer clamps to actual last item on draw.
    #
    # To detect actual selection changes, check bounds first:
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   return if (state.selected || 0) <= 0
    #   state.select_previous
    #
    #--
    # SPDX-SnippetEnd
    #++
    # (Native method implemented in Rust)

    ##
    # :method: select_first
    # :call-seq: select_first() -> nil
    #
    # Jumps selection to the first item (index 0).
    #
    # To detect actual selection changes:
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   return if (state.selected || 0) == 0
    #   state.select_first
    #
    #--
    # SPDX-SnippetEnd
    #++
    # (Native method implemented in Rust)

    ##
    # :method: select_last
    # :call-seq: select_last() -> nil
    #
    # Jumps selection to the last item.
    #
    # === Optimistic Indexing
    #
    # Sets index to maximum possible value. The renderer clamps to actual last
    # item on draw. To get or check the real last index, track item count:
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   max_index = items.size - 1
    #   return if (state.selected || 0) == max_index
    #   state.select(max_index)
    #
    #--
    # SPDX-SnippetEnd
    #++
    # (Native method implemented in Rust)
  end
end
