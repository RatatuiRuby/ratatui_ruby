# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

module RatatuiRuby
  class TUI
    # Style factory methods for Session.
    #
    # Provides convenient access to Style::Style without fully
    # qualifying the class name.
    module StyleFactories
      # Creates a Style::Style.
      # @return [Style::Style]
      def style(...)
        Style::Style.new(...)
      end
    end
  end
end
