# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "mkmf"
require "rb_sys/mkmf"

create_rust_makefile("ratatui_ruby/ratatui_ruby") do |r|
  # Optional: Force release profile if needed, but defaults are usually good
  # r.profile = ENV.fetch("RB_SYS_CARGO_PROFILE", :release).to_sym
end
