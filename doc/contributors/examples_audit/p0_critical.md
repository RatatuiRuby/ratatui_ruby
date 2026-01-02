<!--
SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
SPDX-License-Identifier: CC-BY-SA-4.0
-->

# Priority 0: Critical (Must Fix Before v1.0.0)

Blocking issues that prevent examples from meeting v1.0.0 quality standards.

---

## 1. Fix developing_examples.md (Blocking documentation)

**Status:** 🔴 CRITICAL — Misdirects ALL future example contributions

The file `doc/contributors/developing_examples.md` contains incorrect documentation about test and signature file locations.

### What's Wrong

**Documented (INCORRECT):**
```
Example tests live alongside examples as `test_app.rb` files in the same directory.
Every example must also have an RBS file documenting its public methods: `examples/my_example/app.rbs`
```

**Actual (CORRECT):**
- Tests are in `test/examples/{example_name}/test_app.rb`
- Signatures are in `sig/examples/{example_name}/app.rbs`

### Required Fixes

#### Fix 1: Update "Example Structure" Section

Replace the current RBS documentation with:

```markdown
## Type Signatures

Type signatures live in a centralized location:

`sig/examples/my_example/app.rbs`:
```rbs
class MyExampleApp
  # @public
  def self.new: () -> MyExampleApp

  # @public
  def run: () -> void
end
```
```

#### Fix 2: Update "Testing Examples" Section

Replace the current testing documentation with:

```markdown
## Testing Examples

Example tests live in a centralized test tree:

`test/examples/my_example/test_app.rb`:
```ruby
$LOAD_PATH.unshift File.expand_path("../../lib", __dir__)
require "ratatui_ruby"
require "ratatui_ruby/test_helper"
require "minitest/autorun"
require_relative "app"

class TestMyExampleApp < Minitest::Test
  include RatatuiRuby::TestHelper

  def setup
    @app = MyExampleApp.new
  end

  def test_initial_render
    with_test_terminal do
      inject_key(:q)
      @app.run
      assert_snapshot("initial_render")
    end
  end
end
```
```

#### Fix 3: Add Directory Structure Documentation

Add a new subsection to show the complete layout:

```markdown
## Directory Structure

Examples are organized across three locations:

```
examples/
  my_example/
    app.rb              ← The runnable example code
    README.md           ← REQUIRED: Purpose, architecture, hotkeys, usage

test/examples/
  my_example/
    test_app.rb         ← Tests (centralized, not local to example)
    snapshots/          ← Auto-created by assert_snapshot
      initial_render.txt

sig/examples/
  my_example/
    app.rbs             ← Type signatures (centralized, not local to example)
```
```

#### Fix 4: Add README Requirement

Add to "Key Requirements" section:

```markdown
6. **All examples must include a README.md** explaining:
   - What problem the example solves
   - Architecture (if applicable)
   - Hotkeys (if interactive): Document all keyboard/mouse controls
   - Key concepts demonstrated
   - Usage instructions
   - Learning outcomes

   See examples/app_color_picker/README.md and examples/app_all_events/README.md for patterns.
```

#### Fix 5: Document Snapshot Testing as Standard

Add new section to "Testing Examples":

```markdown
## Snapshot Testing Pattern (REQUIRED)

All example tests MUST use snapshot testing via the `assert_snapshot` API, not manual content assertions.

### Why Snapshots

- **Exact verification:** Captures complete screen state, character-by-character
- **Auto-update:** `UPDATE_SNAPSHOTS=1 bin/agent_rake test` regenerates all snapshots
- **Auto-managed:** Snapshots live in `test/examples/{name}/snapshots/{test_name}.txt`
- **Maintainable:** No tedious manual string checks
- **Self-documenting:** Snapshots show exactly what output is expected

### Basic Pattern

```ruby
def test_initial_render
  with_test_terminal do
    inject_key(:q)
    @app.run
    
    assert_snapshot("initial_render")
  end
end
```

Snapshot auto-saved to: `test/examples/widget_foo_demo/snapshots/initial_render.txt`

### With Normalization (for dynamic content)

For examples with timestamps, random data, or other non-deterministic output:

```ruby
private def assert_normalized_snapshot(snapshot_name)
  assert_snapshot(snapshot_name) do |actual|
    actual.map do |line|
      line.gsub(/\d{2}:\d{2}:\d{2}/, "XX:XX:XX")  # Mask timestamps
           .gsub(/Random ID: \d+/, "Random ID: XXX")  # Mask random values
    end
  end
end

def test_after_event
  with_test_terminal do
    inject_key("a")
    inject_key(:q)
    @app.run
    
    assert_normalized_snapshot("after_event")
  end
end
```

See `test/examples/app_all_events/test_app.rb` for a complete example.

### Regenerating Snapshots

When UI changes are intentional, regenerate all snapshots:

```bash
UPDATE_SNAPSHOTS=1 bin/agent_rake test
```
```

---

## 2. Add README.md to 34 Examples

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

## 3. Migrate Example Tests to Snapshot API

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

- [ ] Fix developing_examples.md (5 corrections)
- [ ] Add README.md to 34 examples
- [ ] Migrate 34 tests to snapshot API

**Blocking:** All three must be done before v1.0.0 release.
