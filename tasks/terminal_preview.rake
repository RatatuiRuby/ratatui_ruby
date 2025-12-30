# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "fileutils"
require_relative "terminal_preview/preview_collection"
require_relative "terminal_preview/example_app"

namespace :terminal_preview do
  desc "Generate native PNG screenshots using Terminal.app"
  task :generate do
    img_dir = File.expand_path("../doc/images", __dir__)
    FileUtils.mkdir_p(img_dir)

    # Create empty placeholder files for any missing images that compile depends on.
    # This prevents Rake from trying to build them as dependencies.
    ExampleApp.all.each do |app|
      image_path = File.join(img_dir, "#{app}.png")
      FileUtils.touch(image_path) unless File.exist?(image_path)
    end

    Rake::Task["compile"].invoke

    collection = PreviewCollection.new(img_dir)
    collection.generate
  end
end
