# mfrmr roadmap

Status: public roadmap, updated 2026-09-24. This document sets priorities and
completion conditions; it does not promise release dates or unimplemented APIs.
See [NEWS](NEWS.md) for changes and the [README](README.md) for use and examples.

## Current releases

mfrmr 0.2.4 is a release candidate. It has not been released on CRAN;
the final release decision is separate from integrating the source. The expanded
candidate includes numeric-feature analysis, assigned-score imputation,
fixed-facet intervals, screening evaluation, and shared random-rater and
Person-specific testlet workflows alongside the existing calibration and
G/D-study functions. Its implementation and help have passed
[five-environment package checks](https://github.com/Ryuya-dot-com/mfrmr/actions/runs/35948657009).

The next fixed snapshot is `v0.2.4-rc.4`. Publication checks still need to confirm
its main-branch integration, downloadable archive and matching website.
Earlier candidates remain available as unchanged evaluation snapshots. Use the
source tag or commit and matching installed help to identify functionality:
earlier candidates also report package version `0.2.4`.

This candidate includes clearer help on function names, defaults and choosing
an analysis. Seven extended-model examples use saved synthetic results so users
can inspect summaries and figures quickly; complete recalculation instructions
remain available. Examples, tutorials and the manual have been checked, and
problems found during those checks have been corrected. Cross-platform package
checks do not establish statistical performance beyond the stated scope or
constitute CRAN acceptance.

| Workflow | Current position | Role in the planned 0.2.4 |
| --- | --- | --- |
| Portable calibration and new-Person scoring | Implemented for the stated fixed-normal RSM/PCM MML scope. | Preserve the supported workflow and corrections during integration. |
| External-feature clustering and imputation sensitivity | Included in the candidate, including hierarchical trees, plots and setting comparisons. | Preserve descriptive interpretation and paired imputation comparisons. |
| Multivariate observed-score G/D studies | Crossed/nested point projections and explicit normal-theory intervals for prespecified two-crossed-facet plan differences are included. | Preserve the supported designs, uncertainty assumptions and metric-specific availability. |
| Structural/model extensions | Person-by-(Child-within-Parent) multivariate G/D-study point estimates are included in the baseline. Shared-rater and testlet RSMs are included for their bounded conditional/descriptive scope; broader inference remains unqualified. | Retain the G/D-study and two RSM workflows specified below; publication verification follows the completed package checks. |

## Purpose and priorities

mfrmr helps users calibrate ratings, compare Persons and facets on an explicit
measurement scale, reuse a calibration, and plan assessments with a clear
account of what the results support. The development order is:

1. Finish the implemented development workflows: APIs, examples, tables,
   plots, exports, saved results and failure behavior.
2. Qualify statistical support for the retained uncertainty, imputation and
   rater-feedback targets, reusing the completed G/D-study evidence.
3. Extend the models for specified assessment designs and analysis targets.
4. Integrate the completed work from stages 1–3, together with the existing
   calibration workflow and corrections, into mfrmr 0.2.4.

Integration and the release decision follow these stages. A reproduced
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

The following is the retained final scope. These public workflows have completed
local integration and cross-platform package checks; publication verification remains.
Completion of the previously published candidate alone did not establish this
expanded scope.

| Included in 0.2.4 | Outcome required before release | Explicit boundary |
| --- | --- | --- |
| Existing MFRM and portable calibration | Preserve supported RSM/PCM, bounded GPCM/JML, anchors, linking, diagnostics, new-Person scoring and corrected saved analyses. | Existing model-specific restrictions remain; new engines or unrestricted inference are not implied. |
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
implemented, and cross-workflow local integration is complete. The extension does
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

| Milestone | Completion condition | Current position |
| --- | --- | --- |
| M0 — Release scope | Inclusion, exclusions, outstanding decisions and the local/public completion boundary agree across this roadmap and the maintained evidence inventory. | Defined by this revision; it does not certify the included methods. |
| M1 — Existing workflows | Numeric/external features, assigned-score MI, existing feedback and G/D planning run from input review to saved output. The MI example and fixed-task planning example have explicit statistical targets. | Fixed-task planning and the joint-RSM MI/sensitivity tutorial execute locally. Ordinary screening now has directional threshold sensitivity, a corrected mean-square-only default and a bounded stress audit; adverse false-flag/detection results remain explicit. The MI example now matches the response likelihood and preserves calibration/shared-Person uncertainty; the paired 200-dataset MAR/MNAR comparison is complete, with bounded MAR support and severe MNAR bias/undercoverage. Local workflow integration is complete within these limits. |
| M2 — Statistical and model decisions | Complete literature-to-equation-to-code correspondence; resolve ability-population constraints, effect sharing, interval targets, comparison likelihoods and diagnostic probabilities. Fix the remaining validation conditions, practical tolerances and Monte Carlo precision before new outcomes. | Ability-variance extension, matched-data comparison and descriptive probability targets are specified. The fixed-facet working-model target is reconciled. A prespecified 800-dataset shared-rater comparison is complete; automatic individual-rater intervals are withdrawn, with explicit approximation access retained. All 53 saved Person-integration failures pass higher-order refits after independent numerical review; the original study decisions remain unchanged. A 480-dataset estimated-population testlet comparison is also complete. Fourteen numerical start-selection failures are repaired; post-repair bounded coverage evidence holds in the two larger balanced conditions, while small/sparse conditions and regular calibration-interval qualification remain inconclusive. Point-score accuracy does not uniformly improve. The paired MI comparison is complete: the declared MAR design meets its bounded criteria, while MNAR coverage falls to 26.0%. A twelve-roster independent posterior comparison now supports the tested 48 conditional Person scores, including endpoint checks using saved joint rater draws. An eight-roster comparison now supports local calibration-likelihood changes at 128 distinct parameter points under the stated numerical tolerance. The retained interval decision is implemented: points/approximate SEs by default, explicit normal calibration bounds, and a separate explicitly requested approximate rater-SD profile. No new variance interval or coverage guarantee is admitted. |
| M3 — Qualified model workflows | Both extensions have matching scoring, comparisons to ordinary MFRM, declared uncertainty and descriptive diagnostics/figures. Independent numerical checks and bounded statistical comparisons support the retained outputs; adverse and unavailable results remain visible. | Completed locally within the stated scope; matched-event centered facet comparisons now connect both extensions to ordinary RSMs, plots and saved reports. Posterior predictive probabilities, full variances and descriptive residual summaries now share a definition with ordinary RSM MML, including matched-event paired/difference comparisons and saved reporting. Source-roster conditional Person comparisons and model-aware Wright/fit-pathway displays are now implemented locally, with matching saved reports. Estimated-population testlet scoring now has a complete bounded comparison and a verified numerical-selection repair, with explicit small-sample/sparse coverage and point-accuracy limitations. A bounded independent posterior comparison now supports all 48 selected shared-rater EAPs/SDs and 96 endpoints at the stated numerical tolerances. A separate eight-roster comparison also supports local calibration-likelihood changes under the stated tolerance. Neither numerical comparison establishes interval coverage or a full SD-profile qualification. The regular/profile output decision and final cross-workflow source/help/output reconciliation are complete locally. |
| M4 — User and maintenance integration | Representative assessment examples, all changed help/NEWS, output compatibility, failure behavior, dependencies and measured resource use agree with the admitted scope. Saved results reproduce the displayed values in a fresh session. | Completed locally; extended-model estimates have interval, precision and cumulative-distribution views. A cross-workflow saved-output pass now covers numeric features/groups, assigned-score MI, complete/incomplete G/D planning, fixed-facet intervals, screening and both extensions. Generic conversion no longer discards dedicated axes or interval semantics; public output routes and PCA colour/shape distinctions are reconciled. The installed package now passes API/help identity checks, representative help examples, ordinary/portable baseline checks and fresh-process saved-result replay. Optional-dependency refusals and reuse paths are checked with simulated namespace absence. Two malformed MI help pages and misleading installation guidance for unsupported plots are corrected. Fifteen executed tutorials, 43 figures with alternative text, repaired namespace imports and final archive/API/help/replay checks now complete this local integration. |
| M5 — Local completion | One frozen source, installable source archive and local documentation pass the applicable integrated package checks. Every included outcome has evidence and no unresolved defect invalidates a supported result. Remaining research is explicitly outside the agreed release scope. | Completed locally for the stated scope. Updated help, examples, tutorials and the manual accompany the installable package. Problems found in packaging, test guidance and article rebuilding are corrected and checked; unchanged calculations retain their earlier validation. Five-environment package checks also pass; CRAN submission checks remain separate. |
| M6 — Public release | The same source passes five-environment CI, is integrated into main, and has matching release assets, version/status metadata, installed help and published site. Publication is verified, not inferred from a successful upload. | Five-environment checks pass for the expanded implementation and help. Main integration, release-download and website verification remain; previous candidate publication does not satisfy them. |

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

## Current local implementation and remaining evidence

The table below records current capability and statistical limits. The release
scope and milestones above set the completion conditions. Local integration is
complete; earlier evidence is reused only for unchanged source and matching
scope. Public release remains pending.

| Workstream | Current status and completion condition |
| --- | --- |
| Numeric k-means/PCA | Implemented and checked locally with explicit geometry, component selection, paired feature imputations, plots, comparisons and executed help examples. Not yet published; group validity and inferential guarantees are not established. |
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
restrictions and unavailable rows remain. The remaining M3/M4 work is final
cross-workflow source, output, help and evidence reconciliation. The interactive viewer and broader inferential
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
| GPCM | A selected facet owns slopes and steps. Free-slope uncertainty, automatic information-criterion ranking and the PCM-versus-GPCM chi-square LRT remain unavailable. Portable GPCM requires a separate model-extension decision. |
| JML | Uncorrected estimates retain infinite extreme Persons; optional display replacements do not change primary estimates. SEs and normal bands remain exploratory. A correction or portable JML needs a separate method decision. |
| Estimated populations and Fair Scores | Existing conditional/diagnostic output retains its limits. New population intervals, omnibus DRF inference or inferential FairZ methods require their own target and evidence. Inclusion requires a specific stage-2/3 scope decision; the new release order does not itself qualify them. |
| Multiple observed scales | Require explicit scale identifiers and a concrete separate-scale use case. Do not silently pool or link scales. Inclusion requires a specified model-extension scope. |

See [model and interpretation boundaries](README.md#model-and-interpretation-boundaries)
for the current output rules. Fixing a numerical or reporting defect does not
by itself qualify a new inferential claim.

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

| Horizon | Outcome | Evidence needed to begin or finish |
| --- | --- | --- |
| 0.2.4 local candidate | Complete the included assessment workflows through M5. | All mandatory rows have source-specific evidence; no workflow is replaced by a promise or a research-only calculation. |
| 0.2.4 public release | Complete M6 for that source; handle CRAN submission and review separately. | Matching platform checks, main source, archive, version status and help/site identity. |
| Maintenance after release | Correct reproducible defects, preserve saved-object compatibility, and assess reported workloads and dependency changes. | A user-visible failure or identified compatibility risk justifies focused reproduction; passing unchanged numerical studies are reused. |
| Further statistical support | Calibration-aware Person/contrast intervals, few-cluster or multiway methods, extended-model DRF and calibrated decision rules. | A named estimand and action, adequate design information, independent calculation and prespecified error/coverage evaluation. A method is not added merely to make every class expose the same columns. |
| Further model/design coverage | Selected additional G-theory structures, heterogeneous or joint random effects, and eventually substantive multidimensional MFRM. | A use case the supported workflows cannot answer, literature and identification, comparison with existing software, measurable benefit and an affordable maintenance path. Multidimensional decisions remain deferred. |

Later work has no automatic version assignment. Revisit it using actual
assessment needs and release feedback, selecting one justified extension at a
time. A fixed collection of tasks represented by score components does not
complete general G-theory, and local testlet dimensions do not complete
substantive multidimensional measurement. Response-time and process models
retain the separate admission conditions above.

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
