<!-- SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com> -->
<!-- SPDX-License-Identifier: AGPL-3.0-or-later -->

# DWIM / DX Improvements for Application Developers

## Problem Statement

Ruby's philosophy of "Do What I Mean" (DWIM) and human-centric design should extend to ratatui_ruby's API. Currently, app developers encounter friction points that force them to remember non-obvious conventions, use overly verbose code, or pattern-match when simple predicates would suffice.

This proposal identifies DX issues across the widget API and suggests improvements that maintain backward compatibility while providing ergonomic alternatives.

## DX Issues Identified

### 1. Confusing Event Method Names

**Current problem**: `event.char` doesn't exist, but `event.code` returns things like `"enter"`, `"ctrl"`, not just characters.

**What users expect**: 
- `event.char` should return the printable character (matching the name)
- `event.ctrl_c?`, `event.enter?`, etc. should work for all key combinations
- `event.key?`, `event.mouse?` predicates exist but only for broad categories

**Solution implemented**: Added `char` method and dynamic predicates via `method_missing`. See `lib/ratatui_ruby/event/key.rb`.

### 2. Dual Parameter APIs Without Predicates

**Current problem**: Widgets accept both forms but no convenience methods to query the state:

```ruby
# Both work, but which one does the widget store?
gauge1 = Gauge.new(ratio: 0.75)
gauge2 = Gauge.new(percent: 75)
gauge1.ratio  # Works
gauge1.percent  # Does NOT exist
```

Similarly with List and Table:
```ruby
list.selected_index = 2  # Works
list.selected?  # Does NOT exist
list.is_selected?  # Does NOT exist
```

**Affected widgets**: 
- `Gauge` (ratio vs percent)
- `LineGauge` (ratio vs percent)
- `List` (selected_index with no query methods)
- `Table` (selected_row and selected_column with no query methods)

**Suggested solutions**:

For `Gauge` and `LineGauge`:
```ruby
# Add convenience predicates
gauge.percent  # => 75 (coerced from ratio internally)
gauge.percent = 50  # => Updates ratio to 0.5

# Or provide explicit accessors
gauge.as_percent  # => 75
gauge.as_ratio   # => 0.75
```

For `List` and `Table`:
```ruby
list.selected?  # => true if selected_index is not nil
list.selection  # => 2 (alias for selected_index)
list.selected_item  # => "Item 3"

table.selected_row?  # => true if selected_row is not nil
table.selected_cell?  # => true if both row and column selected
```

### 3. Symbol Constants for Enum Values

**Current problem**: Magic symbol values scattered across code:

```ruby
list = List.new(
  highlight_spacing: :when_selected,  # What are the other options?
  direction: :top_to_bottom,          # Is :bottom_to_top valid?
)

layout = Layout.new(
  flex: :legacy  # What does "legacy" mean?
)

gauge = Gauge.new(
  use_unicode: true  # Unclear what ASCII fallback looks like
)
```

Users must consult docs or source code to discover valid options.

**Suggested solution**: Add constants to widget classes:

```ruby
class List < Data
  # Highlight spacing modes
  HIGHLIGHT_ALWAYS = :always
  HIGHLIGHT_WHEN_SELECTED = :when_selected
  HIGHLIGHT_NEVER = :never

  # Direction modes
  DIRECTION_TOP_TO_BOTTOM = :top_to_bottom
  DIRECTION_BOTTOM_TO_TOP = :bottom_to_top
end

list = List.new(
  highlight_spacing: List::HIGHLIGHT_WHEN_SELECTED,
  direction: List::DIRECTION_TOP_TO_BOTTOM,
)
```

Benefits:
- IDE autocomplete shows valid options
- Self-documenting code
- Typos caught at runtime (symbol vs constant)
- Easy to grep for where these modes are used

Affected widgets and their enum values:
- `List`: `highlight_spacing` (:always, :when_selected, :never), `direction` (:top_to_bottom, :bottom_to_top)
- `Table`: `highlight_spacing` (same as List), `flex` (:legacy, :default, :fill)
- `Layout`: `direction` (:vertical, :horizontal), `flex` (:legacy, :default, :fill)
- `Gauge`/`LineGauge`: `use_unicode` (boolean, but could have MODE_UNICODE, MODE_ASCII)
- `Paragraph`: `alignment` (:left, :center, :right)
- `Block`: `border_type` (:plain, :rounded, :double, :thick)
- `Canvas`: `marker` (:braille, :dots, :half_block, :sextant, :octant)

### 4. Inconsistent Style APIs

**Current problem**: Different widgets accept styles differently:

```ruby
# Table accepts both
table = Table.new(style: Style.new(fg: :blue))
table = Table.new(style: { fg: :blue })  # Hash shorthand

# But Paragraph doesn't
paragraph = Paragraph.new(text: "hi", style: Style.new(fg: :blue))
paragraph = Paragraph.new(text: "hi", style: { fg: :blue })  # Works but undocumented

# And Gauge has separate properties
gauge = Gauge.new(style: Style.new(fg: :blue), gauge_style: Style.new(fg: :green))
```

**Suggested solution**: Standardize style handling across all widgets:

1. All widgets should accept `Style` objects and `Hash` shorthand
2. Document this clearly in each widget
3. Add a convenience constructor:

```ruby
class Style
  def self.with(fg: nil, bg: nil, modifiers: [])
    Style.new(fg: fg, bg: bg, modifiers: modifiers)
  end
end

# Cleaner than always spelling out keyword args
paragraph = Paragraph.new(text: "hi", style: Style.with(fg: :blue))
```

### 5. Missing State Query Predicates

**Current problem**: Widgets store state but provide no query methods:

