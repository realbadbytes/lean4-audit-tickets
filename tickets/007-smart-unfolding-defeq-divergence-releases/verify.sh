#!/usr/bin/env bash
# master's regression test (fixed 2026-11-23, PRs #16682/83/84) run on RELEASE toolchains:
# elaborator claims `rfl` succeeds, then the C++ kernel rejects the refl proof. exit 0 = reproducible.
set -u; ELAN="$HOME/.elan/bin/elan"; export PATH="$HOME/.elan/bin:$PATH"; cd "$(dirname "$0")"; fail=0
for tc in leanprover/lean4:v4.36.0 leanprover/lean4:v4.37.0-rc1; do
  out=$($ELAN run "$tc" lean smartUnfoldingDiscriminant.lean 2>&1)
  echo "$out" | grep -q 'fail_if_success.*succeeded\|succeeded but was expected to fail' \
    && echo "$out" | grep -q '(kernel) declaration type mismatch' \
    && echo "PASS $tc: elab accepts rfl / kernel rejects (divergence)" \
    || { echo "FAIL $tc: divergence not observed"; fail=1; }
done
exit $fail
