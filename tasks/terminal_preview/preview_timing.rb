# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

class PreviewTiming
  def self.window_startup
    1.5
  end

  def self.between_captures
    0.2
  end

  def self.close_delay
    1.0
  end

  def self.total
    window_startup + close_delay + between_captures
  end
end
