# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

module RatatuiRuby
  # Displays a tab bar for navigation.
  #
  # Screen real estate is limited. You cannot show everything at once. Segregating content into views is necessary for complex apps.
  #
  # This widget separates dimensions. It displays a row of titles, indicating which view is active.
  #
  # Use it at the top of your interface to switch between major modes or contexts.
  #
  # {rdoc-image:/doc/images/widget_tabs_demo.png}[link:/examples/widget_tabs_demo/app_rb.html]
  #
  # === Example
  #
  # Run the interactive demo from the terminal:
  #
  #   ruby examples/widget_tabs_demo/app.rb
  class Tabs < Data.define(:titles, :selected_index, :block, :divider, :highlight_style, :style, :padding_left, :padding_right)
    ##
    # :attr_reader: titles
    # Tab titles (Array of Strings).

    ##
    # :attr_reader: selected_index
    # Index of the active tab.

    ##
    # :attr_reader: block
    # Optional wrapping block.

    ##
    # :attr_reader: divider
    # Separator string between tabs.

    ##
    # :attr_reader: highlight_style
    # Style for the selected tab title.

    ##
    # :attr_reader: style
    # Base style for the tabs area.

    ##
    # :attr_reader: padding_left
    # Left padding for the tabs area (Integer, default: 0).

    ##
    # :attr_reader: padding_right
    # Right padding for the tabs area (Integer, default: 0).

    # Creates a new Tabs widget.
    #
    # [titles] Array of Strings/Lines.
    # [selected_index] Integer (default: 0).
    # [block] Block (optional).
    # [divider] String (optional).
    # [highlight_style] Style (optional).
    # [style] Style (optional).
    # [padding_left] Integer (default: 0).
    # [padding_right] Integer (default: 0).
    def initialize(titles: [], selected_index: 0, block: nil, divider: nil, highlight_style: nil, style: nil, padding_left: 0, padding_right: 0)
      super(
        titles:,
        selected_index: Integer(selected_index),
        block:,
        divider:,
        highlight_style:,
        style:,
        padding_left: Integer(padding_left),
        padding_right: Integer(padding_right)
      )
    end

    # Returns the total width of the tabs.
    def width
      RatatuiRuby._tabs_width(self)
    end
  end
end
