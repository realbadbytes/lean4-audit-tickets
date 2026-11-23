### Prerequisites

* [x] Check that your issue is not already filed — **duplicate of #15652**; this text is prepared for posting as a confirmation comment there.
* [x] Reduce the issue to a minimal, self-contained, reproducible test case. (No Mathlib/Batteries; 1–3 files.)
* [x] Test against the latest nightly (via elan: 4.38.0-nightly-2026-11-23 — results in Versions/Additional below)
* [x] Soundness-bug question re `lake check --paranoid`: N/A — reporting layer; kernel would still reject the sorry term.

### Description

After duplicate-name imports, `#print foo` shows the kept theorem body is `sorry`, while `#print axioms foo` claims **"does not depend on any axioms"** and the module exits 0.

### Context

Confirmation data for #15652 from a 2026-11 audit; still live on current nightly. `#print axioms []` is the community's standard hygiene ritual.

### Steps to Reproduce

1. Build `Good.olean` (`theorem foo : True := trivial`)
2. Build `Bad.olean` (`theorem foo : True := sorry`)
3. `GoodFirst.lean`: `import Good` `import Bad` + `#print foo` + `#print axioms foo`; run `LEAN_PATH=. lean GoodFirst.lean`

**Expected behavior:** `#print axioms foo` lists `sorryAx` (or the duplicate import errors).

**Actual behavior:** ```
sorry
'foo' does not depend on any axioms
```
exit 0 — 4.36.0 and nightly-2026-11-23.

### Versions

Lean (version 4.36.0, x86_64-unknown-linux-gnu, commit 611c117bfaf7b7ae1cfcf246ce6fba31e8f509e9, Release)
Lean (version 4.38.0-nightly-2026-11-23, x86_64-unknown-linux-gnu, commit 231ef9a28b27a9a7ebabdbfa40c84cfb22744c24, Release)
Ubuntu 26.04.1 LTS x86_64; toolchains installed via elan.

### Additional Information


```
-- Bad.lean
theorem foo : 1 + 1 = 2 := sorry
```

```
-- Good.lean
theorem foo : 1 + 1 = 2 := rfl
```

```
-- GoodFirst.lean
import Good
import Bad
#print foo
#print axioms foo
```

<details><summary>verify.sh (exit 0 ⇒ reproduces) + captured output</summary>

```bash
#!/usr/bin/env bash
# After importing Good then Bad (duplicate theorem names), #print foo shows body `sorry`
# while #print axioms foo claims NO axioms. exit 0 = reproducible.
set -u; ELAN="$HOME/.elan/bin/elan"; export PATH="$HOME/.elan/bin:$PATH"; cd "$(dirname "$0")"; fail=0
tc="${AUDIT_TC:-leanprover/lean4:v4.36.0}"; d=$(mktemp -d); cp Good.lean Bad.lean GoodFirst.lean "$d"/
(cd "$d" && $ELAN run "$tc" lean -o Good.olean Good.lean && $ELAN run "$tc" lean -o Bad.olean Bad.lean) >/dev/null 2>&1
out=$(cd "$d" && LEAN_PATH=. $ELAN run "$tc" lean GoodFirst.lean 2>&1); ec=$?
echo "$out"
echo "$out" | grep -q '^sorry$' && echo "PASS: kept body is sorry" || { echo "FAIL: body not sorry"; fail=1; }
echo "$out" | grep -q "does not depend on any axioms" && echo "PASS: axioms list hides sorryAx" || { echo "FAIL"; fail=1; }
[ $ec -eq 0 ] && echo "PASS: exit 0 (no error raised)" || { echo "FAIL: exit $ec"; fail=1; }
rm -rf "$d"; exit $fail
```

```
@[defeq] theorem foo : 1 + 1 = 2 :=
sorry
'foo' does not depend on any axioms
PASS: kept body is sorry
PASS: axioms list hides sorryAx
PASS: exit 0 (no error raised)
```
</details>


### Impact

A `sorry`-backed theorem passes standard axiom audits as clean.
