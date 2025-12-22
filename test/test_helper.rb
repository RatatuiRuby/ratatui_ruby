# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"

require "minitest/autorun"

module RatatuiRuby
  module TestHelper
    def with_test_terminal(width = 20, height = 10)
      RatatuiRuby.init_test_terminal(width, height)
      yield
    ensure
      RatatuiRuby.restore_terminal
    end

    def buffer_content
      RatatuiRuby.get_buffer_content.split("\n")
    end

    def cursor_position
      RatatuiRuby.get_cursor_position
    end
  end
end

class Minitest::Test
  include RatatuiRuby::TestHelper
end
