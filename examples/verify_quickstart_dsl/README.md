<!--
SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Quickstart DSL Verification

Verifies the "Idiomatic Session" tutorial in the [Quickstart](../../doc/quickstart.md#idiomatic-session).

This example exists as a documentation regression test. It ensures the recommended DSL and session-based workflow remains functional.

## Usage

<!-- SYNC:START:app.rb:main -->
```ruby
RatatuiRuby.run do |tui|
  loop do
    # 2. Create your UI with methods instead of classes.
    view = tui.paragraph(
      text: "Hello, Ratatui! Press 'q' to quit.",
      alignment: :center,
      block: tui.block(
        title: "My Ruby TUI App",
        title_alignment: :center,
        borders: [:all],
        border_color: "cyan",
        style: { fg: "white" }
      )
    )

    # 3. Use RatatuiRuby methods, too.
    tui.draw do |frame|
      frame.render_widget(view, frame.area)
    end

    # 4. Poll for events with pattern matching
    case tui.poll_event
    in { type: :key, code: "q" }
      break
    else
      # Ignore other events
    end
  end
end
```
<!-- SYNC:END -->

![verify_quickstart_dsl](../../doc/images/verify_quickstart_dsl.png)
