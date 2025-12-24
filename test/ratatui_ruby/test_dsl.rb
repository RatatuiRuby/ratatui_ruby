# test/ratatui_ruby/test_app_pattern.rb
require "test_helper"

class TestAppPattern < Minitest::Test
  def test_dsl_object_delegation
    with_test_terminal(20, 1) do
      RatatuiRuby.main_loop do |tui|
        p = tui.paragraph(text: "Builder Works")
        tui.draw(p)
        assert_equal "Builder Works       ", buffer_content[0]
        break
      end
    end
  end
end