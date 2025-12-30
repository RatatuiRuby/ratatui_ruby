# Rust Safety Analysis

This document provides a safety audit of the `ratatui_ruby` Rust extension (`ext/ratatui_ruby`). The audit focuses on `unsafe` code usage and potential memory safety issues, particularly regarding the interaction between Ruby's garbage collector and Rust's ownership model.

## Executive Summary

The codebase generally follows safe Rust patterns, with usage of `magnus` ensuring safe interaction with the Ruby VM. The audit identified two categories of findings:
1.  ~~**Critical Safety Issue**~~ **Resolved**: The Use-After-Free (UAF) vulnerability involving `BufferWrapper` has been eliminated by switching to a declarative command buffer pattern.
2.  **Minor Unsafe Usage**: Repeated use of `unsafe { class.name() }` which should be validated or replaced.

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

### 2. Unsafe `class.name()` Usage

**Files**: `src/rendering.rs`, `src/widgets/*.rs`
**Severity**: Low

There are multiple occurrences of:
```rust
let class_name = unsafe { class.name() };
```

Magnus marks `RClass::name()` as unsafe. This typically implies that the returned value might not be rooted or has lifetime requirements tied to the Ruby VM state that are not automatically enforced by the type system.

**Recommendation**:
Verify if `class.inspect()` or a safe alternative exists, or confirm via Magnus documentation that this usage is safe in the context where the GIL is held (which it is). If it is safe, document the rationale in a comment next to the `unsafe` block.

### 3. Memory Leaks Check

**Files**: `src/widgets/chart.rs`, general usage
**Status**: **Clean**

The code generally relies on standard Rust vectors and Magnus's handle of Ruby objects.
- In `chart.rs`, `data_storage` is used to own the vector data for `Dataset` slices. This is a correct pattern to bridge Ruby arrays (which might move or GC) to longer-living Rust slices required by Ratatui widgets within the function scope. The vectors are dropped at the end of the function, preventing leaks.
- No manual `malloc`/`free` or `Box::leak` was observed.

## Conclusion

The extension is well-written. The previously critical `BufferWrapper` raw pointer handling has been replaced with a safe declarative command buffer pattern. The remaining `unsafe { class.name() }` usages are low-severity and follow standard Magnus patterns.
