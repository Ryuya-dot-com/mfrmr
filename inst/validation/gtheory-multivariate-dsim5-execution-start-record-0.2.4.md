# D-SIM-5 execution-start record

Date: 2026-09-01
Status: **all fifty admitted shards complete; denominator closed; scientific adjudication complete with fail disposition**

The admitted D-SIM-5 confirmation entered planned execution with
`D5-SHARD-001`. The first immutable outer checkpoint, `D5-A00001.rds`, was
atomically committed before this record was written. This changes the planned
857/858 state from unopened to opened and makes the earlier executor
qualification's “execution not started” statement historical.

This is an operational start record, not an interim analysis. No coefficient,
interval, acceptance result, or terminal outcome was inspected. Progress was
limited to checkpoint counts and attempt identities. Execution must continue
to all 50 admitted shards and all 15,000 retained outer terminal checkpoints;
the observed contents of any partial shard cannot cancel, replace, replenish,
or reprioritize that denominator.

After 100 ordered checkpoints, the process was deliberately paused at the
preselected D4-S002 scenario boundary because three unrelated long-running R
simulation processes were already active on the host. Reissuing the identical
shard command validated all 100 committed result hashes, skipped them without
using their values or terminal states, and committed checkpoint 101
(`D5-A05001.rds`). The process was then paused again. Thus exact resume is now
observed on planned evidence. Reissuing the same command once more validated
the 101 retained checkpoints and resumed at `D5-A05002.rds`. Execution then
continued through the preselected D4-S003 scenario boundary and was paused
immediately after `D5-A05050.rds`; no `D5-A07501.rds` checkpoint was created.
The next identical invocation validated all 150 hashes and resumed at
`D5-A07501.rds`. An interrupt sent after checkpoint 200 was observed arrived
after the already-running checkpoint 201 had been atomically committed. The
valid planned checkpoint was retained rather than deleted or repeated. A final
identical invocation validated all 201 hashes, resumed at `D5-A10002.rds`, and
stopped at the next preselected scenario boundary after `D5-A10050.rds`; no
`D5-A12501.rds` checkpoint was created. Thus 250/300 outer identities in
`D5-SHARD-001` and 250/15,000 in the full denominator are committed. The next
exact identity is `D5-A12501`.

The same command then validated all 250 retained hashes and completed the
interval-enabled final block from `D5-A12501.rds` through `D5-A12550.rds`
without interruption. The executor emitted `DSIM5_SHARD_COMPLETE` only after
all 300 ordered checkpoints were present and wrote the immutable shard
receipt. Filesystem-only verification found 300 checkpoints, exactly 50 in
each of the six scenario blocks, with both the first and last identities
present. No checkpoint result value or terminal state was read. Consequently,
`D5-SHARD-001` is complete, while the confirmation remains incomplete: 300 of
15,000 outer identities and one of 50 admitted shards are committed.

Execution next opened `D5-SHARD-002` at `D5-A00051.rds`. After its first 50
interval-enabled checkpoints, the interrupt requested at the scenario boundary
arrived after the fast point-only checkpoint 51 (`D5-A02551.rds`) had already
committed. The valid planned identity was retained. The identical command then
validated all 51 hashes, resumed at `D5-A02552.rds`, and ran without interim
stops through the four point-only blocks. It was paused after
`D5-A10100.rds`, before the final interval-enabled block: filesystem-only
verification found 250 checkpoints and every five-block endpoint, while
`D5-A12551.rds` was absent. No result value or terminal state was read.
Therefore `D5-SHARD-002` is 250/300 and the full denominator is 550/15,000.

The next identical invocation validated those 250 hashes and completed the
final interval-enabled block from `D5-A12551.rds` through `D5-A12600.rds`
without interruption. The executor emitted `DSIM5_SHARD_COMPLETE` and wrote
the immutable receipt only after all 300 ordered checkpoints were present.
Filesystem-only verification found all 300 files and every scenario endpoint;
no result value or terminal state was read. `D5-SHARD-002` is therefore
complete. Across the admitted denominator, 600/15,000 outer identities and
2/50 shards are complete.

Execution then opened `D5-SHARD-003` at `D5-A00101.rds`. Its first
interval-enabled block and all four point-only blocks ran continuously through
`D5-A10150.rds`. The process was interrupted before the final interval block.
Filesystem-only verification found exactly 250 checkpoints and all five block
endpoints, while `D5-A12601.rds` was absent. No result value or terminal state
was read. `D5-SHARD-003` is therefore 250/300 and the admitted denominator is
850/15,000.

The identical command then validated those 250 hashes and completed the final
interval-enabled block from `D5-A12601.rds` through `D5-A12650.rds` without
interruption. The executor emitted `DSIM5_SHARD_COMPLETE` and wrote the
immutable receipt only after all 300 ordered checkpoints were present.
Filesystem-only verification found all 300 files and every scenario endpoint;
no result value or terminal state was read. `D5-SHARD-003` is therefore
complete. Across the admitted denominator, 900/15,000 outer identities and
3/50 shards are complete.

Execution then opened `D5-SHARD-004` at `D5-A00151.rds` and ran all six
scenario blocks continuously through `D5-A12700.rds` in one process. The
executor emitted `DSIM5_SHARD_COMPLETE` and wrote the immutable receipt only
after all 300 ordered checkpoints were present. Filesystem-only verification
found all 300 files and every scenario endpoint; no result value or terminal
state was read. Across the admitted denominator, 1,200/15,000 outer identities
and 4/50 shards are complete.

Execution then opened `D5-SHARD-005` at `D5-A00201.rds` and ran all six
scenario blocks continuously through `D5-A12750.rds` in one process. The
executor emitted `DSIM5_SHARD_COMPLETE` and wrote the immutable receipt only
after all 300 ordered checkpoints were present. Filesystem-only verification
found all 300 files and every scenario endpoint; no result value or terminal
state was read. Across the admitted denominator, 1,500/15,000 outer identities
and 5/50 shards are complete.

Execution then opened `D5-SHARD-006` at `D5-A00251.rds` and ran all six
scenario blocks continuously through `D5-A12800.rds` in one process. The
executor emitted `DSIM5_SHARD_COMPLETE` and wrote the immutable receipt only
after all 300 ordered checkpoints were present. Filesystem-only verification
found all 300 files and every scenario endpoint; no result value or terminal
state was read. Across the admitted denominator, 1,800/15,000 outer identities
and 6/50 shards are complete.

