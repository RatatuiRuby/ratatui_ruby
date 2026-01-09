# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  module Widgets
    # Mixin that provides DWIM hash coercion for widget classes.
    #
    # When users call `tui.table(hash)` instead of `tui.table(**hash)`,
    # Ruby's `...` forwarding passes the Hash as a positional argument,
    # causing cryptic TypeErrors at the Rust FFI boundary.
    #
    # This mixin provides a `coerce_args` class method that detects
    # this pattern and automatically splats the hash into keyword arguments.
    #
    # === Behavior
    #
    # - **Production mode**: Unknown keys are silently ignored
    # - **Debug mode (RR_DEBUG=1)**: Raises ArgumentError to catch typos early
    #
    # === Usage
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   class Table < Data.define(:rows, :widths, ...)
    #     include CoerceableWidget
    #   end
    #
    #   # In WidgetFactories:
    #   def table(first = nil, **kwargs)
    #     Widgets::Table.coerce_args(first, kwargs)
    #   end
    #--
    # SPDX-SnippetEnd
    #++
    module CoerceableWidget
      ##
      # Hook called when this module is included in a widget class.
      #
      # Extends the class with ClassMethods and defines KNOWN_KEYS constant
      # from the Data.define members for validation.
      #
      # [base] The class including this module.
      def self.included(base)
        base.extend(ClassMethods)
        base.const_set(:KNOWN_KEYS, base.members.freeze) unless base.const_defined?(:KNOWN_KEYS)
      end

      # Class methods extended onto widget classes.
      module ClassMethods
        # Coerces a bare Hash argument into keyword arguments.
        #
        # @param first [Hash, nil] First positional argument (bare hash case)
        # @param kwargs [Hash] Keyword arguments (normal splatted case)
        # @return [Object] New instance of the widget class
        # @raise [ArgumentError] In debug mode, if unknown keys are present
        def coerce_args(first, kwargs)
          if first.is_a?(Hash) && kwargs.empty?
            unknown = first.keys - self::KNOWN_KEYS
            if unknown.any? && RatatuiRuby::Debug.enabled?
              raise ArgumentError, "#{name}: unknown keys #{unknown.inspect}"
            end
            new(**first.slice(*self::KNOWN_KEYS))
          else
            new(**kwargs)
          end
        end
      end
    end
  end
end
