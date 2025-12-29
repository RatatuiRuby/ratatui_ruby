require "minitest/autorun"
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require_relative "cell_demo"

class TestCellDemo < Minitest::Test
  include RatatuiRuby::TestHelper

  def test_cell_demo_output
    # Run the demo in a test terminal
    # We'll inject a 'q' key to exit the loop immediately after the first draw
    with_test_terminal(40, 20, timeout: 5) do
      inject_key("q")
      CellDemo.new.main

      # Verify Custom Widget Output
      # Check for "░" character from CheckeredBackground
      # It should be visible around the centered widget
      assert_includes buffer_content.join("\n"), "░"

      # Verify Table Output
      # Content strings
      assert_includes buffer_content.join("\n"), "System Status"
      assert_includes buffer_content.join("\n"), "Database"
      assert_includes buffer_content.join("\n"), "Worker"
      
      # We can't easily grep for "FAIL" with color in simple string content check,
      # but we can check the text presence.
      assert_includes buffer_content.join("\n"), "FAIL"
      assert_includes buffer_content.join("\n"), "OK"
      assert_includes buffer_content.join("\n"), "RESTARTING"
    end
  end
end
