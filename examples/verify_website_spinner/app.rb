# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

# Test 1: Inline spinner example
require "ratatui_ruby"

class Spinner
  def main
    RatatuiRuby.run(viewport: :inline, height: 1) do |tui|
      until connected?
        status = tui.paragraph(text: "#{spin} Connecting...")
        tui.draw { |frame| frame.render_widget(status, frame.area) }
        return ending(tui, "Canceled!", :red) if tui.poll_event.ctrl_c?
      end
      ending(tui, "Connected!", :green)
    end
  end

  def ending(tui, message, color) = tui.draw do |frame|
    frame.render_widget(tui.paragraph(text: message, fg: color), frame.area)
  end

  def initialize = (@frame, @finish = 0, Time.now + 1)
  def connected? = Time.now >= @finish # Simulate work
  def spin = SPINNER[(@frame += 1) % SPINNER.length]
  SPINNER = %w[⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏]
end
Spinner.new.main; puts
