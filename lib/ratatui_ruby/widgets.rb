# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

module RatatuiRuby
  # Widget classes for building terminal UIs.
  #
  # This module mirrors +ratatui::widgets+ and contains all renderable
  # widget types: Block, Paragraph, List, Table, Gauge, Chart, etc.
  module Widgets
  end
end

# Core widgets
require_relative "widgets/block"
require_relative "widgets/paragraph"
require_relative "widgets/list"
require_relative "widgets/list_item"
require_relative "widgets/table"
require_relative "widgets/row"
require_relative "widgets/cell"
require_relative "widgets/tabs"
require_relative "widgets/gauge"
require_relative "widgets/line_gauge"
require_relative "widgets/sparkline"
require_relative "widgets/bar_chart"
require_relative "widgets/bar_chart/bar"
require_relative "widgets/bar_chart/bar_group"
require_relative "widgets/chart"
require_relative "widgets/scrollbar"
require_relative "widgets/calendar"
require_relative "widgets/canvas"
require_relative "widgets/clear"
require_relative "widgets/cursor"
require_relative "widgets/overlay"
require_relative "widgets/center"
require_relative "widgets/ratatui_logo"
require_relative "widgets/ratatui_mascot"
require_relative "widgets/shape/label"
