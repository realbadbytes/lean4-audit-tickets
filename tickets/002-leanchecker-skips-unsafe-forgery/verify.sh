#!/usr/bin/env bash
# leanchecker (incl. --fresh) exits 0 on module containing unchecked forged `unsafe` False;
# the SAFE twin of the same forgery IS rejected (proves the unsafe-replay-skip is the gap).
set -u; ELAN="$HOME/.elan/bin/elan"; export PATH="$HOME/.elan/bin:$PATH"; cd "$(dirname "$0")"; fail=0
tc=leanprover/lean4:v4.36.0; LC=$("$ELAN" run "$tc" lean --print-prefix)/bin/leanchecker
d=$(mktemp -d); cp ForgeUnsafe.lean ForgeSafeControl.lean "$d"/
(cd "$d" && $ELAN run "$tc" lean -o ForgeUnsafe.olean ForgeUnsafe.lean && $ELAN run "$tc" lean -o ForgeSafeControl.olean ForgeSafeControl.lean) >/dev/null 2>&1
(cd "$d" && LEAN_PATH=. "$LC" ForgeUnsafe >/dev/null 2>&1); a=$?
(cd "$d" && LEAN_PATH=. "$LC" --fresh ForgeUnsafe >/dev/null 2>&1); b=$?
(cd "$d" && LEAN_PATH=. "$LC" ForgeSafeControl >/dev/null 2>&1); c=$?
[ $a -eq 0 ] && echo "PASS: leanchecker ForgeUnsafe exit 0 (accepts forged unsafe False)" || { echo "FAIL: plain exit $a"; fail=1; }
[ $b -eq 0 ] && echo "PASS: leanchecker --fresh ForgeUnsafe exit 0 (skips isUnsafe replay)" || { echo "FAIL: --fresh exit $b"; fail=1; }
[ $c -ne 0 ] && echo "PASS(control): identical SAFE forgery rejected (exit $c)" || { echo "FAIL(control): safe forgery not rejected"; fail=1; }
rm -rf "$d"; exit $fail
