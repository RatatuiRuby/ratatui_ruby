# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

require "pathname"

require_relative "../problem"

# A relative path to a local file.
#
# Documentation references sibling files: images, other docs, source code.
# Files get renamed. Directories restructure. These paths silently break.
#
# RelativePath resolves the path against the project root and checks if the
# target exists. It also handles RDoc's HTML naming convention (converting
# <tt>foo_rb.html</tt> back to <tt>foo.rb</tt> for validation).
#
# === Example
#
#   link = RelativePath.new("../images/diagram.png", 20, source_file)
#   link.problem(root)  # => nil (file exists) or Problem (missing)
#
class RelativePath < Link
  # Returns a Problem if the target file does not exist. Returns <tt>nil</tt>
  # if the path resolves to an existing file or directory.
  #
  # [root] Project root directory for resolving absolute paths.
  def problem(root)
    root = Pathname.new(root)
    resolved = resolve(root)
    return nil unless resolved

    Problem.new(self, "File not found: #{resolved.relative_path_from(root)}") unless exists?(resolved)
  end

  private def exists?(resolved) # :nodoc:
    return true if resolved.exist?

    # RDoc generates foo_rb.html from foo.rb
    if raw.end_with?("_rb.html")
      source = Pathname.new(resolved.to_s.sub(/_rb\.html$/, ".rb"))
      return true if source.exist?
    end

    resolved.directory? if raw.end_with?("/")
  end

  private def resolve(root) # :nodoc:
    path = raw.split("#").first&.split("?")&.first
    return nil if path.nil? || path.empty? || path.length < 4

    if path.start_with?("/")
      root.join(path.delete_prefix("/"))
    else
      source_file.path.dirname.join(path)
    end
  end
end
