# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

# Script to add SPDX snippet headers to RDoc code examples in Ruby files.
#
# Usage: ruby scripts/add_spdx_rdoc_snippets.rb [path...]
#
# If no paths are given, processes all .rb files via git ls-files.
#
# Rules:
# - Wraps RDoc code examples (indented comment lines) with SPDX snippet headers
# - Uses #-- and #++ to hide the SPDX headers from RDoc rendering
# - Uses git blame to determine the latest edit year for the code lines
# - Skips blocks that are already wrapped with SPDX-SnippetBegin

require "open3"
require "date"

COPYRIGHT_HOLDER = "Kerrick Long"
LICENSE = "MIT-0"

def get_latest_git_year(file, start_line, end_line)
  cmd = %W[git blame -L #{start_line},#{end_line} --date=short -- #{file}]
  output, _status = Open3.capture2(*cmd)
  years = output.scan(/(\d{4})-\d{2}-\d{2}/).flatten.map(&:to_i)
  years.empty? ? Date.today.year : years.max
end

def find_rdoc_code_blocks(lines)
  # Find all RDoc code blocks (indented comment lines)
  # Returns array of {start:, end:, indent:} where indent is the comment prefix
  blocks = []
  i = 0

  while i < lines.length
    line = lines[i]

    # Check if this is an indented code line in a comment
    # Pattern: optional leading whitespace, #, then 3+ spaces (RDoc code indent)
    if line =~ /^(\s*)#(   +)(\S.*)$/
      prefix = $1 # leading whitespace before #
      block_start = i

      # Find the extent of this code block
      j = i
      while j < lines.length
        current = lines[j]
        # Code block continues if line is indented code OR empty comment line
        if current =~ /^#{Regexp.escape(prefix)}#(   +|\s*$)/
          j += 1
        else
          break
        end
      end

      block_end = j - 1

      # Only count as a block if it has actual code (not just empty lines)
      has_code = (block_start..block_end).any? { |k| lines[k] =~ /^#{Regexp.escape(prefix)}#   +\S/ }

      if has_code && block_end > block_start
        blocks << { start: block_start, end: block_end, prefix: }
      end

      i = j
    else
      i += 1
    end
  end

  blocks
end

def is_already_wrapped?(lines, block_start, prefix)
  # Check if the line before the block is #++ (meaning it's already wrapped)
  return false if block_start < 1

  prev_line = lines[block_start - 1]
  prev_line =~ /^#{Regexp.escape(prefix)}#\+\+\s*$/
end

def process_file(filepath)
  content = File.read(filepath)
  lines = content.lines

  blocks = find_rdoc_code_blocks(lines)

  # Filter out already-wrapped blocks
  blocks.reject! { |b| is_already_wrapped?(lines, b[:start], b[:prefix]) }

  return if blocks.empty?

  # Apply changes in reverse order to preserve line numbers
  blocks.sort_by { |b| -b[:start] }.each do |block|
    year = get_latest_git_year(filepath, block[:start] + 1, block[:end] + 1)
    prefix = block[:prefix]

    # Build the wrapper lines
    # REUSE-IgnoreStart
    begin_wrapper = [
      "#{prefix}#--\n",
      "#{prefix}# SPDX-SnippetBegin\n",
      "#{prefix}# SPDX-FileCopyrightText: #{year} #{COPYRIGHT_HOLDER}\n",
      "#{prefix}# SPDX-License-Identifier: #{LICENSE}\n",
      "#{prefix}#++\n",
    ]

    end_wrapper = [
      "#{prefix}#--\n",
      "#{prefix}# SPDX-SnippetEnd\n",
      "#{prefix}#++\n",
    ]
    # REUSE-IgnoreEnd

    # Insert end wrapper after the block
    lines.insert(block[:end] + 1, *end_wrapper)
    # Insert begin wrapper before the block
    lines.insert(block[:start], *begin_wrapper)
  end

  File.write(filepath, lines.join)
  puts "Updated: #{filepath} (#{blocks.length} code block(s))"
end

def find_rb_files(paths)
  if paths.empty?
    `git ls-files '*.rb'`.split("\n")
  else
    paths.flat_map do |path|
      if File.directory?(path)
        `git ls-files '#{path}/**/*.rb'`.split("\n")
      else
        path
      end
    end
  end
end

if __FILE__ == $0
  paths = ARGV.empty? ? [] : ARGV
  files = find_rb_files(paths)

  files.each do |file|
    process_file(file)
  end
end
