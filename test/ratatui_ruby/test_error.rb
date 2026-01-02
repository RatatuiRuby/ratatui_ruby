# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

class TestError < Minitest::Test
  def test_inheritance
    assert_operator RatatuiRuby::Error::Terminal, :<, RatatuiRuby::Error
    assert_operator RatatuiRuby::Error::Safety, :<, RatatuiRuby::Error
    assert_operator RatatuiRuby::Error, :<, StandardError
  end

  def test_rescue_terminal_error
    error = RatatuiRuby::Error::Terminal.new("test")

    rescued = false
    begin
      raise error
    rescue RatatuiRuby::Error::Terminal
      rescued = true
    end
    assert rescued, "Should distinguish Error::Terminal"

    rescued = false
    begin
      raise error
    rescue RatatuiRuby::Error
      rescued = true
    end
    assert rescued, "Error::Terminal should be caught by Error"
  end

  def test_rescue_safety_error
    error = RatatuiRuby::Error::Safety.new("test")

    rescued = false
    begin
      raise error
    rescue RatatuiRuby::Error::Safety
      rescued = true
    end
    assert rescued, "Should distinguish Error::Safety"

    rescued = false
    begin
      raise error
    rescue RatatuiRuby::Error
      rescued = true
    end
    assert rescued, "Error::Safety should be caught by Error"
  end

  def test_rescue_base_error
    error = RatatuiRuby::Error.new("generic")

    rescued = false
    begin
      raise error
    rescue RatatuiRuby::Error
      rescued = true
    end
    assert rescued, "Should catch RatatuiRuby::Error directly"
  end
end
