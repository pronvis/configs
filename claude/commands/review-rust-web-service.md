---
description: Audit a feature branch's diff for Rust web-service logic against the knowledge-base guidelines
argument-hint: <feature-branch>
---

You are reviewing a Rust web-service project. The baseline is the default branch
(`$1`, or `main` if `$1` does not exist); the feature branch under review is
`$2`. Your job is to audit the **entire diff** the feature branch adds relative to the
baseline, and judge it against the project's authoritative guidelines.

## Guardrails (do these first, stop on failure)

- If `$2` is empty, stop and ask the user for the feature branch name.
- Determine the baseline: `git show-ref --verify --quiet refs/heads/$1 && echo $1 || echo main`.
- Verify the branch exists: `git rev-parse --verify $2`. If it fails, stop and report.
- If `git diff <baseline>...$2` is empty, report "no changes to review" and stop.

## Step 1 — Get the diff

Run `git diff <baseline>...$2` (three-dot: exactly what `$2` adds relative to the
common ancestor). Then **read every changed file in full** — not just the hunks — so you
have the surrounding context (function signatures, error types, trait impls, call sites)
needed to judge correctness, not just syntax.

## Step 2 — Load the guides

Read all guideline files under `~/it/knowledge_base`, prioritizing the ones relevant to
this diff:

- **Always:** `rust/README.md`, `rust/architecture.md`, `rust/error-handling.md`,
  `rust/web-api-axum.md`, `rust/service-skeleton.md`.
- **If the diff touches them:** `rust/database-sqlx.md`, `rust/redis-caching.md`,
  `rust/resilient-clients.md`, `rust/outbound-resilience.md`, `rust/grpc-tonic.md`,
  `rust/observability.md`, `rust/tracing-internals.md`, `rust/testing.md`,
  `rust/integration-testing.md`, and the `clickhouse/`, `docker/`, `observability/`,
  `video-streaming/` guides as applicable.

Build a concrete checklist of rules from these files **before** you start reviewing.
Treat the guides as the authoritative standard.

## Step 3 — Review the diff against the guides

For every change, verify it satisfies each applicable guideline. Do not assume
compliance — **prove it** by citing the specific `file:line` in the diff and the specific
rule it follows or violates. Pay particular attention to Rust web-service concerns:

- Error handling and propagation (`?`, custom error enums, HTTP status mapping — no
  `unwrap`/`expect`/`panic!` on request paths).
- Async correctness (no blocking calls in async contexts, no holding locks across `.await`).
- Input validation at request boundaries; no trust of external data.
- Resource handling (connection pools, timeouts, retries, cancellation, graceful shutdown).
- Observability (tracing spans, structured logging, no secrets in logs).
- Security (authn/authz, SQL injection via non-parameterized queries, leaked secrets).
- Test coverage for new logic.

## Output

Group findings by severity: **CRITICAL · HIGH · MEDIUM · LOW**. For each finding:

- **Location:** `file:line`
- **Rule:** the guideline it follows/violates (file + rule)
- **Finding:** what the code does and why it passes or fails
- **Fix:** concrete suggested change (for violations)

End with a short verdict: **APPROVE / APPROVE WITH NITS / REQUEST CHANGES**, plus a
1-3 line summary of the most important issues.

For deeper Rust-idiom analysis, you may delegate to the
`everything-claude-code:rust-reviewer` agent on the changed files.
