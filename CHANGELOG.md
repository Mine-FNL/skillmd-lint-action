# Changelog

All notable changes to `skillmd-lint-action` are recorded here.

## [1.0.0] — 2026-09-17

### Added

- **Composite-action-style Docker action** that installs
  [`skillmd-lint`](https://github.com/Mine-FNL/skillmd-lint) in a fresh
  Python container and lints the requested path.
- **Six inputs**:
  - `path` (default `skills/`)
  - `strict` — treat warnings as errors
  - `fail-on-warnings` — alias for `strict`
  - `version` — skillmd-lint version to install (default `1.4.0`)
  - `extra-args` — pass-through to the CLI (e.g. `--format github --schema`)
  - `index-url` — PEP 503 index URL for `pip install`
- **Two outputs**: `errors` and `warnings` counts.
- **GitHub Actions annotations**: each finding is emitted as `::error` /
  `::warning` for inline PR display.
- **Step summary**: friendly Markdown block on the run summary page.
- **Test fixtures** (`valid`, `warnings`, `invalid`) and a CI workflow that
  builds the image and exercises each fixture.
- **CI workflow** with `shellcheck` for `entrypoint.sh` and `hadolint` for
  `Dockerfile`.

### Fixed

- The Dockerfile now uses a static `python:3.12-slim` base image. GitHub
  does not interpolate `${{ inputs.* }}` inside a Dockerfile, so the
  previous `FROM python:${{ inputs.python-version }}-slim` could never
  build. The `python-version` input was removed with it.
- Default `version` input bumped to `1.4.0` to match the current
  skillmd-lint release.