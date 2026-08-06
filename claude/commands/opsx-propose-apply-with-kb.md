---
description: Apply the current OpenSpec proposal via /opsx:apply, enforcing the ~/it/knowledge_base rules
argument-hint: [extra instructions]
---

Apply the current opsx proposal by running `/opsx:apply`, while following the rules and
conventions in my Knowledge-Base at `~/it/knowledge_base`.

Note: `/opsx:apply` is a **project-scoped** command created by `openspec init`
(`.claude/commands/opsx/`). If it doesn't exist in this repo, stop and tell me — this
command only works inside an OpenSpec-initialized project.

Before applying:
1. Identify which topics the current proposal touches (e.g. ansible, clickhouse, docker,
   observability, rust) and read the relevant rules under `~/it/knowledge_base/<topic>/`.
   Skim `~/it/knowledge_base/README.md` first if you're unsure where something lives.
2. Check the proposal against those rules. If it conflicts with the KB, or if anything is
   ambiguous, risky, or you're not confident it's correct — STOP and ask me before applying.

Then run `/opsx:apply` for the current proposal, making sure the applied result conforms to
the Knowledge-Base rules.

After applying, briefly tell me which KB rules you relied on and anything you adjusted to
stay compliant.

$ARGUMENTS
