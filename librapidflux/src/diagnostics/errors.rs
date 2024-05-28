use std::{
    fmt::{Debug, Display},
    fs,
    io::{self, Write},
    path::PathBuf,
    str::FromStr,
    sync::atomic::{AtomicU64, Ordering},
};

#[cfg(not(test))]
use annotate_snippets::renderer::{Color, RgbColor, Style};
use serde::{Deserialize, Serialize};

use super::Location;

#[cfg(not(test))]
const RENDERER: annotate_snippets::Renderer = annotate_snippets::Renderer::styled()
    .error(Style::new().fg_color(Some(Color::Rgb(RgbColor(225, 0, 0)))))
    .help(Style::new().fg_color(Some(Color::Rgb(RgbColor(0, 80, 200)))))
    .note(Style::new().fg_color(Some(Color::Rgb(RgbColor(180, 180, 0)))));

#[cfg(test)]
const RENDERER: annotate_snippets::Renderer = annotate_snippets::Renderer::plain();

static MAX_ERROR_COUNT: AtomicU64 = AtomicU64::new(0);
static ERROR_COUNT: AtomicU64 = AtomicU64::new(0);

#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize, Default)]
pub enum Severity {
    #[default]
    Info,
    Warning,
    Error,
    Help,
    Note,
}

impl Display for Severity {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Severity::Info => write!(f, "info"),
            Severity::Warning => write!(f, "warning"),
            Severity::Error => write!(f, "error"),
            Severity::Help => write!(f, "help"),
            Severity::Note => write!(f, "note"),
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub struct Annotation {
    label: Option<String>,
    severity: Severity,
    location: Location,
}

impl Display for Annotation {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "{}: {}: {}",
            self.location(),
            self.severity,
            self.label.as_ref().map_or("", std::string::String::as_str)
        )
    }
}

impl Annotation {
    pub fn new(label: Option<String>, severity: Severity, location: Location) -> Self {
        Self {
            label,
            severity,
            location,
        }
    }

    pub fn severity(&self) -> Severity {
        self.severity
    }

    pub fn location(&self) -> &Location {
        &self.location
    }

    pub fn label(&self) -> Option<&str> {
        self.label.as_deref()
    }

    fn to_annotation<'a>(&'a self, source: &'a str) -> annotate_snippets::Annotation<'a> {
        let file_offset = self.location.to_file_offset(source);
        let annotation = match self.severity {
            Severity::Info => annotate_snippets::Level::Info.span(file_offset),
            Severity::Warning => annotate_snippets::Level::Warning.span(file_offset),
            Severity::Error => annotate_snippets::Level::Error.span(file_offset),
            Severity::Help => annotate_snippets::Level::Help.span(file_offset),
            Severity::Note => annotate_snippets::Level::Note.span(file_offset),
        };

        if let Some(label) = self.label() {
            annotation.label(label)
        } else {
            annotation
        }
    }
}

#[derive(Clone, Debug, Serialize, Deserialize, PartialEq, Default)]
pub struct ErrorEntry {
    message: String,
    severity: Severity,
    location: Option<Location>,
    annotations: Vec<Annotation>,
}

impl Display for ErrorEntry {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "{}{}: {}{}{}",
            self.location().map_or(String::new(), |l| format!("{l}: ")),
            self.severity,
            self.message,
            if self.annotations().iter().any(|a| a.label().is_some()) {
                "\n"
            } else {
                ""
            },
            self.annotations()
                .iter()
                .filter_map(|a| a.label().map(|_| a.to_string()))
                .collect::<Vec<String>>()
                .join("\n")
        )
    }
}

impl ErrorEntry {
    pub fn new(
        message: String,
        severity: Severity,
        location: Option<Location>,
        annotations: Vec<Annotation>,
    ) -> Self {
        Self {
            message,
            severity,
            location,
            annotations,
        }
    }

    pub fn message(&self) -> &str {
        &self.message
    }

    pub fn severity(&self) -> Severity {
        self.severity
    }

    pub fn location(&self) -> Option<&Location> {
        self.location.as_ref()
    }

    pub fn annotations(&self) -> &[Annotation] {
        &self.annotations
    }

