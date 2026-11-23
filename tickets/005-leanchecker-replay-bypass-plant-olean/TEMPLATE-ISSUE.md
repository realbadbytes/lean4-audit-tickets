### Prerequisites

* * [x] Check that your issue is not already filed — extends **#16674**; the whole-file-overwrite `--fresh` bypass (row 4 below) appears new. Prepared as a comment on #16674.
* [x] Reduce the issue to a minimal, self-contained, reproducible test case. (No Mathlib/Batteries; 1–3 files.)
* [x] Test against the latest nightly (via elan: 4.38.0-nightly-2026-11-23 — results in Versions/Additional below)
* [x] Soundness-bug question re `lake check --paranoid`: Assumed affected (shares leanchecker; direct lake plant demo not run — `--paranoid` transcript on the unsafe-forgery issue shows the checker accepting forged content).

### Description

Full bypass matrix for `leanchecker`, incl. a **new bypass of `--fresh`**: replacing `<Module>.olean` wholesale defeats fresh replay, because replay re-verifies the attacker's own bytes as that module's source. All rows verified on 4.36.0 and nightly-2026-11-23.

### Context

Extends #16674 (which covers the `.olean.server` plant and recommends `--fresh`); row 4 shows that advice is incomplete. Combined with the unsafe-skip bypass, every leanchecker mode can be satisfied by a forged module.

### Steps to Reproduce

1. Build `Target.olean` (forged `mismatched : False` via run_cmd with **safe** flags ⇒ checker rejects) and `Other.olean` (innocuous)
2. `cp Other.olean Target.olean.server`; `leanchecker Target` → **exit 0**
3. `leanchecker --fresh Target` → exit 1 (catches sidecar)
4. `cp Other.olean Target.olean`; `leanchecker --fresh Target` → **exit 0** (new bypass)

**Expected behavior:** Every mode rejects modules whose olean does not match a replay of their source; `--fresh` immune to on-disk layout tricks.

**Actual behavior:** authentic forged → exit 1 ✓; sidecar plant → **exit 0**; fresh vs sidecar → exit 1 ✓; whole-file overwrite + fresh → **exit 0**. Identical on both toolchains.

### Versions

Lean (version 4.36.0, x86_64-unknown-linux-gnu, commit 611c117bfaf7b7ae1cfcf246ce6fba31e8f509e9, Release)
Lean (version 4.38.0-nightly-2026-11-23, x86_64-unknown-linux-gnu, commit 231ef9a28b27a9a7ebabdbfa40c84cfb22744c24, Release)
Ubuntu 26.04.1 LTS x86_64; toolchains installed via elan.

### Additional Information


```
-- Other.lean
theorem other : True := trivial
```

```
-- Target.lean
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

<details><summary>verify.sh (exit 0 ⇒ reproduces) + captured output</summary>

```bash
#!/usr/bin/env bash
# (1) plant Other.olean as <M>.olean.server: leanchecker <M> exits 0; --fresh rejects (control).
# (2) overwrite variant: replacing <M>.olean wholesale ALSO defeats --fresh (gap vs filed advice).
set -u; ELAN="$HOME/.elan/bin/elan"; export PATH="$HOME/.elan/bin:$PATH"; cd "$(dirname "$0")"; fail=0
tc="${AUDIT_TC:-leanprover/lean4:v4.36.0}"; LC=$("$ELAN" run "$tc" lean --print-prefix)/bin/leanchecker
export PATH="$(dirname "$LC"):$PATH"
d=$(mktemp -d); cp Target.lean Other.lean "$d"/
(cd "$d" && $ELAN run "$tc" lean -o Target.olean Target.lean && $ELAN run "$tc" lean -o Other.olean Other.lean) >/dev/null 2>&1
(cd "$d" && LEAN_PATH=. "$LC" Target >/dev/null 2>&1); base=$?
(cd "$d" && cp Other.olean Target.olean.server && LEAN_PATH=. "$LC" Target >/dev/null 2>&1); plant=$?
(cd "$d" && LEAN_PATH=. "$LC" --fresh Target >/dev/null 2>&1); freshplant=$?
rm "$d"/Target.olean.server; cp "$d"/Other.olean "$d"/Target.olean
(cd "$d" && LEAN_PATH=. "$LC" --fresh Target >/dev/null 2>&1); freshover=$?
[ $base -ne 0 ] && echo "PASS(control): authentic forged module rejected (exit $base)" || { echo "FAIL control"; fail=1; }
[ $plant -eq 0 ] && echo "PASS: sidecar plant -> leanchecker exit 0" || { echo "FAIL plant exit $plant"; fail=1; }
[ $freshplant -ne 0 ] && echo "PASS(control): --fresh catches sidecar (exit $freshplant)" || { echo "FAIL"; fail=1; }
[ $freshover -eq 0 ] && echo "PASS: overwrite defeats --fresh too (exit 0) -- NEW nuance" || { echo "FAIL overwrite exit $freshover"; fail=1; }
rm -rf "$d"; exit $fail
```

```
PASS(control): authentic forged module rejected (exit 1)
PASS: sidecar plant -> leanchecker exit 0
PASS(control): --fresh catches sidecar (exit 1)
PASS: overwrite defeats --fresh too (exit 0) -- NEW nuance
```
</details>

`--fresh` re-elaborates the olean on disk — its trust anchor is the file being audited; mitigation needs an out-of-band source/hash, not a flag.

### Impact

CI guidance "just add --fresh" leaves users exposed to tampered artifacts.
