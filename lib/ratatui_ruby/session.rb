# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module RatatuiRuby
  # Manages the terminal lifecycle and provides a concise API for the render loop.
  #
  # Writing a TUI loop involves repetitive boilerplate. You constantly instantiate widgets (<tt>RatatuiRuby::Paragraph.new</tt>) and call global methods (<tt>RatatuiRuby.draw</tt>). This is verbose and hard to read.
  #
  # The Session object simplifies this. It acts as a factory and a facade. It provides short helper methods for every widget and delegates core commands to the main module.
  #
  # Use it within <tt>RatatuiRuby.run</tt> to build your interface cleanly.
  #
  # == Available Methods
  #
  # The session dynamically defines factory methods for all RatatuiRuby constants.
  #
  # *   <tt>draw(node)</tt> -> Delegates to <tt>RatatuiRuby.draw</tt>
  # *   <tt>poll_event</tt> -> Delegates to <tt>RatatuiRuby.poll_event</tt>
  #
  # === Widget Factories
  #
  # The session acts as a dynamic factory. It creates a helper method for **every** class defined in the `RatatuiRuby` module.
  #
  # **The Rule:**
  # To instantiate a class like `RatatuiRuby::SomeWidget`, call `tui.some_widget(...)`.
  #
  # **Common Examples:**
  # *   <tt>paragraph(...)</tt> -> <tt>RatatuiRuby::Paragraph.new(...)</tt>
  # *   <tt>block(...)</tt> -> <tt>RatatuiRuby::Block.new(...)</tt>
  # *   <tt>layout(...)</tt> -> <tt>RatatuiRuby::Layout.new(...)</tt>
  # *   <tt>list(...)</tt> -> <tt>RatatuiRuby::List.new(...)</tt>
  # *   <tt>table(...)</tt> -> <tt>RatatuiRuby::Table.new(...)</tt>
  # *   <tt>style(...)</tt> -> <tt>RatatuiRuby::Style.new(...)</tt>
  #
  # If a new class is added to the library, it is automatically available here.
  #
  # === Nested Helpers
  #
  # *   <tt>text_span(...)</tt> -> <tt>RatatuiRuby::Text::Span.new(...)</tt>
  # *   <tt>text_line(...)</tt> -> <tt>RatatuiRuby::Text::Line.new(...)</tt>
  #
  # === Examples
  #
  # ==== Basic Usage (Recommended)
  #
  #   RatatuiRuby.run do |tui|
  #     loop do
  #       tui.draw \
  #         tui.paragraph \
  #             text: "Hello, Ratatui! Press 'q' to quit.",
  #             alignment: :center,
  #             block: tui.block(
  #               title: "My Ruby TUI App",
  #               borders: [:all],
  #               border_color: "cyan"
  #             )
  #       event = tui.poll_event
  #       break if event == "q" || event == :ctrl_c
  #     end
  #   end
  #
  # ==== Raw API (Verbose)
  #
  #   RatatuiRuby.run do
  #     loop do
  #       RatatuiRuby.draw \
  #         RatatuiRuby::Paragraph.new(
  #             text: "Hello, Ratatui! Press 'q' to quit.",
  #             alignment: :center,
  #             block: RatatuiRuby::Block.new(
  #               title: "My Ruby TUI App",
  #               borders: [:all],
  #               border_color: "cyan"
  #             )
  #         )
  #       event = RatatuiRuby.poll_event
  #       break if event == "q" || event == :ctrl_c
  #     end
  #   end
  #
  # ==== Mixed Usage (Flexible)
  #
  #   RatatuiRuby.run do |tui|
  #     loop do
  #       RatatuiRuby.draw \
  #         tui.paragraph \
  #             text: "Hello, Ratatui! Press 'q' to quit.",
  #             alignment: :center,
  #             block: tui.block(
  #               title: "My Ruby TUI App",
  #               borders: [:all],
  #               border_color: "cyan"
  #             )
  #       event = RatatuiRuby.poll_event
  #       break if event == "q" || event == :ctrl_c
  #     end
  #   end
  class Session
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

      # Wrap class methods (factories/helpers) as [class_snake]_[method]
      # e.g. Layout.split -> layout_split
      # e.g. Constraint.percentage -> constraint_percentage
      klass.singleton_methods(false).each do |class_method|
        session_method_name = "#{method_name}_#{class_method}"
        if method_name == "layout" && class_method == :split
          # Special case: layout_split is a clearer name than layout_split
        end

        define_method(session_method_name) do |*args, **kwargs, &block|
          klass.public_send(class_method, *args, **kwargs, &block)
        end
      end
    end

    # Wrap nested module classes with prefixed names (e.g., shape_line, text_span)
    { Shape: :shape, Text: :text }.each do |mod_name, prefix|
      next unless RatatuiRuby.const_defined?(mod_name)

      mod = RatatuiRuby.const_get(mod_name)
      mod.constants.each do |const_name|
        klass = mod.const_get(const_name)
        next unless klass.is_a?(Class)

        class_snake = const_name.to_s
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .downcase
        method_name = "#{prefix}_#{class_snake}"

        define_method(method_name) do |*args, **kwargs, &block|
          klass.new(*args, **kwargs, &block)
        end
      end
    end
  end
end
