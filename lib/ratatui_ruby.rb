# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "ratatui_ruby/version"
require_relative "ratatui_ruby/output"

# The RatatuiRuby module acts as a namespace for the entire gem.
module RatatuiRuby
  # Raise this instead of a generic error to identify it as RatatuiRuby's error
  class Error < StandardError; end
end
