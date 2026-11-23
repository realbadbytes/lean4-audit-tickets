**NOT A NEW BUG — DO NOT FILE UPSTREAM.** The elab/kernel divergence is fixed on master (#16682/#16683/#16684, merged 2026-11-22) and verified clean on nightly-2026-11-23 in this very session. What remains is release-timing data only (4.36.0/4.37.0-rc1 lag the fix — standard release cadence, not a defect).
Use below *only* as an optional :+1:/exposure comment on the closed threads.

---

### Prerequisites

* [x] Check that your issue is not already filed — fixed on master via #16682/#16683/#16684 (closed). This reports **release exposure** on 4.36.0/4.37.0-rc1; prepared as a comment on #16682.
* [x] Reduce the issue to a minimal, self-contained, reproducible test case. (No Mathlib/Batteries; 1–3 files.)
* [x] Test against the latest nightly (via elan: 4.38.0-nightly-2026-11-23 — results in Versions/Additional below)
* [x] Soundness-bug question re `lake check --paranoid`: N/A — elab/kernel disagreement; all bundled checkers share the buggy released code.

### Description

On 4.36.0 and 4.37.0-rc1, the elaborator accepts `rfl` for smart-unfolding equations with nested-match discriminants while the kernel type checker rejects the resulting defeq obligation. Fixed on master (#16682-84, closed 2026-11-22) but **in no release**; NOT reproducible on nightly-2026-11-23.

### Context

Exposure comment for #16682. Files are master's own regression tests, so no external minimization needed. Practical for mathlib-style structural recursors over nested matches compiled on released toolchains.

### Steps to Reproduce

1. Take master's `smartUnfoldingDiscriminant.lean` (inlined below)
2. `lean smartUnfoldingDiscriminant.lean` on 4.36.0 → elab claims rfl succeeds; in-process kernel check fails
3. Same on 4.37.0-rc1; on nightly-2026-11-23 compiles clean (exit 0)

**Expected behavior:** Elaborator and kernel agree in released compilers; or the fix is announced/backported.

**Actual behavior:** Divergence on both releases (verify script asserts it, PASS ×2); consistent on nightly.

### Versions

Lean (version 4.36.0, x86_64-unknown-linux-gnu, commit 611c117bfaf7b7ae1cfcf246ce6fba31e8f509e9, Release)
Lean (version 4.37.0-rc1, x86_64-unknown-linux-gnu, commit 0b77e12952ad39077d80d8bd6b66d601f225c321, Release)
Lean (version 4.38.0-nightly-2026-11-23, x86_64-unknown-linux-gnu, commit 231ef9a28b27a9a7ebabdbfa40c84cfb22744c24, Release)  ← fixed here
Ubuntu 26.04.1 LTS x86_64; toolchains installed via elan.

### Additional Information


```
-- smartUnfoldingDiscriminant.lean
module

/-!
Smart unfolding must check a recursive match inside a discriminant before returning
its result. Writing the discriminant inline or binding it with `let` should agree.
-/

private def fromSome : Nat → Nat
  | 0 => 0
  | n+1 => match some (match n with | 0 => 11 | k+1 => fromSome k) with
    | some x => x
    | none => 5

example (n : Nat) : fromSome (n+1) = (match n with | 0 => 11 | k+1 => fromSome k) := by
  fail_if_success exact rfl
  cases n <;> rfl

private def fromSomeLet : Nat → Nat
  | 0 => 0
  | n+1 =>
    let t := match n with | 0 => 11 | k+1 => fromSomeLet k
    match some t with
    | some x => x
    | none => 5

example (n : Nat) : fromSomeLet (n+1) = (match n with | 0 => 11 | k+1 => fromSomeLet k) := by
  fail_if_success exact rfl
  cases n <;> rfl

-- The pair pattern can select its branch even when the match producing the pair is stuck.
private def fromPair : Nat → Nat
  | 0 => 0
  | n+1 =>
    match (match n with | 0 => (0, 0) | k+1 => (fromPair k, 0)) with
    | (x, _) => x

example (n : Nat) :
    fromPair (n+1) = (match n with | 0 => (0, 0) | k+1 => (fromPair k, 0)).1 := by
  fail_if_success exact rfl
  cases n <;> rfl

-- The outer match also needs a marker because the `false` branch recurses on its pattern variable.
private def both (m : Nat) (flag : Bool) : Nat :=
  match m with
  | 0 => 0
  | n+1 =>
    match flag, some (match n with | 0 => 11 | k+1 => both k flag), n with
    | true, some x, _ => x
    | false, _, k+1 => both k flag
    | _, _, _ => 5
termination_by structural m

example (n : Nat) : both (n+1) true = (match n with | 0 => 11 | k+1 => both k true) := by
  fail_if_success exact rfl
  cases n <;> rfl

example (P : Nat → Prop) (k : Nat) (h : P (both k true)) : P (both (k+2) true) := by
  dsimp (config := { autoUnfold := true }) only
  guard_target = P (both k true)
  exact h
```

<details><summary>verify.sh (exit 0 ⇒ reproduces) + captured output</summary>

```bash
#!/usr/bin/env bash
# master's regression test (fixed 2026-11-23, PRs #16682/83/84) run on RELEASE toolchains:
# elaborator claims `rfl` succeeds, then the C++ kernel rejects the refl proof. exit 0 = reproducible.
set -u; ELAN="$HOME/.elan/bin/elan"; export PATH="$HOME/.elan/bin:$PATH"; cd "$(dirname "$0")"; fail=0
for tc in leanprover/lean4:v4.36.0 leanprover/lean4:v4.37.0-rc1; do
  out=$($ELAN run "$tc" lean smartUnfoldingDiscriminant.lean 2>&1)
  echo "$out" | grep -q 'fail_if_success.*succeeded\|succeeded but was expected to fail' \
    && echo "$out" | grep -q '(kernel) declaration type mismatch' \
    && echo "PASS $tc: elab accepts rfl / kernel rejects (divergence)" \
    || { echo "FAIL $tc: divergence not observed"; fail=1; }
done
exit $fail
```

```
PASS leanprover/lean4:v4.36.0: elab accepts rfl / kernel rejects (divergence)
PASS leanprover/lean4:v4.37.0-rc1: elab accepts rfl / kernel rejects (divergence)
```
</details>

Request: release note; consider point release carrying #16682-84, since modules built on affected releases embed proofs the strict kernel disagrees with.

### Impact

Users on 4.36.0/4.37.0-rc1 lose "kernel as final arbiter" for affected patterns until the fix ships.
