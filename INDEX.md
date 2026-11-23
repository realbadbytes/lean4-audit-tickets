 #7 smart-unfolding: NOT A BUG (fixed on master; clean on nightly-2026-11-23) — closed, downgraded to exposure note.
 #8 kernel input-validation: NOT A BUG (#16489/#16648/#16649 fixed upstream; verified fixed on nightly-2026-11-23) — closed, exposure notes only.
# Lean 4 bug backlog (2026-11-23 audit)
 #7 smart-unfolding: NOT A BUG (fixed on master; clean on nightly-2026-11-23) — closed, downgraded to exposure note.
 #8 kernel input-validation: NOT A BUG (#16489/#16648/#16649 fixed upstream; verified fixed on nightly-2026-11-23) — closed, exposure notes only.

 #7 smart-unfolding: NOT A BUG (fixed on master; clean on nightly-2026-11-23) — closed, downgraded to exposure note.
 #8 kernel input-validation: NOT A BUG (#16489/#16648/#16649 fixed upstream; verified fixed on nightly-2026-11-23) — closed, exposure notes only.
Repo-local issue backlog; every ticket is self-verifying: `cd tickets/NNN-* && ./verify.sh`
 #7 smart-unfolding: NOT A BUG (fixed on master; clean on nightly-2026-11-23) — closed, downgraded to exposure note.
 #8 kernel input-validation: NOT A BUG (#16489/#16648/#16649 fixed upstream; verified fixed on nightly-2026-11-23) — closed, exposure notes only.
(exit 0 ⇒ finding reproduces on the pinned toolchains). `results.log` = captured proof per ticket.
 #7 smart-unfolding: NOT A BUG (fixed on master; clean on nightly-2026-11-23) — closed, downgraded to exposure note.
 #8 kernel input-validation: NOT A BUG (#16489/#16648/#16649 fixed upstream; verified fixed on nightly-2026-11-23) — closed, exposure notes only.
Full audit context: `../AUDIT-REPORT.md`.
 #7 smart-unfolding: NOT A BUG (fixed on master; clean on nightly-2026-11-23) — closed, downgraded to exposure note.
 #8 kernel input-validation: NOT A BUG (#16489/#16648/#16649 fixed upstream; verified fixed on nightly-2026-11-23) — closed, exposure notes only.

 #7 smart-unfolding: NOT A BUG (fixed on master; clean on nightly-2026-11-23) — closed, downgraded to exposure note.
 #8 kernel input-validation: NOT A BUG (#16489/#16648/#16649 fixed upstream; verified fixed on nightly-2026-11-23) — closed, exposure notes only.
| # | Title | Labels | Disposition | Verify |
 #7 smart-unfolding: NOT A BUG (fixed on master; clean on nightly-2026-11-23) — closed, downgraded to exposure note.
 #8 kernel input-validation: NOT A BUG (#16489/#16648/#16649 fixed upstream; verified fixed on nightly-2026-11-23) — closed, exposure notes only.
|---|---|---|---|---|
 #7 smart-unfolding: NOT A BUG (fixed on master; clean on nightly-2026-11-23) — closed, downgraded to exposure note.
 #8 kernel input-validation: NOT A BUG (#16489/#16648/#16649 fixed upstream; verified fixed on nightly-2026-11-23) — closed, exposure notes only.
| 001 | lean/leanchecker SIGSEGV on truncated `.olean` (3 toolchains, silent, core dump) | bug, memory-safety | **NEW → security@lean-fro.org first** (per soundness template), then public issue | ✅ 6/6 |
 #7 smart-unfolding: NOT A BUG (fixed on master; clean on nightly-2026-11-23) — closed, downgraded to exposure note.
 #8 kernel input-validation: NOT A BUG (#16489/#16648/#16649 fixed upstream; verified fixed on nightly-2026-11-23) — closed, exposure notes only.
| 002 | `leanchecker --fresh` exit 0 on module w/ unchecked forged `unsafe` False (Replay skips isUnsafe) | bug, validation-gap | **NEW → security@lean-fro.org first**, then public | ✅ 3/3 |
 #7 smart-unfolding: NOT A BUG (fixed on master; clean on nightly-2026-11-23) — closed, downgraded to exposure note.
 #8 kernel input-validation: NOT A BUG (#16489/#16648/#16649 fixed upstream; verified fixed on nightly-2026-11-23) — closed, exposure notes only.
| 003 | `#print axioms` = "no axioms" for imported theorem whose body is `sorry` | bug | comment-confirmation on **#15652** | ✅ 3/3 |
 #7 smart-unfolding: NOT A BUG (fixed on master; clean on nightly-2026-11-23) — closed, downgraded to exposure note.
 #8 kernel input-validation: NOT A BUG (#16489/#16648/#16649 fixed upstream; verified fixed on nightly-2026-11-23) — closed, exposure notes only.
