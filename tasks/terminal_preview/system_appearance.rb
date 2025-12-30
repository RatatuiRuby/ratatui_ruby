# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

class SystemAppearance
  def self.dark?
    result = `osascript -e 'tell application "System Events" to tell appearance preferences to get dark mode'`.strip
    result == "true"
  end
end
