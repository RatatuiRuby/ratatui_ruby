# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "test_helper"

module RatatuiRuby
  class TestRatatuiLogo < Minitest::Test
    def test_initialize
      logo = Widgets::RatatuiLogo.new
      assert_kind_of Widgets::RatatuiLogo, logo
    end
  end
end
