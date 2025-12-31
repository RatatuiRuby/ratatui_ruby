# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

# Configures the test environment.
#
# Loads SimpleCov for coverage analysis.
# Adds `lib` to the load path.
# Requires the library and the test helper module.
#
# Use this entry point for all unit tests.

begin
  require "simplecov"
  SimpleCov.coverage_dir "tmp/coverage"
  SimpleCov.start
rescue LoadError
  # SimpleCov not installed
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"

# Disable experimental warnings for library tests - we already know these features are experimental.
# Application developers' tests are not affected by this setting.
RatatuiRuby.experimental_warnings = false

require "minitest/autorun"

require "ratatui_ruby/test_helper"

