# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # Provides access to the terminal buffer for rendering widgets.
  #
  # Rendering in immediate-mode TUIs requires knowing the terminal dimensions and
  # placing widgets at specific positions. Without explicit control, layout
  # calculations become duplicated between rendering and hit testing.
  #
  # This class exposes the terminal frame during a draw call. It provides the
  # current area and methods to render widgets at precise locations.
  #
  # Use it inside a <tt>RatatuiRuby.draw</tt> block to render widgets with full
  # control over placement.
  #
  # == Thread/Ractor Safety
  #
  # Frame is an *I/O handle*, not a data object. It has side effects
  # (render_widget, set_cursor_position) and is intentionally *not*
  # Ractor-shareable. Passing it to helper methods during the draw block is
  # fine. However, do not include it in immutable TEA Models/Messages or pass
  # it to other Ractors. Frame is only valid during the draw block's execution.
  #
  # === Examples
  #
  # Basic usage with a single widget:
  #
  #   RatatuiRuby.draw do |frame|
  #     paragraph = RatatuiRuby::Widgets::Paragraph.new(text: "Hello, world!")
  #     frame.render_widget(paragraph, frame.area)
  #   end
  #
  # Using Layout.split for multi-region layouts:
  #
  #   RatatuiRuby.draw do |frame|
  #     sidebar, main = RatatuiRuby::Layout.split(
  #       frame.area,
  #       direction: :horizontal,
  #       constraints: [
  #         RatatuiRuby::Layout::Constraint.length(20),
  #         RatatuiRuby::Layout::Constraint.fill(1)
  #       ]
  #     )
  #
  #     frame.render_widget(sidebar_widget, sidebar)
  #     frame.render_widget(main_widget, main)
  #
  #     # Store rects for hit testing — no duplication!
  #     @regions = { sidebar: sidebar, main: main }
  #   end
  class Frame
    ##
    # :method: area
    # :call-seq: area() -> Rect
    #
    # Returns the full terminal area as a Rect.
    #
    # The returned Rect represents the entire drawable area of the terminal.
    # Use it as the starting point for layout calculations.
    #
    # === Example
    #
    #   RatatuiRuby.draw do |frame|
    #     puts "Terminal size: #{frame.area.width}x#{frame.area.height}"
    #   end
    #
    # (Native method implemented in Rust)

    ##
    # :method: render_widget
    # :call-seq: render_widget(widget, area) -> nil
    #
    # Renders a widget at the specified area.
    #
    # Widgets in RatatuiRuby are immutable Data objects. This method takes a
    # widget and a Rect, rendering the widget's content within that region.
    #
    # [widget]
    #   The widget to render (Paragraph, Layout, List, Table, etc.).
    # [area]
    #   A Rect specifying where to render the widget.
    #
    # === Example
    #
    #   RatatuiRuby.draw do |frame|
    #     para = RatatuiRuby::Widgets::Paragraph.new(text: "Content")
    #     frame.render_widget(para, frame.area)
    #   end
    #
    # (Native method implemented in Rust)

    ##
    # :method: render_stateful_widget
    # :call-seq: render_stateful_widget(widget, area, state) -> nil
    #
    # Renders a widget with persistent state.
    #
    # Some UI components (like List or Table) have **runtime status** (Status) that
    # changes during rendering, such as the current scroll offset.
    #
    # Since Widget definitions (Configuration Definition) are immutable inputs,
    # you must pass a separate mutable State object (Output Status) to capture
    # these changes.
    #
    # Note: The Widget configuration is *always* required. The State object is
    # only used for specific widgets that need to persist runtime status.
    #
    #
    # [widget]
    #   The immutable widget configuration (Input) (e.g., RatatuiRuby::List).
    # [area]
    #   The Rect area to render into.
    # [state]
    #   The mutable state object (Output) (e.g., RatatuiRuby::ListState).
    #
    # === Example
    #
    #   # Initialize state once (outside the loop)
    #   @list_state = RatatuiRuby::ListState.new
    #
    #   RatatuiRuby.draw do |frame|
    #     list = RatatuiRuby::Widgets::List.new(items: ["A", "B"])
    #     frame.render_stateful_widget(list, frame.area, @list_state)
    #   end
    #
    #   # Read back the offset calculated by Ratatui
    #   puts @list_state.offset
    #
    # (Native method implemented in Rust)

    ##
    # :method: set_cursor_position
    # :call-seq: set_cursor_position(x, y) -> nil
    #
    # Positions the blinking cursor at the given coordinates.
    #
    # Text input fields show users where typed characters will appear. Without
    # a visible cursor, users cannot tell if the input is focused or where text
    # will insert.
    #
    # This method moves the terminal cursor to a specific cell. Coordinates are
    # 0-indexed from the terminal's top-left corner.
    #
    # Use it when building login forms, search bars, or command palettes.
    #
    # [x]
    #   Column position (<tt>0</tt> = leftmost column).
    # [y]
    #   Row position (<tt>0</tt> = topmost row).
    #
    # === Example
    #
    # Position the cursor at the end of typed text in a login form:
    #
    #   PREFIX = "Username: [ "
    #   username = "alice"
    #
    #   RatatuiRuby.draw do |frame|
    #     # Render the input field
    #     prompt = RatatuiRuby::Widgets::Paragraph.new(
    #       text: "#{PREFIX}#{username} ]",
    #       block: RatatuiRuby::Widgets::Block.new(borders: :all)
    #     )
    #     frame.render_widget(prompt, frame.area)
    #
    #     # Position cursor after the typed text
    #     # Account for border (1) + prefix length + username length
    #     cursor_x = 1 + PREFIX.length + username.length
    #     cursor_y = 1  # First line inside border
    #     frame.set_cursor_position(cursor_x, cursor_y)
    #   end
    #
    # See also:
    # - {Component-based implementation using Frame API}[link:/examples/app_color_picker/app_rb.html]
    # - {Declarative implementation using Tree API}[link:/examples/app_login_form/app_rb.html]
    # - RatatuiRuby::Cursor (Tree API alternative)
    #
    # (Native method implemented in Rust)
  end
end
