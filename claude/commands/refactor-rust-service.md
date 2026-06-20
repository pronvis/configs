Let's refactor this code to make it robust and easier to support in the future.

## Phase 1 — Research (do this first, commit the output before touching code)
Study several high-quality, well-regarded Rust repositories (lots of stars, strong
reputation) that build **web services with a DB and HTTP API** on a tech stack similar
to ours. Don't fixate on libraries like Tokio/Tower — they're libraries, not apps — but
their patterns may still be useful.
Extract the best practices and the clean abstraction layers for writing this kind of
service. Write them up as `.md` files in `docs/` (I'll add them to my Knowledge-Base at
`~/it/knowledge_base`).
Then write a refactoring plan as `docs/refactor-plan.md`: an inventory of the concrete
problems you found in our code (unclean / ugly / fragile places) and the changes you
propose, ordered by value and risk. Commit Phase 1 before editing any code, so the
research and plan survive even if the refactor stops early.

## Phase 2 — Refactor
Work on a new git branch. Refactor only — preserve existing behavior; do not change
features or business logic. If a change would alter behavior, stop and flag it instead.
Commit in small, logical steps so progress is reviewable and reversible.
Work autonomously as far as you can go safely; when you hit an ambiguous decision or
something that needs my input, leave the tree in a consistent state and note where you
stopped.

## Optionally, things I already spotted (may be empty)
$ARGUMENTS

This is only what I can see now — you should find more during the research phase.
