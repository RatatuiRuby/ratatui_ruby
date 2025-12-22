# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # Reusable style object
  # [fg] the foreground color.
  # [bg] the background color.
  # [modifiers] modifiers: [:bold, :italic, :dim, etc.]
  Style = Data.define(:fg, :bg, :modifiers) do
    # Creates a new Style.
    # [fg] the foreground color.
    # [bg] the background color.
    # [modifiers] the modifiers to apply.
    def initialize(fg: nil, bg: nil, modifiers: [])
      super
    end

    # Returns a default style.
    def self.default
      new
    end
  end
end
