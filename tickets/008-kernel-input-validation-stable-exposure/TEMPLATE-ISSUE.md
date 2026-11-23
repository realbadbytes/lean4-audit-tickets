**NOT A NEW BUG — DO NOT FILE UPSTREAM.** All three kernel input-validation defects are already filed (#16489, #16648, #16649), fixed on master, and — verified with tonight's nightly-2026-11-23 — all three behave correctly there. The only content here is exposure data for released toolchains awaiting the next release cut, i.e. comment material on the closed threads, **not** a bug report.

---

### Prerequisites

* [x] Check that your issue is not already filed — **#16489 / #16648 / #16649** (closed, fixes unreleased). This reports stable/nightly exposure data; prepared as comments on those issues.
* [x] Reduce the issue to a minimal, self-contained, reproducible test case. (No Mathlib/Batteries; 1–3 files.)
* [x] Test against the latest nightly (via elan: 4.38.0-nightly-2026-11-23 — results in Versions/Additional below)
* [x] Soundness-bug question re `lake check --paranoid`: Assumed affected via shared C++ kernel paths; direct lake-level demo not run.

### Description

Kernel input-validation exposure on **released** toolchains: #16489 fires on 4.36.0 (`add_inductive` accepts loose-bvar constructor types **and stores a different type than it checked**; rejected on rc1). #16649 (`is_def_eq_unit_like`) fires on 4.36.0 **and** 4.37.0-rc1 (defeq accepts `x ≡ y` for distinct vars). #16648 (`infer_proj`) fires on both. All correct on nightly-2026-11-23 — fixes exist but are unreleased.

### Context

Status comments for #16489/#16648/#16649. Novel for #16489: submitted `Pi[a](Sort 1, Pi[y](#1, T #1))` vs stored `forall (a : Type), a -> T a` (silent re-binding) + auto-recursor from the mangled spec ⇒ *checked == stored* fails. No end-to-end `False` achieved on stable (use-site guards blocked attempts); #16649 includes out-of-layout reads.

### Steps to Reproduce

1. `lean e16489.lean` → 4.36.0: `RESULT-16489: ACCEPTED`; rc1/nightly: rejected
2. `lean e16649-punit.lean` → 4.36.0 & rc1: unit-like rule fires / defeq over-accepts
3. `lean e16648.lean` → 4.36.0 & rc1: projection typed from `Nat.pred`/theorems; nightly: proper `(kernel) invalid projection`

**Expected behavior:** Kernel rejects all malformed declarations on every released toolchain (as it finally does on nightly).

**Actual behavior:** Stable accepts checked≠stored inductives (4.36.0), unit-like defeq over-acceptance (both), garbage-typed projections (both). Scripts/outputs below.

### Versions

Lean (version 4.36.0, x86_64-unknown-linux-gnu, commit 611c117bfaf7b7ae1cfcf246ce6fba31e8f509e9, Release)
Lean (version 4.37.0-rc1, x86_64-unknown-linux-gnu, commit 0b77e12952ad39077d80d8bd6b66d601f225c321, Release)
Lean (version 4.38.0-nightly-2026-11-23, x86_64-unknown-linux-gnu, commit 231ef9a28b27a9a7ebabdbfa40c84cfb22744c24, Release)  ← all three behave correctly here
Ubuntu 26.04.1 LTS x86_64; toolchains installed via elan.

### Additional Information


```
-- e16489.lean
import Lean
open Lean Meta

/-- `inductive T : Type → Type | mk : (a : Type) → (y : #1) → T #1` (one parameter).
    The `#1` in the domain of `y` is a LOOSE bound variable at that point. -/
def decl : Declaration :=
  .inductDecl [] 1
    [{ name := `T, type := .forallE `a (.sort 1) (.sort 1) .default,
       ctors := [{ name := `T.mk,
                   type := .forallE `a (.sort 1)
                             (.forallE `y (.bvar 1) (.app (.const `T []) (.bvar 1)) .default) .default }] }]
    false

