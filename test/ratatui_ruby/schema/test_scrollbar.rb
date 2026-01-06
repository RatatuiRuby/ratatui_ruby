# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

module RatatuiRuby
  class TestScrollbar < Minitest::Test
    include RatatuiRuby::TestHelper
    def test_scrollbar_creation
      s = Widgets::Scrollbar.new(
        content_length: 100,
        position: 10,
        orientation: :horizontal,
        thumb_symbol: "X",
        track_symbol: "-",
        begin_symbol: "<",
        end_symbol: ">"
      )
      assert_equal 100, s.content_length
      assert_equal 10, s.position
      assert_equal :horizontal, s.orientation
      assert_equal "X", s.thumb_symbol
      assert_equal "-", s.track_symbol
      assert_equal "<", s.begin_symbol
      assert_equal ">", s.end_symbol
    end

    def test_scrollbar_defaults
      s = Widgets::Scrollbar.new(content_length: 50, position: 5)
      assert_equal 50, s.content_length
      assert_equal 5, s.position
      assert_equal :vertical, s.orientation
      assert_equal "█", s.thumb_symbol
      assert_nil s.block
    end

    def test_render_vertical
      # Standard vertical scrollbar is on the right of the area
      with_test_terminal(1, 10) do
        s = Widgets::Scrollbar.new(content_length: 10, position: 0)
        RatatuiRuby.draw { |f| f.render_widget(s, f.area) }
        # Position 0 has thumb at row 1, 2, 3, 4
        assert_equal "▲", buffer_content[0]
        assert_equal "█", buffer_content[1]
        assert_equal "█", buffer_content[2]
        assert_equal "█", buffer_content[3]
        assert_equal "█", buffer_content[4]
        assert_equal "║", buffer_content[5]
        assert_equal "║", buffer_content[6]
        assert_equal "║", buffer_content[7]
        assert_equal "║", buffer_content[8]
        assert_equal "▼", buffer_content[9]
      end
    end

    def test_render_horizontal
      with_test_terminal(10, 1) do
        s = Widgets::Scrollbar.new(content_length: 10, position: 0, orientation: :horizontal)
        RatatuiRuby.draw { |f| f.render_widget(s, f.area) }
        # Position 0 has thumb at column 1-4
        assert_equal "◄████════►", buffer_content[0]
      end
    end

    def test_render_styled
      with_test_terminal(10, 1) do
        s = Widgets::Scrollbar.new(
          content_length: 10,
          position: 0,
          orientation: :horizontal,
          thumb_symbol: "#",
          track_symbol: "-",
          begin_symbol: "<",
          end_symbol: ">"
        )
        RatatuiRuby.draw { |f| f.render_widget(s, f.area) }
        # Custom symbols should be rendered
        assert_equal "<####---->", buffer_content[0]
      end
    end

    def test_thumb_style_applies_to_thumb
      with_test_terminal(10, 1) do
        s = Widgets::Scrollbar.new(
          content_length: 10,
          position: 0,
          orientation: :horizontal,
          thumb_style: Style::Style.new(fg: :magenta)
        )
        RatatuiRuby.draw { |f| f.render_widget(s, f.area) }

        ansi_output = render_rich_buffer
        # Magenta foreground = ANSI 35
        assert_includes ansi_output, "\e[35m", "Scrollbar thumb_style should apply magenta foreground"
      end
    end

    def test_track_style_applies_to_track
      with_test_terminal(10, 1) do
        s = Widgets::Scrollbar.new(
          content_length: 10,
          position: 0,
          orientation: :horizontal,
          track_style: Style::Style.new(fg: :yellow)
        )
        RatatuiRuby.draw { |f| f.render_widget(s, f.area) }

        ansi_output = render_rich_buffer
        # Yellow foreground = ANSI 33
        assert_includes ansi_output, "\e[33m", "Scrollbar track_style should apply yellow foreground"
      end
    end
  end
end
