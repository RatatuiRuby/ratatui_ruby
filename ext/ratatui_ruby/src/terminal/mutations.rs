// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

//! Terminal mutation functions (write operations).

use magnus::{Error, Module};

use super::TerminalWrapper;

pub fn insert_before(height: u16, widget: magnus::Value) -> Result<(), Error> {
    let ruby = magnus::Ruby::get().unwrap();

    // with_terminal_mut returns None during draw mode, so we handle that case
    crate::terminal::with_terminal_mut(|wrapper| {
        let module = ruby.define_module("RatatuiRuby").unwrap();
        let error_base = module.const_get::<_, magnus::RClass>("Error").unwrap();
        let error_class = error_base.const_get("Terminal").unwrap();

        match wrapper {
            TerminalWrapper::Crossterm(term) => {
                // Capture rendering error since closure can't return Result
                let mut render_error: Option<String> = None;

                let result = term.insert_before(height, |buf| {
                    let area = buf.area();
                    let area_copy = *area; // Copy rect before closure capture

                    // Render widget to buffer using centralized dispatch
                    let render_result =
                        crate::rendering::render_widget_to_buffer(buf, area_copy, widget);

                    if let Err(e) = render_result {
                        render_error = Some(e.to_string());
                    }
                });

                // Handle insert_before error
                result.map_err(|e| Error::new(error_class, e.to_string()))?;

                // Handle rendering error
                if let Some(err_msg) = render_error {
                    return Err(Error::new(error_class, err_msg));
                }
            }
            TerminalWrapper::Test(term) => {
                // Capture rendering error since closure can't return Result
                let mut render_error: Option<String> = None;

                let result = term.insert_before(height, |buf| {
                    let area = buf.area();
                    let area_copy = *area; // Copy rect before closure capture

                    // Render widget to buffer using centralized dispatch
                    let render_result =
                        crate::rendering::render_widget_to_buffer(buf, area_copy, widget);

                    if let Err(e) = render_result {
                        render_error = Some(e.to_string());
                    }
                });

                // Handle insert_before error
                result.map_err(|e| Error::new(error_class, e.to_string()))?;

                // Handle rendering error
                if let Some(err_msg) = render_error {
                    return Err(Error::new(error_class, err_msg));
                }
            }
        }
        Ok(())
    })
    .unwrap_or_else(|| {
        // During draw or terminal not initialized
        let module = ruby.define_module("RatatuiRuby").unwrap();
        let error_base = module.const_get::<_, magnus::RClass>("Error").unwrap();
        if crate::terminal::is_in_draw_mode() {
            let error_class = error_base.const_get("Invariant").unwrap();
            Err(Error::new(
                error_class,
                "insert_before cannot be called during draw",
            ))
        } else {
            let error_class = error_base.const_get("Terminal").unwrap();
            Err(Error::new(error_class, "Terminal not initialized"))
        }
    })
}

pub fn set_cursor_position(x: u16, y: u16) -> Result<(), Error> {
    let ruby = magnus::Ruby::get().unwrap();

    crate::terminal::with_terminal_mut(|wrapper| {
        let module = ruby.define_module("RatatuiRuby").unwrap();
        let error_base = module.const_get::<_, magnus::RClass>("Error").unwrap();
        let error_class = error_base.const_get("Terminal").unwrap();

        match wrapper {
            TerminalWrapper::Crossterm(term) => {
                term.set_cursor_position((x, y))
                    .map_err(|e| Error::new(error_class, e.to_string()))?;
            }
            TerminalWrapper::Test(term) => {
                term.set_cursor_position((x, y))
                    .map_err(|e| Error::new(error_class, e.to_string()))?;
            }
        }
        Ok(())
    })
    .unwrap_or_else(|| {
        let module = ruby.define_module("RatatuiRuby").unwrap();
        let error_base = module.const_get::<_, magnus::RClass>("Error").unwrap();
        if crate::terminal::is_in_draw_mode() {
            let error_class = error_base.const_get("Invariant").unwrap();
            Err(Error::new(
                error_class,
                "set_cursor_position cannot be called during draw",
            ))
        } else {
            let error_class = error_base.const_get("Terminal").unwrap();
            Err(Error::new(error_class, "Terminal is not initialized"))
        }
    })
}

pub fn resize_terminal(width: u16, height: u16) -> Result<(), Error> {
    let ruby = magnus::Ruby::get().unwrap();

    crate::terminal::with_terminal_mut(|wrapper| {
        match wrapper {
            TerminalWrapper::Crossterm(_) => {}
            TerminalWrapper::Test(terminal) => {
                terminal.backend_mut().resize(width, height);
                if let Err(e) = terminal.resize(ratatui::layout::Rect::new(0, 0, width, height)) {
                    let module = ruby.define_module("RatatuiRuby").unwrap();
                    let error_base = module.const_get::<_, magnus::RClass>("Error").unwrap();
                    let error_class = error_base.const_get("Terminal").unwrap();
                    return Err(Error::new(error_class, e.to_string()));
                }
            }
        }
        Ok(())
    })
    .unwrap_or_else(|| {
        let module = ruby.define_module("RatatuiRuby").unwrap();
        let error_base = module.const_get::<_, magnus::RClass>("Error").unwrap();
        if crate::terminal::is_in_draw_mode() {
            let error_class = error_base.const_get("Invariant").unwrap();
            Err(Error::new(
                error_class,
                "resize_terminal cannot be called during draw",
            ))
        } else {
            // No terminal initialized is OK for resize - just no-op
            Ok(())
        }
    })
}
