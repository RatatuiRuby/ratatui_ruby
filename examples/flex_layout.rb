# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "ratatui_ruby"

class FlexLayoutApp
  def run
    RatatuiRuby.init_terminal
    begin
      loop do
        render
        break if handle_input == :quit
      end
    ensure
      RatatuiRuby.restore_terminal
    end
  end

  def render
    view_tree = RatatuiRuby::Layout.new(
      direction: :vertical,
      constraints: [
        RatatuiRuby::Constraint.length(3),
        RatatuiRuby::Constraint.fill(1),
        RatatuiRuby::Constraint.fill(1),
        RatatuiRuby::Constraint.fill(1),
        RatatuiRuby::Constraint.fill(1)
      ],
      children: [
        RatatuiRuby::Paragraph.new(
          text: "Fill & Flex Layout Demo (press 'q' to quit)",
          block: RatatuiRuby::Block.new(title: "Header", borders: [:all])
        ),
        fill_demo_row,
        space_between_demo_row,
        space_evenly_demo_row,
        ratio_demo_row
      ]
    )

    RatatuiRuby.draw(view_tree)
  end

  def fill_demo_row
    RatatuiRuby::Layout.new(
      direction: :horizontal,
      constraints: [
        RatatuiRuby::Constraint.fill(1),
        RatatuiRuby::Constraint.fill(3)
      ],
      children: [
        RatatuiRuby::Block.new(
          title: "Fill(1)",
          borders: [:all],
          border_color: "red"
        ),
        RatatuiRuby::Block.new(
          title: "Fill(3)",
          borders: [:all],
          border_color: "blue"
        )
      ]
    )
  end

  def space_between_demo_row
    RatatuiRuby::Layout.new(
      direction: :horizontal,
      flex: :space_between,
      constraints: [
        RatatuiRuby::Constraint.length(12),
        RatatuiRuby::Constraint.length(12),
        RatatuiRuby::Constraint.length(12)
      ],
      children: [
        RatatuiRuby::Block.new(
          title: "Block A",
          borders: [:all],
          border_color: "green"
        ),
        RatatuiRuby::Block.new(
          title: "Block B",
          borders: [:all],
          border_color: "yellow"
        ),
        RatatuiRuby::Block.new(
          title: "Block C",
          borders: [:all],
          border_color: "magenta"
        )
      ]
    )
  end

  def space_evenly_demo_row
    RatatuiRuby::Layout.new(
      direction: :horizontal,
      flex: :space_evenly,
      constraints: [
        RatatuiRuby::Constraint.length(12),
        RatatuiRuby::Constraint.length(12),
        RatatuiRuby::Constraint.length(12)
      ],
      children: [
        RatatuiRuby::Block.new(
          title: "Even A",
          borders: [:all],
          border_color: "cyan"
        ),
        RatatuiRuby::Block.new(
          title: "Even B",
          borders: [:all],
          border_color: "blue"
        ),
        RatatuiRuby::Block.new(
          title: "Even C",
          borders: [:all],
          border_color: "red"
        )
      ]
    )
  end

  def ratio_demo_row
    RatatuiRuby::Layout.new(
      direction: :horizontal,
      constraints: [
        RatatuiRuby::Constraint.ratio(1, 4),
        RatatuiRuby::Constraint.ratio(3, 4)
      ],
      children: [
        RatatuiRuby::Block.new(
          title: "Ratio(1, 4)",
          borders: [:all],
          border_color: "green"
        ),
        RatatuiRuby::Block.new(
          title: "Ratio(3, 4)",
          borders: [:all],
          border_color: "magenta"
        )
      ]
    )
  end

  def handle_input
    event = RatatuiRuby.poll_event
    return unless event

    :quit if event == "q" || event == :ctrl_c
  end
end

FlexLayoutApp.new.run if __FILE__ == $0
