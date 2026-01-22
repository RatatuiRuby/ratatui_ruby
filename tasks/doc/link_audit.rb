# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

require_relative "documentation"

# Results of auditing documentation for broken links.
#
# Documentation breaks silently. Links rot. Files move. Paths change. Manual
# checking is tedious and error-prone. Automated checking catches problems
# before users do.
#
# LinkAudit scans all documentation, checks each link, and collects problems.
# It separates web URLs (slow to verify) from local paths (fast to check).
# The results render as a human-readable report via <tt>to_s</tt>.
#
# === Example
#
#   audit = LinkAudit.new("/project/root", verify_web: false)
#   puts audit           # prints the full report
#   exit 1 unless audit.success?
#
class LinkAudit
  # Problems found during the audit.
  attr_reader :problems

  # Web URLs that were not verified (when <tt>verify_web: false</tt>).
  attr_reader :unverified

  # Creates a new LinkAudit and runs the scan immediately.
  #
  # [root] Project root directory to scan.
  # [verify_web] Whether to make HTTP requests to verify web URLs.
  def initialize(root, verify_web: false)
    @root = root
    @docs = Documentation.new(root)
    @verify_web = verify_web
    @problems = []
    @unverified = []
    @checked = 0
    @web_checked = 0
    scan
  end

  # Whether the audit passed with no problems.
  def success?
    @problems.empty?
  end

  # Returns the audit report as a String.
  def to_s
    lines = []
    lines << ""
    lines << "Scanning for broken links in #{@root}..."
    lines << ""

    if @verify_web
      lines << "Checked #{@checked} links in #{@docs.count} files (#{@web_checked} web URLs probed)."
    else
      lines << "Checked #{@checked} links in #{@docs.count} files (URL verification skipped)."
    end
    lines << ""

    unless @unverified.empty?
      lines << "📋 Unverified HTTP/HTTPS URLs (#{@unverified.size}):"
      lines << ""
      @unverified.uniq(&:raw).each { |link| lines << "  #{link.raw}" }
      lines << ""
    end

    if @problems.empty?
      lines << "✅ No broken links found!"
    else
      lines << "❌ Found #{@problems.size} broken link(s):"
      lines << ""

      @problems.group_by(&:file).each do |path, problems|
        lines << "#{path}:"
        problems.each do |problem|
          lines << "  L#{problem.line || '?'}: #{problem.raw}"
          lines << "       → #{problem.reason}"
        end
        lines << ""
      end
    end

    lines.join("\n")
  end

  private def scan # :nodoc:
    @docs.each do |file|
      file.links.each do |link|
        @checked += 1
        check(link)
      end
    end
  end

  private def check(link) # :nodoc:
    if link.web?
      if @verify_web
        @web_checked += 1
        problem = link.problem(@root)
        @problems << problem if problem
      else
        @unverified << link
      end
    else
      problem = link.problem(@root)
      @problems << problem if problem
    end
  end
end
