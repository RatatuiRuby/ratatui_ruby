# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

module RatatuiRuby
  # Mutable state object for Scrollbar widgets.
  #
  # When using {Frame#render_stateful_widget}, the State object is the
  # *single source of truth* for position and content length. Widget
  # properties (+position+, +content_length+) are *ignored* in stateful mode.
  #
  # == Example
  #
  #   @scrollbar_state = RatatuiRuby::ScrollbarState.new(100)
  #   @scrollbar_state.position = 25
  #
  #   RatatuiRuby.draw do |frame|
  #     scrollbar = RatatuiRuby::Scrollbar.new(orientation: :vertical_right)
  #     frame.render_stateful_widget(scrollbar, frame.area, @scrollbar_state)
  #   end
  #
  class ScrollbarState
    ##
    # :method: new
    # :call-seq: new(content_length) -> ScrollbarState
    #
    # Creates a new ScrollbarState with the given content length.
    #
    # (Native method implemented in Rust)

    ##
    # :method: position
    # :call-seq: position() -> Integer
    #
    # Returns the current scroll position.
    #
    # (Native method implemented in Rust)

    ##
    # :method: position=
    # :call-seq: position=(value) -> Integer
    #
    # Sets the current scroll position.
    #
    # (Native method implemented in Rust)

    ##
    # :method: content_length
    # :call-seq: content_length() -> Integer
    #
    # Returns the total content length.
    #
    # (Native method implemented in Rust)

    ##
    # :method: content_length=
    # :call-seq: content_length=(value) -> Integer
    #
    # Sets the total content length.
    #
    # (Native method implemented in Rust)

    ##
    # :method: viewport_content_length
    # :call-seq: viewport_content_length() -> Integer
    #
    # Returns the viewport content length.
    #
    # (Native method implemented in Rust)

    ##
    # :method: viewport_content_length=
    # :call-seq: viewport_content_length=(value) -> Integer
    #
    # Sets the viewport content length.
    #
    # (Native method implemented in Rust)

    ##
    # :method: first
    # :call-seq: first() -> nil
    #
    # Scrolls to the first position.
    #
    # (Native method implemented in Rust)

    ##
    # :method: last
    # :call-seq: last() -> nil
    #
    # Scrolls to the last position.
    #
    # (Native method implemented in Rust)

    ##
    # :method: next
    # :call-seq: next() -> nil
    #
    # Scrolls to the next position.
    #
    # (Native method implemented in Rust)

    ##
    # :method: prev
    # :call-seq: prev() -> nil
    #
    # Scrolls to the previous position.
    #
    # (Native method implemented in Rust)
  end
end
