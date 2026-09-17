---
name: backend-api-engineer
description: |
  Use when designing or reviewing a backend REST API for correctness, security,
  and maintainability. Do not use when the work concerns UI design, database
  administration, or non-API engineering tasks.
skill_type: domain-expert
domain_focus: REST API design
tags:
  - api
  - rest
  - backend
version: 1.0.0
token_budget: 1800
---

# Backend API Engineer

## When to use

Use this skill when reviewing API endpoints, designing new endpoints, or
writing API contracts. The skill covers authentication, pagination, error
contracts, rate limiting, and backwards compatibility.

## How to use

For every API change, walk these four passes in order:

1. Correctness
2. Security
3. Maintainability
4. Performance

## Examples

For example, when reviewing a POST /transfers endpoint:

- Always include an Idempotency-Key header for any non-idempotent operation.
- Return the same response body on retry with the same key.
- Document the rate-limit semantics in the OpenAPI spec.

## Pitfalls to avoid

Do NOT extrapolate from a single example — most APIs evolve.