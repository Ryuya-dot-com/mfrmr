# Interval/output contract and DRF preflight — 2026-09-10

Scope: the bounded numerical and execution work in priorities 0–2 of the
[active queue](internal-roadmap-0.2.3.md#2026-09-10-integrated-work-queue), under
the [prespecified protocol and dated addenda](interval-drf-preflight-protocol-0.2.4.md).
This record adds target/output mappings to existing C05/C06/C07/C10/C12/C17
claim groups. It does not replace the 181-export inventory or close every
output route. No release or large confirmation was performed.

## Repairs and output-path findings

Two demonstrated defects were corrected at their shared implementations:

* `summary(fair_average_table(..., reference="zero"))` previously looked for
  FairM columns that the table had removed. It now uses FairZ values, SEs and
  names; `FairMetric` makes the selected summary target explicit. Mean/both
  references continue to summarize FairM. Native/legacy/both labels are tested.
* The GPCM fair-score SE helper previously replaced missing finite-difference
  gradient components by zero. It now requires the complete gradient or returns
  unavailable SE/CI with a reason. A partial-gradient regression reproducer
  checks that missing uncertainty cannot become a finite SE.

Requested table intervals now carry `FairCIEligible=FALSE` and
`FairCIReportingUse` (`diagnostic_only`/`unavailable`); requested plot intervals
carry `CI_Eligible=FALSE` and `CI_ReportingUse`. These are score-interval fields,
separate from any measure-level `CIEligible`. Numerical `ok`/`regularized`
status does not certify full-refit coverage. Summaries and legacy plot payloads
cannot infer formal eligibility from a finite score SE. Notes remain returned
when titles/notes are hidden in the drawing.

Actual GPCM score tables, summary/print, saved RDS/read-back, old payloads and
CSV exports of the returned tables are checked. `export_summary_appendix()`
**does not accept a Fair Score bundle**, and this explicit rejection is tested;
there is no claim that this appendix route gained support. Use the public
`$stacked`, `summary(...)$summary` and `$preview` data frames with `write.csv()`.
The first attempted appendix test exposed this existing API boundary and was
replaced by a refusal test plus actual table CSV round trips.

## Target and output map

All score coordinates below mean the fitted internal category scale plus its
rating minimum; original category labels are a separate score map. Measure
`umean`/`uscale` transformations do not transform expected scores into logits.
Confidence level and a numerical SE alone do not identify the inferential target.

| Target / claim | Fixed and estimated quantities; covariance | Public route and interval fields | Current interpretation / remaining work |
| --- | --- | --- | --- |
| Structural non-Person effects and thresholds — C05 | Joint constrained MML parameters, including all declared free blocks; fixed and estimated population are separate conditions. | `diagnose_mfrm()` measures and `parameter_uncertainty$steps`; `ModelSE`/`SE`, `CI_Lower/Upper`, `CIEligible`, `CIUse`, readiness. Summary/report routes use these restrictions. | Existing confirmation supports its named fixed-population RSM/PCM conditions. Non-unit weights, active population and GPCM/JML restrictions remain; finite review bands can remain in a table without eligibility. |
| Same-fit facet contrast — C05/C09 | Both estimates from one constrained fit; difference variance includes covariance. | `analyze_facet_equivalence()` pair table and plot; pair-difference SE and eligibility. | Reuse the existing covariance repair and checks. Marginal interval calibration alone does not validate every equivalence/multiplicity decision. |
| RSM/PCM FairM or FairZ plot interval — C12 | Only focal measure uncertainty propagated through expected-score derivative; thresholds, other effects and reference means fixed. | `plot_fair_average(show_ci=TRUE)` → `$data$data`/`$data$plot_data` → base or `as_ggplot()`; `CI_SE`, `CI_Lower/Upper`, `CI_Level`, `CI_Method`, `CI_Eligible`. | Diagnostic clipped normal delta interval. A saved RSM/PCM score table alone cannot reconstruct this fitted-model derivative; intervals stay unavailable. JML source uncertainty remains exploratory. |
| GPCM non-Person fair-score interval — C04/C12 | Joint structural covariance of effects, thresholds and applicable slopes; Person EAPs/reference Person mean conditioned on. Complete gradient required. | `fair_average_table(fair_se=TRUE)` raw `FairMSE/FairZSE`, raw `FairM/FairZ_CI_*`, formatted adjusted-score columns, summary/plot/RDS/CSV; common `FairCIEligible`. | Diagnostic only, including regularized cases. Person structural fair SE is unavailable. This is not a full-reference bootstrap or a validation of the complete GPCM model. |
| Fixed-reference RSM/PCM non-Person FairZ candidate — C12 | Other-facet/Person reference is zero; full joint effect/step covariance in the current free coordinates. | Repository-only `fair_reference()` oracle and new audit target CSV; no new public SE API. | Numerical preflight below; separate repeated-sampling confirmation still required. Five targets per cell do not validate Person/FairM or all threshold profiles. |
| Reestimated-reference FairM — C12 | Reference means depend on the data; full procedure must refit, rescore Persons and recompute those means. | Existing point score and diagnostic intervals above. | Define the repeated-sampling truth/reference before estimating this uncertainty. The fixed-reference FairZ study cannot supply its coverage. |
| Person ability / fitted-object scoring — C05/C06 | Posterior conditional on fitted calibration and declared prior; calibration uncertainty excluded. | `predict_mfrm_units()` returns `Estimate`, `SD`, grid-quantile `Lower/Upper`, `SourceScoringReady`, `EstimateUse`, settings/notes. Diagnostic measure bands are a different construction. | Posterior credibility is not a frequentist ability-stratified confidence statement. Review-only source restrictions must propagate; existing readiness regression tests are reused. |
| Portable Person scoring — C07 | Frozen point calibration, stored prior/grid, supported RSM/PCM contract. | `extract/review/validate/freeze/save/load_mfrm_calibration()` → `score_mfrm_calibration()`, posterior `Estimate/SD/Lower/Upper`, calibration/scoring records. | Code mapping only in this increment; lifecycle and cross-platform scoring are not rerun here. No calibration-parameter uncertainty is included. |
| Observed-minus-fair gap — C12 | The plotted observed average is fixed while the fair-score interval is reflected around it. | Difference view in `plot_fair_average()`; plotting `Lower/Upper`, explicit returned note. | Whiskers are not a confidence interval for a stochastic observed-minus-fair difference. Need joint observed/fitted variation for that claim. |
| GPCM observation-level expected/residual score — C04/C12 | Existing score-side delta route sums available measure component variances, without cross-component covariance. | `scorefile` `ScoreSideSE`, `ScoreSideCI_*`, `ScoreSideResidualCI_*`, method/status/detail fields. | Separate approximation from the joint fair-score delta method. Mapped from source, not newly validated or promoted by this preflight. |
| Change after model/anchor intervention — C08/C12 | Two fits to the same responses; common scale and between-fit covariance, possibly data-dependent linking/screening. | `plot_compare_mfrm()` matched coordinates/probability differences; anchor/offset-sensitivity tables. | No new difference SE/CI. Releasing an anchor, deleting ratings and excluding linking elements are different procedures; each needs a paired target-specific design. |
| DRF residual / refit screen — C10 | Residual contrasts use score units. Refit contrasts use linked severity coordinates, conditioning on baseline estimated linking anchors; shared calibration uncertainty is omitted. | `analyze_dff()` `$dif_table`, `ContrastBasis`, `SEBasis`, `ReportingUse`, `FormalInferenceEligible`, `ConditionalRefitScreenEligible` where applicable. | Screening only. Missing common elements, weak linking and unsupported population/interaction refits remain unavailable. Holm-adjusted screening p-values do not become formal tests. |

## FairZ numerical and complete-refit results

Runner: [fair-joint-contract-0.2.4.R](fair-joint-contract-0.2.4.R).
Evidence: [8 runs](fair-joint-contract-0.2.4/runs.csv),
[40 target rows](fair-joint-contract-0.2.4/targets.csv),
[public replay checks](fair-joint-contract-0.2.4/replay_checks.csv), fit/data RDS
and source hashes in the same directory.

Eight fresh datasets cross RSM/PCM, 80/320 Persons and 3/6 ratings per Person.
All q61 and q121 fits were inference-ready under their structural contract and
had unregularized covariance status `ok`. The two executed public replay
scripts reproduced q61 parameters, objective and Person EAPs exactly. Thus
there were 18 complete fits: 8 q61, 8 q121 and 2 replayed q61 fits. No fit
warnings/errors occurred. Higher-grid fits reoptimized all free coordinates
and rescored Persons; these were not evaluations at old parameter values.

| Check across the 40 named targets | Maximum absolute discrepancy |
| --- | ---: |
| Independent FairZ versus public raw table | 4.44e-16 |
| Analytic versus numerical gradient | 1.61e-11 |
| SE after invertible free-coordinate transformation | 1.39e-17 |
| q121 minus q61 FairZ | 7.34e-11 |
| Relative joint-SE change | 2.20e-10 |
| Clipped 95% endpoint change | 7.60e-11 |
| Free-parameter change | 2.36e-10 |
| Person EAP change | 2.31e-9 |
| Objective change (descriptive, not an added acceptance criterion) | 8.77e-9 |

All prespecified numerical tolerances passed. Joint/diagonal-only SE ratios
were 0.700–1.000, while joint/focal-conditional SE ratios were 0.977–1.016.
The covariance contribution cannot be described as an automatic widening.
No interval in these microcases hit a score boundary; the stored unclipped
and clipped endpoints therefore do not constitute a boundary-coverage test.
Aggregate measured elapsed time was 35.637 seconds, including both grids,
score/plot-data checks and replay. q61 optimization alone totaled 3.731 seconds;
this excludes work needed for a production confirmation and is not an
end-to-end long-study budget.

**Answer:** the joint FairZ formula and current output mapping survive these
numerical/refit checks. They do not resolve the earlier RSM R3 result of 16/20
covered intervals, nor establish 95% coverage for any new condition. Keep the
earlier pilot intact and freeze a fresh confirmation protocol next.

## DRF/interaction execution and assignment findings

Runner: [drf-execution-preflight-0.2.4.R](drf-execution-preflight-0.2.4.R).
The initial 14 cases, 18-case review and final expanded run are stored
separately under [drf-execution-preflight-0.2.4](drf-execution-preflight-0.2.4/).
The protocol addenda retain the mistaken three-anchor expectation and its
failed assertions. These were validation-design errors, not evidence to
change the API's actual five-anchor criterion. Empty-table warnings introduced
by the first runner were also fixed there, without altering package results.

The [final run table](drf-execution-preflight-0.2.4/final/runs.csv) contains
22 unique datasets (11 cases × RSM/PCM), including the original 14/18 seeds.
All 22 execution cases pass their final, documented path assertions. There
are 22 additive fits, six additional population/interaction fits and 44
subgroup fits, with no unexpected fit errors. Final elapsed time was 100.242
seconds, including diagnostics/screens/refits; baseline optimization alone
was 5.464 seconds. These timings were measured locally, partly alongside
regression tests, and are not a power-study runtime prediction.

Independent probability and eta-decomposition errors were at most 6.67e-16
and 8.89e-16. The Group B common shift is algebraically identical to shifting
ability, while the rater-specific DRF component sums to zero. Positive eta
means leniency; the output retains its method-specific contrast direction.

The [44 additive-fit screens](drf-execution-preflight-0.2.4/final/screens.csv)
show the actual API boundaries:

* Two/three linking criteria produce descriptive refit differences with
  `weak_link`, unavailable SE/p-values and no formal eligibility.
* Five-anchor null/DRF cases return all three conditional refit-screen
  SE/p-values per dataset, retaining
  `ReportingUse="screening_only_conditional_plugin"` and false formal eligibility.
* No-common-rater cases produce no finite per-rater contrasts. Refit tables
  are empty, rather than fabricated comparisons. The two retained package
  warnings concern identification through a common latent population despite
  deficient free-Person JML design rank; this is not an ordinary linked DRF test.
* All six explicit population/interaction refit attempts are
  [rejected as specified](drf-execution-preflight-0.2.4/final/guards.csv).
  Their residual-screen tables are saved separately.

Five-anchor null examples have zero flags in both methods/models; the DRF
examples flag one rater in RSM and two in PCM. These are four individual
datasets, **not Type I error or power estimates**. One additional two-criterion
PCM DRF example has two residual flags. No null result establishes absence
of bias, and a returned descriptive contrast is not an available inferential
contrast merely because it is finite.

**Further design finding:** the public generator draws uncentered rater and
criterion effects. In these examples, recentering both facet sets implies a
population intercept from -0.462 to 0.490, whereas the additive replay fixes
its population mean at zero. See the post-run
[truth-location audit](drf-execution-preflight-0.2.4/final/truth-location-audit.csv).
Consequently even a `null` case here means zero injected DRF/interaction,
not a certificate of complete generation/estimation agreement. Before a
calibrated null/power study, declare and align the location constraint and
population intercept as well as the group-ability shift. Do not silently
recenter effects without a compensating change to ability/intercept.

**Answer:** the required null/non-null and unavailable workflows are executable,
and the five-anchor minimum materially changes what can be returned. A DRF
confirmation protocol must address both linking and location alignment; the
current small executions cannot qualify screening error rates or justify
lifting population/interaction restrictions.

## Regression verification

The final [focused test log](fair-joint-contract-0.2.4/focused-tests.log) and
[test rows](fair-joint-contract-0.2.4/focused-tests.csv) contain 121 passed
expectations in 14 test blocks (`fair-interval-contract`, `gpcm-fair-average`),
zero failures, warnings or skips. The output writer was corrected to omit
testthat's list-valued result column; that was a validation-log issue after
the tests had passed.

The earlier [related run](fair-joint-contract-0.2.4/related-tests-with-initial-appendix-failure.log)
passed 717 expectations across five other files: bundle dispatch 167, Fair
Score plots 256, observation-weight readiness 128, readiness propagation 92
and results-readiness propagation 74. Its sole error was the unsupported
Fair Score appendix test discussed above. Final per-file results therefore
cover 838 distinct expectations; overlapping runs are not added together.
Runtime R-source hashes still match all current R files. Full package/release
and cross-platform rendering checks were not rerun for this bounded increment.

## Evidence identity and next decisions

Runtime source hashes cover every R source file and the relevant runners and
protocols; start/end equality is checked. The original protocol copies stored
with the initial FairZ and DRF evidence match their original hashes, before
the DRF addenda. Historical pilots and frozen confirmation results were not
rewritten. Current source adds reporting metadata and rejects incomplete
GPCM gradients; it does not change the RSM/PCM estimator used by this audit.

Next: freeze the fixed-reference, non-Person FairZ confirmation (eight cells,
at least 2,500 fresh datasets per cell as the existing planning floor), retaining
all targets and the R3 concern. Before setting a DRF error-rate/power study,
separate weak-link descriptive output from conditionally linked screens,
declare calibration-anchor uncertainty, align generator location constraints,
and model ability shifts explicitly.
Full FairM/Person uncertainty, boundary stress, full GPCM/TAM and weighted or
estimated-population coverage remain separate open work. Passing numerical
checks and software tests does not authorize release.
