# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "session/core"
require_relative "session/layout_factories"
require_relative "session/style_factories"
require_relative "session/widget_factories"
require_relative "session/text_factories"
require_relative "session/state_factories"
require_relative "session/canvas_factories"
require_relative "session/buffer_factories"

module RatatuiRuby
  # Manages the terminal lifecycle and provides a concise API for the render loop.
  #
  # Writing a TUI loop involves repetitive boilerplate. You constantly instantiate widgets
  # (<tt>RatatuiRuby::Widgets::Paragraph.new</tt>) and call global methods (<tt>RatatuiRuby.draw</tt>).
  # This is verbose and hard to read.
  #
  # The Session object simplifies this. It acts as a factory and a facade. It provides short helper
  # methods for every widget and delegates core commands to the main module.
  #
  # Use it within <tt>RatatuiRuby.run</tt> to build your interface cleanly.
  #
  # == Thread/Ractor Safety
  #
  # Session is an *I/O handle*, not a data object. It has side effects (draw,
  # poll_event) and is intentionally *not* Ractor-shareable. Caching it in
  # instance variables (<tt>@tui = tui</tt>) during your application's run loop
  # is fine. However, do not include it in immutable TEA Models/Messages or
  # pass it to other Ractors.
  #
  # == Included Mixins
  #
  # [Core] Terminal operations: draw, poll_event, get_cell_at, draw_cell.
  # [LayoutFactories] Layout helpers: rect, constraint_*, layout, layout_split.
  # [StyleFactories] Style helpers: style.
  # [WidgetFactories] Widget creation: block, paragraph, list, table, etc.
  # [TextFactories] Text helpers: span, line, text_width.
  # [StateFactories] State objects: list_state, table_state, scrollbar_state.
  # [CanvasFactories] Canvas shapes: shape_map, shape_line, shape_point, etc.
  # [BufferFactories] Buffer inspection: cell.
  #
  # === Examples
  #
  # ==== Basic Usage (Recommended)
  #
  #   RatatuiRuby.run do |tui|
  #     loop do
  #       tui.draw \
  #         tui.paragraph \
  #             text: "Hello, Ratatui! Press 'q' to quit.",
  #             alignment: :center,
  #             block: tui.block(
  #               title: "My Ruby TUI App",
  #               borders: [:all],
  #               border_color: "cyan"
  #             )
  #       event = tui.poll_event
  #       break if event == "q" || event == :ctrl_c
  #     end
  #   end
  class Session
    include Core
    include LayoutFactories
    include StyleFactories
    include WidgetFactories
    include TextFactories
    include StateFactories
    include CanvasFactories
    include BufferFactories
  end
end