```ruby
list.selected_index = 0

# To check if something is selected, must do:
if list.selected_index&.nonzero?  # Awkward
if list.selected_index.nil? == false  # Confusing

# Should be:
list.selected?  # => true
list.empty?  # => false (for items array)
```

**Suggested solution**: Add predicates to state-holding widgets:

```ruby
# List
list.selected?      # => !selected_index.nil?
list.empty?         # => items.empty?
list.selection      # => selected_index (alias)
list.selected_item  # => items[selected_index] (convenience)

# Table
table.selected_row?    # => !selected_row.nil?
table.selected_cell?   # => !selected_row.nil? && !selected_column.nil?
table.empty?           # => rows.empty?

# Gauge
gauge.filled?          # => ratio > 0
gauge.complete?        # => ratio >= 1.0
```

### 6. Magic Numeric Coercions

**Current problem**: Widgets accept `Numeric` but silently coerce:

```ruby
# These all work, but behavior is undocumented
list = List.new(selected_index: "2")    # Coerced to 2
list = List.new(selected_index: 2.7)    # Coerced to 2
list = List.new(selected_index: 2.0)    # Coerced to 2

gauge = Gauge.new(percent: 150)  # Should clamp?
gauge = Gauge.new(ratio: 1.5)    # Should clamp?
```

**Suggested solution**: 

1. Document coercion rules explicitly in RDoc
2. Add validation and raise on invalid inputs:

```ruby
def initialize(percent: nil, ...)
  if percent
    raise ArgumentError, "percent must be 0..100, got #{percent}" unless percent.between?(0, 100)
    ratio = Float(percent) / 100.0
  end
end
```

3. Provide clear error messages:
```ruby
gauge = Gauge.new(percent: 150)
# => ArgumentError: percent must be between 0 and 100 (got 150)
```

## Implementation Strategy

### Phase 1: Event Improvements (DONE)
- [x] Add `char` method to Key event
- [x] Implement dynamic predicates via `method_missing`
- [x] Update examples to use new API

### Phase 2: State Query Predicates
- [ ] Add predicates to `List` (selected?, empty?, selected_item)
- [ ] Add predicates to `Table` (selected_row?, selected_cell?, empty?)
- [ ] Add predicates to `Gauge` (filled?, complete?)
- [ ] Tests for all new predicates

### Phase 3: Symbol Constants
- [ ] Add enum constants to `List`, `Table`, `Layout`
- [ ] Add enum constants to `Gauge`, `LineGauge`, `Paragraph`, `Block`
- [ ] Update all examples to use constants
- [ ] Document constants in RDoc

### Phase 4: Style Consistency
- [ ] Standardize `Hash` shorthand support across all widgets
- [ ] Add `Style.with(fg:, bg:, modifiers:)` convenience constructor
- [ ] Update `.rbs` files to reflect HashStyle support
- [ ] Document in style guide

### Phase 5: Numeric Coercion Validation
- [ ] Add validation to `Gauge`, `LineGauge`, `List`, `Table`
- [ ] Raise `ArgumentError` on out-of-range values
- [ ] Provide clear error messages
- [ ] Update tests

### Phase 6: Convenience Accessors
- [ ] Add `percent` to `Gauge` and `LineGauge`
- [ ] Add `selection` alias to `List` and `Table`
- [ ] Add `selected_item` to `List`
- [ ] Tests and documentation

## Example: Before and After

### Before (Confusing)
```ruby
class GameApp
  def initialize
    @menu = List.new(
      items: ["Start Game", "Load Game", "Options", "Quit"],
      selected_index: 0,
      highlight_spacing: :when_selected,  # What's valid here?
      direction: :top_to_bottom
    )
  end

  def handle_input(event)
    case event
    when :ctrl_c
      exit
    when :up
      if @menu.selected_index && @menu.selected_index > 0
        @menu = @menu.with(selected_index: @menu.selected_index - 1)
      end
    end
  end

  def render(tui)
    tui.draw(@menu)
  end
end
```

### After (DWIM)
```ruby
class GameApp
  def initialize
    @menu = List.new(
      items: ["Start Game", "Load Game", "Options", "Quit"],
      selected_index: 0,
      highlight_spacing: List::HIGHLIGHT_WHEN_SELECTED,  # IDE autocomplete!
      direction: List::DIRECTION_TOP_TO_BOTTOM
    )
  end

  def handle_input(event)
    return if event.ctrl_c?  # Dynamic predicate!
    
    if event.up?
      move_menu_up if @menu.selected?  # State predicate!
    end
  end

  def move_menu_up
    index = @menu.selected_index
    return if index == 0
    @menu = @menu.with(selected_index: index - 1)
  end

  def render(tui)
    tui.draw(@menu)
  end
end
```

## Migration Path

All changes are backward compatible (additive):
- Existing code using symbols continues to work
- New constants coexist with symbols
- New predicates don't change existing behavior
- New methods are additions, not replacements

Apps can migrate at their own pace:
```ruby
# Old style still works
list = List.new(highlight_spacing: :when_selected)

# New style also works
list = List.new(highlight_spacing: List::HIGHLIGHT_WHEN_SELECTED)

# Mix and match
if list.selected?  # New predicate
  puts list.selected_index  # Old accessor
end
```

## Metrics for Success

1. **Discoverability**: New developers can find valid options via IDE autocomplete
2. **Clarity**: Code self-documents valid states and modes
3. **Type safety**: Constants and predicates provide type checking
4. **Error feedback**: Invalid inputs raise with helpful messages
5. **Backward compatibility**: Zero breaking changes, all existing code works

## Related Issues

- AGENTS.md requirement: All examples must have tests verifying behavior
- Example improvements: Apply constants and predicates to all example code
- Documentation: Update style guide with DWIM principles
