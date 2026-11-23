---
title: "#16489 fires on stable 4.36.0 (stored ctor type ≠ checked type); #16648/#16649 fire on BOTH released toolchains"
labels: [bug, kernel, exposure-report]
component: "C++ kernel addDecl (type_checker.cpp infer_proj / is_def_eq_unit_like; inductive loose bvars)"
affected: ["v4.36.0 (stable) — #16489, #16648, #16649", "v4.37.0-rc1 — #16648, #16649 (fix #16655 unreleased)"]
status: comment-existing   # leanprover/lean4 #16489, #16648, #16649 — ticket = exposure + payload data
---
## New payload evidence (beyond the filed repros)
- #16489 on 4.36.0: `addDecl` ACCEPTS the loose-bvar inductive and **stores a different type than
  it checked**: submitted `Pi[a](Sort 1, Pi[y](#1, T #1))`, stored `∀ (a : Type), a → T a`
  (kernel's checked==stored invariant fails), with auto-generated `T.rec` on the mangled block.
- #16649 unit-like rule FIRES (`x ≡ y` for distinct vars → "invalid return type", never a clean
  "application type mismatch") on both released toolchains — memory-unsafe record downcast live
  in the shipping kernel.

## Proof
`./verify.sh` → `results.log` (accept/fire lines per toolchain; master's expected strings quoted in filed tests).
