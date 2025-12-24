# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

# Lockfiles need to be refreshed by a tool after Manifests are changed.
class CargoLockfile < Data.define(:path, :dir, :name)
  def exists?
    File.exist?(path)
  end

  def refresh
    return unless exists?

    Dir.chdir(dir) do
      system("cargo update -p #{name} --offline")
    end
  end
end
