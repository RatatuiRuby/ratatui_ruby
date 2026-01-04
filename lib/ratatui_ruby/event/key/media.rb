# frozen_string_literal: true

#--
# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later
#++

module RatatuiRuby
  class Event
    class Key < Event
      # Methods and logic for media keys.
      module Media
        # Returns true if this is a media key.
        #
        # Media keys include: play, pause, stop, track controls, volume controls.
        # These are only available in terminals supporting the Kitty keyboard protocol.
        #
        #   event.media? # => true for media_play, media_pause, etc.
        def media?
          @kind == :media
        end

        # Handles media-specific DWIM logic for method_missing.
        private def match_media_dwim?(key_name)
          return false unless @kind == :media

          # Allow unprefixed predicate
          # e.g., pause? returns true for media_pause
          if @code.start_with?("media_")
            base_code = @code.delete_prefix("media_")
            return true if key_name == base_code
          end

          # Bidirectional media overlaps
          # e.g., play? and pause? both match media_play_pause
          return true if @code == "media_play_pause" && (key_name == "play" || key_name == "pause")

          # e.g., play_pause? matches media_play or media_pause
          return true if key_name == "play_pause" && (@code == "media_play" || @code == "media_pause")

          false
        end
      end
    end
  end
end
