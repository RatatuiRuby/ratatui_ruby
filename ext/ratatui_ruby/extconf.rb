# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "mkmf"
require "rb_sys/mkmf"

create_rust_makefile("ratatui_ruby/ratatui_ruby") do |r|
  # Optional: Force release profile if needed
  # r.profile = ENV.fetch("RB_SYS_CARGO_PROFILE", :release).to_sym

  # Force static linking on musl to avoid "cdylib" issues
  if RbConfig::CONFIG["target_os"].include?("linux-musl") || RbConfig::CONFIG["host_os"].include?("linux-musl")
    r.extra_rustc_args = ["--crate-type", "staticlib"]
  else
    r.extra_rustc_args = ["--crate-type", "cdylib"]
  end
end
