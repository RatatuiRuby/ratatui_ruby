# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)

require "ratatui_ruby"

class QuickstartLayoutApp
  def run
    RatatuiRuby.run do |tui|
      loop do
        tui.draw do |frame|
          # 1. Split the screen
          top, bottom = tui.layout_split(
            frame.area,
            direction: :vertical,
            constraints: [
              tui.constraint_percentage(75),
              tui.constraint_percentage(25),
            ]
          )

          # 2. Render Top Widget
          frame.render_widget(
            tui.paragraph(
              text: "Hello, Ratatui!",
              alignment: :center,
              block: tui.block(title: "Content", borders: [:all], border_color: "cyan")
            ),
            top
          )

          # 3. Render Bottom Widget with Styled Text
          # We use a Line of Spans to style specific characters
          text_line = tui.text_line(
            spans: [
              tui.text_span(content: "Press '"),
              tui.text_span(
                content: "q",
                style: tui.style(modifiers: [:bold, :underlined])
              ),
              tui.text_span(content: "' to quit."),
            ],
            alignment: :center
          )

          frame.render_widget(
            tui.paragraph(
              text: text_line,
              block: tui.block(title: "Controls", borders: [:all])
            ),
            bottom
          )
        end

        event = tui.poll_event
        break if event == "q" || event == :ctrl_c
      end
    end
  end
end

QuickstartLayoutApp.new.run if __FILE__ == $PROGRAM_NAME
