# Step 3: Verify and Report

## Verify Chart Publications

For each chart, confirm it exists in GHCR:

```bash
REGISTRY="oci://ghcr.io/osac-project/charts"
# VERSION is from the monitor step

CHARTS=(
  "osac-operator-crds"
  "osac-operator"
  "fulfillment-service"
  "osac-aap"
  "bare-metal-fulfillment-operator-crds"
  "bare-metal-fulfillment-operator"
  "osac-ui"
  "osac"
)

for chart in "${CHARTS[@]}"; do
  helm show chart "${REGISTRY}/${chart}" --version "${VERSION}" >/dev/null 2>&1
  # Print ✅ or ❌ per chart
done
```

Print verification progress:
```text
📦 Verifying published charts...
  ✅ osac-operator-crds
  ✅ osac-operator
  ✅ fulfillment-service
  ✅ osac-aap
  ✅ bare-metal-fulfillment-operator-crds
  ✅ bare-metal-fulfillment-operator
  ✅ osac-ui
  ✅ osac (umbrella)
```

## Check Git Tag

```bash
TAG="v${VERSION}"
gh api "repos/osac-project/osac-installer/git/refs/tags/${TAG}" >/dev/null 2>&1
```

Print:
```text
🏷️ Tag: v<VERSION>
```

## Display Results Table

Print the final formatted table per `guidelines.md`:

```text
Nightly Build v<VERSION> - Published

┌────────────────────────────────────────┬──────────────────────────────────────┬──────────────────────────────────────────────────────────────────────────┐
│ Chart                                  │ Version                              │ Registry                                                                 │
├────────────────────────────────────────┼──────────────────────────────────────┼──────────────────────────────────────────────────────────────────────────┤
│ osac-operator-crds                     │ <VERSION>                            │ oci://ghcr.io/osac-project/charts/osac-operator-crds                     │
│ osac-operator                          │ <VERSION>                            │ oci://ghcr.io/osac-project/charts/osac-operator                          │
│ fulfillment-service                    │ <VERSION>                            │ oci://ghcr.io/osac-project/charts/fulfillment-service                    │
│ osac-aap                               │ <VERSION>                            │ oci://ghcr.io/osac-project/charts/osac-aap                               │
│ bare-metal-fulfillment-operator-crds   │ <VERSION>                            │ oci://ghcr.io/osac-project/charts/bare-metal-fulfillment-operator-crds   │
│ bare-metal-fulfillment-operator        │ <VERSION>                            │ oci://ghcr.io/osac-project/charts/bare-metal-fulfillment-operator        │
│ osac-ui                                │ <VERSION>                            │ oci://ghcr.io/osac-project/charts/osac-ui                                │
│ osac (umbrella)                        │ <VERSION>                            │ oci://ghcr.io/osac-project/charts/osac                                   │
└────────────────────────────────────────┴──────────────────────────────────────┴──────────────────────────────────────────────────────────────────────────┘
```

## Download Artifacts (optional)

Ask user if they want to download the build artifacts:

```bash
gh run download "${RUN_ID}" --repo osac-project/osac-installer \
  --dir "./nightly-artifacts"
```

This downloads:
- `osac-<VERSION>.tgz` (packaged umbrella chart)
- `images.txt` (container image manifest)

## Status-Only Mode

If user invoked the skill with "check nightly status" (not "trigger"), skip
Steps 1-2 and instead:

```bash
# Get the latest completed nightly run
RUN_ID=$(gh run list --repo osac-project/osac-installer \
  --workflow nightly-build.yaml --status completed --limit 1 \
  --json databaseId,conclusion,createdAt,headSha \
  --jq 'first')
```

Then proceed directly to verification and display the table for the most
recent successful build.
