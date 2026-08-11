# TAM/immer/mfrmr factor-pilot checkpoint contract for mfrmr 0.2.3

Status: repository-only Draft.77 execution-integrity contract, 2026-08-09.

## Purpose

The 290-dataset factor pilot contains 230 datasets with nine attempted method
modes, 40 deliberately structurally unidentified datasets, and 20 guarded
anchor datasets. Requiring all work to survive in memory until the final
aggregate would make interruption an unrecorded selection mechanism. Draft.77
therefore makes one complete dataset the smallest reusable execution unit.

This contract changes no response model, estimator, correction, metric, or
evidence status. Every result remains calibration-only and
`EvidenceReady = FALSE`.

## Execution identity

Every checkpoint is bound to:

- schema `mfrmr-tam-immer-jml-factor-checkpoint-v1`;
- tier and complete manifest SHA-256;
- formals/body hashes for manifest generation, data generation, fitting,
  recovery metrics, cell execution, checkpoint construction, and checkpoint
  validation;
- the loaded mfrmr `fit_mfrm`, TAM `tam.jml`, and immer `immer_jml` version and
  function hashes inherited from Draft.75;
- R version, platform, and RNG-kind identity; and
- the exact manifest-row and dataset identifier for the cell.

The loaded runtime identity is frozen at the first identity query after the
runner is sourced. This is necessary because the development mfrmr function
object acquires a different serialized representation after its first lazy
compilation even though its source-level formals/body and behavior do not
change. Resourcing the runner resets the cache. Runner-function hashes and the
manifest remain independently recomputed, so a source or design change still
invalidates reuse.

## Atomic cell publication

Each cell payload contains exactly one dataset-state row, its realized design
audit, all retained mode and metric rows, and the complete output object when a
fit was attempted. Before publication the runner:

1. hashes the manifest row and payload;
2. serializes to a same-directory temporary file;
3. reads the temporary file and verifies the serialized-object hash; and
4. renames it to the final safe dataset-derived filename.

An existing final path is never overwritten. Unexpected `.rds` files,
unreadable payloads, schema differences, execution differences, row-hash
differences, dataset differences, and payload-hash differences fail closed.
Existing cell files require an explicit `resume = TRUE` call.

## Completion marker

Only after all 290 declared checkpoint files have been read or executed does
the runner create `completion-marker.rds`. The marker binds the execution and
manifest hashes, normalized checkpoint ledger and file hashes, and a result
hash over all deterministic aggregate tables. A marker without every cell is
invalid. A resumed complete run must reconstruct the same result and marker
hash without refitting any cell.

The ledger's `Source` field records `executed` versus `resumed_checkpoint`, but
that operational label is excluded from the normalized result identity. The
scientific aggregate must be identical whether it was completed in one process
or reconstructed from valid checkpoints.

## Tests and prohibitions

Repository tests cover deterministic execution identity, manifest-row
mutation, payload mutation, one-cell intentional interruption, atomic file
creation, and refusal to mix existing files without explicit resume. The
completed pilot additionally passed a 290/290 independent resumed
reconstruction.

- A valid checkpoint proves execution identity and payload integrity, not
  statistical adequacy.
- A completion marker does not promote a pilot to confirmation evidence.
- Checkpoints from a different manifest, runner, runtime, package version, or
  RNG contract are never pooled.
- No result-dependent cell deletion or rerun is permitted.
