# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

# Script to add SPDX snippet headers to fenced code blocks in markdown files.
#
# Usage: ruby tasks/license/snippets_md.rb [path...]
#
# If no paths are given, processes all .md files via git ls-files.
#
# Rules:
# - Wraps all fenced code blocks (``` or ````) with SPDX snippet headers (MIT-0)
# - For SYNC:START/SYNC:END blocks, wraps AROUND the sync markers (not inside)
# - Uses git blame to determine the latest edit year for the code lines
# - Skips blocks that are already properly wrapped with MIT-0 and Kerrick Long
# - Removes malformed existing SPDX-Snippet blocks and replaces with correct ones

require "open3"
require "date"

COPYRIGHT_HOLDER = "Kerrick Long"
LICENSE = "MIT-0"

# Files to skip entirely (relative paths from repo root)
EXCLUDED_FILES = [
  "doc/contributors/v1.0.0_blockers.md",
  "doc/contributors/upstream_requests/tab_rects.md",
  "doc/contributors/upstream_requests/title_rects.md",
].freeze

def get_latest_git_year(file, start_line, end_line)
  cmd = %W[git blame -L #{start_line},#{end_line} --date=short -- #{file}]
  output, _status = Open3.capture2(*cmd)
  years = output.scan(/(\d{4})-\d{2}-\d{2}/).flatten.map(&:to_i)
  years.empty? ? Date.today.year : years.max
end

def is_our_snippet_header?(lines, idx)
  # Check if the current SPDX-SnippetBegin block already has our copyright/license
  i = idx + 1
  has_our_copyright = false
  has_mit0 = false

  while i < lines.length && !lines[i].include?("-->")
    line = lines[i]
    has_our_copyright = true if line.include?(COPYRIGHT_HOLDER) && line.include?("SPDX-FileCopyrightText")
    has_mit0 = true if line.include?("MIT-0") && line.include?("SPDX-License-Identifier")
    i += 1
  end

  has_our_copyright && has_mit0
end

def find_snippet_end(lines, start_idx)
  i = start_idx
  while i < lines.length
    return i if lines[i].include?("SPDX-SnippetEnd")
    i += 1
  end
  nil
end

def process_file(filepath)
  # Skip excluded files
  return if EXCLUDED_FILES.any? { |excluded| filepath.end_with?(excluded) }

  content = File.read(filepath)
  lines = content.lines

  # Track code block ranges (to exclude from file header year calculation)
  code_block_ranges = []
  changes = []
  removals = [] # existing malformed SPDX snippet blocks to remove
  i = 0

  while i < lines.length
    line = lines[i]

    # Check if we're at an existing SPDX-SnippetBegin
    if line.include?("SPDX-SnippetBegin")
      snippet_start = i
      snippet_end = find_snippet_end(lines, i)

      if snippet_end
        # Check if this is already our proper snippet
        if is_our_snippet_header?(lines, i)
          # Skip this block entirely - it's already correct
          i = snippet_end + 1
          next
        else
          # Mark for removal - we'll re-wrap the inner content
          removals << { start: snippet_start, end: snippet_end }
          i = snippet_end + 1
          next
        end
      end
    end

    # Check for SYNC:START pattern
    if line =~ /<!--\s*SYNC:START/
      sync_start_line = i
      j = i + 1
      code_start = nil
      code_end = nil
      sync_end_line = nil

      while j < lines.length
        if lines[j] =~ /^(````*)(\w*)$/
          if code_start.nil?
            code_start = j
          else
            code_end = j
          end
        elsif lines[j] =~ /<!--\s*SYNC:END/
          sync_end_line = j
          break
        end
        j += 1
      end

      if code_start && code_end && sync_end_line
        year = get_latest_git_year(filepath, code_start + 1, code_end + 1)
        changes << {
          type: :sync_block,
          start: sync_start_line,
          end: sync_end_line,
          year:,
        }
        code_block_ranges << (code_start..code_end)
        i = sync_end_line + 1
        next
      end
    end

    # Check for standalone fenced code block
    if line =~ /^(````*)(\w*)$/
      fence_marker = $1
      fence_start = i
      re_end = /^#{Regexp.escape(fence_marker)}$/

      j = i + 1
      fence_end = nil
      while j < lines.length
        if lines[j] =~ re_end
          fence_end = j
          break
        end
        j += 1
      end

      if fence_end
        year = get_latest_git_year(filepath, fence_start + 1, fence_end + 1)
        changes << {
          type: :code_block,
          start: fence_start,
          end: fence_end,
          year:,
        }
        code_block_ranges << (fence_start..fence_end)
        i = fence_end + 1
        next
      end
    end

    i += 1
  end

  # Handle removals and additions
  has_changes = !changes.empty? || !removals.empty?

  # Remove existing malformed SPDX blocks (in reverse order)
  removals.sort_by { |r| -r[:start] }.each do |removal|
    # Remove the SnippetEnd line
    lines.delete_at(removal[:end])
    # Remove lines from SnippetBegin through the --> closing the comment
    close_idx = removal[:start]
    while close_idx < lines.length && !lines[close_idx].include?("-->")
      close_idx += 1
    end
    # Remove from start to close_idx inclusive
    (close_idx - removal[:start] + 1).times { lines.delete_at(removal[:start]) }
  end

  # Recalculate content after removals
  content = lines.join
  lines = content.lines

  # Re-scan for code blocks that need wrapping
  changes = []
  i = 0

  while i < lines.length
    line = lines[i]

    # Skip if already inside an SPDX-SnippetBegin block
    if line.include?("SPDX-SnippetBegin")
      while i < lines.length && !lines[i].include?("SPDX-SnippetEnd")
        i += 1
      end
      i += 1
      next
    end

    # Check for SYNC:START pattern
    if line =~ /<!--\s*SYNC:START/
      sync_start_line = i
      j = i + 1
      code_start = nil
      code_end = nil
      sync_end_line = nil

      while j < lines.length
        if lines[j] =~ /^(````*)(\w*)$/
          if code_start.nil?
            code_start = j
          else
            code_end = j
          end
        elsif lines[j] =~ /<!--\s*SYNC:END/
          sync_end_line = j
          break
        end
        j += 1
      end

      if code_start && code_end && sync_end_line
        year = get_latest_git_year(filepath, code_start + 1, code_end + 1)
        changes << {
          type: :sync_block,
          start: sync_start_line,
          end: sync_end_line,
          year:,
        }
        i = sync_end_line + 1
        next
      end
    end

    # Check for standalone fenced code block
    if line =~ /^(````*)(\w*)$/
      fence_marker = $1
      fence_start = i
      re_end = /^#{Regexp.escape(fence_marker)}$/

      j = i + 1
      fence_end = nil
      while j < lines.length
        if lines[j] =~ re_end
          fence_end = j
          break
        end
        j += 1
      end

      if fence_end
        year = get_latest_git_year(filepath, fence_start + 1, fence_end + 1)
        changes << {
          type: :code_block,
          start: fence_start,
          end: fence_end,
          year:,
        }
        i = fence_end + 1
        next
      end
    end

    i += 1
  end

  return if changes.empty? && !has_changes

  # Apply changes in reverse order to preserve line numbers
  changes.sort_by { |c| -c[:start] }.each do |change|
    # REUSE-IgnoreStart
    snippet_begin = "<!-- SPDX-SnippetBegin -->\n<!--\n  SPDX-FileCopyrightText: #{change[:year]} #{COPYRIGHT_HOLDER}\n  SPDX-License-Identifier: #{LICENSE}\n-->\n"
    snippet_end = "<!-- SPDX-SnippetEnd -->\n"
    # REUSE-IgnoreEnd

    # Insert end marker after the block
    lines.insert(change[:end] + 1, snippet_end)
    # Insert begin marker before the block
    lines.insert(change[:start], snippet_begin)
  end

  File.write(filepath, lines.join)
  puts "Updated: #{filepath} (#{changes.length} code block(s))"
end

def find_md_files(paths)
  # Use git ls-files to respect .gitignore
  if paths.empty?
    `git ls-files '*.md'`.split("\n")
  else
    paths.flat_map do |path|
      if File.directory?(path)
        `git ls-files '#{path}/**/*.md'`.split("\n")
      else
        path
      end
    end
  end
end

if __FILE__ == $0
  paths = ARGV.empty? ? [] : ARGV
  files = find_md_files(paths)

  files.each do |file|
    process_file(file)
  end
end
