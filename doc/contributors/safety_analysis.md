# Rust Safety Analysis

This document provides a safety audit of the `ratatui_ruby` Rust extension (`ext/ratatui_ruby`). The audit focuses on `unsafe` code usage and potential memory safety issues, particularly regarding the interaction between Ruby's garbage collector and Rust's ownership model.

## Executive Summary

The codebase generally follows safe Rust patterns, with usage of `magnus` ensuring safe interaction with the Ruby VM. The audit identified two categories of findings, both now resolved:
1.  ~~**Critical Safety Issue**~~ **Resolved**: The Use-After-Free (UAF) vulnerability involving `BufferWrapper` has been eliminated by switching to a declarative command buffer pattern.
2.  ~~**Minor Unsafe Usage**~~ **Resolved**: Repeated use of `unsafe { class.name() }` now immediately converts to owned strings to avoid GC-related memory safety issues.

## Detailed Findings

### 1. `BufferWrapper` Use-After-Free Vulnerability

**File**: ~~`src/buffer.rs`~~, `src/rendering.rs`
**Severity**: ~~**Critical**~~ **Resolved**

~~The `BufferWrapper` struct holds a raw pointer to a `ratatui::buffer::Buffer`:~~

**Resolution**: The `BufferWrapper` was completely removed. Custom widgets now use a **declarative command buffer pattern**:

```ruby
# Old (REMOVED):
def render(area, buffer)
  buffer.set_string(0, 0, "Hi", {fg: :red})
end

# New:
def render(area)
  [RatatuiRuby::Draw.string(0, 0, "Hi", {fg: :red})]
end
```

Ruby widgets return an array of `Draw::StringCmd` and `Draw::CellCmd` objects. Rust processes these commands internally without ever exposing buffer pointers to Ruby code. This eliminates the category of use-after-free bugs entirely.

**Benefits**:
- **Safety**: No raw pointers exposed to Ruby—impossible to cause segfaults.
- **Testability**: Widgets can be unit tested by asserting on the returned array.
- **Consistency**: Aligns with the rest of the library's "Data In, Data Out" architecture.

### 2. ~~Unsafe `class.name()` Usage~~ (Resolved)

**Files**: `src/rendering.rs`, `src/widgets/*.rs`
**Severity**: ~~Low~~ **Resolved**

~~There are multiple occurrences of:~~
```rust
let class_name = unsafe { class.name() };
```

**Resolution**: All occurrences now immediately convert to an owned `String`:

```rust
// SAFETY: Immediate conversion to owned avoids GC-unsafe borrowed reference.
let class_name = unsafe { class.name() }.into_owned();
```

Magnus marks `RClass::name()` as unsafe because it returns a `Cow<str>` backed by Ruby-managed memory. By calling `.into_owned()`, we copy the string data into Rust-owned memory before any subsequent Ruby calls that might trigger GC. This eliminates any risk of use-after-free.

### 3. Memory Leaks Check

**Files**: `src/widgets/chart.rs`, general usage
**Status**: **Clean**

The code generally relies on standard Rust vectors and Magnus's handle of Ruby objects.
- In `chart.rs`, `data_storage` is used to own the vector data for `Dataset` slices. This is a correct pattern to bridge Ruby arrays (which might move or GC) to longer-living Rust slices required by Ratatui widgets within the function scope. The vectors are dropped at the end of the function, preventing leaks.
- ~~The `style.rs` string interner used `Box::leak` for custom border characters.~~ Replaced with render-scoped arena allocation (`bumpalo::Bump`)—no permanent leaks.

## Conclusion

The extension is well-written with no remaining safety concerns. Both previously-identified issues have been resolved:
- The `BufferWrapper` raw pointer handling has been replaced with a safe declarative command buffer pattern.
- All `unsafe { class.name() }` usages now immediately convert to owned strings, eliminating GC-related memory concerns.
