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
