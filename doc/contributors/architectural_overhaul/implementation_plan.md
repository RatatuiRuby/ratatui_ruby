# Table Rich Text, Row, Cell, and Line#width

## User Review Required

> [!IMPORTANT]
> **Namespace Decision:** Following existing patterns (`Text::Span`, `BarChart::Bar`), I recommend:
> - `RatatuiRuby::Table::Cell` — table cell construction (content + style)
> - `RatatuiRuby::Table::Row` — row construction (cells + style + height)
> - `RatatuiRuby::Buffer::Cell` — buffer inspection (renamed from current `Cell`)
>
> This groups related concepts and mirrors how Ratatui separates `widgets::Cell` from `buffer::Cell`.

### Breaking Changes

1. `RatatuiRuby::Cell` → `RatatuiRuby::Buffer::Cell` (buffer inspection)
2. `RatatuiRuby::Row` → `RatatuiRuby::Table::Row` (if we move it)

---

## Proposed Structure

```
RatatuiRuby::
├── Table                      # Table widget
│   ├── Cell                   # NEW: content + style for cells
│   └── Row                    # MOVE: cells + style + height
├── Buffer::
│   └── Cell                   # RENAME: from RatatuiRuby::Cell
├── Text::
│   ├── Span                   # existing
│   └── Line                   # existing (now with #width)
└── ... other widgets
```

---

## Changes Summary

| Feature | Status |
|---------|--------|
| Table cells accept Text::Span/Line | ✅ Done |
| Row class with style/height | ✅ Done (needs move to Table::Row) |
| Line#width method | ✅ Done |
| Table::Cell class | ⏳ Pending approval |
| Buffer::Cell rename | ⏳ Pending approval |

---

## Verification

```bash
bin/agent_rake
```

