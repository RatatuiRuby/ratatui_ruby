# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module Autodoc
  class Rbs < Data.define(:path, :notice)
    def write(inventory)
      FileUtils.mkdir_p(File.dirname(path))

      # REUSE-IgnoreStart
      lines = [
        "# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>",
        "# SPDX-License-Identifier: AGPL-3.0-or-later",
        "",
      ]
      # REUSE-IgnoreEnd
      lines += notice.rbs
      lines += [
        "module RatatuiRuby",
        "  class Session",
        "    def self.new: () -> Session",
        "                | () { (Session) -> void } -> void",
        "",
      ]

      inventory.each do |member|
        lines << member.rbs
      end

      lines << "  end"
      lines << "end"

      File.write(path, "#{lines.join("\n")}\n")
      puts "Generated #{path}"
    end
  end
end
