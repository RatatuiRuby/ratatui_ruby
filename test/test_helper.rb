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
  SimpleCov.start do
    add_filter "test/"
    add_filter "examples/"
    add_filter "tasks/"
    add_filter "ext/"
  end
rescue LoadError
  # SimpleCov not installed
end

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"

module Warning
  module RaiseOnWarn
    def warn(message)
      # Ignore experimental warnings from the library itself
      if message.include?("experimental")
        super
        return
      end

      # Raise strictly on any other warning
      raise message
    end
  end
  singleton_class.prepend(RaiseOnWarn)
end

# Disable experimental warnings for library tests - we already know these features are experimental.
# Application developers' tests are not affected by this setting.
RatatuiRuby.experimental_warnings = false

require "minitest/autorun"

require "ratatui_ruby/test_helper"

##
# Temporarily sets an environment variable within a block.
#
# Safely saves the original value, sets the new value, yields, and then
# restores the original (or deletes if it was not set before).
#
# This prevents the common bug where a test sets an ENV var and then
# deletes it, accidentally affecting all subsequent tests in the process.
#
# === Example
#
#   with_env("UPDATE_SNAPSHOTS", "1") do
#     # ENV["UPDATE_SNAPSHOTS"] == "1" here
#   end
#   # Original value restored (or deleted if it wasn't set)
#
def with_env(key, value)
  original = ENV[key]
  ENV[key] = value
  yield
ensure
  original ? ENV[key] = original : ENV.delete(key)
end
