# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

# Manages system clipboard interaction with transient feedback.
#
# Apps need to copy data to the clipboard. Users need feedback: "Did it work?"
# Manual clipboard handling and feedback timers scattered through app logic is
# messy.
#
# This object handles clipboard writes to all platforms (pbcopy, xclip, xsel).
# It manages a feedback message and countdown timer.
#
# Use it to provide copy-to-clipboard functionality with user feedback.
#
# === Example
#
#   clipboard = Clipboard.new
#   clipboard.copy("#FF0000")
#   puts clipboard.message  # => "Copied!"
#
#   # In render loop:
#   clipboard.tick  # Decrement timer
#   puts clipboard.message  # => "" (after 60 frames)
class Clipboard
  def initialize
    @message = ""
    @timer = 0
  end

  # Writes text to the system clipboard.
  #
  # Tries pbcopy (macOS), xclip (Linux), then xsel (Linux fallback). Sets the
  # feedback message to <tt>"Copied!"</tt> and starts a 60-frame timer.
  #
  # [text] String to copy
  #
  # === Example
  #
  #   clipboard = Clipboard.new
  #   clipboard.copy("#FF0000")
  #   clipboard.message  # => "Copied!"
  def copy(text)
    if `which pbcopy 2>/dev/null`.strip.length > 0
      IO.popen("pbcopy", "w") { |io| io.write(text) }
    elsif `which xclip 2>/dev/null`.strip.length > 0
      IO.popen("xclip -selection clipboard", "w") { |io| io.write(text) }
    elsif `which xsel 2>/dev/null`.strip.length > 0
      IO.popen("xsel --clipboard --input", "w") { |io| io.write(text) }
    end
    @message = "Copied!"
    @timer = 60
  end

  # Decrements the feedback timer by one frame.
  #
  # Call this once per render cycle. The message disappears when the timer
  # reaches zero.
  #
  # === Example
  #
  #   clipboard.copy("text")  # timer = 60
  #   clipboard.tick          # timer = 59
  #   60.times { clipboard.tick }  # message becomes ""
  def tick
    @timer -= 1 if @timer > 0
    @message = "" if @timer <= 0
  end

  # Current feedback message.
  #
  # Empty string when no active message. <tt>"Copied!"</tt> after a successful
  # copy, fading after 60 frames.
  #
  # === Example
  #
  #   clipboard.message  # => ""
  #   clipboard.copy("x")
  #   clipboard.message  # => "Copied!"
  def message
    @message
  end
end
