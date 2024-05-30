use std::path::PathBuf;

use librapidflux::source_code as lib;
use pyo3::prelude::*;

use crate::register_submodule_functions;

#[pyfunction]
fn register(path: PathBuf, source_code: String) {
    lib::register(path, source_code);
}

/// Retrieve source code from a path.
///
/// # Caution
///
/// This operation can be expensive as it copies the whole source code.
#[pyfunction]
#[allow(clippy::needless_pass_by_value)]
fn retrieve(path: PathBuf) -> Option<String> {
    lib::retrieve(&path).map(|s| s.to_string())
}

register_submodule_functions!(source_code, [register, retrieve]);
