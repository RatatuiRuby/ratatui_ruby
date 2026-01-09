# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "minitest/autorun"
require "ratatui_ruby"
require "ratatui_ruby/test_helper"

class TestErrorMessages < Minitest::Test
  include RatatuiRuby::TestHelper

  # TDD: Error messages should include the actual value received
  # to help developers debug type mismatches.

  def test_table_rows_error_includes_received_value
    with_test_terminal do
      # Pass a hash where an array is expected for `rows:`
      bad_rows = { title: "Processes", header: ["Name"], rows: [] }

      error = assert_raises(TypeError) do
        RatatuiRuby.draw do |frame|
          table = RatatuiRuby::Widgets::Table.new(rows: bad_rows, widths: [])
          frame.render_widget(table, frame.area)
        end
      end

      # Error message should include "got" and the inspected value
      assert_match(/expected array for rows/, error.message)
      assert_match(/got/, error.message)
      if RUBY_VERSION >= "3.4"
        assert_match(/title:/, error.message)
      else
        assert_match(/:title=>/, error.message)
      end
    end
  end
end
