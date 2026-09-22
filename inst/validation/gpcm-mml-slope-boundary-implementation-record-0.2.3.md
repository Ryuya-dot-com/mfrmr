# GPCM MML slope-boundary implementation record for mfrmr 0.2.3

Status: completed Draft.69 instrumentation slice; calibration, readiness
propagation, threshold freeze, confirmation, and release authorization pending

Run date: 2026-08-09 JST

## Exact implementation identity

| Field | SHA-256 |
| --- | --- |
| Installed runtime package | `2a6344a815dadee12dc50eeac339e2f5774cf43cce2b86771a24aa8c132aa0e3` |
| Marginal boundary implementation | `5a67c827de455bf17495c6aa7fbc6474ffd336f1f4083d80aafdab75db63d83e` |
| Fit-pipeline integration (`R/mfrm_core.R`) | `f2a97c7ddfb219a0d75a2a790e53ac44ca2bd1aff617df13f7af0fdcf5782b7e` |
| Mathematical contract | `73b3161c5d954f60ee0b8d82640ffa687c4ed5903b6635b800a6d44938194614` |
| Dedicated tests | `048fb230177800a9ee2c4ecd2c07ad6d9c1ebd34c8d6da025790ebf1c1ec7e7c` |
| Source tarball | `d94e152c358c7f500c33d063e2c897c0027558409b97d0985e2a4c6801ee020b` |
| `R CMD check` log | `992c1d5009b7697de12174af209e26669dc6f0b2fd898be021444a2ad596532b` |

The source tarball and check directory are temporary local verification
artifacts under `/private/tmp/mfrmr-rcheck-draft69/`; they are not release
candidate evidence and are not referenced by a checklist result.

## Implemented mathematical boundary

The MML branch no longer stores the conditional JML slope-path result as its
only boundary placeholder. It now evaluates the estimator-specific finite
quadrature Person-pattern marginal objective. For every ordered pair of slope
levels it:

1. applies a constant expanded log-slope direction with loadings `+1,-1`,
   which preserves the geometric-mean-one constraint;
2. checks at every retained quadrature node that positive-group responses
   maximize unscaled category utility and negative-group responses minimize
   it;
3. requires strict utility support on at least one effective response;
4. reconstructs the boundary response probabilities independently and then
   reintegrates complete Person patterns with the unchanged quadrature basis;
   and
5. records likelihood reconstruction, dimensions, group support, every tested
   pair, certified directions, and bounded failure states.

The derivative argument and its source boundary are frozen in
`gpcm-mml-slope-boundary-contract-0.2.3.md`. It is a sufficient result for the
implemented finite-node objective with additive coordinates fixed. It is not
claimed as a theorem for the continuous integral or the global joint model.

## Positive and negative controls

The constructed sparse positive control has 12 Persons, two anchored Raters,
two criterion-owned slopes, binary responses, and q=5. Exactly one of the two
ordered directions is certified: C1 has positive loading and C2 negative
loading. In the retained run:

- current marginal log likelihood: approximately `-16.71199`;
- reconstructed boundary log likelihood: approximately `-16.63553`;
- boundary improvement: approximately `0.07645`; and
- direct path values at distances 0, 0.25, 0.5, 1, 2, 4, and 8 increase
  monotonically toward the reconstructed boundary.

Reversing every retained row preserves certification and boundary
improvement. Setting the pair-node execution limit to zero returns
`not_evaluated_size_limit`; an invalid node count returns
`not_evaluated_control`. The ordinary `example_core` MML GPCM fit returns
`none_certified_fixed_quadrature_marginal`. This negative result is explicitly
not a finite-MLE claim.

Both the positive and negative controls retain free-slope `ParameterStatus =
"not_evaluated"`, unavailable primary values, review-only fit readiness, and
`InferenceReady = FALSE`. Thus the instrument cannot promote itself into
evidence readiness.

## Verification

- The dedicated marginal-boundary test file passes 42 expectations.
- Existing JML slope-boundary and joint-boundary tests pass unchanged.
- Installed-runtime release-readiness, documentation-terminology, marginal
  and JML boundary, and optimizer-boundary selections pass.
- The vignette-built source tarball passes `R CMD check --no-manual` with
  `Status: OK` under R 4.6.1.

The previous Draft.68 full local suite reached 12,261 passes before its only
failures were classified as excluded internal-validation artifacts and the
intentionally unbuilt vignette. Draft.69 then added installed-package guards
for those repository-only tests and passed the targeted changed surfaces and
the distribution check above. This record does not mislabel the earlier broad
run as a full Draft.69 run.

## Gate consequence

Draft.69 closes an instrumentation absence, not a statistical gate. No MML
slope becomes primary, no standard error or interval becomes eligible, no q
grid becomes sufficient, no owner or estimator ranking is made, and no
checklist row or confirmation state changes.

The next evidence must calibrate certificate stability across q=31/61/91 on
independently identified criterion-owned and rater-owned datasets, add direct
q61-to-q91 parameter differences, retain failed fits and none-certified cases,
and propose any propagation rule before independent confirmation seeds are
inspected.
