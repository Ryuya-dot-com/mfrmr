# mfrmr roadmap

`mfrmr` connects three tasks in performance assessment:

1. **Measurement models:** estimate person ability while accounting for rater severity, task or criterion difficulty, category thresholds, and supported discrimination or dependence structures.
2. **G-theory assessment planning:** separate observed-score variance components in a `G-Study` and project reliability, generalizability (`G`), dependability (`Phi`), and standard errors across candidate rating designs in a `D-Study`.
3. **Rater feedback and decision support:** turn agreement, fit, residual, network, bias/DFF, and conditional classification analyses into structured, reviewable evidence without automating high-stakes rater exclusion or causal fairness claims.

The goal is a reproducible route from a rating design to defensible scores, feedback and future assessment plans. The package remains a single package, with optional external tools for specialized estimation and secondary analysis. This roadmap distinguishes implemented development features, release conditions and research candidates. For changes already implemented in `0.3.0`, see [NEWS](NEWS.md) and `help("mfrmr_api_migration_030")`.

Users can choose measurement, planning and feedback independently.
Dataset-specific preparation and downstream survey analysis can use separate
scripts or optional articles; they need not share one mfrmr entry point.

The core analysis entries are `fit_mfrm()`, `diagnose_mfrm()`, `mfrm_g_study()`
and `mfrm_d_study()`. Keep their input roles, result-object meanings and
supported `summary()`, `plot()` and `confint()` workflows stable within the
0.3 series. `describe_mfrm_data()` reviews inputs; `mfrm_results()` and
`mfrm_report()` organize supported results. The default `mfrmr_output_guide()`
connects these routes; specialist tools remain available through an explicit
scope. Model-specific support and uncertainty restrictions still apply.

From a native fit, `mfrm_report(fit, type = ...)` selects specification,
data quality, category, facet-statistics, precision, checklist and reference
review components. Saved bias estimates also support interaction, recalibration
history and pairwise reports; saved DFF analyses support narrative reports.
Optimization replay remains a distinct report type. Collected results
continue to use `mfrm_report(res)` with their supported styles and formats.

## What should become easier in 0.3.0?

The intended benefit is a connected assessment workflow: start with a rating
table, understand the design and diagnostics, and use the results to prepare
feedback or compare a future rating plan. The
[development tour source](vignettes/articles/mfrmr.Rmd)
connects this sequence with data, figures, explanations and a saved analysis.
The release work includes checking the complete example and its corresponding
website version; a working section alone does not establish the whole workflow.
The [ICNALE essay-rating example](vignettes/articles/mfrmr-icnale-caf.Rmd)
extends that sequence to a licensed external workbook obtained by the reader.
It keeps fixed CAF dimensions distinct from sampled tasks and separates
latent-scale calibration from observed-score planning. The repository provides
the workflow code without distributing corpus data or individual results.

| Your question | The workflow should help you do this |
| --- | --- |
| Can I compare people rated by different panels? | Inspect who rated whom, distinguish missing assignments from zero scores, and review model identification. A connected graph alone is insufficient. |
| What should I discuss with a rater? | Read severity together with consistency, exposure and uncertainty; prepare a reviewable report without automatic rater exclusion. |
| Should I add raters or tasks? | Compare precision with total ratings, rater workload and resource limits. Known calibrated panels use conditional information; sampled future rater/task populations use the separate observed-score G/Phi route. Neither supplies an automatic optimum. |
| Can I reproduce this result later? | Save the analysis, diagnostics and numerical plot data together, and reload them for reporting. |

