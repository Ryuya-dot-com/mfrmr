# mfrmr roadmap

Status: public roadmap, updated 2026-09-30. This document describes user
priorities and supported or planned capabilities. Planned features are not
available merely because they appear here. See [NEWS](NEWS.md) for changes
and the [README](README.md) for analysis examples.

## Current releases

mfrmr 0.2.4.9000 is under development and has not been released.
The working release target is an integrated **0.2.4**. Earlier 0.2.4 release
candidates represent earlier source versions; their checks do not establish
that the current development version is ready for release.

The expanded release is unfinished. Two-slope-family GMFRM and corrected JML
are part of the agreed development program, with experimental implementations
and unresolved statistical questions. Their inclusion here is not a claim of
completed inference or a decision to move this work to a later release.

## Focus for 0.2.4

The release has three complementary purposes:

| Purpose | Question for the user | Current foundation and remaining work |
| --- | --- | --- |
| Generalized many-facet measurement | How do ability, severity, category use and discrimination explain ratings? | RSM/PCM and one-slope-family GPCM, with a provisional two-slope-family MML--EM route. Finish the supported inference, scoring and model-specific outputs without treating successful computation as evidence of accurate intervals. |
| Multivariate observed-score G/D studies | How would tasks, raters and score weights affect the dependability of an assessment? | Crossed and selected nested designs, incomplete-source estimation, composites, plots and scoped plan-comparison intervals. Preserve the distinction between the observed design and the future plan. |
| Rater feedback and assessment decisions | What should an assessor or assessment team review, and how uncertain is the conclusion? | Diagnostics, individual RSM/PCM feedback sheets, saved reports and calibration reuse. Finish the connections supported by each model and make unavailable operations clear. |

Educational performance assessment is the principal application. Music,
clinical assessment and judged sport also motivate the design, provided their
rating structure and assumptions match the selected model. Arbitrary column
names do not make every assessment design supported.

Validation must connect simulated recovery and interval coverage to actual
assessment workflows. The GPCM guide includes an empirical writing-data
review; its uneven assignment and unresolved numerical sensitivity identify
work still needed before rater feedback. A separate clinical-assessment design
review distinguishes the current model from published extensions. Real-data
fit, known-truth simulation and practitioner usability answer different
questions and do not substitute for one another.

The development order is to finish implemented workflows, establish the
statistical support for their claims, complete the agreed model extensions,
and integrate them as 0.2.4. G-theory, latent measurement and external-feature
clustering retain distinct quantities and interpretations, even when applied
to the same assessment.

## Model scope

| Model or estimator | Available in the development version | Important boundary |
| --- | --- | --- |
| RSM/PCM | MML/JML fitting and established diagnostics, scoring, reporting and calibration workflows. | Population, anchor, category and interaction choices affect the meaning and availability of results. |
| One-slope-family GPCM | MML permits separate slope and step owners; JML uses a shared owner. Scoped MML intervals, profiles, comparisons and portable MML/JML EAP scoring are implemented. | Slopes multiply the complete adjacent-category predictor. Formal JML structural intervals and portable ML/WLE are unavailable. One-family GPCM does not yet have its own public EM implementation. |
| Two-slope-family GPCM / GMFRM | Explicit ordered facet roles, fixed-standard-normal MML--EM, summaries, conditional curves, experimental component-slope intervals, descriptive response diagnostics and saved reports. | Exactly two non-Person facets, no anchors or population covariates, and one ability dimension. Curve/location intervals, model ranking, ordinary fit/bias tests, Wright/Pathway maps and new-Person/portable scoring remain unavailable. Statistical qualification is unfinished. |
| Corrected GPCM JML | Explicit correction order, shared slope/step owner, adjusted-equation fitting, summaries, descriptive residuals and conditional new-Person/portable EAP. | Experimental; residual bias may remain. No automatic order selection, formal structural intervals, corrected Person ML/WLE or corrected RSM/PCM implementation. Local root standard errors are not qualified confidence intervals. |
| Random-rater and testlet extensions | Separate shared-rater and Person-local testlet RSMs, with scoped scoring and descriptive comparisons. | These are distinct models with limited uncertainty support, not a combined random-effects GMFRM. |

GMFRM denotes a generalization of many-facet measurement; unequal
discrimination is not strict equal-discrimination Rasch measurement. The
estimation core is frequentist. EAP scoring conditional on calibration does
not make the calibration model fully Bayesian.

