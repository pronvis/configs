---
description: High-scrutiny review of the `$1` branch diff — money-movement safety + guideline compliance
---

You are reviewing a Rust web-service project that handles **real payments moving real
money**. Baseline branch: `master`. Feature branch under review: `$1`. Your job is
to audit the **entire diff** the `$1` branch adds relative to `master`, with the
highest possible scrutiny. **This pass is review-only — do not modify any code unless the
user explicitly asks.**

## Guardrails (do these first, stop on failure)

- Verify both branches exist: `git rev-parse --verify master` and `git rev-parse --verify $1`. If either fails, stop and report.
- If `git diff master...$1` is empty, report "no changes to review" and stop.

## Step 1 — Get the diff

Run `git diff master...$1` (three-dot: exactly what `$1` adds relative to the
common ancestor). Then **read every changed file in full** — not just the hunks — so you
have the surrounding context (error types, transaction boundaries, call sites, trait
impls) needed to judge correctness. For money-handling code, also read the *unchanged*
callers and callees of changed functions; a bug is often in how new code is wired into old
code.

## Step 2 — Load the guides

Read every guideline file under `./docs/rust-*`:

- `rust-web-service-architecture.md`
- `rust-error-handling.md`
- `rust-database-patterns.md`
- `rust-external-clients-and-resilience.md`
- `rust-testing-patterns.md`
- `rust-knowledge-base.md`

Also read the knowledge base under `~/it/knowledge_base` (prioritize
`rust/error-handling.md`, `rust/web-api-axum.md`, `rust/database-sqlx.md`,
`rust/resilient-clients.md`, `rust/outbound-resilience.md`, `rust/testing.md`, plus any
payment/idempotency/observability guides present). Treat all of these as the authoritative
standard and build a concrete checklist from them **before** reviewing. Do not invent
rules — every cited rule must trace back to one of these files.

## Step 3 — Review the diff against the guides

For every change, verify it satisfies each applicable guideline. Cite the specific
`file:line` in the diff and the specific rule it follows or violates. **Do not assume
compliance — prove it.**

## ⚠️ CRITICAL CONTEXT — real money is at stake

A bug here can double-charge users, lose funds, leak payment credentials, or process
fraudulent transactions. Hunt specifically for:

- **Money math:** incorrect/missing amount or currency handling, rounding errors,
  float-based money (must be integer minor units / decimal), mismatched currencies,
  silent truncation or overflow.
- **Idempotency:** could a retry, duplicate request, or webhook replay charge twice? Is
  there an idempotency key, and is it enforced atomically at the storage layer?
- **Concurrency:** race conditions and non-atomic state transitions around payment status
  (check-then-act without a transaction/lock, lost updates, status moving backwards).
- **Untrusted input:** missing validation/signature-verification of payment-provider
  webhooks, provider API responses, and user input. Webhook authenticity (HMAC/signature)
  must be verified before any state change.
- **Error paths:** swallowed failures, `unwrap`/`expect`/`panic!` on payment paths, errors
  that leave a payment in an inconsistent or indeterminate state, missing compensating
  actions / reconciliation.
- **Secrets & auth:** hardcoded keys/tokens/secrets, secrets in logs or error messages,
  missing or weak authn/authz on payment endpoints.
- **Tests:** insufficient coverage of failure and edge cases (declines, timeouts, partial
  failures, duplicate webhooks, currency edge cases).

Assume nothing is safe until you've verified it. When in doubt, flag it.

## Step 4 — Report

Produce a structured report:

1. **Guideline compliance** — pass/fail per guide rule, each with diff citations
   (`file:line`).
2. **Payment-safety findings** — ordered by severity (**CRITICAL / HIGH / MEDIUM / LOW**),
   each with: exact location (`file:line`), why it's dangerous (concrete failure scenario
   — e.g. "webhook replay double-charges because…"), and a concrete fix.
3. **Verdict** — is this branch safe to merge? If not, list the blocking issues
   (CRITICAL/HIGH) explicitly.

Reminder: review-only. Do not modify code unless the user explicitly asks.
