# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

require "ratatui_ruby"

# Fail fast if accidentally running in bundled environment
if ENV["BUNDLE_GEMFILE"] || ENV["BUNDLER_VERSION"]
  abort "ERROR: Smoke test must run outside bundler to verify gem packaging"
end

FRAMES = 18 # ~300ms at 60fps (16ms per frame)

# 1. Inline viewport
RatatuiRuby.run(viewport: :inline, height: 1) do |tui|
  FRAMES.times do
    tui.draw { |f| f.render_widget(tui.paragraph(text: "1/3 Inline"), f.area) }
    abort "Canceled." if tui.poll_event.ctrl_c?
  end
end
puts

# 2. Fullscreen viewport with block and centered mascot
RatatuiRuby.run(viewport: :fullscreen) do |tui|
  block = tui.block(borders: [:all], border_style: { fg: :cyan }, title: "Smoke Test")
  mascot = tui.ratatui_mascot
  centered = tui.center(child: mascot, width_percent: 50, height_percent: 80)
  text = tui.paragraph(text: "2/3 Fullscreen", alignment: :center)
  FRAMES.times do
    tui.draw do |f|
      f.render_widget(block, f.area)
      top, bottom = tui.layout_split(block.inner(f.area), constraints: [
        tui.constraint_length(1),
        tui.constraint_fill(1),
      ])
      f.render_widget(centered, bottom)
      f.render_widget(text, top)
    end
    abort "Canceled." if tui.poll_event.ctrl_c?
  end
end

# 3. Inline viewport with scrollback insertion
RatatuiRuby.run(viewport: :inline, height: 1) do |tui|
  FRAMES.times do |i|
    tui.draw { |f| f.render_widget(tui.paragraph(text: "3/3 Scrollback"), f.area) }
    # Insert a line into scrollback midway through
    tui.insert_before(1, tui.paragraph(text: "Inserted line at frame #{i}")) if (i % 6).zero?
    abort "Canceled." if tui.poll_event.ctrl_c?
  end
  area = tui.viewport_area
  RatatuiRuby.cursor_position = [0, area.y + area.height]
end
puts
puts "OK"
