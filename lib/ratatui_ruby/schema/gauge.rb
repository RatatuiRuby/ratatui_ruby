# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
    # Displays a standard progress bar.
    #
    # Long-running tasks create anxiety. Users need to know that the system is working and how much is left to do.
    #
    # This widget visualizes completion. It fills a bar based on a percentage.
    #
    # Use it for downloads, installations, or processing jobs.
    #
    # === Examples
    #
    #   Gauge.new(
    #     ratio: 0.75,
    #     label: "75%",
    #     style: Style.new(fg: :green)
    #   )
    class Gauge < Data.define(:ratio, :label, :style, :block, :use_unicode)
      ##
      # :attr_reader: ratio
      # Progress ratio from 0.0 to 1.0.

      ##
      # :attr_reader: label
      # Text label to display (optional).
      #
      # If nil, it often displays the percentage automatically depending on renderer logic,
      # but explicit labels are preferred.

      ##
      # :attr_reader: style
      # Style of the bar.

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
      # [label] String (optional).
      # [style] Style object (default: Style.default).
      # [block] Block widget (optional).
      # [use_unicode] Boolean (default: true).
      def initialize(ratio: nil, percent: nil, label: nil, style: Style.default, block: nil, use_unicode: true)
        if percent
          ratio = percent.to_f / 100.0
        end
        ratio ||= 0.0
        super(ratio:, label:, style:, block:, use_unicode:)
      end
    end
end
