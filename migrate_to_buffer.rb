# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

# !/usr/bin/env ruby

# Migration script to refactor widget renderers from Frame to Buffer

require "fileutils"

WIDGETS_DIR = "/Users/kerrick/Developer/ratatui_ruby/ext/ratatui_ruby/src/widgets"

# Files to update (excluding block.rs which is already done)
WIDGET_FILES = %w[
  barchart.rs
  calendar.rs
  canvas.rs
  center.rs
  chart.rs
  clear.rs
  cursor.rs
  gauge.rs
  layout.rs
  line_gauge.rs
  list.rs
  overlay.rs
  paragraph.rs
  ratatui_logo.rs
  ratatui_mascot.rs
  scrollbar.rs
  sparkline.rs
  table.rs
  tabs.rs
].freeze

def migrate_file(filepath)
  puts "Migrating #{File.basename(filepath)}..."

  content = File.read(filepath)
  original_content = content.dup

  # 1. Update function signature
  content.gsub!("pub fn render(frame: &mut Frame,", "pub fn render(buffer: &mut Buffer,")
  content.gsub!("pub fn render_ratatui_mascot(frame: &mut Frame,", "pub fn render_ratatui_mascot(buffer: &mut Buffer,")

  # 2. Update imports - Add Buffer, remove Frame
  # Handle various import patterns
  content.gsub!(/use ratatui::\{([^}]*),\s*Frame\s*\};/, 'use ratatui::{\1};')
  content.gsub!(/use ratatui::\{Frame,\s*([^}]*)\};/, 'use ratatui::{\1};')
  content.gsub!("use ratatui::Frame;", "")

  # Add Buffer import if not present
  unless content.match?(/use ratatui::(?:\{[^}]*)?buffer::Buffer/)
    # Find the ratatui use statement and add buffer::Buffer
    content.gsub!("use ratatui::{", "use ratatui::{buffer::Buffer, ")
    content.gsub!("use ratatui::layout::Rect;", "use ratatui::{buffer::Buffer, layout::Rect};")
  end

  # 3. Update widget.render calls
  # frame.render_widget(widget, area) → widget.render(area, buffer)
  content.gsub!(/frame\.render_widget\(([^,]+),\s*([^)]+)\)/, '\1.render(\2, buffer)')

  # 4. Update direct buffer access
  content.gsub!("frame.buffer_mut()", "buffer")

  # 5. Update recursive render_node calls
  content.gsub!("render_node(frame,", "render_node(buffer,")

  # 5.5. Update stateful widget rendering
  # frame.render_stateful_widget(widget, area, state) → StatefulWidget::render(widget, area, buffer, state)
  content.gsub!(/frame\.render_stateful_widget\(([^,]+),\s*([^,]+),\s*([^)]+)\)/, 'StatefulWidget::render(\1, \2, buffer, \3)')

  # Add StatefulWidget import if stateful widgets are used
  if content.match?(/StatefulWidget::render/) && !content.match?(/use ratatui::widgets::StatefulWidget/) && content.match?(/use ratatui::/)
    content.sub!("use ratatui::{", "use ratatui::{widgets::StatefulWidget, ")
  end

  # 6. Clean up any double-added Buffer imports and duplicate Widget imports
  content.gsub!(/buffer::Buffer,\s*buffer::Buffer,/, "buffer::Buffer,")
  content.gsub!(/widgets::Widget,\s*widgets::Widget/, "widgets::Widget")
  content.gsub!(/(use ratatui::\{[^}]*widgets::Widget[^}]*),\s*widgets::Widget/, '\1')

  # 7. Fix Widget trait usage - make sure Widget is imported where .render is called
  # Add Widget to imports if calling .render on widgets
  if content.match?(/\.render\(area,\s*buffer\)/) && !content.match?(/use ratatui::widgets::Widget/) && content.match?(/use ratatui::\{/) && !content.match?(/widgets::Widget/)
    content.sub!("use ratatui::{", "use ratatui::{widgets::Widget, ")
  end

  # 8. For files that don't have proper Buffer imports yet, add them
  if !content.match?(/use ratatui::\{[^}]*buffer::Buffer/) && content.match?(/use ratatui::/)
    # Try to add to first ratatui import
    content.sub!("use ratatui::", "use ratatui::{buffer::Buffer};\nuse ratatui::")
  end

  # 9. Special case: cursor.rs uses frame.set_cursor_position which doesn't exist on Buffer
  # Cursor widget needs special handling - it can't work with just Buffer
  if File.basename(filepath) == "cursor.rs"
    puts "  ⚠ cursor.rs requires special handling - skipping set_cursor_position"
    # This widget can't be fully migrated as set_cursor_position is Frame-only
    # Will need manual fix or different approach
  end
  # Only write if content changed
  if content != original_content
    File.write(filepath, content)
    puts "  ✓ Updated #{File.basename(filepath)}"
    true
  else
    puts "  - No changes needed for #{File.basename(filepath)}"
    false
  end
end

def main
  puts "Starting widget renderer migration..."
  puts "=" * 60

  updated_count = 0

  WIDGET_FILES.each do |filename|
    filepath = File.join(WIDGETS_DIR, filename)

    unless File.exist?(filepath)
      puts "  ⚠ File not found: #{filename}"
      next
    end

    # Create backup
    backup_path = "#{filepath}.premigration"
    FileUtils.cp(filepath, backup_path) unless File.exist?(backup_path)

    updated_count += 1 if migrate_file(filepath)
  end

  puts "=" * 60
  puts "Migration complete!"
  puts "  Files updated: #{updated_count}/#{WIDGET_FILES.length}"
  puts "\nBackups saved with .premigration extension"
  puts "Run 'bundle exec rake compile' to verify the changes"
end

main if __FILE__ == $PROGRAM_NAME
