# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

require "timeout"

module RatatuiRuby
  module TestHelper
    ##
    # Portable subprocess timeout helper.
    module SubprocessTimeout
      private def popen_with_timeout(env, cmd, timeout: 2)
        output = +""
        IO.popen(env, cmd, err: [:child, :out]) do |io|
          deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + timeout
          loop do
            remaining = deadline - Process.clock_gettime(Process::CLOCK_MONOTONIC)
            break if remaining <= 0
            break unless io.wait_readable(remaining)

            chunk = io.read_nonblock(4096, exception: false)
            break if chunk.nil? || chunk == :wait_readable

            output << chunk
          end
          Process.kill("KILL", io.pid) rescue nil # rubocop:disable Style/RescueModifier
        end
        output.strip
      end
    end
  end
end
