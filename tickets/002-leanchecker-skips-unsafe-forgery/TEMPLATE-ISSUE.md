### Prerequisites

* * [x] Check that your issue is not already filed — related: #16674 (planted olean replay). The unsafe/skipped-declaration replay-skip angle and the `lake check --paranoid` demonstration below do not appear filed.
* [x] Reduce the issue to a minimal, self-contained, reproducible test case. (No Mathlib/Batteries; 1–3 files.)
* [x] Test against the latest nightly (via elan: 4.38.0-nightly-2026-11-23 — results in Versions/Additional below)
* [x] Soundness-bug question re `lake check --paranoid`: **Yes — empirically: `lake check --paranoid` exits 0 on the forged module on 4.36.0 and nightly-2026-11-23.**

### Description

`leanchecker` — **including `--fresh`** — exits **0 (module accepted)** on an olean containing a fabricated `unsafe` proof of `False`: replay skips every `isUnsafe`/`isPartial` constant (`src/Lean/Replay.lean:188` in 4.36.0). The same project passes **`lake check --paranoid`** with exit 0 on stable and nightly (transcript below).

### Context

The forgery uses `set_option debug.skipKernelTC true` (live in release builds, `src/Lean/AddDecl.lean:30`) + `unsafe run_cmd addDecl (.thmDecl ...)` to store `forged : False := True.intro` un-kernel-checked. Imports trust oleans by design; checkers are the defense-in-depth for untrusted artifacts — the hole sits exactly at unchecked declarations.

### Steps to Reproduce

1. Build repro: `lean -o ForgeUnsafe.olean ForgeUnsafe.lean` → exit 0
2. `LEAN_PATH=. leanchecker ForgeUnsafe` → **exit 0**
3. `LEAN_PATH=. leanchecker --fresh ForgeUnsafe` → **exit 0**
4. Control: identical module without `unsafe` is rejected by both
5. Lake demo: module inside a project; `lake build && lake check --paranoid` → **exit 0** (4.36.0 and nightly-2026-11-23)

**Expected behavior:** A checker meant to validate untrusted oleans must reject a module containing an unchecked `False := True.intro` (the safe control is correctly rejected).

**Actual behavior:** Both checker modes exit 0; `lake check --paranoid` exits 0; inside the module `#print axioms forged` prints `does not depend on any axioms`.

### Versions

Lean (version 4.36.0, x86_64-unknown-linux-gnu, commit 611c117bfaf7b7ae1cfcf246ce6fba31e8f509e9, Release)
Lean (version 4.38.0-nightly-2026-11-23, x86_64-unknown-linux-gnu, commit 231ef9a28b27a9a7ebabdbfa40c84cfb22744c24, Release)
Ubuntu 26.04.1 LTS x86_64; toolchains installed via elan.

### Additional Information


```
-- ForgeSafeControl.lean
import Lean
open Lean Elab Command
-- A declaration whose stated type does not match its value, emitted with the
-- kernel check skipped so `lean` still writes the .olean. Plain `leanchecker`
-- and `leanchecker --fresh` both reject this module.
set_option debug.skipKernelTC true in
run_cmd liftCoreM <| addDecl (.thmDecl
  { name := `mismatched, levelParams := [], type := mkConst ``False,
    value := mkConst ``True.intro, all := [`mismatched] })
```

```
-- ForgeUnsafe.lean
import Lean
open Lean Elab Command
set_option debug.skipKernelTC true in
run_cmd liftCoreM <| addDecl (.defnDecl { name := `forged, levelParams := [], type := mkConst ``False, value := mkConst ``True.intro, hints := .opaque, safety := .unsafe })
#print axioms forged
```

<details><summary>verify.sh (exit 0 ⇒ reproduces) + captured output</summary>

```bash
#!/usr/bin/env bash
# leanchecker (incl. --fresh) exits 0 on module containing unchecked forged `unsafe` False;
# the SAFE twin of the same forgery IS rejected (proves the unsafe-replay-skip is the gap).
set -u; ELAN="$HOME/.elan/bin/elan"; export PATH="$HOME/.elan/bin:$PATH"; cd "$(dirname "$0")"; fail=0
tc="${AUDIT_TC:-leanprover/lean4:v4.36.0}"; LC=$("$ELAN" run "$tc" lean --print-prefix)/bin/leanchecker
export PATH="$(dirname "$LC"):$PATH"
d=$(mktemp -d); cp ForgeUnsafe.lean ForgeSafeControl.lean "$d"/
(cd "$d" && $ELAN run "$tc" lean -o ForgeUnsafe.olean ForgeUnsafe.lean && $ELAN run "$tc" lean -o ForgeSafeControl.olean ForgeSafeControl.lean) >/dev/null 2>&1
(cd "$d" && LEAN_PATH=. "$LC" ForgeUnsafe >/dev/null 2>&1); a=$?
(cd "$d" && LEAN_PATH=. "$LC" --fresh ForgeUnsafe >/dev/null 2>&1); b=$?
(cd "$d" && LEAN_PATH=. "$LC" ForgeSafeControl >/dev/null 2>&1); c=$?
[ $a -eq 0 ] && echo "PASS: leanchecker ForgeUnsafe exit 0 (accepts forged unsafe False)" || { echo "FAIL: plain exit $a"; fail=1; }
[ $b -eq 0 ] && echo "PASS: leanchecker --fresh ForgeUnsafe exit 0 (skips isUnsafe replay)" || { echo "FAIL: --fresh exit $b"; fail=1; }
[ $c -ne 0 ] && echo "PASS(control): identical SAFE forgery rejected (exit $c)" || { echo "FAIL(control): safe forgery not rejected"; fail=1; }
rm -rf "$d"; exit $fail
```

```
PASS: leanchecker ForgeUnsafe exit 0 (accepts forged unsafe False)
PASS: leanchecker --fresh ForgeUnsafe exit 0 (skips isUnsafe replay)
PASS(control): identical SAFE forgery rejected (exit 1)
```
</details>

Lake/paranoid transcript (identical on 4.36.0 and nightly):
```
$ lake build            # exit 0
$ lake check --paranoid # exit 0  ← accepts project containing forged False
```
Harness note: `leanchecker` spawns `lean`; put the matching toolchain `bin/` on PATH or version skew yields spurious "incompatible header" failures (cf. #16679).

Security-adjacent: coordinated disclosure via security@lean-fro.org intended per this template's guidance.

### Impact

Teams gating third-party oleans with leanchecker/lake --paranoid get false assurance; a malicious dependency ships `unsafe False` surviving every bundled checker.