| 004 | `#print axioms` drops `Classical.choice` for imported inductive (S9 vs S9.mk contradiction in one run) | bug | comment-confirmation on **#15226** | ✅ 2/2 |
 #7 smart-unfolding: NOT A BUG (fixed on master; clean on nightly-2026-11-23) — closed, downgraded to exposure note.
 #8 kernel input-validation: NOT A BUG (#16489/#16648/#16649 fixed upstream; verified fixed on nightly-2026-11-23) — closed, exposure notes only.
| 005 | leanchecker sidecar plant bypass **+ NEW: whole-file overwrite defeats `--fresh`** | bug | comment on **#16674** (new matrix row) | ✅ 4/4 |
 #7 smart-unfolding: NOT A BUG (fixed on master; clean on nightly-2026-11-23) — closed, downgraded to exposure note.
 #8 kernel input-validation: NOT A BUG (#16489/#16648/#16649 fixed upstream; verified fixed on nightly-2026-11-23) — closed, exposure notes only.
| 006 | bundled `lean4lean` rejects its own toolchain's oleans ("incompatible header") | bug | comment-confirmation on **#16679** | ✅ 1/1 |
 #7 smart-unfolding: NOT A BUG (fixed on master; clean on nightly-2026-11-23) — closed, downgraded to exposure note.
 #8 kernel input-validation: NOT A BUG (#16489/#16648/#16649 fixed upstream; verified fixed on nightly-2026-11-23) — closed, exposure notes only.
| 007 | smart-unfolding elab/kernel defeq divergence reproducible on 4.36.0 + 4.37.0-rc1 | bug | comment on **#16682/83/84** (fixed master, untagged): request release note | ✅ 2/2 |
 #7 smart-unfolding: NOT A BUG (fixed on master; clean on nightly-2026-11-23) — closed, downgraded to exposure note.
 #8 kernel input-validation: NOT A BUG (#16489/#16648/#16649 fixed upstream; verified fixed on nightly-2026-11-23) — closed, exposure notes only.
| 008 | #16489 accepted on stable (stored type ≠ checked type); #16648/#16649 fire on both releases | bug, kernel | comment exposure/payload data on **#16489/#16648/#16649** | ✅ 3/3 |
 #7 smart-unfolding: NOT A BUG (fixed on master; clean on nightly-2026-11-23) — closed, downgraded to exposure note.
 #8 kernel input-validation: NOT A BUG (#16489/#16648/#16649 fixed upstream; verified fixed on nightly-2026-11-23) — closed, exposure notes only.

 #7 smart-unfolding: NOT A BUG (fixed on master; clean on nightly-2026-11-23) — closed, downgraded to exposure note.
 #8 kernel input-validation: NOT A BUG (#16489/#16648/#16649 fixed upstream; verified fixed on nightly-2026-11-23) — closed, exposure notes only.
## Submission
 #7 smart-unfolding: NOT A BUG (fixed on master; clean on nightly-2026-11-23) — closed, downgraded to exposure note.
 #8 kernel input-validation: NOT A BUG (#16489/#16648/#16649 fixed upstream; verified fixed on nightly-2026-11-23) — closed, exposure notes only.
No GitHub credentials in this environment; tickets 001/002 are security-adjacent and should go to
 #7 smart-unfolding: NOT A BUG (fixed on master; clean on nightly-2026-11-23) — closed, downgraded to exposure note.
 #8 kernel input-validation: NOT A BUG (#16489/#16648/#16649 fixed upstream; verified fixed on nightly-2026-11-23) — closed, exposure notes only.
`security@lean-fro.org` before any public issue (their template, `ef5d196b49`). When submitting
 #7 smart-unfolding: NOT A BUG (fixed on master; clean on nightly-2026-11-23) — closed, downgraded to exposure note.
 #8 kernel input-validation: NOT A BUG (#16489/#16648/#16649 fixed upstream; verified fixed on nightly-2026-11-23) — closed, exposure notes only.
public items: use lean4's bug-report template, paste `ISSUE.md` body, attach `verify.sh` +
 #7 smart-unfolding: NOT A BUG (fixed on master; clean on nightly-2026-11-23) — closed, downgraded to exposure note.
 #8 kernel input-validation: NOT A BUG (#16489/#16648/#16649 fixed upstream; verified fixed on nightly-2026-11-23) — closed, exposure notes only.
`results.log`, apply the listed labels.
