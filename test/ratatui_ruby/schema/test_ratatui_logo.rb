# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

module RatatuiRuby
  class TestRatatuiLogo < Minitest::Test
    def test_initialize
      logo = RatatuiLogo.new
      assert_kind_of RatatuiLogo, logo
    end
  end
end
