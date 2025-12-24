# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RDocConfig
  RDOC_FILES = %w[
    **/*.md
    **/*.rdoc
    lib/**/*.rb
    exe/**/*
  ].freeze

  MAIN = "README.md"
end
