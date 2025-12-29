# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
    # Displays a tab bar for navigation.
    #
    # Screen real estate is limited. You cannot show everything at once. Segregating content into views is necessary for complex apps.
    #
    # This widget separates dimensions. It displays a row of titles, indicating which view is active.
    #
    # Use it at the top of your interface to switch between major modes or contexts.
    #
    # === Examples
    #
    #   Tabs.new(
    #     titles: ["Home", "Settings", "Logs"],
    #     selected_index: 0,
    #     highlight_style: Style.new(fg: :yellow),
    #     divider: "|"
    #   )
    class Tabs < Data.define(:titles, :selected_index, :block, :divider, :highlight_style)
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

      # Creates a new Tabs widget.
      #
      # [titles] Array of Strings/Lines.
      # [selected_index] Integer (default: 0).
      # [block] Block (optional).
      # [divider] String (optional).
      # [highlight_style] Style (optional).
      def initialize(titles: [], selected_index: 0, block: nil, divider: nil, highlight_style: nil)
        super
      end
    end
end
