# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

require "pathname"
require_relative "link"

# A file that may contain links.
#
# Documentation lives in many files: Ruby source with RDoc comments, Markdown
# guides, RDoc text files. Each file may reference images, other docs, or
# external URLs. Extracting these links by hand is tedious.
#
# SourceFile scans its content with regex patterns. It creates the appropriate
# Link subclass for each match. It tracks line numbers for error reporting.
#
# === Example
#
#   file = SourceFile.new("/path/to/guide.md", "/project/root")
#   file.links.each do |link|
#     puts "#{link.raw} at line #{link.line}"
#   end
#
class SourceFile
  # Regex patterns for extracting links from documentation.
  PATTERNS = {
    rdoc_image_link: /\{rdoc-image:([^}]+)\}\[link:([^\]]+)\]/,
    rdoc_link: /\{[^}]*\}\[link:([^\]]+)\]/,
    rdoc_image: /\{rdoc-image:([^}]+)\}/,
    markdown_link: /\[(?:[^\]]*)\]\((?!mailto:|#)([^)\s]+)\)/,
    markdown_image: /!\[[^\]]*\]\(([^)\s]+)\)/,
    html_src: /src=["']([^"']+)["']/,
    html_href: /href=["'](?!mailto:|#)([^"']+)["']/,
  }.freeze

  # The Pathname to this file.
  attr_reader :path

  # Creates a new SourceFile.
  #
  # [path] Path to the file (String or Pathname).
  # [root] Project root directory for computing relative paths.
  def initialize(path, root)
    @path = Pathname.new(path)
    @root = Pathname.new(root)
  end

  # Extracts all links from the file content. Returns an Array of Link objects.
  def links
    found = []

    PATTERNS.each_value do |pattern|
      content.scan(pattern) do |matches|
        matches = [matches] unless matches.is_a?(Array)
        matches.each do |match|
          next if match.nil? || match.empty?
          next unless looks_like_link?(match)
          found << Link.build(match, line_for(match), self)
        end
      end
    end

    found
  end

  # The file path relative to the project root.
  def relative_path
    @path.relative_path_from(@root).to_s
  end

  private def content # :nodoc:
    @content ||= @path.read(mode: "rb").force_encoding("UTF-8").scrub("")
  end

  private def line_for(link_text) # :nodoc:
    line_num = 1
    content.each_line do |line|
      return line_num if line.include?(link_text)
      line_num += 1
    end
    nil
  end

  private def looks_like_link?(text) # :nodoc:
    # Skip regex patterns and other false positives
    return false if text.match?(/[\[\]^*+?]/) # Contains regex special chars
    return false if text.length < 4
    true
  end
end
