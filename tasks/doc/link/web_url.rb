# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

require "net/http"
require "uri"

require_relative "../problem"

# An HTTP or HTTPS URL in documentation.
#
# External links rot. Servers go offline. Pages move. A link that worked last
# year may 404 today. Manual verification is slow and error-prone.
#
# WebUrl checks reachability by making a HEAD request. It returns a Problem if
# the server responds with an error or is unreachable.
#
# === Example
#
#   link = WebUrl.new("https://example.com", 15, source_file)
#   link.web?           # => true
#   link.problem(root)  # => nil (site is up) or Problem (site is down)
#
class WebUrl < Link
  # Whether this link points to a web URL. Always <tt>true</tt> for WebUrl.
  def web?
    true
  end

  # Returns a Problem if the URL is unreachable. Returns <tt>nil</tt> if the
  # server responds with a 2xx or 3xx status.
  #
  # [_root] Unused. Present for interface compatibility.
  def problem(_root)
    Problem.new(self, "URL returned error or is unreachable") unless reachable?
  end

  private def reachable? # :nodoc:
    uri = URI.parse(raw)
    return false unless uri.is_a?(URI::HTTP) || uri.is_a?(URI::HTTPS)

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == "https"
    http.open_timeout = 5
    http.read_timeout = 5

    response = http.request_head(uri.request_uri)
    response.code.to_i < 400
  rescue
    false
  end
end
