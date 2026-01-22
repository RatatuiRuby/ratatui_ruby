# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

# Base class for links found in documentation.
#
# Documentation contains links: URLs, file paths, images. These links break.
# Pages move. Files get renamed. Servers go offline. Manual checking is tedious.
#
# Link is the base type. It holds the raw text, line number, and source file.
# Subclasses (FileUrl, WebUrl, RelativePath) implement <tt>problem</tt> to
# detect specific breakage.
#
# Use <tt>Link.build</tt> to create the correct subclass based on the raw text.
#
# === Example
#
#   link = Link.build("https://example.com", 42, source_file)
#   link.web?      # => true
#   link.problem(root)  # => nil or Problem
#
class Link < Data.define(:raw, :line, :source_file)
  # Creates the appropriate Link subclass based on the raw text.
  #
  # [raw] The raw link text extracted from the file.
  # [line] Line number where the link appears.
  # [source_file] The SourceFile containing this link.
  def self.build(raw, line, source_file)
    if raw.start_with?("file://")
      FileUrl.new(raw, line, source_file)
    elsif raw.start_with?("https://", "http://")
      WebUrl.new(raw, line, source_file)
    else
      RelativePath.new(raw, line, source_file)
    end
  end

  # Whether this link points to a web URL.
  #
  # WebUrl overrides this to return <tt>true</tt>. Other link types return
  # <tt>false</tt>. The audit uses this to decide whether to skip verification.
  def web?
    false
  end
end

require_relative "link/file_url"
require_relative "link/web_url"
require_relative "link/relative_path"
