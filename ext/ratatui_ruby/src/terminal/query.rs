// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

//! Terminal query trait and implementations.
//!
//! This module provides a compiler-enforced interface for querying terminal state.
//! All queries go through `TerminalQuery` trait which has two implementations:
//! - `LiveTerminal`: Used outside draw, queries actual terminal
//! - `DrawSnapshot`: Used during draw, queries pre-captured snapshot

use ratatui::buffer::Cell;
use ratatui::layout::Rect;

/// All terminal queries MUST go through this trait.
/// Compiler enforces both implementations when adding new queries.
pub trait TerminalQuery {
    fn size(&self) -> Rect;
    fn viewport_area(&self) -> Rect;
    fn is_test_mode(&self) -> bool;
    fn cursor_position(&self) -> Option<(u16, u16)>;
    fn cell_at(&self, x: u16, y: u16) -> Option<Cell>;
}

/// Snapshot of terminal state captured before draw.
/// Answers queries during draw without accessing terminal.
#[derive(Clone)]
pub struct DrawSnapshot {
    pub size: Rect,
    pub viewport_area: Rect,
    pub is_test_mode: bool,
    pub cursor_position: Option<(u16, u16)>,
    pub buffer: Option<ratatui::buffer::Buffer>,
}

impl DrawSnapshot {
    /// Capture snapshot from a `TerminalWrapper`.
    pub fn capture(wrapper: &mut super::wrapper::TerminalWrapper) -> Self {
        match wrapper {
            super::wrapper::TerminalWrapper::Crossterm(t) => {
                let size = t.size().unwrap_or_default();
                let viewport = t.get_frame().area();
                Self {
                    size: Rect::new(0, 0, size.width, size.height),
                    viewport_area: viewport,
                    is_test_mode: false,
                    cursor_position: None,
                    buffer: None,
                }
            }
            super::wrapper::TerminalWrapper::Test(t) => {
                let size = t.size().unwrap_or_default();
                let viewport = t.get_frame().area();
                let cursor = t.get_cursor_position().ok().map(Into::into);
                let buffer = t.backend().buffer().clone();
                Self {
                    size: Rect::new(0, 0, size.width, size.height),
                    viewport_area: viewport,
                    is_test_mode: true,
                    cursor_position: cursor,
                    buffer: Some(buffer),
                }
            }
        }
    }
}

impl TerminalQuery for DrawSnapshot {
    fn size(&self) -> Rect {
        self.size
    }
    fn viewport_area(&self) -> Rect {
        self.viewport_area
    }
    fn is_test_mode(&self) -> bool {
        self.is_test_mode
    }
    fn cursor_position(&self) -> Option<(u16, u16)> {
        self.cursor_position
    }
    fn cell_at(&self, x: u16, y: u16) -> Option<Cell> {
        self.buffer.as_ref()?.cell((x, y)).cloned()
    }
}

/// Live queries against actual terminal (outside draw).
/// Uses interior mutability since ratatui's API requires &mut for some queries.
pub struct LiveTerminal<'a>(std::cell::RefCell<&'a mut super::wrapper::TerminalWrapper>);

impl<'a> LiveTerminal<'a> {
    pub fn new(wrapper: &'a mut super::wrapper::TerminalWrapper) -> Self {
        Self(std::cell::RefCell::new(wrapper))
    }
}

