---
name: coordinator-prompt
description: Generate a multi-agent coordinator prompt file from a GitHub issue or parent issue graph — waves, branches and worktrees, implementer/reviewer/fixer briefs, blocking-findings list, gates, PR, final report. Use when asked to build, write, or refresh a prompt for implementing an issue, ticket, slice, or epic with orchestrated subagents.
---

Turn a GitHub issue into the prompt a coordinator session is pasted, so the orchestration is decided here — on cheap research — rather than improvised mid-run by an agent already holding eight subagent reports.

The artifact is a file under the workspace `prompts/` directory. Its skeleton, and the boilerplate briefs that never vary, live in [`TEMPLATE.md`](TEMPLATE.md). Read it before drafting.

You produce the prompt. You never execute it: no branch, worktree, or subagent dispatch belongs to this skill.

## 1. Resolve the target

Accept `#N`, a GitHub URL, `issue://owner/repo/N`, or an epic/slice name. Then:

- **Repo directory**: the sibling of `prompts/` whose `git -C <dir> remote get-url origin` matches the issue's repo. `prompts/` is not itself a git repo. A cross-repo issue the ticket names is read through `gh` from any repo directory; its clone is only needed when the prompt must cite that repo's files or history.
- **Fetch** `gh issue view <N> --json title,state,body,comments` for the target and every parent, child, and cross-repo issue it names. One non-interactive call each: `--comments` prints nothing when piped and truncates long bodies. Children are GitHub's sub-issue list reconciled against the body's list; a child in one and not the other is a report line.
- **Precedence.** Every source in the graph is dated, and the later decision wins: a comment outranks the body it answers, a parent's comment outranks a child's body, an issue body outranks an older ADR or `CLAUDE.md` line (the prompt then names the amendment), a spec commit on the spec repo's default branch outranks a comment that cited an older revision, and a closed sibling's closing comment outranks a body claim it invalidated. Collect every override as a row — source that lost → source that won → the brief that lands it — and carry them in the prompt's `PRECEDENCE` block. A decision that lives only in a comment and is never written down is the failure this step exists to prevent.
- **Dependencies.** A dependency named in any form — a `Blocked by:` field, or a "depends on" / "remains dependent on" sentence — is a decision, not a stop: either the prompt proceeds against a contract or pin (naming the artifact that stands in for the missing dependency) or the work waits. When the issue names several outcomes with different dependencies, say which outcome each open dependency gates. Ask in step 4 if the issue does not settle it.

## 2. Fan out research

One `task` batch, `scout` agents, concurrent. Each returns file paths and quoted lines, never prose summaries.

Research the **default branch, not the working tree**: `git show <default>:<path>`, `git grep <pattern> <default> -- <paths>`. A checkout sitting on a feature branch, or a dirty tree, is the user's — often a previous attempt at this very issue; reading it would make the prompt describe finished work as what exists. Name it untouchable in the prompt and say so in the report. Pre-existing worktrees get `git log --oneline <default>..<branch>` — subjects only, never the tree: a subject that mints a primitive or seam a ticket here needs is a step-4 question, and the prompt says which build owns it and defers the other.

- **Issue graph** — per ticket: acceptance criteria verbatim, named QA rows, dependency edges, explicit non-goals, and every override found in step 1.
- **Conventions** — the `CLAUDE.md` / `AGENTS.md` / `CONTEXT.md` sections a ticket touches, `docs/adr/*` numbers with their one-line rules, and the **exact gate commands** from `.github/workflows/*.yml` job steps, `package.json` scripts, `.cargo/config.toml` aliases, `Makefile` / `justfile`, and `scripts/*.sh`. CI is the list; where a doc's gate list disagrees with CI, CI wins and the difference is a report line. Also: the commit-subject convention from `git log --oneline -30`; the worktree precedent from `git worktree list` (`.worktrees/<name>` is only the default when the repo has none); and whether `skill://implement` and `skill://code-review` resolve — when one is absent, the brief carries the plain instruction instead of the `$name` call, and the report says so.
- **Existing surfaces** — per ticket, what already exists and must be consumed (stub, adapter, primitive, registry, harness, seed) with paths and symbol names, versus what it creates. Generated and vendored files and pins are named so the prompt can forbid hand edits. When the ticket **moves a pin**: the full delta of every vendored file between the current pin and the target, as added / removed / changed rows, with the consumer of each removed row — that delta is usually the bulk of the work and the whole scope question.
- **External spec sources** — the owning spec file per surface, the shared section numbers, and the precedence chain between them. Read at the revision the ticket cites, then diff the sections in use against the vendored pin and against the spec repo's default branch: a section that moved after the cited revision is a `PRECEDENCE` row when it bears on the work, a report line when it does not. Verify every `§` the issue cites resolves against that file's headings; a `§` that does not resolve is a report line, never a prompt line.

## 3. Shape and order

Three shapes. Pick on **file ownership**, not ticket count, and defend the pick in the report with the shared files that drove it.

- **Waves** — tickets whose diffs land in disjoint files. Wave 0 is whatever more than one later ticket would otherwise each invent: a shared primitive, a contract re-vendor, a doc or pin amendment, an empty-sectioned QA manifest that later branches fill in disjoint regions. Middle waves are the independent surfaces, one ticket each. The last wave is the cross-cutting thing nothing else can prove: route graph, E2E spine, responsive QA. Barrier between waves; concurrent inside one. A file two tickets both touch is a Wave 0 seam first — a provider, a prop, a fixture, a registry key one ticket owns before the others branch.
- **Sequential** — the collision that survives that seam: two tickets rewriting the same function body, the same router or service file, or the same seed rows. Not a wave: one branch, one commit per item, the enabling item first. Parallel branches here buy only merge conflicts that a fixer must re-integrate into what one implementer would have written once.
- **Small** — one ticket with no shared prerequisite: three phases on one branch.

