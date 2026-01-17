// SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
//
// SPDX-License-Identifier: AGPL-3.0-or-later

// Instance-based terminal initialization (Proposal 1 from terminal.md)
// Returns terminal ID for Ruby to store
#[allow(clippy::needless_pass_by_value)]
pub fn init_test_terminal_instance(
    width: u16,
    height: u16,
    viewport_type: String,
    viewport_height: Option<u16>,
) -> Result<u64, Error> {
    let ruby = magnus::Ruby::get().unwrap();
    let backend = TestBackend::new(width, height);
    let module = ruby.define_module("RatatuiRuby")?;
    let error_base = module.const_get::<_, magnus::RClass>("Error")?;
    let error_class = error_base.const_get("Terminal")?;

    // Parse viewport type
    let viewport = match viewport_type.as_ref() {
        "inline" => {
            let vp_height = viewport_height.unwrap_or(height);
            Viewport::Inline(vp_height)
        }
        _ => Viewport::Fullscreen,
    };

    let options = TerminalOptions { viewport };
    let terminal = Terminal::with_options(backend, options)
        .map_err(|e| Error::new(error_class, e.to_string()))?;

    // Generate unique ID and store instance
    let id = NEXT_TERMINAL_ID.fetch_add(1, Ordering::SeqCst);
    let mut instances = TERMINAL_INSTANCES.lock().unwrap();
    instances.insert(id, TerminalWrapper::Test(terminal));

    Ok(id)
}
