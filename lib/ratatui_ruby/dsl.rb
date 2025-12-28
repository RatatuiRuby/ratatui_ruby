# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  ##
  # A wrapper class that provides a concise DSL for creating widgets and interacting
  # with the terminal within the +main_loop+.
  #
  # This class is yielded to the block provided to {RatatuiRuby.main_loop}.
  # It uses metaprogramming to delegate method calls to {RatatuiRuby} module functions
  # and to act as a factory for {RatatuiRuby} widget classes.
  #
  # == Features
  #
  # 1. **Widget Shorthand**: Provides factory methods for every widget class.
  #    Converts snake_case method calls (e.g., +paragraph+) into CamelCase class instantiations
  #    (e.g., +RatatuiRuby::Paragraph.new+).
  #
  # 2. **Method Shorthand**: Aliases module functions of {RatatuiRuby}, allowing you
  #    to call methods like +draw+ and +poll_event+ directly on the DSL object.
  #
  # == Example
  #
  #   RatatuiRuby.main_loop do |tui|
  #     # Create UI using shorthand methods
  #     view = tui.paragraph(
  #       text: "Hello World",
  #       block: tui.block(borders: [:all])
  #     )
  #
  #     # Use module aliases to draw and handle events
  #     tui.draw(view)
  #     event = tui.poll_event
  #
  #     break if event && event[:code] == "q"
  #   end
  class DSL
    # Wrap methods directly
    RatatuiRuby.singleton_methods(false).each do |method_name|
      define_method(method_name) do |*args, **kwargs, &block|
        RatatuiRuby.public_send(method_name, *args, **kwargs, &block)
      end
    end

    # Wrap classes as snake_case factories
    RatatuiRuby.constants.each do |const_name|
      next if const_name == :Buffer

      klass = RatatuiRuby.const_get(const_name)
      next unless klass.is_a?(Class)

      method_name = const_name.to_s
                              .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
                              .gsub(/([a-z\d])([A-Z])/, '\1_\2')
                              .downcase

      define_method(method_name) do |*args, **kwargs, &block|
        klass.new(*args, **kwargs, &block)
      end
    end
  end
end