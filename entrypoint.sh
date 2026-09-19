#!/usr/bin/env bash
# Entrypoint for the skillmd-lint-action Docker action.
#
# Reads CLI args injected from action.yml, installs the requested skillmd-lint
# version, runs it against the workspace, and writes a GitHub Actions summary
# before exiting with the appropriate code.

set -euo pipefail

# Defaults — overridden by the --*-input flags injected from action.yml.
PATH_ARG="skills/"
STRICT_INPUT="false"
FAIL_ON_WARNINGS_INPUT="false"
VERSION_INPUT="1.4.0"
EXTRA_ARGS_INPUT=""
INDEX_URL_INPUT=""

# Parse the arg vector.
while [[ $# -gt 0 ]]; do
    case "$1" in
        --path=*)                  PATH_ARG="${1#*=}" ;;
        --strict-input=*)          STRICT_INPUT="${1#*=}" ;;
        --fail-on-warnings-input=*) FAIL_ON_WARNINGS_INPUT="${1#*=}" ;;
        --version-input=*)         VERSION_INPUT="${1#*=}" ;;
        --extra-args-input=*)      EXTRA_ARGS_INPUT="${1#*=}" ;;
        --index-url-input=*)       INDEX_URL_INPUT="${1#*=}" ;;
        *) echo "::warning::unknown arg: $1" ;;
    esac
    shift
done

# Resolve to absolute path inside the workspace.
if [[ "$PATH_ARG" = /* ]]; then
    ABS_PATH="$PATH_ARG"
else
    ABS_PATH="$GITHUB_WORKSPACE/$PATH_ARG"
fi

if [[ ! -e "$ABS_PATH" ]]; then
    echo "::error::skillmd-lint: path '$PATH_ARG' (resolved: '$ABS_PATH') does not exist in the workspace."
    exit 2
fi

# Install skillmd-lint at the pinned version. Default to PyPI; allow
# index-url override for users on private indexes.
PIP_FLAGS=(--disable-pip-version-check --quiet)
if [[ -n "$INDEX_URL_INPUT" ]]; then
    PIP_FLAGS+=(--index-url "$INDEX_URL_INPUT")
fi

# shellcheck disable=SC2086
python -m pip install "${PIP_FLAGS[@]}" "skillmd-lint==${VERSION_INPUT}"

# Build the CLI args. Either `--strict` or `--fail-on-warnings` enables strict.
EXTRA=()
if [[ "$EXTRA_ARGS_INPUT" != "" ]]; then
    # Allow the user to pass multiple args split on whitespace.
    # shellcheck disable=SC2206
    EXTRA=( $EXTRA_ARGS_INPUT )
fi

if [[ "$STRICT_INPUT" == "true" || "$FAIL_ON_WARNINGS_INPUT" == "true" ]]; then
    EXTRA+=("--strict")
fi

# Run the linter. cd into the workspace so relative paths in `path:` resolve
# the way the user expects.
cd "$GITHUB_WORKSPACE"
echo "::group::skillmd-lint $VERSION_INPUT — linting $PATH_ARG"
set +e
LINT_OUTPUT=$(python -m skillmd_lint "${EXTRA[@]}" "$ABS_PATH" 2>&1)
LINT_RC=$?
set -e
echo "$LINT_OUTPUT"
echo "::endgroup::"

# Count error/warning codes for the action outputs. Best-effort grep; if the
# output uses `--format json` we could parse it, but the human format is the
# default and good enough for outputs.
ERRORS=$(echo "$LINT_OUTPUT" | grep -cE '^\s*✗\s*error' || true)
WARNINGS=$(echo "$LINT_OUTPUT" | grep -cE '^\s*⚠\s*warning' || true)

# Write outputs in the format GitHub expects.
{
    echo "errors=$ERRORS"
    echo "warnings=$WARNINGS"
} >>"$GITHUB_OUTPUT"

# Write a friendly summary block.
{
    echo "## skillmd-lint v${VERSION_INPUT}"
    echo ""
    echo "- Path: \`${PATH_ARG}\`"
    echo "- Errors: **${ERRORS}**"
    echo "- Warnings: **${WARNINGS}**"
    if [[ $LINT_RC -eq 0 ]]; then
        echo ""
        echo "✅ All checks passed."
    else
        echo ""
        echo "❌ Lint failed (exit $LINT_RC)."
    fi
} >>"$GITHUB_STEP_SUMMARY"

# Surface each finding as a workflow annotation so they show up inline in PRs.
echo "$LINT_OUTPUT" | while IFS= read -r line; do
    if echo "$line" | grep -qE '^\s*✗\s*error'; then
        echo "::error::${line#  }"
    elif echo "$line" | grep -qE '^\s*⚠\s*warning'; then
        echo "::warning::${line#  }"
    fi
done

exit $LINT_RC