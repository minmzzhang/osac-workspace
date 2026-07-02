# Step 1: Trigger Nightly Build

## Preflight Checks

Before triggering, run these checks silently. Only report failures.

```bash
# Verify gh CLI auth
gh auth status >/dev/null 2>&1 || { echo "❌ Not authenticated with gh CLI"; exit 1; }

# Check for already-running nightly builds
RUNNING=$(gh run list --repo osac-project/osac-installer \
  --workflow nightly-build.yaml --status in_progress --json databaseId --jq 'length')
```

If `RUNNING > 0`, print:
```text
⚠️ Nightly build already in progress (Run #<ID>)
```
Ask user: "Wait for it?" / "Cancel it and start fresh?" / "Just monitor the existing one?"

## Show Current State

```bash
# Latest nightly tag
LATEST_TAG=$(gh api repos/osac-project/osac-installer/tags --jq '
  [.[] | select(.name | startswith("v") and contains("nightly"))] | first | .name // "none"
')

# Chart.yaml base version
BASE_VERSION=$(gh api repos/osac-project/osac-installer/contents/charts/osac/Chart.yaml \
  --jq '.content' | base64 -d | grep '^version:' | awk '{print $2}')
```

Print:
```text
  Latest nightly: <LATEST_TAG>
  Base version:   <BASE_VERSION>
```

## Trigger

```bash
RUN_URL=$(gh workflow run nightly-build.yaml \
  --repo osac-project/osac-installer \
  --ref main 2>&1)
```

If user specified a branch via argument, use `--ref <branch>` instead of `main`.

Wait 5 seconds, then fetch the run ID:
```bash
sleep 5
RUN_ID=$(gh run list --repo osac-project/osac-installer \
  --workflow nightly-build.yaml --status in_progress \
  --json databaseId --jq 'first | .databaseId')
```

Print:
```text
🚀 Nightly build triggered (Run #<RUN_ID>)
   https://github.com/osac-project/osac-installer/actions/runs/<RUN_ID>
```

Proceed to `steps/monitor.md`.
