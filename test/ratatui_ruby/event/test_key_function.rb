# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

require "test_helper"

module RatatuiRuby
  ##
  # Round-trip tests for function KeyCode variants through the Rust FFI layer.
  #
  # Tests: F(1) through F(24) and extended function keys up to F(255).
  class TestKeyFunction < Minitest::Test
    include RatatuiRuby::TestHelper

    def test_f1
      with_test_terminal do
        inject_keys("f1")
        event = RatatuiRuby.poll_event

        # Precise
        assert_equal "f1", event.code
        assert event.f1?

        # Kind
        assert_equal :function, event.kind
        assert event.function?
        refute event.media?

        # Text
        refute event.text?
        assert_equal "", event.char

        # Modifiers
        refute event.ctrl?
        refute event.alt?
        refute event.shift?
      end
    end

    def test_f2
      with_test_terminal do
        inject_keys("f2")
        event = RatatuiRuby.poll_event
        # Precise
        assert_equal "f2", event.code
        assert event.f2?

        # Kind
        assert_equal :function, event.kind
        assert event.function?
        refute event.standard?
      end
    end

    def test_f3
      with_test_terminal do
        inject_keys("f3")
        event = RatatuiRuby.poll_event
        # Precise
        assert_equal "f3", event.code
        assert event.f3?

        # Kind
        assert_equal :function, event.kind
        assert event.function?
        refute event.modifier?
      end
    end

    def test_f4
      with_test_terminal do
        inject_keys("f4")
        event = RatatuiRuby.poll_event
        # Precise
        assert_equal "f4", event.code
        assert event.f4?

        # Kind
        assert_equal :function, event.kind
        assert event.function?
        refute event.system?
      end
    end

    def test_f5
      with_test_terminal do
        inject_keys("f5")
        event = RatatuiRuby.poll_event
        # Precise
        assert_equal "f5", event.code
        assert event.f5?

        # Kind
        assert_equal :function, event.kind
        assert event.function?
        refute event.media?
      end
    end

    def test_f6
      with_test_terminal do
        inject_keys("f6")
        event = RatatuiRuby.poll_event
        # Precise
        assert_equal "f6", event.code
        assert event.f6?

        # Kind
        assert_equal :function, event.kind
        assert event.function?
        refute event.standard?
      end
    end

    def test_f7
      with_test_terminal do
        inject_keys("f7")
        event = RatatuiRuby.poll_event
        # Precise
        assert_equal "f7", event.code
        assert event.f7?

        # Kind
        assert_equal :function, event.kind
        assert event.function?
        refute event.modifier?
      end
    end

    def test_f8
      with_test_terminal do
        inject_keys("f8")
        event = RatatuiRuby.poll_event
        # Precise
        assert_equal "f8", event.code
        assert event.f8?

        # Kind
        assert_equal :function, event.kind
        assert event.function?
        refute event.system?
      end
    end

    def test_f9
      with_test_terminal do
        inject_keys("f9")
        event = RatatuiRuby.poll_event
        # Precise
        assert_equal "f9", event.code
        assert event.f9?

        # Kind
        assert_equal :function, event.kind
        assert event.function?
        refute event.media?
      end
    end

    def test_f10
      with_test_terminal do
        inject_keys("f10")
        event = RatatuiRuby.poll_event
        # Precise
        assert_equal "f10", event.code
        assert event.f10?

        # Kind
        assert_equal :function, event.kind
        assert event.function?
        refute event.standard?
      end
    end

    def test_f11
      with_test_terminal do
        inject_keys("f11")
        event = RatatuiRuby.poll_event
        # Precise
        assert_equal "f11", event.code
        assert event.f11?

        # Kind
        assert_equal :function, event.kind
        assert event.function?
        refute event.modifier?
      end
    end

    def test_f12
      with_test_terminal do
        inject_keys("f12")
        event = RatatuiRuby.poll_event
        # Precise
        assert_equal "f12", event.code
        assert event.f12?

        # Kind
        assert_equal :function, event.kind
        assert event.function?
        refute event.system?
      end
    end

    def test_f13
      with_test_terminal do
        inject_keys("f13")
        event = RatatuiRuby.poll_event
        # Precise
        assert_equal "f13", event.code
        assert event.f13?

        # Kind
        assert_equal :function, event.kind
        assert event.function?
        refute event.media?
      end
    end

    def test_f24
      with_test_terminal do
        inject_keys("f24")
        event = RatatuiRuby.poll_event
        # Precise
        assert_equal "f24", event.code
        assert event.f24?

        # Kind
        assert_equal :function, event.kind
        assert event.function?
        refute event.modifier?
      end
    end

    def test_extended_function_keys
      with_test_terminal do
        inject_keys("f24")
        event = RatatuiRuby.poll_event
        assert_equal "f24", event.code
        assert event.f24?

        inject_keys("f100")
        event = RatatuiRuby.poll_event
        assert_equal "f100", event.code
        assert event.f100?

        inject_keys("f255")
        event = RatatuiRuby.poll_event
        assert_equal "f255", event.code
        assert event.f255?
      end
    end

    def test_alt_f1
      with_test_terminal do
        inject_event(RatatuiRuby::Event::Key.new(code: "f1", modifiers: ["alt"]))
        event = RatatuiRuby.poll_event
        # Precise
        assert_equal "f1", event.code
        refute event.f1?

        # Kind
        assert_equal :function, event.kind
        assert event.function?
        refute event.system?

        # Modifiers
        assert event.alt?
        assert event.alt_f1?
      end
    end

    def test_alt_f5
      with_test_terminal do
        inject_event(RatatuiRuby::Event::Key.new(code: "f5", modifiers: ["alt"]))
        event = RatatuiRuby.poll_event
        assert_equal "f5", event.code
        assert event.alt?
        assert event.alt_f5?
      end
    end

    def test_alt_f12
      with_test_terminal do
        inject_event(RatatuiRuby::Event::Key.new(code: "f12", modifiers: ["alt"]))
        event = RatatuiRuby.poll_event
        assert_equal "f12", event.code
        assert event.alt?
        assert event.alt_f12?
      end
    end
  end
end