[TAM](https://alexanderrobitzsch.github.io/TAM/reference/tam.mml.html),
[mirt](https://philchalmers.github.io/mirt/docs/reference/mixedmirt.html),
[sirt](https://alexanderrobitzsch.github.io/sirt/reference/rm.facets.html) or
FACETS can remain the right choice for a particular model or established
workflow. Their capabilities already include flexible latent models,
information curves and, in applicable packages, rater facets and discrimination.
mfrmr's aim is to connect rating assignments, interpretable estimates, assessment
planning and reviewable rater feedback through reusable results. This is a
workflow goal, not a claim of a new information formula or superior estimation.
Beginner comprehension and successful use still need evaluation.

<a id="release-completion-milestones"></a>

## Milestones and dependencies

“Implemented” means available in development source within a documented scope.
It does not mean released, or validated for every rating design. The sequence
below describes outcomes and completion conditions rather than calendar promises.
Existing numerical and saved-result evidence remains useful when the relevant
code, inputs and settings have not changed.

| Stage | What users should be able to do | Remaining completion condition |
| --- | --- | --- |
| **0.2.4.1 — repair the published 0.2.4** | Use corrected diagnostics, boundary reporting and figures through the existing interface | Validate the repair-only distribution, including BLAS-portable tests, mice compatibility and applicable existing-feature fixes. Evaluate Windows results and total check time before publication. |
| **0.3.0 — interpret estimates and uncertainty** | Identify the estimate, its scale, whether an interval is available, and the reason for a limitation | Reconcile final outputs, help and saved results for the supported model/estimator combinations. Retain valid point estimates when only the interval is unavailable. Distinguish finite estimates, limiting fits, unidentified quantities and numerical failure. |
| **0.3.0 — compare rating plans** | Compare additional raters, tasks or assignments against precision and operational burden | Complete the two planning routes below, preserving every declared candidate, assumptions, missing costs and inconclusive comparisons through plots and saved reports. |
| **0.3.0 — prepare rater feedback** | Trace a diagnostic flag to the relevant ratings and decide what warrants substantive review | Connect severity, consistency, exposure, missingness and uncertainty without automatic rater exclusion. Verify that unavailable diagnostics remain distinguishable from reassuring results. |
| **0.3.0 — navigate and reproduce an analysis** | Start from a short help example, find specialist conditions, customize a figure, and reload results | Align migration examples, supported saved objects, numerical plot data and reports. Check the complete affected example and website interactions; keep essential interpretation available offline. |
| **0.3.0 — release a consistent package and website** | Follow documentation that matches the installed version | Once the preceding scope is settled, validate the final archive in the required environments, evaluate check duration and remaining issues, and verify the matching website and distribution. |
| **0.3.x — selected extensions and stronger guidance** | Use additional explanatory or linked models, specify [selected step constraints](#step-constraints), or make better-supported design recommendations | Select a concrete missing capability or recommendation. Establish its target, identifiable design and required evidence before adding it. These are separate adoption decisions, not one required bundle. |
| **0.4.x and later — selected new model families** | Answer a question that the existing models or an external workflow cannot adequately address | Select a model branch, then establish identification, independent numerical checks, computational feasibility and evidence for its intended interpretation. |

Maintenance corrections come first and do not wait for a new model, a redesigned
interface or a general sample-size guideline. The 0.3.0 estimation conditions
define the scope of planning and feedback; documentation and saved-result work
can proceed alongside them. Final packaging follows integration of that scope.
An error in supported functionality must be corrected. A broader claim that
lacks evidence remains explicitly limited or moves to later research.

The immediate design priority is precision versus burden. Keep these routes
separate:

| Rating decision | Existing route | What the comparison can support |
| --- | --- | --- |
| Add or reassign **known calibrated** rater/task levels for one Person's plan | `compute_information(rating_plan = ...)`, `plot()` and `plot_data()` | Conditional information over a declared ability range, with rating counts and workload assumptions. This does not include calibration uncertainty or predict an uncalibrated rater. |
| Change the number of raters/tasks **sampled from a declared future population** | G-Study, supported D-Study comparisons and `recommend_mfrm_design()` | Observed-score G/Phi/SEM, resource limits and supported paired differences. Increasing future counts does not add information to the original G-Study. |

In either workflow, retain all proposed plans, unavailable precision and unknown costs.
Total cohort workload and each rater's workload are different quantities.
Adding raters does not by itself redistribute existing assignments. Neither
route establishes an automatic optimum or a universal minimum sample size.
The [development visual tour](vignettes/articles/mfrmr.Rmd) connects the
calculation, interpretation and saving steps.

Later research starts from a decision that current evidence cannot support:

- **Design guidance:** use the existing small studies to select informative
  conditions, then confirm the proposed recommendation independently. Distinguish
  Persons, raters, tasks, overlap and ratings per Person; retain failures and
  Monte Carlo uncertainty. If the evidence is insufficient, provide conditional
  guidance rather than a universal rule.
- **Explanatory and linked models:** identify the owner of each covariate,
  scale constraint and uncertainty target before extending estimation. Extensions
  to Person latent regression, rater-experience models, linking uncertainty and mixed
  category sets require separate decisions.
- **New model families:** select one branch for a concrete need. An existing
  external-software route may be sufficient; model-name count is not a goal.

Formative evaluation can use the current estimation, planning and feedback
workflows without waiting for another model. Observe whether intended readers
can find the relevant result, explain its limits and complete the task. Until
that is evaluated, shorter help and successful examples are editorial and
technical improvements, not demonstrated gains in comprehension.
Dataset tutorials, including IEA and survey-analysis recipes, remain optional
applications with no assigned package-release milestone.

## Starting from the published 0.2.4 release

CRAN published **0.2.4 on 2026-10-30**. It is the stable reference for this
roadmap; `0.2.4.9000` is development toward **0.3.0**, not a replacement
already available from CRAN.

Repair-only release **0.2.4.1** is being prepared from published 0.2.4 before
the 0.3.0 interface transition. It addresses BLAS-portable tests, mice
compatibility and verified existing-feature defects while retaining public
entry points, numerical engines and supported saved-model meanings. Corrections
to availability or reporting state their conditions and effects in NEWS.
The GitHub 0.2.5 maintenance snapshot remains separate. New model options,
interval procedures and interface redesigns remain in the development series.

For figures, 0.2.4.1 retains base graphics and optional `as_ggplot()` conversion.
Maintenance corrections reject conflicting Person group labels, align group-density
exclusions with the main Wright map, and distinguish group names from facet
legend entries. Invalid group specifications are rejected; groups too small for a density
curve are omitted with an explanation when no curve can be drawn. These corrections do not require the new ggplot
return contract or a change to the default visual theme.

| Area | Published 0.2.4 | Intended change in 0.3.0 |
| --- | --- | --- |
| Public entry points | 189 exports | 156 exports: consolidate 35 names into shared routes and add `facets_guide()` / `import_irt_fit()`. Follow the migration guide for exact replacements. |
| Two-family GPCM | Experimental two-facet MML | Choose two slope facets among fixed additive facets, with separate step ownership and a named slope reference; retain experimental inference limits. |
| Model specification | Flat `fit_mfrm()` arguments | Group advanced model choices in `spec` and numerical settings in `control`, with validated legacy calls. |
| Figures and saved results | Base graphics, saved plot payloads and optional `as_ggplot()` conversion | Return editable `ggplot` objects consistently, with a restrained shared theme; use `plot_data()` for numerical payloads. Preserve supported saved-result classes and methods. |
| Bayesian workflows | Export and posterior-summary review | Direct data/spec export, optional CmdStanR execution, joint-draw contrasts and new-Person scoring with separate predictive-precision checks. |
| Assessment planning | G-Study / D-Study and paired contrasts | Review a declared finite set of plans against costs, limits and targets, preserving pointwise uncertainty and avoiding an automatic optimum claim. |
| Learning and reference | Extensive reference help and tutorials | A visual entry page, five core offline tutorials, specialist website articles and shorter task-focused reference navigation. |

Reliability plots and `compute_information()` already exist in 0.2.4; they
are not new statistical capabilities in 0.3.0. Improve their visibility and
interpretation: distinguish Person/rater separation, observed agreement,
G/Phi and ability-dependent information. By default, the information total uses
all observed rating exposures. In 0.3.0, `compute_information(rating_plan = ...)`
also evaluates a declared plan for one Person using fitted facet levels and
independent rating counts. It supports converged additive MML RSM, PCM and
one-family GPCM calibrations within its documented boundary restrictions.
Plans retain their assignments, counts and fixed-calibration interpretation
when plotted or saved. GPCM comparisons using working coordinates without
primary slope estimates remain explicitly exploratory. This comparison does not propagate calibration
uncertainty, predict an uncalibrated rater, supply EAP uncertainty or choose an
optimal allocation. G/Phi comparisons remain a separate observed-score analysis.

## 0.3.0: migration and release conditions

The capabilities in the comparison table are implemented in the development
source. They are not yet a CRAN release. The next interface-changing release is
**0.3.0** because
consolidating public names and changing `plot()` returns require script updates:

- Replace retired entry points using the `help("mfrmr_api_migration_030")`.
- Extract plotted numerical values with `plot_data()`; `plot()` returns a
  `ggplot` object. Supported saved `0.2.x` result classes and legacy plot
  payloads retain their documented methods.
- Use complete argument names with `fit_mfrm()` and `do.call()`. Only the
  first four positional arguments retain their old positions. Abbreviations
  for names now passed through `...` are not supported; the migration guide
  gives before/after calls.

The 0.3.0 default figures use a white background, restrained grids and spacing
suited to papers, presentations and screen reading. Existing presets provide
the initial appearance; ordinary ggplot edits control finer details. Save the
edited ggplot to retain those edits: `plot_data()` contains the original
statistical payload and settings. Explicitly sized text layers may need their
own adjustments. Representative exports and saved-object checks support this
design; they do not establish readability at every size or improved user
comprehension.

Wright-map group displays in 0.3.0 additionally provide a shared adjustable
bandwidth, Person-level rug marks, empirical CDF values and exclusion counts.
They describe fitted Person estimates, not a latent population density or a
DIF/DFF test. These display extensions are separate from the maintenance fixes.

Interface changes and faster numerical kernels retain the documented
statistical targets, quadrature rules, convergence criteria and independent
checks. They do not establish finite-sample inference validity for additional
models or rating designs. Shared `spec` lists remain subject to each function's
scope, including the export limits below.

Alternative response equations and later model candidates below are outside
`0.3.0`; supported-scope errors and misleading claims still require correction.

## Measurement models: current limits and extension order

Model choice and estimation method are separate decisions. Current native support
in `0.2.4.9000` is bounded as follows; consult `help("mfrmr_gpcm_scope")` and
`help("fit_mfrm_technical_details")` for the complete conditions.

| Response model | Native estimation paths | Boundary that extensions must preserve |
| --- | --- | --- |
| Ordinary RSM / PCM | MML, ordinary JML and CML within their documented scopes; a separate Jeffreys-penalized JML path | Fixed versus estimated ability populations change the MML model. Numerical admissibility alone does not validate small-sample intervals. |
| One-family GPCM, shared step and slope facet | MML, ordinary JML and experimental profile-score-adjusted JML | The adjustment is not a general small-sample correction for every model; its root-variation SE does not establish structural-parameter interval coverage. |
| One-family GPCM, separate step and slope facets | MML | JML and its profile-score adjustment are not supported for this specification. |
| Two-family GPCM | Experimental fixed-grid EM or adaptive-direct MML | Two named slope facets among the declared fixed additive facets; step ownership, the noncentered location facet and the geometric-mean-one slope reference are separately specified. Ability remains fixed to N(0,1). |

With few informative ratings per Person, ordinary JML can retain
incidental-parameter bias even as the number of Persons increases. The number
of categories or fitted steps alone does not determine that bias. `mfrmr` does
not apply a universal test-length multiplier. RSM/PCM CML, population-based
MML, Jeffreys-penalized JML and the restricted GPCM profile-score adjustment
have different assumptions and uncertainty targets; none is a blanket guarantee
of bias removal. The stability guide will evaluate exposure and category use
separately from Person count, including residual bias and failed estimates.

The two-family GPCM implementation retains the current response equation, in which
both slope factors multiply the whole ability-minus-location-and-step expression.
For example, Task and Rater can own slopes while Criterion owns steps. Use
`slope_reference` to name the slope family with geometric mean one and
`noncenter_facet` to name the sole uncentered location facet. Additional Occasion
or Venue effects remain fixed additive effects, not extra ability dimensions.
The old two-facet defaults and saved fits retain their meaning. Extended portable
calibrations use format 7; the original two-facet structure retains format 6.

Three- and five-facet calculations and representative workflows are checked.
These checks do not guarantee identification, convergence or interval coverage
for every design. In particular, an optimizer can converge while the integration
checks refuse intervals or portable scoring. Extended-role Stan export from an
existing fit supports posterior reload, contrasts, plots and reports. Two-family
simulation, direct data/spec export and new-Person posterior scoring remain
unsupported. Changing the slope reference with fresh independent priors changes
the Bayesian model. This extension is included in **0.3.0**. Its point-estimation review separates
identification, numerical accuracy and sampling error; adding support does not
remove experimental interval restrictions.
Point estimates now carry separate numerical and boundary status in summaries
and reports. A converged value at a chosen integration rule is distinguished
from a solution with automatic integration and score checks; neither is a guarantee
of a unique global maximum or adequate small-sample accuracy.

For supported all-low/all-high boundary cases, the remaining targets can be
estimated through a separate limiting-likelihood fit, including models with
rater-owned steps or a criterion without slopes. One affected facet outside
the reference slope family can be reduced when at least two of its levels and
all other facet levels remain. Unidentified slopes or free steps of removed
levels are distinguished from remaining estimates and binary steps fixed at zero.
These point estimates do not qualify ordinary full-model intervals.
For ordinary finite fits, experimental step-offset intervals use
`confint(fit, parm = "steps")`, with the full joint covariance and within-level
sum-zero constraints. They retain numerical checks and unqualified coverage;
binary steps fixed at zero have no inferential interval.

Per-level rating-design tables separate distinct persons, rating rows,
per-person exposure, marginal facet crossings and category use. Full-model
and limiting-fit counts are labelled separately. These descriptions help
inspect the data behind each estimate; they are not sample-size guarantees.

A bounded three-facet study now separates Person count from ratings per Person.
All numerical checks passed, but the 60-Person, four-rating Task-slope interval
covered its true value in 183/200 replications. The design, Monte Carlo
uncertainty and precision results are described in the [development GPCM guide](https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-gpcm-scope.html#three-facets-person-count-and-rating-exposure). They do not establish a general minimum sample
size or remove experimental interval restrictions. The number of levels of
each facet was fixed at two.

Point-estimation checks address identification, starting values, integration,
curvature and sampling error separately. A positive local Hessian is not proof
of a unique global maximum. Supported point estimates remain usable when the
corresponding interval is unqualified or unavailable. Extension decisions must
preserve this distinction throughout prediction, reporting and saved results.

Two-family JML, its bias correction, alternative slope placement and the
[Uto (2021)](https://doi.org/10.1007/s41237-021-00144-w) response equation are
separate candidates. They require their own identification and estimation
contracts. A Bayesian implementation must specify the link coefficient, ability
scale and constrained prior density; reproducing the published appendix and
adopting a different symmetric prior are distinct choices. A logistic link with
coefficient 1.7 is not an exact normal-ogive link. Metric conversion must preserve
probabilities and transform covariance and priors consistently.

These candidates are considered alongside ordinary-model needs: mixed binary
and polytomous category sets, rubric differences, and uncertainty in linked
calibrations. Current native fits use one declared category range; a step facet
does not provide facet-specific category support. The choice to extend `mfrmr`
or use a supported TAM/ConQuest workflow depends on the required model and
outputs, not a goal of reproducing every external modeling option.

<a id="step-constraints"></a>

## Step constraints: fixed values and partial sharing

This planned **0.3.x** extension would let users fix selected step offsets or
share selected transitions across criteria while estimating the remaining
steps separately. For example, two criteria could share only the transition
from category 0 to 1. Common RSM steps and facet-specific PCM steps already
exist; this plan concerns additional constraints, not a new estimation entry.

| Priority | Planned capability | Scope |
| --- | --- | --- |
| First | Fixed step values and prespecified equalities | Extend the existing `fit_mfrm()` specification, starting with RSM/PCM on one shared category range. Public option names and formats remain to be designed. |
| Next | Reusable constraint groups | Simplify repeated declarations of the same supported constraints; first distinguish needs already met by existing step ownership. |
| Later candidate | General linear constraints or design-matrix input | Assess separately after the bounded cases work through the supported analysis and reporting routes. |

Initial targets are centered step offsets. A location-plus-step threshold has
a different meaning and requires separate support. Fixed values and equalities
are substantive assumptions; they do not establish category invariance from
the data. Constraints must be consistent with centering and an identifiable
model. Shared offsets do not permit different category ranges in this scope.

Completion requires consistent estimation, parameter counts, uncertainty,
prediction, diagnostics, plots, reports and saved-result reuse. Each estimator,
GPCM extension, calibration/export and simulation route needs an explicit
support decision; unsupported combinations must fail clearly. Existing defaults
and saved fits retain their meanings. This extension is not a prerequisite for
maintenance releases or 0.3.0 release.

## Current Bayesian export scope and 0.3.x extensions

| Capability | Native `mfrmr` path | Stan / brms export in `0.2.4.9000` | Planned extension |
| --- | --- | --- | --- |
| Ordinary RSM / PCM | Supported within documented MML, JML, and CML scopes | Direct `data` + `spec` or `mfrm_fit` export (`stan` and `brms`, plus optional `run_cmdstan = TRUE` in `stan`) with fixed $\mathcal{N}(0,1)$ ability population and permitted fixed anchors / group means; checksum-bound joint-draw contrasts, arbitrary credible levels, out-of-sample new-Person scoring via `predict()`, and reporting via `read_mfrm_posterior()` | Connect posterior-predictive rating-plan comparisons where applicable |
| One-family GPCM | MML; JML only with a shared step/slope facet | Direct `data` + `spec` or `mfrm_fit` export: estimated intercept-only normal population (`stan`, with optional `run_cmdstan = TRUE`) or fixed $\mathcal{N}(0,1)$ population (`stan` and `brms`), with permitted fixed anchors / group means; checksum-bound joint-draw contrasts, arbitrary credible levels, out-of-sample new-Person scoring via `predict()`, and reporting via `read_mfrm_posterior()` | Connect posterior-predictive rating-plan comparisons where applicable |
| Two-family GPCM | Experimental MML within the named-role scope above | Fixed-population Stan export from an explicit `mfrm_fit`, including additional fixed facets and separate step/location roles; named roles and the prior reference follow posterior reload, contrasts, intervals, plots and reports. Direct data/spec, brms and new-Person posterior scoring remain unsupported | Integrate only explicitly supported model extensions; assess interval validity separately from computational support |
| Person-level latent regression | Conditional-normal MML via `population_formula` | Rejected explicitly | Bounded `0.3.x` extension of `export_mfrm_model()` |
| Non-Person facet interactions | Supported two-way fixed effects in RSM/PCM via `facet_interactions` | Rejected explicitly | Bounded `0.3.x` extension of `export_mfrm_model()` |

Covariate interactions inside `population_formula` and rating-facet interactions in `facet_interactions` represent different statistical terms with different identification constraints; they will be specified and validated separately rather than merged. Exported Bayesian models share the measurement model's response equation and add explicit priors; their posterior summaries and credible intervals are not native MML point estimates, Wald intervals, or likelihood-ratio tests. See `help("export_mfrm_model")`, `help("read_mfrm_posterior")`, and `help("predict.mfrm_posterior_summary")`.

<a id="plausible-values-existing-draws-and-later-secondary-analysis-support"></a>

## Plausible values and optional survey-analysis integration

`sample_mfrm_plausible_values()` already returns approximate Person posterior
draws in `$values`; it remains available in 0.3.0. Supported MML fits use the
fitted population, including Person covariates for latent regression. Calibration
and population parameters stay fixed. JML-source draws add an explicit scoring
prior after calibration; they are not a population distribution estimated by JML.
These draws are neither individual true scores nor automatic validation of
downstream regressions. See `help("sample_mfrm_plausible_values")` for model scope,
scoring-prior choices, integration checks and saved-result reuse.

mfrmr is responsible for correct scoring, labelled Person/draw values, the
calibration and scoring basis, numerical-review information and saved-result
reuse. Existing result objects and the `plausible_values` arguments of
`export_mfrm_bundle()` and `build_mfrm_replay_script()` provide a general
handoff. Improvements to posterior scoring or conditioning require their own
measurement justification, independent of a particular survey package.

The [PV application](vignettes/articles/application-plausible-values.Rmd)
shows extraction, inspection and saving, with the conditions for a separate
downstream analysis. This does not add a dedicated adapter, dependency or
release milestone. A convenience API needs a recurring, generalizable problem
that existing outputs cannot reasonably solve. Fixed-calibration draws retain
their stated uncertainty limits regardless of which downstream tool is used.

## Explanatory models: covariate ownership before more options

Existing Person-level `population_formula` and `person_data` support latent
regression within their documented MML scope. For one essay or speech per
Person, a Person-constant language feature can enter that population model.
The fitted total ability and the residual after conditioning are different
quantities; the residual is not automatically a fairer score.

| Assessment question | Existing basis or proposed extension | Required distinction |
| --- | --- | --- |
| Do vocabulary, syntax or speaking speed relate to performance? | Existing Person latent regression for Person-constant features; validate a reproducible applied example | One speech cannot separate stable ability from a unique topic or occasion. Feature extraction, missingness and assignment matter. |
| Does rater experience relate to severity? | Candidate 0.3.x extension of the random-rater RSM with a conditional severity mean | Experience constant within a rater is confounded with unrestricted fixed rater effects. A conditional random-effect model and a finite-panel secondary contrast answer different questions. |
| Does a feature matter differently across criteria or performances? | Separately specified response-side and within-/between-Person extensions | Repeated performances are not independent Persons. Continuous covariate effects, categorical facet interactions and GPCM slopes are distinct terms. |

Start a joint extension with a bounded RSM specification and independent
probability/likelihood checks, then evaluate realistic assignment and small-rater
conditions. PCM, performance-level effects and additional interactions are
separate acceptance decisions. Existing TAM/ConQuest design and regression
facilities provide comparison routes; mfrmr's intended contribution is a clear,
validated path from model ownership to scores, uncertainty and reports. A general
SEM/GLMM engine is outside this plan. These new joint models do not block 0.3.0.
See the methodological basis in [Mariano & Junker (2007)](https://www.stat.cmu.edu/~brian/trs/mariano-junker-jebs-2007.pdf)
and the [existing ordinal/SEM comparison](vignettes/articles/mfrmr.Rmd).

## Assessment planning, rater assignment, and feedback principles

### G-theory planning and operational design comparison
Univariate and multivariate `G-Study` and `D-Study` workflows, paired multivariate D-study comparisons, and design simulations remain first-class capabilities that do not require Bayesian software. Classical observed-score generalizability and IRT/MFRM latent-scale precision answer complementary questions and keep distinct labels, variance denominators, and interval assumptions. Beyond the finite feasible plan comparison in `0.3.0`, broader sparse future rosters, adaptive rater allocation, and post-selection plan adjustments remain separate research-backed extensions so single-plan intervals are never overstated as optimal-design guarantees. See `help("mfrmr_methods_reference")`, `help("mfrmr_workflow_methods")`, and the `vignette("mfrmr-gtheory", package = "mfrmr")`.

Existing interval choices include scoped F/MLS methods, conservative
`mean_square_region` bounds for balanced designs, and experimental REML profiles.
Plan differences can use the documented paired-delta, shared-region or profile
routes within their respective scopes. These methods have different assumptions
and coverage qualifications; a smaller SE does not establish a more reliable
interval. See `help("confint.mfrm_multivariate_d_study")` and
`help("mfrm_d_study_comparison")` for choosing a supported route.

Improving interval calibration for small rater pools is a separate research
question; an MFRM-parameter coverage study cannot answer it.

### Rater assignment, linking, and anchors
Guidance and diagnostics for complete and incomplete rating networks distinguish direct parameter anchors, group-mean anchors, and unanchored common-person/common-rater linking. No single percentage of common ratings guarantees a stable common scale across designs: graph connectivity, overlap geometry, anchor fit, and empirical drift all matter. Fixed anchors impose exact scale constraints and do not by themselves establish invariance or propagate prior calibration uncertainty. A scoped direct RSM/PCM MML route can estimate the receiving population mean and variance and add supplied independent-source anchor covariance, using fixed or adaptive integration. This route is intercept-only and excludes groups/interactions. Shared-sample propagation and uncertainty in differences involving the source population mean remain separate from this implemented route. Cohort shifts, panel-wide severity shifts, and individual rater drift require identifiable comparisons; broader support remains a `0.3.x` and later task. See the [linking and DFF guide](vignettes/articles/mfrmr-linking-and-dff.Rmd) and `help("mfrm_facet_intervals")`.

The [sample-size stability guide](vignettes/articles/mfrmr-facet-intervals.Rmd#sample-size-stability)
will develop in three stages:

1. **Map the decision and existing evidence.** Distinguish Persons, raters,
   tasks, linking performances and ratings per Person. Name the target: ability,
   a severity contrast, a cohort difference, population variance or screening
   accuracy. Descriptive count bands are not adequacy thresholds.
2. **Explore point-estimation sensitivity.** Reuse existing studies and vary
   Person distributions, fixed-facet spread, steps, rater-by-criterion bias,
   category use and assignment in small, realistic writing/speaking scenarios.
   Distinguish model misspecification from error under the fitted model; retain
   failures and numerical-review states. Facet types, level counts and free
   parameters are different measures of complexity.
3. **Confirm selected recommendations.** Evaluate bias/RMSE, interval
   availability, width and coverage with Monte Carlo uncertainty. For diagnostics,
   assess false flags and detection; for reliability, name the coefficient and
   population target. Use independent confirmation for selected design rules,
   not a universal minimum N derived from a small exploratory study.

The same fits can support these questions where their saved information is
sufficient. They cannot turn severity-interval coverage into evidence about
Infit detection or G/Phi. Rater separation is not agreement, and increasing
ratings cannot remove topic, rubric or recording-mode confounding. Anchor
studies must separate source-calibration size, linking information and receiving
sample size; bias/DFF studies must distinguish conditional screening from joint
interaction estimation and account for multiple comparisons.

Joint RSM/PCM cell and contrast intervals can retain an estimated normal
population under direct MML, including adaptive integration and joint information.
This removes the need to fix the population solely to obtain those intervals,
but does not establish classroom sample-size recommendations.

An explicit experimental `method = "profile"` in `mfrm_facet_intervals()` now
supports one pairwise contrast in direct RSM/PCM MML with an estimated normal
population. It includes zero residual variance in nuisance optimization,
uses adaptive integration with refinement checks throughout the profile, and
retains both the source and reoptimized estimates. The bounded Task-difference study supports improved
availability near the variance boundary, not a universal coverage advantage
or minimum sample size. General boundary calibration remains unqualified.

### Rater feedback and diagnostic screening
Severity estimates, infit/outfit `MnSq` and `ZSTD`, centrality/restriction indices, exact and weighted agreement, bias/DFF screens, residual networks, and exploratory clustering help assessment teams decide which ratings, criteria, or raters warrant substantive review. They are not automatic judgments of test fairness, rater competence, or training causal effects. Future feedback improvements prioritize clearer diagnostic explanations and cohesive `mfrm_results()` / `mfrm_report()` synthesis. Evaluate whether intended users can interpret these outputs; working examples and readable figures alone do not establish that outcome.

Matched comparisons include binary MH, explicitly selected multi-category/
multi-group GMH, and cumulative ordinal logistic models for two or more groups. These
require independent Persons within each target and justified matching;
they do not pool repeated Person-target ratings. GMH supplies an omnibus
association test, not a severity estimate. Logistic output separates omnibus
group tests from reference/focal point effects on a matching range shared by
all groups. Repeated-rating comparisons remain separate development work;
finite-sample performance requires evidence beyond numerical convergence.

New screening cutoffs require evidence about false flags and detection under
the intended assignment design. The feedback milestone above also requires
traceable examples and appropriate review actions.

### Public double-scoring data as an applied evaluation candidate

The [double-scoring application](vignettes/articles/application-double-scoring.Rmd)
uses invented observations to explain agreement, missingness and the additional
information needed for individual-rater inference. It links to IEA data sources
without distributing their records. An agreement analysis and a PV analysis
can stand independently. Dataset examples do not create an importer or model
milestone; general capabilities are evaluated across relevant rating designs.

<a id="interoperability-ergonomics-and-release-readiness-standards"></a>

## Interoperability and computational feasibility

<a id="open-facets-and-genova-compatibility-decisions"></a>

Existing external-software routes provide a baseline; the `0.3.x` work is
bounded extension of those routes, not the introduction of interoperability:

| Software | Existing route | Candidate change after 0.3.0 | Acceptance boundary |
| --- | --- | --- | --- |
| FACETS | Scorefile/fit-table reading, fit review and terminology guides | No new general-equivalence promise; retain explicit convention differences | Extreme scores, weights, anchors and fit-statistic degrees of freedom must be compared under matching conventions. |
| TAM; eRm and mirt | Import documented fitted components on the source scale through `import_irt_fit()` | Extend reporting for supported TAM outputs while retaining their source-model meaning | `DesignCell` locations do not identify separate facet effects or their joint covariance without the underlying design mapping. No new generic eRm/mirt importer is planned here. |
| ConQuest | Export bundles and normalization for demonstrated additive overlap specifications | Extend comparisons for bounded polytomous additive RSM/PCM specifications | Match response equations, scale constraints and uncertainty definitions; retain unsupported cases explicitly. |

Do not merge MML, unpenalized JML, bias-corrected JML, CML, G-theory ANOVA/MLS, and Bayesian HMC outputs merely because they produce similarly shaped tables. See the `help("mfrmr_gpcm_scope")`, `help("build_conquest_overlap_bundle")`, and `help("import_irt_fit")`.

Sparse-design resource use is part of numerical usability. Current native
likelihood paths index observed rating rows and reuse eligible probability
calculations; they do not require a complete Person-by-generalized-item response
matrix. This is not a fully sparse implementation: quadrature arrays, observed-cell
EM workspaces, corrected-JML count tables and joint covariance calculations can
still be large. The information-workspace budget is not a cap on total process
memory. Priorities are measured peak memory and elapsed time by engine and design,
followed by bounded caching, block processing or sparse operators where useful,
while preserving likelihoods, gradients, uncertainty checks and failure reasons.
First check existing supported paths at matched observed-rating counts while
varying Persons, observed cells and imbalance; report integration-node/category
counts and free parameters alongside resource use. Generalized-item reshaping
for external software is a separate allocation. New covariate/facet extensions
must demonstrate feasibility in their declared scope; reducing quadrature accuracy
or omitting required inference checks is not a performance improvement.

In 0.3.0, dependent sum-to-zero facet levels remain reportable. Supported MML
uncertainty transforms the full free-coordinate covariance to all levels,
including covariance terms for the dependent level. Facet fit summaries aggregate
observed rows for every level. A dependent level is not a known anchor: fixed
values, boundary-related omissions and unavailable information retain separate
labels. Ordinary JML's observation-information SEs remain exploratory and are
not the same joint covariance. Free-coordinate `coef()`/`vcov()` omit dependent
coordinates by design; use `mfrm_facet_intervals()` and the labelled diagnostic
tables for the corresponding all-level results within their supported scopes.

## 0.4.x and later model branches

New model families will be introduced only when their identification rules, independent numerical reference checks, inferential properties, and practical reporting workflow are established for a concrete assessment question.

| Target series | Intended capability | Initial scope and methodological boundary |
| --- | --- | --- |
| `0.4.x`: Multidimensional rubric profiles | Low-dimensional domain profiles, domain correlations, joint profile contrasts, and criterion/rater feedback | Start with a prespecified simple between-item binary loading matrix $Q$ on one rubric facet and unit slopes. Evaluate native MML initially for $D \in \{2, 3\}$ and Stan HMC for explicitly supported dimensions, with measured accuracy and resource limits. Verify reduction to the corresponding unit-slope model with matching step, link and scale conventions. Define and validate subscore added value for the intended score before recommending domain reporting. |
| `0.4.x+`: Rating-process and response/scoring time models | Joint or linked review of rating outcomes with timing observations | Model person production/response time and rater scoring time as distinct observation processes; never duplicate one event duration across multiple criterion rows as independent likelihood contributions. |
| `0.4.x+`: Direct rater-effect and latent-class extensions | Bounded parametric centrality, halo, or restricted rater-class models for targeted operational questions | Establish label-switching/scale identification and compare against simpler additive + diagnostic workflows under sparse designs before public adoption. |
| `0.4.x+`: Attribute-based cognitive diagnosis | Bounded rater-effects cognitive-diagnosis workflow with an explicit discrete skill-$Q$ matrix | Restrict initial support to small, prespecified binary attribute profiles; keep discrete skill-$Q$ cognitive diagnosis strictly separate in parameterization and interface from continuous multidimensional loading-$Q$ MFRM and exploratory clustering. |
| `0.4.x+` candidate: Graded response models (GRM) | A cumulative-link alternative for a specified ordinal-rating question; not native support in 0.3.0 | Define ordered threshold ownership, slope placement and identification; validate category probabilities, derivatives, information, scoring and diagnostics independently. GRM is a different response family from adjacent-category RSM/PCM/GPCM, and does not inherit their CML or bias-correction routes. External cumulative-model comparisons precede a decision to implement. |

The initial simple-loading model is not a reproduction of Uto (2021)'s freely
varying positive loadings. General cross-loadings require explicit axis and
rotation constraints; a prior that selects an orientation is not likelihood
identification. Nor does setting one dimension make Uto (2021)'s equation
identical to the current Uto & Ueno (2020) type two-family equation. These
distinctions must be resolved before implementation or performance studies.

Foundational references for these extensions include [Uto & Ueno (2020)](https://doi.org/10.1007/s41237-020-00115-7), [Uto (2021)](https://doi.org/10.1007/s41237-021-00144-w), [Haberman (2008)](https://doi.org/10.3102/1076998607302636), [Shan & Wang (2020)](https://doi.org/10.3389/fpsyg.2020.00525), and [Ulitzsch et al. (2023)](https://doi.org/10.3758/s13428-023-02259-2). Haberman's PRMSE framework motivates the subscore question; its applicability and estimator must be specified for the chosen score target. Better global fit alone does not establish useful subscores. Because these model classes exist in the psychometric literature, `mfrmr` evaluates contributions by transparency of assumptions, numerical reliability, and end-to-end usability rather than model-name count.

## What counts as complete?

Completion is specific to a model, rating design, output and user task:

1. **Correct calculation and scope:** equations, scales and constraints are
   stated; relevant calculations agree with independent references; unsupported
   inputs are distinguished from numerical failures.
2. **Usable and reproducible results:** documented calls, summaries, figures,
   reports and saved objects agree about the target and its status. Supported
   older results reload across R sessions, and external-software comparisons
   retain their model and convention differences.
3. **Appropriate interpretation:** numerical checks determine which quantities
   are available for the dataset. They do not establish model adequacy or
   finite-sample coverage. A point estimate, its uncertainty and its boundary
   status may have different qualifications.
4. **Evidence for the claim:** a sample-size rule, diagnostic cutoff, optimal
   plan or comprehension claim needs evidence for that specific use. Interval
   studies distinguish availability, coverage among available intervals and the
   fraction of all planned replications returning a covering interval, with
   failures and Monte Carlo uncertainty retained.

Experimental methods may be offered with explicitly limited evidence. An
unresolved general research question does not automatically prevent release
of a correct, bounded workflow. Conversely, successful checks or one real-data
example cannot establish a general recommendation.

Normal package checks retain representative real calculations and essential
regressions; longer research and optional-software checks have their own
reproducible execution paths. Final release checks apply to the actual archive.
Essential interpretation remains available offline, and website examples must
match the documented package version. Publication is complete only when those
artifacts are available to users.
