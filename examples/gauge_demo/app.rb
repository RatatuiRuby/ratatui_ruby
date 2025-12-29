# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

# Demonstrates Gauge widget with interactive attribute cycling.
class GaugeDemoApp
  def initialize
    @ratio = 0.65
    @ratios = [0.0, 0.25, 0.5, 0.65, 0.8, 0.95, 1.0]
    @ratio_index = 3

    @gauge_colors = [
      { name: "Green", color: :green },
      { name: "Yellow", color: :yellow },
      { name: "Red", color: :red },
      { name: "Cyan", color: :cyan },
      { name: "Blue", color: :blue }
    ]
    @gauge_color_index = 0

    @bg_styles = [
      { name: "None", style: nil },
      { name: "Dark Gray BG", style: RatatuiRuby::Style.new(fg: :dark_gray) },
      { name: "White on Black", style: RatatuiRuby::Style.new(fg: :white, bg: :black) },
      { name: "Bold White", style: RatatuiRuby::Style.new(fg: :white, modifiers: [:bold]) }
    ]
    @bg_style_index = 1

    @use_unicode_options = [true, false]
    @use_unicode_index = 0

    @label_modes = [
      { name: "Percentage", template: ->(ratio) { "#{(ratio * 100).to_i}%" } },
      { name: "Ratio (decimal)", template: ->(ratio) { format("%.2f", ratio) } },
      { name: "Progress", template: ->(ratio) { "Progress: #{(ratio * 100).to_i}%" } },
      { name: "None", template: ->(ratio) { nil } }
    ]
    @label_mode_index = 0
  end

  def run
    RatatuiRuby.run do
      loop do
        render
        break if handle_input == :quit
      end
    end
  end

  private

  def render
    @ratio = @ratios[@ratio_index]
    gauge_color = @gauge_colors[@gauge_color_index][:color]
    bg_style = @bg_styles[@bg_style_index][:style]
    use_unicode = @use_unicode_options[@use_unicode_index]
    label_template = @label_modes[@label_mode_index][:template]

    gauge_style = RatatuiRuby::Style.new(fg: gauge_color)
    label = label_template.call(@ratio)

    layout = RatatuiRuby::Layout.new(
      direction: :horizontal,
      constraints: [
        RatatuiRuby::Constraint.new(type: :percentage, value: 70),
        RatatuiRuby::Constraint.new(type: :percentage, value: 30)
      ],
      children: [
        # Main content area with multiple gauge examples
        RatatuiRuby::Layout.new(
          direction: :vertical,
          constraints: [
            RatatuiRuby::Constraint.length(1),
            RatatuiRuby::Constraint.length(3),
            RatatuiRuby::Constraint.length(3),
            RatatuiRuby::Constraint.length(3),
            RatatuiRuby::Constraint.fill(1)
          ],
          children: [
            RatatuiRuby::Paragraph.new(
              text: "Gauge Widget Demo - Cycle attributes with hotkeys"
            ),
            # Gauge 1: Main interactive gauge
            RatatuiRuby::Gauge.new(
              ratio: @ratio,
              label:,
              style: bg_style,
              gauge_style:,
              use_unicode:,
              block: RatatuiRuby::Block.new(title: "Interactive Gauge")
            ),
            # Gauge 2: Inverse ratio for comparison
            RatatuiRuby::Gauge.new(
              ratio: 1.0 - @ratio,
              label: label_template.call(1.0 - @ratio),
              style: bg_style,
              gauge_style:,
              use_unicode:,
              block: RatatuiRuby::Block.new(title: "Inverse (1.0 - ratio)")
            ),
            # Gauge 3: Fixed at different stages
            RatatuiRuby::Gauge.new(
              ratio: [@ratio, 0.5].max,
              label: "Min 50%",
              style: RatatuiRuby::Style.new(fg: :dark_gray),
              gauge_style: RatatuiRuby::Style.new(fg: :magenta),
              use_unicode:,
              block: RatatuiRuby::Block.new(title: "Min Threshold (Magenta)")
            ),
            RatatuiRuby::Paragraph.new(text: "")
          ]
        ),
        # Sidebar with controls
        RatatuiRuby::Layout.new(
          direction: :vertical,
          constraints: [
            RatatuiRuby::Constraint.length(6),
            RatatuiRuby::Constraint.length(5),
            RatatuiRuby::Constraint.length(5),
            RatatuiRuby::Constraint.length(4),
            RatatuiRuby::Constraint.fill(1)
          ],
          children: [
            # Ratio control
            RatatuiRuby::Block.new(
              title: "Ratio",
              borders: [:all],
              children: [
                RatatuiRuby::Paragraph.new(
                  text: [
                    "←→: Adjust",
                    "  Current: #{format('%.2f', @ratio)}"
                  ]
                )
              ]
            ),
            # Gauge color control
            RatatuiRuby::Block.new(
              title: "Gauge Color",
              borders: [:all],
              children: [
                RatatuiRuby::Paragraph.new(
                  text: [
                    "g: Cycle",
                    "  #{@gauge_colors[@gauge_color_index][:name]}"
                  ]
                )
              ]
            ),
            # Background style control
            RatatuiRuby::Block.new(
              title: "Background",
              borders: [:all],
              children: [
                RatatuiRuby::Paragraph.new(
                  text: [
                    "b: Cycle",
                    "  #{@bg_styles[@bg_style_index][:name]}"
                  ]
                )
              ]
            ),
            # Unicode and label mode
            RatatuiRuby::Block.new(
              title: "Options",
              borders: [:all],
              children: [
                RatatuiRuby::Paragraph.new(
                  text: [
                    "u: Unicode (#{use_unicode ? 'on' : 'off'})",
                    "l: Label",
                    "  #{@label_modes[@label_mode_index][:name]}"
                  ]
                )
              ]
            ),
            # General
            RatatuiRuby::Block.new(
              title: "General",
              borders: [:all],
              children: [
                RatatuiRuby::Paragraph.new(text: "q: Quit")
              ]
            )
          ]
        )
      ]
    )

    RatatuiRuby.draw(layout)
  end

  def handle_input
    event = RatatuiRuby.poll_event
    return unless event

    case event
    in {type: :key, code: "q"} | {type: :key, code: "c", modifiers: ["ctrl"]}
      :quit
    in type: :key, code: "right"
      @ratio_index = (@ratio_index + 1) % @ratios.length
    in type: :key, code: "left"
      @ratio_index = (@ratio_index - 1) % @ratios.length
    in type: :key, code: "g"
      @gauge_color_index = (@gauge_color_index + 1) % @gauge_colors.length
    in type: :key, code: "b"
      @bg_style_index = (@bg_style_index + 1) % @bg_styles.length
    in type: :key, code: "u"
      @use_unicode_index = (@use_unicode_index + 1) % @use_unicode_options.length
    in type: :key, code: "l"
      @label_mode_index = (@label_mode_index + 1) % @label_modes.length
    end
  end
end

GaugeDemoApp.new.run if __FILE__ == $PROGRAM_NAME
