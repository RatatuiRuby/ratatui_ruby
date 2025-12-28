# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

begin
  require "simplecov"
  SimpleCov.coverage_dir "tmp/coverage"
  SimpleCov.start
rescue LoadError
  # SimpleCov not installed
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"

require "minitest/autorun"

require "ratatui_ruby/test_helper"

class Minitest::Test
  include RatatuiRuby::TestHelper
end
