# Fixed-calibration G1 lifecycle and scoring record for mfrmr 0.2.4

Status: `G1_complete_internal_public_gate_closed`, 2026-08-22.

- Production implementation: `R/core-fixed-calibration.R`
- Public constructor/export authorized: `FALSE`
- Persistence implementation complete: `TRUE`
- Prohibited-state exclusion complete: `TRUE`
- Required corruption/mutation slice complete: `TRUE`
- Artifact-only operational scoring complete: `TRUE`
- Terminal lineage transitions complete: `TRUE`
- CORE-01 complete: `TRUE`
- CORE-02 complete: `TRUE`

## Implemented boundary

The unexported core implements draft extraction, structured validation,
immutable validation/freezing/supersession/retirement transitions, print and
summary methods, canonical RDS version-3 save/load, and artifact-only posterior
scoring. It remains restricted to current-readiness, one-scale,
one-dimensional RSM/PCM MML fits under an explicit fixed standard-normal prior
and stored Gauss-Hermite nodes and weights.

Expanded facet, shared-step or owner-specific-step, and complete two-way
interaction coordinates are retained at full precision in typed, canonical
tables. Direct and group facet anchors are retained as declarations. JML,
GPCM, estimated-population, and latent-regression fits fail closed under their
own codes and do not inherit core eligibility.

## Artifact-only scoring

`mfrmr_score_calibration()` is internal. It first revalidates the artifact and
requires exact `frozen` state. Its default new-response policy is all-or-
nothing: malformed column mappings, missing or blank values, unknown scores,
nonpositive or nonfinite weights, unseen facet levels, duplicate Person-by-
all-facets events, and invalid interval levels are reason-coded errors; no row
is silently dropped. G3 has since added explicit missing-response omission and
event-identified repeat policies without weakening this default.

The scorer materializes values only from the expanded artifact coordinate
table. It independently evaluates the RSM or PCM cumulative-logit likelihood,
combines response log likelihoods by Person, applies the stored quadrature
weights, and returns EAP, posterior SD, grid interval, observation count, and
weighted count. Its body does not call `predict_mfrm_units()`,
`compute_person_posterior_summary()`, `build_indices()`, `expand_params()`, or
`fit_mfrm()`.

The numerical suite covers weighted additive RSM and owner-specific PCM
equivalence against the existing fitted-object scorer, one independently
written direct RSM oracle, complete two-way RSM interaction reconstruction,
row-order and per-Person chunk-order invariance, an equivalent frozen
score-map recoding, caller RNG preservation, and contrast/digits option
invariance.

## Privacy and sufficiency boundary

The artifact contains no source fit object, raw optimizer vector, training
response rows, training design matrix, Person identifiers, source Person
coordinates or estimates, optimizer trace, diagnostic bulk, closure,
environment, external pointer, RNG state, ambient-option snapshot, or absolute
source path. Source column names are nonsemantic input defaults; source-column
values are absent.

An isolated temporary-library install and two separate `Rscript --vanilla`
workers loaded and scored frozen RSM and PCM artifacts. Each worker received
only one artifact and one new-response input, created no RNG state, observed
no fit or training-data object, left both inputs unchanged, and reproduced the
parent-process three-Person estimate table with maximum absolute difference
zero. The reproducible worker is
`inst/validation/fixed-calibration-g1-scoring-worker-0.2.4.R`.

## Lifecycle, provenance, and persistence

The main lifecycle is `draft -> validated -> frozen`. A frozen artifact can
also produce a distinct immutable `superseded` or `retired` terminal record;
the frozen parent remains unchanged and the derived record carries the exact
parent identity. Event revisions, operations, from/to states, parent IDs, and
RFC3339 UTC timestamps are checked as one contiguous registered chain.
Terminal records cannot score or transition again.

Save/load preserve draft, validated, frozen, superseded, and retired states
and re-run schema and semantic review on load. Existing output is not
overwritten without explicit authorization. Creator identity, package version,
creation/validation times, terminal-parent rules, and the typed refusal table
are validated rather than trusted as prose.

## Adversarial evidence

The mutation suite refuses corrupt RDS, missing fields, duplicate coordinate
keys/selectors, nonfinite values, altered score maps, invalid quadrature
weights, injected training state, newer schema versions, invalid provenance,
broken event chains, malformed scoring inputs, and noncanonical operational
coordinates. All errors preserve code, field path, bounded detail, and the
input object.

`tests/testthat/test-fixed-calibration-lifecycle.R` passes 144 assertions and
`tests/testthat/test-fixed-calibration-g1-schema.R` passes 61 assertions, with
zero failures, warnings, or skips. The broader prediction/anchor/namespace
regression passed with only the two pre-existing category-support warnings.
`git diff --check` and a Pandoc roadmap render passed.

The post-edit source tarball completed
`R CMD check --no-manual --ignore-vignettes` with `Status: OK` under R 4.6.1
on aarch64 macOS. Its SHA-256 is
`0dafad2d0a18dfe595e8ec95fe5be25e3bcf05feb2d66d72db8c030d0c2ed0d6`.
The isolated evidence SHA-256 values are:

- RSM artifact: `775a6698fa2060029f72e1fc4238a981d7174b259b3579be5615d63084a13ea5`
- RSM worker result: `73a960756b536102297af5a018b93d91e04e4974913a656dc0a143bd126925a0`
- PCM artifact: `9db7bdd906a012634e0e45e56e68e4991d58737856ed902a28d9301048e3f1e1`
- PCM worker result: `3a0eb8f4418b47ee067bdba69bb8d4722f0d1d7c925c019c2f3a2d1a081e3eec`
- Shared new-response input: `2fab85e8e37586374e75b89f8373028426b6af52ea8943d649f2e73d0b9dbc8c`

## Release consequence

G1, CORE-01, and CORE-02 are complete. This proves internal artifact
sufficiency and lossless lifecycle behavior. G2/CORE-03 has since closed under
its separate typed-anchor record, and G3/CORE-04 has since closed under the
operational-scoring record. The broader independent/reproducibility matrices
and every public API gate remain open. The next bounded stage is G4, and all
constructor/scorer functions remain unexported.