A ticket already closed and merged is an entry condition, never work to recreate. Shared files get one named default owner plus a `hub` message as the way in for the other ticket (waves), or the append-only rule (sequential).

## 4. Ask once

One `ask` round, only for what research cannot answer:

- proceed-against-contract vs wait on an open dependency;
- push + PR vs branch-only;
- a model-routing pin; a review-round cap other than three;
- the scope of riders a pin or contract move drags in — default: only what the gates force, everything else reported as a follow-up with its repo named;
- every wire behaviour a handler cannot avoid answering that neither the issue graph nor the contract settles, each with the default you propose.
- a ticket that lists its own alternative resolutions and picks none — ask which, proposing the cheapest one no open upstream issue blocks.

Skip every question the issue graph already answers, and never ask what `gh` or the repo can tell you.

## 5. Draft, then sharpen

Fill every `TEMPLATE.md` slot; delete what research found irrelevant — a whole section or a single line — rather than leaving a placeholder, because a placeholder is a question the coordinator will improvise an answer to. The prompt carries decisions and their sources, not the issue's prose: a coordinator can read the issue itself. Then take one pass whose only job is removing what would make an agent guess:

- Every constraint cites its source — issue bullet, comment, ADR number, `CLAUDE.md` section, spec `§`. A constraint with no source is deleted, asked about, or — when a handler cannot avoid answering it — stated with the proposed default and marked a decision taken here.
- Every path, command, script and branch name was observed in step 2. Files the work **creates** are decisions: label them `(new)` and follow the module's naming precedent. Gate commands are verbatim; a narrow test or typecheck command may be **derived** from an observed script when the prompt names the derivation (`test:core` minus `--coverage`; `cargo check --tests`; `cargo test --test <binary> <name>`).
- A SHA already on the default branch may be cited as a reference, or as an assertion the run checks (ancestry, equality). A value the run captures or writes — `BASE`, `BASE_A`, a pin file — is never hardcoded.
- Every acceptance criterion of every ticket appears in exactly one implementer brief. A criterion the work **excludes** is placed once as a deferred row under `ENTRY CONDITION` naming what excluded it — a comment, a wire fact, an in-flight sibling branch — and the issue that now owes it; when nothing owes it, the row says so and the report repeats it. That counts as placed. A criterion in two briefs is an ownership bug; in none, a dropped ticket.
- Every state the ticket names has the test that proves it: for a service or UI, the wire states (absent keys, empty strings, nulls, error codes, caps); for a ticket with no wire, the failure states of its derivation (a removed key with a live consumer, a generator refusing a row, a vendored file drifting past the research). A state the pinned dependency cannot produce is proven at the seam with a typed fixture, the end-to-end suite asserts nothing about it, and `ENTRY CONDITION` names the pin bump that lifts that. This is the most-missed class in these prompts.
- Every wave or item names: branch, worktree, base, the tests that prove it, the files it owns, and the files it must not touch.

## 6. Write and report

Write `prompts/<repo>_issue_<N>_prompt.md`. `<repo>_slice_<N>_prompt.md` is for an epic — a parent whose sub-issues each become their own wave item; a parent whose comments settle one slice across its children is an issue. A set of siblings with no parent is `<repo>_set_<slug>_prompt.md`, where `<slug>` is the branch segment the prompt mints (`implementation/<slug>/…`). Check `<repo>_issue_<N>` and the legacy unprefixed `issue_<N>` before writing: an existing prompt for the same issue is refreshed in place, not duplicated under a second name.

Report: the file path, the wave or phase table, the shape decision with its evidence, which decisions came from comments rather than bodies, and every gap left for the user — each with the exact question and why research could not close it.

## House invariants

These hold in every generated prompt; they are why the briefs in `TEMPLATE.md` read the way they do.

**Dispatch.** The coordinator owns every dispatch, fixed point, review verdict, fix commit, merge, gate run, push and PR. Implementers never dispatch a reviewer or fixer — nesting them costs the reviewer its own review axes. One `task` call per phase carrying every item of that wave; wait for the batch to settle before the next phase. Agents are named by role (`task` to implement, `reviewer`, `fixer`); models come from omp config, so a prompt naming a model inside a child task changes nothing — state routing as a preflight the coordinator verifies, or leave it out.

**Review loop.** Implement → independent review against a captured fixed point → fixer on blocking findings only → re-review against the same fixed point. Three rounds max in a wave, two in the small variant; a branch still blocking at the cap is reported, not merged. The fixer does not commit; the coordinator inspects and commits. A finding that is a deliberate issue decision is rejected in the report, naming the contract line — not silently obeyed.

**Git.** Integration branch from a captured base; one branch and worktree per ticket from that integration base, at whatever path the repo's own precedent uses; wave order already encodes dependencies, so no ticket branches off a sibling. Non-fast-forward merges in a stated order. Never commit to the default branch, never push before gates are green, never reset/delete/clean an unexpected branch or worktree. The user's untracked files — the prompt files themselves — and pre-existing worktrees are left untouched. The small and sequential variants use one worktree too, whenever the repo's precedent is one per issue or the root checkout must stay on the default branch.

**Verification.** Implementers run only their named tests and narrow typechecks; the coordinator runs the project-wide gates once, at the end, from the integration worktree. A red gate goes to a fixer with the exact failure, then reruns.
