# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

require "ratatui_ruby"

# This example renders an inline menu. Arrow keys select, enter confirms.
# The menu appears in-place, preserving scrollback. When the user chooses,
# the TUI closes and the script continues with the selected value.
class RadioMenu
  CHOICES = ["Production", "Staging", "Development"]         # ASCII strings are universally supported.
  PREFIXES = { active: "●", inactive: "○" }                  # Some terminals may not support Unicode.
  CONTROLS = "↑/↓: Select | Enter: Choose | Ctrl+C: Cancel"  # Let users know what keys you handle.
  TITLES = [
    "Select Environment", # The default title position is top left.
    {
content: CONTROLS, # Multiple titles can save space.
position: :bottom, # Titles go on the top or bottom,
alignment: :right,
},
] # aligned left, right, or center

  def call                                                   # This method blocks until a choice is made.
    RatatuiRuby.run(viewport: :inline, height: 5) do |tui|   # RatauiRuby.run manages the terminal.
      @tui = tui                                             # The TUI instance is safe to store.
      show_menu until chosen?                                # You can use any loop keyword you like.
    end                                                      # `run` won't return until your block does,
    RadioMenu::CHOICES[@choice]                              # so you can use it synchronously.
  end
                                                             # Classes like RadioMenu are convenient for

  private def show_menu = @tui.draw do |frame| # RatatuiRuby gives you low-level access.
    widget = @tui.paragraph(                                 # But the TUI facade makes it easy to use.
      text: menu_items,                                      # Text can be spans, lines, or paragraphs.
      block: @tui.block(borders: :all, titles: TITLES)       # Blocks give you boxes and titles, and hold
    )                                                        # one or more widgets. We only use one here,
    frame.render_widget(widget, frame.area)                  # but "area" lets you compose sub-views.
  end

  private def chosen? # You are responsible for handling input.
    interaction = @tui.poll_event                            # Every frame, you receive an event object:
    return choose if interaction.enter?                      # Key, Mouse, Resize, Paste, FocusGained,
                                                             # FocusLost, or None objects. They come with
    move_by(-1) if interaction.up?                           # predicates, support pattern matching, and
    move_by(1) if interaction.down?                          # can be inspected for properties directly.
    quit! if interaction.ctrl_c?                             # Your application must handle every input,
    false                                                    # even interrupts and other exit patterns.
  end

  private def choose # Here, the loop is about to exit, and the
    prepare_next_line                                        # block will return. The inline viewport
    @choice                                                  # will be torn down and the terminal will
  end                                                        # be restored, but you are responsible for

                                                             # positioning the cursor.
  private def prepare_next_line # To ensure the next output is on a new
    area = @tui.viewport_area                                # line, query the viewport area and move
    RatatuiRuby.cursor_position = [0, area.y + area.height]  # the cursor to the start of the last line.
    puts                                                     # Then print a newline.
  end

  private def quit! # All of your familiar Ruby control flow
    prepare_next_line                                        # keywords work as expected, so we can
    exit 0                                                   # use them to leave the TUI.
  end

  private def move_by(line_count) # You are in full control of your UX, so
    @choice = (@choice + line_count) % CHOICES.size          # you can implement any logic you need:
  end                                                        # Would you "wrap around" here, or not?

  private def menu_items = CHOICES.map.with_index do |choice, i| # Notably, RatatuiRuby has no concept of
    "#{prefix_for(i)} #{choice}"                             # "menus" or "radio buttons". You are in
  end                                                        # full control, but it also means you must

  private def prefix_for(choice_index) # implement the logic yourself. For larger
    return PREFIXES[:active] if choice_index == @choice      # applications, consider using Rooibos,
    PREFIXES[:inactive]                                      # an MVU framework built with RatatuiRuby.
  end                                                        # Or, use the upcoming ratatui-ruby-kit,

                                                             # our object-oriented component library.
  private def initialize = @choice = 0 # However, those are both optional, and
end                                                          # designed for full-screen Terminal UIs.
                                                             # RatatuiRuby will always give you the most
choice = RadioMenu.new.call                                  # control, and is enough for "rich CLI
puts "You chose #{choice}!"                                  # moments" like this one.
