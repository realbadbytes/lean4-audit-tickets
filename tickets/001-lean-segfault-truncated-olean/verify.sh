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
