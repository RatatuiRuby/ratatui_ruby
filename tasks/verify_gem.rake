# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
#
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

desc "Verify the built gem can be installed and run"
task :verify_gem do
  gem_file = Dir["pkg/*.gem"].max_by { |f| File.mtime(f) }
  abort "No .gem file found in pkg/. Run `rake build` first." unless gem_file

  sh "gem install --local #{gem_file} --no-document"
  Bundler.with_unbundled_env do
    sh "ruby examples/verify_smoke_test/app.rb"
  end
  # Cleanup - ignore errors since gem may be installed elsewhere by bundler
  system "gem uninstall ratatui_ruby --all -x 2>/dev/null"
end
