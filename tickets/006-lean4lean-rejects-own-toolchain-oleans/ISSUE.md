---
title: "4.36.0 toolchain's bundled lean4lean rejects oleans built by that same 4.36.0 toolchain ('incompatible header')"
labels: [bug]
component: "lean4lean (independent kernel) shipped in toolchain"
affected: ["v4.36.0 (stable)"]
status: confirm-existing   # https://github.com/leanprover/lean4/issues/16679 — ticket = minimal 2-line proof
action: comment on #16679
---
## Summary
`lean -o R.olean R.lean` (2 lines) then the toolchain's own `bin/lean4lean R` →
"failed to read file './R.olean', incompatible header". Out of the box, the independent-kernel
differential defense is nonfunctional on the release, i.e. users believe they have a second
kernel checking them while they do not.

## Proof
`./verify.sh` → `results.log`.
