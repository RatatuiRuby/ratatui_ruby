# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: LGPL-3.0-or-later
#++

module RatatuiRuby
  class Event
    class Key < Event
      # DWIM predicates for common key patterns.
      #
      # These predicates anticipate what developers intuitively try. Space bars,
      # character categories, Unix signals, and Vim-style navigation.
      module Dwim
        # Returns true if the key is a space character.
        #
        #   event.space? # => true for " "
        def space?
          @code == " " && @modifiers.empty?
        end

        alias spacebar? space?

        # Returns true if the key is Enter. Alias for carriage return.
        #
        #   event.cr? # => true for enter
        def cr?
          @code == "enter" && @modifiers.empty?
        end

        alias carriagereturn? cr?
        alias linefeed? cr?
        alias newline? cr?
        alias lf? cr?

        # Returns true if the key is a single letter (a-z, A-Z).
        #
        #   Event::Key.new(code: "a").letter? # => true
        def letter?
          @code.length == 1 && @code.match?(/\A[A-Za-z]\z/)
        end

        # Returns true if the key is a digit (0-9).
        #
        #   Event::Key.new(code: "5").digit? # => true
        def digit?
          @code.length == 1 && @code.match?(/\A[0-9]\z/)
        end

        # Returns true if the key is alphanumeric.
        #
        #   Event::Key.new(code: "a").alphanumeric? # => true
        def alphanumeric?
          letter? || digit?
        end

        # Returns true if the key is punctuation.
        #
        #   Event::Key.new(code: "@", modifiers: ["shift"]).punctuation? # => true
        def punctuation?
          return false unless @code.length == 1
          !letter? && !digit? && !whitespace?
        end

        # Returns true if the key is whitespace (space, enter, tab).
        #
        #   Event::Key.new(code: " ").whitespace? # => true
        def whitespace?
          @code == " " || @code == "enter" || @code == "tab"
        end

        # Returns true for interrupt (Ctrl+C).
        #
        #   event.interrupt? # => true for Ctrl+C
        def interrupt?
          @code == "c" && @modifiers == ["ctrl"]
        end

        # Returns true for end-of-file (Ctrl+D).
        #
        #   event.eof? # => true for Ctrl+D
        def eof?
          @code == "d" && @modifiers == ["ctrl"]
        end

        # Returns true for cancel (Esc or Ctrl+C).
        #
        #   event.cancel? # => true for Esc or Ctrl+C
        def cancel?
          (@code == "esc" && @modifiers.empty?) || interrupt?
        end

        # Returns true for SIGINT (Ctrl+C).
        #
        #   event.sigint? # => true for Ctrl+C
        def sigint?
          interrupt?
        end

        alias int? sigint?

        # Returns true for SIGTSTP (Ctrl+Z) - suspend/stop.
        #
        #   event.suspend? # => true for Ctrl+Z
        def suspend?
          @code == "z" && @modifiers == ["ctrl"]
        end

        alias sigtstp? suspend?
        alias tstp? suspend?

        # Returns true for SIGQUIT (Ctrl+\).
        #
        #   event.quit? # => true for Ctrl+\
        def quit?
          @code == "\\" && @modifiers == ["ctrl"]
        end

        alias sigquit? quit?

        NAVIGATION_KEYS = %w[up down left right home end page_up page_down].freeze # :nodoc:

        # Returns true if key is a navigation key.
        #
        #   Event::Key.new(code: "up").navigation? # => true
        def navigation?
          NAVIGATION_KEYS.include?(@code) && @modifiers.empty?
        end

        ARROW_KEYS = %w[up down left right].freeze # :nodoc:

        # Returns true if key is an arrow key.
        #
        #   Event::Key.new(code: "up").arrow? # => true
        def arrow?
          ARROW_KEYS.include?(@code) && @modifiers.empty?
        end

        VIM_MOVEMENT_KEYS = %w[h j k l w b g G].freeze # :nodoc:

        # Returns true if key is a Vim movement key.
        #
        #   Event::Key.new(code: "j").vim? # => true
        def vim?
          return true if VIM_MOVEMENT_KEYS.include?(@code) && @modifiers.empty?
          @code == "G" && @modifiers == ["shift"]
        end

        # Returns true for Vim left (h).
        def vim_left?
          @code == "h" && @modifiers.empty?
        end

        # Returns true for Vim down (j).
        def vim_down?
          @code == "j" && @modifiers.empty?
        end

        # Returns true for Vim up (k).
        def vim_up?
          @code == "k" && @modifiers.empty?
        end

        # Returns true for Vim right (l).
        def vim_right?
          @code == "l" && @modifiers.empty?
        end

        # Returns true for Vim word forward (w).
        def vim_word_forward?
          @code == "w" && @modifiers.empty?
        end

        # Returns true for Vim word backward (b).
        def vim_word_backward?
          @code == "b" && @modifiers.empty?
        end

        # Returns true for Vim go to top (gg pattern, here just g).
        def vim_top?
          @code == "g" && @modifiers.empty?
        end

        # Returns true for Vim go to bottom (G).
        def vim_bottom?
          @code == "G" && @modifiers == ["shift"]
        end

        # Punctuation name predicates - generated at load time for performance.
        # Maps intuitive names to their symbol characters.
        # :nodoc:
        PUNCTUATION_NAMES = {
          # Navigation shortcuts (the original use case!)
          tilde: "~",
          slash: "/",
          forwardslash: "/",
          backslash: "\\",

          # Common punctuation
          comma: ",",
          period: ".",
          dot: ".",
          colon: ":",
          semicolon: ";",

          # Question and exclamation
          question: "?",
          questionmark: "?",
          exclamation: "!",
          exclamationmark: "!",
          exclamationpoint: "!",
          bang: "!",

          # Programming symbols
          at: "@",
          atsign: "@",
          hash: "#",
          pound: "#",
          numbersign: "#",
          dollar: "$",
          dollarsign: "$",
          percent: "%",
          caret: "^",
          circumflex: "^",
          ampersand: "&",
          asterisk: "*",
          star: "*",

          # Arithmetic and comparison
          underscore: "_",
          hyphen: "-",
          dash: "-",
          minus: "-",
          plus: "+",
          equals: "=",
          equalsign: "=",
          pipe: "|",
          bar: "|",
          lessthan: "<",
          lt: "<",
          greaterthan: ">",
          gt: ">",

          # Brackets and parens
          lparen: "(",
          leftparen: "(",
          openparen: "(",
          leftparenthesis: "(",
          openparenthesis: "(",
          rparen: ")",
          rightparen: ")",
          closeparen: ")",
          rightparenthesis: ")",
          closeparenthesis: ")",
          lbracket: "[",
          leftbracket: "[",
          openbracket: "[",
          leftsquarebracket: "[",
          opensquarebracket: "[",
          rbracket: "]",
          rightbracket: "]",
          closebracket: "]",
          rightsquarebracket: "]",
          closesquarebracket: "]",
          lbrace: "{",
          leftbrace: "{",
          openbrace: "{",
          leftcurlybrace: "{",
          opencurlybrace: "{",
          rbrace: "}",
          rightbrace: "}",
          closebrace: "}",
          rightcurlybrace: "}",
          closecurlybrace: "}",

          # Quotes
          backtick: "`",
          grave: "`",
          singlequote: "'",
          apostrophe: "'",
          doublequote: "\"",
        }.freeze

        # Generate predicate methods at load time (faster than method_missing)
        PUNCTUATION_NAMES.each do |name, char|
          class_eval <<~RUBY, __FILE__, __LINE__ + 1
            def #{name}?
              @code == #{char.inspect}
            end
          RUBY
        end

        # quote? matches both single and double quotes
        def quote?
          @code == "'" || @code == "\""
        end
      end
    end
  end
end
