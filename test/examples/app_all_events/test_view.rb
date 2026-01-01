# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "minitest/autorun"
require_relative "../../../examples/app_all_events/view"

class TestView < Minitest::Test
  def test_view_module_exists
    assert_kind_of Module, View
  end
end
