# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "rake/extensiontask"

spec = Gem::Specification.load("ratatui_ruby.gemspec")
Rake::ExtensionTask.new("ratatui_ruby", spec) do |ext|
  ext.lib_dir = "lib/ratatui_ruby"
  ext.ext_dir = "ext/ratatui_ruby"
end
