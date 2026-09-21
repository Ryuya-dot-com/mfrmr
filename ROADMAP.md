# mfrmr roadmap

Status: public roadmap, updated 2026-09-21. This document sets priorities and
completion conditions; it does not promise release dates or unimplemented APIs.
See [NEWS](NEWS.md) for changes and the [README](README.md) for use and examples.

## Current releases

mfrmr 0.2.4 is a release candidate and has not been released on CRAN. It
integrates the selected work from stages 1–3 below. GitHub pre-releases are
available for evaluation; their release pages link to the applicable CI results.
The final release decision remains pending.
Use `packageVersion("mfrmr")` and installed help to identify available functionality.

| Workflow | Current position | Role in the planned 0.2.4 |
| --- | --- | --- |
| Portable calibration and new-Person scoring | Implemented for the stated fixed-normal RSM/PCM MML scope. | Preserve the supported workflow and corrections during integration. |
| External-feature clustering and imputation sensitivity | Included in the candidate, including hierarchical trees, plots and setting comparisons. | Preserve descriptive interpretation and paired imputation comparisons. |
| Multivariate observed-score G/D studies | Crossed/nested point projections and explicit normal-theory intervals for prespecified two-crossed-facet plan differences are included. | Preserve the supported designs, uncertainty assumptions and metric-specific availability. |
| Structural/model extensions | Person-by-(Child-within-Parent) multivariate G/D-study point estimates are implemented, including identifiable incomplete or unequal source designs. | Integrate this selected stage-3 scope; other nesting structures and random-facet MFRM remain separate extensions. |

## Purpose and priorities

mfrmr helps users calibrate ratings, compare Persons and facets on an explicit
measurement scale, reuse a calibration, and plan assessments with a clear
account of what the results support. The development order is:

1. Finish the implemented development workflows: APIs, examples, tables,
   plots, exports, saved results and failure behavior.
2. Extend statistical support, beginning with uncertainty in multivariate
   G/D-study planning comparisons.
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

The release combines finished exploratory-feature and multivariate G/D-study
workflows, statistical support and selected model extensions with portable
calibration. Current functionality and planned additions remain distinct until
implementation and validation are complete.

| Stage | Deliverable | Completion condition before integration |
| --- | --- | --- |
| 1. Finish implemented functions | Consistent clustering/MI comparisons and G/D-study APIs, beginner examples, plots, exports and saved-result behavior. | Supported data-to-result workflows execute; units, identities, exclusions and metric-specific availability are consistent. Remaining defects are corrected with focused checks. |
| 2. Extend statistical support | A justified uncertainty method for prespecified G/Phi/SEM planning comparisons, preserving dependence between plans and composites. | Implemented output matches a declared sampling target; boundary/failure handling and coverage or decision error are evaluated under explicit conditions. An uncertainty statement alone does not complete this stage. |
| 3. Extend models | Person-by-(Child-within-Parent) G/D-study point estimates, such as task-specific rater teams, with fitting, projections and user guidance. | The selected design has identifiable components, working raw-data estimation and D-study rules, independent calculation checks and an executable assessment example. Nested intervals, other nesting structures and other model families remain separate extensions. |
| 4. Integrate as 0.2.4 — local verification complete | The selected work now forms one candidate with consistent APIs, documentation, migration guidance and a distributable archive. | Make the release decision on this source, preserving supported scope and the distinction between local verification and publication. |

Selected methods must meet their stated statistical requirements before
inclusion; changes to the planned scope will be reflected here. Model extensions
will target specified assessment designs, rather than every G-theory or MFRM
model family in one version. Compatibility is maintained throughout development;
stage 4 verifies how the completed features work together.

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

## Generalizability theory

The planning question is how tasks, raters or score weights affect the
dependability of a score used for ranking or for absolute decisions. For
component and composite scores, between-score covariances matter; averaging
separate reliability coefficients does not answer the composite question.

The development functions `mfrm_multivariate_gstudy()` and
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

The next work is organized around decisions, rather than more reference-software
comparisons:

| User question | Next deliverable | Evidence needed to consider it complete |
| --- | --- | --- |
| Can I use the current point projections correctly? | Consolidate the existing data → G-study → scenario/composite → table/plot workflow and saved-result behavior. | Examples use supported designs; metric-specific omissions, score units and limitations survive printing, export and replay. No new estimator is required for this step. |
| How uncertain is the improvement between two feasible plans? | Specify and evaluate joint uncertainty in G/Phi/SEM differences using the same estimated components. | A declared sampling target, design/missingness assumptions and treatment of boundaries/failures; assessment of interval coverage or decision error for that target before offering an inferential API. |
| Does a sparse source design estimate the quantities needed for planning? | Reuse existing recovery results; investigate only a named unresolved allocation, score-distribution or missingness condition. | Bias/error, unavailable attempts and decision consequences reported together. Rank, graph connectivity or a returned coefficient alone cannot establish adequacy. |
| Does my assessment require local raters, nested tasks or partial sharing? | Use the implemented Person-by-(Child-within-Parent) model when appropriate, such as separate rater teams for tasks. Specify other nesting/partial-sharing designs separately. | The implemented five-component point workflow has independent QR/kernel and projection checks. These do not establish precision or recovery for arbitrary sparse allocations, nor provide nested-design intervals. |

