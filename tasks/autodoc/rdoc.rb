# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module Autodoc
  class Rdoc < Data.define(:path, :notice)
    def write(inventory)
      FileUtils.mkdir_p(File.dirname(path))

      # REUSE-IgnoreStart
      lines = [
        "# frozen_string_literal: true",
        "",
        "# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>",
        "# SPDX-License-Identifier: AGPL-3.0-or-later",
        "",
      ]
      # REUSE-IgnoreEnd
      lines += notice.rdoc
      lines += [
        "module RatatuiRuby",
        "  class Session",
      ]

      lines << "    # == RatatuiRuby Delegates"
      lines << "    #"
      inventory.delegates.each do |member|
        lines += member.rdoc
      end

      lines << "    # == Widget Factories"
      lines << "    #"
      inventory.factories.each do |member|
        lines += member.rdoc
      end

      lines << "  end"
      lines << "end"

      File.write(path, "#{lines.join("\n")}\n")
      puts "Generated #{path}"
    end
  end
end
