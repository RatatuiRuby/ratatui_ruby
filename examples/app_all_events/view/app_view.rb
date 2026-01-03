# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "../view"
require_relative "counts_view"
require_relative "live_view"
require_relative "log_view"
require_relative "controls_view"

# Orchestrates the complete UI layout and sub-view composition.
#
# Complex applications need a structured way to divide the screen and delegate rendering.
# Placing all layout logic in one monolithic method makes the code difficult to maintain.
#
# This class defines the screen layout using a series of split constraints and delegates to sub-views.
#
# Use it as the root view for the All Events example application.
#
# === Examples
#
#   app_view = View::App.new
#   app_view.call(model, tui, frame, area)
class View::App
  # Creates a new View::App and initializes sub-views.
  def initialize
    @counts_view = View::Counts.new
    @live_view = View::Live.new
    @log_view = View::Log.new
    @controls_view = View::Controls.new
  end

  # Renders the entire application UI to the given area.
  #
  # [model] AppModel containing all application data.
  # [tui] RatatuiRuby instance.
  # [frame] RatatuiRuby::Frame being rendered.
  # [area] RatatuiRuby::Layout::Rect defining the total available space.
  #
  # === Example
  #
  #   app_view.call(model, tui, frame, area)
  def call(model, tui, frame, area)
    main_area, control_area = tui.layout_split(
      area,
      direction: :vertical,
      constraints: [
        tui.constraint_fill(1),
        tui.constraint_length(3),
      ]
    )

    counts_area, _margin_area, right_area = tui.layout_split(
      main_area,
      direction: :horizontal,
      constraints: [
        tui.constraint_length(20),
        tui.constraint_length(1),
        tui.constraint_fill(1),
      ]
    )

    live_area, log_area = tui.layout_split(
      right_area,
      direction: :vertical,
      constraints: [
        tui.constraint_length(9),
        tui.constraint_fill(1),
      ]
    )

    @counts_view.call(model, tui, frame, counts_area)
    @live_view.call(model, tui, frame, live_area)
    @log_view.call(model, tui, frame, log_area)
    @controls_view.call(model, tui, frame, control_area)
  end
end
