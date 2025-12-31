# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

class CrashReport < Data.define(:app, :error, :preamble)
  def self.new(app, error, preamble = nil)
    # Allow preamble to be optional while Data.define requires all fields
    super(app:, error:, preamble:)
  end

  def to_s
    output = error.message.strip
    formatted_error = output.split("\n").map { |line| format_line(line) }.join("\n")
    preamble_section = preamble ? <<~PREAMBLE.chomp : ""
      #{box_top}
      #{format_line(preamble)}
      #{box_bottom}
    PREAMBLE

    <<~TEXT
      #{preamble_section}
      #{border_top(app.to_s)}
      #{formatted_error}
      #{box_bottom}
    TEXT
  end

  private def box_top
    "┌#{'─' * (width - 2)}┐"
  end

  private def box_bottom
    "└#{'─' * (width - 2)}┘"
  end

  private def border_top(title)
    left = "┌─ #{title} "
    right = "┐"
    dashes = "─" * (width - left.length - right.length)
    left + dashes + right
  end

  private def format_line(line)
    truncated = line[0...(width - 4)]
    "│ #{truncated.ljust(width - 4)} │"
  end

  private def width
    80
  end
end
