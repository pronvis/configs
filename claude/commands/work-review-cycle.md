---
description: Run a work→review→work loop until the reviewer approves or max cycles reached
argument-hint: <max-cycles> <work-branch> [baseline-branch]
---

Drive an iterative **work → review → react** loop on a feature branch until the reviewer
approves or a cycle cap is hit. You are the **worker**; the reviewer runs as a separate
agent in an isolated git worktree so it never disturbs your checkout.

## Parameters
- `$1` = **max cycles** (hard stop, e.g. `5`). Required.
- `$2` = **work branch** — the branch you commit to and the reviewer reviews. Required.
- `$3` = **baseline branch** — what the diff is measured against. Optional, default `master`.
- Worker command (first cycle): `/opsx-propose-apply-with-kb`
- Reviewer command (every cycle): `/review-rust-web-service <baseline> <work-branch>`

## Guardrails (do first, stop on failure)
- If `$1` or `$2` is empty, stop and ask the user.
- Baseline = `$3` if set, else `master`. Verify it exists (`git rev-parse --verify <baseline>`).
- Ensure you are on `$2` (create it from baseline if it doesn't exist).
- Never commit on the baseline branch.

## Cycle 1 — produce the initial implementation
If `$2` has **no commits** ahead of the baseline yet, run the worker command
`/opsx-propose-apply-with-kb` to create the initial change, then commit it to `$2`
(use `gcsm "<message>"`; if the commit fails because of GPG signing, stop and tell me).
If `$2` already has work on it, skip straight to the review loop.

## Review loop — repeat for cycle `i` = 1, 2, … up to `$1`
1. **Spawn a reviewer agent** (use the Task tool, fresh context). Instruct it to:
   - Create an isolated worktree:
     `git worktree add -b <work-branch>-reviewer-<i> ~/it/<work-branch>-reviewer-<i> <work-branch>`
   - From inside that worktree, run `/review-rust-web-service <baseline> <work-branch>`.
   - Return the full review output (findings grouped by severity + the verdict).
   - Then remove the worktree: `git worktree remove --force ~/it/<work-branch>-reviewer-<i>`
     and delete the branch `git branch -D <work-branch>-reviewer-<i>`.
2. **Read the reviewer output.** Decide the stop condition:
   - If the verdict is **APPROVE** with no actionable findings → the loop is done, go to Done.
   - Otherwise continue to step 3.
3. **React to each finding** on `$2`:
   - CRITICAL / HIGH / MEDIUM, and any LOW that's a real issue → implement the fix.
   - A finding you judge to be intentional/known/acceptable → **don't change behavior**; instead add a
     short code comment explaining why it's intended and approved, so the next review sees
     it's a conscious decision.
   - If a finding is ambiguous or risky and you're not confident, STOP and ask me.
4. **Commit** the reactions to `$2` (`gcsm "<message>"`; stop on signing failure).
5. If `i` reached `$1`, stop even if findings remain (see Done). Otherwise `i = i + 1`
   and go back to step 1.

## Done
Report:
- How many cycles ran and why it stopped (approved vs. hit cap `$1`).
- A short summary of what changed across cycles.
- Any remaining open findings (typically LOW/comment-only nits) if it stopped on the cap.
- Confirm no stray reviewer worktrees/branches are left (`git worktree list`).

$ARGUMENTS
