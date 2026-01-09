# frozen_string_literal: true

# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

target :lib do
  signature "sig"
  check "lib"

  # Legacy schema/ files pending migration - exclude from checking
  # Only schema/text.rb and schema/draw.rb are loaded by the main gem
  # See doc/contributors/v1.0.0_blockers.md
  ignore "lib/ratatui_ruby/schema/bar_chart.rb"
  ignore "lib/ratatui_ruby/schema/bar_chart/"
  ignore "lib/ratatui_ruby/schema/block.rb"
  ignore "lib/ratatui_ruby/schema/calendar.rb"
  ignore "lib/ratatui_ruby/schema/canvas.rb"
  ignore "lib/ratatui_ruby/schema/center.rb"
  ignore "lib/ratatui_ruby/schema/chart.rb"
  ignore "lib/ratatui_ruby/schema/clear.rb"
  ignore "lib/ratatui_ruby/schema/constraint.rb"
  ignore "lib/ratatui_ruby/schema/cursor.rb"
  ignore "lib/ratatui_ruby/schema/gauge.rb"
  ignore "lib/ratatui_ruby/schema/layout.rb"
  ignore "lib/ratatui_ruby/schema/line_gauge.rb"
  ignore "lib/ratatui_ruby/schema/list.rb"
  ignore "lib/ratatui_ruby/schema/list_item.rb"
  ignore "lib/ratatui_ruby/schema/overlay.rb"
  ignore "lib/ratatui_ruby/schema/paragraph.rb"
  ignore "lib/ratatui_ruby/schema/ratatui_logo.rb"
  ignore "lib/ratatui_ruby/schema/ratatui_mascot.rb"
  ignore "lib/ratatui_ruby/schema/rect.rb"
  ignore "lib/ratatui_ruby/schema/row.rb"
  ignore "lib/ratatui_ruby/schema/scrollbar.rb"
  ignore "lib/ratatui_ruby/schema/shape/"
  ignore "lib/ratatui_ruby/schema/sparkline.rb"
  ignore "lib/ratatui_ruby/schema/style.rb"
  ignore "lib/ratatui_ruby/schema/table.rb"
  ignore "lib/ratatui_ruby/schema/tabs.rb"

  # ClassMethods mixin pattern cannot be typed in RBS
  # (self in ClassMethods refers to the including Class)
  ignore "lib/ratatui_ruby/widgets/coerceable_widget.rb"

  library "pathname"
  library "fileutils"
  library "minitest"
  library "date"
end
