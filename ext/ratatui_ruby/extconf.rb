# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "mkmf"

# We use Cargo to build the Rust extension, so we just create a dummy Makefile
# that Ruby's extension builder expects.
create_makefile("ratatui_ruby/ratatui_ruby")
