#!/usr/bin/env bash
# #16489 (loose-bvar ctor) fires on 4.36.0; #16649 (is_def_eq_unit_like layout confusion)
# fires on BOTH released toolchains (fix unreleased): kernel reports "invalid return type"
# (= x ≡ y accepted for distinct vars) where the fixed kernel reports "application type mismatch".
set -u; ELAN="$HOME/.elan/bin/elan"; export PATH="$HOME/.elan/bin:$PATH"; cd "$(dirname "$0")"; fail=0
o=$($ELAN run leanprover/lean4:v4.36.0 lean e16489.lean 2>&1); echo "$o"
echo "$o" | grep -q 'ACCEPTED' && echo "PASS: #16489 accepted on 4.36.0" || { echo "FAIL 16489"; fail=1; }
for tc in leanprover/lean4:v4.36.0 leanprover/lean4:v4.37.0-rc1; do
  o=$($ELAN run "$tc" lean e16649-punit.lean 2>&1); echo "$o"
  echo "$o" | grep -q "invalid return type" && echo "PASS: #16649 unit-like rule fired on $tc" || { echo "FAIL 16649 on $tc"; fail=1; }
done
exit $fail
