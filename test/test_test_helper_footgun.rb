require "minitest/autorun"
require "ratatui_ruby/test_helper"
require "ratatui_ruby"

class TestFootgunPrevention < Minitest::Test
  include RatatuiRuby::TestHelper

  def test_raises_when_injecting_outside_context
    error = assert_raises(RuntimeError) do
      inject_key("q")
    end
    assert_match(/Events must be injected/, error.message)
  end

  def test_allows_injecting_inside_context
    with_test_terminal(10, 5) do
      # Should not raise
      inject_key("q")
    end
  end
end
