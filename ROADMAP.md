# mfrmr roadmap

Status: public roadmap, updated 2026-09-10.

This roadmap describes the package's intended user-facing direction. It is not
a promise of release dates. Completed changes are documented in `NEWS.md`.
The immediate priority is to establish the evidence supporting the existing
public analysis routes before extending the model families or releasing 0.2.4.

## Current releases

- mfrmr 0.2.3.1 is the current CRAN source release.
- mfrmr 0.2.4.9000 is under development and has not been released.

The 0.2.4 development version retains the established MFRM fitting workflow
and adds portable calibration objects for supported RSM and PCM analyses. These
objects are designed to preserve the model, scale, category mapping, facet
levels, anchors, and scoring settings needed to score new Persons consistently.

## What 0.2.4 is intended to support

The planned portable workflow is deliberately narrow:

- one observed rating scale per analysis;
- RSM or PCM;
- MML calibration on a fixed standard-normal Person distribution;
- stored direct and group facet anchors;
- same-data numerical-integration sensitivity review before extraction;
- validation before a calibration is frozen;
- EAP scoring of new Persons from the frozen calibration; and
- explicit rejection of incompatible data, levels, categories, models, and
  scoring settings.

The ordinary fitted-object workflow continues to support the model and
estimation combinations documented by `fit_mfrm()`. A fitted model and a
portable calibration are different objects: the latter has a stricter identity
and compatibility contract for later scoring.

Implementation of this workflow and successful package checks do not complete
the release review. Existing GPCM and JML functionality must also be covered by
the review, even though portable calibration does not support those routes.

## Evidence required before 0.2.4

For every public analysis claim, the review must identify its model, estimator,
parameter or score, supported data conditions, existing evidence, and remaining
limitations. Earlier release inclusion does not substitute for this evidence.
The work proceeds in the following order; dates depend on the findings.

| Order | Question and work | Completion requirement |
| --- | --- | --- |
| 1. Match claims to evidence | What can users infer from each fitted-model, scoring, diagnostic, and reporting route? Reconcile help, examples, capability tables, and actual outputs with existing validation. | Every retained claim has an explicit evidence basis or an enforced restriction; missing evidence and required follow-up are recorded. |
| 2. Verify numerical behavior | Does each implementation evaluate and optimize its stated model? Check independent likelihood/probability calculations, derivatives, identification, boundary behavior, and integration sensitivity; use external comparisons where the models match. | Differences have an explained cause and a verified correction or restriction. A returned fit or optimizer success code is insufficient. |
| 3. Evaluate statistical performance | Under the stated use conditions, how well are parameters recovered and how reliable are the reported uncertainties? Evaluate bias, RMSE, standard errors, interval coverage, and failure/readiness behavior for the relevant quantities. | Prespecified, practically justified criteria and Monte Carlo precision support the retained claims. Inconclusive results remain unresolved. |
| 4. Verify output restrictions | Can an unsupported inference become an ordinary estimate, interval, ranking, or decision through summaries, plots, scoring, or export? | Each affected route preserves its restrictions in executable checks and a complete user workflow. Warnings alone cannot justify unsupported inferential output. |
| 5. Check the release source | Do the final source package, examples, documentation, and operating-system checks reproduce the reviewed behavior? | Statistical and output reviews are resolved before the final release decision; the checked source includes all resulting changes. |

The first stage reuses existing evidence and identifies the specific questions
that require further work. It does not automatically repeat every historical
simulation. Numerical agreement, parameter recovery, uncertainty calibration,
and correct refusal of unsupported inference are distinct results.

### Current evidence and unresolved decisions — 2026-09-10

Read the status by claim and condition, not by number of functions, plots or
successful fits. The public goal is a defensible workflow from rating design
and estimation through uncertainty, scoring and communication. A new score or
plot inherits only the evidence for its actual target and reference.

