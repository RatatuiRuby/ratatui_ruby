# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

# Semantic message types for the Proto-TEA architecture.
#
# Raw events from the terminal are converted to semantic Msg types. This
# decouples the Update function from the event system, making it easier
# to test and reason about.
#
# === Example
#
#   msg = Msg::Input.new(event: key_event)
#   msg = Msg::Quit.new
module Msg
  # A keyboard, mouse, or paste event to record.
  Input = Data.define(:event)

  # A terminal resize event.
  #
  # [width] Integer new terminal width
  # [height] Integer new terminal height
  # [previous_size] Array [width, height] before resize
  Resize = Data.define(:width, :height, :previous_size)

  # A focus change event.
  #
  # [gained] Boolean true if focus was gained, false if lost
  Focus = Data.define(:gained)

  # A none/timeout event (no input received).
  NoneEvent = Data.define

  # A quit signal.
  Quit = Data.define
end
