# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

class RatatuiLogoDemoApp
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
    # Main content: The Logo
    logo = RatatuiRuby::RatatuiLogo.new
    
    # Center the logo using nested Layouts
    # Logo is roughly 47x8
    centered_logo = RatatuiRuby::Layout.new(
      direction: :vertical,
      flex: :center,
      constraints: [RatatuiRuby::Constraint.length(10)], # Height + margin
      children: [
        RatatuiRuby::Layout.new(
          direction: :horizontal,
          flex: :center,
          constraints: [RatatuiRuby::Constraint.length(50)], # Width + margin
          children: [logo]
        )
      ]
    )

    # Control Panel
    control_text = RatatuiRuby::Text::Line.new(spans: [
      RatatuiRuby::Text::Span.new(content: "q", style: RatatuiRuby::Style.new(modifiers: [:bold, :underlined])),
      RatatuiRuby::Text::Span.new(content: ": Quit")
    ])

    control_panel = RatatuiRuby::Paragraph.new(
      text: [control_text],
      block: RatatuiRuby::Block.new(
        title: "Controls",
        borders: [:top],
        style: RatatuiRuby::Style.new(fg: :dark_gray)
      )
    )

    # Layout
    layout = RatatuiRuby::Layout.new(
      direction: :vertical,
      constraints: [
        RatatuiRuby::Constraint.fill(1), # Fill remaining space
        RatatuiRuby::Constraint.length(3)
      ],
      children: [
        centered_logo,
        control_panel
      ]
    )

    RatatuiRuby.draw(layout)
  end

  def handle_input
    case RatatuiRuby.poll_event
    in {type: :key, code: "q"} | {type: :key, code: "c", modifiers: ["ctrl"]}
      :quit
    else
      nil
    end
  end
end

RatatuiLogoDemoApp.new.run if __FILE__ == $0
