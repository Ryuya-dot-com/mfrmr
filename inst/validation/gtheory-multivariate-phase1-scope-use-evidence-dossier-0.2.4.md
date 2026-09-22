# D-SIM-0 Phase 1 scope-and-use evidence dossier for mfrmr 0.2.4

Status: historical v3 evidence classification; superseded as an admission gate
Review date: 2026-08-30
Contract: `MFRMR-GTHEORY-MV-DSIM0-MULTIVERSE-V3`
Contract hash: `f5e2cff2e470f6ad0ab592a2c49597a873b7286f5b9f7f8e4669069635788905`

## Purpose

Phase 1 asks whether `ABS-PHI` and `REL-G` each have a named operational use,
owner, affected workflow, and consequence. This dossier classifies what the
repository can establish before that owner response. It does not enable either
family and cannot be used as a substitute for external operational evidence.

## Supersession note (2026-08-30)

The v4 package-capability contract supersedes this owner-response path. The
questions below can still be useful in a particular applied analysis, but they
are not prerequisites for developing or validating a general R package.
`ABS-PHI` and `REL-G` both enter the package validation multiverse; the package
owns their semantics and numerical behavior, while users own targets,
interpretations, workflows, and consequences. This dossier and its blank
response remain immutable provenance for an unexecuted v3 proposal.

## Bottom line

The repository establishes that univariate `G` and `Phi` calculations and
analytic D-study projections are publicly available. It does not establish a
named multivariate workflow, decision owner, affected workflow identity, or
consequence for either family. `ABS-PHI` has a stronger historical technical
candidate because v2 used it as a provisional primary estimand, but v2 also
kept owner confirmation and execution false. `REL-G` is computationally
available and has a documented relative-decision meaning, but no repository
record names a real rank-ordering workflow or consequence. Therefore both v3
enablement values must remain missing.

## Repository evidence and claim ceiling

| Evidence | What it establishes | What it does not establish |
|---|---|---|
| `R/api-generalizability.R`, `mfrm_generalizability()` | The public univariate main-effects helper returns `G` for relative decisions and `Phi` for absolute decisions, with identification warnings. | A multivariate composite estimand, operational use, owner, workflow, or action consequence. |
| `R/api-generalizability.R`, `mfrm_d_study()` | Both coefficients can be projected over planned facet counts under explicit residual-scaling assumptions. | A fully crossed G-study, a validated multivariate covariance model, or decision readiness. |
| `vignettes/mfrmr-workflow.Rmd`, “Design Simulation and Prediction” | Users are shown how to inspect `G`, `Phi`, identification status, and sensitivity projections. | A deployed workflow or evidence that either coefficient drives a real action. |
| `tests/testthat/test-q3-and-person-fit.R` | Both coefficient paths and their boundary/singularity downgrades are covered as software behavior. | Substantive thresholds, operating characteristics, ownership, or consequences. |
| `gtheory-multivariate-decision-simulation-contract-v2-0.2.4.R` | `ABS-PHI` was a provisional absolute-score-dependability primary estimand and `G` a secondary sensitivity in a bounded technical proposal. | Owner acceptance. V2 explicitly leaves sign-off, execution, seed access, and public support false. |
| `gtheory-multivariate-decision-multiverse-contract-v3-0.2.4.R` | `ABS-PHI` and `REL-G` are separate families that cannot be pooled or treated as votes. | Enablement. Both remain `OwnerEnablementStatus = pending`. |
| historical ledger state before v4 | D0 was treated as the sole active decision gate and remained unsatisfied. | Any authority to infer the missing owner response from implementation history. |
| `gtheory-measurement-core-page-review-0.2.4.md` | Literature supports keeping facet structure, latent dimension, observation-event identity, and coefficient purpose distinct. | A local operational purpose, named owner, or consequence. |

The public example formerly reversed the expected coefficient ordering in one
comment. With nonnegative facet main-effect variance under the implemented
formulas, absolute error contains relative error plus facet main effects, so
`Phi <= G`. The example now says that `Phi < G` indicates noisier absolute than
relative decisions, and the D-study test guards this ordering. This correction
does not create an operational use for either family.

## Family-specific candidate interpretations

### ABS-PHI

Repository-supported candidate meaning:

- absolute composite-score dependability across fixed registered strata;
- not pass/fail accuracy and not universal acceptance of `Phi = 0.80`;
- a possible planning question about allocations and cost, conditional on
  common scale, fixed weights, covariance identity, and external consequences.

Still required externally:

- named use case and target population;
- named decision owner and owner role;
- affected workflow and version;
- consequence identity for acting or not acting on the result; and
- an immutable evidence anchor independent of simulation outcomes.

### REL-G

Repository-supported candidate meaning:

- relative rank-order dependability, separate from absolute-score use;
- a possible planning question only if a real workflow uses relative ordering
  of objects or persons and has a stated consequence.

Still required externally:

- the actual rank-ordering use rather than generic coefficient availability;
- named owner, workflow/version, target population, and consequence; and
- an immutable evidence anchor independent of simulation outcomes.

## Prohibited inferences

- Public API availability does not imply operational need.
- A vignette example does not identify a deployed workflow.
- A passing software test does not validate a decision threshold.
- V2's provisional `ABS-PHI` primary role is not owner acceptance.
- Literature establishes construct meaning, not the local owner or consequence.
- Simulation outcomes may not be used to decide which family should have been
  enabled.

## Owner response surface

The companion
`gtheory-multivariate-phase1-owner-response-candidate-0.2.4.csv` has one blank
row per family. For an enabled family, the owner must supply the named use,
identity, role, workflow, population, consequence, and external anchor. For a
disabled family, the owner must supply a disable rationale and evidence anchor.
At least one family must be enabled for the current v3 contract to continue. If
neither has a defensible use, D-SIM-0 stops; a technical implementation cannot
manufacture a purpose.

The response CSV is a facilitation surface, not the typed owner packet. An
accepted response must still be transferred into
`mfrmr_gtds_v3_owner_input_candidate()`, rehashed, completed across all thirteen
inputs, and externally signed. Every simulation and execution flag remains
false.

## Admission and legitimate stop

The v3 typed packet requires at least one enabled family, which is correct for
constructing a continuing multiverse but cannot by itself represent a valid
decision that neither family has an operational use. The companion
`gtheory-multivariate-phase1-admission-gate-0.2.4.R` therefore sits upstream of
the typed packet and derives exactly three states:

- `pending_external_owner_evidence`: at least one family row is unresolved or
  lacks its owner identity, role, external anchor, confirmation, or
  branch-specific evidence;
- `completed_advance_to_phase2_evidence_collection`: at least one family has a
  complete enabled-use record; only construction of the family portion of a
  newly hashed owner packet and further evidence collection may proceed; or
- `completed_stop_no_operational_use`: both families have complete,
  externally anchored disable decisions; the study ends without constructing
  a v3 owner packet.

The completed stop is not `Dsim0Satisfied`; it is a prior admission outcome
that makes D-SIM unnecessary. The advance state is also not authorization.
Both branches retain `SimulationExecutionAllowed = FALSE` and
`PlannedSeedAccessAllowed = FALSE`. The candidate response currently yields
the pending state.
