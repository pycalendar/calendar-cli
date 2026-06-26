# Changelog

All notable changes to this project should be documented in this file.

This file was introduced in v1.0.3, so no changelog exists for earlier changes.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.3] - 2026-06-26

Quite a bit of cleanup has been done, and I've added some of the scaffolding that I use for other projects (only details for the "user-facing" changes are included below).

### Changed
- Packaging migrated from `setup.py` to a PEP 621 `pyproject.toml` using the
  Hatch build backend. The version is now derived automatically from git tags
  via hatch-vcs instead of being hard-coded in `calendar_cli/metadata.py`, so
  the released version can no longer drift from the tags
  (https://github.com/pycalendar/calendar-cli/issues/117).
- Installation is now done via `make install` (or any PEP 517 frontend, e.g.
  `pip install .`) rather than `./setup.py install`; dependencies are declared
  in `pyproject.toml`.

### Fixed
- `--interactive-config` no longer crashes on Python 3: it relied on the
  removed Python 2 `raw_input` builtin and used `os`, `time` and `getpass`
  without importing them.
- The package license metadata now uses the valid SPDX identifier
  `GPL-3.0-or-later`
  (https://github.com/pycalendar/calendar-cli/issues/115).
