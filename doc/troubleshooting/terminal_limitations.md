<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Terminal Limitations

Some behaviors are outside the control of `ratatui_ruby`. This document explains common pitfalls that affect your application or your users, but cannot be fixed in the library.

## Keyboard Event Interception

### The Problem

Your application receives a key event, but the modifier flags are missing. You pressed Ctrl+PageUp, but the event shows `code="page_up"` with `modifiers=[]`.

### The Cause

Terminal emulators intercept certain key combinations for their own features. The key press never reaches your application—the terminal consumes it first.

Common culprits on macOS:

| Key Combination      | Terminal Behavior                    |
|---------------------|--------------------------------------|
| Ctrl+PageUp/Down    | Switch tabs (Terminal.app, iTerm2)   |
| Ctrl+Tab            | Switch tabs                          |
| Cmd+T / Cmd+N       | New tab / New window                 |
| Cmd+C / Cmd+V       | Copy / Paste (not Ctrl)              |

Linux terminals vary widely. Windows Terminal and ConEmu have their own defaults.

### The Solution

1. **Test with different terminals.** Kitty, WezTerm, and Alacritty pass more key combinations through to applications by default. If a key works in Kitty but not Terminal.app, the terminal is the issue.

2. **Reconfigure your terminal.** Most terminal emulators let you unbind or remap default shortcuts in their settings.

3. **Use alternative key bindings.** If your users will run your application in various terminals, design your keybindings to avoid commonly intercepted combinations:
   - Use Alt+PageUp instead of Ctrl+PageUp
   - Use Ctrl+J/K instead of Ctrl+Up/Down
   - Avoid Ctrl+Tab entirely

4. **Document requirements.** If your application depends on specific key combinations, document the terminal requirements for your users.

### Enhanced Keyboard Protocol

Some terminals support the [Kitty keyboard protocol](https://sw.kovidgoyal.net/kitty/keyboard-protocol/), which provides unambiguous key event reporting including:

- Individual modifier key events (LeftShift vs RightShift)
- Media keys (Play, Pause, Volume controls)
- Repeat and release events

Terminals with full protocol support:
- Kitty
- WezTerm
- Foot
- Alacritty (partial)

Standard terminals (Terminal.app, iTerm2, GNOME Terminal) do not support the enhanced protocol.

**RatatuiRuby Status:** The underlying library (crossterm) supports this protocol, but RatatuiRuby does not yet expose a way to enable it. The key code mappings for media keys and individual modifier keys exist, but they will only be received from terminals that enable the protocol by default. This is planned for a future release.

## Mouse Event Limitations

### The Problem

Mouse events work in some terminals but not others. Or they work, but only up to certain coordinates.

### The Cause

Mouse reporting requires terminal escape sequence support. Older terminals may not support:

- SGR mouse mode (coordinates > 223)
- Mouse motion tracking
- Button-event tracking

### The Solution

Ensure your terminal supports modern mouse modes. Most actively maintained terminals do. If running in a legacy environment, test mouse functionality and provide keyboard alternatives.

## Focus Events

### The Problem

`Event::FocusGained` and `Event::FocusLost` are never received.

### The Cause

Focus event reporting requires explicit terminal support and configuration. Some terminals don't support it at all.

### The Solution

Don't rely on focus events for critical functionality. Treat them as nice-to-have enhancements. If your application shows stale data when the user returns, periodically refresh instead of waiting for focus events.

## Process Termination

### The Problem

Your TUI app is terminated by `kill -9` or the [OOM killer](https://en.wikipedia.org/wiki/Out_of_memory#Out_of_memory_management). The terminal stays in raw mode. The user's cursor vanishes. Input echoes weirdly. Their shell is unusable.

### The Cause

SIGKILL (`kill -9`) terminates processes immediately. No cleanup code runs. The terminal never receives the escape sequences to restore normal mode.

This also happens when:
- The system OOM killer terminates your process
- A parent process force-kills your app
- A debugger disconnects ungracefully

### The Solution

There's no way to catch SIGKILL. You can only mitigate the impact.

**Tell your users how to recover.** In your README or troubleshooting docs, explain: if the terminal breaks, type `reset` and press Enter. The characters won't echo, but the command runs.

**Script graceful shutdowns.** If you write deployment or process management scripts, prefer graceful signals with a timeout before SIGKILL:

```bash
# Graceful first, force if needed
kill -15 $PID
sleep 2
kill -0 $PID 2>/dev/null && kill -9 $PID
```

See [Application Architecture: Signal Handling](../concepts/application_architecture.md#signal-handling) for programmatic cleanup strategies.

