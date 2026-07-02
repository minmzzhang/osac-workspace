# Step 2: Monitor Build Progress

## Polling Strategy

Poll every 30 seconds until the workflow completes. Show each job's status as
it transitions.

```bash
REPO="osac-project/osac-installer"
# RUN_ID is from the trigger step

gh run view "${RUN_ID}" --repo "${REPO}" \
  --json status,conclusion,jobs \
  --jq '{status, conclusion, jobs: [.jobs[] | {name, status, conclusion}]}'
```

## Status Display

Print a live-updating status block. Update each line as jobs transition:

```text
⏳ Build and publish nightly charts...
⏭️ E2E validation (waiting)
⏭️ Tag and notify (waiting)
```

As jobs complete, update to:

```text
✅ Build and publish nightly charts (4m 12s)
⏳ E2E validation...
⏭️ Tag and notify (waiting)
```

Final success state:

```text
✅ Build and publish nightly charts (4m 12s)
✅ E2E validation (8m 30s)
✅ Tag and notify (12s)
```

## Timing

Calculate duration from the job's `startedAt` and `completedAt` fields:

```bash
gh run view "${RUN_ID}" --repo "${REPO}" \
  --json jobs --jq '.jobs[] | {name, status, conclusion, startedAt, completedAt}'
```

## On Failure

If any job fails:

```bash
FAILED_JOB=$(gh run view "${RUN_ID}" --repo "${REPO}" \
  --json jobs --jq '[.jobs[] | select(.conclusion == "failure")] | first | .name')
```

Print the failure status, then ask user:
```text
❌ <JOB_NAME> — failed

  [Show logs] [Retry run] [Abort]
```

If user chooses "Show logs":
```bash
gh run view "${RUN_ID}" --repo "${REPO}" --log-failed 2>&1 | tail -40
```

If user chooses "Retry run":
```bash
gh run rerun "${RUN_ID}" --repo "${REPO}" --failed
```
Then restart monitoring.

## Completion

On full success, extract the version from job outputs and proceed to
`steps/verify.md`:

```bash
VERSION=$(gh run view "${RUN_ID}" --repo "${REPO}" \
  --json jobs --jq '.jobs[] | select(.name == "Build and publish nightly charts") | .steps[] | select(.name == "Generate nightly version") | .outputs.version' 2>/dev/null)
```

If version extraction from steps fails, parse it from the run logs:
```bash
VERSION=$(gh run view "${RUN_ID}" --repo "${REPO}" --log 2>&1 \
  | grep "Nightly version:" | tail -1 | awk '{print $NF}')
```