For planning uncertainty, preserve dependence between scenarios and composites;
separate intervals cannot simply be treated as uncertainty in their difference.
Distinguish uncertainty for a prespecified comparison from inference after
selecting the largest estimate. Evaluate how often a plan choice differs and
how much true dependability it loses; these are different criteria. The paired
comparison API now supplies approximate pointwise intervals for two crossed facets
under an explicit normal random-effects assumption. Existing saved-result
comparisons and targeted distribution checks support this bounded method;
they do not establish robustness across score distributions and designs.

The first uncertainty scope should use the existing common-facet model and
prespecified complete future plans. It does not automatically include automatic
weight selection, optimal sparse assignments, simultaneous guarantees or
informative-missingness correction. If no method is adequately supported,
keep current output explicitly at the point-projection scope while revising
the method or proposed inclusion; do not present an unqualified interval.
Equal rating counts need not imply equal examinee burden or cost.

See [the G-theory workflow](README.md#multivariate-g-theory). The existing
GENOVA comparisons remain useful checks of formulas and negative-component
conventions; full software equivalence is not a development or release goal.

## External features, grouping, and missing values

The implemented development workflow reviews one row per Person, rater or task
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

| User need | Next action and completion condition |
| --- | --- |
| Use the existing descriptive workflow | Consolidate the tutorial, ID/omission accounting, plots and imputation-pairing behavior for stage 1 of the planned 0.2.4 integration. Reuse existing stress evidence within its tested workload; input caps are not runtime or memory guarantees. |
| Relate person, rater and task groups | Preserve separate feature tables and join classifications to planned/observed ratings by ID. Descriptive relationships must not become causal group effects or a joint clustering model. |
| Use many features or numeric PCA/k-means | Add a specific workflow only after stating its purpose, scaling, distance and the role of PCA. Assess redundant/irrelevant features and interpretation of the transformed space; more features or another algorithm is not itself an improvement. |
| Make claims about stable groups or classify new entities | Specify the sampling or prediction target separately from imputation sensitivity. Evaluate it before adding a stability statistic or assignment API. |

Missing external attributes, unassigned ratings and missing assigned responses
remain distinct. Response-score imputation is a separate extension: it must
preserve rating structure and identify how downstream estimates and uncertainty
are combined on a common scale. It requires an explicit missingness model and
sensitivity assumptions, not filling every empty cell or treating MAR as a
correction. Ward linkage, pooled trees, joint cross-facet imputation and pooled
inferential group effects are outside the present workflow.

See [external-feature examples](README.md#external-features-and-exploratory-groups)
and `vignette("mfrmr-external-features", package = "mfrmr")`.

## Rater assignment and anchors

Design support asks which allocation serves a declared Person or facet target
within total workload, per-rater workload and examinee-burden constraints.
The unit of cost must be explicit: a performance, a scored response and an
individual criterion rating need not have the same cost.

The next useful extension should reuse existing assignment and coverage review,
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

This is a possible model-extension track for generalization beyond observed raters:
how uncertain is a Person comparison when different raters are sampled?
Current fixed-facet MML, post-fit shrinkage and observed-score G-theory do not
jointly estimate a random-facet MFRM.

The first proposed scope is one observed scale, unit weights, adjacent-category
RSM probabilities, one random-rater intercept shared across Persons, fixed
task/criterion effects and a declared Person distribution. Development requires
observed-rater and replacement-rater targets, identification/scale constraints,
a matching likelihood, and estimation/prediction evidence at realistic workloads
and variance boundaries before a public scoring route.

Reuse an existing computation only when its probabilities, effect sharing,
constraints and target match. A cumulative-link ordinal model or a new random
effect integrated independently for every Person is a different model.
Person-local testlets require a different covariance structure. PCM, sampled
tasks, covariance and random slopes follow concrete needs after this initial
scope; they are not all prerequisites for a first bounded random-rater method.

## Model scope

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

| Horizon | Outcome and sequencing |
| --- | --- |
| 0.2.4, release candidate | The selected function, statistical-support and model extensions are implemented. Integrate and verify their combined source before publication. |
| Further releases | Address needs beyond the selected 0.2.4 scope while maintaining supported APIs, saved-object compatibility and reproducible performance. |

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