### GPCM: specific restrictions and their exit conditions

The two-family route still has a declared slope product and identification
scheme. Removing a restriction requires a defined response equation, an
identified scale, matching uncertainty and useful output. It cannot be achieved
by changing the label used for the model.

Profiles are optional sensitivity analyses; better coverage than Wald
intervals has not been established for the current two-family procedure.
Numerical convergence, accurate integration and sampling performance are
separate requirements. Small or weakly determined slopes can affect all three.

Saved fitted objects, portable calibration and new-Person scoring are different
capabilities. Conditional scoring intervals omit calibration uncertainty unless
explicitly stated otherwise. A saved report does not add a missing scoring model.

## Generalizability theory

`mfrm_multivariate_gstudy()` and `mfrm_multivariate_d_study()` support one or
two named random facets, crossed or with one nested within the other while
Persons are crossed. Score components are fixed. ANOVA handles complete
balanced data; MINQUE(0) handles identifiable incomplete or unequal sources.

D-studies project complete balanced future scenarios with the supported
structure, weighted composites or signed score differences. Sparse source
data require an explicit future plan; these projections do not estimate the
reliability of an arbitrary sparse future roster. Negative or indefinite
component estimates remain visible, and availability is assessed separately
for each metric.

`mfrm_multivariate_d_compare()` supplies approximate paired-delta intervals
for prespecified plan differences with two crossed facets under an explicit
normal-random-effects assumption. Nonnormal-robust, nested and simultaneous
intervals, adaptive weight selection and unequal future allocations remain
outside this scope.

Tables and 2D plots should make tasks, raters, weights, workload and uncertainty
understandable. A multivariate score does not require a 3D display. These
observed-score analyses do not estimate latent MFRM reliability or pass/fail
classification accuracy, and missing-row omission does not correct selective
assignment or nonresponse.

## Rater feedback across application areas

Feedback connects exposure and overlap, severity with its reference and
available uncertainty, category use, fit and selected unexpected ratings.
Individual sheets currently accept native additive RSM/PCM fits. GPCM,
interaction, imported, random-rater and testlet models require their own
supported reports; exporting a fitted object does not provide an individual
sheet for these models.

Severity, discrimination, inconsistency and differential functioning answer
different questions. None alone measures assessor competence or establishes
that training, exclusion or rubric revision will help. Useful feedback keeps
missing results visible and protects other recipients' information.

The next integration work must preserve these meanings from summary and
figure through report and reopening. Beginner-facing guidance should explain
what to review and what the result cannot establish. Clear writing and author
review do not replace evidence from actual novice readers.

## External features, grouping, and missing values

Mixed-feature PAM and hierarchical clustering, numeric PCA/k-means,
dendrograms, profiles and setting comparisons are implemented. Persons,
raters and tasks are grouped separately from their own feature tables and
joined to ratings by ID. Groups are descriptive, not latent ability levels,
causal effects or rater-quality classes.

Feature-imputation comparisons preserve the supplied imputation model and
eligible cells. Co-membership across completions is sensitivity to that model,
not Rubin pooling or sampling stability. Assigned-response imputation review,
fitting and eligible pooling are separate workflows. Unassigned ratings are
not imputed; observed scores and the planned assignment remain intact.
Missingness assumptions need substantive justification, and current support
does not imply extended-model imputation or pooled Person scores.

## Rater assignment and anchors

There is no single recommended percentage of common ratings or anchors.
Assessment teams need guidance for complete and incomplete rating designs,
including direct anchors, group anchors, and unanchored linking.

The relevant questions include:

1. What contrasts are identified in complete versus connected
   incomplete assignments, and how much information supports them?
2. Do all-rater common Persons, rotating panels or random subsets cover the
   ability range and provide useful overlap at a comparable rating budget?
3. What changes when bridges weaken or disappear, or when the linked groups
   differ in ability distribution?
4. Which values are fixed externally, and is uncertainty conditional on those
   values or intended to include their calibration uncertainty?

Observed common Persons connect data; they are not automatically fixed ability
anchors. Connectivity alone does not establish slope identification or adequate
precision. Evidence from one allocation pattern will not be generalized to all
sparse designs. Planned nonassignment, missing assigned ratings and selective
nonresponse remain distinct. The two-family fitter currently has no anchor
support; anchor findings from simpler models do not establish that support.

