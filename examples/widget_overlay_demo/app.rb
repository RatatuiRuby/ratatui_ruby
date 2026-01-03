# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

HEADLINES = [
  "Scientists Discover New Species of Deep-Sea Octopus Near Hawaii",
  "Global Climate Summit Reaches Historic Agreement on Emissions",
  "Tech Giant Announces Breakthrough in Quantum Computing Research",
  "Local Community Garden Initiative Expands to Ten More Cities",
  "Astronomers Detect Unusual Radio Signals from Distant Galaxy",
  "New Study Links Mediterranean Diet to Improved Heart Health",
  "Electric Vehicle Sales Surge as Battery Technology Improves",
  "Ancient Manuscripts Reveal Previously Unknown Trading Routes",
  "Renewable Energy Now Powers 40% of National Grid",
  "Robotics Team Develops AI System for Disaster Response",
  "Archaeological Dig Uncovers Evidence of Early Human Settlement",
  "Major Airline Commits to Carbon-Neutral Flights by 2035",
  "Breakthrough Treatment Shows Promise for Rare Genetic Disease",
  "City Council Approves Expanded Public Transportation Network",
  "Marine Biologists Track Migration Patterns of Endangered Whales",
  "New App Helps Farmers Optimize Water Usage During Drought",
  "International Space Station Extends Mission Timeline to 2030",
  "Local Schools Implement Innovative STEM Education Program",
  "Wildlife Conservation Efforts Lead to Species Population Recovery",
  "Research Team Creates Biodegradable Alternative to Plastic Packaging",
  "Historic Theater Restoration Project Nears Completion",
  "Cybersecurity Experts Warn of Emerging Online Threats",
  "Community Food Bank Serves Record Number of Families This Year",
  "Innovative Urban Planning Reduces Traffic Congestion by 30%",
].freeze

# Overlay Demo Example
# Demonstrates the Overlay widget for layering widgets with depth.
class WidgetOverlayDemo
  def initialize
    @layer_count = 2 # Start with 2 layers visible
    @swapped = false
    @clear = true
  end

  def run
    RatatuiRuby.run do |tui|
      @tui = tui
      loop do
        tui.draw do |frame|
          render(frame)
        end
        break if handle_input == :quit
        sleep 0.05
      end
    end
  end

  private def render(frame)
    area = frame.area

    # Split into main area and control panel
    layout = @tui.layout_split(
      area,
      direction: :vertical,
      constraints: [
        @tui.constraint_fill(1),
        @tui.constraint_length(5),
      ]
    )

    main_area = layout[0]
    control_area = layout[1]

    # Render background layer - RSS reader
    frame.render_widget(background_layer, main_area)

    # Render upper layers based on layer_count and swap state
    if @swapped
      render_beta_layer(frame, main_area) if @layer_count >= 2
      render_notification_layer(frame, main_area) if @layer_count >= 1
    else
      render_notification_layer(frame, main_area) if @layer_count >= 1
      render_beta_layer(frame, main_area) if @layer_count >= 2
    end

    # Render control panel
    frame.render_widget(control_panel, control_area)
  end

  def background_layer
    @background_layer ||= @tui.list(
      items: HEADLINES,
      block: @tui.block(
        title: "RSS Reader",
        borders: [:all]
      )
    )
  end

  def render_notification_layer(frame, area)
    # Position modal: 20% from top, 60% height, 15% from left, 70% width

    vertical_sections = @tui.layout_split(
      area,
      direction: :vertical,
      constraints: [
        @tui.constraint_fill(2),
        @tui.constraint_fill(5),
        @tui.constraint_fill(3),
      ]
    )

    horizontal_sections = @tui.layout_split(
      vertical_sections[1],
      direction: :horizontal,
      constraints: [
        @tui.constraint_fill(1),
        @tui.constraint_fill(5),
        @tui.constraint_fill(1),
      ]
    )

    modal_rect = horizontal_sections[1]

    frame.render_widget(@tui.clear, modal_rect) if @clear

    # Render the modal content
    frame.render_widget(
      @tui.paragraph(
        text: "Your feeds have been updated",
        wrap: true,
        alignment: :center,
        block: @tui.block(
          title: "Notification",
          borders: [:all],
          border_style: @tui.style(fg: :black),
          style: @tui.style(bg: :red, fg: :black)
        )
      ),
      modal_rect
    )
  end

  def render_beta_layer(frame, area)
    # Position modal: 30% from top, 40% height, 25% from left, 50% width

    vertical_sections = @tui.layout_split(
      area,
      direction: :vertical,
      constraints: [
        @tui.constraint_fill(3),
        @tui.constraint_fill(4),
        @tui.constraint_fill(2),
      ]
    )

    horizontal_sections = @tui.layout_split(
      vertical_sections[1],
      direction: :horizontal,
      constraints: [
        @tui.constraint_fill(2),
        @tui.constraint_fill(3),
        @tui.constraint_fill(2),
      ]
    )

    modal_rect = horizontal_sections[1]

    frame.render_widget(@tui.clear, modal_rect) if @clear

    # Render the modal content
    frame.render_widget(
      beta_paragraph,
      modal_rect
    )
  end

  def beta_paragraph
    @beta_paragraph ||= @tui.paragraph(
      text: "Thank you for being a beta tester. To give feedback, shout very loudly and we will hear you. Be careful not to scare the llamas.",
      wrap: true,
      alignment: :left,
      block: @tui.block(
        title: "Beta Program",
        borders: [:all],
        border_style: @tui.style(fg: :black),
        style: @tui.style(bg: :blue, fg: :black)
      )
    )
  end

  def control_panel
    bold_underline = @tui.style(modifiers: [:bold, :underlined])

    first_controls = [
      @tui.text_span(content: "0", style: bold_underline),
      @tui.text_span(content: "/"),
      @tui.text_span(content: "1", style: bold_underline),
      @tui.text_span(content: "/"),
      @tui.text_span(content: "2", style: bold_underline),
      @tui.text_span(content: ": Change number of overlays | "),
      @tui.text_span(content: "space", style: bold_underline),
      @tui.text_span(content: ": Swap overlay order"),
    ]
    second_controls = [
      @tui.text_span(content: "c", style: bold_underline),
      @tui.text_span(content: ": Toggle clear (currently #{@clear ? 'on' : 'off'})"),
    ]
    third_controls = [
      @tui.text_span(content: "q", style: bold_underline),
      @tui.text_span(content: ": Quit"),
    ]

    first = @tui.text_line(spans: first_controls)
    second = @tui.text_line(spans: second_controls)
    third = @tui.text_line(spans: third_controls)

    @tui.paragraph(
      text: [first, second, third],
      alignment: :center,
      block: @tui.block(
        title: "Controls",
        borders: [:all]
      )
    )
  end

  def handle_input
    case @tui.poll_event
    in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
      :quit
    in { type: :key, code: "0" }
      @layer_count = 0
    in { type: :key, code: "1" }
      @layer_count = 1
    in { type: :key, code: "2" }
      @layer_count = 2
    in { type: :key, code: " " }
      @swapped = !@swapped
    in { type: :key, code: "c" }
      @clear = !@clear
    else
      nil
    end
  end
end

WidgetOverlayDemo.new.run if __FILE__ == $PROGRAM_NAME
