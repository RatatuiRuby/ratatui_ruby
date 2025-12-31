# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "input"
require_relative "palette"
require_relative "clipboard"
require_relative "copy_dialog"

# Orchestrates layout and rendering of the color picker UI.
#
# Building a complete color picker UI involves layout calculation, widget
# composition, and coordinate tracking for hit testing. Keeping this logic
# scattered across the main app makes the app harder to read and test.
#
# This object owns the layout logic. It orchestrates all sections. It calculates
# and caches rects for hit testing.
#
# Use it to encapsulate complex UI composition.
#
# === Example
#
#   scene = Scene.new(tui)
#   scene.render(frame, input:, palette:, clipboard:, dialog:)
#
#   # For hit testing:
#   rect = scene.export_rect
#   if rect.contains?(x, y)
#     # Handle click
#   end
class Scene
  def initialize(tui)
    @tui = tui
    @export_area_rect = nil
    @hotkey_style = @tui.style(modifiers: [:bold, :underlined])
  end

  # Renders the complete UI given all model objects.
  #
  # Calculates layout once per frame. Renders input, palette, export, controls,
  # and dialog sections. Caches the export area rect for hit testing.
  #
  # [frame] Frame object from RatatuiRuby.draw block
  # [input] Input object for text input display
  # [palette] Palette object for color display
  # [clipboard] Clipboard object for feedback message
  # [dialog] CopyDialog object for confirmation dialog
  #
  # === Example
  #
  #   scene.render(frame, input: @input, palette: @palette, clipboard: @clipboard, dialog: @dialog)
  def render(frame, input:, palette:, clipboard:, dialog:)
    input_area, rest = @tui.layout_split(
      frame.area,
      direction: :vertical,
      constraints: [
        @tui.constraint_length(3),
        @tui.constraint_fill(1),
      ]
    )

    color_area, control_area = @tui.layout_split(
      rest,
      direction: :vertical,
      constraints: [
        @tui.constraint_length(14),
        @tui.constraint_fill(1),
      ]
    )

    harmony_area, @export_area_rect = @tui.layout_split(
      color_area,
      direction: :vertical,
      constraints: [
        @tui.constraint_length(7),
        @tui.constraint_fill(1),
      ]
    )

    frame.render_widget(input.render(@tui), input_area)
    frame.render_widget(build_palette_section(palette, harmony_area), harmony_area)
    frame.render_widget(build_export_section(palette), @export_area_rect)
    frame.render_widget(build_controls_section(clipboard), control_area)

    if dialog.active?
      dialog_center = calculate_center_area(frame.area, 40, 8)
      frame.render_widget(@tui.clear, frame.area)
      frame.render_widget(dialog.render(@tui, dialog_center), dialog_center)
    end
  end

  # The cached rectangle of the export formats section, used for hit testing.
  #
  # Populated during #render. Use this to detect clicks on the export section.
  #
  # === Example
  #
  #   scene.render(frame, ...)
  #   if scene.export_rect.contains?(x, y)
  #     # Click on export section
  #   end
  def export_rect
    @export_area_rect
  end

  private def build_palette_section(palette, _harmony_area)
    if palette.main.nil?
      @tui.paragraph(text: "No color selected")
    else
      blocks = palette.as_blocks(@tui)
      @tui.layout(
        direction: :horizontal,
        constraints: Array.new(blocks.size) { @tui.constraint_fill(1) },
        children: blocks
      )
    end
  end

  private def build_export_section(palette)
    if palette.main.nil?
      @tui.block(
        title: "Export Formats",
        borders: [:all],
        children: [
          @tui.paragraph(
            text: @tui.text_line(spans: [
              @tui.text_span(content: "Enter a color to see formats"),
            ])
          ),
        ]
      )
    else
      color = palette.main
      hex = color.hex
      rgb = color.rgb
      hsl = color.hsl_string
      text_color = color.contrasting_text_color
      bg_style = @tui.style(bg: hex, fg: text_color)

      @tui.block(
        title: "Export Formats",
        borders: [:all],
        style: bg_style,
        children: [
          @tui.paragraph(
            text: [
              @tui.text_line(spans: [
                @tui.text_span(content: "HEX: ", style: bg_style),
                @tui.text_span(content: hex, style: @tui.style(bg: hex, fg: text_color, modifiers: [:underlined])),
              ]),
              @tui.text_line(spans: [
                @tui.text_span(content: "RGB: ", style: bg_style),
                @tui.text_span(content: rgb, style: @tui.style(bg: hex, fg: text_color, modifiers: [:underlined])),
              ]),
              @tui.text_line(spans: [
                @tui.text_span(content: "HSL: ", style: bg_style),
                @tui.text_span(content: hsl, style: @tui.style(bg: hex, fg: text_color, modifiers: [:underlined])),
              ]),
            ]
          ),
        ]
      )
    end
  end

  private def build_controls_section(clipboard)
    control_lines = [
      @tui.text_line(spans: [
        @tui.text_span(content: "a-z/0-9", style: @hotkey_style),
        @tui.text_span(content: ": Type  "),
        @tui.text_span(content: "enter", style: @hotkey_style),
        @tui.text_span(content: ": Parse  "),
        @tui.text_span(content: "bksp", style: @hotkey_style),
        @tui.text_span(content: ": Erase  "),
        @tui.text_span(content: "esc", style: @hotkey_style),
        @tui.text_span(content: ": Quit"),
      ]),
    ]

    unless clipboard.message.empty?
      control_lines << @tui.text_line(spans: [
        @tui.text_span(content: clipboard.message, style: @tui.style(fg: :green, modifiers: [:bold])),
      ])
    end

    @tui.block(
      title: "Controls",
      borders: [:all],
      children: [
        @tui.paragraph(text: control_lines),
      ]
    )
  end

  private def calculate_center_area(parent_area, width, height)
    x = (parent_area.width - width) / 2
    y = (parent_area.height - height) / 2
    @tui.rect(x:, y:, width:, height:)
  end
end
