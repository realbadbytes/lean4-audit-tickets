# Lean 4 bug backlog (2026-11-23 audit)

Repo-local issue backlog; every ticket is self-verifying: `cd tickets/NNN-* && ./verify.sh`
(exit 0 ⇒ finding reproduces on the pinned toolchains). `results.log` = captured proof per ticket.
Full audit context: `../AUDIT-REPORT.md`.

| # | Title | Labels | Disposition | Verify |
|---|---|---|---|---|
| 001 | lean/leanchecker SIGSEGV on truncated `.olean` (3 toolchains, silent, core dump) | bug, memory-safety | **NEW → security@lean-fro.org first** (per soundness template), then public issue | ✅ 6/6 |
| 002 | `leanchecker --fresh` exit 0 on module w/ unchecked forged `unsafe` False (Replay skips isUnsafe) | bug, validation-gap | **NEW → security@lean-fro.org first**, then public | ✅ 3/3 |
| 003 | `#print axioms` = "no axioms" for imported theorem whose body is `sorry` | bug | comment-confirmation on **#15652** | ✅ 3/3 |
| 004 | `#print axioms` drops `Classical.choice` for imported inductive (S9 vs S9.mk contradiction in one run) | bug | comment-confirmation on **#15226** | ✅ 2/2 |
| 005 | leanchecker sidecar plant bypass **+ NEW: whole-file overwrite defeats `--fresh`** | bug | comment on **#16674** (new matrix row) | ✅ 4/4 |
| 006 | bundled `lean4lean` rejects its own toolchain's oleans ("incompatible header") | bug | comment-confirmation on **#16679** | ✅ 1/1 |
| 007 | smart-unfolding elab/kernel defeq divergence reproducible on 4.36.0 + 4.37.0-rc1 | bug | comment on **#16682/83/84** (fixed master, untagged): request release note | ✅ 2/2 |
| 008 | #16489 accepted on stable (stored type ≠ checked type); #16648/#16649 fire on both releases | bug, kernel | comment exposure/payload data on **#16489/#16648/#16649** | ✅ 3/3 |

## Submission
No GitHub credentials in this environment; tickets 001/002 are security-adjacent and should go to
`security@lean-fro.org` before any public issue (their template, `ef5d196b49`). When submitting
public items: use lean4's bug-report template, paste `ISSUE.md` body, attach `verify.sh` +
`results.log`, apply the listed labels.
