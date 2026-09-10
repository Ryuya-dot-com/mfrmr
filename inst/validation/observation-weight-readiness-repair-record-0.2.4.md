# Observation-weight ordinary-inference restriction

Date: 2026-09-10. Status: implemented and targeted checks complete. This closes
the reproduced output defect by restricting inference; it does not establish
a valid weighted sampling model or approve the 0.2.4 release.

## Question and reason for the change

The [use-condition audit](mml-use-condition-audit-record-0.2.4.md) showed that
six MML fits with within-Person weights (0.5, 1, 1.5) admitted ordinary inference
and facet-equivalence decisions. Independent integration agreed with the
weighted objective, but pattern enumeration gave nonzero expected scores at
the original generating truth. Thus computational correctness did not justify
transferring the unit-weight sampling-uncertainty evidence. Changing only a
warning or the equivalence entry point would leave sibling routes permissive.

The repair therefore asks whether a shared restriction reaches every tested
fit/diagnostic/decision route, including saved results, while retaining the
numerical calculations and the explicit-unit positive controls. These are
implementation and compatibility checks, not new coverage simulations.

## Implemented behavior

- The input component of `build_mfrm_readiness_record()` reuses
  `mfrm_ic_weight_policy()`. Omitted and explicit-unit weights retain their
  existing eligibility; non-unit weights produce `InputState = review` and
  `nonunit_observation_weights_inference_unvalidated`. Missing or invalid
  retained weights fail closed. The classifier retains its existing numerical
  tolerance; normalization to mean one does not remove the restriction.
- Fit, diagnostic, reliability and decision flags cannot authorize ordinary
  inference for these fits. MML step bands carry `CIEligible` and `CIUse`;
  attached diagnostic tables retain eligibility/use labels. Finite precision
  and normal-band calculations remain diagnostic quantities. Review text no
  longer incorrectly attributes every inference restriction to the optimizer.
- Contract `mfrmr-readiness-0.2.4-v1` supersedes v3. Old fit records, including
  unit-weight records, require a current audit/refit; no automatic migration
  guesses their missing weight approval. Detached diagnostic summaries retain
  review-only interpretation, and reuse of obsolete native diagnostics is
  rejected. Equivalence bundles must retain the current readiness contract as
  well as the corrected covariance and contrast rank. Summary, print and plot
  cannot reuse the old approval. Raw historical fields remain preserved in
  the source objects and archives; accessing a raw list is not a new decision.

The likelihood, optimizer, covariance calculation, integration grid and weight
semantics are unchanged. No sandwich covariance, bias correction, frequency
reinterpretation or new quadrature default is introduced.

## Evidence and interpretation

The [replay helper](observation-weight-readiness-repair-0.2.4.R) reuses the
retained use-condition archive. Its [numeric summary](observation-weight-readiness-repair-summary-0.2.4.csv)
contains ten fits: RSM/PCM heterogeneous weights at q31/q61/q121 (six), and
RSM/PCM q61 controls with omitted/explicit-unit weights (four). Every fitted
parameter, objective, covariance entry and expanded facet/step SE matches the
corresponding pre-repair value exactly (maximum absolute difference **0**).
All six non-unit fits now refuse formal inference and equivalence; all four
unit controls retain eligibility. The ten fit/reference/diagnostic pipelines
took 13.323 seconds and generated no warnings or errors.

The [saved-object replay](observation-weight-readiness-repair-migration-0.2.4.csv)
checks all **52** actual historical fits and all **46** historical equivalence
bundles. Every obsolete fit and raw summary row loses inference approval;
every equivalence bundle is rejected by summary, print and plot. Six original
population-regression fits were already ineligible and remain so. This is a
migration check of stored objects, not 52 new independent datasets.

The focused tests additionally exercise within-Person constant non-unit weights,
invalid/missing weights, fit and diagnostic summaries, attached tables, supplied
diagnostics with promoted flags, and diagnostic plots. Serialized v3 unit-fit
and detached-diagnostic controls verify the conservative migration policy.
Prediction, portable-calibration lifecycle/schema, category/estimability,
results, interval and release-protocol tests check affected compatibility.

The latest result for each of **14** test files totals **2,433 passing
expectations**, zero failures/errors/skips, and one category-support warning
in the existing boundary-separation fixture. The [test summary](observation-weight-readiness-repair-tests-0.2.4.csv)
and [execution log](observation-weight-readiness-repair-tests-0.2.4.log) retain
the counts and warning. Initial compatibility execution had two failed
documentation assertions: both rejected evidence-link destinations containing
`inst/validation` as internal operations prose. The checker now excludes those
Markdown destinations while still rejecting raw internal instructions; positive
and negative checks pass. Initial failures remain in the log and archive.

The [complete evidence archive](observation-weight-readiness-repair-evidence-0.2.4.rds)
retains refits, covariances, warnings, migration rows, all test executions,
source snapshots and identities. Documentation was regenerated for the three
changed help topics. This was targeted verification, not a new complete
`R CMD check` or operating-system release certification.

## Reproduction and remaining work

Run from the package root:

```r
source("inst/validation/observation-weight-readiness-repair-0.2.4.R")
observation_weight_readiness_repair()
pkgload::load_all(".", quiet = TRUE)
testthat::test_file("tests/testthat/test-observation-weight-readiness.R")
```

The test CSV lists the other files; the archived execution groups retain the
full focused-check results. The runtime helper writes a new replay archive;
retain the dated archive separately when executing another source revision.
Neither the earlier 20,000-dataset study nor the 30,000-dataset bias confirmation
was recalculated or rewritten. Their old source hashes describe their own
source snapshot; the ten-fit replay supports numerical continuity only for
its selected cases and does not turn those studies into full current-source
certificates.

Next review nonlinear estimability for estimated-population models and the
remaining structural-SE integration-review scope. Keep Person-score precision,
joint Wald/TOST calibration, full GPCM and estimator-specific JML questions
separate. Non-unit weighted ordinary inference remains unsupported until its
estimand, sampling design and uncertainty method have their own valid basis.
