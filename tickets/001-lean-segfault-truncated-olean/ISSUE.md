---
title: "lean and leanchecker segfault (SIGSEGV, exit 139, no diagnostic) when importing a truncated .olean"
labels: [bug, memory-safety]
component: "olean deserialization (lean + leanchecker)"
affected: ["v4.33.1", "v4.36.0 (stable)", "v4.37.0-rc1"]
status: new   # no matching GitHub issue found via search (olean+truncat*, core dump*)
routing: security@lean-fro.org first (memory safety on untrusted input), then public issue
severity: medium (deterministic DoS; unbounded OOB-read posture; .olean is untrusted in cache-sharing model)
---
## Summary
`lean` importing a truncated `.olean` crashes with SIGSEGV + core dump and **zero** diagnostic
output. Same crash in `leanchecker`. Deterministic (3/3 repeats) on three toolchains, incl. stable.
The deserializer evidently trusts section-table offsets against actual file size.

## Reproduction (verify.sh, exit 0 = reproducible)
1. `lean -o Lib.olean Lib.lean` (2-line module; any module works)
2. `head -c 90%` of the olean over it
3. `LEAN_PATH=. lean consumer.lean` (consumer imports Lib) → **exit 139, empty stderr**
4. `leanchecker Lib` → **exit 139**

## Expected vs actual
Expected: clean `malformed/truncated module` error, exit 1 (as `incompatible header` already does).
Actual: SIGSEGV, core dumped, no message. Byte-level control: mid-file flips / appended garbage are
accepted silently (no checksum — see discussion of replay in #16674/#16679).

## Proof
Run `./verify.sh`; transcript in `results.log`. Full-size originals + exit codes per toolchain.
