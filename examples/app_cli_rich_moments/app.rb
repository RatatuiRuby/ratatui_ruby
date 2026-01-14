# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"

class AppCliRichMoments
  SPINNER_FRAMES = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"].freeze
  MENU_OPTIONS = [
    "Development Environment",
    "Staging Environment",
    "Production Environment",
  ].freeze

  def initialize
    @selected_index = 0
    @choice = nil
    @tui = RatatuiRuby::TUI.new
  end

  def run
    phase_connecting
    @choice = phase_menu
    phase_editor
    phase_saving
  end

  private def phase_connecting
    RatatuiRuby.run(viewport: :inline, height: 1) do
      10.times do |i|
        render_spinner(SPINNER_FRAMES[i % SPINNER_FRAMES.length], "Connecting to server...")
        sleep 0.1
      end

      # Insert success message above viewport into scrollback
      status = "✓ Connected to server"
      @tui.insert_before(1, @tui.paragraph(text: status, style: @tui.style(fg: :green)))
    end
  end

  private def phase_menu
    RatatuiRuby.run(viewport: :inline, height: 5) do
      loop do
        render_menu
        case handle_menu_input
        when :quit, :select
          # Position cursor after viewport for next phase
          area = @tui.viewport_area

          # # If you wanted to remove the menu from scrollback, you could do:
          # @tui.draw { |frame| frame.render_widget(@tui.clear, frame.area) }
          # # And move the cursor to avoid extra blank space.
          # RatatuiRuby.cursor_position = [0, area.y]

          # But instead, we'll leave it in scrollback for reference.
          # Move the cursor to avoid overwriting it.
          RatatuiRuby.cursor_position = [0, area.y + area.height]

          return MENU_OPTIONS[@selected_index]
        end
      end
    end
  end

  private def phase_editor
    RatatuiRuby.run do # Fullscreen by default
      loop do
        render_editor
        break if handle_editor_input == :quit
      end
    end
  end

  private def phase_saving
    RatatuiRuby.run(viewport: :inline, height: 1) do
      10.times do |i|
        render_spinner(SPINNER_FRAMES[i % SPINNER_FRAMES.length], "Saving configuration...")
        sleep 0.1
      end

      status = "✓ Configuration saved to #{@choice.downcase.gsub(' ', '_')}.yml"
      @tui.insert_before(1, @tui.paragraph(text: status, style: @tui.style(fg: :green)))
    end
  end

  private def render_spinner(frame, message)
    @tui.draw do |f|
      text = "#{frame} #{message}"
      widget = @tui.paragraph(text:, style: @tui.style(fg: :cyan))
      f.render_widget(widget, f.area)
    end
  end

  private def render_menu
    @tui.draw do |f|
      lines = MENU_OPTIONS.map.with_index do |option, idx|
        prefix = (idx == @selected_index) ? "→ " : "  "
        style = (idx == @selected_index) ? @tui.style(fg: :cyan, modifiers: [:bold]) : @tui.style(fg: :white)
        @tui.text_line(spans: [@tui.text_span(content: "#{prefix}#{option}", style:)])
      end

      widget = @tui.paragraph(
        text: lines,
        block: @tui.block(borders: :all, title: "Select Environment")
      )
      f.render_widget(widget, f.area)
    end
  end

  private def render_editor
    @tui.draw do |f|
      areas = @tui.layout_split(
        f.area,
        direction: :vertical,
        constraints: [
          @tui.constraint_fill(1),
          @tui.constraint_length(3),
        ]
      )

      # Main content area
      content_text = [
        "Editing: #{@choice}",
        "",
        "# Database Configuration",
        "database:",
        "  adapter: postgresql",
        "  host: db.example.com",
        "  port: 5432",
        "",
        "# Cache Configuration",
        "cache:",
        "  provider: redis",
        "  ttl: 3600",
      ].join("\n")

      content = @tui.paragraph(
        text: content_text,
        block: @tui.block(borders: :all, title: "Configuration Editor"),
        style: @tui.style(fg: :yellow)
      )
      f.render_widget(content, areas[0])

      # Help panel
      help_text = "q: Save and Exit  |  Ctrl+C: Cancel"
      help = @tui.paragraph(
        text: help_text,
        block: @tui.block(borders: :all),
        style: @tui.style(fg: :dark_gray),
        alignment: :center
      )
      f.render_widget(help, areas[1])
    end
  end

  private def handle_menu_input
    case @tui.poll_event
    in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
      :quit
    in { type: :key, code: "enter" }
      :select
    in { type: :key, code: "up" }
      @selected_index = (@selected_index - 1) % MENU_OPTIONS.length
      nil
    in { type: :key, code: "down" }
      @selected_index = (@selected_index + 1) % MENU_OPTIONS.length
      nil
    else
      nil
    end
  end

  private def handle_editor_input
    case @tui.poll_event
    in { type: :key, code: "q" }
      :quit # "and save," presumably
    in { type: :key, code: "c", modifiers: ["ctrl"] }
      :quit
    else
      nil
    end
  end
end

AppCliRichMoments.new.run if __FILE__ == $PROGRAM_NAME
