# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

# Script to ensure Ruby files have correct SPDX file headers.
#
# Usage: ruby tasks/license/headers_rb.rb [path...]
#
# If no paths are given, processes lib/, ext/, test/, examples/, tasks/, bin/.
#
# License selection by directory:
# - lib/, ext/, test/ → LGPL-3.0-or-later
# - examples/widget_*, examples/verify_* → MIT-0
# - examples/app_*, tasks/, bin/ → AGPL-3.0-or-later

require_relative "license_utils"

YOUR_NAME = "Kerrick Long"
YOUR_EMAIL = "me@kerricklong.com"
YOUR_IDENTIFIERS = [YOUR_NAME, YOUR_EMAIL].freeze
YOUR_COPYRIGHT = "#{YOUR_NAME} <#{YOUR_EMAIL}>"

def license_for_file(filepath)
  case filepath
  when %r{^(lib|sig/ratatui_ruby|ext|test)/}
    "LGPL-3.0-or-later"
  when %r{^(examples|sig/examples)/(widget_|verify_)}
    "MIT-0"
  else
    "AGPL-3.0-or-later"
  end
end

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
      frozen_string = lines[0].include?("frozen_string_literal") ? lines[0] : nil

      header_lines = []
      header_lines << "# frozen_string_literal: true\n" unless frozen_string
      header_lines << "\n" if frozen_string.nil? && !lines[0].strip.empty?
      header_lines << "#--\n"

      # REUSE-IgnoreStart
      updated_copyrights.each do |c|
        header_lines << "# SPDX-FileCopyrightText: #{c[:year]} #{c[:holder]}\n"
      end
      header_lines << "# SPDX-License-Identifier: #{target_license}\n"
      # REUSE-IgnoreEnd
      header_lines << "#++\n"

      content_start = existing[:end_line] + 1
      while content_start < lines.length && lines[content_start].strip.empty?
        content_start += 1
      end

      remaining = lines[content_start..]

      new_content = if frozen_string
        "#{frozen_string}\n#{header_lines.join}\n#{remaining.join}"
      else
        "#{header_lines.join}\n#{remaining.join}"
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
    header << "# SPDX-License-Identifier: #{target_license}\n"
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
    # Process all relevant directories
    dirs = %w[lib ext test examples tasks bin sig]
    files = dirs.flat_map do |dir|
      # Include both root files and subdirectory files, for both .rb and .rbs
      %w[rb rbs].flat_map do |ext|
        root_files = `git ls-files '#{dir}/*.#{ext}' 2>/dev/null`.split("\n")
        sub_files = `git ls-files '#{dir}/**/*.#{ext}' 2>/dev/null`.split("\n")
        root_files + sub_files
      end
    end
    files.uniq
  else
    paths.flat_map do |path|
      if File.directory?(path)
        rb_files = `git ls-files '#{path}/**/*.rb'`.split("\n")
        rbs_files = `git ls-files '#{path}/**/*.rbs'`.split("\n")
        rb_files + rbs_files
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
