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
