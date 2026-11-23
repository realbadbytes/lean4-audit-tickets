### Prerequisites

* [x] Check that your issue is not already filed — searched for "olean segfault", "truncated olean", "SIGSEGV import"; no matching issue found (2026-11-23).
* [x] Reduce the issue to a minimal, self-contained, reproducible test case. (No Mathlib/Batteries; 1–3 files.)
* [x] Test against the latest nightly (via elan: 4.38.0-nightly-2026-11-23 — results in Versions/Additional below)
* [x] Soundness-bug question re `lake check --paranoid`: No lake-level run, but both crash entry points (`lean`, `leanchecker`) are exactly what `lake check --paranoid` invokes — assume affected.

### Description

Importing a **truncated `.olean`** deterministically crashes both `lean` and `leanchecker` with **SIGSEGV (exit 139, core dump, zero diagnostic bytes)**. The olean reader does not bounds-check against the actual file size before reading sections.

### Context

Found during a systematic audit of Lean's proof-validation chain (2026-11). `.olean` files are exchanged in community caches and build artifacts; truncated/corrupt files are a realistic untrusted input (interrupted download/rsync, tampering).

### Steps to Reproduce

1. `Lib.lean`: `def x := 1`; build with `lean -o Lib.olean Lib.lean`
2. Truncate to 90%: `head -c $(( $(stat -c%s Lib.olean) * 9 / 10 )) Lib.olean > t && mv t Lib.olean`
3. `consumer.lean`: `import Lib`; run `LEAN_PATH=. lean consumer.lean`

**Expected behavior:** A clean diagnostic error ("failed to read file" / unexpected EOF) with a normal nonzero exit code.

**Actual behavior:** `exit 139` (SIGSEGV) + core dump — for `lean` **and** `leanchecker Lib` — on 4.33.1, 4.36.0, 4.37.0-rc1 and **nightly-2026-11-23**; truncation levels 50/90/99% all crash; no message printed.

### Versions

Lean (version 4.33.1, x86_64-unknown-linux-gnu, commit 819816b2e0a3bf405af45ae5c7af2491d8f5bee6, Release)
Lean (version 4.36.0, x86_64-unknown-linux-gnu, commit 611c117bfaf7b7ae1cfcf246ce6fba31e8f509e9, Release)
Lean (version 4.37.0-rc1, x86_64-unknown-linux-gnu, commit 0b77e12952ad39077d80d8bd6b66d601f225c321, Release)
Lean (version 4.38.0-nightly-2026-11-23, x86_64-unknown-linux-gnu, commit 231ef9a28b27a9a7ebabdbfa40c84cfb22744c24, Release)
Ubuntu 26.04.1 LTS x86_64; toolchains installed via elan.

### Additional Information


```
-- Lib.lean
def answer : Nat := 40 + 2
theorem ans : answer = 42 := rfl
```

```
-- consumer.lean
import Lib
theorem use : answer + 0 = 42 := rfl
```

<details><summary>verify.sh (exit 0 ⇒ reproduces) + captured output</summary>

```bash
#!/usr/bin/env bash
# Repro: truncated .olean import segfaults lean and leanchecker. exit 0 = finding reproduces.
set -u; ELAN="$HOME/.elan/bin/elan"; export PATH="$HOME/.elan/bin:$PATH"; cd "$(dirname "$0")"; ulimit -c 0
fail=0
for tc in ${AUDIT_TCS:-leanprover/lean4:v4.36.0 leanprover/lean4:v4.33.1 leanprover/lean4:v4.37.0-rc1}; do
  d=$(mktemp -d); cp Lib.lean consumer.lean "$d"/
  (cd "$d" && $ELAN run "$tc" lean -o Lib.olean Lib.lean) >/dev/null 2>&1 || { echo "BUILD FAIL $tc"; fail=1; continue; }
  sz=$(stat -c%s "$d/Lib.olean"); head -c $((sz*9/10)) "$d/Lib.olean" > "$d/Lib.olean.t"; mv "$d/Lib.olean.t" "$d/Lib.olean"
  (cd "$d" && LEAN_PATH=. $ELAN run "$tc" lean consumer.lean >/dev/null 2>&1); ec=$?
  LC=$("$ELAN" run "$tc" lean --print-prefix)/bin/leanchecker
  (cd "$d" && LEAN_PATH=. "$LC" Lib >/dev/null 2>&1); lc=$?
  [ $ec -eq 139 ] && echo "PASS lean $tc: exit 139 (SIGSEGV)" || { echo "FAIL lean $tc: exit $ec (want 139)"; fail=1; }
  [ $lc -eq 139 ] && echo "PASS leanchecker $tc: exit 139 (SIGSEGV)" || { echo "FAIL leanchecker $tc: exit $lc (want 139)"; fail=1; }
  rm -rf "$d"
done
exit $fail
```

```
./verify.sh: line 9: 1540261 Segmentation fault         (core dumped) LEAN_PATH=. $ELAN run "$tc" lean consumer.lean > /dev/null 2>&1
./verify.sh: line 11: 1540276 Segmentation fault         (core dumped) LEAN_PATH=. "$LC" Lib > /dev/null 2>&1
PASS lean leanprover/lean4:v4.36.0: exit 139 (SIGSEGV)
PASS leanchecker leanprover/lean4:v4.36.0: exit 139 (SIGSEGV)
./verify.sh: line 9: 1540416 Segmentation fault         (core dumped) LEAN_PATH=. $ELAN run "$tc" lean consumer.lean > /dev/null 2>&1
./verify.sh: line 11: 1540431 Segmentation fault         (core dumped) LEAN_PATH=. "$LC" Lib > /dev/null 2>&1
PASS lean leanprover/lean4:v4.33.1: exit 139 (SIGSEGV)
PASS leanchecker leanprover/lean4:v4.33.1: exit 139 (SIGSEGV)
./verify.sh: line 9: 1540462 Segmentation fault         (core dumped) LEAN_PATH=. $ELAN run "$tc" lean consumer.lean > /dev/null 2>&1
./verify.sh: line 11: 1540525 Segmentation f
```
</details>

Memory-safety class (untrusted-input bounds check). Per this template's guidance, coordinated disclosure to security@lean-fro.org is intended.

### Impact

Crash of any import pipeline that touches a malformed olean; crash-only (no code execution demonstrated).