run_meta do
  try
    addDecl decl
    IO.println "RESULT-16489: ACCEPTED (addDecl succeeded)"
  catch e =>
    IO.println s!"RESULT-16489: REJECTED: {(← e.toMessageData.toString).splitOn "\n" |>.head!}"
```

```
-- e16649-punit.lean
import Lean
open Lean Meta
def mkBlock (ns c2 : Name) : Declaration :=
  let I1 := ns ++ `I1; let I2 := ns ++ `I2; let i2 := mkConst I2
  let pTy := mkForall `_ .default i2 (mkSort Level.zero)
  let fty := mkForall `P .default pTy (mkForall `x .default i2 (mkForall `y .default i2
               (mkForall `h .default (mkApp (mkBVar 2) (mkBVar 1)) (mkApp (mkBVar 3) (mkBVar 1)))))
  let fn := mkLambda `_ .default fty (mkConst ``Nat.zero)
  let arg := mkLambda `P .default pTy (mkLambda `x .default i2 (mkLambda `y .default i2
               (mkLambda `h .default (mkApp (mkBVar 2) (mkBVar 1)) (mkBVar 0))))
  let mk1 := mkApp (mkConst I1) (mkApp fn arg)
  .inductDecl [] 0 [{ name := I1, type := mkForall `n .default (mkConst ``Nat) (mkSort Level.one),
                      ctors := [{ name := I1 ++ `mk, type := mk1 }] },
                    { name := I2, type := mkSort Level.one, ctors := [{ name := c2, type := i2 }] }] false
run_meta do
  try addDecl (mkBlock `case3 ``PUnit.unit); IO.println "RESULT-16649: ACCEPTED (block validated)"
  catch e => IO.println s!"RESULT-16649: {(← e.toMessageData.toString).splitOn "\n" |>.head!}"
```

<details><summary>verify.sh (exit 0 ⇒ reproduces) + captured output</summary>

```bash
#!/usr/bin/env bash
# #16489 (loose-bvar ctor) fires on 4.36.0; #16649 (is_def_eq_unit_like layout confusion)
# fires on BOTH released toolchains (fix unreleased): kernel reports "invalid return type"
# (= x ≡ y accepted for distinct vars) where the fixed kernel reports "application type mismatch".
set -u; ELAN="$HOME/.elan/bin/elan"; export PATH="$HOME/.elan/bin:$PATH"; cd "$(dirname "$0")"; fail=0
o=$($ELAN run leanprover/lean4:v4.36.0 lean e16489.lean 2>&1); echo "$o"
echo "$o" | grep -q 'ACCEPTED' && echo "PASS: #16489 accepted on 4.36.0" || { echo "FAIL 16489"; fail=1; }
for tc in leanprover/lean4:v4.36.0 leanprover/lean4:v4.37.0-rc1; do
  o=$($ELAN run "$tc" lean e16649-punit.lean 2>&1); echo "$o"
  echo "$o" | grep -q "invalid return type" && echo "PASS: #16649 unit-like rule fired on $tc" || { echo "FAIL 16649 on $tc"; fail=1; }
done
exit $fail
```

```
RESULT-16489: ACCEPTED (addDecl succeeded)
PASS: #16489 accepted on 4.36.0
RESULT-16649: (kernel) invalid return type for 'case3.I1.mk'
PASS: #16649 unit-like rule fired on leanprover/lean4:v4.36.0
RESULT-16649: (kernel) invalid return type for 'case3.I1.mk'
PASS: #16649 unit-like rule fired on leanprover/lean4:v4.37.0-rc1
```
</details>

Fix status: #16489 → v4.37.0-rc1; #16648 → #16655; #16649 → merged but in no tag yet (nightly 231ef9a28b is clean). Request changelog notes at next cut; check whether `--paranoid` replay kernels share the vulnerable C++ paths. Related open: #16490 (aux names; precedent #14616 previously yielded axiom-free `False`).

### Impact

Everyone on 4.36.0/4.37.0-rc1 importing untrusted oleans ships the porous kernel input validation; breaks the checked==stored invariant the soundness argument rests on.
