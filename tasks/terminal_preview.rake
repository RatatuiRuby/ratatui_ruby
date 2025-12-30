# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "terminal_preview/preview_collection"

namespace :terminal_preview do
  desc "Generate native PNG screenshots using Terminal.app"
  task generate: :compile do
    img_dir = File.expand_path("../doc/images", __dir__)
    FileUtils.mkdir_p(img_dir)

    collection = PreviewCollection.new(img_dir)
    collection.generate
  end
end
