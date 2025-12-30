# Rust Safety Analysis

This document provides a safety audit of the `ratatui_ruby` Rust extension (`ext/ratatui_ruby`). The audit focuses on `unsafe` code usage and potential memory safety issues, particularly regarding the interaction between Ruby's garbage collector and Rust's ownership model.

## Executive Summary

The codebase generally follows safe Rust patterns, with usage of `magnus` ensuring safe interaction with the Ruby VM. However, there are two categories of findings:
1.  **Critical Safety Issue**: A potential Use-After-Free (UAF) vulnerability involving `BufferWrapper`.
2.  **Minor Unsafe Usage**: Repeated use of `unsafe { class.name() }` which should be validated or replaced.

## Detailed Findings

### 1. `BufferWrapper` Use-After-Free Vulnerability

**File**: `src/buffer.rs`, `src/rendering.rs`
**Severity**: **Critical**

The `BufferWrapper` struct holds a raw pointer to a `ratatui::buffer::Buffer`:

```rust
pub struct BufferWrapper {
    ptr: *mut Buffer,
}
unsafe impl Send for BufferWrapper {}
```

This wrapper is created in `src/rendering.rs` inside the `draw` loop, where `Frame` borrows the buffer from the terminal backend. The wrapper is then passed to Ruby code via `node.render(area, wrapper)`.

```rust
// src/rendering.rs
let wrapper = BufferWrapper::new(frame.buffer_mut());
// ...
node.funcall::<_, _, Value>("render", (ruby_area, wrapper_obj))?;
```

**The Issue**:
The `BufferWrapper` structure does not enforce any lifetime constraints on the underlying `Buffer`. If the Ruby code were to store the `BufferWrapper` object (e.g., in a global variable or instance variable) and access it after the `draw` function has returned, the `ptr` would point to invalid memory (stack memory or a dropped buffer from the previous frame). Accessing it would lead to undefined behavior (segfault or memory corruption).

**Recommendation**:
The `BufferWrapper` functionality needs to be safer.
1.  **Invalidation**: Add a mechanism to invalidate the wrapper after the `render` call returns. The wrapper could hold a flag or shared state that marks it as "closed", and all methods (`set_string`, `set_cell`) would check this flag before dereferencing the pointer.
2.  **Review Usage**: Ensure that documentation explicitly warns against storing the `Buffer` object. However, documentation is not a safety guarantee.

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

The extension is mostly well-written but the `BufferWrapper` raw pointer handling presents a significant safety risk that should be addressed to prevent potential crashes in complex Ruby applications.
