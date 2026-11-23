#!/usr/bin/env bash
# `#print axioms S9` shows [Classical.choice] in its own module but "does not depend on any
# axioms" in an importing module (while S9.mk still reports the choice). exit 0 = reproducible.
set -u; ELAN="$HOME/.elan/bin/elan"; export PATH="$HOME/.elan/bin:$PATH"; cd "$(dirname "$0")"; fail=0
tc=leanprover/lean4:v4.36.0; d=$(mktemp -d); cp A.lean B.lean "$d"/
a=$(cd "$d" && $ELAN run "$tc" lean -o A.olean A.lean && LEAN_PATH=. $ELAN run "$tc" lean B.lean 2>&1)
echo "$a"
echo "$a" | tail -2 | head -1 | grep -q "does not depend on any axioms" && echo "PASS: S9 underreported" || { echo "FAIL"; fail=1; }
echo "$a" | tail -1 | grep -q "Classical.choice" && echo "PASS: S9.mk still reports choice (contradiction visible in one run)" || { echo "FAIL control"; fail=1; }
rm -rf "$d"; exit $fail
