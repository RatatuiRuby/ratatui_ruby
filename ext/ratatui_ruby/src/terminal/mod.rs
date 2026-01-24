// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

//! Terminal management module.
//!
//! Provides thread-local terminal storage with safe accessors. Queries
//! during `draw()` callbacks return data from a pre-captured snapshot,
//! avoiding reentrancy issues with the terminal lock.

mod capabilities;
mod init;
mod mutations;
mod queries;
mod query;
mod storage;
mod wrapper;

pub use storage::{
    is_in_draw_mode, is_initialized, lend_for_draw, set_terminal, take_terminal, with_query,
    with_terminal_mut,
};
pub use wrapper::TerminalWrapper;

// Init/restore functions
pub use init::{
    get_terminal_size_instance, init_terminal, init_test_terminal, init_test_terminal_instance,
    restore_terminal,
};

// Query functions
pub use queries::{
    get_buffer_content, get_cell_at, get_cursor_position, get_terminal_area, get_terminal_size,
    get_viewport_type,
};

// Mutation functions
pub use mutations::{insert_before, resize_terminal, set_cursor_position};

// Capability detection
pub use capabilities::{
    available_color_count, force_color_output, supports_keyboard_enhancement, terminal_window_size,
};
