# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  # Layout primitives for geometry and space distribution.
  #
  # This module mirrors +ratatui::layout+ and contains:
  # - {Rect} — Rectangle geometry
  # - {Constraint} — Sizing rules
  # - {Layout} — Space distribution
  module Layout
  end
end

require_relative "layout/rect"
require_relative "layout/constraint"
require_relative "layout/layout"
