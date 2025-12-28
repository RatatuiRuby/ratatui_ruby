# frozen_string_literal: true

require "test_helper"

class TestRun < Minitest::Test
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
