# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

class ExampleApp < Data.define(:directory)
  def self.all
    examples_dir = File.expand_path("../../examples", __dir__)
    Dir.glob("#{examples_dir}/*/app.rb").map do |path|
      new(File.basename(File.dirname(path)))
    end.sort_by(&:directory)
  end

  def app_path
    "examples/#{directory}/app.rb"
  end

  def screenshot_filename
    "#{directory}.png"
  end

  def to_s
    directory
  end
end
