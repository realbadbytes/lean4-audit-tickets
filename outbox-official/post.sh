#!/usr/bin/env bash
# Post the staged audit findings to leanprover/lean4.
# Usage: GITHUB_TOKEN=<classic PAT with repo scope for realbadbytes> ./post.sh
set -eu; cd "$(dirname "$0")"; : "${GITHUB_TOKEN:?set GITHUB_TOKEN to a classic PAT (repo scope) for realbadbytes}"
python3 - "$GITHUB_TOKEN" <<'PYEOF'
import json, subprocess, sys
tok = sys.argv[1]
plan = json.load(open("plan.json"))
for it in plan:
    if it["kind"] == "issue":
        path, payload = "/repos/leanprover/lean4/issues", {"title": it["title"], "body": it["body"], "labels": ["bug"]}
    else:
        path, payload = f'/repos/leanprover/lean4/issues/{it["issue"]}/comments', {"body": it["body"]}
    r = subprocess.run(["curl", "-s", "-X", "POST",
                        "-H", f"Authorization: Bearer {tok}",
                        "-H", "Accept: application/vnd.github+json",
                        "-d", json.dumps(payload), f"https://api.github.com{path}"],
                       capture_output=True, text=True)
    d = json.loads(r.stdout or "{}")
    print(("OK  " if "html_url" in d else "FAIL"), it.get("title") or f'#{it["issue"]}',
          d.get("html_url") or d.get("message"))
PYEOF
