<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Priority 0: Critical (Must Fix Before v1.0.0)

Blocking issues that prevent examples from meeting v1.0.0 quality standards.

---



## 1. Add README.md to 34 Examples

**Status:** 🔴 CRITICAL — Prevents discoverability and learning

**32 of 34 examples lack README.md** (only app_all_events and app_color_picker have them).

Users discover examples by browsing `examples/` directory. READMEs explain purpose, architecture, and learning outcomes.

### Template for widget examples

```markdown
# {Widget Name} Example

{1-2 sentence description of what problem this solves}

## Features Demonstrated

- {Concept 1}
- {Concept 2}
- {Concept 3}

## Hotkeys

- {key}: {Action}
- q: Quit

## Usage

\`\`\`bash
ruby examples/widget_foo_demo/app.rb
\`\`\`

## Learning Outcomes

Use this example if you need to...
- {Goal 1}
- {Goal 2}
```

For complex examples, follow the style of:
- `examples/app_color_picker/README.md`
- `examples/app_all_events/README.md`

---

## 2. Migrate Example Tests to Snapshot API

**Status:** 🔴 CRITICAL — Tests don't meet mutation-testing standards

Most example tests use manual content assertions instead of the snapshot API.

### Pattern Change

**OLD:**
```ruby
content = buffer_content
assert content.any? { |line| line.include?("Item 1") }
```

**NEW:**
```ruby
assert_snapshot("initial_render")
```

### Why Snapshots

- **Exact output verification** — not just substring matching
- **Auto-update** — `UPDATE_SNAPSHOTS=1 bin/agent_rake test`
- **Automatic snapshot management** — snapshots live in `test/examples/{name}/snapshots/`
- **Mutation-testing capable** — verifies every character, not just presence of text
- **Self-documenting** — snapshots show exactly what output is expected

### Example Update

For widget_list_demo/test_app.rb:

```ruby
def test_initial_render
  with_test_terminal do
    inject_key(:q)
    @app.run
    assert_snapshot("initial_render")
  end
end

def test_cycle_direction
  with_test_terminal do
    inject_key("d")  # Cycle direction
    inject_key(:q)
    @app.run
    assert_snapshot("after_direction_cycle")
  end
end
```

Snapshots automatically store in `test/examples/widget_list_demo/snapshots/` and can be regenerated with `UPDATE_SNAPSHOTS=1 bin/agent_rake test`.

### For Dynamic Content

Use normalization blocks (as seen in `test/examples/app_all_events/test_app.rb`):

```ruby
private def assert_normalized_snapshot(snapshot_name)
  assert_snapshot(snapshot_name) do |actual|
    actual.map do |line|
      line.gsub(/\d{2}:\d{2}:\d{2}/, "XX:XX:XX")  # Mask timestamps
           .gsub(/\d+/, "XXX")                      # Mask numbers
    end
  end
end
```

---

## Completion Checklist

- [x] Fix developing_examples.md (5 corrections)
- [ ] Add README.md to 34 examples
- [ ] Migrate 34 tests to snapshot API

**Blocking:** All three must be done before v1.0.0 release.
