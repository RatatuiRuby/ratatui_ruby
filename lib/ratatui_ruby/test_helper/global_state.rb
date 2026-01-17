# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long &lt;me@kerricklong.com&gt;
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  module TestHelper
    ##
    # Helpers for testing code that reads global state.
    #
    # Applications often read +ARGV+ and +ENV+ at startup. Testing these code
    # paths requires stubbing those constants. Doing it manually is brittle —
    # tests that forget to restore the original values leak state.
    #
    # These helpers swap the constants, yield to the block, and restore the
    # originals automatically.
    #
    # == Example
    #
    #--
    # SPDX-SnippetBegin
    # SPDX-FileCopyrightText: 2026 Kerrick Long
    # SPDX-License-Identifier: MIT-0
    #++
    #   def test_parses_command_line_flags
    #     with_argv(["--verbose", "--log=debug.log"]) do
    #       app = MyApp.new
    #       assert app.verbose?
    #       assert_equal "debug.log", app.log_path
    #     end
    #   end
    #
    #   def test_reads_api_key_from_environment
    #     with_env("API_KEY", "test-key-1234") do
    #       client = APIClient.new
    #       assert_equal "test-key-1234", client.api_key
    #     end
    #   end
    #--
    # SPDX-SnippetEnd
    #++
    module GlobalState
      # Temporarily replaces ARGV for the duration of the block.
      #
      # [argv] An array of strings to use as ARGV.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   with_argv(["--help"]) do
      #     # Code here sees ARGV as ["--help"]
      #   end
      #--
      # SPDX-SnippetEnd
      #++
      def with_argv(argv)
        original_argv = ARGV.dup
        ARGV.replace(argv)
        yield
      ensure
        ARGV.replace(original_argv)
      end

      # Temporarily replaces an environment variable for the duration of the block.
      #
      # If +value+ is +nil+, the variable is deleted for the block's duration.
      #
      # [key] The environment variable name (String).
      # [value] The value to set, or +nil+ to delete.
      #
      # === Example
      #
      #--
      # SPDX-SnippetBegin
      # SPDX-FileCopyrightText: 2026 Kerrick Long
      # SPDX-License-Identifier: MIT-0
      #++
      #   with_env("DEBUG", "1") do
      #     # Code here sees ENV["DEBUG"] as "1"
      #   end
      #
      #   with_env("DEBUG", nil) do
      #     # Code here does not see ENV["DEBUG"]
      #   end
      #--
      # SPDX-SnippetEnd
      #++
      def with_env(key, value)
        original_value = ENV[key]
        if value.nil?
          ENV.delete(key)
        else
          ENV[key] = value
        end
        yield
      ensure
        if original_value.nil?
          ENV.delete(key)
        else
          ENV[key] = original_value
        end
      end
    end
  end
end
