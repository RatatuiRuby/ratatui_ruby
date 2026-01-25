# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

# ReleaseBranch represents a release/X.Y branch for a version series.
class ReleaseBranch < Data.define(:major, :minor)
  def self.for_version(semver)
    new(semver.major, semver.minor)
  end

  def name
    "release/#{major}.#{minor}"
  end
end
