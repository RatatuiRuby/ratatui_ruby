# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"

# Quick debug script to check viewport initialization

viewport = RatatuiRuby::Terminal::Viewport.inline(5)
puts "Viewport type: #{viewport.type}, height: #{viewport.height}"

RatatuiRuby.instance_variable_set(:@tui_session_active, false)
RatatuiRuby.init_test_terminal(80, 24, viewport.type.to_s, viewport.height)

area = RatatuiRuby.get_terminal_area
puts "Area: #{area.width}x#{area.height}"

RatatuiRuby.restore_terminal
