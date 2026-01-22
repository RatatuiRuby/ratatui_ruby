# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

require_relative "../problem"

# A <tt>file://</tt> URL in documentation.
#
# IDEs generate these links for local file access. They work on your machine.
# They break for everyone else. Published docs cannot contain local paths.
#
# FileUrl always returns a Problem. There is no valid use case for
# <tt>file://</tt> URLs in published documentation.
#
# === Example
#
#   link = FileUrl.new("file:///path/to/file.rb", 10, source_file)
#   link.problem(root)  # => Problem (always)
#
class FileUrl < Link
  # Returns a Problem. <tt>file://</tt> URLs never work in published docs.
  #
  # [_root] Unused. Present for interface compatibility.
  def problem(_root)
    Problem.new(self, "file:// URLs won't work when published")
  end
end
