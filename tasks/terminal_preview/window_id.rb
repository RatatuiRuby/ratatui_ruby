# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

class WindowID < Data.define(:value)
  def valid?
    !value.empty? && value.match?(/^\d+$/)
  end

  def to_s
    value
  end
end
