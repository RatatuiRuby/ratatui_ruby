# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  module Widgets
    # Displays a standard progress bar.
    #
    # Long-running tasks create anxiety. Users need to know that the system is working and how much is left to do.
    #
    # This widget visualizes completion. It fills a bar based on a percentage.
    #
    # Use it for downloads, installations, or processing jobs.
    #
    # {rdoc-image:/doc/images/widget_gauge.png}[link:/examples/widget_gauge/app_rb.html]
    #
    # === Example
    #
    # Run the interactive demo from the terminal:
    #
    #   ruby examples/widget_gauge/app.rb
    class Gauge < Data.define(:ratio, :label, :style, :gauge_style, :block, :use_unicode)
      include CoerceableWidget

      ##
      # :attr_reader: ratio
      # Progress ratio from 0.0 to 1.0.

      ##
      # :attr_reader: label
      # Text label to display (optional).
      #
      # Accepts String or Text::Span for rich styling.
      #
      # If nil, it often displays the percentage automatically depending on renderer logic,
      # but explicit labels are preferred.

      ##
      # :attr_reader: style
      # Base style applied to the entire gauge background (optional).

      ##
      # :attr_reader: gauge_style
      # Style applied specifically to the filled bar portion (optional).

      ##
      # :attr_reader: block
      # Optional wrapping block.

      ##
      # :attr_reader: use_unicode
      # Whether to use Unicode block characters (true) or ASCII characters (false).
      # Default is false (ASCII) to be conservative, though Ratatui defaults to true.

      # Creates a new Gauge.
      #
      # [ratio] Float (0.0 - 1.0).
      # [percent] Integer (0 - 100), alternative to ratio.
      # [label] String or Text::Span (optional).
      # [style] Style object for the background (optional).
      # [gauge_style] Style object for the filled bar (optional).
      # [block] Block widget (optional).
      # [use_unicode] Boolean (default: true).
      def initialize(ratio: nil, percent: nil, label: nil, style: nil, gauge_style: nil, block: nil, use_unicode: true)
        if percent
          # Float(Numeric) incorrectly returns Float? -- https://github.com/ruby/rbs/issues/2793
          float_percent = Float(percent) #: Float
          ratio = float_percent / 100.0
        end
        ratio = Float(ratio || 0.0)
        super(ratio:, label:, style:, gauge_style:, block:, use_unicode:)
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
      #   Widgets::Gauge.new(ratio: 0.0).filled?  # => false
      #   Widgets::Gauge.new(ratio: 0.5).filled?  # => true
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
      #   Widgets::Gauge.new(ratio: 0.99).complete?  # => false
      #   Widgets::Gauge.new(ratio: 1.0).complete?   # => true
      #--
      # SPDX-SnippetEnd
      #++
      def complete?
        ratio >= 1.0
      end

      # Returns the progress as an integer percentage (0-100).
      #
      # Gauge stores progress as a ratio (0.0 to 1.0). User-facing code often
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
      #   gauge = Widgets::Gauge.new(percent: 75)
      #   gauge.percent  # => 75
      #
      #   gauge = Widgets::Gauge.new(ratio: 0.456)
      #   gauge.percent  # => 45
      #--
      # SPDX-SnippetEnd
      #++
      def percent
        (ratio * 100).to_i
      end
    end
  end
end
