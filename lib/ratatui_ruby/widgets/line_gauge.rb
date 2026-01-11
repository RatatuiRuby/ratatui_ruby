# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  module Widgets
    # Displays a compact, single-line progress bar.
    #
    # Screen space is precious. Standard block gauges are bulky and consume multiple rows.
    #
    # This widget compresses the feedback. It draws a progress bar using line characters, fitting perfectly into tight layouts or lists.
    #
    # Use it when you need to show status without stealing focus or space.
    #
    # {rdoc-image:/doc/images/widget_line_gauge.png}[link:/examples/widget_line_gauge/app_rb.html]
    #
    # === Example
    #
    # Run the interactive demo from the terminal:
    #
    #   ruby examples/widget_line_gauge/app.rb
    class LineGauge < Data.define(:ratio, :label, :style, :filled_style, :unfilled_style, :block, :filled_symbol, :unfilled_symbol)
      include CoerceableWidget

      ##
      # :attr_reader: ratio
      # Progress ratio from 0.0 to 1.0.

      ##
      # :attr_reader: label
      # Optional label (String or Text::Span for rich styling).

      ##
      # :attr_reader: style
      # Base style applied to the entire gauge.

      ##
      # :attr_reader: filled_style
      # Style for the completed portion.

      ##
      # :attr_reader: unfilled_style
      # Style for the remainder.

      ##
      # :attr_reader: block
      # Optional wrapping block.

      ##
      # :attr_reader: filled_symbol
      # Character for filled segments.

      ##
      # :attr_reader: unfilled_symbol
      # Character for empty segments.

      # Creates a new LineGauge.
      #
      # [ratio] Float (0.0 - 1.0).
      # [percent] Integer (0 - 100), alternative to ratio.
      # [label] String or Text::Span (optional).
      # [style] Style (optional, base style for the gauge).
      # [filled_style] Style.
      # [unfilled_style] Style.
      # [block] Block.
      # [filled_symbol] String (default: <tt>"█"</tt>).
      # [unfilled_symbol] String (default: <tt>"░"</tt>).
      #
      # Raises ArgumentError if percent is not 0..100.
      def initialize(ratio: nil, percent: nil, label: nil, style: nil, filled_style: nil, unfilled_style: nil, block: nil, filled_symbol: "█", unfilled_symbol: "░")
        if percent
          float_percent = Float(percent)
          unless float_percent.between?(0, 100)
            raise ArgumentError, "percent must be between 0 and 100 (got #{percent.inspect})"
          end
          ratio = float_percent / 100.0
        end
        ratio = Float(ratio || 0.0)
        super(
          ratio:,
          label:,
          style:,
          filled_style:,
          unfilled_style:,
          block:,
          filled_symbol:,
          unfilled_symbol:
        )
      end

      # Returns true if the gauge has any fill (ratio > 0).
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   Widgets::LineGauge.new(ratio: 0.0).filled?  # => false
      #   Widgets::LineGauge.new(ratio: 0.5).filled?  # => true
      #--
      # SPDX-SnippetEnd
      #++
      def filled?
        ratio > 0
      end

      # Returns true if the gauge is at 100% or more (ratio >= 1.0).
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   Widgets::LineGauge.new(ratio: 0.99).complete?  # => false
      #   Widgets::LineGauge.new(ratio: 1.0).complete?   # => true
      #--
      # SPDX-SnippetEnd
      #++
      def complete?
        ratio >= 1.0
      end

      # Returns the progress as an integer percentage (0-100).
      #
      # LineGauge stores progress as a ratio (0.0 to 1.0). User-facing code often
      # displays percentages. Converting manually is tedious.
      #
      # This is the inverse of passing <tt>percent:</tt> to the constructor.
      # Rounds down to the nearest integer.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   lg = Widgets::LineGauge.new(percent: 75)
      #   lg.percent  # => 75
      #
      #   lg = Widgets::LineGauge.new(ratio: 0.456)
      #   lg.percent  # => 45
      #--
      # SPDX-SnippetEnd
      #++
      def percent
        (ratio * 100).to_i
      end
    end
  end
end
