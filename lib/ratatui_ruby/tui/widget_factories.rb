# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  class TUI
    # Widget factory methods for Session.
    #
    # Provides convenient access to all Widgets::* classes without
    # fully qualifying the class names. This is the largest mixin,
    # covering all renderable UI components.
    #
    # All factories use DWIM hash coercion: both `tui.table(hash)` and
    # `tui.table(**hash)` work correctly.
    module WidgetFactories
      # Creates a Widgets::Block.
      # @return [Widgets::Block]
      def block(first = nil, **kwargs)
        Widgets::Block.coerce_args(first, kwargs)
      end

      # Creates a Widgets::Paragraph.
      # @return [Widgets::Paragraph]
      def paragraph(first = nil, **kwargs)
        Widgets::Paragraph.coerce_args(first, kwargs)
      end

      # Creates a Widgets::List.
      # @return [Widgets::List]
      def list(first = nil, **kwargs)
        Widgets::List.coerce_args(first, kwargs)
      end

      # Creates a Widgets::ListItem.
      # @return [Widgets::ListItem]
      def list_item(first = nil, **kwargs)
        Widgets::ListItem.coerce_args(first, kwargs)
      end

      # Creates a Widgets::Table.
      # @return [Widgets::Table]
      def table(first = nil, **kwargs)
        Widgets::Table.coerce_args(first, kwargs)
      end

      # Creates a Widgets::Row (for Table rows).
      # @return [Widgets::Row]
      def row(first = nil, **kwargs)
        Widgets::Row.coerce_args(first, kwargs)
      end

      # Creates a Widgets::Row (alias for table row).
      # @return [Widgets::Row]
      def table_row(first = nil, **kwargs)
        Widgets::Row.coerce_args(first, kwargs)
      end

      # Creates a Widgets::Cell (for Table cells).
      # @return [Widgets::Cell]
      def table_cell(first = nil, **kwargs)
        Widgets::Cell.coerce_args(first, kwargs)
      end

      # Creates a Widgets::Tabs.
      # @return [Widgets::Tabs]
      def tabs(first = nil, **kwargs)
        Widgets::Tabs.coerce_args(first, kwargs)
      end

      # Creates a Widgets::Gauge.
      # @return [Widgets::Gauge]
      def gauge(first = nil, **kwargs)
        Widgets::Gauge.coerce_args(first, kwargs)
      end

      # Creates a Widgets::LineGauge.
      # @return [Widgets::LineGauge]
      def line_gauge(first = nil, **kwargs)
        Widgets::LineGauge.coerce_args(first, kwargs)
      end

      # Creates a Widgets::Sparkline.
      # @return [Widgets::Sparkline]
      def sparkline(first = nil, **kwargs)
        Widgets::Sparkline.coerce_args(first, kwargs)
      end

      # Creates a Widgets::BarChart.
      # @return [Widgets::BarChart]
      def bar_chart(first = nil, **kwargs)
        Widgets::BarChart.coerce_args(first, kwargs)
      end

      # Creates a Widgets::BarChart::Bar.
      # @return [Widgets::BarChart::Bar]
      def bar(first = nil, **kwargs)
        Widgets::BarChart::Bar.coerce_args(first, kwargs)
      end

      # Creates a Widgets::BarChart::BarGroup.
      # @return [Widgets::BarChart::BarGroup]
      def bar_group(first = nil, **kwargs)
        Widgets::BarChart::BarGroup.coerce_args(first, kwargs)
      end

      # Creates a Widgets::BarChart::Bar (alias).
      # @return [Widgets::BarChart::Bar]
      def bar_chart_bar(first = nil, **kwargs)
        Widgets::BarChart::Bar.coerce_args(first, kwargs)
      end

      # Creates a Widgets::BarChart::BarGroup (alias).
      # @return [Widgets::BarChart::BarGroup]
      def bar_chart_bar_group(first = nil, **kwargs)
        Widgets::BarChart::BarGroup.coerce_args(first, kwargs)
      end

      # Creates a Widgets::Chart.
      # @return [Widgets::Chart]
      def chart(first = nil, **kwargs)
        Widgets::Chart.coerce_args(first, kwargs)
      end

      # Creates a Widgets::Dataset.
      # @return [Widgets::Dataset]
      def dataset(first = nil, **kwargs)
        Widgets::Dataset.coerce_args(first, kwargs)
      end

      # Creates a Widgets::Axis.
      # @return [Widgets::Axis]
      def axis(first = nil, **kwargs)
        Widgets::Axis.coerce_args(first, kwargs)
      end

      # Creates a Widgets::Scrollbar.
      # @return [Widgets::Scrollbar]
      def scrollbar(first = nil, **kwargs)
        Widgets::Scrollbar.coerce_args(first, kwargs)
      end

      # Creates a Widgets::Calendar.
      # @return [Widgets::Calendar]
      def calendar(first = nil, **kwargs)
        Widgets::Calendar.coerce_args(first, kwargs)
      end

      # Creates a Widgets::Canvas.
      # @return [Widgets::Canvas]
      def canvas(first = nil, **kwargs)
        Widgets::Canvas.coerce_args(first, kwargs)
      end

      # Creates a Widgets::Clear.
      # @return [Widgets::Clear]
      def clear(first = nil, **kwargs)
        Widgets::Clear.coerce_args(first, kwargs)
      end

      # Creates a Widgets::Cursor.
      # @return [Widgets::Cursor]
      def cursor(first = nil, **kwargs)
        Widgets::Cursor.coerce_args(first, kwargs)
      end

      # Creates a Widgets::Overlay.
      # @return [Widgets::Overlay]
      def overlay(first = nil, **kwargs)
        Widgets::Overlay.coerce_args(first, kwargs)
      end

      # Creates a Widgets::Center.
      # @return [Widgets::Center]
      def center(first = nil, **kwargs)
        Widgets::Center.coerce_args(first, kwargs)
      end

      # Creates a Widgets::RatatuiLogo.
      # @return [Widgets::RatatuiLogo]
      def ratatui_logo(first = nil, **kwargs)
        Widgets::RatatuiLogo.coerce_args(first, kwargs)
      end

      # Creates a Widgets::RatatuiMascot.
      # @return [Widgets::RatatuiMascot]
      def ratatui_mascot(first = nil, **kwargs)
        Widgets::RatatuiMascot.coerce_args(first, kwargs)
      end

      # Creates a Widgets::Shape::Label.
      # @return [Widgets::Shape::Label]
      def shape_label(first = nil, **kwargs)
        Widgets::Shape::Label.coerce_args(first, kwargs)
      end
    end
  end
end
