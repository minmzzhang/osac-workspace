---
name: nightly-build
description: >
  Trigger, monitor, and report on OSAC nightly Helm chart builds. Dispatches
  the nightly-build workflow, streams job progress, verifies published charts
  in GHCR, and displays a formatted results table. USE WHEN user says
  "nightly-build", "nightly build", "trigger nightly", "run nightly",
  "check nightly status", or wants to manually kick off a nightly chart build.
triggers:
  - nightly-build
  - nightly build
  - trigger nightly
  - run nightly
  - check nightly status
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
---

# /nightly-build -- OSAC Nightly Chart Build Wizard

Trigger and monitor the nightly build workflow that packages and publishes all
OSAC Helm charts with the latest component versions from main.

**CRITICAL RULES -- read these first:**
- **ZERO narration.** NEVER output filler text. Only formatted status lines
  with icons. No explanations, no transitions, no commentary.
- **Suppress bash output.** Redirect stdout with `>/dev/null`. Keep stderr for
  failure diagnosis. Never show raw git/helm/gh output on success.
- **Print progress BEFORE running.** Show icon lines before the bash command,
  result (check/cross) after.

Read `guidelines.md` for the full output formatting rules, icon vocabulary,
and step-by-step output examples.

**Announce at start:** Print this banner, then proceed to Step 0.

```text
 ███╗   ██╗██╗ ██████╗ ██╗  ██╗████████╗██╗  ██╗   ██╗    ██████╗ ██╗   ██╗██╗██╗     ██████╗
 ████╗  ██║██║██╔════╝ ██║  ██║╚══██╔══╝██║  ╚██╗ ██╔╝    ██╔══██╗██║   ██║██║██║     ██╔══██╗
 ██╔██╗ ██║██║██║  ███╗███████║   ██║   ██║   ╚████╔╝     ██████╔╝██║   ██║██║██║     ██║  ██║
 ██║╚██╗██║██║██║   ██║██╔══██║   ██║   ██║    ╚██╔╝      ██╔══██╗██║   ██║██║██║     ██║  ██║
 ██║ ╚████║██║╚██████╔╝██║  ██║   ██║   ███████╗██║       ██████╔╝╚██████╔╝██║███████╗██████╔╝
 ╚═╝  ╚═══╝╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝       ╚═════╝  ╚═════╝ ╚═╝╚══════╝╚═════╝
```

## Component Registry

The nightly build publishes charts for all OSAC components plus the umbrella:

| Component | Repo | Chart Name | Image |
|-----------|------|-----------|-------|
| osac-operator | osac-project/osac-operator | `osac-operator` + `osac-operator-crds` | `ghcr.io/osac-project/osac-operator` |
| fulfillment-service | osac-project/fulfillment-service | `fulfillment-service` | `ghcr.io/osac-project/fulfillment-service` |
| osac-aap | osac-project/osac-aap | `osac-aap` | `ghcr.io/osac-project/osac-aap` |
| bare-metal-fulfillment-operator | osac-project/bare-metal-fulfillment-operator | `bare-metal-fulfillment-operator` + CRDs | `ghcr.io/osac-project/bare-metal-fulfillment-operator` |
| osac-ui | osac-project/osac-ui | `osac-ui` | `ghcr.io/osac-project/osac-ui` |
| osac (umbrella) | osac-project/osac-installer | `osac` | N/A |

All charts are published to `oci://ghcr.io/osac-project/charts/`.

## Workflow

The skill follows these steps in order. Read the corresponding step file
before executing each one.

1. **Preflight** -- Verify auth, check for in-progress runs, show current state
2. **Trigger** -- Dispatch the workflow (`steps/trigger.md`)
3. **Monitor** -- Poll job status until completion (`steps/monitor.md`)
4. **Verify & Report** -- Confirm charts in GHCR, display table (`steps/verify.md`)

On failure at any step, show the error, offer to display logs, and offer retry.
