# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

# Script to ensure Rust files have correct SPDX file headers.
#
# Usage: ruby tasks/license/headers_rs.rb [path...]
#
# If no paths are given, processes ext/.
#
# License selection by directory:
# - ext/ → LGPL-3.0-or-later

require_relative "license_utils"

YOUR_NAME = "Kerrick Long"
YOUR_EMAIL = "me@kerricklong.com"
YOUR_IDENTIFIERS = [YOUR_NAME, YOUR_EMAIL].freeze
YOUR_COPYRIGHT = "#{YOUR_NAME} <#{YOUR_EMAIL}>"

def license_for_file(filepath)
  case filepath
  when %r{^ext/}
    "LGPL-3.0-or-later"
  else
    "AGPL-3.0-or-later"
  end
end

def parse_existing_header(lines)
  # Rust files have // with no #-- or #++ wrappers

  copyrights = []
  license = nil
  header_end = nil

  lines.each_with_index do |line, i|
    if line =~ %r{^//\s*SPDX-FileCopyrightText:\s*(\d{4})\s+(.+)$}
      copyrights << { year: $1.to_i, holder: $2.strip }
    # REUSE-IgnoreStart
    elsif line =~ %r{^//\s*SPDX-License-Identifier:\s*(.+)$}
      # REUSE-IgnoreEnd
      license = $1.strip
      header_end = i
    elsif !line.start_with?("//") && line.strip.empty? && header_end
      # Blank line after header — we're done
      break
    elsif !line.start_with?("//") && !line.strip.empty?
      # Non-comment, non-blank line — header is over
      break
    end
  end

  return nil if copyrights.empty? && license.nil?

  { end_line: header_end || 0, copyrights:, license: }
end

def process_file(filepath)
  content = File.read(filepath)
  lines = content.lines

  target_license = license_for_file(filepath)

  # Get contributors from git for year lookups
  all_contributors = LicenseUtils.get_contributors_for_lines(filepath)
  your_year = LicenseUtils.get_your_latest_year(filepath, YOUR_IDENTIFIERS)

  existing = parse_existing_header(lines)

  if existing
    # File has existing header - only update years for EXISTING contributors
    needs_update = false
    updated_copyrights = []

    existing[:copyrights].each do |c|
      # Find this contributor's latest year from git
      git_year = nil
      all_contributors.each do |contributor, year|
        if c[:holder].split.any? { |word| contributor.include?(word) }
          git_year = [git_year || 0, year].max
        end
      end

      if git_year && git_year != c[:year]
        puts "  Updated #{c[:holder].split.first}'s copyright year: #{c[:year]} -> #{git_year}"
        updated_copyrights << { year: git_year, holder: c[:holder] }
        needs_update = true
      else
        updated_copyrights << c
      end
    end

    # Check if YOUR year needs updating (if you're a contributor)
    your_existing = updated_copyrights.find { |c| YOUR_IDENTIFIERS.any? { |id| c[:holder].include?(id) } }
    if your_existing.nil?
      puts "  Adding your copyright"
      updated_copyrights << { year: your_year, holder: YOUR_COPYRIGHT }
      needs_update = true
    end

    # Check license
    if existing[:license] != target_license
      puts "  Fixing license: #{existing[:license]} -> #{target_license}"
      needs_update = true
    end

    if needs_update
      header_lines = []

      # REUSE-IgnoreStart
      updated_copyrights.each do |c|
        header_lines << "// SPDX-FileCopyrightText: #{c[:year]} #{c[:holder]}\n"
      end
      header_lines << "// SPDX-License-Identifier: #{target_license}\n"
      # REUSE-IgnoreEnd

      content_start = existing[:end_line] + 1
      while content_start < lines.length && lines[content_start].strip.empty?
        content_start += 1
      end

      remaining = lines[content_start..]

      new_content = "#{header_lines.join}\n#{remaining.join}"

      File.write(filepath, new_content)
      puts "Updated: #{filepath}"
    end
  else
    # No header - add one with YOUR copyright only
    header = []
    # REUSE-IgnoreStart
    header << "// SPDX-FileCopyrightText: #{your_year} #{YOUR_COPYRIGHT}\n"
    header << "// SPDX-License-Identifier: #{target_license}\n"
    # REUSE-IgnoreEnd
    header << "\n"

    File.write(filepath, header.join + lines.join)
    puts "Added header: #{filepath}"
  end
end

def find_rs_files(paths)
  if paths.empty?
    dirs = %w[ext]
    files = dirs.flat_map do |dir|
      root_files = `git ls-files '#{dir}/*.rs' 2>/dev/null`.split("\n")
      sub_files = `git ls-files '#{dir}/**/*.rs' 2>/dev/null`.split("\n")
      root_files + sub_files
    end
    files.uniq
  else
    paths.flat_map do |path|
      if File.directory?(path)
        `git ls-files '#{path}/**/*.rs'`.split("\n")
      else
        path
      end
    end
  end
end

if __FILE__ == $0
  paths = ARGV.empty? ? [] : ARGV
  files = find_rs_files(paths)

  files.each do |file|
    process_file(file)
  end
end
