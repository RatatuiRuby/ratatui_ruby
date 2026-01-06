# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

# Script to ensure Ruby files have correct SPDX file headers (AGPL-3.0-or-later).
#
# Usage: ruby tasks/license/headers_rb.rb [path...]
#
# If no paths are given, processes all .rb files in lib/ via git ls-files.
#
# Rules:
# - Ensures file has AGPL-3.0-or-later license header with YOUR copyright
# - Updates years for EXISTING contributors based on git blame + Co-Authored-By
# - Does NOT add new contributors from git history - only updates existing ones
# - Adds header with YOUR copyright if missing

require_relative "license_utils"

YOUR_NAME = "Kerrick Long"
YOUR_EMAIL = "me@kerricklong.com"
YOUR_IDENTIFIERS = [YOUR_NAME, YOUR_EMAIL].freeze
YOUR_COPYRIGHT = "#{YOUR_NAME} <#{YOUR_EMAIL}>"
LICENSE = "AGPL-3.0-or-later"

def parse_existing_header(lines)
  # Returns { end_line:, copyrights: [{year:, holder:}], license: }
  # REUSE-IgnoreStart
  # Ruby files typically have:
  #   # frozen_string_literal: true
  #   (blank line)
  #   #--
  #   # SPDX-FileCopyrightText: YYYY Name
  #   # SPDX-License-Identifier: LICENSE
  #   #++
  # REUSE-IgnoreEnd

  copyrights = []
  license = nil
  header_end = nil
  found_spdx = false

  lines.each_with_index do |line, i|
    if line =~ /^#\s*SPDX-FileCopyrightText:\s*(\d{4})\s+(.+)$/
      copyrights << { year: $1.to_i, holder: $2.strip }
      found_spdx = true
    # REUSE-IgnoreStart
    elsif line =~ /^#\s*SPDX-License-Identifier:\s*(.+)$/
      # REUSE-IgnoreEnd
      license = $1.strip
      found_spdx = true
    elsif line =~ /^#\+\+\s*$/ && found_spdx
      header_end = i
      break
    end
  end

  return nil if copyrights.empty? && license.nil?

  { end_line: header_end || 0, copyrights:, license: }
end

def process_file(filepath)
  content = File.read(filepath)
  lines = content.lines

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
    if your_existing && your_existing[:year] != your_year
      # Already handled in the loop above
    elsif your_existing.nil?
      # You're not in the header yet - add you
      puts "  Adding your copyright"
      updated_copyrights << { year: your_year, holder: YOUR_COPYRIGHT }
      needs_update = true
    end

    # Check license
    if existing[:license] != LICENSE
      puts "  Fixing license: #{existing[:license]} -> #{LICENSE}"
      needs_update = true
    end

    if needs_update
      frozen_string = lines[0].include?("frozen_string_literal") ? lines[0] : nil

      header_lines = []
      header_lines << "# frozen_string_literal: true\n" unless frozen_string
      header_lines << "\n" if frozen_string.nil? && !lines[0].strip.empty?
      header_lines << "#--\n"

      # REUSE-IgnoreStart
      updated_copyrights.each do |c|
        header_lines << "# SPDX-FileCopyrightText: #{c[:year]} #{c[:holder]}\n"
      end
      header_lines << "# SPDX-License-Identifier: #{LICENSE}\n"
      # REUSE-IgnoreEnd
      header_lines << "#++\n"

      content_start = existing[:end_line] + 1
      while content_start < lines.length && lines[content_start].strip.empty?
        content_start += 1
      end

      remaining = lines[content_start..]

      if frozen_string
        new_content = "#{frozen_string}\n#{header_lines.join}\n#{remaining.join}"
      else
        new_content = "#{header_lines.join}\n#{remaining.join}"
      end

      File.write(filepath, new_content)
      puts "Updated: #{filepath}"
    end
  else
    # No header - add one with YOUR copyright only
    frozen_line = lines[0]&.include?("frozen_string_literal") ? lines.shift : nil

    header = []
    header << "# frozen_string_literal: true\n\n" unless frozen_line
    header << "#--\n"
    # REUSE-IgnoreStart
    header << "# SPDX-FileCopyrightText: #{your_year} #{YOUR_COPYRIGHT}\n"
    header << "# SPDX-License-Identifier: #{LICENSE}\n"
    # REUSE-IgnoreEnd
    header << "#++\n\n"

    if frozen_line
      File.write(filepath, "#{frozen_line}\n#{header.join}#{lines.join}")
    else
      File.write(filepath, header.join + lines.join)
    end
    puts "Added header: #{filepath}"
  end
end

def find_rb_files(paths)
  if paths.empty?
    `git ls-files 'lib/**/*.rb'`.split("\n")
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
