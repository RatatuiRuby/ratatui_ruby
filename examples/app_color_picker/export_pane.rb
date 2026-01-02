# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

# A self-contained component displaying export formats for a color.
#
# Users need to copy color values in different formats (HEX, RGB, HSL).
# This component renders the export section and detects clicks on itself.
#
# === Component Contract
#
# - `render(tui, frame, area, palette:)`: Draws the export formats; stores `area` for hit testing
# - `handle_event(event) -> Symbol | nil`: Returns `:copy_requested` when clicked
#
# === Example
#
#   export_pane = ExportPane.new
#   export_pane.render(tui, frame, area, palette: palette)
#
#   result = export_pane.handle_event(event)
#   if result == :copy_requested && palette.main
#     dialog.open(palette.main.hex)
#   end
class ExportPane
  def initialize
    @area = nil
  end

  # The cached render area, for hit testing.
  attr_reader :area

  # Renders the export formats section into the given area.
  #
  # Shows HEX, RGB, and HSL values for the current color. If no color is set,
  # displays a placeholder message.
  #
  # [tui] Session or TUI factory object
  # [frame] Frame object from RatatuiRuby.draw block
  # [area] Rect area to draw into
  # [palette] Palette object containing the color to display
  #
  # === Example
  #
  #   export_pane.render(tui, frame, export_area, palette: palette)
  def render(tui, frame, area, palette:)
    @area = area
    widget = build_widget(tui, palette)
    frame.render_widget(widget, area)
  end

  # Processes a mouse event and returns a signal if clicked.
  #
  # Returns:
  # - `:copy_requested` when the pane is clicked (caller should open copy dialog)
  # - `nil` when the event was ignored or outside the area
  #
  # [event] Event from RatatuiRuby.poll_event
  #
  # === Example
  #
  #   result = export_pane.handle_event(event)
  #   if result == :copy_requested
  #     dialog.open(palette.main.hex)
  #   end
  def handle_event(event)
    case event
    in { type: :mouse, kind: "down", button: "left", x:, y: }
      if @area&.contains?(x, y)
        :copy_requested
      end
    else
      nil
    end
  end

  private def build_widget(tui, palette)
    if palette.main.nil?
      tui.block(
        title: "Export Formats",
        borders: [:all],
        children: [
          tui.paragraph(
            text: tui.text_line(spans: [
              tui.text_span(content: "Enter a color to see formats"),
            ])
          ),
        ]
      )
    else
      build_color_widget(tui, palette.main)
    end
  end

  private def build_color_widget(tui, color)
    hex = color.hex
    rgb = color.rgb
    hsl = color.hsl_string
    text_color = color.contrasting_text_color
    bg_style = tui.style(bg: hex, fg: text_color)

    tui.block(
      title: "Export Formats",
      borders: [:all],
      style: bg_style,
      children: [
        tui.paragraph(
          text: [
            tui.text_line(spans: [
              tui.text_span(content: "HEX: ", style: bg_style),
              tui.text_span(content: hex, style: tui.style(bg: hex, fg: text_color, modifiers: [:underlined])),
            ]),
            tui.text_line(spans: [
              tui.text_span(content: "RGB: ", style: bg_style),
              tui.text_span(content: rgb, style: tui.style(bg: hex, fg: text_color, modifiers: [:underlined])),
            ]),
            tui.text_line(spans: [
              tui.text_span(content: "HSL: ", style: bg_style),
              tui.text_span(content: hsl, style: tui.style(bg: hex, fg: text_color, modifiers: [:underlined])),
            ]),
          ]
        ),
      ]
    )
  end
end
