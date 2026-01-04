# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RDocConfig
  MAX_FILE_SIZE = 100_000 # 100KB - skip large files like chat logs

  RDOC_FILES = Dir.glob(%w[
    doc/**/*.md
    examples/**/*.md
    *.md
    *.rdoc
    lib/**/*.rb
    exe/**/*
  ]).reject { |f|
    # Skip large files
    if File.size(f) > MAX_FILE_SIZE
      warn "RDoc: skipping #{f} (#{File.size(f) / 1024}KB > #{MAX_FILE_SIZE / 1024}KB limit)"
      next true
    end
    # Skip verification examples (internal testing, not user-facing)
    f.start_with?("examples/verify_")
  }.freeze

  MAIN = "README.md"
end
