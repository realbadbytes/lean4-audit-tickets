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
