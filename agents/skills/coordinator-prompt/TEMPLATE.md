# The prompt skeleton

Sections in this order. `{{slot}}` is filled from research; a section or line the work does not have is deleted, never left empty. Lines marked `(conditional)` are kept only when research found the thing they name — a backend repo has no QA manifest or copy layer, and a reviewer told to check one will hunt for a file that never existed.

Prose in the briefs is copied verbatim. It is the part that does not vary between issues, and rewriting it per issue is how a constraint gets lost.

The file opens with `Here is your task:` and ends with the final-report demand.

---

```text
Here is your task:

Implement {{issue-uri}}{{ + " (with " + companion-uris + ")" if any }} as {{one line: what
shape — a waved multi-agent build on one integration branch / a sequential single-branch
build, one commit per item / a three-phase build on one branch}}: {{the waves or items in
one sentence}}.

Repo:
  {{absolute path}}
  GitHub: {{owner/repo}}

TECH STACK:
  {{versions that decide command syntax and test placement — nothing decorative}}

SPEC SOURCES:
  1. {{issue-uri}} — the ticket. {{one line on how to read its bullets; e.g. every state
     listed is a designed-for state the client handles, never an error to report back}}
  2. {{cross-repo issue + comments}} — the decision record for {{what}}.
  3. {{external spec repo, cloned at <path>}}:
       {{spec file}}   ({{what it owns}})
       {{shared spec file}} ({{the § numbers this work reads, each verified to resolve}})
     {{demos: interaction/layout reference only; what is explicitly not ported}}
  4. Repo conventions: {{CLAUDE.md (auto-loaded)}}, {{docs/adr/NNNN (rule)}},
     {{docs/qa/README.md}} (conditional).

PRECEDENCE (a comment is a later decision than any body it answers):
  {{source that lost}} → {{source that won}} → {{the brief that lands it}}
  {{one row per override found in the graph; the chain when specs disagree:
    <precedence chain>}}

ENTRY CONDITION:
  {{what is already landed and must be consumed, not recreated — issue number, the commit
    it landed as, and the names of the things it provides}}
  {{if a dependency is still open — the deliberate override: what artifact the work is
    built against instead, what must be asserted before starting, and what is deferred}}
  Deferred (named here so it is placed, not dropped):
    {{criterion the work excludes}} — excluded by {{the comment / wire fact / in-flight
    branch}}; owed on {{the issue that keeps it, or "no issue yet"}}.
  {{a mismatch between the asserted artifact and the ticket is a stop-and-report}}

WHAT EXISTS (consume, never recreate):
  - {{path}} — {{symbol(s)}}: {{what it already answers}}
  - {{generated / vendored files and pins that are never hand-edited}}
  - {{the current checkout, if it is not the default branch or the tree is dirty}} is the
    user's work. Never check it out, commit, stash, reset or clean it.
  - Untracked root files ({{the prompt files}}) and every existing worktree
    ({{git worktree list output}}) are the user's. Never add, edit, delete, stash, commit,
    reset or clean them.

GIT BASELINE:
  - BASE = local {{default branch}} HEAD ({{assertion it must satisfy}}; never hardcode a
    SHA). Assert `git rev-list --count origin/{{default}}..{{default}}` — if non-zero, the
    user pushes {{default}} before any PR, and the prompt says so.
  - Integration branch {{implementation/issue_N}} from BASE, worktree {{path, following
    `git worktree list` precedent}}.
  - {{Wave 0 works directly on the integration branch; capture its final commit as BASE_A.}}
  - {{Wave 1 branches + worktrees, all from BASE_A:
       A  <name>  → branch <...>  worktree <...>}}
  - If a target branch/worktree exists, reuse it only if it belongs to this workflow with
    the expected base and no unrelated work; otherwise stop and report. Never reset,
    delete or overwrite an unexpected one.
  - Implementers commit on their branch; the coordinator commits fixer output, merges,
    {{pushes and opens the PR / prints the push and PR commands and stops}}. Nothing is
    pushed before the integration review is clean and the gates are green.
  - Commit subjects follow this repo's history: {{observed convention}}.

ONE-TIME APPROVAL GATE:
  Before changing files or creating branches/worktrees:
  1. Explain how you understand the issue graph.
  2. List the branches, worktrees, agent batches, review/fix loop, merge order, gates and
     final verification you will execute.
  3. Ask for one approval.
  After approval, execute the whole workflow without asking for routine confirmations.

{{MODEL ROUTING PREFLIGHT — only when the user pinned a role:
  Before the first task call, verify the coordinator runs as {{role}} and that
  task.agentModelOverrides for task / reviewer / fixer / scout resolve to {{role}}.
  A mismatch is a stop-before-dispatch, reported as the exact mismatched route.
  Model selection lives in omp configuration; prompt text inside a child task cannot
  change its model. Do not shell out to claude, codex, aider or any agent CLI — use the
  task tool.}}

ORCHESTRATION (you own every dispatch, fixed point, review, fix commit, merge, gate run,
push and the PR; implementers never dispatch their own reviewer/fixer):

  Wave 0 — {{shared prerequisite}} (one `task` agent, on the integration branch)
    {{what it builds, at which path, and what it explicitly does not build}}
    {{tests that prove it}}
    Then one `reviewer` (`$code-review BASE`), fixer loop as below, max three rounds.
    Commit; record BASE_A.

  Wave 1 — {{n}} surfaces (ONE task tool call with {{n}} `task` items, agent field
  omitted; each item gets its brief below plus the CONSTRAINTS block in the batch context)
    {{A / B / C one line each}}
    Each implementer invokes `$implement` with the overrides below and commits on its own
    branch. Wait for the whole batch.
    Then ONE task call with {{n}} `reviewer` items, each `$code-review BASE_A` in its
    worktree, Spec axis = that surface's ticket bullets + owner spec. Then one `fixer`
    item per branch with blocking findings (one task call). Re-review with a fresh
    `reviewer` against the same BASE_A. Max three rounds per branch; a branch still
    blocking after round three is not merged — stop and report the exact blocker.

  Wave 2 — integration (coordinator)
    Merge into {{integration branch}}, non-fast-forward, in order {{A, B, C}}. Then write
    every ADR and {{CLAUDE.md}} amendment the implementers reported, in one commit.
    Conflicts: resolve in the integration checkout only when mechanically clear and both
    accepted contracts survive; otherwise one `fixer` with both sides, the conflict, both
    briefs and the CONSTRAINTS block. Commit each resolution.
    One `reviewer`: `$code-review BASE` on the integration branch, Spec axis = the whole
    issue, with an explicit cross-surface brief: {{exactly one of each shared thing; no
    surface re-deriving what another owns}}. Fixer loop, max two rounds.

  Wave 3 — gates (coordinator, once, in {{integration worktree}})
    {{the exact commands, in CI's order and CI's spelling}}
    {{commands deliberately skipped, with the reason and what replaces them}}
    A red gate → `fixer` with the exact failure → rerun. Never push red. Do not commit
    format-only churn outside touched files.

  Wave 4 — push + PR
    git push -u origin {{integration branch}}
    gh pr create --base {{default branch}} --head {{integration branch}}
    Title: {{title}}. Body: {{Closes #N}}; {{the entry-condition override}}; the gates
    run; {{screenshot paths}}; review rounds per branch; ADR amendments. No auto-merge. Do
    not comment on or close issues directly — the PR's `Closes` does that on merge.
    Feature branches are not pushed.
    {{branch-only ending instead: print the exact push and `gh pr create` commands for the
    user, state that the issue stays open until they run them, and stop.}}

CONSTRAINTS (batch context for every implementer, reviewer and fixer):
  - {{what BASE_A ships and that a second copy of it is a spec defect}}
  - {{the data-flow rule: which seam reads the wire, one owner per datum}}
  - {{the copy / token / parameter rule: no user-visible literal outside <layer>}} (conditional)
  - {{dead-UI rule: absent or empty renders nothing; no skeleton, placeholder, or enabled
     no-op}} (conditional)
  - {{failure doctrine, per ADR: which failures share one block, which are 404s, which
     are silent absence}}
  - {{generated files are never hand-edited; a missing key or operation is an upstream gap
     named in the report, never a local literal}}
  - No implementer touches {{out-of-scope areas}} or another surface's files. Shared-file
    needs ({{list}}) go through the coordinator via `hub` before editing; default owners:
    {{file → surface}}.
  - Cross-surface facts: {{what A must know about B without reading B's branch}}
  - `docs/**` is never a wave item's ownership: an implementer reports the amendment line
    its decision needs and the coordinator writes them all at integration, as one-line
    amendments to the relevant ADR — a new ADR only when a decision has no home.
  - Skip project-wide formatters, linters and suites; run only touched tests and the
    narrow typechecks. The coordinator runs the gates once.

IMPLEMENTER BRIEF — COMMON (paste into every task):
  Work only in your assigned worktree on your assigned branch. Read, in order: your
  ticket bullets; {{the cross-repo decision record}}; your owner spec; {{the shared spec
  sections}}; {{the CLAUDE.md sections}}; the WHAT EXISTS files for your surface; the demo
  last. Then invoke `$implement` and land every item of your brief. Deliberate overrides
  to `$implement`: do not invoke its nested `$code-review`; do not dispatch any
  reviewer/fixer; do not run project-wide formatters, linters or the full suite. TDD at
  observable seams ({{adapters, pure functions, store rules}}); contract tests alongside
  for UI. Run {{narrow typecheck, e.g. `tsc --noEmit -p tsconfig.core.json` /
  `cargo check --tests`}} after each seam and touched tests via {{narrow test command,
  e.g. `pnpm exec vitest run --project core <file>` / `cargo test --test <binary>
  <name>`}}. {{Prove your widths through the mechanism this repo already uses — a dev
  command, or the width-matrix test helper named in step 2 — with typed fixtures at the
  adapter seam; review-only screenshots at a path named in your report, never pixel
  baselines.}} (conditional) Commit with a message referencing {{#N}}. Report:
  changed files, commit SHA(s), commands run with results, {{screenshot paths}}, ADR
  amendments, upstream gaps (with the repo they belong to), any unmet row. Must not: push;
  open a PR; comment on or close issues; touch other worktrees/branches; move any pin;
  edit generated files; add mocks, fixtures posing as production data, or fake IDs; add
  behaviour outside your brief.

IMPLEMENTER BRIEF — {{A}}: {{surface}}
  Ticket sections: {{...}}. Owner spec: {{...}}.
  {{The decisions, verbatim from the issue and its comments: what each field comes from,
    what is omitted versus null, what is capped, what is a named constant in one place
    with the reason recorded once. Each with the source that decided it; a value neither
    the graph nor the contract settles is marked DECISION TAKEN HERE with its default.}}
  Creates: {{path (new)}}.
  Tests: {{one line per state the ticket names — every absent key, empty string, null,
    error code and cap — each with the path that proves it}}.

BLOCKING REVIEW FINDINGS (every reviewer applies this list):
  - a ticket bullet or owner-spec rule missing, partial, or wrong for the surface under
    review;
  - a ticket-named state handled as an error {{list the concrete ones}};
  - re-derivation of something another layer owns {{list}};
  - a second copy of {{the shared thing(s) the enabling item owns}};
  - {{a user-visible literal outside the copy layer, an operational value outside the
     parameter layer}} (conditional);
  - {{boundary violations: which module may import what}};
  - a dead-UI breach (placeholder, skeleton, empty wrapper, enabled no-op) (conditional);
  - a fabricated identifier, demo record, or mock server;
  - a hand edit to a generated file, a pin move;
  - a QA-manifest row ticked without a test proving it, or a ticket-named QA row missing
    (conditional);
  - an edit outside the item's ownership (CONSTRAINTS);
  - a regression in {{out-of-scope areas}}.
  Smell-only judgement calls are non-blocking unless they have concrete correctness or
  maintainability impact; record them, do not refactor speculatively.

REVIEWER BRIEF (paste into each `reviewer` task):
  Fresh `reviewer`, independent of the implementer, read-only. In the named worktree:
  `git rev-parse <fixed-point>` must resolve and `git diff <fixed-point>...HEAD` must be
  non-empty; then invoke `$code-review <fixed-point>`. Spec axis as named by the
  coordinator for this branch. Standards axis: {{CLAUDE.md, the ADR numbers, the spec
  precedence chain}}, plus the skill's smell baseline. Report Standards and Spec
  separately with file:line evidence, each finding marked blocking or non-blocking against
  the BLOCKING REVIEW FINDINGS list. No edits; no build, lint, formatter or test runs. The
  issue tracker is reachable via issue:// URIs and `gh`; do not run a setup workflow to
  rediscover it.

FIXER BRIEF (paste into each `fixer` task):
  Apply only the blocking findings supplied, in the named worktree. Fix causes, not
  symptoms: no narrowed tests, suppressed diagnostics, special-cased inputs, or unrelated
  refactors; follow the established pattern in the touched module and the CONSTRAINTS
  block. Run only the specific test/command covering each fix. Do not commit, push, or run
  project-wide validation. Report each finding as fixed or rejected with evidence; a
  rejection names the conflicting contract line, spec rule, or repository invariant.

FINAL REPORT (to the user):
  {{Integration branch}}, {{PR URL or the push/PR commands owed}}, BASE and BASE_A,
  per-item commit lists, review rounds with what each fixed, merge conflicts and their
  resolutions, the gate summary, {{screenshot paths}}, {{deferred rows and what now owes
  them}}, ADR amendments, upstream gaps (with the repo each belongs to), and confirmation
  that the user's untracked prompt files, pre-existing worktrees and the {{feature
  checkout}} were left untouched.
```

---

## The small variant

One ticket, no parallelism. Keep every section above; only `ORCHESTRATION`'s waves change, and `CONSTRAINTS` loses its cross-surface lines:

- **Phase 1** — one `task` agent implements on `{{implementation/issue_N}}`, in a worktree when the repo's precedent is one per issue or the root checkout must stay on the default branch.
- **Phase 2** — one `reviewer` on the finished branch: `$code-review BASE`.
- **Phase 3** — one `fixer`, only if the verdict is REQUEST_CHANGES or a blocking finding exists; the coordinator commits its output. Then one more review on the new tip. Stop at APPROVE or after the second review, whichever comes first.

Then the gates, once, and the ending the user chose — push + PR, or the printed commands.

## The sequential variant

Several tickets whose diffs land in the same files: one branch, one commit per item, in an order where the enabling item lands first. Keep every section above, with `ORCHESTRATION` as three phases:

- **Phase A** — the enabling item (the shared projection, fixture, harness, or registry key) implemented by one `task` agent, then its `reviewer` / `fixer` loop, then commit and record `BASE_A`. Everything else assumes it.
- **Phase B** — the remaining items in order, one `task` agent and one commit each, no review between them. Each gets a `## Item N — {{what gets an owner}}` section carrying **Target** (paths, plus the exact `grep` that found its consumers), the change, and the test that proves it.
- **Phase C** — one integration `reviewer` (`$code-review BASE`, cross-item brief), its fixer loop, then the gates once and the chosen ending.

`CONSTRAINTS` replaces the shared-file owner rule with the append-only rule: **an item appends to a shared file and never rewrites an earlier item's code; a needed change to earlier code is a `hub` message to the coordinator first.**
