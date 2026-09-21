# mfrmr roadmap

Status: public roadmap, updated 2026-09-21. This roadmap describes the direction
of development; release dates are not promised.
See [NEWS](NEWS.md) for implemented changes and the
[README](README.md) for current usage and interpretation limits.

## Current releases

mfrmr 0.2.4 is a release candidate and has not been released.
This source branch is the subsequent unreleased development version 0.2.4.9001.
The README describes this working version; use `packageVersion("mfrmr")`
and the help shipped with your installation for its available functionality.

## Purpose and priorities

mfrmr helps users calibrate ratings, compare Persons and facets on an explicit
measurement scale, reuse a calibration, and report what the results support.
The immediate release priority is a reliable existing workflow with clear
uncertainty and compatibility limits. Multivariate observed-score G-theory is
a priority for subsequent feature development: it addresses the dependability
of component and composite scores when raters, tasks, or score weights change.
Rating-design support and models for sampled raters remain separate extensions.

The estimation core remains frequentist MML/JML. Posterior EAP scoring
conditional on a fitted calibration does not make the calibration fully
Bayesian. Future computational choices must preserve the intended measurement
model, scale and inferential target.

## Focus for 0.2.4

The principal addition is portable calibration and new-Person scoring:

- one observed rating scale, RSM or PCM, and MML calibration with a fixed
  standard-normal Person distribution;
- supported direct and group facet anchors and stored two-way facet interactions;
- review of fitting-integration sensitivity using the same data, score map,
  model and fitting settings, with estimation completed at every requested order;
- extraction from the exact highest-order fit in that review, with separate
  scoring-integration settings;
- preservation of categories, facet levels, anchors and scoring assumptions
  when saving, transferring and loading the calibration;
- EAP scoring of new Persons with compatible data and known non-Person levels,
  with incompatible inputs refused explicitly.

No single quadrature order is sufficient for every design. Users must judge
whether changes across the reviewed orders matter for their analysis.
Portable intervals condition on the saved point calibration and standard-normal
prior; they exclude calibration-estimation uncertainty. A successful numerical
review does not establish that the scoring prior suits a new population.
See the portable calibration workflow
(`vignette("mfrmr-portable-calibration", package = "mfrmr")`).

The other priority is consistent interpretation throughout existing analyses:

| Result | Meaning and limits to retain in tables, plots and reports |
| --- | --- |
| Fit and precision summaries | Optimizer success, estimability and precision assessment are separate. Brief and full summaries must give the same interpretation decision. |
| Person scores and posterior draws | EAP, SD and intervals condition on the fitted calibration and stated prior. Estimated-population scoring requires explicit exploratory review. Draws alone do not qualify downstream group or regression inference. |
| ICC intervals | Use joint parametric bootstrap ratios under the fitted Gaussian model; retain failed refits and withhold incomplete intervals. Separate component-profile bounds are not ICC profile-likelihood intervals. Saved interval results require recalculation. |
| ICC analysis sample | Preserve numeric score labels, require explicit omission of incomplete rows, and retain exclusion accounting. Calculate design effects using the same observations and grouping-level counts as the ICC model. Omission does not correct missing-data bias. |
| ICC score units and design-effect scope | Retain small positive variances without a fixed unit-dependent cutoff; constant scores have undefined variance shares. Treat design effects as separate per-facet approximations, not estimates of full-design precision. |
| Reliability and separation | Report the finite estimates and corresponding SEs used; incomplete SEs cannot produce a complete index. High rater separation means differences in severity, not high agreement. |
| Fit, category, marginal, PCA and Q3 diagnostics | Preserve missing results and report how many observations or elements were evaluated. Flags are descriptive review aids, without guaranteed individual or multiple-element error rates. Ordered point estimates do not by themselves establish adequate categories. |
| QC | Assess differentiation only for facets selected for that purpose. An unavailable check cannot become a pass, and an overall QC result does not establish statistical validity. |
| Agreement, networks and response times | Retain unavailable comparisons, graph scope and the number of observations with valid times. Agreement and graph patterns do not establish rater quality or causal halo; time cutoffs do not establish rapid guessing or effort. |
| Fair Scores | State the reference profile and omitted uncertainty. Existing approximate intervals remain diagnostic; a new inferential FairZ method is outside 0.2.4. |
| Group comparisons and linking | Residual differences describe observed-minus-expected scores without tests or confidence intervals. Linked subgroup refits and drift screens retain their separate uncertainty limits. A new omnibus differential-functioning test is outside 0.2.4. |
| Observed-score G/D studies and shrinkage | Retain their distinct models and conditional assumptions; neither is a jointly estimated random-facet MFRM or a source of fully propagated uncertainty. Reapplying shrinkage replaces the previous adjustment, and replay preserves its position after fitting. |
| External imports | Preserve source coordinates and uncertainty conventions. Missing joint covariance cannot be reconstructed from marginal SEs. Imported objects do not become native fits or portable calibrations. |

