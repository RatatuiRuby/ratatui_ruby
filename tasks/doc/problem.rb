# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

# Represents a broken link.
#
# Link checking produces results. Some links are fine. Some are broken. You
# need to report the broken ones with context: where they were found and why
# they failed.
#
# Problem holds the link and the reason it failed. It delegates to the link
# for file, line, and raw text. Use it to build human-readable error reports.
#
# === Example
#
#   problem = Problem.new(link, "File not found: missing.md")
#   problem.file    # => "doc/guide.md"
#   problem.line    # => 42
#   problem.raw     # => "missing.md"
#   problem.reason  # => "File not found: missing.md"
#
class Problem < Data.define(:link, :reason)
  # Relative path to the file containing the broken link.
  def file
    link.source_file.relative_path
  end

  # Line number where the broken link appears.
  def line
    link.line
  end

  # The raw link text that failed validation.
  def raw
    link.raw
  end
end