Execution then opened `D5-SHARD-007` at `D5-A00301.rds` and ran all six
scenario blocks continuously through `D5-A12850.rds` in one process. The
executor emitted `DSIM5_SHARD_COMPLETE` and wrote the immutable receipt only
after all 300 ordered checkpoints were present. Filesystem-only verification
found all 300 files and every scenario endpoint; no result value or terminal
state was read. Across the admitted denominator, 2,100/15,000 outer identities
and 7/50 shards are complete.

Execution then opened `D5-SHARD-008` at `D5-A00351.rds` and ran all six
scenario blocks continuously through `D5-A12900.rds` in one process. The
executor emitted `DSIM5_SHARD_COMPLETE` and wrote the immutable receipt only
after all 300 ordered checkpoints were present. Filesystem-only verification
found all 300 files and every scenario endpoint; no result value or terminal
state was read. Across the admitted denominator, 2,400/15,000 outer identities
and 8/50 shards are complete.

Execution then opened `D5-SHARD-009` at `D5-A00401.rds` and ran all six
scenario blocks continuously through `D5-A12950.rds` in one process. The
executor emitted `DSIM5_SHARD_COMPLETE` and wrote the immutable receipt only
after all 300 ordered checkpoints were present. Filesystem-only verification
found all 300 files and every scenario endpoint; no result value or terminal
state was read. Across the admitted denominator, 2,700/15,000 outer identities
and 9/50 shards are complete.

Execution then opened `D5-SHARD-010` at `D5-A00451.rds` and ran all six
scenario blocks continuously through `D5-A13000.rds` in one process. The
executor emitted `DSIM5_SHARD_COMPLETE` and wrote the immutable receipt only
after all 300 ordered checkpoints were present. Filesystem-only verification
found all 300 files and every scenario endpoint; no result value or terminal
state was read. Across the admitted denominator, 3,000/15,000 outer identities
and 10/50 shards are complete.

Execution then opened `D5-SHARD-011` at `D5-A00501.rds` and ran all six
scenario blocks continuously through `D5-A13050.rds` in one process. The
executor emitted `DSIM5_SHARD_COMPLETE` and wrote the immutable receipt only
after all 300 ordered checkpoints were present. Filesystem-only verification
found all 300 files and every scenario endpoint; no result value or terminal
state was read. Across the admitted denominator, 3,300/15,000 outer identities
and 11/50 shards are complete.

Execution then opened `D5-SHARD-012` at `D5-A00551.rds` and ran all six
scenario blocks continuously through `D5-A13100.rds` in one process. The
executor emitted `DSIM5_SHARD_COMPLETE` and wrote the immutable receipt only
after all 300 ordered checkpoints were present. Filesystem-only verification
found all 300 files and every scenario endpoint; no result value or terminal
state was read. Across the admitted denominator, 3,600/15,000 outer identities
and 12/50 shards are complete.

Execution then opened `D5-SHARD-013` at `D5-A00601.rds` and ran all six
scenario blocks continuously through `D5-A13150.rds` in one process. The
executor emitted `DSIM5_SHARD_COMPLETE` and wrote the immutable receipt only
after all 300 ordered checkpoints were present. Filesystem-only verification
found all 300 files and every scenario endpoint; no result value or terminal
state was read. Across the admitted denominator, 3,900/15,000 outer identities
and 13/50 shards are complete.

Execution then opened `D5-SHARD-014` at `D5-A00651.rds` and ran all six
scenario blocks continuously through `D5-A13200.rds` in one process. The
executor emitted `DSIM5_SHARD_COMPLETE` and wrote the immutable receipt only
after all 300 ordered checkpoints were present. Filesystem-only verification
found all 300 files and every scenario endpoint; no result value or terminal
state was read. Across the admitted denominator, 4,200/15,000 outer identities
and 14/50 shards are complete.

Execution then opened `D5-SHARD-015` at `D5-A00701.rds` and ran all six
scenario blocks continuously through `D5-A13250.rds` in one process. The
executor emitted `DSIM5_SHARD_COMPLETE` and wrote the immutable receipt only
after all 300 ordered checkpoints were present. Filesystem-only verification
found all 300 files and every scenario endpoint; no result value or terminal
state was read. Across the admitted denominator, 4,500/15,000 outer identities
and 15/50 shards are complete.

Execution then opened `D5-SHARD-016` at `D5-A00751.rds` and was deliberately
interrupted after three atomically committed checkpoints at `D5-A00753.rds`.
The identical command validated all three retained hashes, resumed at
`D5-A00754.rds`, and completed all six scenario blocks through
`D5-A13300.rds`. The executor emitted `DSIM5_SHARD_COMPLETE` and wrote the
immutable receipt only after all 300 ordered checkpoints were present.
Filesystem-only verification found all 300 files and every scenario endpoint;
no result value or terminal state was read. Across the admitted denominator,
4,800/15,000 outer identities and 16/50 shards are complete.

Execution then opened `D5-SHARD-017` at `D5-A00801.rds` and ran all six
scenario blocks continuously through `D5-A13350.rds` in one process. The
executor emitted `DSIM5_SHARD_COMPLETE` and wrote the immutable receipt only
after all 300 ordered checkpoints were present. Filesystem-only verification
found all 300 files and every scenario endpoint; no result value or terminal
state was read. Across the admitted denominator, 5,100/15,000 outer identities
and 17/50 shards are complete.

Execution then opened `D5-SHARD-018` at `D5-A00851.rds` and ran all six
scenario blocks continuously through `D5-A13400.rds` in one process. The
executor emitted `DSIM5_SHARD_COMPLETE` and wrote the immutable receipt only
after all 300 ordered checkpoints were present. Filesystem-only verification
found all 300 files and every scenario endpoint; no result value or terminal
state was read. Across the admitted denominator, 5,400/15,000 outer identities
and 18/50 shards are complete.

Execution then opened `D5-SHARD-019` at `D5-A00901.rds` and ran all six
scenario blocks continuously through `D5-A13450.rds` in one process. The
executor emitted `DSIM5_SHARD_COMPLETE` and wrote the immutable receipt only
after all 300 ordered checkpoints were present. Filesystem-only verification
found all 300 files and every scenario endpoint; no result value or terminal
state was read. Across the admitted denominator, 5,700/15,000 outer identities
and 19/50 shards are complete.

