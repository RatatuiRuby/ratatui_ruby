# Performance Considerations

This document describes performance characteristics and any resolved performance concerns in `ratatui_ruby`.

## Memory Usage

### Custom Border Sets

**Status**: ~~**Concern**~~ **Resolved**

~~When using custom border sets in `Block` widgets (via the `border_set` parameter), `ratatui_ruby` uses a global string interner to cache the border characters. This allows for efficient reuse of strings, which is critical since the underlying Rust library requires static lifetime strings for symbols.~~

~~**Implication**: Every *unique* string used as a border character is permanently stored in memory for the lifetime of the application.~~

**Resolution**: Custom border sets now use **render-scoped arena allocation** (`bumpalo::Bump`). Border character strings are allocated in a temporary arena created at the start of each render call, then automatically deallocated when the render completes.

```rust
// Before (REMOVED):
let leaked = Box::leak(s.to_string().into_boxed_str());  // Permanent memory

// After:
let arena = Bump::new();  // Created at render start
let s = arena.alloc_str(&value);  // Automatically freed after render
```

**Benefits**:
- **Zero permanent memory growth** from custom border sets
- Developers can freely use dynamically generated border characters
- Aligns with the "Stateless/Immediate Mode" architecture

~~**Best Practice**:~~
~~- Define your custom border sets as constants or reuse the same Hash objects.~~
~~- **Reusing string literals** (e.g., `border_set: { tl: "1" }` in a loop) is generally safe because the string content is identical and maps to the same interned value.~~
~~- **Do not** dynamically generate infinite unique strings for border characters.~~

**Current Best Practice**: Use custom border sets freely without memory concerns.
