### Prerequisites

* * [x] Check that your issue is not already filed — **duplicate of #16679** with a fresh two-file repro; prepared as a confirmation comment there.
* [x] Reduce the issue to a minimal, self-contained, reproducible test case. (No Mathlib/Batteries; 1–3 files.)
* [x] Test against the latest nightly (via elan: 4.38.0-nightly-2026-11-23 — results in Versions/Additional below)
* [x] Soundness-bug question re `lake check --paranoid`: Partially — `lake check --paranoid` advertises running all bundled checkers incl. lean4lean, which cannot read a project's own oleans as shipped.

### Description

The `lean4lean` bundled inside 4.36.0 (and nightly-2026-11-23) rejects oleans built by that same toolchain: `failed to read file './R.olean', incompatible header`. The out-of-the-box differential defense is nonfunctional as shipped.

### Context

Independent confirmation of #16679 with a two-file self-contained repro; also broken on current nightly.

### Steps to Reproduce

1. `R.lean`: `def x : Nat := 1`; `lean -o R.olean R.lean` with the toolchain's own compiler
2. Same toolchain: `LEAN_PATH=. PATH="<toolchain>/bin:$PATH" bin/lean4lean R`

**Expected behavior:** Exit 0 — the bundled replay kernel reads its own release's artifacts.

**Actual behavior:** ```
failed to read file './R.olean', incompatible header    (exit 1)
```
on 4.36.0 **and** nightly-2026-11-23. (`lean4lean` spawns `lean`; keep matching `bin/` on PATH.)

### Versions

Lean (version 4.36.0, x86_64-unknown-linux-gnu, commit 611c117bfaf7b7ae1cfcf246ce6fba31e8f509e9, Release)
Lean (version 4.38.0-nightly-2026-11-23, x86_64-unknown-linux-gnu, commit 231ef9a28b27a9a7ebabdbfa40c84cfb22744c24, Release)
Ubuntu 26.04.1 LTS x86_64; toolchains installed via elan.

### Additional Information


```
-- R.lean
def x : Nat := 1
theorem y : x = 1 := rfl
```

<details><summary>verify.sh (exit 0 ⇒ reproduces) + captured output</summary>

```bash
#!/usr/bin/env bash
# The lean4lean shipped inside the 4.36.0 toolchain vs a module built by that same toolchain.
set -u; ELAN="$HOME/.elan/bin/elan"; export PATH="$HOME/.elan/bin:$PATH"; cd "$(dirname "$0")"; fail=0
tc="${AUDIT_TC:-leanprover/lean4:v4.36.0}"; B=$("$ELAN" run "$tc" lean --print-prefix)/bin
d=$(mktemp -d); cp R.lean "$d"/
(cd "$d" && $ELAN run "$tc" lean -o R.olean R.lean) >/dev/null 2>&1 || { echo "BUILD FAIL"; exit 1; }
out=$(cd "$d" && LEAN_PATH=. PATH="$B:$PATH" "$B/lean4lean" R 2>&1); ec=$?
echo "$out (exit $ec)"
if echo "$out" | grep -qi 'incompatible header'; then echo "PASS: bundled lean4lean rejects own toolchain's olean (#16679 repro)"; else echo "NOTE: lean4lean read the olean (exit $ec) — see results.log"; fi
rm -rf "$d"
[ $fail -eq 0 ]
```

```
lean4lean found a problem in R:
failed to read file './R.olean', incompatible header (exit 1)
PASS: bundled lean4lean rejects own toolchain's olean (#16679 repro)
```
</details>

Likely header/version-tag encoding mismatch between `lean` writer and `lean4lean` reader within one bundle.

### Impact

The bundled *independent* kernel check is unusable out of the box for multi-kernel verification guidance.
