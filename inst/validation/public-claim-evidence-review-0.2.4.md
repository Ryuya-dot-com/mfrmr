# 0.2.4 public-claim and evidence review

Date: 2026-09-09. Status: initial inventory and targeted current-source audit
complete; claim closure and release remain open. This is a working review under
the [current internal roadmap](internal-roadmap-0.2.3.md#2026-09-09-024-validation-before-release),
not a replacement release policy or a statistical acceptance certificate.

Follow-up: the [facet-equivalence repair](facet-equivalence-repair-record-0.2.4.md)
supersedes the open implementation-defect status below. This initial audit and
its original runtime/covariance CSVs retain the pre-repair observations. The
runner now checks the corrected behavior; its new output must be saved separately.
Statistical uncertainty and the other claim reviews remain open.
The [independent RSM/PCM information extension](mml-independent-information-conditions-record-0.2.4.md)
advances C05's numerical checks and records the subsequent correction of a
singular anchored comparison. It does not close empirical SE/coverage.
The subsequent [fixed structural-uncertainty confirmation](mml-structural-coverage-record-0.2.4.md)
adds 20,000 datasets: five evaluated cells meet every criterion and three
retain bias review. C05 remains open outside that scoped support. The initial
inventory and audit findings below are retained as their original snapshot.
The separate [fresh bias confirmation](mml-structural-bias-confirmation-record-0.2.4.md)
subsequently supports all three repeated cells under the original criteria.
The [use-condition audit](mml-use-condition-audit-record-0.2.4.md) then identifies
the non-unit-weight inference-eligibility gap as the next shared correction,
while preserving the separate quadrature and population-readiness questions.
The subsequent [observation-weight repair](observation-weight-readiness-repair-record-0.2.4.md)
resolves that shared output defect through an enforced inference restriction,
with unchanged numerical replay and saved-object checks. It does not validate
weighted sampling uncertainty or close the other claim groups.

## Decision from this audit

The first repair priority is `analyze_facet_equivalence()`. It produces positive
TOST decisions for fits whose ordinary inference is unavailable, and computes
pair-difference SEs without the covariance of the jointly estimated facet
effects. Both issues were reproduced on the current source. This is a concrete
release blocker; an additional simulation cannot repair these output and
calculation defects.

Next, establish the numerical and statistical basis for the RSM/PCM MML
uncertainty that the current API *does* make eligible for ordinary inference.
Continue the separate full-model GPCM and estimator-specific JML reviews.
Their current restrictions do not establish numerical validity, but neither
does unavailable ordinary inference require manufacturing a TAM parity claim.

No production implementation was changed by this audit. The defect remains
open. The previous conditional-output audit was scoped evidence and did not
cover this equivalence route; it cannot be treated as complete current output
coverage.

## Scope and source applicability

The [inventory](public-claim-evidence-inventory-0.2.4.csv) accounts for all 181
exports and 191 S3 registrations in `NAMESPACE`, including aliases. Each entry
records its implementation location, a help alias where present, and claim
groups below. Several routes serve multiple groups; presentation methods also
belong to C17. An empty help path means no direct alias was found, not that the
route necessarily lacks documentation.

This is entry-point accounting, **not 372 independent validations**. Only the
targeted behavior described below was executed in this audit. The group table
assigns the remaining evidence and follow-up, including secondary diagnostics
whose complete decision-bearing paths still require tracing. Parameter,
population, anchor, interaction, weighting, and slope-owner subclaims must
remain separate within each group when closing it.

Reviewed package: `mfrmr 0.2.4.9000`, branch `development/0.2.4`, base commit
`df609a30a2dc8ec226d6acdca2fbf963fe502ee6`. `R/`, `NAMESPACE`, and `DESCRIPTION`
had no differences from that commit during execution. Roadmap and audit files
were uncommitted. Older records retain their original source identities and
scope; citing one here does not assert that its complete experiment was rerun.

## Claims, evidence, and bounded next actions

Dispositions: **defect** = reproduced blocker; **inference gap** = ordinary
uncertainty evidence needs closure; **scope review** = apply existing evidence
to the exact retained claim and check missing paths; **descriptive/tooling** =
retain only the stated calculation or workflow interpretation pending that
review. None of these labels means release pass.

| Group / public claim and conditions | Evidence and current restriction | Disposition / next check and release consequence |
| --- | --- | --- |
| C01 Input, category support, connectivity, and design description: `describe_mfrm_data()`, preprocessing in `fit_mfrm()`, subset reviews. | First-use tests replayed here include structural rejection and review-state propagation. Connectivity alone is not adequate information. | **Scope review.** Trace declared versus observed support with missing categories, disconnected and weak bridges, duplicates, anchors, interactions, and non-unit weights. Incorrect acceptance or lost design restrictions blocks the affected route. |
| C02 RSM/PCM MML point estimates and integration, with fixed or estimated Person population as documented. | [Benign overlap](tam-mml-core-current-head-record-0.2.4.md), [RSM stress](tam-mml-release-stress-record-0.2.4.md), [density diagnostic](tam-mml-density-diagnostic-record-0.2.4.md), and [PCM stress](tam-pcm-mml-conditional-stress-record-0.2.4.md) are distinct evidence. Current RSM/PCM example fits report ordinary-inference eligibility. | **Scope review + inference gap.** Preserve adverse failures; check density and tail range separately, objective/derivative agreement, and the claimed anchor/interaction/weight/population variants. Then close C05. No single integration order is certified. |
| C03 JML RSM/PCM estimates, raw/adjusted/corrected modes and extreme-Person profile limits. | [Matched TAM/immer modes](tam-immer-jml-mode-comparison-record-0.2.3.md), [factor pilot](tam-immer-jml-factor-pilot-record-0.2.3.md), [extreme recovery pilot](jml-extreme-profile-recovery-pilot-record-0.2.3.md). Current JML precision tier is exploratory even when fit readiness is `ready`. | **Scope review.** Replay a finite no-extreme raw common target before estimator-specific recovery. Match corrections and extreme conventions explicitly. Do not launch the old topology pilot unchanged or treat ordinary JML SE/CI as validated. |
| C04 GPCM complete selected-owner model, Criterion or Rater owner, JML and MML. | [Non-unit score oracle](gpcm-nonunit-score-oracle-record-0.2.3.md), [owner smoke](gpcm-owner-current-default-smoke-p1s-record-0.2.3.md), [item-only TAM overlap](tam-gpcm-item-only-overlap-record-0.2.3.md), [external feasibility](gpcm-owner-external-reproducibility-preflight-p1t-record-0.2.3.md), [asymptotics pilot](gpcm-estimator-asymptotics-pilot-record-0.2.3.md). Current free-slope `SEEligible`/`CIEligible` are false. | **Scope review.** Reconcile later owner/boundary evidence before another run. Check the exact full predictor with nonzero other-facet effects, both owners and estimators, information and estimability. Item-only TAM agreement does not validate the full model; unavailable full external overlap requires an independent exact-model route. |
| C05 Structural SE/CI, Person precision, separation/reliability, chi-square summaries and decision labels. | `compute_mml_parameter_covariance()`, `build_measure_se_table()`, `build_precision_profile()` and `mfrm_fit_decision_summary()` expose MML model-based inference, JML exploratory uncertainty and GPCM restrictions. [Earlier output audit](conditional-fallback-coverage-audit-0.2.3.md) and current focused tests cover selected paths. | **Inference gap.** Independently check constrained covariance and contrast transforms, then SE versus empirical SD, coverage, width and availability for the retained estimands. Separate Person posterior uncertainty and fit-adjusted measures. `coverage_complete` in the precision table is table-combination completeness, not empirical interval coverage. |
| C06 Fitted-object unit/population prediction and plausible values. | `api-prediction.R` and the GPCM score-side contract distinguish fitted scoring from portable scoring. Review-only GPCM scoring does not promote slope inference. | **Scope review.** Trace each returned interval and draw against its prior, integration grid, calibration treatment and readiness; verify refusals and downstream labels. Do not infer frequentist or transported-population coverage from a posterior SD. |
| C07 Portable RSM/PCM MML calibration lifecycle and conditional EAP scoring; fixed standard-normal population and documented anchor constraints. | [Quadrature remedy](mml-quadrature-remedy-record-0.2.4.md) and [earlier hosted revalidation](fixed-calibration-g4-hosted-run-34018691491-revalidation-record-0.2.4.md). Extraction requires the highest reviewed grid and completed fits, not an automatically satisfied movement tolerance. | **Scope review + uncertainty scope.** Replay material-movement and mismatched-review cases, fit-time versus score-time integration, identity/refusal and conditional intervals. Reconcile the source changes since the hosted payload. Calibration estimation uncertainty remains excluded. |
| C08 Anchors, linking/equating and drift: known fixed anchors versus estimated links. | [Anchor design refinement](rater-anchor-incomplete-design-refinement-record-0.2.4.md), [sparse pilot](rater-anchor-sparse-stress-pilot-record-0.2.3.md), [portable anchor record](fixed-calibration-g2-anchor-record-0.2.4.md). Source exposes direct/group anchors and separate linking reviews. | **Scope review.** Map exact supported anchor constraints, common scale and sparse connectivity to current tests. Inspect uncertainty propagation and automated drift decisions; fixed-anchor conditional evidence cannot validate estimated-link uncertainty. |
| C09 Facet equivalence: `analyze_facet_equivalence()`, its bundle and plots. | Current six-fit probe below reproduces unsupported positive decisions. Pair SE uses marginal SEs alone; current MML covariance permits direct calculation of the omitted covariance term. | **Defect.** Fix at the shared analysis function and preserve the restriction through bundles/plots. Validate contrast covariance and all accompanying inferential summaries before retaining formal decisions. Reproducer is retained below; blocker remains open. |
| C10 Bias, DFF/DIF, fixed interactions and screening reports. | [Interaction/bias/PCA pilot](interaction-bias-pca-stress-pilot-record-0.2.3.md) explicitly does not establish false-positive or power performance. A fitted interaction and a residual screen answer different questions. | **Descriptive/tooling + scope review.** Trace p-values, flags, automatic rankings and multiple comparisons to their actual SE/readiness basis. Any formal decision claim requires matched-null/alternative operating characteristics; preserve exploratory interpretation where that evidence is absent. |
| C11 Fit statistics, person fit, residual PCA/Q3, unexpected responses and QC. | Same scoped [pilot](interaction-bias-pca-stress-pilot-record-0.2.3.md), current source helpers and historical convention audits. Residual eigenvalues do not identify a named latent dimension. | **Descriptive/tooling + scope review.** Check formula and convention targets, missingness, degrees of freedom, thresholds and readiness across reports. Calibrate any retained diagnostic decision separately from numerical parameter agreement. |
| C12 Expected/fair-average scores, information and category/threshold curves. | Current tables and curve implementations; GPCM independent probability/score foundations supply only their stated numerical scope. | **Scope review.** Check reference Person/facet settings, weights, category maps, slope ownership, anchor alignment and monotonic/limiting behavior with an independent small calculation. Do not let a display silently create unsupported score uncertainty. |
| C13 Public observed-score G-study and D-study helpers. | `api-generalizability.R` fits Gaussian observed-score random main effects plus a collapsed residual. D-study exposes residual-scaling assumptions and singular/boundary warnings. Repository covariance/reconstruction studies concern distinct, broader research models. | **Scope review.** Validate the exact public formulas and scope, including negative/singular cases and design sensitivity. Do not borrow multivariate/reconstructed-component evidence to claim public main-effect coefficient coverage. The exported baseline cannot be deferred together with future multivariate features. |
| C14 Hierarchy, ICC/design effects, small-facet reviews and optional post-hoc empirical-Bayes shrinkage. | `api-hierarchical-audit.R` and `api-shrinkage.R`; shrinkage adds columns and treats the supplied/estimated prior variance as known in its naive posterior SE. It is not a hierarchical refit of the MFRM likelihood. | **Scope review.** Trace `ShrunkSE`, full-pooling zero-SE cases, small-sample thresholds and all downstream uses. Independently check formulas and restrictions before any ordinary uncertainty or design recommendation; no calibrated shrinkage interval claim is established here. |
| C15 Simulation/recovery/design evaluation, resampling and reference benchmarks. | Current generators/evaluators and [external historical recovery review](external-parameter-recovery-simulation-0.2.0.md). That review used JMLE and misspecified stress designs and does not validate present MML/GPCM coverage. | **Descriptive/tooling.** Check truth/identification alignment, assigned and attempted datasets, clustered sampling, failed/eligible accounting and MCSE before reusing the machinery for Step 3. A callable evaluator or one-replicate planning result supplies no statistical acceptance result. |
| C16 External imports and FACETS/ConQuest normalization/overlap bundles. | Separate imported-fit class, source/coordinate and reporting-convention reviews; import is not native re-estimation. TAM/GPCM and JML limitations remain as above. | **Scope review.** Exercise absent covariance/raw-data cases, category/constraint mismatches and unsupported imported diagnostics. Parser agreement cannot authorize new parameter, likelihood or SE equivalence claims. |
| C17 All tables, S3 methods, plots, APA/QC/results reports, exports, replay bundles, guides and viewer. | Namespace inventory plus 703 current focused expectations below. Earlier conditional-output audit is useful but incomplete, as C09 demonstrates. | **Scope review; affected C09 routes blocked.** Trace shared objects through ordinary user workflows, including imported and old/supplied bundles, so a summary, plot or export cannot recreate a suppressed claim. Presentation success is not statistical validation. |
| C18 Network/agreement and response-time reviews. | Network helpers and `api-response-time.R` provide descriptive summaries; response-time review does not change the measurement likelihood. | **Descriptive/tooling + scope review.** Check missing/invalid times, graph/overlap definitions and automatic labels; avoid causal, latent-ability or inferential conclusions beyond the computed summaries. |

## Current-source execution and the equivalence counterexample

Question: can an ordinary inferential decision reappear after the fitted-object
summary says formal inference is unavailable, and is the pair SE consistent
with the fit's own joint covariance?

Design: use the same bundled `example_core` data for RSM, PCM and GPCM under
MML and JML; use Criterion-owned steps/slopes as applicable, 31 quadrature
points and `maxit = 150`. This compact contrast isolates estimator/model
readiness from the downstream helper. Inspect Rater equivalence at the default
bound 0.5 and a deliberately wide diagnostic bound 5. The latter is not a
recommended practical threshold. These are six fits of one dataset, not six
independent recovery replications.

The [runtime results](public-claim-evidence-runtime-0.2.4.csv) show:

| Fits | Ordinary inference in fit/diagnostic decision | Equivalent Rater pairs at bound 0.5 | Equivalent pairs at bound 5 |
| --- | --- | --- | --- |
| MML RSM and PCM | Yes | 2 of 6 in each fit | 6 of 6 in each fit |
| MML GPCM; JML RSM, PCM and GPCM | No | 2 of 6 in each fit | 6 of 6 in each fit |

Thus all four inference-ineligible fits produce positive decisions even at the
default bound. Across the two bounds this yields eight contradictory rows;
that count is a reproducer result, not an estimated false-positive rate. The
runtime probe emitted no warnings. JML RSM/PCM being fit-ready does not cure the
contradiction: their precision profile still says ordinary inference is false.

`analyze_facet_equivalence()` reads finite `Estimate`/`SE` columns without
checking the fit's inference eligibility or the provenance of supplied
diagnostics. Its pair calculation is `sqrt(SE_A^2 + SE_B^2)`. For the difference
of jointly estimated effects the variance is
`Var(A) + Var(B) - 2 * Cov(A, B)`. Using the current MML Hessian covariance and
the existing constraint Jacobian gives the
[twelve pair comparisons](public-claim-evidence-covariance-0.2.4.csv): reported
pair SEs are 12.708% to 13.996% smaller. For PCM R02 minus R04 the reported SE
is 0.117607, versus 0.136746 including covariance.

This demonstrates an internal contrast-calculation inconsistency. It does not
independently validate the Hessian, interval coverage, or a corrected TOST's
finite-sample behavior. Both models still returned two equivalent pairs at the
default bound in the original implementation; no corrected decision result
was executed or claimed here.

The same helper also reports a weighted chi-square, a BIC/Bayes-factor
heuristic, and grand-mean ROPE summaries. The repair must review their distinct
targets and covariance assumptions. Changing only the pair SE or adding only
a JML warning would leave the shared inferential problem incomplete. The help's
claim that non-significant heterogeneity is *necessary* for practical
interchangeability also needs correction: exact equality and a nonzero
practical bound are different hypotheses.

## Reproduction and regression evidence

From the package root, with the current source dependencies installed:

```sh
Rscript inst/validation/public-claim-evidence-audit-0.2.4.R /tmp/mfrmr-claim-audit
```

The [runner](public-claim-evidence-audit-0.2.4.R) checks inventory completeness
and exported-function resolution, executes the six fits, and saves runtime,
covariance, warning and session records. It deliberately reports observed
defects rather than issuing a release pass. A later repaired implementation
must add regression assertions for the new behavior; the historical CSVs above
must not be overwritten as if they had originally passed.

The separate [focused test result](public-claim-evidence-tests-0.2.4.csv) contains
50 test cases from seven files: 703 passed expectations, zero failures/errors/
skips, and five warnings. Warnings concerned category support, three GPCM
review-only plots, and suppressed information criteria. Reproduce with:

```r
devtools::test(
  filter = paste0("^(first-use-readiness-contracts|readiness-propagation|",
                  "results-readiness-propagation|gpcm-capability-matrix|",
                  "information-criteria-contract|gpcm-verification|",
                  "identified-step-parameterization)$"),
  reporter = "summary", stop_on_failure = TRUE
)
```

Execution environment: R 4.6.1, macOS Tahoe 26.6.2, aarch64, mfrmr
0.2.4.9000, testthat 3.3.2, pkgload 1.5.3. These are selected regression and
counterexample runs, not a new TAM execution, full package check, cross-platform
matrix, or SE/coverage simulation.

## Next work and closure criteria

1. **Repair C09 at the common analysis path.** Bind diagnostics and covariance
   to the actual fit; prevent formal decisions when inference is unavailable;
   use valid constrained contrasts where supported. Review the accompanying
   chi-square/BF/ROPE interpretations. Update the example and existing
   equivalence tests, including fit-input plots and bundle summaries. Close only
   when the reproduced unsupported decisions are prevented and the retained
   numerical calculations have independent checks.
2. **Finish C05's numerical prerequisite.** Compare the RSM/PCM MML information
   and covariance with an independent calculation under matching constraints,
   regularity and population treatment; cover the claim-relevant anchors,
   interactions and weights identified in C01/C08. Preserve GPCM/JML
   restrictions until their separate basis closes. A corrected C09 alone does
   not validate the rest of MML inference.
3. **Prepare the missing statistical protocol and finish secondary-route
   tracing.** Use the internal roadmap's estimand-specific recovery, SE/SD,
   coverage, availability and false-ready criteria with prespecified Monte
   Carlo precision. C06--C08 and C10--C18 remain assigned reviews, not silently
   accepted features. Reuse existing evidence where source and estimands match;
   do not reopen unrelated dormant extension studies.
4. **Reassess release only after these dispositions close.** The initial
   inventory portion of Step 1 is complete. Full claim closure, Steps 2--4 and
   final-source checks remain open. No release date is justified by this audit.
