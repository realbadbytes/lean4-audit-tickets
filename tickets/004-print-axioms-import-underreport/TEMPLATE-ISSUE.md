### Prerequisites

* [x] Check that your issue is not already filed — **related to #15226** (same collectAxioms import gap); the S9-vs-S9.mk contradiction within one run appears new. Prepared as a comment on #15226.
* [x] Reduce the issue to a minimal, self-contained, reproducible test case. (No Mathlib/Batteries; 1–3 files.)
* [x] Test against the latest nightly (via elan: 4.38.0-nightly-2026-11-23 — results in Versions/Additional below)
* [x] Soundness-bug question re `lake check --paranoid`: N/A — reporting layer.

### Description

`#print axioms S9` under-reports `Classical.choice` for an **imported** inductive while `#print axioms S9.mk` reports it — two contradictory answers in one session.

### Context

Confirmation + minimization for #15226; still live on current nightly.

### Steps to Reproduce

1. `A.lean`: inductive with derivation/decider route through `Classical.choice`; build `A.olean`
2. `B.lean`: `import A` + `#print axioms S9` + `#print axioms S9.mk`; `LEAN_PATH=. lean B.lean`

**Expected behavior:** Both lines agree on `Classical.choice`.

**Actual behavior:** ```
'S9' does not depend on any axioms
'S9.mk' depends on axioms: [Classical.choice]
```
4.36.0 and nightly-2026-11-23.

### Versions

Lean (version 4.36.0, x86_64-unknown-linux-gnu, commit 611c117bfaf7b7ae1cfcf246ce6fba31e8f509e9, Release)
Lean (version 4.38.0-nightly-2026-11-23, x86_64-unknown-linux-gnu, commit 231ef9a28b27a9a7ebabdbfa40c84cfb22744c24, Release)
Ubuntu 26.04.1 LTS x86_64; toolchains installed via elan.

### Additional Information


```
-- A.lean
noncomputable def pick : Nat := Classical.choice ⟨0⟩

structure S9 where
  x : Fin (pick + 1)

#print axioms S9
```

```
-- B.lean
import A
theorem usesS9 (_ : S9) : True := trivial
#print axioms S9
#print axioms S9.mk
```

<details><summary>verify.sh (exit 0 ⇒ reproduces) + captured output</summary>

```bash
#!/usr/bin/env bash
# `#print axioms S9` shows [Classical.choice] in its own module but "does not depend on any
# axioms" in an importing module (while S9.mk still reports the choice). exit 0 = reproducible.
set -u; ELAN="$HOME/.elan/bin/elan"; export PATH="$HOME/.elan/bin:$PATH"; cd "$(dirname "$0")"; fail=0
tc="${AUDIT_TC:-leanprover/lean4:v4.36.0}"; d=$(mktemp -d); cp A.lean B.lean "$d"/
a=$(cd "$d" && $ELAN run "$tc" lean -o A.olean A.lean && LEAN_PATH=. $ELAN run "$tc" lean B.lean 2>&1)
echo "$a"
echo "$a" | tail -2 | head -1 | grep -q "does not depend on any axioms" && echo "PASS: S9 underreported" || { echo "FAIL"; fail=1; }
echo "$a" | tail -1 | grep -q "Classical.choice" && echo "PASS: S9.mk still reports choice (contradiction visible in one run)" || { echo "FAIL control"; fail=1; }
rm -rf "$d"; exit $fail
```

```
'S9' depends on axioms: [Classical.choice]
'S9' does not depend on any axioms
'S9.mk' depends on axioms: [Classical.choice]
PASS: S9 underreported
PASS: S9.mk still reports choice (contradiction visible in one run)
```
</details>


### Impact

Downstream projects believe they are Classical-free when they are not.
