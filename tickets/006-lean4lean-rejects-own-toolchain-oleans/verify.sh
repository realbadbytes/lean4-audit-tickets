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
