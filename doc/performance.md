# Performance Considerations

## Memory Usage

### Custom Border Sets

When using custom border sets in `Block` widgets (via the `border_set` parameter), `ratatui_ruby` uses a global string interner to cache the border characters. This allows for efficient reuse of strings, which is critical since the underlying Rust library requires static lifetime strings for symbols.

**Implication**: Every *unique* string used as a border character is permanently stored in memory for the lifetime of the application.

**Best Practice**:
- Define your custom border sets as constants or reuse the same Hash objects.
- **Reusing string literals** (e.g., `border_set: { tl: "1" }` in a loop) is generally safe because the string content is identical and maps to the same interned value.
- **Do not** dynamically generate infinite unique strings for border characters (e.g., do not use a timestamp or random string as a border character: `border_set: { tl: rand.to_s }`).
- If your application requires a large number of unique border styles that change frequently and are never reused, be aware that memory usage will grow over time. For typical TUI applications, this is negligible (a few bytes per unique character), but could become an issue if generated programmatically without bounds.
