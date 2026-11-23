---
title: "#print axioms reports 'does not depend on any axioms' for an imported theorem whose body is sorry"
labels: [bug]
component: "#print axioms / module import (duplicate declaration resolution)"
affected: ["v4.30.0+ incl. v4.36.0 (stable)"]
status: confirm-existing   # https://github.com/leanprover/lean4/issues/15652 — ticket = fresh 4.36.0 proof
action: post results.log excerpt as comment on #15652
---
## Summary (from our run on pristine 4.36.0)
`import Good; import Bad` (both define `theorem foo : 1+1=2`; Bad uses `sorry`):
- `#print foo` → body **`sorry`** (kept)
- `#print axioms foo` → **"does not depend on any axioms"**, exit 0.
Reverse order keeps `rfl` but reports `[sorryAx]`. The primary audit command silently lies.

## Proof
`./verify.sh` → `results.log` (verbatim stdout+exit code on 4.36.0).
