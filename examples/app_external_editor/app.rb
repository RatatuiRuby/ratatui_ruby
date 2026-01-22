# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "tempfile"

# Disable experimental warnings for line_count
RatatuiRuby.experimental_warnings = false

# External Editor Example
#
# Demonstrates full lifecycle control for temporarily exiting the TUI
# to invoke an external editor, then re-entering—like editing a commit
# message in lazygit.
#
# This example uses the low-level API (init_terminal/restore_terminal)
# instead of RatatuiRuby.run, which is required when you need to
# repeatedly enter and exit raw mode during a session.
#
# Features:
# - `e` edits this example's README.md
# - `s` edits a scratch file; saved content appears in a split pane
# - Focus-aware scrolling with visual indicators
# - Mouse scroll on hover
class AppExternalEditor
  README_PATH = File.expand_path("README.md", __dir__)

  def initialize
    @tui = RatatuiRuby::TUI.new
    @readme_scroll = 0
    @scratch_scroll = 0
    @readme_content = File.read(README_PATH)
    @scratch = Tempfile.new(["scratch", ".md"])
    @scratch_content = nil
    @focus = :readme

    # Cached geometry (set during calculate_layout)
    @readme_area = nil
    @scratch_area = nil
    @readme_page_height = 10
    @scratch_page_height = 10
    @readme_line_count = 0
    @scratch_line_count = 0
  end

  def run
    loop do
      action = tui_session
      case action
      when :quit then break
      when :edit_readme then edit_file(README_PATH) { reload_readme }
      when :edit_scratch then edit_file(@scratch.path) { reload_scratch }
      end
    end
  ensure
    @scratch.unlink
  end

  private def tui_session
    RatatuiRuby.init_terminal
    begin
      loop do
        @tui.draw do |frame|
          calculate_layout(frame.area)   # Phase 1: Geometry (once per frame)
          render(frame)                  # Phase 2: Draw
        end
        action = handle_input            # Phase 3: Input (uses cached geometry)
        return action if action          # Early return triggers ensure block
      end
    ensure
      RatatuiRuby.restore_terminal       # Always runs, even on early return
    end
  end

  # Open an external editor on the given file.
  #
  # Note: The terminal is already restored when this method is called!
  # The tui_session method's ensure block handles restore_terminal before
  # we get here. After the editor closes, the run loop calls tui_session
  # again which does init_terminal. This pattern avoids explicit
  # save/restore calls at every handoff point.
  private def edit_file(path)
    editor = ENV.fetch("EDITOR", "vi")
    system(editor, path)
    yield if block_given?
  end

  # Phase 1: Calculate layout and cache all geometry
  private def calculate_layout(area)
    content_area, @controls_area = @tui.layout_split(
      area,
      direction: :vertical,
      constraints: [
        @tui.constraint_fill(1),
        @tui.constraint_length(3),
      ]
    )

    if split_view?
      @readme_area, @scratch_area = @tui.layout_split(
        content_area,
        direction: :horizontal,
        constraints: [
          @tui.constraint_percentage(50),
          @tui.constraint_percentage(50),
        ]
      )
    else
      @readme_area = content_area
      @scratch_area = nil
    end

    # Calculate wrapped line counts and page heights
    calculate_readme_geometry
    calculate_scratch_geometry if split_view?

    # Clamp scroll positions now that we have accurate geometry
    clamp_scroll_positions
  end

  private def calculate_readme_geometry
    block = @tui.block(borders: [:all])
    inner = block.inner(@readme_area)
    @readme_page_height = inner.height

    paragraph = @tui.paragraph(text: @readme_content, wrap: true, block:)
    @readme_line_count = paragraph.line_count(inner.width)
  end

  private def calculate_scratch_geometry
    return unless @scratch_area

    block = @tui.block(borders: [:all])
    inner = block.inner(@scratch_area)
    @scratch_page_height = inner.height

    paragraph = @tui.paragraph(text: @scratch_content || "", wrap: true, block:)
    @scratch_line_count = paragraph.line_count(inner.width)
  end

  private def clamp_scroll_positions
    @readme_scroll = @readme_scroll.clamp(0, max_readme_scroll)
    @scratch_scroll = @scratch_scroll.clamp(0, max_scratch_scroll) if split_view?
  end

  # Phase 2: Render using cached geometry
  private def render(frame)
    render_readme(frame)
    render_scratch(frame) if split_view?
    render_controls(frame)
  end

  private def split_view? = @scratch_content && !@scratch_content.strip.empty?

  private def render_readme(frame)
    focused = @focus == :readme
    paragraph = @tui.paragraph(
      text: @readme_content,
      scroll: [@readme_scroll, 0],
      wrap: true,
      block: @tui.block(
        title: "README.md (#{@readme_scroll + 1}-#{[@readme_scroll + @readme_page_height, @readme_line_count].min}/#{@readme_line_count})",
        borders: [:all],
        border_style: focused ? { fg: "cyan" } : { fg: "dark_gray" }
      )
    )
    frame.render_widget(paragraph, @readme_area)

    # Stateful scrollbar with viewport_content_length
    # content_length = max_scroll + 1, so position=max_scroll => content_length-1 => thumb at bottom
    scrollbar = @tui.scrollbar(content_length: 0, position: 0, orientation: :vertical, track_symbol: nil)
    state = RatatuiRuby::ScrollbarState.new(max_readme_scroll + 1)
    state.position = @readme_scroll
    state.viewport_content_length = @readme_page_height
    frame.render_stateful_widget(scrollbar, @readme_area, state)
  end

  private def render_scratch(frame)
    focused = @focus == :scratch
    paragraph = @tui.paragraph(
      text: @scratch_content,
      scroll: [@scratch_scroll, 0],
      wrap: true,
      block: @tui.block(
        title: "Scratch (#{@scratch_scroll + 1}-#{[@scratch_scroll + @scratch_page_height, @scratch_line_count].min}/#{@scratch_line_count})",
        borders: [:all],
        border_style: focused ? { fg: "yellow" } : { fg: "dark_gray" }
      )
    )
    frame.render_widget(paragraph, @scratch_area)

    # Stateful scrollbar with viewport_content_length
    scrollbar = @tui.scrollbar(content_length: 0, position: 0, orientation: :vertical, track_symbol: nil)
    state = RatatuiRuby::ScrollbarState.new(max_scratch_scroll + 1)
    state.position = @scratch_scroll
    state.viewport_content_length = @scratch_page_height
    frame.render_stateful_widget(scrollbar, @scratch_area, state)
  end

  private def render_controls(frame)
    spans = [
      @tui.text_span(content: "↑/↓", style: hotkey_style),
      @tui.text_span(content: ": Scroll  "),
      @tui.text_span(content: "e", style: hotkey_style),
      @tui.text_span(content: ": Edit README  "),
      @tui.text_span(content: "s", style: hotkey_style),
      @tui.text_span(content: ": Edit Scratch  "),
    ]
    if split_view?
      spans += [
        @tui.text_span(content: "Tab", style: hotkey_style),
        @tui.text_span(content: ": Focus  "),
      ]
    end
    spans += [
      @tui.text_span(content: "q", style: hotkey_style),
      @tui.text_span(content: ": Quit"),
    ]

    paragraph = @tui.paragraph(
      text: [@tui.text_line(spans:)],
      alignment: :center,
      block: @tui.block(title: "Controls", borders: [:all])
    )
    frame.render_widget(paragraph, @controls_area)
  end

  private def hotkey_style = @tui.style(modifiers: [:bold, :underlined])

  # Phase 3: Handle input using cached geometry
  private def handle_input
    case @tui.poll_event
    # Quit
    in { type: :key, code: "q" } | { type: :key, code: "c", modifiers: ["ctrl"] }
      :quit

    # Edit actions
    in { type: :key, code: "e" }
      :edit_readme
    in { type: :key, code: "s" }
      :edit_scratch

    # Focus switching (only in split view)
    in { type: :key, code: "tab" } | { type: :key, code: "backtab" } |
       { type: :key, code: "left" } | { type: :key, code: "right" } |
       { type: :key, code: "h" } | { type: :key, code: "l" } if split_view?
      switch_focus
      nil

    # Keyboard scrolling
    in { type: :key, code: "up" } | { type: :key, code: "k" }
      scroll_up
      nil
    in { type: :key, code: "down" } | { type: :key, code: "j" }
      scroll_down
      nil
    in { type: :key, code: "page_up" }
      scroll_up(page_height)
      nil
    in { type: :key, code: "page_down" }
      scroll_down(page_height)
      nil
    in { type: :key, code: "home" }
      scroll_to(0)
      nil
    in { type: :key, code: "end" }
      scroll_to(max_scroll)
      nil

    # Mouse scroll - hit test to determine target pane
    in { type: :mouse, kind: "scroll_up", x:, y: }
      pane = pane_at(x, y)
      scroll_pane_up(pane) if pane
      nil
    in { type: :mouse, kind: "scroll_down", x:, y: }
      pane = pane_at(x, y)
      scroll_pane_down(pane) if pane
      nil

    # Mouse click to focus (only in split view)
    in { type: :mouse, kind: "down", x:, y: } if split_view?
      pane = pane_at(x, y)
      @focus = pane if pane
      nil

    else
      nil
    end
  end

  private def pane_at(x, y)
    if @scratch_area&.contains?(x, y)
      :scratch
    elsif @readme_area&.contains?(x, y)
      :readme
    end
  end

  private def switch_focus
    @focus = (@focus == :readme) ? :scratch : :readme
  end

  private def scroll_up(n = 1) = scroll_pane_up(@focus, n)
  private def scroll_down(n = 1) = scroll_pane_down(@focus, n)

  private def scroll_pane_up(pane, n = 1)
    if pane == :readme
      @readme_scroll = [@readme_scroll - n, 0].max
    else
      @scratch_scroll = [@scratch_scroll - n, 0].max
    end
  end

  private def scroll_pane_down(pane, n = 1)
    if pane == :readme
      @readme_scroll = [@readme_scroll + n, max_readme_scroll].min
    else
      @scratch_scroll = [@scratch_scroll + n, max_scratch_scroll].min
    end
  end

  private def scroll_to(y)
    if @focus == :readme
      @readme_scroll = y.clamp(0, max_readme_scroll)
    else
      @scratch_scroll = y.clamp(0, max_scratch_scroll)
    end
  end

  private def max_scroll = (@focus == :readme) ? max_readme_scroll : max_scratch_scroll
  private def max_readme_scroll = [@readme_line_count - @readme_page_height, 0].max
  private def max_scratch_scroll = [@scratch_line_count - @scratch_page_height, 0].max
  private def page_height = (@focus == :readme) ? @readme_page_height : @scratch_page_height

  private def reload_readme = @readme_content = File.read(README_PATH)
  private def reload_scratch = @scratch_content = File.read(@scratch.path)
end

AppExternalEditor.new.run if __FILE__ == $PROGRAM_NAME
