# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

require_relative "repository"
require_relative "changelog"

# Base class for version bump workflows.
# Subclasses implement the template methods: prepare, release_on_branch, finalize.
class BumpWorkflow
  def initialize(gem:, repository: Repository.new)
    @gem = gem
    @repository = repository
  end

  def call(segment)
    @repository.assert_can_bump!(segment)
    @target = @gem.version.next(segment)

    prepare(segment)
    release_on_branch
    finalize
  end

  attr_reader :target

  private def release_on_branch
    changelog = Changelog.new
    @commit_message = changelog.commit_message(target)
    changelog.release(target)
    @gem.update_version(target)
    @repository.commit_all(@commit_message)
  end

  # Template methods for subclasses
  private def prepare(segment) = nil
  private def finalize = nil
end
