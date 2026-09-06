# TAM MML release-stress contract for mfrmr 0.2.4

Status: prospectively frozen before the release-stress results are inspected,
2026-09-06. This is an internal release-validation contract, not a claim of
general TAM compatibility and not a scientific preregistration.

## Release question

The 0.2.4 portable-calibration workflow publicly supports one-dimensional RSM
or PCM MML fits under a fixed standard-normal scoring basis. The release must
therefore not rely only on the earlier benign latent-regression comparison.
Before 0.2.4 is frozen, a matched TAM comparison must exercise the fixed-basis
RSM MML likelihood and EAP scoring under ordinary and adverse data layouts.

The comparison can block the release, narrow the documented scope, or expose a
defect. It cannot by itself authorize general TAM parity, multidimensional
models, free-slope multifacet GPCM, or a new public feature.

## Matched computational route

The primary fixed-basis route is:

1. Generate the TAM many-facet RSM design matrix with
   `tam.mml.mfr(..., formulaA = ~ item + rater + step,
   constraint = "items")`.
2. Refit the resulting pseudo-item responses and design matrix with
   `tam.mml(..., beta.fixed = cbind(1, 1, 0), est.variance = FALSE)`.
3. Fit the identical long data with
   `mfrmr::fit_mfrm(method = "MML", model = "RSM",
   population_formula = NULL, mml_engine = "direct")`.

This two-stage TAM route is required because `constraint = "items"` in the
high-level many-facet call estimates the latent mean, whereas the 0.2.4
portable mfrmr route fixes the scoring basis to mean zero and variance one.
Using `constraint = "cases"` or comparing an estimated TAM population against
the fixed mfrmr basis would compare different estimands.

The secondary intercept-only route fits the same RSM with the latent mean and
variance estimated in both packages. It is retained only to disposition
`population_formula = ~ 1` readiness within the 0.2.4 review. It does not make
estimated-population fits eligible for portable calibration.

## Frozen bounded multiverse

Three deterministic replications are used for each applicable profile. The
baseline declares 80 Persons, six Criteria, five Raters, four categories, and
a complete Person-by-Rater assignment. Each stress profile changes only the
listed feature.

| Profile | Persons | Raters per Person | Additional perturbation | Fixed N(0,1) | Estimated intercept-only population |
| --- | ---: | ---: | --- | --- | --- |
| `BASELINE` | 80 | 5 | none | yes | yes |
| `SPARSE_RATER` | 80 | 2 | incomplete Person-by-Rater assignment | yes | no |
| `MCAR_20` | 80 | 5 | remove 20% of rating rows deterministically | yes | no |
| `EXTREME_10` | 80 | 5 | force 5% all-minimum and 5% all-maximum Persons | yes | no |
| `WEAK_EXPOSURE` | 80 | 1 | one Rater and six ratings per Person | yes | yes |

Every dataset is fitted at 31 and 61 quadrature points. This yields 42 matched
package comparisons: 30 fixed-basis comparisons and 12 estimated-population
comparisons. The input hash, seed, source/runtime identity, warning/message
counts, optimizer status, and retained row counts are part of the evidence.

## Frozen overlap contract

| Layer | Required overlap | Deliberate difference |
| --- | --- | --- |
| MeasurementSpec | unidimensional RSM; unit slope; Criterion and Rater facets; four ordered categories; common step structure; identical observed rows | TAM represents Criterion-by-Rater combinations as pseudo-items |
| EstimationSpec | person-pattern MML; same fixed or estimated normal population mode; item, rater, and step sum constraints; identical response weights | TAM uses its M-step and equally spaced integration nodes; mfrmr uses direct optimization and Gauss-Hermite nodes |
| ScoringSpec | EAP and posterior SD for the same Person response patterns under the fitted/fixed population basis | posterior integration grids follow the respective engines |

Facet coordinates are compared through the complete cumulative-difficulty
surface, so constrained-level naming differences such as TAM's `item2` cannot
be mistaken for a parameter disagreement. Multifacet is not relabelled as
multidimensional.

## Frozen engineering acceptance rules

The following are numerical-regression bounds for this exact matched contract;
they are not universal scientific-equivalence thresholds.

- Both engines must return finite objectives for every planned fit.
- mfrmr must report `ConvergenceStatus = "converged"`; TAM must stop before
  its 1,000-iteration ceiling.
- For every q-specific pair, absolute deviance difference, maximum absolute
  cumulative-difficulty difference, maximum absolute EAP difference, and
  maximum absolute posterior-SD difference must each be at most `1e-4`.
- Fixed-basis runs must retain latent mean 0 and variance 1 in both engines.
- Estimated-population runs must have mean and variance differences at most
  `1e-4`, with a positive finite variance in both engines.
- Within each package, q31-to-q61 movement is retained rather than hidden. A
  maximum absolute movement above `1e-3` in deviance, cumulative difficulty,
  EAP, posterior SD, mean, or variance blocks a release pass pending review.
- All planned dataset/q/engine outcomes, including failures, remain in the
  denominator. No profile, seed, metric, or bound may be changed after result
  inspection without issuing a new contract version and invalidating the old
  confirmation claim.

Passing this contract permits only the statement that the bounded 0.2.4 RSM
MML computational overlap survived the specified release stress. PCM remains
covered by the existing benign TAM comparison plus the independent 0.2.4
fixed-calibration recovery evidence; a new PCM stress lane is added only if the
RSM run reveals a family-general issue or the PCM-specific evidence conflicts.

## Explicit non-goals

- TAM compatibility mode or solver imitation;
- free-slope multifacet GPCM through `tam.mml.mfr()`;
- multidimensional MML;
- standard-error or coverage equivalence;
- model selection, fit-statistic, or substantive decision equivalence; and
- an unbounded Monte Carlo study.