impl TerminalQuery for LiveTerminal<'_> {
    fn size(&self) -> Rect {
        match *self.0.borrow() {
            super::wrapper::TerminalWrapper::Crossterm(ref t) => {
                let s = t.size().unwrap_or_default();
                Rect::new(0, 0, s.width, s.height)
            }
            super::wrapper::TerminalWrapper::Test(ref t) => {
                let s = t.size().unwrap_or_default();
                Rect::new(0, 0, s.width, s.height)
            }
        }
    }

    fn viewport_area(&self) -> Rect {
        match *self.0.borrow_mut() {
            super::wrapper::TerminalWrapper::Crossterm(ref mut t) => t.get_frame().area(),
            super::wrapper::TerminalWrapper::Test(ref mut t) => t.get_frame().area(),
        }
    }
    fn is_test_mode(&self) -> bool {
        matches!(*self.0.borrow(), super::wrapper::TerminalWrapper::Test(_))
    }
    fn cursor_position(&self) -> Option<(u16, u16)> {
        match *self.0.borrow_mut() {
            super::wrapper::TerminalWrapper::Test(ref mut t) => {
                t.get_cursor_position().ok().map(Into::into)
            }
            super::wrapper::TerminalWrapper::Crossterm(_) => None,
        }
    }
    fn cell_at(&self, x: u16, y: u16) -> Option<Cell> {
        match &*self.0.borrow() {
            super::wrapper::TerminalWrapper::Test(t) => t.backend().buffer().cell((x, y)).cloned(),
            super::wrapper::TerminalWrapper::Crossterm(_) => None,
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    // Test: TerminalQuery trait can be implemented by a simple struct
    struct MockQuery {
        size: Rect,
    }

    impl TerminalQuery for MockQuery {
        fn size(&self) -> Rect {
            self.size
        }
        fn viewport_area(&self) -> Rect {
            Rect::default()
        }
        fn is_test_mode(&self) -> bool {
            false
        }
        fn cursor_position(&self) -> Option<(u16, u16)> {
            None
        }
        fn cell_at(&self, _x: u16, _y: u16) -> Option<Cell> {
            None
        }
    }

    #[test]
    fn test_trait_can_be_implemented() {
        let query = MockQuery {
            size: Rect::new(0, 0, 80, 24),
        };
        assert_eq!(query.size(), Rect::new(0, 0, 80, 24));
    }

    #[test]
    fn test_draw_snapshot_returns_size() {
        let snapshot = super::DrawSnapshot {
            size: Rect::new(0, 0, 120, 40),
            viewport_area: Rect::new(0, 0, 120, 40),
            is_test_mode: false,
            cursor_position: None,
            buffer: None,
        };
        assert_eq!(snapshot.size(), Rect::new(0, 0, 120, 40));
    }

    #[test]
    fn test_draw_snapshot_returns_viewport_area() {
        let snapshot = super::DrawSnapshot {
            size: Rect::new(0, 0, 120, 40),
            viewport_area: Rect::new(5, 10, 80, 20), // Different from size!
            is_test_mode: false,
            cursor_position: None,
            buffer: None,
        };
        // This should return the stored viewport_area, not Rect::default()
        assert_eq!(snapshot.viewport_area(), Rect::new(5, 10, 80, 20));
    }

    #[test]
    fn test_draw_snapshot_returns_is_test_mode() {
        let snapshot = super::DrawSnapshot {
            size: Rect::default(),
            viewport_area: Rect::default(),
            is_test_mode: true, // TRUE!
            cursor_position: None,
            buffer: None,
        };
        assert!(snapshot.is_test_mode());
    }

    #[test]
    fn test_draw_snapshot_returns_cursor_position() {
        let snapshot = super::DrawSnapshot {
            size: Rect::default(),
            viewport_area: Rect::default(),
            is_test_mode: false,
            cursor_position: Some((15, 20)), // Not None!
            buffer: None,
        };
        assert_eq!(snapshot.cursor_position(), Some((15, 20)));
    }

    #[test]
    fn test_draw_snapshot_returns_cell_at() {
        use ratatui::buffer::Buffer;

        // Create a buffer with a known cell
        let mut buffer = Buffer::empty(Rect::new(0, 0, 10, 10));
        buffer[(5, 5)].set_char('X');

        let snapshot = super::DrawSnapshot {
            size: Rect::new(0, 0, 10, 10),
            viewport_area: Rect::new(0, 0, 10, 10),
            is_test_mode: true,
            cursor_position: None,
            buffer: Some(buffer),
        };

        let cell = snapshot.cell_at(5, 5);
        assert!(cell.is_some());
        assert_eq!(cell.unwrap().symbol(), "X");
    }

    #[test]
    fn test_capture_from_terminal_wrapper() {
        use crate::terminal::TerminalWrapper;
        use ratatui::{backend::TestBackend, Terminal};

        let backend = TestBackend::new(80, 24);
        let terminal = Terminal::new(backend).unwrap();
        let mut wrapper = TerminalWrapper::Test(terminal);

        let snapshot = super::DrawSnapshot::capture(&mut wrapper);

        assert_eq!(snapshot.size(), Rect::new(0, 0, 80, 24));
        assert!(snapshot.is_test_mode());
    }

    #[test]
    fn test_live_terminal_exists() {
        use crate::terminal::TerminalWrapper;
        use ratatui::{backend::TestBackend, Terminal};

        let backend = TestBackend::new(80, 24);
        let terminal = Terminal::new(backend).unwrap();
        let mut wrapper = TerminalWrapper::Test(terminal);

        // LiveTerminal should exist and wrap a TerminalWrapper reference
        let _live = super::LiveTerminal::new(&mut wrapper);
    }

    #[test]
    fn test_live_terminal_returns_size() {
        use crate::terminal::TerminalWrapper;
        use ratatui::{backend::TestBackend, Terminal};

        let backend = TestBackend::new(100, 50);
        let terminal = Terminal::new(backend).unwrap();
        let mut wrapper = TerminalWrapper::Test(terminal);

        let live = super::LiveTerminal::new(&mut wrapper);
        // LiveTerminal must implement TerminalQuery
        let size = live.size();
        assert_eq!(size.width, 100);
        assert_eq!(size.height, 50);
    }

    #[test]
    fn test_live_terminal_returns_is_test_mode() {
        use crate::terminal::TerminalWrapper;
        use ratatui::{backend::TestBackend, Terminal};

        let backend = TestBackend::new(80, 24);
        let terminal = Terminal::new(backend).unwrap();
        let mut wrapper = TerminalWrapper::Test(terminal);

        let live = super::LiveTerminal::new(&mut wrapper);
        // TestBackend should return true for is_test_mode
        assert!(live.is_test_mode());
    }

    #[test]
    fn test_live_terminal_returns_viewport_area() {
        use crate::terminal::TerminalWrapper;
        use ratatui::{backend::TestBackend, Terminal};

        let backend = TestBackend::new(120, 40);
        let terminal = Terminal::new(backend).unwrap();
        let mut wrapper = TerminalWrapper::Test(terminal);

        let live = super::LiveTerminal::new(&mut wrapper);
        let viewport = live.viewport_area();
        // Viewport should match the terminal size for fullscreen mode
        assert_eq!(viewport.width, 120);
        assert_eq!(viewport.height, 40);
    }

    #[test]
    fn test_live_terminal_viewport_area_differs_from_size_for_inline() {
        use crate::terminal::TerminalWrapper;
        use ratatui::{backend::TestBackend, Terminal, Viewport};

        // Create terminal with inline viewport of height 5 in a 40-line terminal
        let backend = TestBackend::new(80, 40);
        let options = ratatui::TerminalOptions {
            viewport: Viewport::Inline(5),
        };
        let terminal = Terminal::with_options(backend, options).unwrap();
        let mut wrapper = TerminalWrapper::Test(terminal);

        let live = super::LiveTerminal::new(&mut wrapper);
        let size = live.size();
        let viewport = live.viewport_area();

        // Terminal size is 80x40
        assert_eq!(size.width, 80);
        assert_eq!(size.height, 40);

        // But viewport is only 5 lines high (inline mode)
        assert_eq!(viewport.width, 80);
        assert_eq!(viewport.height, 5);
    }
}
