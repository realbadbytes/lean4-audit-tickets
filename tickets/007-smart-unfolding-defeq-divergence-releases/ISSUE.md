---
title: "released toolchains: elaborator claims rfl succeeds for smart-unfolding examples the kernel rejects (elab/kernel defeq divergence)"
labels: [bug]
component: "Meta.isDefEq / smart unfolding (PreDefinition/Structural/SmartUnfolding.lean, Meta/WHNF.lean)"
affected: ["v4.36.0 (stable)", "v4.37.0-rc1"]; fixed_master: ["#16682", "#16683", "#16684 (2026-11-23, untagged)"]
status: comment-existing   # file = master regression tests; request release note / cherry-pick
severity: medium (no artifact escapes the kernel — file fails to compile — but tactic proofs and
  metaprograms built on Meta.isDefEq over-accept silently; kernel is the sound arbiter)
---
## Summary
Running master's own regressions (`smartUnfoldingDiscriminant.lean`) on the RELEASE toolchains:
`exact rfl` succeeds under `fail_if_success` (elab isDefEq over-accept) and then the kernel emits
`(kernel) declaration type mismatch` — an elaborator-vs-kernel disagreement on the same terms.

## Proof
`./verify.sh` (both released toolchains) → `results.log`; master (fixed) rejects at elaboration.
