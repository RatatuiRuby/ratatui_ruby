# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

require_relative "bump_workflow"

# PatchRelease performs a patch release on the current release branch.
class PatchRelease < BumpWorkflow
  private def prepare(segment)
    puts "Bumping #{segment}: #{@gem.version} -> #{target}"
  end

  private def finalize
    puts "\nCommitted. Push and run: bundle exec rake release"
  end
end
