# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module Autodoc
  class Examples
    def self.sync
      new.sync
    end

    def sync
      Dir.glob("{README.md,doc/*.md,examples/*/README.md}").each do |readme_path|
        sync_readme(readme_path)
      end
    end

    private def sync_readme(readme_path)
      content = File.read(readme_path)
      dir = File.dirname(readme_path)

      new_content = content.gsub(/<!-- SYNC:START:([^ ]+) -->.*?<!-- SYNC:END -->/m) do
        marker_info = $1
        source_rel_path, segment_id = marker_info.split(":")
        source_path = File.join(dir, source_rel_path)

        unless File.exist?(source_path)
          warn "Warning: Source file not found: #{source_path}"
          next $&
        end

        source_content = File.read(source_path)
        extracted_content = if segment_id
          extract_segment(source_content, segment_id, source_path)
        else
          source_content
        end

        # Detect language from extension
        ext = File.extname(source_path).delete(".")
        lang = (ext == "rb") ? "ruby" : ext

        # Build replacement
        "<!-- SYNC:START:#{marker_info} -->\n```#{lang}\n#{extracted_content}```\n<!-- SYNC:END -->"
      end

      if new_content != content
        puts "Syncing #{readme_path}..."
        File.write(readme_path, new_content)
      end
    end

    def extract_segment(content, segment_id, source_path)
      start_marker = /#\s*\[SYNC:START:#{segment_id}\]/
      end_marker = /#\s*\[SYNC:END:#{segment_id}\]/

      lines = content.lines
      start_idx = lines.find_index { |l| l =~ start_marker }
      end_idx = lines.find_index { |l| l =~ end_marker }

      if start_idx && end_idx
        "#{unindent(lines[(start_idx + 1)...end_idx].join).strip}\n"
      else
        warn "Warning: Segment '#{segment_id}' not found in #{source_path}"
        content # Fallback to full content or error? Let's fallback to original for now.
      end
    end

    def unindent(text)
      lines = text.lines
      # Don't unindent if empty or just one line
      return text if lines.empty?

      # Find common leading whitespace
      indentation = lines.grep(/\S/).map { |l| l[/^\s*/].length }.min || 0
      lines.map { |l| (l.length > indentation) ? l[indentation..-1] : "#{l.strip}\n" }.join
    end
  end
end
