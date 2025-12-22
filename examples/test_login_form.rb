# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "login_form"

class Minitest::Test
  include RatatuiRuby::TestHelper
end

class TestLoginForm < Minitest::Test
  def setup
    @app = LoginFormApp.new
  end

  def test_render_initial_state
    with_test_terminal(60, 20) do
      @app.render
      assert buffer_content.any? { |line| line.include?("Enter Username:") }
      # Initial cursor position check could be tricky without inspecting cursor state, 
      # but we can rely on visual cursor rendering if we had a way to check attributes,
      # or just assume the widget logic puts it there.
    end
  end

  def test_input_handling
    # Type 'a'
    RatatuiRuby.stub :poll_event, { code: "a", type: :key } do
      @app.handle_input
    end

    with_test_terminal(60, 20) do
      @app.render
      assert buffer_content.any? { |line| line.include?("Enter Username: [ a ]") }
    end
  end

  def test_popup_flow
    # Enter username 'user'
    ["u", "s", "e", "r"].each do |char|
      RatatuiRuby.stub :poll_event, { code: char, type: :key } do
        @app.handle_input
      end
    end

    # Press Enter
    RatatuiRuby.stub :poll_event, { code: "enter", type: :key } do
      @app.handle_input
    end

    with_test_terminal(60, 20) do
      @app.render
      assert buffer_content.any? { |line| line.include?("Successful!") }
    end
    
    # Press 'q' to quit popup/app
    status = RatatuiRuby.stub :poll_event, { code: "q", type: :key } do
      @app.handle_input
    end
    assert_equal :quit, status
  end
end
