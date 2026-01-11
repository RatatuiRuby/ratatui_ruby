# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  class Frame
    # A11Y Lab Integration
    #
    # When the A11Y lab is enabled, we capture widgets as they are rendered
    # and write the tree to XML when flush_a11y_capture is called.
    module A11yCapture
      # Intercepts render_widget to capture widgets for A11Y export.
      # @param widget [widget] The widget being rendered
      # @param area [Layout::Rect] The area to render into
      def render_widget(widget, area)
        if Labs.enabled?(:a11y)
          widgets = (@a11y_widgets ||= []) #: Array[[(_CustomWidget | widget), Layout::Rect]]
          widgets << [widget, area]
        end
        super
      end

      # Intercepts render_stateful_widget to capture widgets for A11Y export.
      # @param widget [widget] The widget being rendered
      # @param area [Layout::Rect] The area to render into
      # @param state [Object] The widget state
      def render_stateful_widget(widget, area, state)
        if Labs.enabled?(:a11y)
          widgets = (@a11y_widgets ||= []) #: Array[[(_CustomWidget | widget), Layout::Rect]]
          widgets << [widget, area]
        end
        super
      end

      # Called at end of draw block to flush captured widgets
      def flush_a11y_capture
        widgets = @a11y_widgets
        return unless Labs.enabled?(:a11y) && widgets&.any?

        Labs::A11y.dump_widgets(widgets)
        @a11y_widgets = nil
      end
    end

    prepend A11yCapture
  end
end
