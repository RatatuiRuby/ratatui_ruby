# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # Displays a selectable list of items.
  #
  # Users need to choose from options. Menus, file explorers, and selectors are everywhere.
  # Implementing navigation, highlighting, and scrolling state from scratch is tedious.
  #
  # This widget manages the list. It renders the items. It highlights the selection. It handles the scrolling window.
  #
  # Use it to build main menus, navigation sidebars, or logs.
  #
  # {rdoc-image:/doc/images/widget_list_demo.png}[link:/examples/widget_list_demo/app_rb.html]
  #
  # === Examples
  #
  #   # Basic List
  #   List.new(items: ["Item 1", "Item 2"])
  #
  #   # Navigation Menu
  #   List.new(
  #     items: ["New Game", "Load Game", "Options", "Quit"],
  #     selected_index: 0,
  #     highlight_style: Style.new(bg: :blue),
  #     highlight_symbol: ">> "
  #   )
  class List < Data.define(:items, :selected_index, :style, :highlight_style, :highlight_symbol, :repeat_highlight_symbol, :highlight_spacing, :direction, :scroll_padding, :block)
    ##
    # :attr_reader: items
    # The items to display (Array of Strings).

    ##
    # :attr_reader: selected_index
    # Index of the active selection (Integer or nil).

    ##
    # :attr_reader: style
    # Base style for unselected items.

    ##
    # :attr_reader: highlight_style
    # Style for the selected item.

    ##
    # :attr_reader: highlight_symbol
    # Symbol drawn before the selected item.

    ##
    # :attr_reader: repeat_highlight_symbol
    # Whether to repeat the highlight symbol for each line of the selected item.

    ##
    # :attr_reader: highlight_spacing
    # When to show the highlight symbol column.
    #
    # <tt>:always</tt>, <tt>:when_selected</tt>, or <tt>:never</tt>.

    ##
    # :attr_reader: direction
    # Render direction.
    #
    # <tt>:top_to_bottom</tt> or <tt>:bottom_to_top</tt>.

    ##
    # :attr_reader: scroll_padding
    # Number of items to keep visible above/below the selected item when scrolling (Integer or nil).

    ##
    # :attr_reader: block
    # Optional wrapping block.

    # Creates a new List.
    #
    # Integer parameters accept any object responding to +to_int+ or +to_i+ (duck-typed).
    #
    # [items] Array of Strings.
    # [selected_index] Numeric (nullable, coerced to Integer).
    # [style] Style object.
    # [highlight_style] Style object.
    # [highlight_symbol] String (default: <tt>"> "</tt>).
    # [repeat_highlight_symbol] Boolean (default: <tt>false</tt>).
    # [highlight_spacing] Symbol (default: <tt>:when_selected</tt>).
    # [direction] Symbol (default: <tt>:top_to_bottom</tt>).
    # [scroll_padding] Numeric (nullable, coerced to Integer, default: <tt>nil</tt>).
    # [block] Block (optional).
    def initialize(items: [], selected_index: nil, style: nil, highlight_style: nil, highlight_symbol: "> ", repeat_highlight_symbol: false, highlight_spacing: :when_selected, direction: :top_to_bottom, scroll_padding: nil, block: nil)
      super(
        items:,
        selected_index: selected_index.nil? ? nil : Integer(selected_index),
        style:,
        highlight_style:,
        highlight_symbol:,
        repeat_highlight_symbol:,
        highlight_spacing:,
        direction:,
        scroll_padding: scroll_padding.nil? ? nil : Integer(scroll_padding),
        block:
      )
    end
  end
end