Execution then opened `D5-SHARD-020` at `D5-A00951.rds` and ran all six
scenario blocks continuously through `D5-A13500.rds` in one process. The
executor emitted `DSIM5_SHARD_COMPLETE` and wrote the immutable receipt only
after all 300 ordered checkpoints were present. Filesystem-only verification
found all 300 files and every scenario endpoint; no result value or terminal
state was read. Across the admitted denominator, 6,000/15,000 outer identities
and 20/50 shards are complete.

Execution then opened `D5-SHARD-021` at `D5-A01001.rds` and ran all six
scenario blocks continuously through `D5-A13550.rds` in one process. The
executor emitted `DSIM5_SHARD_COMPLETE` and wrote the immutable receipt only
after all 300 ordered checkpoints were present. Filesystem-only verification
found all 300 files and every scenario endpoint; no result value or terminal
state was read. Across the admitted denominator, 6,300/15,000 outer identities
and 21/50 shards are complete.

Execution then opened `D5-SHARD-022` at `D5-A01051.rds` and ran all six
scenario blocks continuously through `D5-A13600.rds` in one process. The
executor emitted `DSIM5_SHARD_COMPLETE` and wrote the immutable receipt only
after all 300 ordered checkpoints were present. Filesystem-only verification
found all 300 files and every scenario endpoint; no result value or terminal
state was read. Across the admitted denominator, 6,600/15,000 outer identities
and 22/50 shards are complete.

Execution then opened `D5-SHARD-023` at `D5-A01101.rds` and ran all six
scenario blocks continuously through `D5-A13650.rds` in one process. The
executor emitted `DSIM5_SHARD_COMPLETE` and wrote the immutable receipt only
after all 300 ordered checkpoints were present. Filesystem-only verification
found all 300 files and every scenario endpoint; no result value or terminal
state was read. Across the admitted denominator, 6,900/15,000 outer identities
and 23/50 shards are complete.

Execution then opened `D5-SHARD-024` at `D5-A01151.rds`. The single process
was intentionally interrupted after checkpoint 271 (`D5-A13671.rds`) and the
unchanged runner subsequently resumed at the exact next identity,
`D5-A13672.rds`, before completing all six scenario blocks through
`D5-A13700.rds`. The executor emitted `DSIM5_SHARD_COMPLETE` and wrote the
immutable receipt only after all 300 ordered checkpoints were present.
Filesystem-only verification found all 300 files and every scenario endpoint;
no result value or terminal state was read. Across the admitted denominator,
7,200/15,000 outer identities and 24/50 shards are complete.

After `D5-SHARD-024` completed and the D-SIM process count returned to zero,
two unchanged `preflight` commands were run concurrently as a capacity-only
qualification. Both exited zero, returned the frozen contract
`a64facef158aaf7f4e4463512af9b7367195f708d45183e2cd3d5d63ec9bf6f3` and
manifest `e7a6442be5c1f5f987d5f5283c380f7a07c3ff9e7aef4cc187348814067d1fa7`,
qualified all 50 shards, reported `execution_started=FALSE` and
`rng_opened=FALSE`, and overlapped in wall time. A concurrent process sample
recorded RSS values of 319,424 KiB and 315,456 KiB on this 36-GiB host. The
remaining acquisition may therefore use at most two simultaneous execution
processes, only for distinct shard IDs launched in shard order. Concurrent
execution of the same shard is prohibited, the cumulative record advances only
over the contiguous completed prefix, and four-way execution remains
unqualified. This operational ceiling changes no frozen executor, runner,
contract, manifest, launch input, seed, attempt identity, or denominator; no
scientific result informed the decision.

Execution then opened distinct `D5-SHARD-025` and `D5-SHARD-026` processes
concurrently under that ceiling, beginning at `D5-A01201.rds` and
`D5-A01251.rds`. Both unchanged runners completed all six scenario blocks
through `D5-A13750.rds` and `D5-A13800.rds`, exited zero, emitted
`DSIM5_SHARD_COMPLETE`, and wrote immutable receipts only after their 300
ordered checkpoints were present. Filesystem-only verification found all 300
files and every scenario endpoint in each shard; no result value or terminal
state was read. The contiguous completed prefix is therefore 7,800/15,000
outer identities and 26/50 shards.

Execution then opened distinct `D5-SHARD-027` and `D5-SHARD-028` processes
concurrently under the same ceiling, beginning at `D5-A01301.rds` and
`D5-A01351.rds`. Both unchanged runners completed all six scenario blocks
through `D5-A13850.rds` and `D5-A13900.rds` and wrote immutable receipts only
after their 300 ordered checkpoints were present. Filesystem-only verification
found all 300 files and every scenario endpoint in each shard; no result value
or terminal state was read. The contiguous completed prefix is therefore
8,400/15,000 outer identities and 28/50 shards.

Execution then opened distinct `D5-SHARD-029` and `D5-SHARD-030` processes
concurrently under the same ceiling, beginning at `D5-A01401.rds` and
`D5-A01451.rds`. Both unchanged runners completed all six scenario blocks
through `D5-A13950.rds` and `D5-A14000.rds`, exited zero, emitted
`DSIM5_SHARD_COMPLETE`, and wrote immutable receipts only after their 300
ordered checkpoints were present. Filesystem-only verification found all 300
files and every scenario endpoint in each shard; no result value or terminal
state was read. The contiguous completed prefix is therefore 9,000/15,000
outer identities and 30/50 shards.

Execution then opened distinct `D5-SHARD-031` and `D5-SHARD-032` processes
concurrently under the same ceiling, beginning at `D5-A01501.rds` and
`D5-A01551.rds`. Both unchanged runners completed all six scenario blocks
through `D5-A14050.rds` and `D5-A14100.rds` and wrote immutable receipts only
after their 300 ordered checkpoints were present. Filesystem-only verification
found all 300 files and every scenario endpoint in each shard; no result value
or terminal state was read. The contiguous completed prefix is therefore
9,600/15,000 outer identities and 32/50 shards.

Execution then opened distinct `D5-SHARD-033` and `D5-SHARD-034` processes
concurrently under the same ceiling, beginning at `D5-A01601.rds` and
`D5-A01651.rds`. Both unchanged runners completed all six scenario blocks
through `D5-A14150.rds` and `D5-A14200.rds`, exited zero, emitted
`DSIM5_SHARD_COMPLETE`, and wrote immutable receipts only after their 300
ordered checkpoints were present. Filesystem-only verification found all 300
files and every scenario endpoint in each shard. The contiguous completed
prefix is therefore 10,200/15,000 outer identities and 34/50 shards.

