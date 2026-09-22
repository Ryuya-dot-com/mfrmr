# Population-model output eligibility and scoring repair

Date: 2026-09-10. The requirements and replay scope below are fixed before
the scoring-policy edit. This contract narrows output use; it does not approve
estimated-population inference or select a universal numerical cutoff.
Status: implemented; bounded replay and migration checks complete.

## Decision requirements

The question is what a user may do with an estimated population model, given
the preceding [identification](population-identifiability-review-record-0.2.4.md)
and [variance-profile](population-variance-profile-record-0.2.4.md) reviews.
Those reviews concern four datasets, not general sampling validation.

| Requirement | Necessary evidence | Insufficient substitute | Current disposition |
| --- | --- | --- | --- |
| Reproducible calculation | Retained responses, population design/coding, weights, scale constraints, parameter vector, integration settings and source identity | Finite values or optimizer text | Retain numerical traces for review |
| Identified target | Evidence for the actual target under the actual marginal model; resolve exact equivalent parameter paths, or establish invariance of a specified functional along them | Full additive rank; observed-subset rank deficiency alone | The single-rating variance/difficulty ridge disallows unique parameter interpretation; local full rank in the other examples does not establish global uniqueness |
| Qualified numerical solution | Independent objective and full free-coordinate score agreement at the selected solution; relevant start/grid comparisons and stable parameter mapping | Native convergence; two agreeing starts; accurate evaluation of an unrefitted vector; nuisance-only profile gradients | The existing profile checks qualify only their declared fixed-variance nuisance problems |
| Boundary and source selection | Evidence addressing competitive zero/large/joint parameter paths appropriate to the model and declared target | One positive fitted variance; a finite grid ending at 64; a scaled rank check | Bounded profiles are evidence, not a global boundary or source-selection certificate |
| Individual posterior calculation | Qualified source calibration plus scoring-grid checks for the reported EAP, posterior SD, interval and draws, under declared conditional population assumptions | Stable likelihood; fitted variance; a larger scoring grid alone | Estimated-population scoring remains explicitly review-only |
| Sampling uncertainty and decisions | Estimand-specific structural information/SE evidence and sampling calibration for the intended design, weights and model; separate Person and joint-decision evidence | Local identification; inverse-Hessian existence; coordinate coverage in a different population model | No ordinary population-model inference, joint Wald/TOST approval or calibrated Person coverage follows |

The numerical bounds in the preceding audits remain diagnostic comparisons,
not production thresholds. Missing evidence means review, not proven
nonidentification. Exact ambiguity means the affected parameters are not
uniquely determined; fitted marginal probabilities can nevertheless be
identified. The requirements above are necessary conditions for a future
support decision, not a self-certifying sufficient checklist.

## Reproduced implementation gap and bounded repair

`prediction_source_scoring_readiness()` explicitly accepts
`EstimabilityState = not_evaluated` when a population model is active. All four
retained fits therefore report scoring-ready despite fit inference remaining
restricted, including the exact-ridge negative control. The numerical component
checks the optimizer's own score, and the finite MML boundary component concerns
Person sufficient-score treatment; neither is a population-variance certificate.

Remove the population exception in the shared scoring guard and explicitly keep
estimated-population scoring review-only until the requirements above have an
implemented, evidenced acceptance rule. Both `predict_mfrm_units()` and
`sample_mfrm_plausible_values()` must refuse their default operational path and
retain the existing `readiness_policy = "review"` path. The benchmark's shared
guard must also decline a posterior-shift claim for an unqualified source.
Do not modify fit estimates, covariance, optimizer behavior or integration grids.

Replay the four retained population fits and four omitted/explicit-unit
fixed-population controls. Capture both default and review predictions and
plausible values before editing; compare all numerical columns and seeded
draws afterward. Independently evaluate a positive-response EAP at four points
on the negative control's exact ridge to determine whether its identical
observed marginal distribution also implies identical individual scores.
Retain prior archives unchanged. Old prediction/PV objects claiming ordinary
population scoring must be regenerated with explicit review before their
summary, print or structured export can be used. Existing flattened CSVs and
tables remain historical values, not current eligibility certificates.

## Result and its practical meaning

