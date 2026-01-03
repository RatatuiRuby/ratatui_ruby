# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  class TUI
    # Buffer inspection factory methods for Session.
    #
    # Provides convenient access to Buffer::Cell for testing
    # and buffer inspection purposes.
    module BufferFactories
      # Creates a Buffer::Cell (for testing).
      # @return [Buffer::Cell]
      def cell(...)
        Buffer::Cell.new(...)
      end
    end
  end
end
