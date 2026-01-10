# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  module Widgets
    # A styled table row combining cells with optional row-level styling.
    #
    # By default, Table rows are arrays of cell content. For more control over styling
    # individual rows, wrap the cells in a Row object to apply row-level style.
    #
    # The cells can be Strings, Text::Spans, Text::Lines, Paragraphs, or Cells.
    # The style applies to the entire row background.
    #
    # === Examples
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   # Row with red background
    #   Row.new(cells: ["Error", "Something went wrong"], style: Style.new(bg: :red))
    #
    #   # Row with styled cells and custom height
    #   Row.new(
    #     cells: [
    #       Text::Span.new(content: "Status", style: Style.new(modifiers: [:bold])),
    #       Text::Span.new(content: "OK", style: Style.new(fg: :green))
    #     ],
    #     height: 2
    #   )
    #--
    # SPDX-SnippetEnd
    #++
    class Row < Data.define(:cells, :style, :height, :top_margin, :bottom_margin)
      include CoerceableWidget

      ##
      # :attr_reader: cells
      # The cells to display (Array of Strings, Text::Spans, Text::Lines, Paragraphs, or Cells).

      ##
      # :attr_reader: style
      # The style to apply to the row (optional Style).

      ##
      # :attr_reader: height
      # Fixed row height in lines (optional Integer).

      ##
      # :attr_reader: top_margin
      # Margin above the row in lines (optional Integer).

      ##
      # :attr_reader: bottom_margin
      # Margin below the row in lines (optional Integer).

      # Creates a new Row.
      #
      # [cells] Array of Strings, Text::Spans, Text::Lines, Paragraphs, or Cells.
      # [style] Style object (optional).
      # [height] Integer for fixed height (optional).
      # [top_margin] Integer for top margin (optional).
      # [bottom_margin] Integer for bottom margin (optional).
      def initialize(cells:, style: nil, height: nil, top_margin: nil, bottom_margin: nil)
        super(
          cells:,
          style:,
          height: height.nil? ? nil : Integer(height),
          top_margin: top_margin.nil? ? nil : Integer(top_margin),
          bottom_margin: bottom_margin.nil? ? nil : Integer(bottom_margin)
        )
      end

      # Returns a new Row with strikethrough styling enabled.
      #
      # Table rows sometimes need strikethrough styling to indicate
      # deleted, deprecated, or cancelled items. Manually managing
      # style modifiers is tedious.
      #
      # This method adds the <tt>:crossed_out</tt> modifier to the row's
      # style. If the row has no existing style, a new style is created.
      #
      # Use it to visually mark rows as cancelled, completed, or invalid.
      #
      # *Terminal Compatibility:* Strikethrough (SGR 9) is not universally
      # supported. macOS Terminal.app notably lacks support. Modern terminals
      # like Kitty, iTerm2, Alacritty, and WezTerm render it correctly.
      # Consider pairing with <tt>:dim</tt> as a fallback for visibility.
      #
      # Returns a new Row instance with strikethrough enabled.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   row = Row.new(cells: ["Cancelled Task", "2024-01-15"])
      #   strikethrough_row = row.enable_strikethrough
      #   # Row style now includes :crossed_out modifier
      #--
      # SPDX-SnippetEnd
      #++
      def enable_strikethrough
        current_style = style || Style::Style.new
        current_modifiers = current_style.modifiers || []
        new_modifiers = current_modifiers.include?(:crossed_out) ? current_modifiers : current_modifiers + [:crossed_out]

        new_style = current_style.with(modifiers: new_modifiers)
        with(style: new_style)
      end

      # Ruby-idiomatic alias
      alias strikethrough enable_strikethrough
    end
  end
end
