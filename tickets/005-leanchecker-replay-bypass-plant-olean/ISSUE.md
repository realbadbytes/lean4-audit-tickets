---
title: "leanchecker replays planted olean (sidecar bypass) — and --fresh is also defeated by whole-file overwrite"
labels: [bug]
component: leanchecker module/sidecar resolution
affected: ["v4.33.1–v4.36.0 (stable)"]
status: confirm-existing-plus-new-nuance   # https://github.com/leanprover/lean4/issues/16674
action: comment on #16674 — the NEW part is the second matrix row below
---
## Matrix proved by verify.sh (4.36.0)
| state | `leanchecker Target` | `leanchecker --fresh Target` |
|---|---|---|
| authentic forged module | exit 1 (correct reject) | exit 1 |
| `Target.olean.server` = unrelated olean (planted) | **exit 0 (bypass)** | exit 1 |
| `Target.olean` wholly overwritten by unrelated olean | exit 0 | **exit 0 — NEW: contradicts the "--fresh is safe" guidance** |

## Why the overwrite row matters
Nothing left on disk tells the checker that `Target.olean` is not the real Target (no digest).
"--fresh" advice cannot work when the artifact under check was substituted; needs digests
(lake manifest) or reject-on-mismatch-of-imported-consumers, not freshness alone.

## Proof
`./verify.sh` → `results.log` (all four assertions, exit codes).
