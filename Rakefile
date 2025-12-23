# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "bundler/gem_tasks"

# Import all tasks from the tasks/ directory
Dir.glob("tasks/*.rake").each { |r| import r }

task default: %w[sourcehut test lint]
