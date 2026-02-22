// SPDX-FileCopyrightText: 2026 Kerrick Long <me@kerricklong.com>
// SPDX-License-Identifier: LGPL-3.0-or-later

use magnus::{prelude::*, Error, Value};

/// Creates a `TypeError` with context showing the actual value received.
///
/// Calls `inspect` on the Ruby value and includes it in the error message.
/// Long inspect strings (>200 chars) are truncated.
///
/// # Example error message
/// ```text
/// expected array for rows, got {:title=>"Processes", :header=>["Name", ...]}
/// ```
pub fn type_error_with_context(ruby: &magnus::Ruby, expected: &str, got: Value) -> Error {
    let inspect: String = got
        .funcall("inspect", ())
        .unwrap_or_else(|_| "<uninspectable>".to_string());
    let truncated = if inspect.len() > 200 {
        format!("{}...", &inspect[..200])
    } else {
        inspect
    };
    Error::new(
        ruby.exception_type_error(),
        format!("{expected}, got {truncated}"),
    )
}
