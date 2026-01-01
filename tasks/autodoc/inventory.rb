# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require_relative "name"
require_relative "member"

module Autodoc
  class Inventory
    include Enumerable

    def each(&)
      delegates.each(&)
      factories.each(&)
    end

    def delegates
      RatatuiRuby.singleton_methods(false).sort.map do |method_name|
        Member::Delegate.new(name: method_name)
      end
    end

    def factories
      members = []
      RatatuiRuby.constants.sort.each do |const_name|
        next if const_name == :Buffer

        const = RatatuiRuby.const_get(const_name)
        next unless const.is_a?(Module)

        if const.is_a?(Class)
          snake_name = Name.new(const_name).snake
          members << Member::Factory.new(name: snake_name, const_name:)

          const.singleton_methods(false).sort.each do |class_method|
            members << Member::Helper.new(
              name: "#{snake_name}_#{class_method}",
              class_method:,
              const_name:
            )
          end
        end

        const.constants.sort.each do |child_name|
          child = const.const_get(child_name)
          next unless child.is_a?(Class)

          parent_prefix = Name.new(const_name).snake
          child_suffix = Name.new(child_name).snake

          members << Member::Factory.new(
            name: "#{parent_prefix}_#{child_suffix}",
            const_name: "#{const_name}::#{child_name}"
          )
        end
      end
      members
    end
  end
end
