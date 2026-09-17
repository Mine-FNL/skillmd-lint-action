# syntax=docker/dockerfile:1.7
# GitHub Action container — runs skillmd-lint against the workspace.
# Slim base for fast cold-start; multi-stage optional later.

FROM python:${{ inputs.python-version || '3.12' }}-slim

LABEL org.opencontainers.image.title="skillmd-lint-action"
LABEL org.opencontainers.image.description="Lint SKILL.md files in CI via the skillmd-lint Python package."
LABEL org.opencontainers.image.source="https://github.com/Mine-FNL/skillmd-lint-action"
LABEL org.opencontainers.image.licenses="MIT"

# Install system deps (git for checkout, ca-certificates for pip).
RUN apt-get update \
 && apt-get install -y --no-install-recommends git ca-certificates \
 && rm -rf /var/lib/apt/lists/*

# The action entrypoint is a shell script — copy it now and make it executable.
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]