# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later

# frozen_string_literal: true

require "test_helper"

class TestRun < Minitest::Test
  def setup
    # In CI/headless environments, we can't initialize the real terminal.
    # We divert init_terminal to init_test_terminal (headless backend).
    if ENV["CI"] || !$stdout.tty?
      # Only define original_init_terminal if we haven't already
      unless RatatuiRuby.respond_to?(:original_init_terminal)
        RatatuiRuby.define_singleton_method(:original_init_terminal, RatatuiRuby.method(:init_terminal))
      end

      # Remove the existing init_terminal before redefining to avoid warnings
      RatatuiRuby.singleton_class.__send__(:remove_method, :init_terminal)
      RatatuiRuby.define_singleton_method(:init_terminal) do |**_opts|
        init_test_terminal(80, 24)
      end
    end
  end

  def teardown
    if RatatuiRuby.respond_to?(:original_init_terminal)
      # Remove the mock before restoring the original
      RatatuiRuby.singleton_class.__send__(:remove_method, :init_terminal)
      RatatuiRuby.define_singleton_method(:init_terminal, RatatuiRuby.method(:original_init_terminal))
      RatatuiRuby.singleton_class.__send__(:remove_method, :original_init_terminal)
    end
  end

  def test_run_yields_session
    yielded = nil
    RatatuiRuby.run do |tui|
      yielded = tui
    end
    assert_kind_of RatatuiRuby::Session, yielded
  end

  def test_run_returns_block_result
    result = RatatuiRuby.run do
      "hello"
    end
    assert_equal "hello", result
  end

  def test_run_ensures_restore_on_error
    # This is hard to test perfectly without mocking init/restore,
    # but we can ensure the error propagates
    assert_raises(RuntimeError) do
      RatatuiRuby.run do
        raise "oops"
      end
    end
  end
end
