# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

require "open3"
require "json"
require "tmpdir"

# A completed GitHub Actions workflow run for a specific commit.
class CIRun < Data.define(:id)
  WORKFLOW_NAME = "Build Gems"

  # Finds the most recent successful run for the given commit SHA.
  def self.for_commit(sha)
    out, status = Open3.capture2(
      "gh", "run", "list",
      "--workflow", WORKFLOW_NAME,
      "--commit", sha,
      "--status", "completed",
      "--json", "databaseId,conclusion",
      "--limit", "1"
    )
    return nil unless status.success?

    runs = JSON.parse(out)
    run = runs.first
    return nil unless run
    return nil unless run.fetch("conclusion") == "success"

    new(id: run.fetch("databaseId"))
  end

  def download(dir)
    puts "Downloading native gem artifacts from run #{id}..."
    system("gh", "run", "download", id.to_s, "--dir", dir, exception: true)
    Dir.glob("#{dir}/**/*.gem")
  end
end
