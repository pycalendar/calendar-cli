# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed
- Packaging migrated from `setup.py` to a PEP 621 `pyproject.toml` using the
  Hatch build backend. The version is now derived automatically from git tags
  via hatch-vcs instead of being hard-coded in `calendar_cli/metadata.py`, so
  the released version can no longer drift from the tags
  (https://github.com/pycalendar/calendar-cli/issues/117).

### Fixed
- `--interactive-config` no longer crashes on Python 3: it relied on the
  removed Python 2 `raw_input` builtin and used `os`, `time` and `getpass`
  without importing them.
- The package license metadata now uses the valid SPDX identifier
  `GPL-3.0-or-later`
  (https://github.com/pycalendar/calendar-cli/issues/115).
