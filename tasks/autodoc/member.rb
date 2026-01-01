# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

module Autodoc
  module Member
    class Delegate < Data.define(:name)
      def rbs
        "    def #{name}: (*untyped args, **untyped kwargs) ?{ (*untyped) -> untyped } -> untyped"
      end

      def rdoc
        [
          "    # :method: #{name}",
          "    # :call-seq: #{name}(*args, **kwargs, &block)",
          "    #",
          "    # Delegates to RatatuiRuby.#{name}.",
          "    #",
        ]
      end
    end

    class Factory < Data.define(:name, :const_name)
      def rbs
        "    def #{name}: (*untyped args, **untyped kwargs) ?{ (*untyped) -> untyped } -> untyped"
      end

      def rdoc
        [
          "    # :method: #{name}",
          "    # :call-seq: #{name}(*args, **kwargs, &block)",
          "    #",
          "    # Factory for RatatuiRuby::#{const_name}.new.",
          "    #",
        ]
      end
    end

    class Helper < Data.define(:name, :class_method, :const_name)
      def rbs
        "    def #{name}: (*untyped args, **untyped kwargs) ?{ (*untyped) -> untyped } -> untyped"
      end

      def rdoc
        [
          "    # :method: #{name}",
          "    # :call-seq: #{name}(*args, **kwargs, &block)",
          "    #",
          "    # Helper for RatatuiRuby::#{const_name}.#{class_method}.",
          "    #",
        ]
      end
    end
  end
end
