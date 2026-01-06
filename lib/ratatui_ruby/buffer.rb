# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  # Buffer primitives for terminal cell inspection.
  #
  # This module mirrors +ratatui::buffer+ and contains:
  # - {Cell} — Single terminal cell (for inspection)
  module Buffer
  end
end

require_relative "buffer/cell"