    /// Convert an error entry to an `annotate_snippets`' snippet message
    ///
    /// # Parameters
    /// - `source`: Source code string that caused the error
    pub(crate) fn to_message_mut<'src>(
        &'src mut self,
        source: &'src str,
    ) -> Option<annotate_snippets::Message<'src>> {
        let message = match self.severity {
            Severity::Info => annotate_snippets::Level::Info.title(&self.message),
            Severity::Warning => annotate_snippets::Level::Warning.title(&self.message),
            Severity::Error => annotate_snippets::Level::Error.title(&self.message),
            Severity::Help => annotate_snippets::Level::Help.title(&self.message),
            Severity::Note => annotate_snippets::Level::Note.title(&self.message),
        };

        if let Some(location) = self.location.as_ref() {
            let default_annotation = Annotation::new(None, self.severity, location.clone());

            // Add squiggles below the actual error. Without this, the user won't be able to
            // see the error location (e.g. `foo.rflx:3:4`).
            self.annotations.insert(0, default_annotation);
        }

        if self.annotations.is_empty()
            || source.is_empty()
            || self.location.as_ref().is_some_and(|l| {
                l.source
                    .as_ref()
                    .is_some_and(|s| s == &PathBuf::from_str("<stdin>").expect("unreachable"))
            })
        {
            return None;
        }

        let snippet = annotate_snippets::Snippet::source(source)
            .fold(true)
            .annotations(self.annotations.iter().map(|a| a.to_annotation(source)));

        Some(message.snippet(
            if let Some(Some(source_file)) = self.location.as_ref().map(|l| l.source.as_ref()) {
                snippet.origin(source_file.to_str().unwrap_or("<unknown>"))
            } else {
                snippet
            },
        ))
    }
}

#[derive(Clone, Serialize, Deserialize, Default, PartialEq)]
pub struct RapidFluxError {
    entries: Vec<ErrorEntry>,
}

impl Debug for RapidFluxError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(f, "{:?}", self.entries)
    }
}

impl Display for RapidFluxError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "{}",
            self.entries
                .iter()
                .map(std::string::ToString::to_string)
                .collect::<Vec<String>>()
                .join("\n")
        )
    }
}

impl From<Vec<ErrorEntry>> for RapidFluxError {
    fn from(entries: Vec<ErrorEntry>) -> Self {
        Self { entries }
    }
}

impl RapidFluxError {
    /// Push a new error entry.
    ///
    /// Return true if the push succeeded or false otherwise.
    /// A failed push indicates that we've reached the maximum number of error messages
    /// and we should stop the execution.
    pub fn push(&mut self, entry: ErrorEntry) -> bool {
        self.entries.push(entry);
        ERROR_COUNT.fetch_add(1, Ordering::Relaxed);

        Self::error_count_below_threshold()
    }

    /// Extend error collection from an iterator. Takes the entries' ownership.
    ///
    /// Return value is the same as for the `push` method.
    pub fn extend<T: IntoIterator<Item = ErrorEntry>>(&mut self, entries: T) -> bool {
        let entries_count = self.entries.len();
        self.entries.extend(entries);

        let added_entries_count = (self.entries.len() - entries_count) as u64;
        debug_assert!(added_entries_count <= self.entries.len() as u64);
        ERROR_COUNT.fetch_add(added_entries_count, Ordering::Relaxed);
        Self::error_count_below_threshold()
    }

    pub fn clear(&mut self) {
        self.entries.clear();
    }

    pub fn entries(&self) -> &[ErrorEntry] {
        &self.entries
    }

    pub fn set_max_error(max: u64) {
        MAX_ERROR_COUNT.store(max, Ordering::Relaxed);
    }

    #[cfg(debug_assertions)]
    pub fn reset_counts() {
        ERROR_COUNT.store(0, Ordering::Relaxed);
        MAX_ERROR_COUNT.store(0, Ordering::Relaxed);
    }

    /// Print all messages to `stdout`
    ///
    /// # Errors
    /// Source code needs to be retrieved and error message displayed. This function
    /// might return an `io::Error` if any io operation failed.
    pub fn print_messages<T: Write>(&mut self, stream: &mut T) -> io::Result<()> {
        for entry in &mut self.entries {
            let source_code =
                if let Some(Some(source_path)) = entry.location.as_ref().map(|l| &l.source) {
                    if source_path.to_str().unwrap_or_default() == "<stdin>" {
                        String::new()
                    } else {
                        // TODO(eng/recordflux/RecordFlux#1602): Use stored source code instead of reading file
                        fs::read_to_string(source_path)?
                    }
                } else {
                    String::new()
                };

            match entry.to_message_mut(&source_code) {
                Some(msg) => writeln!(stream, "{}", RENDERER.render(msg))?,
                None => writeln!(stream, "{entry}")?,
            }
        }

        Ok(())
    }

