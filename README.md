<div align="center">

# 🩺 skillmd-lint-action

**Official GitHub Action wrapping [`skillmd-lint`](https://github.com/Mine-FNL/skillmd-lint).**
Lint your `SKILL.md` files in CI on every push and PR.

[![CI](https://github.com/Mine-FNL/skillmd-lint-action/actions/workflows/ci.yml/badge.svg)](https://github.com/Mine-FNL/skillmd-lint-action/actions)
[![action](https://img.shields.io/badge/action-v1.0.1-blueviolet)](https://github.com/Mine-FNL/skillmd-lint-action/releases)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

</div>

---

## Why

`SKILL.md` is the open standard for modular AI expertise
([agentskills.io](https://agentskills.io)). Every skill is a folder with a
`SKILL.md` at its root and a YAML frontmatter block declaring the skill's
`name`, `description`, optional `tags`, and other metadata.

This action runs [`skillmd-lint`](https://github.com/Mine-FNL/skillmd-lint)
against your skills on every push, so typos in frontmatter, missing trigger
phrases, and other common mistakes never make it to `main`.

## Usage

```yaml
# .github/workflows/skill-lint.yml
name: skill-lint
on: [push, pull_request]

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: Mine-FNL/skillmd-lint-action@v1
        with:
          path: skills/
```

That's it. The action installs the pinned `skillmd-lint` wheel from its
GitHub release (falling back to PyPI when available) in a fresh Python
container, lints the requested path, and exits non-zero if any errors are
found. Warnings show up as GitHub Actions annotations on the relevant lines.

## Inputs

| Name              | Required | Default       | Description                                                                                            |
|-------------------|----------|---------------|--------------------------------------------------------------------------------------------------------|
| `path`            | no       | `skills/`     | Path(s) to lint — a `SKILL.md` file, a skill folder, or a folder containing `skills/`.                  |
| `strict`          | no       | `false`       | Treat warnings as errors (sets exit code 1 on any warning).                                            |
| `fail-on-warnings`| no       | `false`       | Alias for `strict`. Either flag at `true` enables strict mode.                                         |
| `version`         | no       | `1.4.0`       | `skillmd-lint` version to install. **Pin this in production.**                                         |
| `extra-args`      | no       | `""`          | Extra args passed through to `skillmd-lint` (e.g. `"--format github --schema"`).                        |
| `index-url`       | no       | `""`          | PEP 503 index URL for `pip install`. Set to a private index for offline / air-gapped runners.          |

## Outputs

| Name        | Description                            |
|-------------|----------------------------------------|
| `errors`    | Number of error-level findings.        |
| `warnings`  | Number of warning-level findings.      |

Use them to gate downstream jobs:

```yaml
      - uses: Mine-FNL/skillmd-lint-action@v1
        id: lint
        with:
          path: skills/
      - run: echo "had ${{ steps.lint.outputs.errors }} errors"
```

## Examples

### Strict mode (warnings block)

```yaml
      - uses: Mine-FNL/skillmd-lint-action@v1
        with:
          path: skills/
          strict: "true"
```

### JSON output

```yaml
      - uses: Mine-FNL/skillmd-lint-action@v1
        with:
          path: skills/
          extra-args: "--format json"
```

### Schema validation on top of the rule engine

```yaml
      - uses: Mine-FNL/skillmd-lint-action@v1
        with:
          path: skills/
          extra-args: "--schema"
```

### Pin a specific skillmd-lint version

```yaml
      - uses: Mine-FNL/skillmd-lint-action@v1
        with:
          path: skills/
          version: 1.4.0
```

### Air-gapped runner (private index)

```yaml
      - uses: Mine-FNL/skillmd-lint-action@v1
        with:
          path: skills/
          index-url: https://your-internal-pypi.example.com/simple/
```

## Exit codes

| Code | Meaning                                          |
|------|--------------------------------------------------|
| `0`  | All rules passed (warnings allowed unless `--strict`). |
| `1`  | At least one error (or warning under `--strict`). |
| `2`  | The `path` input doesn't exist in the workspace. |

## Companion projects

- **[Mine-FNL/skillmd-lint](https://github.com/Mine-FNL/skillmd-lint)** — the Python package this action wraps.
- **[Mine-FNL/LLM-Skill-Factory-Tool](https://github.com/Mine-FNL/LLM-Skill-Factory-Tool)** — author + validate + measure skill loops.

## License

MIT — see [LICENSE](LICENSE).