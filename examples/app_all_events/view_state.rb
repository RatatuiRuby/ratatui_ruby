# frozen_string_literal: true

# SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

# Encapsulates all data required to render the application view.
#
# Views need access to models, global settings, and calculated styles.
# Passing dozens of individual parameters to view components is messy and unmaintainable.
#
# This class provides a single, structured object containing all state necessary for rendering.
#
# Use it to shuttle data from the main application to the various view components.
#
# === Examples
#
#   state = ViewState.build(events, true, tui, nil)
#   puts state.focused #=> true
#   app_view.call(state, tui, frame, area)
class ViewState < Data.define(:events, :focused, :hotkey_style, :dimmed_style, :lit_style, :border_color, :area)
  # Builds a new ViewState with calculated styles.
  #
  # [events] Events model instance.
  # [focused] Boolean indicating if the app has focus.
  # [tui] RatatuiRuby instance for style creation.
  # [_resize_sub_counter] Unused parameter (reserved for future use).
  #
  # === Example
  #
  #   ViewState.build(events, true, tui, nil) #=> #<ViewState ...>
  def self.build(events, focused, tui, _resize_sub_counter)
    new(
      events:,
      focused:,
      hotkey_style: tui.style(modifiers: [:bold, :underlined]),
      dimmed_style: tui.style(fg: :dark_gray),
      lit_style: tui.style(fg: :green, modifiers: [:bold]),
      border_color: focused ? :green : :gray,
      area: nil
    )
  end
end
