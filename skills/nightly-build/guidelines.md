# Output Formatting Guidelines

## Icon Vocabulary

| Icon | Meaning |
|------|---------|
| ⏳ | In progress / waiting |
| ✅ | Step passed |
| ❌ | Step failed |
| ⚠️ | Warning (non-fatal) |
| 🚀 | Triggered / launched |
| 📦 | Chart published |
| 🏷️ | Tag created |
| 🔔 | Notification sent |
| ⏭️ | Skipped |

## Output Rules

1. **Never narrate.** No "Let me check...", "Now I will...", "Great, that worked."
2. **One icon line per action.** Format: `ICON Description... result`
3. **Suppress command output.** Use `>/dev/null 2>&1` on success. Show stderr only on failure.
4. **Progress before execution.** Print the icon line, run the command, then update with result.
5. **Tables for results.** Use box-drawing characters for final output tables.

## Status Line Format

```text
⏳ Triggering nightly build on main...
✅ Nightly build triggered (Run #42)

⏳ Build and publish nightly charts...
✅ Build and publish nightly charts (3m 42s)

⏳ E2E validation...
❌ E2E validation — failed at "Deploy chart"
```

## Table Format

Use this exact box-drawing style for the results table:

```text
Nightly Build v0.0.1-nightly.20260702.abc1234.42 - Published

┌────────────────────────────────────────┬──────────────────────────────────────┬──────────────────────────────────────────────────────────────────────────┐
│ Chart                                  │ Version                              │ Registry                                                                 │
├────────────────────────────────────────┼──────────────────────────────────────┼──────────────────────────────────────────────────────────────────────────┤
│ osac-operator-crds                     │ 0.0.1-nightly.20260702.abc1234.42    │ oci://ghcr.io/osac-project/charts/osac-operator-crds                     │
│ osac-operator                          │ 0.0.1-nightly.20260702.abc1234.42    │ oci://ghcr.io/osac-project/charts/osac-operator                          │
│ fulfillment-service                    │ 0.0.1-nightly.20260702.abc1234.42    │ oci://ghcr.io/osac-project/charts/fulfillment-service                    │
│ osac-aap                               │ 0.0.1-nightly.20260702.abc1234.42    │ oci://ghcr.io/osac-project/charts/osac-aap                               │
│ bare-metal-fulfillment-operator-crds   │ 0.0.1-nightly.20260702.abc1234.42    │ oci://ghcr.io/osac-project/charts/bare-metal-fulfillment-operator-crds   │
│ bare-metal-fulfillment-operator        │ 0.0.1-nightly.20260702.abc1234.42    │ oci://ghcr.io/osac-project/charts/bare-metal-fulfillment-operator        │
│ osac-ui                                │ 0.0.1-nightly.20260702.abc1234.42    │ oci://ghcr.io/osac-project/charts/osac-ui                                │
│ osac (umbrella)                        │ 0.0.1-nightly.20260702.abc1234.42    │ oci://ghcr.io/osac-project/charts/osac                                   │
└────────────────────────────────────────┴──────────────────────────────────────┴──────────────────────────────────────────────────────────────────────────┘
```

## Failure Output

On failure, show:
1. Which job failed
2. The failed step name
3. Offer: "Show logs?" / "Retry?"

```text
❌ Nightly Build Failed

  Job:  Build and publish nightly charts
  Step: Publish component charts
  Run:  https://github.com/osac-project/osac-installer/actions/runs/12345

  [Show logs] [Retry]
```
