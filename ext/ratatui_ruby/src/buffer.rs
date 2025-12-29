// SPDX-FileCopyrightText: 2025 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: AGPL-3.0-or-later

use crate::style::parse_style;
use magnus::prelude::*;
use magnus::{Error, Ruby, Value};
use ratatui::buffer::Buffer;
use std::ffi::CStr;

pub struct BufferWrapper {
    ptr: *mut Buffer,
}

unsafe impl Send for BufferWrapper {}

impl BufferWrapper {
    pub fn new(buffer: &mut Buffer) -> Self {
        Self { ptr: buffer }
    }

    pub fn set_string(&self, x: u16, y: u16, string: String, style_val: Value) -> Result<(), Error> {
        let style = parse_style(style_val)?;
        let buffer = unsafe { &mut *self.ptr };
        buffer.set_string(x, y, string, style);
        Ok(())
    }

    pub fn set_cell(&self, x: u16, y: u16, cell_val: Value) -> Result<(), Error> {
        let buffer = unsafe { &mut *self.ptr };
        let area = buffer.area;

        if x >= area.x + area.width || y >= area.y + area.height {
             return Ok(());
        }

        let symbol: String = cell_val.funcall("char", ())?;
        let fg_val: Value = cell_val.funcall("fg", ())?;
        let bg_val: Value = cell_val.funcall("bg", ())?;
        let modifiers_val: Value = cell_val.funcall("modifiers", ())?;

        // Construct a temporary Style to reuse parse_style logic if possible, 
        // or just parse manually since Cell structure in Ruby assumes separate fields.
        // Actually, we can reuse `parse_style` if we construct a hash, but that's expensive.
        // Let's just create a default style and apply overrides.
        
        // Better: The user passed a RatatuiRuby::Cell. 
        // We should probably rely on helper to extract Style from it?
        // Or just map fields.

        let mut style = ratatui::style::Style::default();
        
        if !fg_val.is_nil() {
             if let Some(color) = crate::style::parse_color_value(fg_val)? {
                 style = style.fg(color);
             }
        }
        if !bg_val.is_nil() {
             if let Some(color) = crate::style::parse_color_value(bg_val)? {
                 style = style.bg(color);
             }
        }
        
        if let Some(mods_array) = magnus::RArray::from_value(modifiers_val) {
             for i in 0..mods_array.len() {
                 let mod_str: String = mods_array.entry::<String>(i as isize)?;
                 if let Some(modifier) = crate::style::parse_modifier_str(&mod_str) {
                     style = style.add_modifier(modifier);
                 }
             }
        }

        if let Some(cell) = buffer.cell_mut((x, y)) {
            cell.set_symbol(&symbol).set_style(style);
        }

        Ok(())
    }

    pub fn area(&self) -> Value {
        let ruby = Ruby::get().unwrap();
        let module = ruby.define_module("RatatuiRuby").unwrap();
        let class = module.const_get::<_, magnus::RClass>("Rect").unwrap();
        let buffer = unsafe { &*self.ptr };
        let area = buffer.area;
        class.funcall("new", (area.x, area.y, area.width, area.height)).unwrap()
    }
}

unsafe impl magnus::TypedData for BufferWrapper {
    fn class(ruby: &Ruby) -> magnus::RClass {
        ruby.define_module("RatatuiRuby")
            .and_then(|m| m.const_get("Buffer"))
            .unwrap()
    }

    fn data_type() -> &'static magnus::DataType {
        static DATA_TYPE: magnus::DataType = magnus::DataType::builder::<BufferWrapper>(unsafe {
            CStr::from_bytes_with_nul_unchecked(b"RatatuiRuby::Buffer\0")
        })
        .build();
        &DATA_TYPE
    }
}

impl magnus::DataTypeFunctions for BufferWrapper {}
