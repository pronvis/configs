# Comments

Default to NOT writing a comment. Code says what it does; a comment
earns its place only by saying something the code cannot.

Apply the delete test to every comment before writing it: if deleting
it loses information a competent reader could not recover from the
code itself, keep it. Otherwise it is noise — delete it.

ALWAYS KEEP (these are the point of comments):
- Why an obvious simpler approach was rejected, and what breaks if
someone "simplifies" it back.
- Non-local invariants: lock ordering, required call order, why this
runs in this transaction, what another module assumes about this.
- Surprising mechanism: a non-obvious API choice, a workaround for a
known bug, `// SAFETY:` on unsafe.
- A pointer to the external source of a decision (ADR, spec section,
issue) that the code cannot contain.

NEVER WRITE:
- Restatements of the signature or the next line
(`// increment counter` above `counter += 1`).
- Section banners (`// ---- helpers ----`), changelog notes, or
"this function does X" where the name already says X.
- Re-explaining something a module-level doc comment two screens up
already said.

