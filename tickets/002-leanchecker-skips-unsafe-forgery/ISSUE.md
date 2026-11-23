---
title: "leanchecker (even --fresh) exits 0 on a module containing an unchecked forged `unsafe` proof of False"
labels: [bug, validation-gap]
component: "leanchecker / Replay (src/Lean/Replay.lean:188 skips isUnsafe/isPartial)"
affected: ["v4.36.0 (stable)", "master"]
status: new   # consequence of Replay.lean skip; no demo/issue found
routing: security@lean-fro.org (validation bypass chain), then public
severity: high (validation tool certifies modules it never checked; chains with olean trust)
---
## Summary
`leanchecker --fresh ForgeUnsafe` **exits 0** for a module containing
`opaque unsafe forged : False := True.intro` (forged with the release-shipped
`debug.skipKernelTC` escape hatch) because replay skips all `isUnsafe`/`isPartial` constants.
Control: the *identical* forgery declared as a safe `theorem` IS rejected ("declaration type mismatch").

## Reproduction
`./verify.sh` — builds both forgeries, runs plain + --fresh checkers, asserts the accept/reject matrix.

## Expected
leanchecker should either replay unsafe-declaration *types* + safety flags faithfully or
loudly report "N declarations NOT verified (unsafe)"; exiting 0 silently is misleading for a checker.

## Proof
`results.log` — 3/3 assertions PASS incl. the safe-twin control.
