# FairZ confirmation status — 2026-09-15

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
stores process/session identities, cell groups and restart precautions;
[saved counts](../../validation-results/fairz-confirmation-20260915/paused-checkpoints.csv)
were read directly from the RDS checkpoints. Resume only when requested by
the user, after verifying process identities and source/backend identity.
Do not remove locks belonging to suspended live processes.

If the processes have ended, resume from the disk checkpoints using the
existing runner after verifying that any remaining locks are stale.
Suspension time may count toward the four-hour invocation ceiling and
in-flight timing fields; account for it in eventual runtime reporting.
The protocol, seeds, estimators and statistical criteria were not changed.
