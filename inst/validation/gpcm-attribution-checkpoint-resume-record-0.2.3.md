# GPCM attribution checkpoint/resume record for mfrmr 0.2.3

Status: repository-only draft.44 structural evidence, 2026-08-05. This record
does not rerun the draft.43 feasibility cells, freeze a statistical criterion,
authorize the guarded core tier, or create confirmation evidence.

## Decision

The replicated-attribution runner now checkpoints one complete `DataCellId` at
a time. A cell contains the four prespecified `GPCM_JML`, `GPCM_MML`,
`PCM_JML`, and `PCM_MML` routes over one common generated/retained dataset.
Row-level checkpoints were rejected because they would make a partially
available route set look reusable before paired-data identity could be audited.

Core execution remains blocked by the unfinished metamorphic property grid and
replication design, but it is no longer blocked by an all-or-nothing runtime
writer.

## Identity contract

Every checkpoint is bound to `mfrmr-gpcm-repilot-checkpoint-v1`. Its execution
hash combines:

- the selected manifest serialization and the manifest's declared hash;
- tier, replicate count, `maxit`, quadrature points, and residual-PCA switch;
- a content hash of the actually loaded mfrmr installation, based on its
  installed `DESCRIPTION`, `NAMESPACE`, R lazy-load database, and native
  runtime files if present;
- content hashes of the replicated, isolated-attribution, and covering-grid
  validation runners; and
- an explicit capability manifest for R, mfrmr, `digest`, `Matrix`, `lpSolve`,
  `psych`, BLAS/LAPACK reporting, platform, and `RNGkind()`. Available R
  packages carry content hashes as well as version strings, so a locally
  modified same-version dependency is a distinct execution identity.

Absolute package and runner paths are recorded for provenance but excluded
from composite hashes. Moving identical bytes does not manufacture a new
statistical execution identity. Changing any selected row, execution control,
runtime package, runner, reported numerical environment, RNG contract, or
optional audit capability does.

The current feasibility dry-run identity under the checked public mfrmr
installation is:

| Field | SHA-256 |
| --- | --- |
| Selected feasibility manifest | `e5e51bbc27726294dd14fab51ab4cb3f059250b331d9c83f779b47771bbc1f72` |
| Declared attribution manifest | `07989badd83624129d3182c3a1bd118def23ad7159265047ffea6cedc475213c` |
| Loaded mfrmr runtime package | `28d3bb9d2a30c519f0d092be2149a819ab4de2dd03c27fb157c09bf7bf4038f8` |
| Three-runner composite | `44cb49f5378e2c3df960951829351164ba63b81014a8d712bdbdfe006366a560` |
| Capability manifest | `e7448ae6361dc97e367049b89ae3bd68cfa38799dd53fddb2d6596a077e9bada` |
| Complete execution identity | `6d305a4ae108dde910a137892e78a0ec841e186957ff4fa76aeafcc75ecf5fee` |

The replicated runner file itself has SHA-256
`f2b2e9db19a93ba4884cc9b669784b382799d1c876acc53920ffd0a446305d10`.
The public tarball remains the exact draft.43 tarball with SHA-256
`88EBD28817AD1924A9AE235F56301264D5EC47FD06A9416D6A4BA55C5C59DFA6`
and `R CMD check --as-cran` log SHA-256
`B3956B95ABCB26BDE6D9CBD1A675ED9DE4C5365970B3F86FAEAA0B7FBDB8AA3D`
(`Status: OK`). The checkpoint runner and this record remain excluded from that
public payload.

## Atomicity and validation

A new cell is serialized to a same-directory `.partial` file, read back, and
compared by payload hash before one filesystem rename publishes the `.rds`
checkpoint. Existing target checkpoints are never overwritten. Orphan
`.partial` files are ignored; unexpected `.rds` files fail closed.

Resume requires an explicit `resume = TRUE`. Each reused cell must pass all of
the following checks:

1. checkpoint class and schema;
2. complete execution-identity equality;
3. data-cell and cell-manifest hash equality;
4. result payload hash equality;
5. exact ScenarioId and four-route sets;
6. result DataCellId and declared-manifest equality; and
7. readable RDS serialization.

Final CSV/RDS outputs are written only after all cells have been reconstructed.
A `run-complete.rds` marker is then published atomically and contains hashes of
the aggregate artifacts and default checkpoint files. A completed directory
is valid only if the marker schema, execution identity, inventory hash, every
listed file, and every listed file hash agree. A partial aggregate writer
therefore cannot be mistaken for a completed evidence bundle.

## Tests performed

The repository-only protocol test replaces the statistical route function with
a deterministic schema-compatible stub and verifies:

- interruption after the first four-route cell leaves exactly one checkpoint;
- resume reuses that cell, executes the other nine one-replicate feasibility
  cells, and produces 40 rows total;
- the resumed results, paired contrasts, and analysis are equal to a clean
  ten-cell execution;
- registry controls reflect the actual `maxit`, quadrature, and PCA arguments;
- runner identity does not contain the absolute repository path;
- an existing checkpoint cannot be reused without explicit resume and an
  unexpected RDS file blocks the directory;
- an orphan `.partial` file is ignored;
- changed `maxit` is rejected as an execution-identity mismatch;
- a modified checkpoint is rejected by the completed-artifact hash audit; and
- an internally hash-consistent completion marker with an absolute or parent-
  traversing artifact path is rejected before file access; and
- the completion marker validates immediately after writing.

The complete `test-release-readiness-protocol.R` file passed under R 4.5.1.
In addition, one real reference data cell was run through both the new
checkpoint path and the prior isolated-attribution path with four model routes,
`maxit = 20`, three MML quadrature points, and PCA disabled. Every result field
except elapsed runtime agreed. Reading the new checkpoint reproduced the full
new-path result exactly.

## Remaining boundary

This is execution-integrity evidence, not evidence that a statistical model is
correct. It does not calibrate recovery, coverage, false-ready rates, residual
PCA, bias, weak bridges, sparse target-size behavior, or FACETS/TAM/immer
normalization. The draft.43 feasibility artifacts predate this schema and are
retained as a completed historical record; they cannot be resumed or silently
relabelled as checkpoint-v1 evidence.

Before guarded core execution, the next blocker is the explicit metamorphic
grid across row permutation, filtered-then-permuted rows, nonlexical Person
labels, unused/retained factor levels, positive weights, and zero-weight rows
for RSM, PCM, and GPCM MML. The core replication count and MCSE/precision rule
must also be chosen before inspecting its outcomes.
