# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  module TestHelper
    ##
    # Test doubles for view testing.
    #
    # View tests verify widget rendering without a real terminal. Real frames draw
    # to the screen. Real rects come from terminal dimensions. Mocking both by hand
    # is tedious.
    #
    # This mixin provides <tt>MockFrame</tt> to capture rendered widgets and
    # <tt>StubRect</tt> to supply fixed dimensions.
    #
    # Use them to test view logic in isolation.
    #
    # === Example
    #
    #   frame = MockFrame.new
    #   area = StubRect.new(width: 60, height: 20)
    #   MyView.new.call(state, tui, frame, area)
    #
    #   widget = frame.rendered_widgets.first[:widget]
    #   assert_equal "Dashboard", widget.block.title
    module TestDoubles
      ##
      # Mock frame for view tests.
      #
      # Captures widgets passed to <tt>render_widget</tt> for later inspection.
      #
      # === Example
      #
      #   frame = MockFrame.new
      #   View::Log.new.call(state, tui, frame, area)
      #   widget = frame.rendered_widgets.first[:widget]
      #   assert_equal "Event Log", widget.block.title
      MockFrame = Data.define(:rendered_widgets) do
        def initialize(rendered_widgets: [])
          super
        end

        def render_widget(widget, area)
          rendered_widgets << { widget:, area: }
        end
      end

      ##
      # Stub rect with fixed dimensions.
      #
      # [x] Integer left edge (default: 0).
      # [y] Integer top edge (default: 0).
      # [width] Integer width in cells (default: 80).
      # [height] Integer height in cells (default: 24).
      #
      # === Example
      #
      #   area = StubRect.new(width: 60, height: 20)
      StubRect = Data.define(:x, :y, :width, :height) do
        def initialize(x: 0, y: 0, width: 80, height: 24)
          super
        end
      end
    end
  end
end