The shared scoring guard now requires explicit review for an estimated
population. Removing only the `not_evaluated` exception would leave a future
local-rank promotion able to bypass still-incomplete boundary and integration
evidence, so the active-population restriction remains explicit. The scoring
policy basis advances to `scoring_readiness_components_and_parameter_layout_v2`;
the fit-readiness contract and all estimation/inference rules are unchanged.
No automated rank, variance or quadrature cutoff was introduced.

| Retained source fits | Default individual prediction/PV before | Default after | Explicit review after | Numerical summaries and seeded draws |
| --- | --- | --- | --- | --- |
| RSM/PCM latent regression and single/paired binary controls (4) | Returned, scoring-ready | Refused | Returned, review-only | Identical |
| Fixed-standard-normal RSM/PCM, omitted/explicit-unit weights (4) | Returned, scoring-ready | Returned, scoring-ready | Returned with original eligibility | Identical |

The after replay took about 0.64 seconds, excluding loading and archive writing;
no fit or simulation was rerun. All eight source parameter/covariance objects
are reused, and EAP, posterior SD, interval endpoints, observation counts and
seeded posterior draws are unchanged. The restriction changes authorized use,
not the underlying computation. A shared guard also prevents the packaged
reference benchmark from reporting an accepted posterior-shift result for an
unqualified population calibration; it reports that check as not evaluated.

An independent continuous-integral calculation makes the consequence of the
negative control explicit. Every row below has the same observed positive
probability `.30` for Rater 1 and `.70` for Rater 2, and the same observed-data
likelihood in that single-rating design. The population mean is fixed at zero
and rater difficulties sum to zero throughout.

| Population variance | Rater-1 difficulty | EAP after a positive Rater-1 response | Posterior SD |
| --- | ---: | ---: | ---: |
| 0.000001 | 0.847298 | 0.000000700 | 0.001000 |
| 0.1 | 0.866898 | 0.068579 | 0.312942 |
| 1 | 1.018401 | 0.589898 | 0.910789 |
| 4 | 1.384226 | 1.749480 | 1.543782 |

These are alternative observationally equivalent model parameters, not four
estimates from independent samples. The individual posterior score is not
invariant along this ridge, so identical fit to the observed proportions does
not identify the reported Person score. This is not a claim that every
single-rating design or every latent-regression model is unidentified.

## Verification, retained evidence and next work

Six focused test files pass 2,458 expectations, with zero failures, errors,
warnings or skips: prediction, export bundles, summary-table bundles, reference
benchmark, readiness propagation, and release-readiness documentation. Existing
population preprocessing/covariate tests now explicitly request review; the
new negative-control test checks the default refusal and saved-output guards.
Fixed-population tests continue to exercise the ordinary path. This was not a
full package/OS release check.

Migration checks exercise 48 actual saved objects/summaries across 192
summary, print, table-bundle, manifest and replay-script calls. All 24 old
population-scoring objects/summaries are rejected on every applicable path;
all 24 fixed-population controls remain available. Newly generated explicit-
review predictions/PVs pass summary and table-bundle checks in all eight cases.
The migration guard rejects inconsistent or missing review labels rather than
rewriting numerical estimates or silently upgrading an old object.

The [replay summary](population-output-contract-summary-0.2.4.csv),
[migration checks](population-output-contract-migration-0.2.4.csv),
[test results](population-output-contract-tests-0.2.4.csv),
[execution log](population-output-contract-execution-0.2.4.log) and
[evidence archive](population-output-contract-evidence-0.2.4.rds) retain both
source revisions, original and current predictions/PVs, original summaries,
the independent ridge calculation, complete test results and unchanged input
archive hashes. Prior identification/profile/weight evidence is historical
evidence for its recorded source, not recertified against this source revision.

The [runner](population-output-contract-0.2.4.R) supports `before` and `after`
stages. To repeat the after replay without replacing retained evidence, extract
`evidence$before` from the archive to `before.rds` in a fresh directory, then run:

```sh
Rscript inst/validation/population-output-contract-0.2.4.R after /tmp/population-output-replay
```

Reproducing the original before behavior requires its archived source revision;
running `before` on the repaired code does not reproduce the old approval.
The archive also contains the migration script and its actual old summaries.

Next examine full-solution stationarity and structural-SE integration accuracy
at the retained population solutions. A nuisance-qualified point with variance
fixed is not a fully stationary free-population estimate. Use that evidence to
select only the missing estimand-specific recovery/coverage work. Population
operational scoring and ordinary inference remain unapproved; full GPCM, JML,
Person-score calibration and joint-decision calibration remain separate.