Existing calculations and interpretations still require review before release.
Clearer wording does not resolve an incorrect formula or unsupported decision.
Changed behavior and saved-object instructions must agree across NEWS, help,
examples and exported results. See
[Updating saved analyses](README.md#updating-saved-analyses) for the user actions.

## Model scope

| Area | Current scope and direction |
| --- | --- |
| RSM / PCM | Existing fitted-model workflows and portable fixed-normal MML calibration. Category structure and identification must match the rating design. |
| GPCM | One selected facet owns both relative slopes and steps. Free-slope uncertainty, automatic information-criterion ranking and the PCM-versus-GPCM chi-square LRT remain unavailable. No portable GPCM in 0.2.4. |
| JML | Fitting uses observed scores without extreme-score adjustment or finite-item bias correction. Free extreme Persons retain infinite estimates; optional display replacements are separate. SEs and normal bands remain exploratory. No corrected-JML estimator or portable JML in 0.2.4. |
| Interactions / estimated populations | Compatible fixed-normal RSM/PCM MML calibrations preserve two-way facet interactions. Estimated-population fits remain fitted-object-only. Scoring compatibility or local information rank does not establish formal interaction inference. |
| Multiple scales | A later extension would identify and fit separate scales explicitly, without silent pooling or automatic cross-scale linking. |

For GPCM, "bounded" refers to documented model and workflow scope, not finite
parameter box constraints. Numerical convergence alone does not remove its
inferential restrictions. The model-scope guide
(`vignette("mfrmr-gpcm-scope", package = "mfrmr")`)
describes the available routes.

## External features, grouping, and missing values

The development version adds external-feature review and exploratory grouping
for one row per Person, rater, or other entity. Features, their types, weights,
and the group count are explicit choices. Group profiles and representative
entities help users interpret the partition; silhouette widths describe sample
separation. Groups do not establish ability levels, rater quality, or latent
measurement classes. Sampling stability and new-entity assignment require
separate development and validation.

Plots now show silhouettes, individual feature profiles, and co-membership
across imputations directly from these results. PAM is nonhierarchical.
Separate hierarchical analyses now support average and complete linkage on
Gower dissimilarities, with retained trees and dendrograms. Their partitions
can be compared with PAM, including across the same feature imputations.
Ward clustering, pooled trees, and branch-support estimates are not provided.

The external-feature tutorial
(`vignette("mfrmr-external-features", package = "mfrmr")`) now
demonstrates separate person, rater, and task tables, with classifications
joined by ID to planned and observed rating rows. This supports descriptive
assignment review, not a joint clustering model or inference about group
effects. Many-feature analyses require attention to redundant and irrelevant
variables. Numeric PCA/k-means integration and joint cross-facet imputation
remain future work; they need explicit distance,
scaling, dependence, and uncertainty choices before implementation.

Missing external features remain visible with user-supplied reasons. Clustering
stops by default; explicit omission retains unclassified IDs. This is not
imputation or correction for missing-data bias. Planned unassigned ratings,
unobserved assigned ratings, and missing external attributes need distinct
handling. The existing rating-design review remains the starting point for
rating coverage; it does not infer why an observation is absent.

The development version also accepts external-feature imputations fitted with
`mice` for repeated clustering. Users select eligible missing cells explicitly;
original observations, IDs, reasons, and model diagnostics are preserved.
Pairwise co-membership proportions describe sensitivity to the supplied
imputations without averaging arbitrary group labels. They do not establish
sampling stability or provide pooled inferential estimates. Numeric ranges are
recalculated in each completed sample and retained for inspection.

Feature-selection, group-count, feature-weight, and clustering-method
sensitivity can be reviewed by comparing existing clustering results on the
same entities. Shared feature values and types must remain unchanged.
Pair changes and adjusted Rand indices compare
partitions without relying on group numbers. For multiply imputed features,
the comparison pairs completed tables and retains every imputation's result.
When feature selections differ, it requires the same fitted imputation model
and checks selected values against each completion. Removing a clustering
feature does not remove it from the imputation model. Group sizes, feature
counts, profiles, and silhouettes remain available for substantive
review; no setting is automatically selected. These descriptive comparisons
do not provide sampling stability or pooled inference.

Further missing-data support for rating responses must preserve rating
structure and combine downstream estimates and uncertainty on a common scale.
Nonresponse related to unobserved outcomes requires explicit assumptions and
sensitivity analysis. No general automatic missing-score correction is
promised for 0.2.4; the new external-feature APIs belong to subsequent development.

## Random-effects MFRM and testlet covariance

The first intended use is generalization beyond observed raters: how much do
raters vary, and how uncertain is a Person comparison when the raters are
replaced? That question differs from dependence among repeated ratings of the
same response. Current fixed-facet MML and post-fit empirical-Bayes shrinkage
do not estimate a joint random-facet MFRM.

The initial model would use one observed scale, unit weights, an
adjacent-category RSM, one shared random-rater intercept, fixed task/criterion
effects and a declared Person distribution. Each rater's effect must be shared
across all Persons rated by that rater. A new effect integrated independently
for every Person would describe a different model.

Development proceeds from a specified target to computation and then to use:

1. Distinguish predictions for observed raters from predictions for replacement
   raters, and state scale constraints, missingness assumptions and the role
   of calibration uncertainty in Person and Person-difference results.
2. Use existing computation where it matches the response probabilities,
   effect sharing and constraints. A cumulative-link ordinal model is not
   interchangeable with a polytomous RSM/PCM.
3. Check identification, likelihood calculations, integration, weak information,
   variance boundaries and performance at realistic rater counts and workloads.
   Evaluate estimation and interval/prediction behavior for the intended target.
4. Preserve those assumptions in scoring, saved results and reports before
   adding PCM, sampled tasks, local testlets, covariance or random slopes.

Person-local testlets and effects shared across raters need different
covariance structures. Positive-definite covariance alone does not establish
identification. A new rater cannot silently be assigned severity zero, and
independent Person SDs do not express the joint uncertainty of a difference.
Random slopes on observed covariates also differ from discrimination on
latent ability. None of these extensions is part of the 0.2.4 promise.

## Rater assignment and anchors

The design question is which assignments provide useful Person or facet
comparisons within a stated total and per-rater workload. Define whether one
unit of cost is a scored response or an individual criterion rating.
Connectedness, balanced workload and an anchor percentage alone cannot answer
the precision question; there is no single recommended percentage.

The next steps are to:

- preserve correct workload, connectivity, requested-facet and failed-run
  accounting in existing design tools;
- compare complete and incomplete rating designs at equal cost for declared
  targets, retaining disconnected cases and any subgroup disadvantages;
- distinguish direct anchors, group anchors, and unanchored linking, including
  the uncertainty introduced by selecting or estimating the link;
- compare allocations using target-specific estimation error, interval
  availability and performance, and computation, rather than connectivity alone;
- extend comparisons to replacement raters only after the matching sampled-rater
  model and prediction methods are available.

Evidence from one allocation pattern will not be generalized to all designs.
Facet-estimation accuracy cannot substitute for Person-difference precision.
An API recommending designs should expose these trade-offs rather than name a
best design without a user-relevant target and workload constraints.

Deleting a rating, fixing an anchor and excluding a common linking element are
different changes. Existing linking sensitivity views hold source estimates
fixed. A future uncertainty analysis that refits models must also repeat any
selection/linking and account for covariance between the compared results.

## Generalizability theory

Current `mfrm_generalizability()` and `mfrm_d_study()` provide an observed-score,
main-effects mixed-model decomposition and planning projection. They do not
estimate reliability on the MFRM latent scale. Missing variance components
leave affected coefficients unavailable; convergence warnings require review.
D-study projections hold estimated variances fixed, and residual-scaling
choices express assumptions rather than uncertainty bounds. These coefficients
do not estimate accuracy at a particular cut score.

In the development version, missing scores or selected facet values require
explicit omission. G/D results retain the source of their data and the counts
of rows supplied, used, and excluded. Stored fitted rows cannot reconstruct
earlier MFRM exclusions, and omission does not correct missing-data bias.

The development version now provides a bounded multivariate G-study and
D-study workflow through `mfrm_multivariate_gstudy()` and
`mfrm_multivariate_d_study()`.
For example, an assessment may score content, organization, and language on
each performance. Users need to examine how changing their composite weights,
or the numbers of raters and tasks, changes score dependability. Correlated
components require universe-score and error covariances; averaging the
components' separate reliability coefficients does not answer this question.

The default ANOVA implementation accepts complete, balanced, fully crossed
Person-by-Task and Person-by-Rater-by-Task designs. An explicit
`method = "minque0"` also estimates these covariance components from an
incomplete observed configuration, provided its moment equations separate
them. The same condition identities apply across all score components.
A Person-by-Task design is requested explicitly with `rater = NULL`;
it estimates Person, Task and combined Person-by-Task/residual covariance
matrices and permits D-studies of task counts only. Score components are fixed
parts of the intended assessment; included raters and tasks are random
conditions of measurement. With a rater facet, the model
also estimates Person-by-Rater, Person-by-Task and Rater-by-Task components.
With one observation per cell, the highest-order interaction and residual
error remain combined. The D-study
retains their distinct averaging rules, score units, and user-specified
weights when forming relative-error and absolute-error covariance matrices,
composite G/Phi, and SEMs.
The D-study plot method shows G/Phi or SEM for one explicitly identified score
or composite, with rater/task counts held fixed within each line. It retains
unavailable results and their reasons. Help leads from a planning question to
scenario construction, metric interpretation and exact values; these plots
are conditional projections without confidence intervals or automatic design
selection.
Signed weights also support difference-score dependability when the score
scales make subtraction meaningful. The same weights are used for the target
composite and its observed estimate; distinct estimation weights and profile
reliability remain outside this workflow.

Sparse estimation retains numerical rank/conditioning and replication
diagnostics. Explicit missing-row omission uses a common multivariate sample
and records excluded rows; it does not impute ratings or correct selective
assignment or nonresponse. Complete-design D-study projections require an
explicit grid when the source data are incomplete. Using global facet-level
counts as per-person replication would describe the wrong measurement design.
Planned assignment coverage, covariance-component identification, numerical
admissibility, and statistical precision remain separate questions.

Raw negative or indefinite component estimates are retained without repair;
materially non-PSD components withhold coefficients and SEMs. Matrix
admissibility does not establish precise estimation or adequate model fit.
The common-task workflow reproduces the numerical example in Brennan's
mGENOVA manual, from the supplied scores to component matrices and D-study
coefficients; this does not establish sampling precision or broad recovery.
This workflow concerns dependability on the observed-score scale.
Treating ordered categories as numeric scores does not
make their coefficients measures of latent ordinal dependability.
Nested/local or partially shared facets, score-specific missing-data models,
covariate-dependent assignment, sparse-roster D-studies and sampling intervals
need separate extensions and evidence. Before broad sparse-design claims,
evaluate recovery and precision under representative overlap, variance
boundaries and assignment mechanisms, rather than judging support by cell
coverage or successful calculation alone.
This workflow complements MFRM on the observed-score scale; it does not
provide multivariate latent MFRM estimation or cut-score classification accuracy.
It is developed separately from the 0.2.4 release candidate, with no release
version promised yet.

For the roles of composite weights and design-specific covariance, see
[Brennan (2016)](https://education.uiowa.edu/sites/education.uiowa.edu/files/2022-10/casma-research-report-50.pdf)
and [Brennan, Kim, and Lee (2022)](https://doi.org/10.1177/00131644211049746).

## Response time and decision processes

These are later research directions. A response-time model first needs a
specific timed event, actor and unit, treatment of missing or censored times,
and an identified relationship between ability and speed. One respondent's
production time must not be duplicated because several raters score that
response; rater scoring time is a different observation.

A drift diffusion model requires an appropriate choice-and-time task and its
own likelihood. Polytomous ratings or essay completion times alone do not
justify it. Current descriptive time summaries do not estimate either model.

## External comparison

mfrmr should reuse computation where response probabilities, parameterization,
identification, effect owners, estimator and target agree. Agreement with
another program is bounded evidence, not a definition of correctness or a
promise of feature parity.

The mirt, TAM and eRm adapters preserve the source ability scale for supported
unidimensional Rasch/partial-credit models. TAM multi-facet displays combine
effects for each response condition; they do not reconstruct separate facet
coordinates. Summaries identify source scoring and uncertainty conventions,
and Wright maps show points only. Posterior SDs do not establish separation
reliability. Importing a result is neither re-estimation nor reconstruction of
an unavailable covariance.

## Version direction

| Version / horizon | Intended outcome |
| --- | --- |
| 0.2.4 | Portable fixed-normal RSM/PCM MML calibration and scoring, corrected existing workflows, and consistent interpretation and migration guidance. |
| 0.2.5 candidate | Explicit scale identifiers and separate-scale RSM/binary and PCM workflows, if user needs justify them. This would not provide automatic linking. |
| Later feature releases, version unassigned | A bounded multivariate observed-score G/D-study workflow, target-specific rating-design support, and a limited frequentist random-rater MFRM, introduced separately when their methods and workflows are ready. |
| 0.3.0 | Consolidate supported APIs, saved-object compatibility and reproducible performance. |
| 1.0.0 | A deliberately limited stable core with clear use conditions, statistical limits and maintenance commitments. |

## Not part of the 0.2.4 promise

There are no promised versions for portable GPCM/JML/estimated populations,
automatic cross-scale linking, multidimensional estimation, mixed response
families, multivariate G-theory, response-time or diffusion models.

## Compatibility principles

- Preserve model, scale, categories, anchors and uncertainty meaning when
  saving results, drawing figures and exporting tables.
- Refuse incompatible objects clearly and provide a migration or refusal
  explanation when saved-object requirements change.
- Use realistic examples without implying that one successful example
  establishes accuracy for every design or population.
- Describe a feature as supported only when its documented conditions,
  implementation and evidence agree. A roadmap entry is not current API support.
