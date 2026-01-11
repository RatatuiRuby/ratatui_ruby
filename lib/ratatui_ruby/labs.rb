# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  # Experimental lab features.
  module Labs
    @enabled_lab = nil #: Symbol?

    class << self
      # Returns whether the specified lab is enabled.
      def enabled?(lab)
        @enabled_lab == lab.to_sym.downcase
      end

      # Enables a lab programmatically.
      def enable!(lab)
        @enabled_lab = lab.to_sym.downcase
      end

      # Resets all labs (for testing only).
      def reset!
        @enabled_lab = nil
        @warned = false
      end

      # Emits experimental warning once per session.
      def warn_once!(feature_name)
        return if @warned

        RatatuiRuby.warn_experimental_feature(feature_name)
        @warned = true
      end
    end
  end
end

# Auto-enable from environment variable
if (lab = ENV["RR_LABS"])
  RatatuiRuby::Labs.enable!(lab)
end

require_relative "labs/a11y"
require_relative "labs/frame_a11y_capture"