At this boundary, a read-only operational integrity audit applied the existing
executor assertions to all 10,200 checkpoints in `D5-SHARD-001` through
`D5-SHARD-034`. All 34 jobs and receipts were valid; all 10,200 attempt IDs were
unique; all generated-data hashes were present; all responses and backend
calls were recorded; and all 22,100/22,100 primary fits returned. Of the
10,200 outer attempts, 10,186 reached their design-expected completion state.
Fourteen retained terminal attempts in `D4-S005` were
`primary_fit_or_target_failure`: 15/22,100 derived primary-coefficient rows
were unavailable with `primary_target_nonfinite`, while every stored primary
numeric coefficient was finite. All 1,353,200/1,353,200 planned inner fits and
targets completed, all 2,706,400 bootstrap metric rows were finite, and all
13,600 interval rows were available. These counts describe execution and data
integrity only; no effect comparison, acceptance decision, replacement, or
scientific adjudication was performed.

Execution then opened distinct `D5-SHARD-035` and `D5-SHARD-036` processes
concurrently under the same ceiling, beginning at `D5-A01701.rds` and
`D5-A01751.rds`. Both unchanged runners completed all six scenario blocks
through `D5-A14250.rds` and `D5-A14300.rds`, exited zero, emitted
`DSIM5_SHARD_COMPLETE`, and wrote immutable receipts only after their 300
ordered checkpoints were present. Metadata-only verification found all 300
files and every scenario endpoint in each shard; no result value or terminal
state was read. The contiguous completed prefix is therefore 10,800/15,000
outer identities and 36/50 shards.

Execution then opened distinct `D5-SHARD-037` and `D5-SHARD-038` processes
concurrently under the same ceiling, beginning at `D5-A01801.rds` and
`D5-A01851.rds`. Both unchanged runners completed all six scenario blocks
through `D5-A14350.rds` and `D5-A14400.rds`, exited zero, emitted
`DSIM5_SHARD_COMPLETE`, and wrote immutable receipts only after their 300
ordered checkpoints were present. Metadata-only verification found all 300
files and every scenario endpoint in each shard; no result value or terminal
state was read. The contiguous completed prefix is therefore 11,400/15,000
outer identities and 38/50 shards.

Execution then opened distinct `D5-SHARD-039` and `D5-SHARD-040` processes
concurrently under the same ceiling, beginning at `D5-A01901.rds` and
`D5-A01951.rds`. Both unchanged runners completed all six scenario blocks
through `D5-A14450.rds` and `D5-A14500.rds`, exited zero, emitted
`DSIM5_SHARD_COMPLETE`, and wrote immutable receipts only after their 300
ordered checkpoints were present. Metadata-only verification found all 300
files and every scenario endpoint in each shard; no result value or terminal
state was read. The contiguous completed prefix is therefore 12,000/15,000
outer identities and 40/50 shards.

Execution then opened distinct `D5-SHARD-041` and `D5-SHARD-042` processes
concurrently under the same ceiling, beginning at `D5-A02001.rds` and
`D5-A02051.rds`. Both unchanged runners completed all six scenario blocks
through `D5-A14550.rds` and `D5-A14600.rds`, exited zero, emitted
`DSIM5_SHARD_COMPLETE`, and wrote immutable receipts only after their 300
ordered checkpoints were present. Metadata-only verification found all 300
files and every scenario endpoint in each shard; no result value or terminal
state was read. The contiguous completed prefix is therefore 12,600/15,000
outer identities and 42/50 shards.

Execution then opened distinct `D5-SHARD-043` and `D5-SHARD-044` processes
concurrently under the same ceiling, beginning at `D5-A02101.rds` and
`D5-A02151.rds`. Both unchanged runners completed all six scenario blocks
through `D5-A14650.rds` and `D5-A14700.rds`, exited zero, emitted
`DSIM5_SHARD_COMPLETE`, and wrote immutable receipts only after their 300
ordered checkpoints were present. Metadata-only verification found all 300
files and every scenario endpoint in each shard; no result value or terminal
state was read. The contiguous completed prefix is therefore 13,200/15,000
outer identities and 44/50 shards.

Execution then opened distinct `D5-SHARD-045` and `D5-SHARD-046` processes
concurrently under the same ceiling, beginning at `D5-A02201.rds` and
`D5-A02251.rds`. Both unchanged runners completed all six scenario blocks
through `D5-A14750.rds` and `D5-A14800.rds`, exited zero, emitted
`DSIM5_SHARD_COMPLETE`, and wrote immutable receipts only after their 300
ordered checkpoints were present. Metadata-only verification found all 300
files and every scenario endpoint in each shard; no result value or terminal
state was read. The contiguous completed prefix is therefore 13,800/15,000
outer identities and 46/50 shards.

Execution then opened distinct `D5-SHARD-047` and `D5-SHARD-048` processes
concurrently under the same ceiling, beginning at `D5-A02301.rds` and
`D5-A02351.rds`. Both unchanged runners completed all six scenario blocks
through `D5-A14850.rds` and `D5-A14900.rds`, exited zero, emitted
`DSIM5_SHARD_COMPLETE`, and wrote immutable receipts only after their 300
ordered checkpoints were present. Metadata-only verification found all 300
files and every scenario endpoint in each shard; no result value or terminal
state was read. The contiguous completed prefix is therefore 14,400/15,000
outer identities and 48/50 shards.

Execution then opened the final distinct `D5-SHARD-049` and `D5-SHARD-050`
processes concurrently under the same ceiling, beginning at `D5-A02401.rds`
and `D5-A02451.rds`. Both unchanged runners completed all six scenario blocks
through `D5-A14950.rds` and `D5-A15000.rds`, exited zero, emitted
`DSIM5_SHARD_COMPLETE`, and wrote immutable receipts only after their 300
ordered checkpoints were present. Metadata-only verification found all 300
files and every scenario endpoint in each shard; no result value or scientific
outcome was read. The contiguous completed prefix is therefore 15,000/15,000
outer identities and 50/50 shards.