| Area | Evidence now available | Decision still needed |
| --- | --- | --- |
| Fixed-population RSM/PCM structural uncertainty | [20,000-dataset confirmation](inst/validation/mml-structural-coverage-record-0.2.4.md), then [30,000 fresh targeted datasets](inst/validation/mml-structural-bias-confirmation-record-0.2.4.md) supporting the three originally reviewed conditions. | Retain the q61, unit-weight, specified-design scope; assess applicability after source changes. These studies are separate and are not 50,000 replications of every condition. |
| Numerical integration and population inference | [Use-condition audit](inst/validation/mml-use-condition-audit-record-0.2.4.md), population identification/profile/output reviews and [full-information checks](inst/validation/population-full-information-record-0.2.4.md); [40 preliminary population datasets](inst/validation/population-coverage-record-0.2.4.md). | Default-grid and long-pattern sensitivity remain design-specific; estimated-population inference stays restricted. The 80,000-dataset population confirmation has not run. Local full rank does not establish strong information or valid boundary inference. |
| Fair Scores and their intervals | Earlier pilot/output repairs and [planned FairZ confirmation with 40 preliminary datasets](inst/validation/fairz-coverage-record-0.2.4.md); joint-SE numerics and full refits checked on the recorded source. | Complete the documentation review before the unrun 20,000-dataset FairZ study and assess its fixed criteria. Reestimated-reference FairM and Person intervals need distinct targets; preliminary numerical checks do not establish coverage. |
| Anchors, linking and paired model comparisons | Graph, topology and [conditional offset sensitivity](inst/validation/offset-sensitivity-record-0.2.4.md); [paired Wright/CCC views](inst/validation/plot-comparison-record-0.2.4.md). | Changes in fixed anchor constraints, rating deletion and common-element exclusion require different procedures. Full-refit changes need a common scale and covariance between the paired estimates. |
| DRF, interactions and diagnostic decisions | [22 unique execution cases](inst/validation/interval-drf-preflight-record-0.2.4.md) verify null/DRF/interaction paths, weak linking, the five-anchor conditional refit screen and population/interaction refusals. | Align generator location constraints and population means before a calibrated null/power study; include calibration-anchor uncertainty. Existing screening output is not a validated hypothesis test. |
| Full GPCM and estimator-specific JML | Independent kernels, owner/boundary records and bounded external comparisons are indexed in the [internal roadmap](inst/validation/internal-roadmap-0.2.3.md#2026-09-09-024-validation-before-release). | Exact full-model numerical, uncertainty and output scope remains open. Item-only TAM overlap and JML comparisons with different corrections cannot close it. |
| Output consistency and usability | Shared inference restrictions, facet-equivalence covariance repairs, colour/grayscale and title/note controls, table/base/ggplot checks; [records indexed here](inst/validation/README.md). | Recheck every decision-bearing route, saved/imported objects and exports; complete dense/cross-platform rendering and end-to-end examples. Passing drawings or tests does not establish coverage. |

### Delivery order and release consequences

1. **Fix the meaning and availability of each result.** Reconcile the existing
   claim inventory with current source. Distinguish measures, FairM/FairZ,
   fixed-calibration Person scores and differences between fits. State the
   reference, units, covariance source and what is reestimated. Decide whether
   each interval is qualified inference, a clearly identified diagnostic
   approximation, or unavailable; enforce that decision through all outputs.
2. **Finish the small studies that determine the large studies.** Audit the
   FairZ joint-SE candidate and interval construction; specify and pilot
   interaction/DRF targets, including group ability differences without DRF.
   Verify full-fit replay and common-scale matching. This precedes the next
   long confirmation batch; it does not require developing every possible
   combined model. Unsupported analysis combinations stay explicit.
3. **Run only the missing claim-specific confirmation.** Fixed-reference FairZ
   is the first new score-uncertainty target. Retain the separate population
   protocol and allocate its execution after the interaction/DRF pilot review.
   Freeze practical criteria, Monte Carlo precision, fresh seeds, failure
   accounting and runtime before each study. The FairZ minimum of 2,500 per
   cell is a coverage-precision starting point, not a guarantee of sufficient
   bias precision. Do not expand the full Cartesian product of all factors.
4. **Extend uncertainty to the actual scoring and anchor procedures.** Specify
   fixed versus reestimated FairM references and Person targets, then evaluate
   the corresponding full-refit or frozen-calibration procedure. For anchor
   changes and model comparisons, refit both procedures on the same replicate
   and repeat any linking/selection belonging to the procedure. Carry paired
   covariance; never reuse the old model's SE as the new result's uncertainty.
5. **Close the independent GPCM/JML and secondary-route reviews.** Exact-model
   numerical/comparison work can progress while the admitted RSM/PCM studies
   run; it is not postponed until every scoring extension is complete.
   Retained fit/diagnostic decisions, G/D-study, shrinkage, imported results and
   other exported claims also need scoped dispositions. Deferred research
   extensions do not excuse gaps in already public functions.
6. **Validate complete user workflows and the final source.** Check design →
   fit → diagnosis → score → plot/report/export, including unsupported cases,
   small devices, monochrome and hidden annotations. Once retained statistical
   claims and restrictions close, freeze one release candidate and run the
   full packaged tests, five-platform matrix, examples/vignettes and CRAN
   checks. A release date follows this decision, not the number of completed
   features.

The [maintainer work queue](inst/validation/internal-roadmap-0.2.3.md#2026-09-10-integrated-work-queue)
assigns dependencies, concrete outputs, acceptance checks and computing
budgets. This queue consolidates the recent plot/Fair Score work with the
existing population and interaction/DRF work; it does not rewrite their frozen
protocols or historical results.

A retained ordinary estimation/inference claim with unresolved evidence holds
release. A narrower support scope requires an explicit documented decision,
implemented restrictions and verification of the remaining claims. Warnings
or the word "descriptive" cannot excuse an incorrect calculation. General
multi-scale, portable GPCM and other research extensions remain outside 0.2.4;
existing promised workflows must still be usable within their stated scope.

### RSM/PCM MML and portable scoring

TAM comparisons found close agreement on simple matched cases, but also
integration sensitivity in the tested patterns with many responses per Person.
The implemented `mml_quadrature_sensitivity()` review exposes movement in
likelihood, parameters, probabilities, EAP, and posterior SD. Portable
extraction requires the reviewed fit with the highest evaluated integration
order and completed estimation at every evaluated order.

This is a required review procedure, not automatic proof of numerical
stability. Neither the default 31 points nor 181 points is a universal accuracy
guarantee. Release review must assess the procedure and its limitations on the
supported designs, with fitting and scoring integration assessed separately.
An explanation of a failed comparison does not convert it into a passed one.

Portable score intervals are conditional on the frozen point calibration and
the recorded prior. They exclude calibration-parameter uncertainty. Their
validation must use that same target; claims about repeated calibration,
linking uncertainty, or transport to another population need separate evidence.

### Fair Scores and complete refits

`plot_fair_average(plot_type = "measure")` now relates measures to Fair Scores;
observed-score and gap views complement it. A transformation plot is not
independent evidence for the model. FairZ denotes zero-reference expected
scores, not z-scores. Current plot intervals are conditional approximations;
they do not establish repeated-calibration or gap uncertainty.

The [Fair Score refit protocol](inst/validation/fair-score-refit-protocol-0.2.4.md)
and its [completed pilot](inst/validation/fair-score-refit-record-0.2.4.md)
compare focal-measure propagation with joint effect/threshold covariance for
fixed-reference FairZ. The joint RSM/PCM candidate is repository-only. The
[eight-cell audit](inst/validation/interval-drf-preflight-record-0.2.4.md) now
passes numerical/refit checks and the minimal DRF workflow has been exercised.
The [fresh-seed coverage supplement](inst/validation/fairz-coverage-record-0.2.4.md)
has a prespecified protocol and 40 preliminary datasets checked on the recorded
source; the planned
20,000-dataset main study remains unrun (about four serial hours initially
budgeted). Execution is paused for the help/README audit; source identity must
be reconciled after documentation changes before resuming numerical work.
The separate DRF confirmation still needs location and linking
alignment. Mean-reference FairM, Person
intervals and paired refit changes have separate targets; their uncertainty
cannot be inherited from structural-parameter coverage. FairZ remains a
zero-reference expected score, not a z-score. Plot title/note suppression
must preserve these definitions and uncertainty limits in returned data.

### GPCM and JML

GPCM verification must cover the documented complete adjacent-category model,
including the selected Criterion- or Rater-owned slope and the other facet
effects. Item-only agreement with TAM does not establish this full-model
result. When an external program does not express the same model, independent
calculations and model-matched recovery studies must supply the relevant
evidence. JML and MML, and the two slope owners, require separate conclusions.

Standard errors require checks against independently calculated information
and sampling variation, with interval coverage assessed under the declared
conditions. Matching another program's marginal SE columns is insufficient
when identification changes require unavailable parameter covariances.
Ordinary inference remains unavailable wherever this basis is unresolved.

JML comparisons must distinguish unadjusted estimates, extreme-Person profile
limits, extreme-score adjustments, and finite-item bias corrections. Compare
like estimators where possible and evaluate different estimators against their
own stated targets. Include connected sparse designs, unequal exposure,
missingness, and extreme responses without discarding failed or ineligible
runs. A profile limit does not by itself correct finite-item JML bias.

## Model scope

| Area | Current direction |
| --- | --- |
| RSM | Supported in the established fitting workflow and the 0.2.4 development portable calibration workflow. |
| PCM | Supported in the established fitting workflow and the 0.2.4 development portable calibration workflow. |
| GPCM | Available only within the documented bounded fitting routes. Portable GPCM calibration is not part of 0.2.4. |
| JML | Retained for documented fitted-model analyses. The 0.2.4 portable calibration workflow is MML-only. |
| Interactions | Supported where documented for fitted models; portable interaction calibration is not part of 0.2.4. |
| Multiple scales | Not silently pooled. Explicit multiple-scale routing is planned for a later version. |

The GPCM limitation is substantive, not merely a user-interface restriction.
Slope identification, boundary behavior, and portable scale identity require a
stronger contract than the RSM/PCM workflow currently provides.

## Generalizability theory

The existing `mfrm_generalizability()` and `mfrm_d_study()` helpers provide a
limited observed-score, main-effects mixed-model decomposition and planning
projection. They do not estimate reliability on the MFRM latent scale or a
full interaction variance decomposition. Their public interpretation and
restrictions belong in the existing-function review above.

A possible future direction includes multivariate designs, with separate
handling of:

- universe-score covariance across outcomes;
- outcome-specific and cross-outcome error components;
- relative and absolute decisions;
- admissible positive-semidefinite covariance structures; and
- design-dependent decision coefficients.

Multivariate support will be described as available only after the public API,
identifiability conditions, numerical behavior, and examples are complete.
Univariate calculations do not by themselves establish multivariate support.

## Rater assignment and anchors

Rater assignment and anchoring are treated as design problems rather than as a
single recommended percentage. Planned guidance distinguishes:

- complete and incomplete rating designs;
- connectedness of Persons, raters, and tasks;
- direct anchors, group anchors, and unanchored linking;
- assignment order and workload balance;
- overlap patterns and bridge raters; and
- sensitivity of facet estimates and Person measures to missing ratings.

Examples and simulations will state the exact design and estimand. Results from
one allocation pattern will not be generalized to all incomplete designs.

The [question-led visualization plan](inst/validation/plot-expansion-plan-0.2.4.md)
prioritizes the existing common-element anchor graph. Its first repair now
retains isolated waves and empty chains, preserves pair-specific screening and
stable identities, and exposes nodes/edges/notes with monochrome and title/note
controls; see the [repair record](inst/validation/equating-graph-record-0.2.4.md).
The [topology follow-up](inst/validation/equating-topology-record-0.2.4.md) now
adds a compact administration-link view and single-element removal audit,
including lost direct links, newly disconnected pairs and component membership.
The [conditional offset follow-up](inst/validation/offset-sensitivity-record-0.2.4.md)
now reruns screening and linking offsets after each common-element deletion,
holding source estimates and SEs fixed. It preserves unavailable links and
records contribution/retention changes. Topology deletion still holds screening
fixed and remains a different question. Full model refits under changed anchor
constraints and justified uncertainty calculations remain separate work; those
must first specify which constraints or observations are changing.
Observed-design, common-element, declared-anchor and residual-association
networks must retain distinct meanings. Follow-up visualization candidates
include aligned difference-versus-mean comparisons and coordinated residual
matrices/networks, reusing existing tables and renderers. Graph connectedness
and centrality do not replace identification, drift or uncertainty checks.

The [JLTA-inspired paired plot follow-up](inst/validation/plot-comparison-record-0.2.4.md)
adds `plot_compare_mfrm()` for two fitted models: Wright distributions/locations
and matched differences, plus selected-group CCCs and signed probability
differences. It checks recorded comparison settings, retains source readiness,
and uses category panels for monochrome/many-category figures. Scale alignment,
external-software adapters and uncertainty for differences remain separate
tasks; visual overlap does not satisfy statistical equivalence gates.

## External comparison

FACETS, ConQuest, TAM, and other software may be used as independent
comparators when model, parameterization, constraints, anchors, categories, and
estimands can be aligned. Agreement with another program is useful evidence,
but it is not the definition of correctness and does not imply feature parity.

## Relationship to adjacent R packages

`mfrmr` should own the many-facet analysis contract: long-format facet roles,
score support, identification and anchor declarations, connectivity and
readiness checks, fitted-scale diagnostics, and a reproducible route from fit
to reporting. It should not reproduce mature estimators or simulation engines
merely to offer another interface to the same estimand.

| Package | Existing responsibility | Relationship to `mfrmr` | Non-goal for `mfrmr` |
| --- | --- | --- | --- |
| TAM | Broad MML/JML IRT, GPCM, multidimensional, latent-regression, plausible-value, and multifacet routes | Independent comparator or external analysis route after the measurement, estimation, and scoring specifications are matched | A TAM compatibility mode or clone of its solver and design-matrix engine |
| mirt | Broad unidimensional/multidimensional IRT, GPCM/GRM, mixed-effects and stochastic estimation routes | First external oracle for response-family, slope, and multidimensional questions outside the bounded `mfrmr` core | Reimplementing MIRT, GRM, mixture, or stochastic engines without a named many-facet use case |
| immer | Hierarchical rater models and CML/CCML/JML partial-credit models for multiple ratings | Alternative-estimand and sensitivity route for hierarchical-rater or conditional-likelihood questions | Calling an HRM, CML, or bias-corrected JML result numerically equivalent to the bounded `mfrmr` GPCM |
| simr | Simulation-based power analysis for `lme4` mixed models | External route for power of a model-matched mixed-model hypothesis | Reusing GLMM power as MFRM recovery, anchor/link, fit-screening, or scoring evidence |

The default order is documentation or export, then one matched external
microcase, then a narrow adapter only if users repeatedly need the same
translation. New dependencies and new package-native engines require evidence
that these smaller routes cannot answer the intended decision.

## Version direction

| Version | User-facing goal |
| --- | --- |
| 0.2.4 | Complete the existing-route evidence and output review, then release portable fixed calibration and operational scoring for one observed RSM/PCM scale, preserving supported facet anchors. |
| 0.2.5 | After the 0.2.4 review closes, consider explicit scale identifiers and separate-scale RSM/binary and PCM routes; mixed response structures follow only after scale-specific identification, scoring, and missingness behavior are validated. |
| 0.3.0 | Consolidate APIs, object schemas, compatibility and migration policy, examples, and reproducible performance evidence for the validated routes. |
| 1.0.0 | Release a deliberately bounded stable core with documented support conditions, statistical evidence, output restrictions, and maintenance commitments. |

Portable GPCM, multidimensional estimation, multivariate G-theory, and new
response families remain conditional research directions without a promised
release version. Each requires a concrete analysis need, a model and estimand
specification, independent verification, and appropriate statistical evidence
before public implementation is promoted. These extensions do not displace
verification of functionality already exposed to users.

Later-version goals may change in response to empirical use, statistical
evidence, and compatibility needs. New functionality will be described as
supported only when its interface, documentation, and numerical behavior are
ready for use.

## Compatibility principles

- Incompatible objects should fail clearly rather than be silently coerced.
- Stored scale and anchor semantics matter more than incidental file hashes.
- Object schema changes require an explicit compatibility or refusal policy.
- Examples should use realistic defaults even when compact examples use
  smaller settings for illustration.
- Help, messages, vignettes, and printed output should use clear reader-facing
  language.

## Not part of the 0.2.4 promise

Version 0.2.4 is not intended to provide:

- portable GPCM calibration;
- portable JML calibration;
- portable interaction calibration;
- automatic cross-scale linking;
- multiple observed scales in one portable calibration;
- exported multivariate G-theory analysis; or
- complete feature parity with external MFRM software.

These exclusions keep the supported claims aligned with the statistical and
operational behavior that users can rely on.