    pub fn has_errors(&self) -> bool {
        self.entries.iter().any(|e| e.severity == Severity::Error)
    }

    fn error_count_below_threshold() -> bool {
        ERROR_COUNT.load(Ordering::Relaxed) < MAX_ERROR_COUNT.load(Ordering::Relaxed)
            || MAX_ERROR_COUNT.load(Ordering::Relaxed) == 0
    }
}

#[cfg(test)]
mod tests {
    use std::{io, path::PathBuf, str::FromStr};

    use indoc::indoc;
    use pretty_assertions::assert_eq;
    use rstest::rstest;
    use serial_test::{parallel, serial};

    use crate::diagnostics::{ErrorEntry, FilePosition, Location};

    use super::{Annotation, RapidFluxError, Severity};

    #[rstest]
    #[case::severity_note(Severity::Note, "note")]
    #[case::severity_info(Severity::Info, "info")]
    #[case::severity_warning(Severity::Warning, "warning")]
    #[case::severity_error(Severity::Error, "error")]
    #[case::severity_help(Severity::Help, "help")]
    fn test_severity_display(#[case] severity: Severity, #[case] expected_str: &str) {
        assert_eq!(severity.to_string(), expected_str);
    }

    #[rstest]
    #[case::annotation_without_label(
        Annotation::new(
            None,
            Severity::Error,
            Location {
                source: Some(PathBuf::from_str("foo.rflx")
                    .expect("failed to create source path")),
                start: FilePosition::new(1, 1),
                end: None,
            },
        ),
        "foo.rflx:1:1: error: "
    )]
    #[case::annotation_with_source_path(
        Annotation::new(
            Some("some. terrible. error".to_string()),
            Severity::Error,
            Location {
                source: Some(PathBuf::from_str("foo.rflx")
                    .expect("failed to create source path")),
                start: FilePosition::new(1, 1),
                end: None,
            },
        ),
        "foo.rflx:1:1: error: some. terrible. error"
    )]
    #[case::annotation_without_source_path(
        Annotation::new(
            Some("some. terrible. error".to_string()),
            Severity::Error,
            Location {
                source: None,
                start: FilePosition::new(1, 1),
                end: None,
            },
        ),
        "<stdin>:1:1: error: some. terrible. error"
    )]
    fn test_annotation_display(#[case] annotation: Annotation, #[case] expected_str: &str) {
        assert_eq!(annotation.to_string().as_str(), expected_str,);
    }

    #[rstest]
    #[case::annotation_severity_note(Severity::Note, "Note", None)]
    #[case::annotation_severity_info(Severity::Info, "Info", None)]
    #[case::annotation_severity_warn(Severity::Warning, "Warning", None)]
    #[case::annotation_severity_error(Severity::Error, "Error", None)]
    #[case::annotation_severity_help(Severity::Help, "Help", None)]
    #[case::annotation_severity_error_with_label(
        Severity::Error,
        "Error",
        Some("label".to_string())
    )]
    fn test_annotation_to_annotate_snippets(
        #[case] severity: Severity,
        #[case] severity_str: &str,
        #[case] label: Option<String>,
    ) {
        let annotation = Annotation::new(
            label.clone(),
            severity,
            Location {
                source: Some(PathBuf::from_str("foo.rflx").expect("failed to create source path")),
                start: FilePosition::new(1, 1),
                end: Some(FilePosition::new(1, 5)),
            },
        );
        let as_annotation = annotation.to_annotation("some amazing source code");
        assert_eq!(
            format!("{as_annotation:?}"),
            format!(
                "Annotation {{ range: 0..4, label: {}, level: {severity_str} }}",
                match label {
                    Some(str) => format!("Some(\"{str}\")"),
                    None => "None".to_string(),
                }
            )
        );
    }

    #[test]
    fn test_annotation_creation() {
        let annotation = Annotation::new(
            Some("label".to_string()),
            Severity::Error,
            Location {
                source: None,
                start: FilePosition::new(1, 1),
                end: None,
            },
        );

        assert_eq!(
            annotation.location(),
            &Location {
                source: None,
                start: FilePosition::new(1, 1),
                end: None,
            }
        );

        assert_eq!(annotation.severity(), Severity::Error);
        assert_eq!(annotation.label().expect("should be present"), "label");
    }

    #[test]
    fn test_error_entry_creation() {
        let error_entry = ErrorEntry::new(
            "Some terrible error".to_string(),
            Severity::Error,
            None,
            vec![Annotation::new(
                Some("Look here".to_string()),
                Severity::Info,
                Location {
                    source: None,
                    start: FilePosition::new(1, 2),
                    end: Some(FilePosition::new(3, 4)),
                },
            )],
        );

        assert_eq!(error_entry.severity(), Severity::Error);
        assert_eq!(error_entry.message(), "Some terrible error");
        assert!(error_entry.location().is_none());
        assert_eq!(
            error_entry.annotations(),
            vec![Annotation::new(
                Some("Look here".to_string()),
                Severity::Info,
                Location {
                    source: None,
                    start: FilePosition::new(1, 2),
                    end: Some(FilePosition::new(3, 4)),
                },
            )]
        );
    }

    #[rstest]
    #[case::error_entry_no_location(
        ErrorEntry::new(
            "Some terrible error".to_string(),
            Severity::Error,
            None,
            Vec::new(),
        ),
        "Some cool source code",
        "error: Some terrible error",
    )]
    #[case::error_entry_severity_info(
        ErrorEntry::new(
            "info".to_string(),
            Severity::Info,
            None,
            Vec::new(),
        ),
        "",
        "info: info",
    )]
    #[case::error_entry_severity_help(
        ErrorEntry::new(
            "help".to_string(),
            Severity::Help,
            None,
            Vec::new(),
        ),
        "",
        "help: help",
    )]
    #[case::error_entry_severity_warning(
        ErrorEntry::new(
            "warning".to_string(),
            Severity::Warning,
            None,
            Vec::new(),
        ),
        "",
        "warning: warning",
    )]
    #[case::error_entry_severity_note(
        ErrorEntry::new(
            "note".to_string(),
            Severity::Note,
            None,
            Vec::new(),
        ),
        "",
        "note: note",
    )]
    #[case::error_entry_with_source_file(
        ErrorEntry::new(
            "Some terrible error".to_string(),
            Severity::Error,
            Some(Location {
                source: None,
                start: FilePosition::new(1, 1),
                end: Some(FilePosition::new(1, 8)),
            }),
            Vec::new(),
        ),
        "package Test is end Test;",
        indoc! {
            r"error: Some terrible error
                |
              1 | package Test is end Test;
                | ^^^^^^^
                |"
        },
    )]
    #[case::error_entry_stdin(
        ErrorEntry::new(
            "Some terrible error".to_string(),
            Severity::Error,
            Some(Location {
                source: Some("<stdin>".into()),
                start: FilePosition::new(1, 1),
                end: Some(FilePosition::new(1, 8)),
            }),
            Vec::new(),
        ),
        "package Test is end Test;",
        "<stdin>:1:1: error: Some terrible error",
    )]
    #[case::error_entry_with_location_and_source_file(
        ErrorEntry::new(
            "Some terrible error".to_string(),
            Severity::Error,
            Some(Location {
                source: Some(PathBuf::from_str("test.rflx").expect("failed to create path")),
                start: FilePosition::new(1, 1),
                end: Some(FilePosition::new(1, 8)),
            }),
            Vec::new(),
        ),
        "package Test is end Test;",
        indoc! {
            r"error: Some terrible error
               --> test.rflx:1:1
                |
              1 | package Test is end Test;
                | ^^^^^^^
                |"
        },
    )]
    #[case::error_entry_with_location_and_source_file(
        ErrorEntry::new(
            "Some terrible error".to_string(),
            Severity::Error,
            Some(Location {
                source: Some(PathBuf::from_str("test.rflx").expect("failed to create path")),
                start: FilePosition::new(1, 1),
                end: Some(FilePosition::new(1, 8)),
            }),
            vec![
                Annotation::new(
                    Some("some help".to_string()),
                    Severity::Help,
                    Location {
                        source: None,
                        start: FilePosition::new(2, 1),
                        end: Some(FilePosition::new(2, 4)),
                    },
            )
        ]),
        indoc! {
            r"package Test is
              end Test;"
        },
        indoc! {
            r"error: Some terrible error
               --> test.rflx:1:1
                |
              1 | package Test is
                | ^^^^^^^
              2 | end Test;
                | --- help: some help
                |"
        },
    )]
    fn test_error_entry_to_message(
        #[case] mut entry: ErrorEntry,
        #[case] source_code: &str,
        #[case] expected_str: &str,
    ) {
        use crate::diagnostics::errors::RENDERER;

        match entry.to_message_mut(source_code) {
            Some(msg) => {
                let str = RENDERER.render(msg).to_string();
                assert_eq!(str.as_str(), expected_str);
            }
            None => assert_eq!(entry.to_string().as_str(), expected_str),
        };
    }

    #[rstest]
    #[case::error_entry_with_location_no_source(
        ErrorEntry::new(
            "Some terrible error".to_string(),
            Severity::Error,
            Some(Location {
                source: None,
                start: FilePosition::new(1, 1),
                end: Some(FilePosition::new(1, 8)),
            }),
            Vec::new(),
        ),
        "<stdin>:1:1: error: Some terrible error"
    )]
    #[case::error_entry_with_location_and_source(
        ErrorEntry::new(
            "Some terrible error".to_string(),
            Severity::Error,
            Some(Location {
                source: Some(PathBuf::from_str("foo.rflx").expect("failed to create path")),
                start: FilePosition::new(1, 1),
                end: Some(FilePosition::new(1, 8)),
            }),
            Vec::new(),
        ),
        "foo.rflx:1:1: error: Some terrible error"
    )]
    #[case::error_entry_with_annotations(
        ErrorEntry::new(
            "Some terrible error".to_string(),
            Severity::Error,
            Some(Location {
                source: Some(PathBuf::from_str("foo.rflx").expect("failed to create path")),
                start: FilePosition::new(1, 1),
                end: Some(FilePosition::new(1, 8)),
            }),
            vec![
                Annotation {
                    severity: Severity::Info,
                    location: Location {
                        source: Some(PathBuf::from_str("foo.rflx").expect("failed to create path")),
                        start: FilePosition::new(1, 1),
                        end: Some(FilePosition::new(1, 8)),
                    },
                    label: Some("some label".to_string())
                }
            ],
        ),
        indoc! {
            r"foo.rflx:1:1: error: Some terrible error
              foo.rflx:1:1: info: some label"
        }
    )]
    fn test_error_entry_display(#[case] error_entry: ErrorEntry, #[case] expected_str: &str) {
        assert_eq!(error_entry.to_string().as_str(), expected_str);
    }

    #[test]
    fn test_rapid_flux_error_entries() {
        let error = RapidFluxError {
            entries: vec![ErrorEntry::new(
                "first".to_string(),
                Severity::Error,
                None,
                Vec::new(),
            )],
        };
        assert_eq!(
            error.entries(),
            vec![ErrorEntry::new(
                "first".to_string(),
                Severity::Error,
                None,
                Vec::new()
            )]
        );
    }

    #[rstest]
    #[case::errors(
        vec![
            ErrorEntry::new("okay".to_string(), Severity::Info, None, Vec::new()),
            ErrorEntry::new("ooof".to_string(), Severity::Error, None, Vec::new()),
        ],
        true,
    )]
    #[case::no_errors(
        vec![
            ErrorEntry::new("okay".to_string(), Severity::Info, None, Vec::new()),
        ],
        false,
    )]
    #[parallel]
    fn test_rapid_flux_error_has_error(#[case] entries: Vec<ErrorEntry>, #[case] expected: bool) {
        let mut error = RapidFluxError::default();
        assert!(!error.has_errors());
        error.extend(entries);
        assert_eq!(error.has_errors(), expected);
    }

    #[test]
    fn test_rapid_flux_error_display() {
        let error = RapidFluxError {
            entries: vec![
                ErrorEntry::new("first".to_string(), Severity::Error, None, Vec::new()),
                ErrorEntry::new("second".to_string(), Severity::Warning, None, Vec::new()),
            ],
        };

        assert_eq!(error.to_string().as_str(), "error: first\nwarning: second");
    }

    #[test]
    fn test_rapid_flux_error_debug() {
        let error = RapidFluxError {
            entries: vec![
                ErrorEntry::new(
                    "first".to_string(),
                    Severity::Error,
                    None,
                    vec![Annotation::new(None, Severity::Error, Location::default())],
                ),
                ErrorEntry::new("second".to_string(), Severity::Warning, None, Vec::new()),
            ],
        };

        assert_eq!(
            format!("{error:?}").as_str(),
            "[ErrorEntry { message: \"first\", severity: Error, location: None, annotations: \
            [Annotation { label: None, severity: Error, location: Location { start: \
            FilePosition(0, 0), end: None, source: None } }] }, ErrorEntry { message: \"second\", \
            severity: Warning, location: None, annotations: [] }]"
        );
    }

    #[test]
    fn test_rapid_flux_error_from_vec() {
        let vector = vec![ErrorEntry {
            message: "dummy".to_string(),
            severity: Severity::Error,
            ..ErrorEntry::default()
        }];

        let error: RapidFluxError = vector.clone().into();
        assert_eq!(error.entries, vector);
    }

    #[test]
    #[parallel]
    fn test_rapid_flux_error_push() {
        RapidFluxError::reset_counts();
        let entry = ErrorEntry {
            message: "dummy".to_string(),
            severity: Severity::Error,
            annotations: vec![Annotation::new(None, Severity::Error, Location::default())],
            location: Some(Location::default()),
        };

        let mut error: RapidFluxError = RapidFluxError::default();
        assert!(error.push(entry.clone()));
        assert_eq!(error.entries, vec![entry.clone()]);
        assert!(error.push(entry.clone()));
        assert_eq!(error.entries, vec![entry.clone(), entry]);
    }

    #[test]
    #[serial]
    fn test_rapid_flux_error_push_with_limit() {
        RapidFluxError::reset_counts();
        RapidFluxError::set_max_error(2);
        let entry = ErrorEntry {
            message: "dummy".to_string(),
            severity: Severity::Error,
            annotations: vec![Annotation::new(None, Severity::Error, Location::default())],
            location: Some(Location::default()),
        };

        let mut error: RapidFluxError = RapidFluxError::default();
        assert!(error.push(entry.clone()));
        assert_eq!(error.entries, vec![entry.clone()]);
        assert!(!error.push(entry.clone()));
        RapidFluxError::set_max_error(0);
    }

    #[test]
    #[parallel]
    fn test_rapid_flux_extend() {
        RapidFluxError::reset_counts();
        let entry = ErrorEntry {
            message: "dummy".to_string(),
            severity: Severity::Error,
            annotations: vec![Annotation::new(None, Severity::Error, Location::default())],
            location: Some(Location::default()),
        };
        let second_entry = ErrorEntry {
            message: "other dummy".to_string(),
            severity: Severity::Error,
            annotations: vec![Annotation::new(None, Severity::Error, Location::default())],
            location: Some(Location::default()),
        };

        let mut error: RapidFluxError = RapidFluxError::default();
        assert!(error.extend([entry, second_entry]));
    }

    #[test]
    #[serial]
    fn test_rapid_flux_error_extend_with_limit() {
        RapidFluxError::reset_counts();
        RapidFluxError::set_max_error(3);
        let entries = vec![
            ErrorEntry {
                message: "dummy".to_string(),
                severity: Severity::Error,
                annotations: vec![Annotation::new(None, Severity::Error, Location::default())],
                location: Some(Location::default()),
            },
            ErrorEntry {
                message: "other dummy".to_string(),
                severity: Severity::Error,
                annotations: vec![Annotation::new(None, Severity::Error, Location::default())],
                location: Some(Location::default()),
            },
        ];

        let mut error: RapidFluxError = RapidFluxError::default();
        assert!(error.extend(entries.clone()));
        assert!(!error.extend(entries.clone()));
        assert!(!error.extend(entries.clone()));
        RapidFluxError::set_max_error(0);
    }

    #[test]
    #[parallel]
    fn test_rapid_flux_error_clear() {
        let vector = vec![
            ErrorEntry {
                message: "dummy".to_string(),
                severity: Severity::Error,
                ..ErrorEntry::default()
            },
            ErrorEntry {
                message: "other".to_string(),
                severity: Severity::Error,
                ..ErrorEntry::default()
            },
        ];
        let mut error = RapidFluxError::default();
        error.extend(vector.clone());
        assert_eq!(error.entries, vector);
        error.clear();
        assert_eq!(error.entries(), &[]);
    }

    #[rstest]
    #[case::rapidfluxerror_oneline_error(
        vec![ErrorEntry::new("Simple error".to_string(), Severity::Error, None, Vec::new())].into(),
        "error: Simple error\n",
    )]
    #[case::rapidfluxerror_oneline_warning(
        vec![ErrorEntry::new("Simple warning".to_string(), Severity::Warning, None, Vec::new())].into(),
        "warning: Simple warning\n",
    )]
    #[case::rapidfluxerror_oneline_note(
        vec![ErrorEntry::new("Simple note".to_string(), Severity::Note, None, Vec::new())].into(),
        "note: Simple note\n",
    )]
    #[case::rapidfluxerror_oneline_help(
        vec![ErrorEntry::new("Simple help".to_string(), Severity::Help, None, Vec::new())].into(),
        "help: Simple help\n",
    )]
    #[case::rapidfluxerror_oneline_info(
        vec![ErrorEntry::new("Simple info".to_string(), Severity::Info, None, Vec::new())].into(),
        "info: Simple info\n",
    )]
    #[case::rapidfluxerror_default_annotation(
        vec![
            ErrorEntry::new(
                "Annotated error".to_string(),
                Severity::Error,
                Some(Location {
                    start: FilePosition::new(1, 1),
                    source: Some(PathBuf::from_str("tests/data/sample.rflx").unwrap()),
                    end: Some(FilePosition::new(1, 8)),
                }),
                Vec::new(),
            )
        ].into(),
        indoc! {
            r"error: Annotated error
               --> tests/data/sample.rflx:1:1
                |
              1 | package Sample is
                | ^^^^^^^
                |
            "
        },
    )]
    #[case::rapidfluxerror_location_from_stdin(
        vec![
            ErrorEntry::new(
                "Annotated error".to_string(),
                Severity::Error,
                Some(Location {
                    start: FilePosition::new(1, 1),
                    source: Some(PathBuf::from_str("<stdin>").unwrap()),
                    end: Some(FilePosition::new(1, 8)),
                }),
                Vec::new(),
            )
        ].into(),
        "<stdin>:1:1: error: Annotated error\n",
    )]
    fn test_rapid_flux_error_print_messages(
        #[case] mut errors: RapidFluxError,
        #[case] expected_str: &str,
    ) {
        use std::io::{Read, Seek};

        let mut memory_stream = io::Cursor::new(Vec::new());
        let mut result = String::new();

        errors.print_messages(&mut memory_stream).unwrap();

        // Set the cursor at the beginning of the stream and retrieve its content
        memory_stream
            .seek(io::SeekFrom::Start(0))
            .expect("failed to seek at the position 0");
        memory_stream
            .read_to_string(&mut result)
            .expect("failed to read message from memory stream");

        assert_eq!(&result, expected_str);
    }

    #[test]
    fn test_rapid_flux_error_serde() {
        let errors = RapidFluxError::from(vec![
            ErrorEntry {
                message: "some error".to_string(),
                severity: Severity::Error,
                annotations: vec![Annotation {
                    severity: Severity::Error,
                    location: Location::default(),
                    label: None,
                }],
                location: None,
            },
            ErrorEntry {
                message: "some other".to_string(),
                severity: Severity::Error,
                ..ErrorEntry::default()
            },
        ]);
        let bytes = bincode::serialize(&errors).expect("failed to serialize");
        let deser: RapidFluxError = bincode::deserialize(&bytes).expect("failed to deserialize");
        assert_eq!(errors, deser);
    }

    #[allow(clippy::redundant_clone)]
    #[test]
    fn test_rapid_flux_error_clone() {
        use std::ptr::addr_of;
        let error = RapidFluxError::default();
        let cloned = error.clone();

        assert_ne!(addr_of!(error), addr_of!(cloned));
    }
}
