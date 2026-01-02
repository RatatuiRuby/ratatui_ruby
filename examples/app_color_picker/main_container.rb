# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "input"
require_relative "palette"
require_relative "export_pane"
require_relative "controls"
require_relative "clipboard"
require_relative "copy_dialog"

# The root container that owns all child components and orchestrates the UI.
#
# Building a complete color picker UI involves layout calculation, widget
# composition, event routing, and cross-component communication. The Container
# pattern centralizes this orchestration while keeping components decoupled.
#
# This container:
# - **Layout Phase**: Calculates Rects using tui.layout_split
# - **Delegation Phase**: Calls child.render(tui, frame, area) for each component
# - **Event Routing (Chain of Responsibility)**: Delegates events front-to-back
# - **Mediator Pattern**: Manages cross-component communication via symbolic signals
#
# === Component Contract
#
# - `render(tui, frame, area)`: Lays out and renders all children
# - `handle_event(event) -> Symbol | nil`: Routes events to children
# - `tick`: Delegates lifecycle updates (clipboard timer)
#
# === Example
#
#   container = MainContainer.new(tui)
#   container.render(tui, frame, frame.area)
#   result = container.handle_event(event)
#   container.tick
class MainContainer
  def initialize(tui)
    @tui = tui
    @input = Input.new
    @palette = Palette.new(@input.parsed_color)
    @export_pane = ExportPane.new
    @controls = Controls.new
    @clipboard = Clipboard.new
    @dialog = CopyDialog.new(@clipboard)

    # Parse initial color
    initial_result = simulate_initial_parse
    @palette.update_color(initial_result) if initial_result
  end

  # Renders all child components into the given area.
  #
  # Calculates layout once per frame. Delegates rendering to each component.
  # Renders the dialog overlay last for z-ordering.
  #
  # [tui] Session or TUI factory object
  # [frame] Frame object from RatatuiRuby.draw block
  # [area] Rect area to draw into
  #
  # === Example
  #
  #   tui.draw { |frame| container.render(tui, frame, frame.area) }
  def render(tui, frame, area)
    # Layout Phase: calculate all areas
    input_area, rest = tui.layout_split(
      area,
      direction: :vertical,
      constraints: [
        tui.constraint_length(3),
        tui.constraint_fill(1),
      ]
    )

    color_area, control_area = tui.layout_split(
      rest,
      direction: :vertical,
      constraints: [
        tui.constraint_length(14),
        tui.constraint_fill(1),
      ]
    )

    harmony_area, export_area = tui.layout_split(
      color_area,
      direction: :vertical,
      constraints: [
        tui.constraint_length(7),
        tui.constraint_fill(1),
      ]
    )

    # Delegation Phase: render each component
    @input.render(tui, frame, input_area)
    @palette.render(tui, frame, harmony_area)
    @export_pane.render(tui, frame, export_area, palette: @palette)
    @controls.render(tui, frame, control_area, clipboard: @clipboard)

    # Overlay Logic: dialog rendered last for z-ordering
    if @dialog.active?
      dialog_area = calculate_center_area(area, 40, 8)
      frame.render_widget(tui.clear, area)
      @dialog.render(tui, frame, dialog_area)
    end
  end

  # Routes events to child components in visual order (front-to-back).
  #
  # Implements Chain of Responsibility:
  # 1. If dialog is active, offer it the event first
  # 2. Then Input, ExportPane (which may trigger dialog)
  # 3. Mediator pattern: interprets symbolic signals for cross-component effects
  #
  # Returns:
  # - `:consumed` when any component handled the event
  # - `nil` when no component handled the event
  #
  # [event] Event from RatatuiRuby.poll_event
  #
  # === Example
  #
  #   result = container.handle_event(event)
  def handle_event(event)
    # Clear input error when not in dialog mode
    @input.clear_error unless @dialog.active?

    # Front-to-back: dialog has priority when active
    if @dialog.active?
      result = @dialog.handle_event(event)
      return :consumed if result == :consumed
    end

    # Input component
    result = @input.handle_event(event)
    case result
    when :submitted
      # Mediator: sync Input -> Palette
      @palette.update_color(@input.parsed_color)
      return :consumed
    when :consumed
      return :consumed
    end

    # ExportPane: may request copy dialog
    result = @export_pane.handle_event(event)
    if result == :copy_requested && @palette.main
      @dialog.open(@palette.main.hex)
      return :consumed
    end

    # Palette and Controls are display-only
    nil
  end

  # Delegates lifecycle tick to time-sensitive components.
  #
  # Currently handles clipboard feedback timer.
  #
  # === Example
  #
  #   container.tick
  def tick
    @controls.tick(@clipboard)
  end

  private def calculate_center_area(parent_area, width, height)
    x = (parent_area.width - width) / 2
    y = (parent_area.height - height) / 2
    @tui.rect(x:, y:, width:, height:)
  end

  # Simulates the initial parse that happens when the app starts.
  # Input is initialized with a default color, so we need to parse it.
  private def simulate_initial_parse
    require_relative "color"
    Color.parse(@input.value)
  end
end
