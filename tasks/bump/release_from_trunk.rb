# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

require_relative "bump_workflow"
require_relative "release_branch"

# ReleaseFromTrunk creates a release branch, releases there, syncs trunk, returns to release branch.
class ReleaseFromTrunk < BumpWorkflow
  private def prepare(segment)
    @branch = ReleaseBranch.for_version(target)

    puts "Creating release branch: #{@branch.name}"
    puts "Bumping #{segment}: #{@gem.version} -> #{target}"

    @repository.create_branch(@branch.name)
  end

  private def release_on_branch
    super
    puts "\nCommitted on #{@branch.name}."

    # Capture for trunk import
    @released_changelog_content = File.read("CHANGELOG.md")
  end

  private def finalize
    sync_trunk
    return_to_release_branch
  end

  private def sync_trunk
    @repository.checkout("trunk")
    trunk_changelog = Changelog.new
    trunk_changelog.import_release(target, @released_changelog_content)
    @gem.update_version(target)
    @repository.commit_all("chore: import v#{target} to trunk")
    puts "Committed on trunk."
  end

  private def return_to_release_branch
    @repository.checkout(@branch.name)
    puts "\nBack on #{@branch.name}. Review, push both branches, then: bundle exec rake release"
  end
end
