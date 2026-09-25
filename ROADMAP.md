# mfrmr roadmap

Status: public roadmap, updated 2026-09-26. This document sets priorities and
completion conditions; it does not promise release dates or unimplemented APIs.
See [NEWS](NEWS.md) for changes and the [README](README.md) for use and examples.
Before CRAN submission, see the [0.2.4 interface and GPCM review](#before-cran-submission-interface-and-gpcm-review).
The subsequent [GPCM inference audit](#gpcm-inference-follow-up-after-local-integration)
now includes the approved inference extensions and population-replay correction.
These changes are integrated into `main` at
[`6f541bfa`](https://github.com/Ryuya-dot-com/mfrmr/commit/6f541bfa3ff5eb6f59e513ee4a375956e9119eb7).
Earlier candidate archives retain only their own recorded check results.
The retained GPCM inference outputs now have explicit
release dispositions: approximate methods remain available, while adverse
coverage results and unqualified stronger claims remain visible. M5 local
archive integration is complete for the September 26 successor. Its five-platform
checks, `main` integration, website update and matching rc.6 tagged assets are
verified. M6 candidate publication is complete; a final release decision and
CRAN submission remain separate.
For the current completion order, start with [Remaining work for the current source](#remaining-work-for-the-current-source).
For work after 0.2.4, start with [Post-release priorities](#post-release-priorities).
That section distinguishes ongoing maintenance, the next development focus and
extensions that need a further scope decision.

## Current releases

mfrmr 0.2.4 is a release candidate. It has not been released on CRAN.
The current candidate is
[`v0.2.4-rc.6`](https://github.com/Ryuya-dot-com/mfrmr/releases/tag/v0.2.4-rc.6).
It combines reusable calibration,
external-feature analysis, assigned-score imputation, fixed-facet intervals,
rater-feedback tools, multivariate observed-score G/D studies and the documented
shared-rater/testlet workflows with the latest GPCM inference and API improvements.

The tag points to `a7529b73`, which adds only package-excluded result records to
implementation commit `6f541bfa`. The implementation passes
[all five CI environments](https://github.com/Ryuya-dot-com/mfrmr/actions/runs/36155335441):
macOS/R-release, Windows/R-release and Ubuntu/R-release, R-devel and R-oldrel-1.
Every package check reports `Status: OK`; international-input and saved-result
portability checks also pass. These are ordinary package checks, not five new
exhaustive or `--as-cran` runs.

The attached source archive and SHA256 were verified by downloading both after
publication. The archive includes 15 matching tutorials and 72 figures with
alternative text. Its local checks combine the initial exhaustive check,
focused repairs and complementary checks described under M5; they are not
represented as another exhaustive run. The archive SHA256 is
`0f1f21c042512318a3b3c8ffbce246bcdab21db1d3dc2dce2cf5e091c58155e1`.

The matching [website build](https://github.com/Ryuya-dot-com/mfrmr/actions/runs/36155335057)
and [Pages deployment](https://github.com/Ryuya-dot-com/mfrmr/actions/runs/36159750653)
succeed. Published help and tutorial source links identify `6f541bfa`.
Seven extended-model examples use saved synthetic results for quick inspection;
complete recalculation instructions remain available. The GPCM guide retains
known adverse coverage results and distinguishes numerical availability from
statistical accuracy.

Earlier candidates, including rc.5, remain unchanged evaluation snapshots.
They also report package version `0.2.4`; retain the exact tag or archive checksum
with saved analyses. Earlier Win-builder checks refer to their uploaded sources.
The same rc.6 archive has now been received by Win-builder for R-release and
R-devel; both results are pending. URL review found no problems, and the current
CRAN index lists no reverse dependencies in the five dependency categories.
No CRAN submission has been made. Candidate publication, a final release
decision and CRAN acceptance remain separate; successful package checks do not
establish general statistical guarantees.

| Workflow | Current position | Role in the planned 0.2.4 |
| --- | --- | --- |
| Portable calibration and new-Person scoring | Implemented for the stated fixed-normal RSM/PCM MML scope. | Preserve the supported workflow and corrections during integration. |
| External-feature clustering and imputation sensitivity | Included in the candidate, including hierarchical trees, plots and setting comparisons. | Preserve descriptive interpretation and paired imputation comparisons. |
| Multivariate observed-score G/D studies | Crossed/nested point projections and explicit normal-theory intervals for prespecified two-crossed-facet plan differences are included. | Preserve the supported designs, uncertainty assumptions and metric-specific availability. |
| Structural/model extensions | Person-by-(Child-within-Parent) multivariate G/D-study point estimates are included in the baseline. Shared-rater and testlet RSMs are included for their bounded conditional/descriptive scope; broader inference remains unqualified. | Retain the G/D-study and two RSM workflows specified below; the matching candidate, archive and help are published. |

## Purpose and priorities

mfrmr helps users calibrate ratings, compare Persons and facets on an explicit
measurement scale, reuse a calibration, and plan assessments with a clear
account of what the results support. The agreed development order for 0.2.4 was:

1. Finish the implemented development workflows: APIs, examples, tables,
   plots, exports, saved results and failure behavior.
2. Qualify statistical support for the retained uncertainty, imputation and
   rater-feedback targets, reusing the completed G/D-study evidence.
3. Extend the models for specified assessment designs and analysis targets.
4. Integrate the completed work from stages 1–3, together with the existing
   calibration workflow and corrections, into mfrmr 0.2.4.

The post-release plan below retains the principle of finishing and qualifying
workflows before broadening models. A reproduced
calculation or interpretation defect is corrected when found. Completion requires
working functionality under stated conditions, applicable evidence and clear
failure behavior. Research results or documentation alone do not implement an extension.

The estimation core remains frequentist MML/JML. EAP scoring conditional on a
fitted calibration does not make calibration fully Bayesian. Observed-score
G-theory, exploratory feature groups and latent MFRM estimates answer different
questions; they must retain their own scales, assumptions and interpretations.

## Focus for 0.2.4

The release outcome is an assessment workflow that connects rating-design
review, estimation, qualified uncertainty, rater feedback, assessment planning
and reproducible output. Educational performance assessment is the principal
example; the same explicit roles can describe music, clinical assessment or
judged performances without claiming validation in every domain.

The following is the retained candidate scope. These public workflows have completed
local integration, cross-platform package checks and GitHub publication verification.
Completion of the previously published candidate alone did not establish this
expanded scope. The interface and GPCM review below is a further pre-submission
requirement; its API, summary and guidance changes are now in `main` and rc.6.
They were not in the rc.5 candidate.

| Included in 0.2.4 | Outcome required before release | Explicit boundary |
| --- | --- | --- |
| Existing MFRM and portable calibration | Preserve supported RSM/PCM, GPCM/JML, anchors, linking, diagnostics, new-Person scoring and corrected saved analyses. | Existing model-specific restrictions remain; new engines or unrestricted inference are not implied. |
| Exploratory external features | Separate Person/rater/task tables; mixed-feature and hierarchical clustering; numeric PCA/k-means; setting and paired-imputation comparisons; interpretable profiles and figures. | Descriptive groups, not latent measurement classes, causal effects or automatic selection of a best partition. |
| Assigned-score multiple imputation | Review supplied ordinal completions, preserve assignment and observed scores, fit on a common scale and pool eligible non-Person fixed-facet targets; provide a statistically examined example. | No filling unassigned cells, automatic choice of an imputation model, pooled EAPs or imputation for the two new model classes. |
| Statistical support for feedback | Fixed-facet one-way sandwich intervals with the correct target; planned-roster evaluation of false flags, detection and unavailable results; ordinary-model bias analysis with its existing limits. | A working-model interval does not remove misspecification bias. Screening is evidence for review, not automatic rater exclusion. |
| Multivariate observed-score G/D studies | Preserve crossed and selected nested estimation, composites, scenarios and supported paired plan-difference intervals. Complete a fixed-task-set / sampled-rater example using fixed score components where that representation is valid. | This example does not add a general fixed-facet solver. Arbitrary nesting, unequal future allocations and universal G-theory structures are outside 0.2.4. |
| Shared-rater and Person-local testlet RSMs | Finish the two locally implemented models as bounded workflows: fit, appropriate Person scoring, rater feedback, declared uncertainty, predictions, same-data ordinary-MFRM comparisons and saved output. | One substantive ability and adjacent-category RSM. Joint shared-rater/testlet, PCM extensions, heterogeneous/correlated local effects and new substantive dimensions are later work. |
| Model-aware diagnostics and figures | Define and verify response moments and descriptive Infit/Outfit for the two extensions; provide model-aware location/Wright displays, fit pathways and comparison figures from matching result objects. | Classic fit cutoffs, standardized tests and likelihood-ratio rules are not automatically transferable. Formal extended-model DRF/bias tests and automatic decisions are outside this release. |
| Help, reporting and migration | Runnable question-to-result tutorials, English plots, consistent help/NEWS, static reports and CSV/HTML/RDS replay; preserve refusals and uncertainty meanings. | The extended-model Shiny viewer and complete feature parity across every result class are not release requirements. |

Conditional Person intervals remain a legitimate, explicitly conditional
output: they hold calibration fixed and are not presented as intervals that
propagate calibration estimation. General calibration-aware Person/contrast
intervals are a later inferential extension. Their absence does not permit
mislabeling current intervals. Existing shared-rater interval undercoverage,
population restrictions and numerical approximation require explicit output
restrictions. Both extensions now omit automatic fixed-facet and step bounds;
shared-rater individual bounds are also omitted. Explicit normal approximations
and the separate approximate population-SD profile remain available under
stated checks and limitations. This output decision does not improve coverage
or turn an unqualified inferential claim into a supported one.

The ability-population decision is to add an estimated normal ability
variance to both RSM extensions before release, retaining fixed N(0,1) as
an explicit restricted option. With a unit Rasch slope, fixing that variance
is a substantive assumption, not just a choice of units. Both local APIs now
estimate ability variance and accept an explicit known SD. Shared-rater
uncertainty, profiles, bootstrap refits and saved reports use the same population
contract. The testlet path now has a bounded estimated-population comparison: accounting
for local dependence improved interval coverage relative to ordinary RSM but
increased point-score error in two balanced conditions. Small/sparse coverage
and regular calibration-interval qualification remain inconclusive. Shared-rater
conditional scoring and local calibration-likelihood changes now have bounded
independent numerical support. The retained interval-output decision is now
implemented, with cross-workflow integration evidence for the earlier source.
Current-source integration remains subject to the milestones below. The extension does
not add substantive dimensions, heterogeneous ability groups or latent
regression. Existing fixed-population checks apply only to their original
branch. Comparisons and descriptive fit summaries must retain matched data,
population assumptions and a declared response-probability definition.

Broader ambitions are kept visible in the later-work section. Moving a
required outcome out of this table changes the release scope and must be
identified as such; it cannot be recorded as implementation completion.

## Milestones and the end of this development cycle

Milestones describe completed user outcomes and evidence, not elapsed time,
numbers of APIs or numbers of passing expectations. There is no promised
release date. The statistical question and model definition are settled before
additional confirmation simulations or a final source freeze.

| Milestone | Completion condition | Current-source status |
| --- | --- | --- |
| M0 — Release scope | Agreed functionality, output meanings and exclusions are explicit. | Scope retained. The completion order below replaces the open-ended sequence of GPCM case investigations. It does not defer the agreed GPCM APIs to another release. |
| M1 — Existing workflows | Calibration/scoring, features, assigned-score MI, feedback and G/D planning run through saved output. | Implemented with earlier workflow evidence. Common-MML cautions reach fixed-facet inference and MI pooling. The current-source educational walkthrough is now complete; optional features/MI/G/D outputs were checked using saved results. This does not qualify every statistical target. |
| M2 — Statistical and model decisions | Freeze the estimator, targets, qualification rules and evaluation protocol before confirmation work. | The registered engineering numerical checks and claim/evidence mapping are complete. The broad grid is not a required deliverable. A 17-case historical replay identified two changed admissions. Numerical coordinate and representative boundary-output checks are complete. A prespecified retrospective analysis now evaluates standardized differences and curves on all 800 saved fits; the adverse probability-coverage result persists in a matched current-estimator refit of its complete 100-dataset cell. Attribution to an old optimizer is ruled out for that cell. The per-family release dispositions below settle the retained inference scope; no stronger coverage claim is accepted. |
| M3 — Qualified model workflows | Numerical and statistical evidence supports the retained model outputs under declared conditions; adverse results remain visible. | Release disposition settled for the retained approximate outputs, as specified below. This is not a finding that every nominal interval has adequate coverage: probability families show substantial undercoverage, and bootstrap repeated-dataset accuracy remains unqualified. The agreed APIs remain available with those limits; no improved-coverage claim or new interval method is included. Earlier shared-rater/testlet restrictions remain in force. |
| M4 — User and maintenance integration | Representative workflows, defaults, warnings, figures, exports and help agree on the same source. | Changed GPCM paths and common-MML consumers have focused evidence. Actual weak/unavailable/unbounded interval displays, Markdown reasons and CSV/RDS replay now pass representative review. The current-source educational assessment-to-feedback walkthrough is complete, including its precision-decision repair and optional saved-result branches. Independent novice usability testing has not been performed. |
| M5 — Local completion | Freeze one source/archive after M1–M4; run applicable integrated checks and resolve failures. | Complete locally for the September 26 successor. The initial full suite found three failures, all repaired and checked with 516 focused expectations. Source-documentation and fresh-session complements pass; the final archive passes 0 errors / 0 warnings / 1 maintainer/update-frequency NOTE. Full tests/examples/manuals were not repeated: the exact repair delta and reusable evidence are recorded in the [integration record](inst/validation/claim-reconciliation-0.2.4.md#2026-09-26--complete-local-integration-of-the-retained-inference-scope). |
| M6 — Public release | The same successor source passes applicable platform checks and has matching main/release assets/help/site. | Candidate publication complete for rc.6: all five platform checks pass, matching help/tutorials are deployed, and the tagged archive/checksum are verified after download. Final release and submission decisions remain separate. Earlier Win-builder uploads retain their original source identity. |

M1 workflow finishing and M2 read-only model/statistical decisions can progress
together. M2 precedes new confirmation work; M3 and M4 precede M5. Corrections
to reproduced calculation or interpretation defects interrupt this order.
Documentation is maintained during implementation, not postponed entirely to M4.

Local completion supplies a reviewable release candidate; it is neither a
GitHub final release nor CRAN acceptance. CRAN submission and the external
review outcome are separate from M6. A current local-development instruction
does not itself start publishing. The current scope cannot be declared done
while an included model, diagnostic or statistical decision is unresolved.

If evidence rejects a proposed method, repair it, restrict the affected
inferential output to a justified scope, or propose an explicit scope change.
Do not silently defer an entire required workflow, relabel a known failure as
success, or keep adding simulations until a favorable result appears.

Portable calibration remains part of the integrated release. Its current scope
is one observed scale, fixed-standard-normal RSM/PCM MML, supported direct/group
facet anchors and stored two-way facet interactions. Fitting-integration review
refits at each requested order, extraction uses the reviewed highest-order fit,
and scoring settings remain separate. Save/load and fresh-session scoring must
preserve categories, scale, anchors and settings; incompatible inputs must be
refused. No order is universally sufficient. Portable intervals condition on
the saved calibration and prior, without calibration-estimation uncertainty.

Existing ICC, residual-reporting and shrinkage/replay corrections must also
survive integration. Migration guidance must distinguish reprinting, recomputing,
rescoring and refitting. Earlier checks support unchanged content only; the
expanded 0.2.4 needs its own source identity and final verification. See
[updating saved analyses](README.md#updating-saved-analyses) and
`vignette("mfrmr-portable-calibration", package = "mfrmr")`.

## Current implementation and remaining evidence

The table below records current capability and statistical limits. The release
scope and milestones above set the completion conditions. The September 26 successor completes M5 locally. Evidence is reused only for
unchanged source and matching scope, with the exact repair delta recorded.
This implementation is now in `main`; its five-platform checks and website
deployment pass. The matching rc.6 tag and downloadable archive are verified.

| Workstream | Current status and completion condition |
| --- | --- |
| Numeric k-means/PCA | Implemented and checked locally with explicit geometry, component selection, paired feature imputations, plots, comparisons and executed help examples. Included in GitHub rc.5; the later recommended PAM name and guidance are included in rc.6. Group validity and inferential guarantees are not established. |
| Assigned-response multiple imputation | Implemented and checked locally for reviewed supplied imputations and fixed-standard-normal RSM/PCM MML analyses. Event eligibility, assignment, categories and observed evidence are preserved; eligible non-person facet targets use covariance-aware Rubin pooling. The joint-RSM tutorial includes forty posterior predictive completions, shared Person draws, calibration uncertainty, sampling diagnostics, category probabilities and a separate lower-score assumption. In its 30-missing-score example, direct observed-score MML and MI contrasts are 0.463 and 0.468 logits; the lower-score assumption gives 0.667 logits. All eighty completed-data fits are eligible. A paired 200-dataset comparison now adds bounded evidence: under the tested MAR design, MI coverage is 96.5% among 198 available intervals (95% Monte Carlo bounds 92.9--98.6%); two posteriors miss the sampling-diagnostic threshold. Under low-score-dependent MNAR, coverage is 26.0% with +0.574-logit bias despite a similar missing fraction near 14%. The planned comparison is complete. Preserve this scope through integration; proper imputer priors versus MML moments remain an approximation, and arbitrary imputers/designs or general coverage are not qualified. EAP pooling and other model families remain outside this route. |
| Robust intervals and coverage | A one-way sandwich API is implemented and checked locally for fixed-facet RSM/PCM MML estimates and contrasts, using persons or declared larger independent clusters. Help, plots, independent derivative checks and a 1,600-dataset bounded comparison are complete. All intervals were available; generating-truth coverage still fell to 87% in the joint skewed/sparse scenario. The method targets the working model's limiting parameter and does not remove misspecification bias. This bounded target, its public interpretation and local integration are complete. Small-cluster, multiway/crossed, G/D-study and variance-boundary extensions remain later work. |
| Rater diagnostic accuracy | A planned-roster API, plot and tutorial are implemented locally, with unavailable outcomes retained and per-target/family rates distinguished. A prespecified 1,000-trial matched-budget study reused 200 results and fitted 800 new datasets. The tested Infit/Outfit union detected only 6/100 and 2/100 contaminated-rater cases under two sparse assignments; false-family flags were 0/100 except 1/100 in one missingness condition. All screens were computable, but three fits required category-support review. Threshold calibration, other departures including differential rater functioning, and broader accuracy remain open. Flagging alone does not justify rater exclusion. |
| Random-rater MFRM | Implemented locally: shared normal rater effects, estimated or known normal ability SD, approximate MML, observed/replacement-rater probabilities, population-SD profiles, conditional Person scoring, ordinary-model comparisons, descriptive diagnostics, model-aware maps and saved reports. A prespecified 800-dataset estimated-population study found individual-rater conditional coverage of 91.6–91.8% with six raters and 94.0–94.1% with 24; finite-interval availability was 99% and 87–88%. None met the combined qualification criterion. Automatic individual-rater bounds are withdrawn; `confint(fit, parm = "raters")` and `plot(fit, intervals = "normal")` retain explicitly requested approximations without implying corrected coverage. Bootstrap intervals remain an unqualified alternative, not the default. A separate saved-case review resolves all 53 Person-integration failures by higher-order refitting with unchanged tolerances and adds explicit stability/refit guidance. This does not revise the original coverage study or establish a universally adequate order. An independent fixed-calibration posterior comparison now supports all 48 selected conditional Person EAPs/SDs and 96 interval endpoints at the stated numerical tolerances on twelve full/reduced rosters. Original raw-quantile precision limits and the saved-draw CDF refinement remain distinct; this is not coverage qualification. The local calibration-likelihood approximation now has bounded independent support at 128 distinct parameter points in eight saved datasets, with a maximum .0071-log-likelihood error allowance against the .05 tolerance. This does not establish absolute likelihood normalization, full SD-profile accuracy or boundary inference. Calibration bounds are now omitted by default and explicitly requested through `confint(..., parm = "calibration")` or the summary/results options. Rater-SD profiles remain separate explicit approximations; no regular variance interval is added. Earlier known-population pilots remain evidence for their own scope. PCM, anchors and broader populations/designs remain beyond this bounded route. |
| Testlet MFRM | A local RSM fit, conditional continuous Person scoring, plots, saved results and tutorial are implemented for explicit non-overlapping memberships, estimated normal ability variance and a common local variance. Explicit known ability SD retains the earlier fixed-population model; old saved fits retain N(0,1). Independent likelihood/gradient and continuous-interval checks support the new calculation, including zero-variance handling. Matched ordinary-model facet, predictive and conditional Person comparisons, descriptive diagnostics and model-aware Wright/fit-pathway displays are implemented locally. A 480-dataset estimated-population comparison is complete, with original outcomes retained separately from a verified fourteen-case numerical start-selection repair. The repaired replay supports conditional coverage in the two larger balanced conditions; small/sparse conditions and regular calibration intervals remain inconclusive. Dependence modeling improves coverage relative to ordinary RSM but increases EAP mean-square error in two balanced conditions. Earlier fixed-population evidence retains its own scope. A new executed task/criterion tutorial compares fixed-budget model-conditional precision and unequal-block score sensitivity, while distinguishing halo hypotheses, task-specific variance and policy weighting. This completes an application example, not statistical qualification or a heterogeneous-variance extension. Default calibration bounds are now omitted; explicit normal approximations preserve numerical/boundary guards and the selected level through plots and saved reports. |
| Multidimensional MFRM | Deferred at the user's request. Dimension membership, loading constraints, latent covariance and scale remain undecided. It is not a 0.2.4 completion requirement. |
| Broader G-theory structures | Existing one/two-facet crossed and selected nested designs are retained. A runnable fixed-task-set / sampled-rater example uses existing fixed score components, with rater-count plots and direct weighted-score checks for complete and incomplete sources. A general arbitrary-design solver is later work, not a claim attached to that example. |

No method can guarantee nominal coverage or diagnostic accuracy for arbitrary
unidentified designs, distributions and unspecified missingness mechanisms.
The statistical work will state its conditions and evaluate performance under
those conditions; code execution and one successful simulation are insufficient.
Missing scores on assigned ratings remain distinct from unassigned combinations.
A general response-imputation route must preserve that distinction and the
measurement reference used to combine downstream estimates.

## Remaining work for the current source

This is the active completion order for 0.2.4. The approved workflows in
[Focus for 0.2.4](#focus-for-024) remain included, including the additional
GPCM inference targets below. A closed investigation is not necessarily a
validated method: a negative result may establish a stated limitation, but
cannot justify an inaccurate advertised output. Any proposed removal of an
agreed feature must be identified as a scope change.

A reproduced error in a supported result must be repaired. An implemented
feature with insufficient evidence remains verification work. A failure can
be retained as a limitation only if its status, estimates, unavailable bounds
and interpretation are consistent throughout the supported user workflow.
Providing a finite answer for every dataset is not a release condition.
Research extensions already excluded from the scope do not hold up these repairs.

| Remaining work | Classification | Current evidence | Condition for completion |
| --- | --- | --- | --- |
| Common-MML covariance consumers: fixed-facet intervals, practical equivalence, MI pooling, diagnostics and comparisons | Focused impact review and propagation repair completed (M1/M4); statistical qualification remains separate | Source tracing and RSM/PCM contract tests cover successful and failed information. Cautions now reach fixed-facet/equivalence/pooled tables and plots; MI retains imputation identity, fixed-facet reports retain warnings, diagnostic delta outputs and quadrature reviews retain details. | The branch tests inject reviewed covariance metadata into eligible fits; they do not estimate real-data frequency or coverage. Recheck only if the information contract changes. Carry these outputs into the planned current-source workflow integration and independent qualification. |
| Fixed estimator and output qualification | Engineering checks and per-family release dispositions completed (M2) | [Confirmation protocol](inst/validation/gpcm-inference-confirmation-protocol-0.2.4.md) fixes the source pair, targets, rules, seeds and resource stops. All 32 engineering arm/cell jobs pass independent probability, NLL, derivative and target checks. Failure-aware summaries and isolated source loading were checked. The main-phase timing projection exceeds its 24-hour envelope; no confirmation data have been generated. | Use the release dispositions below. The numerical and representative output checks are complete; retained APIs supply approximations, not newly established coverage guarantees. New performance claims need matching evidence. Preserve protocol versions and failure accounting; the original broad grid is not mandatory. |
| Independent evidence for changed inference | Numerical review and release disposition complete; stronger performance claims unqualified (M2/M3) | Earlier multi-dataset studies and the saved-case audits are available. The 499-refit pilot is one dataset, not independent coverage evidence. Cases used to develop the repair are regression cases, not a holdout. | Use the target-specific evidence map, not mandatory completion of protocol v1. If asserting a new sampling-performance or repair-benefit claim, supply matching independent evidence and MC uncertainty; pair comparator arms only where the question requires them. Historical replay is not a holdout. Keep ordinary intervals, standardized differences, curves and bootstrap/LRT qualification distinct; resolve adverse results without changing thresholds to pass. |
| Extreme slopes, empty categories and boundary approaches | Representative safe-failure/output checks complete (M2/M4); broader boundary inference not qualified | The saved steep-slope case, eleven saved zero-boundary candidates and an empty-category representative remain ineligible. Actual weak, unavailable and unbounded interval examples now retain states/reasons through figures, Markdown, CSV and RDS. This is representative display evidence, not every boundary case or every presentation route. | Retain the checked summaries, intervals/comparisons, plots, reports and starting-value/integration guidance in M5. A reproduced incorrect admitted result still requires repair. Formal boundary estimation needs its own specified target and evidence; a new universal solver is not required for this release. |
| Reconcile changed bootstrap results | Provenance reconciliation and output repair complete (M2/M4) | The original object has 408 admitted / 91 unresolved; the assembled category-case reanalysis has 470 / 29. Seeds and all 62 replaced rows match their retained records. Two later finite repairs remain separate. Reanalysis history now follows print, intervals and report tables. | Neither saved object is a full run of the current estimator. Preserve both unchanged; do not claim 472 accepted or current-procedure bootstrap performance. A complete new bootstrap is needed only to make a corresponding new performance claim; repeated-dataset coverage remains unqualified. |
| Assessment-to-feedback and planning workflows | Current-source educational walkthrough complete; author integration review (M4) | The 282-rating educational example runs from rubric/assignment review through RSM MML, diagnostics, feedback, figures, report/export and RDS reload. Saved precision now reaches result/report decisions correctly. Existing PCA/group/MI and complete/incomplete D-study outputs retain matching summaries and plot data without refitting. Earlier extended-model evidence is retained. | Preserve the explicit category choice, session-dependent screening explanation and dedicated branch routes during final integration. This is author review, not a novice-reader study, coverage validation or fresh qualification of every model/option. See the assessment-workflow record below. |
| Current-source help and local archive | Complete locally (M5) | The September 26 archive has executed/replayed updates for three articles, twelve unchanged article outputs, 72 described figures and a verified 15-entry vignette index. The full test findings and focused repairs are reconciled; the final archive passes its applicable checks with one maintainer/update-frequency NOTE. | Preserve the frozen source and its evidence. Any later runtime change needs impact-specific checks; the earlier CI/Windows snapshots do not validate this archive. |
| Successor CI, Windows and publication | Candidate handoff complete (M6); submission checks pending | `6f541bfa` passes all five CI environments, including Windows/R-release. Matching website deployment and rc.6 assets are verified. Both Win-builder versions have received the same archive; URL and CRAN reverse-dependency checks are complete. | Review the current R-release/R-devel result logs before the final release/submission decision. Earlier Win-builder results retain their original source identity. CRAN submission and acceptance remain distinct. |

The claim/evidence mapping is now recorded in the
[retained-claims review](inst/validation/claim-reconciliation-0.2.4.md#2026-09-25--map-retained-claims-to-evidence-and-audit-changed-admissions).
The 30.54-hour, 8,000-dataset/two-arm plan is retained as an unexecuted protocol,
not a mandatory release deliverable. No source, margin or result was silently
changed to reduce its cost.

A current-source replay of 17 saved historical cases gives exact endpoint
agreement for ten eligible controls and keeps five originally unavailable
cases unavailable. Two formerly unavailable cases now receive cautioned
intervals. Their likelihood/integration checks agree with independent reference
calculations. A failed direct cross-coordinate SE comparison was explained by
the nonzero-gradient term in the Hessian transformation, with the original
failure retained. This is numerical evidence, not fresh coverage evidence or
proof that all historical optimizer results remain unchanged.

The earlier difference evidence concerned relative slopes and different
contrasts. A further [saved-fit target reanalysis](inst/validation/gpcm-saved-target-reanalysis-0.2.4.md)
now evaluates the two standardized differences and explicit probability and
information grids on all 800 historical fits. It uses matching saved generating
truths and current interval calculations, without refitting. This supplies
target-specific retrospective evidence, not an independent current-estimator
confirmation or bootstrap coverage. The 400 historical null LRT pairs remain
part of this 800-fit corpus, not extra independent evidence.

The representative interval-display/replay review is complete, with repairs
for invisible unavailable curve intervals, clipped cautions and missing
Markdown status/reasons. See the
[display review](inst/validation/claim-reconciliation-0.2.4.md#2026-09-25--preserve-unavailable-and-weak-inference-through-figures-and-reports).
Only plotting and report composition changed; numerical evidence is retained.

The **current-source assessment-to-feedback walkthrough is complete** at its
stated educational-example scope. It exposed and repaired a dropped precision
assessment in ordinary result/report decisions; the supported, unsupported and
unreviewed states remain distinct, and fit restrictions still take precedence.
The guide now connects category policy, screening settings, archived results
and the optional feature/MI/G/D routes. See the
[assessment-workflow record](inst/validation/claim-reconciliation-0.2.4.md#2026-09-25--complete-the-educational-assessment-to-feedback-walkthrough).
Do not repeat this walkthrough or the completed display review without a
relevant change or failure.

The **GPCM probability-interval evidence** informs the release dispositions
below. The saved-fit reanalysis finished in 185.7 seconds without generating data or optimizing models. In the
small incomplete unequal-rater-slope condition, the nominal-95% sandwich
Bonferroni family covered 82/98 available datasets (83.7%, MC interval
74.8–90.4%), or 82/100 planned datasets. This adverse result is retained in the
public guide; multiplicity adjustment is not a remedy for a poor marginal
approximation. Standardized-difference and information results have their own
tables and counts of planned and available datasets. This does not establish that all current-estimator
fits behave the same way or that bootstrap intervals solve the problem.

The [matched-refit attribution check](inst/validation/gpcm-probability-refit-attribution-0.2.4.md)
is now complete. All 100 datasets in that adverse cell were refitted under the
current numerical implementation with ordinary initialization and unchanged
settings. Objectives, parameters, probabilities and interval endpoints are
exactly unchanged; family availability and coverage also remain unchanged.
The computation took 479.5 seconds. An independent analytic probability
Jacobian/full-covariance propagation agrees with public output on the two
prespecified refits (maximum endpoint error below 2e-9). The optimizer-version
difference does not explain this cell's shortfall. This is not proof of global
optimality, integration accuracy, or approximation error as the only cause.

Close this attribution task; do not repeat the same 100 fits or launch the
broad grid to seek a better-looking coverage result. Printing and default
curve subtitles now identify approximate intervals; numerical availability
is not a nominal-coverage certification. Keep the API and its calculated
values without arbitrary sample-size refusal or outcome-tuned widening.

### Release dispositions for GPCM inference

These decisions settle what the retained APIs mean in 0.2.4. They do not turn
an adverse result into successful statistical qualification. All agreed APIs
remain included; no entire workflow is deferred or removed. The release
provides explicitly approximate inference, with numerical checks and the
following target-specific evidence, rather than a new finite-sample guarantee.

| Retained family | Disposition for 0.2.4 | Claim not established |
| --- | --- | --- |
| Relative/standardized slopes; model and independent-cluster sandwich covariance | Retain approximate log-Wald intervals with full joint covariance, numerical cautions and unavailable outcomes. Reuse independent calculations and historical design-specific sampling evidence; changed numerical branches have separate regression evidence. | Uniform nominal coverage, general misspecification robustness, or fresh sampling qualification of every changed branch. |
| Ratios and differences | Retain declared-scale, covariance-aware delta intervals and finite-family Bonferroni adjustment. Standardized differences have the separate 800-fit retrospective evaluation. | Coverage for arbitrary contrasts or designs, or transfer of relative-contrast performance to a different scale. |
| Probability curves | Retain fixed-native-ability logit-delta intervals as approximate calibration uncertainty. Numerical transformations are checked; all 100 matched current refits reproduce the adverse cell. | Nominal 95% family coverage: the observed sandwich Bonferroni rate is 82/98 available, with MC bounds 74.8–90.4%, or 82/100 planned. This claim is rejected for the evaluated procedure/condition; no remedy is asserted. |
| Information curves | Retain log-delta intervals for information per rating, with their own numerical and retrospective sampling evidence. | Total-test information uncertainty, Person-score uncertainty or a continuous simultaneous band. |
| PCM/GPCM LRT and local IC | Retain asymptotic testing and likelihood-based ranking only after their separate matching, nesting, counting and numerical checks. The 400 historical null pairs remain a subset of the 800-fit corpus. | Finite-sample test calibration for arbitrary sparse designs, automatic scoring-policy selection or proof of global maximization. |
| Basic bootstrap slopes / PCM-null bootstrap LRT | Retain fitted-model simulation, correct basic quantiles / null-test counting and unresolved-outcome bounds. Original and selected-update results remain distinguishable through saved output. | Repeated-dataset coverage/Type I error, a current-procedure performance estimate from the assembled pilot, or a remedy for probability-curve undercoverage. |

The bootstrap provenance question is closed by retaining the original 408/91
run and the separately labelled 470/29 selected-update analysis. The later
two repaired finite cases have not been spliced into either object. Checks
match all seeds and all 62 replacement vectors to saved records, with unchanged
input-file hashes. The reporting repair preserves selected-update history
through interval cautions, printing and result/report tables. It changes no
draw, interval endpoint, estimation rule or acceptance decision.

The probability nominal-coverage claim and bootstrap repeated-dataset accuracy
remain unresolved statistical capabilities, not hidden release achievements.
Improved procedures require a justified method and independent evaluation;
they are not silently claimed by this release decision. The broad grid and
nested study remain unexecuted. General guarantees were already outside the
stated scope; no agreed API is being moved to another release.

**M5 and M6 candidate publication are complete for rc.6.** The final
archive SHA256 is `0f1f21c042512318a3b3c8ffbce246bcdab21db1d3dc2dce2cf5e091c58155e1`.
The initial full suite passed 23,290 expectations and found three failures;
these are repaired, with 516 focused expectations passing. The final archive
passes its applicable check with 0 errors, 0 warnings and one NOTE for maintainer
information/update frequency. Examples and manuals passed initially and were
not repeated. The final delta is limited to input routing, two test files,
NEWS/date and the restored vignette index; numerical core and article bytes
are unchanged. Source documentation and fresh-session checks complement the
installed suite; 32 repository-research skips retain their existing scope.

Do not repeat the 100 matched refits, 800-fit reanalysis or full suite without
a relevant change or failure. The five-platform run and website deployment
were separately authorized after local completion. Tagged release publication,
Win-builder upload and CRAN submission remain separate. Probability undercoverage and unqualified bootstrap sampling claims
remain as stated in the release dispositions.

The common-MML consumer repair remains supported by its focused checks; those
checks do not establish weak-information frequency or sampling coverage. See
the [consumer-review record](inst/validation/claim-reconciliation-0.2.4.md#2026-09-25--preserve-common-mml-cautions-across-consumers).
The steep-slope case is not an automatic next optimization project.

Before an independent study starts, specify each question, generating model,
assignment/missingness mechanism, target and old/new comparator. Fix seeds not
used to develop the repair, replication/Monte Carlo precision, practical
accuracy and performance criteria, and a resource/stop budget. Separate
conditional coverage among available intervals from covered-and-returned
frequency over all planned datasets; report failure and width distributions.
A bootstrap study additionally needs a fixed replication/failure-handling
rule. Numerical tolerances do not substitute for these statistical decisions.
If an implementation defect changes the protocol, retain the earlier results
and identify which evidence needs renewal rather than silently reusing it.

The local endpoint is a coherent current source with the included outcomes
supported at their declared level, warnings/refusals preserved across outputs,
and a checked installable archive. A practical limitation is not made complete
by adding a warning if the output still contradicts its advertised target.
Conversely, universal coverage, convergence for every sparse dataset,
multidimensional MFRM, arbitrary G-theory structures, new GPCM slope families
and full cross-software equivalence are not hidden prerequisites. Their
existing exclusions are unchanged; this review adds no new deferral.


## GPCM inference follow-up after local integration

The user approved implementation of the additional inference targets found in
the review. The scope below belongs to the current 0.2.4 local source. Earlier
archive checks are historical evidence for their own source, not checks of
these additions. Default relative/model intervals remain compatible.

| User outcome | Implemented route | Qualification and completion boundary |
| --- | --- | --- |
| Preserve an explicit population model while checking quadrature | `mml_quadrature_sensitivity()` replays formulas, person covariates, factor coding and the same canonical design; slope endpoints and eligibility are compared. | Intercept-only and categorical-covariate refits are verified. Matched PCM/GPCM decisions must be compared on common grids. No universal grid cutoff is selected. |
| Use one information calculation for IC/LRT and intervals | Shared joint observed information with a configurable dense-matrix workspace budget. | A 120-Person, 27-criterion model with 83 free coordinates returned all 27 slope intervals and passed the IC solution check. This is one numerical case, not a general capacity guarantee; the workspace estimate excludes likelihood arrays and other process memory. |
| Quantify standardized slopes and specified comparisons | `confint()` supports population-SD-standardized slopes, named slope ratios/differences, corresponding Wald tests and Bonferroni adjustment. | Includes the full scale covariance and cross terms. With covariates, standardized means residual-population-SD scaling. Adjustment covers the requested finite family. |
| Assess working-model uncertainty with independent clusters | `method = "sandwich"`, default Person clusters or an explicit complete larger-cluster map. | Requires sufficient score-vector rank and many independent clusters. It cannot remove estimation bias or repair informative assignment. Richardson derivatives independently agree with the Person score calculation. |
| Use a fitted-model simulation alternative | `bootstrap_mfrm_gpcm()` and saved-result `confint()` implement basic parametric bootstrap intervals or a matched PCM/GPCM bootstrap LRT. | Every planned trial and failure is retained; unresolved draws bound intervals/p-values. Small runs verify mechanics only. Profile likelihood and a general small-sample coverage/size guarantee are not included. |
| Show uncertainty in fitted curves | `mfrm_curve_intervals()` and its plot method supply category probability and per-rating information intervals. | Known native-scale ability grid, full calibration covariance, optional sandwich/Bonferroni, color plus line type and removable annotations. A finite-grid adjustment is not a continuous simultaneous band. |
| Reuse selected inference in feedback and reporting | Saved slope/curve intervals and bootstrap results connect to `apa_table()`, `plot()`, `plot_data()`, `as_ggplot()` and named `mfrm_results(intervals = ...)` routes. Reports and exports retain target, level, method, multiplicity, cluster settings and unresolved outcomes. | Source identity is checked; replay reloads saved results. Wright/Pathway location and fit displays retain their own targets. Discrimination intervals do not classify rater quality or choose scoring weights. |
| Carry RSM/PCM fixed-facet intervals through the same reporting workflow | Saved `mfrm_facet_intervals()` results connect to APA tables, named `facet_` result plots, base/ggplot customization, reports and exported replay. Help and the RSM/PCM example are updated and executed. | This is M4 integration, not a change of estimator, covariance or coverage qualification. Selected interval methods do not replace ordinary Wright/Pathway uncertainty. |

The completion order is now the [current-source register](#remaining-work-for-the-current-source):
retain the completed common-MML consumer checks and registered protocol,
reuse the completed engineering, changed-inference and supported-workflow
reviews, M5 archive checks and the completed five-platform checks and candidate
publication under M6. A single dataset with many bootstrap refits
is not a repeated-dataset coverage study. Changing the point estimator requires
paired evidence of benefit and a documented target change; it is not an automatic
response to one low-coverage cell.

The release dispositions above settle the retained approximate APIs; stronger
statistical performance claims remain unqualified. The focused M4 checks now
cover agreement among the changed outputs, help, NEWS and retained evidence.
The September 26 successor completes M5 locally, as recorded above. The saved-inference follow-up
also corrects displayed replay code in summaries/HTML/viewer output so it saves
and reloads the complete result; reconstructing from the fit alone would omit
attached inference. Starter export indexes now expose the saved RSM/PCM and
GPCM inference figures with descriptions. The changed paths have focused
regression evidence, without repeating the numerical studies. The September 26
M5 record supplies the new source identity and applicable integrated checks.
M6 requires matching platform checks and publication; those gates are not
inferred from one successful simulation. Profile likelihood, JML inference, additional
slope structures and cross-software joint-interval equivalence remain separate
work; bootstrap is the implemented simulation alternative in this scope.

### Evidence available for the remaining decisions

Earlier studies cover relative/standardized slopes, model/sandwich intervals
and selected assignment/sample-size contrasts under declared normal-population
conditions. They include low coverage in a small incomplete condition and wide
intervals; neither sandwich estimation nor bootstrap is qualified as a universal
remedy. Those results apply to their original estimator and admission rules.
See the [inference-extension record](inst/validation/claim-reconciliation-0.2.4.md#september-24-gpcm-inference-extensions)
and [design/reporting follow-up](inst/validation/claim-reconciliation-0.2.4.md#september-24-gpcm-inference-reporting-and-design-follow-up).

The saved 499-refit pilot and its selected replays retain all failures. The
recorded singleton-only change raises availability from 408 to 470 while all
three standardized 95% basic intervals remain zero to infinity. Later audits
separate unused categories, zero-discrimination approaches, premature stopping
and severe integration sensitivity. This is one-dataset diagnostic evidence,
not repeated-dataset coverage. The original pilot has not been rewritten with
the later repaired estimates.

Two premature-stopping cases now recover better finite solutions through the
native API, with agreement at 61/101 quadrature nodes. A remaining ill-conditioned
information case now passes numerical refinement without an eigenvalue floor,
with explicit cautions through the GPCM output routes. Its weakest standardized
slope still has a 95% log-Wald interval around 1e-25 to 1e21. Numerical verification
does not establish useful precision or boundary coverage. The saved boundary
candidates remain ineligible. Details and reusable source-specific checks are
in the [optimizer record](inst/validation/claim-reconciliation-0.2.4.md#2026-09-25--recover-finite-gpcm-solutions-before-relaxing-inference-rules)
and [information review](inst/validation/claim-reconciliation-0.2.4.md#2026-09-25--verify-weak-mml-information-instead-of-blanket-exclusion).

These completed repairs close the reproduced numerical problems under their
tested conditions. The subsequent common-MML consumer review repairs warning
propagation. Those repairs alone did not establish sampling qualification or
workflow completion; the later release dispositions, representative output
checks and M5 integration above supply the separate release decisions.
M6 candidate publication is verified for rc.6. The earlier sequence of repeated case investigations is
superseded by that register. A new general boundary estimator is not inferred
from finding an unavailable interval; the demonstrated refusal/output behavior
and remaining statistical limits remain in force.

## Rater feedback across application areas

The first application is educational performance assessment, with feedback
to raters as a central use. The APIs should also support appropriately modeled
ratings in music, psychology, health-professions education and judged sports.
Column names identify roles such as the rated unit, judge, task, criterion and
occasion. Application-specific score maps, model assumptions and reference
constraints must remain explicit. Repeated performances by one person do not
become independent merely by giving each performance a new ID.

Music assessment provides evidence that linking design and model fit affect
the interpretation of rater-adjusted results
([Wind, Engelhard, and Wesolowski, 2016](https://doi.org/10.1080/10627197.2016.1236676)).
A figure-skating study illustrates detailed feedback to individual judges
([Looney, 2004](https://pubmed.ncbi.nlm.nih.gov/14757990/)). These applications
motivate examples and validation questions; they do not establish support for
every scoring system or every model used in those papers. Preserve individual
ordered ratings rather than substituting weighted competition totals.

The feedback workflow should connect rater coverage and overlap, signed
severity with its reference and uncertainty, category use, fit and selected
rating discrepancies. Existing diagnostics and plots provide the components.
Local refinement now preserves unavailable diagnostics, screening settings
and fit restrictions across dashboard tables, plots and exported reports;
the README connects coverage, category use and case review using existing
APIs. A single 5,000-person rotating-rater probe completed and exposed costly
pairwise diagnostic assembly; that path now runs faster with identical outputs
on the saved fit. A guarded final optimizer restart subsequently resolved the
terminal-gradient review in this workload without relaxing its tolerance;
OS memory use was also measured. A subsequent same-data integration review
found changes beyond the chosen numerical budgets at 31 points. One 61-point
refit followed by a 121-point evaluation met those movement budgets for facet
SEs, local parameter displacement and the selected person-score probes.
This is evidence for that workload, not a sufficient grid for all data or a
guarantee of interval coverage or capacity. A small paired simulation pilot
now supplies preliminary rater-interval evidence for complete, rotating-pair
and weakly linked assignments under a matching response/population model.
Remaining evaluations are selected through M2 for the retained release
claims; this historical workload is not an automatic queue for more pilots.
Severity, inconsistency and differential functioning answer different questions. Screening flags
support rubric review and additional common ratings, not automatic rater
exclusion or a demonstrated effect of training.

Stress evaluation will distinguish computational capacity from the accuracy
of rater feedback. At comparable rating budgets, vary common linking sets,
overlapping panels, weak bridges and disconnected assignments, then examine
rater precision and false flags as well as person scores. Separate planned
nonassignment from missing assigned ratings and selective nonresponse.
Larger samples cannot repair a design that does not identify the intended
contrast. Design-dependent sensitivity is documented for sparse rater-bias
screening ([Wind and Ge, 2021](https://doi.org/10.1177/0013164420988108)).

Increase person counts, facet counts and response-pattern length separately,
recording elapsed time, memory, convergence, unavailable results and numerical
agreement. Comparisons with TAM or ConQuest require a shared model and
estimand; their capacity is not a demonstrated capacity of mfrmr. Existing
tests and stress results will be reused where applicable, with additional
work directed at the remaining feedback and scale questions.

## Generalizability theory

The planning question is how tasks, raters or score weights affect the
dependability of a score used for ranking or for absolute decisions. For
component and composite scores, between-score covariances matter; averaging
separate reliability coefficients does not answer the composite question.

The functions `mfrm_multivariate_gstudy()` and
`mfrm_multivariate_d_study()` provide the following scope:

| Part | Implemented scope | Interpretation boundary |
| --- | --- | --- |
| G-study model | One or two named random facets: crossed, or one nested within the other with persons crossed. Score components are fixed, with one observation per retained cell. ANOVA handles complete balanced data; MINQUE(0) handles identifiable incomplete or unequal configurations. | Identities, including parent/child pairs, must be shared across persons and scores. Naming an Occasion facet does not model growth. Fixed facets, nesting within persons and partially shared identities are unsupported. |
| Covariance components | Three components for one facet; seven for two crossed facets; five for Person-by-(Child-within-Parent). Raw negative or indefinite estimates are retained. | Highest-order interaction and within-cell error are combined. Numerical rank and covariance admissibility do not establish estimation precision. |
| D-study | Future complete balanced scenarios preserving the crossed/nested structure, original scores, named weighted composites and signed differences, with G/Phi and SEMs. | Incomplete or unequal source designs require an explicit future grid. Nested child counts are per parent, not total pool sizes. Projections do not estimate reliability of the sparse roster; unequal future allocations are unsupported. |
| Output | Metric-specific availability, component diagnostics, base plots, ggplot conversion for point projections and exact plotted values. | A non-PSD component does not automatically suppress every metric. Calculability does not validate the whole covariance model. No automatic design recommendation is provided. |
| Prespecified plan differences | `mfrm_multivariate_d_compare()` supplies approximate paired-delta intervals and base plots for two common random facets, including incomplete MINQUE(0) sources, when `assumption = "normal"` is explicit. | These are pointwise normal-theory approximations. One-facet, nonnormal-robust, nested/fixed-facet and simultaneous intervals, adaptive weight/plan selection and informative-missingness correction remain unsupported. |

The existing `mfrm_generalizability()` / `mfrm_d_study()` main-effects workflow
remains separate. Neither workflow estimates reliability on the MFRM latent
scale or pass/fail classification accuracy. Explicit missing-row omission
records exclusions; it does not correct selective assignment or nonresponse.

The implemented workflows answer the following questions within their stated
scope. Integration preserves these paths; extensions require a named need and
evidence for the additional claim.

| User question | Available in the candidate | Integration requirement or separate extension |
| --- | --- | --- |
| Can I use the current point projections correctly? | Data → G-study → future scenarios/composites → tables and plots, with saved-result reuse. | Preserve metric-specific omissions, score units, weights and limitations in displayed and saved output. Changing only future counts or score weights reuses the G-study. |
| How uncertain is the improvement between two feasible plans? | `mfrm_multivariate_d_compare()` supplies approximate paired-delta intervals for prespecified G/Phi/SEM differences under normal random effects with two crossed facets. | Preserve the sampling target, explicit assumption and unavailable-interval reasons. Existing bounded checks do not qualify nonnormal-robust, nested or simultaneous intervals; these remain separate extensions. |
| Does a sparse source design estimate the quantities needed for planning? | MINQUE(0) estimates separable covariance components from supported incomplete designs; D-studies project explicit complete future plans. | Reuse existing recovery evidence. Investigate a named unresolved allocation, distribution or missingness condition only when needed for the intended use. Rank, connectivity or a returned coefficient alone cannot establish precision or correct selective missingness. |
| Does my assessment require task-specific rater teams? | Person-by-(Child-within-Parent) point estimation and projections, with independent QR/kernel and projection checks. | Preserve the meaning of child counts per parent. Other nesting, partly shared raters and nested intervals remain separate extensions; current checks do not establish recovery for arbitrary sparse allocations. |

For planning uncertainty, preserve dependence between scenarios and composites;
separate intervals cannot simply be treated as uncertainty in their difference.
Distinguish uncertainty for a prespecified comparison from inference after
selecting the largest estimate. Evaluate how often a plan choice differs and
how much true dependability it loses; these are different criteria. The paired
comparison API now supplies approximate pointwise intervals for two crossed facets
under an explicit normal random-effects assumption. Existing saved-result
comparisons and targeted distribution checks support this bounded method;
they do not establish robustness across score distributions and designs.

The implemented uncertainty scope uses the common-facet model and prespecified
complete future plans. Automatic weight selection, optimal sparse assignments,
simultaneous guarantees and informative-missingness correction are outside
that scope. When the assumptions or supported design do not match the intended
use, do not interpret the returned approximation as a qualified interval.
Point projections retain their own model and design requirements.
Equal rating counts need not imply equal examinee burden or cost.

See [the G-theory workflow](README.md#multivariate-g-theory). The existing
GENOVA comparisons remain useful checks of formulas and negative-component
conventions; full software equivalence is not a development or release goal.

## External features, grouping, and missing values

The implemented workflow reviews one row per Person, rater or task
and clusters those entities separately. Gower/PAM supports mixed features;
Gower with average or complete linkage supplies hierarchical partitions and
dendrograms. Profiles, silhouettes and setting comparisons help users interpret
results without identifying groups as ability levels, rater quality or latent
measurement classes.

`mfrm_cluster_imputed()` accepts user-fitted `mice` completions and an explicit
set of eligible missing feature cells. Observed values, IDs, feature types,
missingness reasons and imputation diagnostics are preserved. Co-membership
across completions describes sensitivity to that model; it is not Rubin pooling,
sampling stability or a posterior probability of class membership.

`mfrm_cluster_compare()` compares group counts, feature selections, weights and
methods on the same entities. Imputed comparisons use paired completions from
the same retained model. Removing a clustering feature does not remove it from
the imputation model. No setting or consensus partition is selected automatically.

| User need | Current workflow or condition for an extension |
| --- | --- |
| Use the existing descriptive workflow | The executable tutorial connects ID/omission accounting, profiles, plots and paired imputation comparisons. Preserve these paths during integration and reuse existing stress evidence within its tested workload; input caps are not runtime or memory guarantees. |
| Relate person, rater and task groups | Preserve separate feature tables and join classifications to planned/observed ratings by ID. Descriptive relationships must not become causal group effects or a joint clustering model. |
| Use numeric PCA/k-means | The local `mfrm_pca()` / `mfrm_cluster_kmeans()` route retains explicit standardization, squared-distance weights, retained components and initialization. Paired imputation comparisons and original-unit profiles are available; validate selected features and interpretation of the transformed space. |
| Make claims about stable groups or classify new entities | Specify the sampling or prediction target separately from imputation sensitivity. Evaluate it before adding a stability statistic or assignment API. |

Missing external attributes, unassigned ratings and missing assigned responses
remain distinct. The assigned-response MI workflow is implemented locally and
included in the 0.2.4 plan. It preserves rating structure and combines eligible
downstream estimates and uncertainty on a common scale. Its joint-RSM example and paired MAR/MNAR comparison now support the stated
bounded MAR use while retaining severe MNAR bias and undercoverage. Supplied
imputation models still require substantive justification and sensitivity
review; filling every empty cell or labeling missingness MAR is not a correction.
Ward linkage, pooled trees, joint cross-facet imputation and pooled inferential
group effects are outside the present external-feature workflow.

See [external-feature examples](README.md#external-features-and-exploratory-groups)
and `vignette("mfrmr-external-features", package = "mfrmr")`.

## Rater assignment and anchors

Design support asks which allocation serves a declared Person or facet target
within total workload, per-rater workload and examinee-burden constraints.
The unit of cost must be explicit: a performance, a scored response and an
individual criterion rating need not have the same cost.

A later assignment extension should reuse existing assignment and coverage review,
retain disconnected/failed cases and subgroup disadvantages, and compare
estimation error or qualified interval performance for a named target.
Connectivity, balanced workload and an anchor percentage alone cannot select
a design. Facet precision cannot substitute for Person-difference precision.

Direct anchors, group anchors and estimated linking have different uncertainty.
A future comparison that refits models must repeat any estimated linking or
selection and preserve covariance between compared results. Design evaluation
for observed fixed raters can proceed within its own supported model; design
for replacement raters requires the matching random-rater prediction model.

## Random-effects MFRM and testlet covariance

This is a requested model-extension track for generalization beyond observed raters:
how uncertain is a Person comparison when different raters are sampled?
Current fixed-facet MML, post-fit shrinkage and observed-score G-theory do not
jointly estimate a random-facet MFRM.

The local implementation uses one observed scale, unit weights,
adjacent-category RSM probabilities, one random-rater intercept shared across
Persons, fixed task/criterion effects and a normal Person distribution with
estimated variance by default. A known SD is an explicit restricted option.
Observed-rater intervals and replacement-rater probabilities at specified
abilities are distinct outputs. Conditional Person scoring has an independent
fixed-calibration posterior comparison on twelve full/reduced rosters. Its
bounded numerical support does not establish repeated-sampling coverage. A
separate eight-roster comparison now supports local calibration-likelihood
changes; it does not qualify an entire SD profile or variance boundaries.

The 800-dataset interval comparison did not qualify automatic individual-rater
normal bounds; these are now withheld by default. Explicit normal approximations
and bootstrap comparisons retain their limitations, unavailable refits and
variance boundaries. Availability, width and coverage must be assessed together;
bootstrap availability alone does not make it a qualified replacement.

Reuse an existing computation only when its probabilities, effect sharing,
constraints and target match. A cumulative-link ordinal model or a new random
effect integrated independently for every Person is a different model.
Person-local testlets require a different covariance structure. PCM, sampled
tasks, covariance and random slopes follow concrete needs after this initial
scope; they are not all prerequisites for a first bounded random-rater method.

The initial local testlet workflow now accepts explicit non-overlapping
membership within a Person, retains fixed facet roles and fits one common
normal local variance, with normal ability variance now estimated by default.
An explicit known ability SD retains a fixed-population analysis.
Nested-quadrature checks, continuous conditional Person
scoring, saved fits, plots and beginner guidance form a usable bounded route.
Scoring uses the complete supplied rating set, without implicitly appending
responses or conditioning on saved local modes. Prior-only and unavailable
rows remain explicit. Estimated variance boundaries withhold regular
calibration intervals; no regular variance interval is supplied.

Both local model routes now connect stored calibration and explicitly supplied
predictions or random-rater bootstrap intervals to the common results,
static-report and CSV/HTML/RDS export workflow. Reports preserve numerical
checks, missing-score accounting and interval limitations without refitting.
Model-aware comparison, scoring, descriptive diagnostics and figures are
implemented locally. The retained interval-output decision is implemented:
fixed-facet and step estimates/approximate SEs remain the default, with explicit
normal bounds and a separate approximate rater-SD profile. Numerical/boundary
restrictions and unavailable rows remain. M3/M4 cross-workflow source, output,
help and evidence reconciliation is complete for the retained 0.2.4 scope.
The interactive viewer and broader inferential
extensions have the separate scope stated above.

Calibration-aware Person uncertainty remains a later extension. For testlets,
the 480-dataset estimated-population study and numerical-selection repair now
support the stated conditional-coverage criterion in two larger balanced
conditions. Small/sparse conditions and regular calibration intervals remain
inconclusive; Person point estimates do not uniformly improve relative to
ordinary RSM. Numerical comparisons of additional memberships, categories and
unequal blocks do not establish their coverage. Retain earlier fixed-population
results under their original assumptions. Correlated or heterogeneous testlets
and joint shared-rater/testlet models remain separate extensions.

## Model scope

Joint multidimensional MFRM is deferred while the existing APIs, shared help,
visualization and reporting boundaries are consolidated. Dimension assignment,
loading constraints and covariance identification remain undecided; this
deferral does not imply implementation or completion.

| Area | Current restriction or trigger for further work |
| --- | --- |
| RSM/PCM | Preserve the supported fitted-model workflows and fixed-normal MML portable scope. Extend only with matching identification and uncertainty evidence. |
| GPCM | A selected facet owns slopes and steps. MML IC ranking, the matched PCM/GPCM LRT and approximate relative-slope intervals have separate checks; see G1--G3 below. Small incomplete designs retain coverage/precision limits. JML intervals, additional slope structures and portable GPCM remain separate work. |
| JML | Uncorrected estimates retain infinite extreme Persons; optional display replacements do not change primary estimates. SEs and normal bands remain exploratory. A correction or portable JML needs a separate method decision. |
| Estimated populations and Fair Scores | Existing conditional/diagnostic output retains its limits. New population intervals, omnibus DRF inference or inferential FairZ methods require their own target and evidence. Inclusion requires a specific stage-2/3 scope decision; the new release order does not itself qualify them. |
| Multiple observed scales | Require explicit scale identifiers and a concrete separate-scale use case. Do not silently pool or link scales. Inclusion requires a specified model-extension scope. |

See [model and interpretation boundaries](README.md#model-and-interpretation-boundaries)
for the current output rules. Fixing a numerical or reporting defect does not
by itself qualify a new inferential claim.

## Before CRAN submission: interface and GPCM review

The September 24 review revises the earlier proposal to put API integration
entirely in 0.2.5. mfrmr 0.2.4 has not reached CRAN. Several confusing entry
points, including feature clustering, supplied-imputation review and the two
RSM extensions, are new relative to CRAN 0.2.3.1. Clarifying their canonical
names and behavior before first CRAN publication avoids teaching an interface
that immediately needs migration. GitHub candidates already exist, so those
calls and saved objects still need compatibility. Existing CRAN interfaces
such as `fit_mfrm()` require particular care.

The agreed submission scope now includes completing MML information-criterion
comparison, PCM/GPCM likelihood-ratio testing and relative-slope intervals for
the existing GPCM. These are 0.2.4 release requirements, not default 0.2.5
deferrals. They do not add another slope family or substantive ability
dimension. Naming changes and documentation of missing functionality do not
complete these requirements.

| Before submitting 0.2.4 | Completion condition | Work that is not bundled into it |
| --- | --- | --- |
| Clarify GPCM terminology and reconcile claims | Help, summaries, capability guidance and comparisons distinguish the one-facet slope/step structure from limits on estimation, uncertainty and scoring. Correct contradictory instructions. | Removing guards merely to stop using the word bounded. |
| Integrate the principal API routes | Complete the [API work package](#first-integration-work-package-api-names-arguments-and-help), prioritizing misleading new names and arguments/defaults that change the analysis. Adopt justified canonical names, preserve old calls and saved objects, and make help/examples/NEWS agree. | A cosmetic rename of every export, a new universal wrapper, or silent changes to defaults or `predict()` return values. |
| Complete existing-model GPCM inference | Implement and verify output-specific MML IC comparison, matched PCM/GPCM LRT and approximate relative-slope intervals. Eligible regular cases must return useful output; unstable, singular or incompatible cases must retain explicit reasons. Close G1--G3 below before final source freeze. | Deferring the three whole operations to 0.2.5, treating explanatory restrictions as implementation, or merely deleting guards. Universal coverage and a global-maximum theorem are not required. |
| Freeze and verify the revised candidate | Review the complete source/help/migration changes, check affected behavior, then verify one final archive and its applicable platform checks. Preserve the identity of the earlier Windows result. | Repeating the full suite after each wording edit or treating a previous archive's result as a check of new code. |

This trade-off accepts some release delay and a final candidate check to avoid
avoidable user confusion and a second migration immediately after release.
Unrestricted GPCM, separate slope/step structures and additional slope families
would change the statistical scope and remain separately admitted work. If the
eligibility review exposes an unreliable advertised result, repair or withdraw
that claim before submission; a limitation paragraph cannot make it correct.

The September 24 **retain-with-restrictions** proposal is superseded by the
user's instruction to resolve these three operations in 0.2.4. The earlier
disposition is not a final scope decision or evidence that the shared
eligibility policy is the right design.
The current implementation retains numerical fitting, curves,
conditional scoring and descriptive sensitivity comparisons
within their documented limits. The local IC implementation now separates
solution checks from interval/test readiness, including the estimated-population
PCM comparison. The matched PCM/GPCM LRT and approximate relative-slope
intervals are now implemented locally, with separate eligibility checks and
targeted sampling evidence. For the earlier G1--G3 snapshot, package integration
and source freeze were completed locally under M5; these results do not establish
universal finite-sample inference. The review found and repaired an actual
legacy-output defect: missing slope-eligibility metadata could expose ordinary
SEs and intervals. Current likelihood/solution checks are now required, and
diagnostic covariance values remain separate from qualified approximate bounds.

Statistical qualification is output-specific. IC comparison requires
its own common-likelihood, solution and integration evidence, whereas slope
intervals additionally require an uncertainty method and assessment of its
sampling behavior. Neither output waits for all proposed GPCM extensions.
That earlier source reconciled the principal API choices with saved results,
summaries, figures, reports and installed help. Category policy and actual
score recoding remain distinct, including unknown metadata in older objects.
The feedback guide and GPCM inference decisions are included in the checked
archive. The M5 record identifies the full run, test repairs and reused results;
older Windows checks do not validate this successor. Its five-platform CI now
passes, its website is updated and its rc.6 tagged assets are verified under M6. Package checks do not turn restricted outputs into
universal statistical guarantees.

## GPCM: specific restrictions and their exit conditions

GPCM is implemented. In 0.2.4, one selected facet has level-specific positive
discriminations and category steps, and `slope_facet` must equal `step_facet`.
The slope multiplies the full adjacent-category predictor. Relative slopes
have geometric mean one; default MML estimates the normal ability population,
while the explicitly fixed-standard-normal option is a narrower specification.
This is a one-dimensional, single-facet discrimination structure. It does not
estimate task and rater slopes simultaneously.

Public model names now use **GPCM**, without a blanket *bounded* qualifier.
One substantive ability dimension is shared with the current MFRM response
models, and is not a reason to give GPCM a restrictive name. Structural
choices and unavailable operations are described separately. Ordinary GPCM with
item slopes does not require simultaneous task/rater slopes; those represent
an additional model. The [GPCM tutorial](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-gpcm-scope.html) explains
the current parameterization and interpretation.

The local pre-submission API integration replaces the blanket label in help,
model messages, route tables and tutorials with an explicit model description
and the status of the requested operation. This wording change preserves
the substantive model structure. The three inference outputs now use separate
MML checks: information-criterion comparison, the matched PCM/GPCM test, and
pointwise relative-slope intervals. This is pre-freeze work; a release number
alone is not a reason to defer a justified correction. Longer fitting alone
does not establish adequate categories, nonsingular information, model
compatibility or interval coverage. JML intervals and additional slope
structures remain outside these implementations.

| Stage | What it would change | Evidence required before calling it complete |
| --- | --- | --- |
| 0.2.4 pre-submission integration | Readers can distinguish model structure, estimation checks, uncertainty, scoring and diagnostic availability. | Fit help, tutorial, capability table, summaries and comparisons agree on the current behavior. No claim that a new name unlocks an unavailable interval or prediction. |
| 0.2.4 existing-model inference | The current single-facet GPCM provides MML IC comparison, a matched PCM/GPCM LRT and approximate relative-slope intervals for eligible fits. | Complete G1--G3, propagate their separate decisions through summaries, weighting reviews, plots and saved output, and reconcile help/examples/NEWS. Reuse existing numerical evidence and run only missing target-specific checks. JML inference and additional slope structures remain separate. |
| First structural extension | For example, criterion-specific discrimination with rater-specific category steps, using one slope family. | Specify separate slope/step roles and identifiable data patterns; recover the current model when roles coincide and PCM at unit slopes. Verify probabilities, derivatives, parameter maps, numerical behavior, uncertainty and the retained scoring/reporting paths. This removes the equality restriction only for the admitted scope. |
| Further model proposals | Simultaneous task/rater slope families, moderated effects or other structures. | A separate substantive need, constraints separating the effects, informative designs, matched numerical/statistical evidence and useful output. These proposals are not prerequisites for completing the preceding stages. |

Qualification must match the output: a parameter interval, a predictive
quantity and an information-criterion comparison do not have identical
requirements. The present shared readiness policy is an implementation choice
to reassess, not a theorem that all GPCM outputs require one universal boundary
certificate. Any narrower eligibility rule needs its own justified conditions,
failure handling and evidence; it must not merely bypass the existing guard.

The three required 0.2.4 milestones have distinct acceptance conditions:

1. **G1 — MML IC comparison:** reuse the current same-data/likelihood, parameter-count
   and integration checks, then define and verify solution-quality and
   identification conditions independently of slope-CI availability. Exercise
   stable interior fits and numerical/singular counterexamples. No CI-coverage
   or universal global-optimum theorem is required to implement this rule.
2. **G2 — PCM/GPCM LRT:** align the population model, steps and other constraints,
   verify the unit-slope null and free-dimension difference, then assess the
   chi-square approximation under PCM. With only G relative slopes differing,
   the null supplies G-1 restrictions. Slope one is interior; parameter
   positivity alone does not justify a boundary-mixture reference. Neither
   default-model labels nor the IC rule automatically authorize this test.
3. **G3 — Slope intervals:** reuse joint free-coordinate covariance and log-slope
   transformations, specify the approximate interval and its eligible fits,
   and assess availability/coverage in declared relevant designs. Preserve
   failed/singular cases and distinguish relative from standardized slopes.
   Exact coverage under arbitrary misspecification is not an acceptance gate.

Resolve G1 before expanding numerical studies. Keep MML and JML separate and
reuse existing witnesses with their source/model limitations. A numerical or
statistical failure requires repair or a clearly explained reconsideration;
it does not silently move an entire required operation to the next version.
The earlier M5 source completed G1--G3, downstream integration and applicable
package checks. The follow-up above subsequently completed its own September 26
M5 integration; it is not covered by the earlier frozen archive below. A broad
data-design guarantee is not part of either endpoint.

Initial G1--G3 integration status (before the follow-up above): G1 has focused checks plus two
same-data PCM/GPCM comparisons, with Criterion or Rater slopes. It reevaluates
local solution information for GPCM and estimated-population RSM/PCM. It retained
the then-existing 80-free-coordinate execution limit, subsequently replaced by
shared joint information and a workspace budget. It keeps
IC eligibility separate from interval/LRT readiness. This is not a universal
solution or capacity guarantee. G2 now implements the matched PCM/GPCM MML
LRT through `compare_mfrm(..., nested = TRUE)` and the corresponding optional
weighting-review argument. It verifies the shared population design, facet/step
constraints and interactions, and G-1 free relative-slope restrictions; numerical
solution checks remain independent of slope-interval availability. The test is
asymptotic, retains explicit failure reasons and does not choose a scoring policy.
Its targeted null validation and limits are recorded under
`validation-results/gpcm-lrt-20260924/`; this is not a general finite-sample
size guarantee. G3 now provides `confint(fit, parm = "slopes", level = 0.95)`
and the same calculation through diagnostics. Joint information includes
population-parameter estimation, and the log-slope transformation preserves the
geometric-mean-one constraint. Stored flags alone cannot authorize intervals.
Summaries, attached diagnostics, weighting tables and interval guides retain
the separate decision; Wright/Pathway locations and plug-in information curves
do not acquire slope-uncertainty bands.

The targeted G3 check reused all 400 G2 null fits and added 400 unequal-slope
fits (two owners, two designs, 100 replicates per cell). All crossed-N100 fits
returned intervals, with level-specific coverage of 92--98%. For N40 with two
of three raters per Person, unit-slope coverage was 95--97% with full
availability. Unequal-slope availability was 96--97%, and coverage among
available intervals was 90.6--97.9%; coverage-and-return over all planned
replicates reached as low as 87%. Four regularized-information cases and three
category-support cases stayed unavailable. Very wide intervals and undercoverage
in some small-sample cells remain explicit limitations. These are model-based
pointwise approximations, not standardized-slope, simultaneous or robust bounds.
See `validation-results/gpcm-slope-intervals-20260924/` for the plan, saved
results, per-level Monte Carlo intervals, width summaries and API checks.

G1--G3 implementation and targeted local validation were completed for these
stated outputs. That earlier source completed M5 local integration, with
the full-run findings repaired and a frozen successor archive checked. The
integration record distinguishes the initial full run from focused repairs
and content-identical reuse. Earlier Win-builder results cannot validate this
archive; current-source CI and rc.6 publication are verified separately under M6.

Portable GPCM calibration is a separate lifecycle extension: it must retain
slopes, steps, population/scoring reference, anchors and versioned identity.
Fitted-object GPCM scoring does not already provide that artifact. Conversely,
portable scoring, Bayesian estimation, FACETS output equivalence and a theorem
covering every global likelihood path are not all mandatory prerequisites for
qualifying one clearly stated MML inference target. The required evidence must
match the claim; numerical convergence alone remains insufficient.

There is no defensible calendar date for removing all restrictions together.
The sequence is concrete: reconcile terminology and complete the existing-model
inference scope before submitting 0.2.4; then assess slope action and slope/step
ownership as distinct structural questions, as specified below. Release each
qualified capability when its own conditions are met, without waiting for
multidimensional MFRM or calling the result unrestricted. If an inference
investigation fails, retain its limitation explicitly rather than leaving a
whole model indefinitely described only as "bounded".

### ConQuest/TAM model and inference decisions

Use the [GPCM guide](vignettes/mfrmr-gpcm-scope.Rmd#what-can-and-cannot-be-compared-across-programs)
to distinguish a coordinate change from a model change. TAM's documented
Example 14c combines a many-facet intercept design with estimated slopes;
ConQuest supplies generalized-item scores and a scoring design. Neither is
automatically the current mfrmr model, where one facet's slope multiplies
the complete adjacent-category predictor. The programs also support broader
latent-variable designs; their availability is not evidence that mfrmr
already implements those structures or needs them all for 0.2.4.

| Work | Decision and completion evidence | Release relationship |
| --- | --- | --- |
| Current-model explanation | State the slope action, shared slope/step facet, population identification and each inference target. Include the TAM many-facet route and ConQuest scoring design, with exact versus different-model comparisons distinguished. | Required 0.2.4 documentation; reconciled locally. Does not add an estimator. |
| Standardized-slope uncertainty | Implemented locally by `confint(scale = "standardized")`, with the full scale Jacobian, cross-covariances and an explicit target. Independent derivative/algebra checks and reuse of saved normal-population fits examine numerical and sampling behavior. | Cross-software joint-interval equivalence and broader distribution/design performance remain unqualified. Marginal external SEs cannot substitute for missing cross-covariances. |
| Slope action | Decide whether users need slopes on ability with additive rater effects, alongside the current slope on the complete predictor. Require an explicit formula, identification, unit-slope reduction, probability/derivative checks and design-specific performance evidence. | Separate structural extension. Preserve the current default and saved-model meaning; changing only argument names cannot implement it. |
| Slope/step ownership | Independently assess criterion steps with rater slopes, separate slope groups or multiple slope blocks. Define the constraints and free dimensions for each admitted design. | Separate from slope action and from multidimensionality. Do not implement several unresolved structures together. |
| Comparison and interoperability | For numerical replication, align observations, categories, normal population model, constraints and numerical accuracy. Retain source versions and parameter ordering. Different models may be compared by IC on compatible likelihoods, using each model's free dimensions; establish nesting separately before an LRT. | Reuse existing TAM 4.3-25 and ConQuest 5.47.5 evidence within its scope. A new covariance adapter requires its own evidence; general parity is not a release gate. |

For slope-action work, prioritize whether a user needs the rater-severity
contrast to have the same log-odds effect across criteria. Existing algebra and
sampling records already show that the two formulations can differ and that a
connected acyclic rater-by-criterion design may not distinguish them. Reuse
that evidence; validate only new estimator or inference claims. Future
acceptance must cover score calculation, information, residual diagnostics,
bias analysis and saved-result compatibility for the new formula, rather than
assuming existing downstream methods transfer unchanged.

## Response time and decision processes

These remain later research directions. A response-time model needs a defined
event and actor, appropriate time units, missing/censored-time treatment and
an identified relation to the measurement target. Response production time
must not be duplicated because several raters score the same response; rater
scoring time is a separate observation.

A diffusion model requires suitable choice-and-time data and its own likelihood.
Polytomous ratings or essay completion times alone do not supply that model.
A concrete assessment need and data take precedence over adding these names
to the API.

## External comparison

Use a comparator to answer a specific formula, convention or interoperability
question. Match model, parameterization, estimator, scale and uncertainty
meaning first; numerical agreement is supporting evidence within that scope.
It does not establish statistical validity or a promise of feature parity.

The mirt, TAM and eRm adapters preserve supported source scales and conventions.
TAM multi-facet displays do not reconstruct separate facet coordinates, and
marginal SEs cannot reconstruct a missing joint covariance. Imported objects
are not native fits or portable calibrations. Preserve these distinctions in
any future adapter extension.

## Version direction

| Horizon | Outcome | Release boundary |
| --- | --- | --- |
| 0.2.4 | Finish the pre-submission API/GPCM review, publish and maintain the retained assessment workflows. | rc.6 candidate publication is verified: the successor completes M5, is in `main`, passes five-platform CI and has matching help/tutorials and downloaded release assets. Approximate-output limits remain explicit. Final release/submission decisions remain separate; earlier Win-builder results belong to their uploaded snapshots. CRAN acceptance is not implied. |
| Maintenance releases, if needed | Correct reproducible calculation, interpretation, installation or compatibility defects. | Preserve supported behavior where possible; identify affected versions, explain any changed result and provide recovery or migration instructions. Research extensions do not delay necessary repairs. |
| Next feature release, provisionally 0.2.5 | Improve rater feedback where qualified and address actual post-release API experience. | Build on the interface and GPCM scope decisions completed before 0.2.4 submission. Keep compatible transitions; admit additional inference or model scope only with its own evidence. |
| Subsequent feature releases | Extend assessment planning and the retained models for concrete decisions. | Assess the GPCM slope action and slope/step ownership separately, using the ConQuest/TAM model decisions above. Neither waits for multidimensional MFRM or full software parity. Each admitted extension has its own release scope; not every candidate belongs in 0.2.5. |
| A future stable API release | Make the supported interfaces, saved objects and migration policy predictable over time. | Stability depends on user experience, reproducible evidence and maintenance capacity; it does not require every model on the research list. Neither 0.3.0 nor 1.0 is a promise of universal statistical validity. |

## Post-release priorities

The principal user outcome is feedback that helps a rater or assessment team
decide what to review, what additional ratings to collect and what the analysis
cannot establish. Educational performance assessment remains the main example.
Music, clinical assessment and judged sport inform the role and design checks;
renaming columns is not validation in another application area.

The API and current-GPCM decision rows below are carried forward as maintenance
responsibilities after their pre-submission completion, not postponed from 0.2.4.
The order reflects current evidence and the user's emphasis on rater
feedback. It can change when an actual defect, assessment need or result changes
the case for a task. The completed PCA/k-means, assigned-score MI, multivariate
G/D-study and two RSM extensions are the starting point, not new features to
implement again.

| Priority | User outcome | Next bounded work | Condition for completion or moving on |
| --- | --- | --- | --- |
| Continuous maintenance and adoption | A new user can choose an analysis, understand a limitation and reproduce a saved report. | Address demonstrated failures in setup, defaults, messages, examples, accessibility and saved-result reuse. Walk through an educational assessment from raw ratings to feedback, with a graduate-student reader when available. | The reproduced problem is fixed and its affected paths are checked. A usability claim requires actual reader evidence; an author walkthrough alone is not a user study. |
| Interface integration and maintenance | Users can find the right operation and predict what its arguments, defaults and result mean. | Finish the work package below before submission across the principal estimation, scoring, diagnostics, G/D planning, features and imputation routes; subsequently use actual feedback to refine it. | One recommended entry per distinct task, clear argument decisions, matching help/examples/results and tested compatibility. This is a 0.2.4 pre-submission requirement. |
| GPCM decision before further structural expansion | Users know which model is fitted and why a particular estimate, interval or comparison is available. | Separate the existing model's inference requirements from additional slope structures and optional workflows. Use the locally completed G1--G3 inference work before extending the kernel. | Maintain the separate MML eligibility rules, publish the small-sample limitations, and preserve the final integrated package-check evidence. Renaming the model alone does not close a statistical limitation. |
| First statistical focus: rater uncertainty | Show how uncertain an observed rater's severity is when calibration was estimated from finite data. | Assess the existing shared-rater interval candidates against the documented normal approximation, using the existing RSM and matched ordinary-MFRM feedback as context. | Declare the repeated-sampling target and qualify coverage, availability and usefulness together. If evidence is inadequate, keep the explicit limitations and conclude the investigation rather than automatically adding another model or simulation grid. |
| Next planning focus: feasible assessment designs | Compare whether additional tasks, raters or criteria are worth their workload for the intended decision. | First use existing G/D scenarios with explicitly supplied costs and constraints; identify the first planning question they cannot answer. The leading statistical extension is uncertainty for a prespecified comparison of two supported nested plans. | Show a usable plan comparison, with cost units, assumptions and uncertainty where qualified. A new nested interval method needs its own covariance and performance evidence; a cost table does not implement unequal future allocations. |
| Later uncertainty targets | Compare Persons or raters while carrying the relevant shared calibration uncertainty. | Choose one prespecified contrast and its observed/new-entity target. Assess few-cluster or multiway methods only for a specified sampling/dependence structure. | Preserve covariance, anchoring and any estimated linking; compare with the current conditional or working-model result. Support remains limited to the examined model and design. |
| Selected model/design extensions | Answer a demonstrated assessment question that the supported workflows cannot answer. | Consider the candidates below after defining the decision, data and simpler alternatives. | New likelihoods or covariance structures require identification, independent numerical checks, statistical evidence, usable output and an affordable maintenance path. |

### First integration work package: API names, arguments and help

This work package is now assigned to 0.2.4 before CRAN submission. Its earlier
allocation to the next feature release is superseded. It prioritizes existing
workflow meaning and compatibility; it does not require renaming every export.

Readable help is part of API design. The fitting entry currently combines data
roles, score coding, model assumptions and numerical settings in more than forty arguments.
A glossary added after that interface does not by itself make those choices
understandable. The first redesign covers the path from a user's question to
the appropriate function, its defaults, its result and the next interpretation.

| Current source of confusion | Required design decision |
| --- | --- |
| `mfrm_cluster()` specifically uses Gower/PAM, while `mfrm_cluster_kmeans()` names its algorithm. | Implemented locally: `mfrm_cluster_pam()` is the recommended entry, with `mfrm_cluster()` retained as an identical alias. New and old calls preserve partitions, result classes and saved-result methods. |
| `mfrm_response_imputations()` reviews supplied completions; it does not generate imputations. | Implemented locally: `review_mfrm_imputations(..., impute_ids = ...)` names the operation and event-ID selection. The old wrapper preserves its argument order and output class; fitting and pooling use the same reviewed completions. |
| `predict()` returns category probabilities for shared-rater models but Person scores for testlet models. | Separate ability scoring from response prediction in the recommended routes. Explain the supported fitted/new-Person roster for each. Existing `predict()` calls must not silently start returning a different quantity. |
| `keep_original` can change which category steps are fitted. | Implemented locally in fitting, data review and anchor review: `category_policy = "preserve"`/`"collapse"`. The old boolean and default are retained, explicit conflicts fail, and replay retains the existing representation. Data-review and fit summaries now show the policy separately from actual score recoding; unknown legacy metadata is not inferred. No new category information or default change is implied. |
| `level`, `ci_level`, `conf_level` and `interval_level` appear in related interfaces. | Retain current spellings in 0.2.4 rather than add duplicate arguments solely for appearance. The help must identify parameter intervals, latent-effect intervals and conditional Person scoring. Standard R generics retain their conventions; any later consolidation needs a specific usability benefit. |
| `newdata`/`new_data`, `missing = "fail"`/`"error"`, and category declarations differ between workflows. | Retain existing spellings and choices for 0.2.4. Document what is omitted, how the analysis sample changes and whether the complete shared-effect roster is needed. These interfaces do not all have the same target; do not silently treat an observation-row filter as output-only Person selection. |
| `person_sd = NULL` estimates a variance in extensions, while a numeric value fixes it; ordinary-model population defaults differ. | Explain estimate versus fix explicitly, distinguish these inputs from starting values, and put population assumptions in the first-use comparison. Do not equalize them through an undocumented default change. |
| Guide, table, report, review and export functions compete for the same first screen. | The beginner route remains compact. `mfrmr_output_guide("feedback")` now connects rater-feedback questions to model-specific intervals, residual review and known-truth accuracy, with matching saved-output routes. Preserve R's `summary()`, `plot()` and `confint()` conventions rather than renaming their standard `x`/`object` arguments for cosmetic consistency. |

Help pages will start with the question answered, the required input and a small
interpreted result. Explain essential arguments first, then statistical choices,
then computation and display options. For each consequential default, show what
omission or `NULL` means, a valid example, and what changes in the analysis.
Long-form ratings, column names, actual values and fitted objects must be
distinguished explicitly. Technical derivations remain available after that
introduction. Document the matching model restrictions on the same page.

The same vocabulary must appear in installed help, the website, examples,
warnings and returned tables. Where two functions share semantics, maintain one
source for that explanation; do not copy a paragraph across statistically
different arguments just because their names match. Organize the documentation
around rating review, model fitting, ability scoring, response prediction,
rater feedback, planning, features, missing scores and reporting. Observed-score
G-theory and external-feature clustering do not require a fitted MFRM.

Completion requires executable old/new-call comparisons for adopted renames,
explicit errors for conflicting old/new arguments, preserved saved-object and
S3 behavior, and a migration table naming the canonical route. Deprecations
need an announced transition across a subsequent feature release where safe;
the 0.2.4 interface is not broken simply to make spelling uniform. A long
argument list is not solved by hiding everything in `...` or an undocumented
control list, and a second universal wrapper is not a substitute for clearer
existing entries. Reuse current tutorials and improve them around actual
reader failures rather than adding a parallel set of guides.

### First statistical work package: uncertainty in rater feedback

The first target is an interval for an **observed rater's latent severity**,
relative to the modeled rater population mean, in the existing shared-rater RSM.
It is not an interval for a future rater, a
Person ability or a change caused by training. The current bootstrap API
targets model-based prediction error across generated Person and rater effects,
conditional on the supplied rating arrangement. Average performance over those
effects does not guarantee coverage for each fixed true rater severity.
Selecting that target explicitly is the first decision; it must not be changed
after inspecting results to obtain a more favorable conclusion.

The 800-dataset comparison already shows that automatic normal bounds did not
meet the combined coverage and availability criterion. Those results and the
existing bootstrap implementation are reusable evidence and code, not a
qualified replacement interval. Before further computation, separate remaining
errors in numerical approximation from the uncertainty method's statistical
performance, and establish which saved fits and draws remain applicable.
An earlier 24-dataset bootstrap pilot also remains limited: its outer sample
and 99 draws per fit were too small for a precise coverage decision, and its
original population specification must be respected when reusing the results.
It is evidence to plan from, not a reason to repeat the same small pilot.

Evaluation must retain failed fits and unavailable or unbounded intervals.
Report coverage among all returned intervals and among finite intervals
separately, together with finite/unbounded/unavailable proportions, widths and
the proportion of all planned cases producing a finite interval that covers
the target. An unbounded interval is not a successful finite result. Examine
shrinkage and sparse or weakly linked designs rather
than relying only on a favorable pooled average. A comparison with ordinary
MFRM uses the same observations and an explicit scale and target; the two
models' rater uncertainty measures are not interchangeable by name.

Choose the comparison methods, practically acceptable performance and Monte
Carlo precision before generating new results. Start from the smallest study
that can resolve the specific remaining decision. Replications of a coverage
study and draws within a bootstrap have different roles and both need adequate
precision. A more complicated interval is useful only if its gain justifies
its computation and interpretation. Reporting, figures, help and saved replay
must preserve the chosen target and failed results.

Rater contrasts, extended-model bias tests, simultaneous screening decisions and
Person intervals are separate targets. They do not become qualified because an
individual-rater interval passes. There is no commitment to a general coverage
or diagnostic-accuracy guarantee across all designs and missingness mechanisms.

### How subsequent candidates will be selected

| Candidate | Concrete reason to reopen it | Required boundary |
| --- | --- | --- |
| Nested, fixed-facet or sparse-future G-theory | A named assessment cannot express its task/rater sampling or feasible future plan using the current crossed/nested workflows. | Begin with one structure and intended score/composite. Distinguish fixed tasks represented as score components from a general fixed-facet solver; distinguish incomplete source data from an unequal future allocation. Do not implement all structures under a single claim of general G-theory. |
| Testlet planning or task-specific dependence | Decisions about adding tasks versus rubric criteria, or revising a particular task, require quantities the common local variance cannot supply. | Compare the current common-variance model and ordinary RSM first. Specify true membership and enough repeated information before a heterogeneous-variance extension. Local dependence alone does not diagnose halo, and modeling it does not impose equal task weights. |
| PCM extensions or joint shared-rater/testlet effects | A real rubric needs different category structures, or both shared-rater and Person-local dependence materially change the same decision. | Add one structure at a time, with the existing RSM and zero-effect reductions. Establish what typical sparse data can identify; an external model may be the better route. |
| Missing-response sensitivity | Selective missing assigned ratings could change the reported rater or planning conclusion. | Preserve observed scores and the assignment roster. A sensitivity model states how its assumptions differ; it does not identify MNAR from the observed data or fill unassigned cells. Extended-model MI and pooled Person scores need separate justification. |
| Calibrated screening or bias analysis | A specified review action needs known false-flag and detection behavior, beyond the current descriptive fit/threshold displays. | Define the affected rater/group and error criterion, preserve failed/unavailable cases and examine relevant null and non-null designs. Checking many raters or choosing thresholds after looking at results requires its own treatment. Existing Infit/Outfit bands are not universal tests or evidence that training will help. |
| Feature stability or new-entity assignment | Users need reproducible group descriptions under sampling variation, or must assign new raters/tasks using an existing feature analysis. | Keep imputation sensitivity distinct from sampling stability. New-entity use must retain the fitted feature coding, scaling, PCA and assignment rule, and assess prediction separately from in-sample clustering. Do not infer rater quality from an external-feature group. |
| Larger workloads | An actual target workload exceeds demonstrated time or memory, or a dependency change causes regression. | Vary Persons, facet levels and response-pattern length separately; measure memory, time, numerical agreement and unavailable results. Report a tested configuration, not a universal capacity limit. Optimize only an identified bottleneck while preserving the statistical target. |
| Multiple scales and multidimensional MFRM | A substantive decision needs separate scales or distinct traits that a one-scale analysis cannot represent. | Multiple observed scales and latent dimensions are different proposals. Multidimensional MFRM remains deferred pending construct definitions, loading and covariance identification, useful subscores and a tractable computation plan. It is not a prerequisite for the next release. |

These candidates are not a hidden checklist for the next version. Threshold
selection, new model families and more plots are not progress unless they improve
a named user outcome. GRM, explanatory item models, response-time/process models,
mixtures and new backends retain their separate entry conditions. Existing
GPCM, JML and portable-calibration defects still receive maintenance priority;
their broader inference or model scope does not expand automatically.

## Milestones after 0.2.4

These milestones apply to a selected work package. Maintenance can proceed
alongside it; a blocked research result must not hold necessary fixes hostage.
Help, examples and output design develop alongside the method; milestone 4 is
their final integration review, not a reason to postpone them until computation
is finished.

| Milestone | Reviewable outcome | Decision |
| --- | --- | --- |
| 1. Define the decision | One user question, target quantity, representative rating design, current workaround and declared exclusions. | Confirm that the proposed work changes a useful decision; otherwise retain the existing workflow or use an external tool. |
| 2. Establish the method or interface | For a statistical change: literature-to-equation correspondence, independent small-case calculations, identification and numerical checks, with reusable evidence. For API integration: explicit operation/input/output semantics, defaults and a compatibility/migration design. | Fix the relevant acceptance criteria before implementation or a new confirmation study. Stop or narrow the proposal if these cannot be supported; a spelling change does not require a new statistical experiment. |
| 3. Evaluate the claim | A statistical comparison reports uncertainty, failures, adverse conditions, time and memory as relevant. An interface change checks equivalent old/new calls, consequential defaults/NULLs, conflicting arguments and saved-object behavior. | Adopt only the demonstrated scope, repair a specific defect, or conclude that the proposal is not supported. Distinguish source/author checks from evidence that new readers understand the workflow. |
| 4. Complete the user workflow | Input review through summaries, meaningful accessible plots, saved results, migration and an executable question-to-answer tutorial. | Check beginner interpretation, defaults, missing results and consistency with existing APIs. Avoid a new wrapper where current functions already answer the question. |
| 5. Release and review | A defined feature set, affected regression checks, candidate/platform checks, compatible documentation and verified publication. | Release only the admitted work; explain unresolved limits and use actual feedback to choose the next package of work. Research failure does not create a reason to release an empty feature version. |

Review priorities at each completed or rejected work package and before the next
release scope is fixed. Revisit the user need if a study grows mainly to explain
its previous study, if maintenance cost exceeds the likely benefit, or if a
simpler existing workflow gives the same actionable answer. Reuse applicable
evidence and run new checks only for changed behavior, a failure or an explicit
new claim. API compatibility and dependable maintenance can justify a later
stable release without completing this entire research list.

## Compatibility principles

- Preserve model, scale, categories, anchors, score/composite identity and
  uncertainty meaning across saved results, tables, figures and exports.
- Explain incompatible inputs and saved-object migration in user-facing terms;
  internal study identifiers and execution records belong in maintainer material.
- Keep examples executable, plots in English, and missing results visible.
  An unavailable estimate must not become zero or a successful check.
- Add work when it can change a stated user outcome. Reuse applicable evidence;
  repeat or broaden checks for changed behavior, a failure or a justified
  release integration need. Test counts and documentation volume are not
  completion criteria.
