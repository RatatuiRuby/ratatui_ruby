# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

require "pathname"
require_relative "source_file"

# All documentation files in the project.
#
# Projects contain many files. Only some are documentation: Ruby source with
# RDoc, Markdown guides, RDoc text files. Finding them manually is tedious.
# Missing files means missing broken links.
#
# Documentation enumerates all relevant files. It excludes vendor and temp
# directories. It wraps each path in a SourceFile for link extraction.
#
# === Example
#
#   docs = Documentation.new("/project/root")
#   docs.each do |file|
#     file.links.each { |link| puts link.raw }
#   end
#   docs.count  # => 392
#
class Documentation
  include Enumerable

  # File extensions to scan for links.
  EXTENSIONS = %w[rb md rdoc].freeze

  # Directories to skip.
  EXCLUDES = %w[/vendor/ /tmp/].freeze

  # Creates a new Documentation collection.
  #
  # [root] Project root directory to scan.
  def initialize(root)
    @root = Pathname.new(root)
  end

  # Yields each SourceFile in the project.
  def each(&)
    files.each(&)
  end

  private def files # :nodoc:
    @files ||= EXTENSIONS.flat_map { |ext| glob(ext) }
  end

  private def glob(extension) # :nodoc:
    Dir.glob(@root.join("**/*.#{extension}")).filter_map do |path|
      next if EXCLUDES.any? { |exclude| path.include?(exclude) }
      SourceFile.new(path, @root)
    end
  end
end
