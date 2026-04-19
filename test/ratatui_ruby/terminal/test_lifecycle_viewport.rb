# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require "ratatui_ruby"
require "minitest/autorun"
require "test_helper"

class TestTerminalLifecycleViewport < Minitest::Test
  include RatatuiRuby::TestHelper

  def test_run_resolves_inline_symbol_to_viewport_object
    # Verify that run -> init_terminal resolves viewport logic and passes correct strings/ints
    # to the low-level _init_terminal method.

    mock = Minitest::Mock.new
    # _init_terminal(focus_events, bracketed_paste, keyboard_enhancement, viewport_type, viewport_height)
    mock.expect :call, nil do |focus, paste, kbd_enhancement, type_str, height|
      focus == true &&
        paste == true &&
        kbd_enhancement == false &&
        type_str == "inline" &&
        height == 8
    end

    # Stub the private class method _init_terminal
    RatatuiRuby.stub :_init_terminal, mock do
      RatatuiRuby.stub :restore_terminal, -> {} do
        RatatuiRuby.run(viewport: :inline, height: 8) do
          # no-op
        end
      end
    end

    mock.verify
  end
end
