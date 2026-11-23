---
title: "#print axioms drops Classical.choice for imported structure (S9 vs S9.mk disagree in one run)"
labels: [bug]
component: "#print axioms / import-time axiom cache"
affected: ["v4.30.0+ incl. v4.36.0 (stable)"]
status: confirm-existing   # https://github.com/leanprover/lean4/issues/15226 — ticket = fresh 4.36.0 proof
action: post results.log excerpt as comment on #15226
---
## Summary
Module A: `structure S9` over `Fin (pick+1)`, `pick := Classical.choice ⟨0⟩`. In-module
`#print axioms S9` = `[Classical.choice]`; after import, `#print axioms S9` =
**"does not depend on any axioms"** while `#print axioms S9.mk` = `[Classical.choice]` in the
*same run* — the contradiction is self-evident in one output.

## Proof
`./verify.sh` → `results.log`.