A complete-denominator identity closure then reapplied the existing executor
assertions to every stored job, receipt, and checkpoint. It found 50 exact
shards, 15,000 unique admitted attempt identities, 15,000 one-to-one terminal
identity records, 995,000 registered inner attempts, and 2,022,500 registered
backend fit calls, with zero missing, duplicate, or foreign identities. The
metadata-only closure hash is
`ac47234f184edbcb3860f0e7e00de8888efe802b98d739af8a0b4f5f3ef9d4a6`.
This closes acquisition and execution identity only; no scientific
adjudication was computed.

## Bound identities

- executor contract: `a64facef158aaf7f4e4463512af9b7367195f708d45183e2cd3d5d63ec9bf6f3`
- executor qualification manifest: `e7a6442be5c1f5f987d5f5283c380f7a07c3ff9e7aef4cc187348814067d1fa7`
- admission manifest: `8f13db52ad19cbe5adcda0aabb6be6ec8ff949cb555d6043ea1dba0e74972510`
- launch input: `e93d5de438a99d89f89d51f24c9dcd58393dc52127b90926133c7e50a0c91071`
- `D5-SHARD-001` hash: `0652fcc15705ebe595eebcd06f8518aa59486d55e557b4a2bb199d66d0bf7003`
- `D5-SHARD-001` job hash: `14ba45490e85d108bbe798c9b839e4c7b0dc36930c119e7ce2727d0bde81576a`
- `D5-SHARD-001` receipt hash: `32b5194a9ef88d714333bd42229185eb7db921e7df83d90c3b9f2b33b05a7677`
- `D5-SHARD-002` hash: `eff5f13e6e0203486fa746f71241ba77c45940da4af30d45a2ea4482562f0d7b`
- `D5-SHARD-002` job hash: `f9c23aa878a7c2afa7fdf164b125e6c610258b6286768db10bc6d8d0f2cb43ea`
- `D5-SHARD-002` receipt hash: `4ba9ec159fc27c9f338c3ade40fdd816d7c72e8f8fbb0101273b94aa475df156`
- `D5-SHARD-003` hash: `54bc5ac70e6c1ceeac304979239c421435371fc849be32a81760c897885aa045`
- `D5-SHARD-003` job hash: `4689786758eb57312c43724152be42039e9f4ccb7053fe4e364a67384811378a`
- `D5-SHARD-003` receipt hash: `6e3a285a1f36c6d6939fb1382cae60333be0faefcf3b4d4242db02a4b643db55`
- `D5-SHARD-004` hash: `65b4676310613841babbb5e29445ea21879d021ec7b12f3a797a3ee2ac10675f`
- `D5-SHARD-004` job hash: `26a3bb517eb27394889f04e6a312aa23ed1ed0e9bac1ad1165f1618a640074ba`
- `D5-SHARD-004` receipt hash: `90a962b9e50d62d1e5bcd9b28c64602f260d91f4decc51f486f37094a840a144`
- `D5-SHARD-005` hash: `af4888638888643a296620694ea6f58b2ac9ca26cc8418af8a66d9504ab4fdc8`
- `D5-SHARD-005` job hash: `849ffee77d41cf8f8c20519164f9deeab5e505b3499e912c6c195b9823c2e8e2`
- `D5-SHARD-005` receipt hash: `c24a2fa8e81be7487fa7ee5e0ee4b8a6c0a80aca753391d8ea44e1adc2bec7bb`
- `D5-SHARD-006` hash: `26fa4c031275181fe8419c55a269eadf804c7dbf6998285e71a63decc6ccab74`
- `D5-SHARD-006` job hash: `62a9dab704ad7b31022a870579a0fe9c4204c6914777fae1b19df5e8d0eb5fb1`
- `D5-SHARD-006` receipt hash: `d76990ca319ae6d1055027683ae57b3a4272001c4c013eb777e780a256862891`
- `D5-SHARD-007` hash: `eb173a203693b70a5cbe143427f2b14efabf69638c097ed97486b3702d5930ac`
- `D5-SHARD-007` job hash: `fb83f97898a7db47f27561d2b8aa22ca0e7b338908321043032da6a7255a99e8`
- `D5-SHARD-007` receipt hash: `632ce9ca6766f26453c56a7a53cea7beaaa860789b6952bcd986e42c3cda8157`
- `D5-SHARD-008` hash: `fb178ef987113b2da2dcff8f66914654ee69d6e150e67ba953ffab813c3fd724`
- `D5-SHARD-008` job hash: `a42d72bd2ff56b4f7aa7b3808fed48c196bb60b81212230970c07b6af1dc9af5`
- `D5-SHARD-008` receipt hash: `d0f96a35fe71f4415ecbbd49018d83af56cbfcc297935b67be81b7a53a6ec85c`
- `D5-SHARD-009` hash: `64d27b94181a6e46ae44372b484c096f43c81ea7ee55aab0641a2e98c2933068`
- `D5-SHARD-009` job hash: `25f5a13abc44b5860de0110b942e225fff4af40b0747c192f45f707ebf1ab0b6`
- `D5-SHARD-009` receipt hash: `8f70b30e32649789f18e3577e28cea8fed9a1304d5c556d772141a22aab25dff`
- `D5-SHARD-010` hash: `cdfcbfac0c74e15580548b6179dd4691da8552a763bff048705fa8c98abcfa2c`
- `D5-SHARD-010` job hash: `275cb93781f1cb0a43d12d252393d29806ddfd842abfabbe2f70e3c8647f6c15`
- `D5-SHARD-010` receipt hash: `882d36b46bde8b5510ef790ecfaf33ac571af943b4eb30373fab0cf7fc5b2939`
- `D5-SHARD-011` hash: `5ddaa9c2153ef16716cfd3601ab7b83dbf75e1cf360b4eb1c8ce8b7790c7b123`
- `D5-SHARD-011` job hash: `48e7745c80c695cd9c4b5241539237aa7169d9aec922fe8ae5c004159402f034`
- `D5-SHARD-011` receipt hash: `40656ea08b8e813ff39b34859352b8b47b14ca528d1c7520a6343ff780a1b8c8`
- `D5-SHARD-012` hash: `1f5b5e8a99f19edefa5dbc0e7b845e5b0b4d9dbf639f40d581b7371b1447ac7a`
- `D5-SHARD-012` job hash: `6bb1eb81f9a1e75dbd052971457d52ac12f4abd47dcb9f812477064a9e623710`
- `D5-SHARD-012` receipt hash: `1543b4e0a460ef7daf4bb82776c2db5a153250680b5bec7ce35cfcf9d916bdee`
- `D5-SHARD-013` hash: `ab344740957bfe644da359b76c387f62d07ea7e51610f04a912a5441478f55b7`
- `D5-SHARD-013` job hash: `f2aea06f6024f58c93693cc26188116b77f9c3d6c96b89b0d27e7bd8211c0cc7`
- `D5-SHARD-013` receipt hash: `09c6c06e8cd8dcf73a5945e584dbf9a9c9cff640ab760dd7063d41f9b003aca3`
- `D5-SHARD-014` hash: `8d52a68837009d3eaa41099096f27a2962833c220ca111e7797214a9b566af13`
- `D5-SHARD-014` job hash: `2439266d0a9d4a3d88fd0b0c58c1daceecaa0932bb3b55643d6ad49b3fc2f5c6`
- `D5-SHARD-014` receipt hash: `44f8a2f92f34d76a04c001a027a5966354889da66e33eae17f837a0625444425`
- `D5-SHARD-015` hash: `8af41c6730176035c2b435a42e677c2d2f1b67b0f518eaa00abf2c435357691f`
- `D5-SHARD-015` job hash: `53d8c81d8bdd3b03d091b590f626b844048e08e3c09456a7d96c59dbd7663cd5`
- `D5-SHARD-015` receipt hash: `2709cb631184883be124a3bd162e62dd77eae86574c12f016987d67d86b2a00c`
- `D5-SHARD-016` hash: `fab0b672dca4848b75497a6a0b2c522e8356e5a050d23c6ff5f533860592e0dd`
- `D5-SHARD-016` job hash: `2b5cd9bf178361ea2ab4bd12135330adc2df0f9d38b04a576f4b2f19df5b7cf8`
- `D5-SHARD-016` receipt hash: `7547ca1ea4f73e9461bbd24d1a81058b033a34d0b337c415b789988f53ebe120`
- `D5-SHARD-017` hash: `cb9636befc891254b3cd39479cc2f107d727c6ca708a65d9650dcd1f21f8829c`
- `D5-SHARD-017` job hash: `e609bece34c80a1e7ea61b3e0033a1b39b4ef7828a7512d06b2a298383c1ba99`
- `D5-SHARD-017` receipt hash: `bff2b9a081d99534a345523e2ce068d0974ab3411663e1f55fdbdd94129f0bb6`
- `D5-SHARD-018` hash: `6143b161ceab95dede1d670ef7c42918e9d57f5d4508d073c9c590a3f187f24e`
- `D5-SHARD-018` job hash: `9f40a95fc8c4124f3196ce44af8663e1050ec4609c3e0fdfea95a7a914c11563`
- `D5-SHARD-018` receipt hash: `cb6cf26851ddcbad0c6b87aa8891f62c4de098df7133425aac1e8b574dca9666`
- `D5-SHARD-019` hash: `123aa1cc7d6f142291a1f7b761ab5220edcc0ba7d6bec69ad28cdc589ca18f35`
- `D5-SHARD-019` job hash: `25df731278454b3e2358b602c48c46df2b055c6fa95a405c68df898bd343b0c0`
- `D5-SHARD-019` receipt hash: `4b91aee074302d8d79922903109b85412b9af40b02237c0b1d4c48748c4c2ce1`
- `D5-SHARD-020` hash: `5048ae9c90ec48c29c3fe799eae8e1e0de0ca8b255d6f6935bae7c7ce94b4866`
- `D5-SHARD-020` job hash: `7c312e76a1c6972e33bb1134584f8223c2565625bfdcf470c152c8b019df1f1e`
- `D5-SHARD-020` receipt hash: `db7bbd4ba9066b00edf1763c58bcdcbf5be58476d113522e3a079119542482c0`
- `D5-SHARD-021` hash: `d7eb00fd50dfb5f2dc6d482575a7b5a3914e9c62872ad4a20654320892fedd81`
- `D5-SHARD-021` job hash: `f17d47d1763e77e873e1c33cd844e77cc5153327077bed0aeec6b882844aae67`
- `D5-SHARD-021` receipt hash: `d92d8c29e6f646932cf4db481e77b169e35f1a9edeb6e72e3f016c69259021db`
- `D5-SHARD-022` hash: `50df641f4c492525a337d1dc0605673d73402da5b8a262e032ab355e184e28bb`
- `D5-SHARD-022` job hash: `113e28ea6852d07ba8cbd6237628a03bfffb1dab568b2cadb3fb06508d24f4f4`
- `D5-SHARD-022` receipt hash: `b7d327c09c37af793e317c7a10e1ca3e126a7104d40d115776a840e235fb3511`
- `D5-SHARD-023` hash: `1db0725b9d94730ecf1cfd05d8db024c138e46b0cf7afe5840029a35a09b18b2`
- `D5-SHARD-023` job hash: `08cd9cf7db531d96e7927ee97b12674ad63af9ea20a52edb914a4dea0c6ce46f`
- `D5-SHARD-023` receipt hash: `85a203a8180a4511c4f6029832acc860f8bbbe88647fe86e5a3086c2993511aa`
- `D5-SHARD-024` hash: `7b16a10a650d507e030f72584a97e1322b5640fcffda27beaf4035f9c7ba33e7`
- `D5-SHARD-024` job hash: `39c3f28f539b1aaf3b3f90e3b64c9b4340b37963402426ff15bdbd59608a89bc`
- `D5-SHARD-024` receipt hash: `99e2626af7e95fed862190b8d9531170830fbbcfdb707c39b6ad9dbb8b16e3e2`
- `D5-SHARD-025` hash: `05c56c332eccd85c38dff03cb626c3b37cdc7a737ecbf23d122f4448195f2102`
- `D5-SHARD-025` job hash: `8088c70205f6bbf8d304488a595b549e2dcd47fda0a54d513163bc67fc3c03ec`
- `D5-SHARD-025` receipt hash: `602ed08b1ae31e07cec7d8b726ad8768269d956bff16d7c9ff049ef7db46ebda`
- `D5-SHARD-026` hash: `6c1561949abd15d59103a706ab3accede8da0fbe9fda4ee0b6492b99d123a553`
- `D5-SHARD-026` job hash: `378969b58637b3206f763fec144415ac672e6a757157db784911d78b20e49341`
- `D5-SHARD-026` receipt hash: `beb6b50a19136d6b857f1567b4efd4714df9ac295b0806bc7675ae0f33685b4e`
- `D5-SHARD-027` hash: `d600f233899f539e1dc57b96cc6bcc0ca62ddfc7e8b29818fbd49132b764918e`
- `D5-SHARD-027` job hash: `f7a97dda1874d9c18297c0933e7f97ee3b09e6f506c72c62c8a4f9c62b447be2`
- `D5-SHARD-027` receipt hash: `212c63cdf24faeeaee4ca18c63b44c3f929ad599d5a2fdd0b115cf1478e218b2`
- `D5-SHARD-028` hash: `f0b66f9fae88bd7cc8c218ddccfeedb3cc7182d0e0e4e2ed7728d6ed87729911`
- `D5-SHARD-028` job hash: `23583461f3f6e8a2efd048d3545b1b5df6643f063255cc4daf9d00f2eec912f1`
- `D5-SHARD-028` receipt hash: `5fa509b177bbdab0bca1dde64c8409b8e41271b38a7928331eca4cb8322ee0e3`
- `D5-SHARD-029` hash: `109e955f2bd01da73170441c16af2c0aa49f2ddfa493d58da7d3dc56ae1c9bf0`
- `D5-SHARD-029` job hash: `b5af96cc18cf3c877e8f12f27ca5671ce1d83447faee7d8eb4fa7ced1a84c2b2`
- `D5-SHARD-029` receipt hash: `056d3a3bbe7a8aed29032469c5f8f0bad960a0243ea950a392dd8ff38986482c`
- `D5-SHARD-030` hash: `4cc69492b8dd9d495d57db704551a25742c6474621fea25d72213a4c377e96a3`
- `D5-SHARD-030` job hash: `85af52091649c448d72073a750df0ca62100a0ceea85e21a5a775cbe1d445d45`
- `D5-SHARD-030` receipt hash: `1ac119c12e955774781cd361aa31d2a690517aa8708bf6bdef24199e08591dc0`
- `D5-SHARD-031` hash: `428efb7afabb8909b272ca50c0a75e35bfd690972d24caf308fd9ead558509b1`
- `D5-SHARD-031` job hash: `a317d9bbd1d9293f8d0cebfd0a3e17d872f1e6362a5052ebf6646761fd7cc766`
- `D5-SHARD-031` receipt hash: `73394a4cdae4b37d16550e0218a8300c011689e29ba8a6e06d2837d2174c06ec`
- `D5-SHARD-032` hash: `89501785370ad2fb31c38d09c23e06b4826e0ce14895655fc067182acd98ef5d`
- `D5-SHARD-032` job hash: `330703f1897230c013ddd33ea2c9f5066390ecae0a4c380d84b7011e3741475b`
- `D5-SHARD-032` receipt hash: `97af384bd556519eafc055de566d2fdfe88af22001a98de6e23a787b1b6a9e28`
- `D5-SHARD-033` hash: `fb78f4fcd457f75f3d9b17fd9b0f5662d6e38e56bdf9a6786f5aee247fd54b2f`
- `D5-SHARD-033` job hash: `e60807738860bfd219a0efbb4b1bfce64298701de7299a0f15b224c0f2734719`
- `D5-SHARD-033` receipt hash: `fa1e5270ee02a1c1cd5916f66d5fe8d27fb4bd492deafb027686fef8d663b829`
- `D5-SHARD-034` hash: `09dd3d780943802ad7131fcc2ff21c84227ca064c055ecc6537e602223242119`
- `D5-SHARD-034` job hash: `fa527e686faa5e45694a4b210d79872be5d0ba4f6747dabe13eec747296d9446`
- `D5-SHARD-034` receipt hash: `d36234af1a692e6bd577fac7e58a1d126fd2fec2ae590f44eff3dc2c6f4a4837`
- `D5-SHARD-035` hash: `41d7bb157a70227f4a627c8df935e4f115ba34af6ffe46ba37122f65e5d0934a`
- `D5-SHARD-035` job hash: `45a6bee1cc059c6b3bda23e40908e595c66d5731ffc14654b0057afe7ee85ca5`
- `D5-SHARD-035` receipt hash: `bb7ff0ebae0022a2d8a9c5ffe2ff51824a53843bda57fea2ca992577313021fb`
- `D5-SHARD-036` hash: `d2a431309a254a4a1511f37cfee2bc6cea08abfc9aa7f2cb8b9838b3dfcd0ea9`
- `D5-SHARD-036` job hash: `5e3a447a3130ac54c126a3c7197b1d5702d21eef810d06fe129de914e79c0cff`
- `D5-SHARD-036` receipt hash: `159b88770b45dc62ae65bb6c19c368fac3eb79443fe028dc71106d3207ffff00`
- `D5-SHARD-037` hash: `fab44d4da3e57cb04608ebbff163ad6fbab7f8061f61eadb4370edd36bcb85b4`
- `D5-SHARD-037` job hash: `3714c451a1d705a7c7e8656e8fd8854448ef1571c684991dc751b49013834871`
- `D5-SHARD-037` receipt hash: `8ad51dbc7073240f149f2833fa0dacdf381d2315cc671491b8bd2f1e35a5363a`
- `D5-SHARD-038` hash: `466b39881c688b6910245b5582558628b71771323633c28562b5befc72fa5045`
- `D5-SHARD-038` job hash: `597deef0362cd92227826ca5c252f05ab2364e31bc0771ce257a47eb728c434f`
- `D5-SHARD-038` receipt hash: `61c71bab84a498f256ff82291c9f5847df21b1104da691a542c9c973cb44d28d`
- `D5-SHARD-039` hash: `b7fcfc224c683d1f29618943ca4829915d56d416e63bf2a5ae6db37e419cc201`
- `D5-SHARD-039` job hash: `7159cc7a88d5ed20f62c6b607902e46d9ec542176694774546b99183025e8406`
- `D5-SHARD-039` receipt hash: `c36ec02b3e996b99d9fe3ba24a768933a1d98c5bcd94a6ef1418de6b45ade77b`
- `D5-SHARD-040` hash: `9302b86966573eea31b0dc4919403c6374c0867e9dbed3c3c803434a7c0b87a1`
- `D5-SHARD-040` job hash: `10a426257e98dd7e50f9bd19c3d16d094bc381478712e8ecd69e9b616fa6987b`
- `D5-SHARD-040` receipt hash: `b68e98d11dc520ca911bdeb6e05b58c699e39b00aa01d23a2497c3d1425bf348`
- `D5-SHARD-041` hash: `1902ac963e6fc1d7ab627e1c29a68c83d9d03d1b13221c6fbc1fc5b75305c688`
- `D5-SHARD-041` job hash: `e5b5b4c1892e17191cc88dfb22ae7ec033fe4e46053407e3d8e7f796c726f555`
- `D5-SHARD-041` receipt hash: `55d39aa9a2a4156d4e2ad66fc696d149717f8a94fe43b51f70cb09ffc810d787`
- `D5-SHARD-042` hash: `0e1fa7185eea19372ac0c53a076661a12cb80b71e319973b721e464d27a755d9`
- `D5-SHARD-042` job hash: `090da29f552434443bf00d3cac1f0c89ba87916c541dde2e827926899080ae44`
- `D5-SHARD-042` receipt hash: `25ef881427f754c331173275b0bbedb5b9cfa58621df9f681325752f3a36703b`
- `D5-SHARD-043` hash: `ae7ae8080d992ef798755a0694d4b9f64c976fb1a75ee430fc054ef040a259a8`
- `D5-SHARD-043` job hash: `d337d9336d9c93ffbfc65b084d2070c265d4be112ed31b24612bd0d3c1566a6f`
- `D5-SHARD-043` receipt hash: `8a6edf6b0ec1d08d56ee4d7e2f8b08f84a6e7dda3e60cb062ecf4e597240b34e`
- `D5-SHARD-044` hash: `abf6f287ce062783178475e6c2f6c70569c230d98a107c8bc4e2362d50dde27a`
- `D5-SHARD-044` job hash: `391993d96d3f1e9712cd1cf94fda6e6519de5740f300faa44c3b962977ec1ec1`
- `D5-SHARD-044` receipt hash: `31c71bb4a7832d74b80878a703aaca59b87e706e141a34982f29edc4614ec0a5`
- `D5-SHARD-045` hash: `918767e6fdba04729aa7fdfca3ad91a2db95682131c6a46bf6c57875f35d94b4`
- `D5-SHARD-045` job hash: `ed6196fdf37068cbe32cb70d14520d59897b7570d432e7b552298a8ca571d931`
- `D5-SHARD-045` receipt hash: `d565e6d680a26dd71445779c853fe3e7acaae5336d973c0f85d1ba45dcce03d9`
- `D5-SHARD-046` hash: `4ea0e889cde8c266b34f7f66c092b14bcc9172f6d75f358a2a1c39d1a54de469`
- `D5-SHARD-046` job hash: `c0ab8779172be8c7366660397a66e2082b9e117f1ad7e4d6a7c1b9047cfe0a87`
- `D5-SHARD-046` receipt hash: `dca0ceb4084d40a42c9a4324c007e2e2700e29b7afd79a0ecc21a6adc4d8100d`
- `D5-SHARD-047` hash: `54131c139aeda331f5bea9171f49fce09349183f5d0d3a390a1b997cf9fb64f4`
- `D5-SHARD-047` job hash: `78d502299432ab6d339dd0c73dc2ac11eaed9d9e10c8c0340933425e2cb1dce3`
- `D5-SHARD-047` receipt hash: `f9bf0c373de49ee67ce5eea7b9fc1f2a7dcd3189c4154ed44234c9fc7bd56c60`
- `D5-SHARD-048` hash: `bc8b4f5a0884ed3e099eebb84a7cafc86e3376ac0d91db1018a522bfc2758e1a`
- `D5-SHARD-048` job hash: `927b5b5f555bdf7ede579a7ddd22031e7bb9439458d1c5f3c16ebc467fbc5517`
- `D5-SHARD-048` receipt hash: `19a78d4112e94c56d68d003d4a8a97c6e1a7562d73023f0959b7ce57cdca111c`
- `D5-SHARD-049` hash: `ce09b43562e409c64d28e00e87d8df54d9310c3c488d7db6e206dc269c898ed5`
- `D5-SHARD-049` job hash: `8167df4a1cbbc8007d443ddb00a132242f06136149718da94f10cd71de4b42ca`
- `D5-SHARD-049` receipt hash: `05a5bf63c0e181b2e2eb1e6f53ee8fb97c9d68e200b49933900d15a1f00ee35f`
- `D5-SHARD-050` hash: `a61927cd5229cdaf1cf433716417d7a6b90c471d89d94f0286fc498ce9ecc10d`
- `D5-SHARD-050` job hash: `8002e739f2680d468ed1110e4f0b3e20ec8eeb5de49b4eb43893129a21e7eafb`
- `D5-SHARD-050` receipt hash: `0017f3dd25d91cb1f53e54ef17c37fc1f2c2a6a45247b54e28e045cfc6e02168`
- complete-denominator identity closure hash: `ac47234f184edbcb3860f0e7e00de8888efe802b98d739af8a0b4f5f3ef9d4a6`
- executor source SHA-256: `44ffdfda0f72c43af036f1e99187c5286adcf273d543158cd677a5f85ad07735`
- execution runner SHA-256: `8d4a21fee77507f9af7e916280f43e4e28e86f18c4d5f51ca77f4baaaab29b94`

## Final claim ceiling

- planned execution started: **yes**
- 857/858 RNG identities opened: **yes**
- complete-denominator result values scientifically adjudicated: **yes**
- planned exact resume observed: **yes, in four completed shards**
- completed admitted shards: **50/50**
- active admitted shards: **0 (acquisition complete)**
- current-host execution ceiling: **2 processes for distinct shard IDs; same-shard duplication prohibited**
- currently committed outer checkpoints: **15,000/15,000**
- complete 15,000-attempt denominator available: **yes; identity closure passed**
- complete-denominator adjudication: **fail for ABS-PHI and REL-G**
- simulation validation ready: **no**
- public support ready: **no**

Acquisition, blind assembler qualification, and one frozen adjudication are
complete. The detailed negative result and exact artifact identities are in
`gtheory-multivariate-dsim5-complete-denominator-adjudication-record-0.2.4.md`.
No threshold, scenario, estimator, interval, seed, or denominator was changed,
and no public promotion follows.
