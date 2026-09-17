# FairZ confirmation status — updated 2026-09-17

**Completed: all 20,000 planned datasets were retained and adjudicated on
September 17.** The frozen primary rules yield five supported cells and
three review cells; none is concern. See the
[final results and retained evidence](fairz-confirmation-results-0.2.4.md).
Public Fair Score interval eligibility remains unchanged (`FairCIEligible = false`).

All eight final states and the matching preflight passed the existing
source/backend/plan/seed/shape validation. Four nonready fits retained their
assigned identities and unavailable intervals; execution errors, ready
numerical conflicts and verification failures were zero. The 24-configuration
output audit also passed. Completion is not a package or release pass.

## September 17 resumption record

The study resumed from 450 saved datasets after the user explicitly requested
source/state verification and resumption.

The original three processes had ended, and a process scan found no other
FairZ writer. The existing validators confirmed identical source payload,
compiled backend, R version/platform, cell definitions, stage, planned count,
seed order and result shapes for all eight complete preflight cells and the
three saved main-study cells. The reviewed source is preserved in commit
`fe8220ce`. The backend MD5 remains `59d00f20719463739c7fcd191e4d28da`.

Only the three empty stale cell locks were removed. Three new R processes
resume the same disjoint groups `(8,1)`, `(4,3)` and `(7,6,2,5)` with the
existing runner. Saved attempts are retained; any unsaved interrupted attempts
use their original assigned seeds. Each cell still stops at 2,500 datasets,
with the unchanged four-hour invocation ceiling and atomic checkpoints every
50 attempts. There is no stopping or extension based on observed coverage.

Restart provenance, initial counts, process IDs and worker logs are under
[`validation-results/checkpoint-20260917/`](../../validation-results/checkpoint-20260917/):
`fairz-resume.json`, `fairz-resume-check.log`, `fairz-resume-counts.csv`, and
`fairz-worker-{1,2,3}.{pid,log}`. The RDS checkpoints remain in the original
`fairz-current-20260915/final-current/confirmation/` directory. Worker logs
give progress between dated status updates; no partial coverage judgment is
assigned. New invocation timers exclude the suspension because the original
processes ended; preserve the September 15 timing records separately.

## Preserved September 15 pause record

**Paused at the user's request: 450/20,000 datasets checkpointed.**
The current-source preflight/backend identity check passed before launch.
The frozen confirmation was started in three local R processes, using
disjoint cell groups `(8,1)`, `(4,3)` and `(7,6,2,5)`.

Saved counts are cell 4: 150, cell 7: 200 and cell 8: 100; other cells have
not started. These 450 saved attempts have no recorded errors, warnings or
numerical conflicts. No coverage or statistical disposition is assigned to
this incomplete experiment. Public Fair Score interval eligibility is unchanged.

All three R processes were suspended with `SIGSTOP` and verified in state
`T`. Their unsaved in-memory state is retained. The
[pause record](../../validation-results/fairz-confirmation-20260915/pause.json)
stores the original process/session identities, cell groups and restart precautions;
[saved counts](../../validation-results/fairz-confirmation-20260915/paused-checkpoints.csv)
were read directly from the RDS checkpoints. At that time, resumption required
a user request and process/source/backend verification. That request and the
completed checks are recorded above. Locks belonging to suspended live
processes must not be removed.

If the processes have ended, resume from the disk checkpoints using the
existing runner after verifying that any remaining locks are stale.
Suspension time may count toward the four-hour invocation ceiling and
in-flight timing fields; account for it in eventual runtime reporting.
The protocol, seeds, estimators and statistical criteria were not changed.