## Random-effects MFRM and testlet covariance

Shared-rater effects and Person-local testlet effects use different sharing
units and prediction populations. Existing implementations must retain those
distinctions when compared with ordinary MFRM on matched data. Ordinary fit
cutoffs or regular chi-square variance tests cannot be transferred automatically.

Task-versus-criterion planning and task-specific dependence are useful future
questions. A local variance alone does not diagnose halo, impose equal task
weights or supply a G-theory reliability coefficient. Combining effects or
adding random slopes requires a separately defined and evaluated model.

## One-ability checks and residual exploration

A one-ability model can be investigated using substantive structure, residual
patterns, conditional comparisons and appropriately calibrated simulation.
Residual PCA or a residual network can reveal patterns to investigate; neither
alone proves the number of traits. Sparse pair exposure, shared effects and
model-fitting uncertainty affect interpretation. Descriptive residuals do not
automatically provide calibrated dimensionality tests.

Native multidimensional MFRM remains deferred. It is not necessary to implement
every alternative model before investigating a one-ability assumption, although
formal model comparison requires explicitly compatible models and targets.

## External comparison

TAM, ConQuest, sirt and GENOVA are references for explicitly matched models,
scales and quantities. Agreement in conditional probabilities, fixed-calibration
scoring or a variance formula does not establish free-estimator equivalence,
interval coverage or suitability for another design. Reproducing all features
of another package is not the goal. Core analysis and beginner examples should
work without optional external software.

## Before CRAN submission: interface and GPCM review

### First integration work package: API names, arguments and help

Finish one recommended route per task through existing functions and result
classes. Explain essential inputs and consequential defaults before expert
controls, including what omission or `NULL` changes. Keep ability scoring
separate from response prediction and distinguish different uncertainty targets.

The recommended PAM and imputation-review names have compatible older aliases.
Keep established argument spellings where a cosmetic rename would add
ambiguity. Standard `summary()`, `plot()` and `confint()` conventions remain
useful. Any deprecation needs a specific replacement and a migration path.

Help, examples, returned tables and plots must agree about model support.
Figures should use readable labels, non-color distinctions, exact plotted data
and usable title/annotation controls. Reports and saved-plot replay must not
silently start expensive fitting or interval calculations.

## Milestones and the end of this development cycle

Completion means that the agreed analyses work within their declared scope,
have evidence appropriate to their claims, and remain interpretable through
plots, reports and saved reuse. The unfinished joint-slope and corrected-JML
work cannot be declared complete merely by adding a limitation to the help.
A change to the agreed release scope requires an explicit decision.

Final checks must concern the assembled source and its documentation. Local
completion, repository publication, CRAN submission and CRAN acceptance are
different states. Completion of 0.2.4 does not mean every future model or a
universal accuracy or capacity guarantee has been delivered.

## Post-release priorities

After the integrated release, choose work from demonstrated assessment needs:

- Improve adoption, individual feedback, accessibility and calibration reuse.
- Extend G/D planning for a specified unsupported structure or feasible roster.
- Investigate calibrated screening or dependence when it changes a review decision.
- Address missing-response sensitivity, feature stability or new-entity assignment
  with explicit inference or prediction targets.
- Improve measured bottlenecks for actual workloads while preserving results.
- Consider additional slope structures, multidimensional models or process models
  only after defining their constructs, identification and useful outputs.

Broader structures are not automatically assigned to 0.2.5. Maintenance of
supported analyses and compatibility continues alongside selected extensions.

## Milestones after 0.2.4

Each selected extension should connect a user question to a defined method,
appropriate evaluation, a complete usable workflow and a maintained release.
An inconclusive result can justify revising the approach or retaining the
existing method; it does not automatically require a larger experiment.

## Compatibility principles

- Preserve model, scale, categories, anchors, score identity and uncertainty
  meaning across saved results, tables, figures and exports.
- Keep valid older calls and saved objects compatible; explain changes and
  migration when results or formats must change.
- Keep examples usable, plots in English and unavailable results visible.
- Keep implementation history and operational decisions in maintainer material,
  with analysis guidance in help and user-visible changes in NEWS.

Maintainers should use the [internal work plan](inst/validation/internal-roadmap-0.2.4.md)
for execution order and evidence requirements.
