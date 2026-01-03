# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  class Session
    # Widget factory methods for Session.
    #
    # Provides convenient access to all Widgets::* classes without
    # fully qualifying the class names. This is the largest mixin,
    # covering all renderable UI components.
    module WidgetFactories
      # Creates a Widgets::Block.
      # @return [Widgets::Block]
      def block(...)
        Widgets::Block.new(...)
      end

      # Creates a Widgets::Paragraph.
      # @return [Widgets::Paragraph]
      def paragraph(...)
        Widgets::Paragraph.new(...)
      end

      # Creates a Widgets::List.
      # @return [Widgets::List]
      def list(...)
        Widgets::List.new(...)
      end

      # Creates a Widgets::ListItem.
      # @return [Widgets::ListItem]
      def list_item(...)
        Widgets::ListItem.new(...)
      end

      # Creates a Widgets::Table.
      # @return [Widgets::Table]
      def table(...)
        Widgets::Table.new(...)
      end

      # Creates a Widgets::Row (for Table rows).
      # @return [Widgets::Row]
      def row(...)
        Widgets::Row.new(...)
      end

      # Creates a Widgets::Row (alias for table row).
      # @return [Widgets::Row]
      def table_row(...)
        Widgets::Row.new(...)
      end

      # Creates a Widgets::Cell (for Table cells).
      # @return [Widgets::Cell]
      def table_cell(...)
        Widgets::Cell.new(...)
      end

      # Creates a Widgets::Tabs.
      # @return [Widgets::Tabs]
      def tabs(...)
        Widgets::Tabs.new(...)
      end

      # Creates a Widgets::Gauge.
      # @return [Widgets::Gauge]
      def gauge(...)
        Widgets::Gauge.new(...)
      end

      # Creates a Widgets::LineGauge.
      # @return [Widgets::LineGauge]
      def line_gauge(...)
        Widgets::LineGauge.new(...)
      end

      # Creates a Widgets::Sparkline.
      # @return [Widgets::Sparkline]
      def sparkline(...)
        Widgets::Sparkline.new(...)
      end

      # Creates a Widgets::BarChart.
      # @return [Widgets::BarChart]
      def bar_chart(...)
        Widgets::BarChart.new(...)
      end

      # Creates a Widgets::BarChart::Bar.
      # @return [Widgets::BarChart::Bar]
      def bar(...)
        Widgets::BarChart::Bar.new(...)
      end

      # Creates a Widgets::BarChart::BarGroup.
      # @return [Widgets::BarChart::BarGroup]
      def bar_group(...)
        Widgets::BarChart::BarGroup.new(...)
      end

      # Creates a Widgets::BarChart::Bar (alias).
      # @return [Widgets::BarChart::Bar]
      def bar_chart_bar(...)
        Widgets::BarChart::Bar.new(...)
      end

      # Creates a Widgets::BarChart::BarGroup (alias).
      # @return [Widgets::BarChart::BarGroup]
      def bar_chart_bar_group(...)
        Widgets::BarChart::BarGroup.new(...)
      end

      # Creates a Widgets::Chart.
      # @return [Widgets::Chart]
      def chart(...)
        Widgets::Chart.new(...)
      end

      # Creates a Widgets::Dataset.
      # @return [Widgets::Dataset]
      def dataset(...)
        Widgets::Dataset.new(...)
      end

      # Creates a Widgets::Axis.
      # @return [Widgets::Axis]
      def axis(...)
        Widgets::Axis.new(...)
      end

      # Creates a Widgets::Scrollbar.
      # @return [Widgets::Scrollbar]
      def scrollbar(...)
        Widgets::Scrollbar.new(...)
      end

      # Creates a Widgets::Calendar.
      # @return [Widgets::Calendar]
      def calendar(...)
        Widgets::Calendar.new(...)
      end

      # Creates a Widgets::Canvas.
      # @return [Widgets::Canvas]
      def canvas(...)
        Widgets::Canvas.new(...)
      end

      # Creates a Widgets::Clear.
      # @return [Widgets::Clear]
      def clear(...)
        Widgets::Clear.new(...)
      end

      # Creates a Widgets::Cursor.
      # @return [Widgets::Cursor]
      def cursor(...)
        Widgets::Cursor.new(...)
      end

      # Creates a Widgets::Overlay.
      # @return [Widgets::Overlay]
      def overlay(...)
        Widgets::Overlay.new(...)
      end

      # Creates a Widgets::Center.
      # @return [Widgets::Center]
      def center(...)
        Widgets::Center.new(...)
      end

      # Creates a Widgets::RatatuiLogo.
      # @return [Widgets::RatatuiLogo]
      def ratatui_logo(...)
        Widgets::RatatuiLogo.new(...)
      end

      # Creates a Widgets::RatatuiMascot.
      # @return [Widgets::RatatuiMascot]
      def ratatui_mascot(...)
        Widgets::RatatuiMascot.new(...)
      end

      # Creates a Widgets::Shape::Label.
      # @return [Widgets::Shape::Label]
      def shape_label(...)
        Widgets::Shape::Label.new(...)
      end
    end
  end
end
