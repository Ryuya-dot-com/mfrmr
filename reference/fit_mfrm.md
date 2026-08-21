# Fit many-facet ordered-response models with a flexible number of facets

This is the package entry point. It wraps `mfrm_estimate()` and defaults
to `method = "MML"`. Any number of facet columns can be supplied via
`facets`. The `RSM` / `PCM` branches are the package's many-facet
Rasch-family reference route; the bounded `GPCM` branch is available
where explicitly documented.

## Usage

``` r
fit_mfrm(
  data,
  person,
  facets,
  score,
  rating_min = NULL,
  rating_max = NULL,
  weight = NULL,
  keep_original = FALSE,
  missing_codes = NULL,
  model = c("RSM", "PCM", "GPCM"),
  method = c("MML", "JML", "JMLE"),
  step_facet = NULL,
  slope_facet = NULL,
  facet_interactions = NULL,
  min_obs_per_interaction = 10,
  interaction_policy = c("warn", "error", "silent"),
  anchors = NULL,
  group_anchors = NULL,
  noncenter_facet = "Person",
  dummy_facets = NULL,
  positive_facets = NULL,
  anchor_policy = c("warn", "error", "silent"),
  min_common_anchors = 5L,
  min_obs_per_element = 30,
  min_obs_per_category = 10,
  quad_points = 31,
  maxit = 400,
  reltol = 1e-09,
  optimizer = c("auto", "BFGS", "L-BFGS-B"),
  mml_engine = c("direct", "em", "hybrid"),
  population_formula = NULL,
  person_data = NULL,
  person_id = NULL,
  population_policy = c("error", "omit"),
  facet_shrinkage = c("none", "empirical_bayes", "laplace"),
  facet_prior_sd = NULL,
  shrink_person = FALSE,
  attach_diagnostics = FALSE,
  checkpoint = NULL,
  gpcm_mml_identification = c("free_population", "fixed_standard_normal")
)
```

## Arguments

- data:

  A data.frame in long format with one row per observed rating event.

- person:

  Column name for the person (character scalar).

- facets:

  Character vector of facet column names.

- score:

  Column name for the observed ordered category score. Values must be
  coercible to numeric integer category codes. Fractional values are
  rejected. Binary `0/1` or `1/2` responses are supported as the ordered
  two-category special case. When `keep_original = FALSE`, unused
  intermediate categories are collapsed to a contiguous internal scale
  and the mapping is recorded in `fit$prep$score_map`. If `rating_min` /
  `rating_max` are supplied and the observed scores are a contiguous
  subset of that range (for example a 1-5 scale with only 2-5 observed),
  the supplied full range is retained so zero-count boundary categories
  remain visible in the data-support review. A zero-count boundary
  category is retained as review evidence. With `keep_original = TRUE`,
  however, an unobserved internal category in a polytomous fitted ladder
  creates an unsupported adjacent-step contrast and fitting stops before
  optimization with a structured category-support error.

- rating_min:

  Optional minimum category value. Supply this with `rating_max` when
  the intended score scale includes unobserved boundary categories.

- rating_max:

  Optional maximum category value. Supply this with `rating_min` when
  the intended score scale includes unobserved boundary categories.

- weight:

  Optional weight column name.

- keep_original:

  Logical. `FALSE` (the current default) collapses non-consecutive
  observed categories to a contiguous internal scale and records the
  mapping in `fit$prep$score_map` (the downstream Count = 0 rows are
  consequently absent). `TRUE` preserves the declared scale so unused
  intermediate categories remain visible in
  [`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rating_scale_table.md)
  and APA outputs, which is recommended for publication reporting.

- missing_codes:

  Optional pre-processing step that converts sentinel missing-code
  values to `NA` before any downstream logic. One of:

  - `NULL` (default): no recoding; strictly backward-compatible.

  - `TRUE` or `"default"`: FACETS / SPSS / SAS convention set (`"99"`,
    `"999"`, `"-1"`, `"N"`, `"NA"`, `"n/a"`, `"."`, `""`) on the score
    column only. Person and facet identifiers are preserved because
    short codes such as `"N"` can be legitimate labels.

  - Character vector: an explicit code set, e.g. `c("99", "999", ".a")`,
    applied across the person, facet, and score columns.

  Replacement counts are recorded in `fit$prep$missing_recoding` and
  surfaced by
  [`build_mfrm_manifest()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_manifest.md).
  Equivalent to calling
  [`recode_missing_codes()`](https://ryuya-dot-com.github.io/mfrmr/reference/recode_missing_codes.md)
  manually before the fit.

- model:

  `"RSM"`, `"PCM"`, or bounded `"GPCM"`.

- method:

  `"MML"` (default) or `"JML"`. `"JMLE"` is accepted as a
  backward-compatible alias for the same joint-maximum-likelihood path.

- step_facet:

  Facet whose levels receive separate step parameters in `PCM` and
  bounded `GPCM`. Supply it explicitly for a final analysis. If it is
  omitted for `PCM`, mfrmr uses a unique item-like facet name (for
  example, `Item`, `Task`, or `Criterion`) when available; otherwise it
  retains the first-facet fallback with a warning. `GPCM` always
  requires an explicit value. This argument is not used by `RSM`, which
  has one shared set of rating-scale thresholds.

- slope_facet:

  Slope facet for the bounded `GPCM` branch. mfrmr estimates one
  positive slope for every level of this designated facet. Thus
  `slope_facet = "Criterion"` gives criterion-specific slopes, whereas
  `slope_facet = "Rater"` gives rater-specific slopes. The current route
  accepts exactly one slope-owning facet, requires
  `slope_facet == step_facet`, and cannot estimate criterion and rater
  slope blocks simultaneously. Slopes are identified on the log scale
  with their geometric mean fixed to 1, so the table reports relative
  discrimination across the selected facet's levels rather than
  unrelated absolute weights.

- facet_interactions:

  Optional confirmatory two-way interaction terms between non-person
  facets, supplied as explicit character terms such as
  `"Rater:Criterion"` or as a list of length-two character vectors.
  These interactions are estimated simultaneously as fixed effects in
  `RSM` and `PCM` fits. Person-involving interactions, higher-order
  interactions, and random-effect interaction terms are outside the
  current scope.

- min_obs_per_interaction:

  Minimum weighted observations recommended for each interaction cell.
  Cells below this value are flagged in
  [`interaction_effect_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interaction_effect_table.md)
  and handled according to `interaction_policy`.

- interaction_policy:

  How to handle sparse interaction cells: `"warn"` (default), `"error"`,
  or `"silent"`.

- anchors:

  Optional anchor table.

- group_anchors:

  Optional group-anchor table.

- noncenter_facet:

  One facet to leave non-centered.

- dummy_facets:

  Facets to fix at zero.

- positive_facets:

  Facets with positive orientation.

- anchor_policy:

  How to handle anchor-review issues: `"warn"` (default), `"error"`, or
  `"silent"`.

- min_common_anchors:

  Minimum anchored levels per linking facet used in anchor-review
  recommendations.

- min_obs_per_element:

  Minimum weighted observations per facet level used in anchor-review
  recommendations.

- min_obs_per_category:

  Minimum weighted observations per score category used in anchor-review
  recommendations.

- quad_points:

  Integer number of Gauss-Hermite quadrature points used for MML
  integration over the person distribution. The default is `31`. Useful
  accuracy/runtime settings are:

  |  |  |
  |----|----|
  | `7` | lightweight screening run; information-criterion deltas, weights, preferences, and LRT are disabled. Helpers such as [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md) and [`reference_case_benchmark()`](https://ryuya-dot-com.github.io/mfrmr/reference/reference_case_benchmark.md) use this value. |
  | `15` | intermediate review run when runtime matters; automatic model ranking remains disabled. |
  | `31` | package default and the starting grid for model comparison. |
  | `61+` | sensitivity analysis for narrow score distributions or demanding numerical comparisons. |

  Quadrature adequacy depends on the fitted distribution and score
  support. When substantive conclusions are sensitive, compare results
  under a denser rule and report the setting used. Raw AIC/BIC/SABIC
  remain visible below 31 points for diagnosis, but
  [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
  fails closed rather than turning a screening/review grid into
  automatic selection.

- maxit:

  Computational ceiling on optimizer iterations. The default is `400`.
  This is not a convergence criterion or a model-selection control: a
  fit that reaches the ceiling remains non-ready until the common
  convergence and terminal-gradient checks pass. Smaller values used in
  executable examples shorten package checks and should not be copied
  into a final analysis without an explicit computational protocol.

- reltol:

  Portable tolerance setting for the initial optimizer stage. The
  default is `1e-9`. For BFGS this is passed as `reltol`; for L-BFGS-B
  it is mapped to `factr` and `pgtol`, whose actual values are recorded
  in the fit. When this setting is at least as strict as the public
  default (`reltol <= 1e-9`), optimizer code zero followed by a failed
  common terminal-gradient review triggers a bounded warm-started polish
  ladder. The best non-worsening stage under the recorded selection rule
  is retained. Requested and selected-stage settings remain in
  `fit$summary`, and the complete stage history remains in
  `fit$opt$optimizer_polish`.

- optimizer:

  Direct-optimization method. `"auto"` (default) uses the limited-memory
  `"L-BFGS-B"` method for MML and for larger JML parameter vectors (at
  least 200 free parameters), while retaining BFGS for smaller JML fits.
  Use `"BFGS"` or `"L-BFGS-B"` to request one method explicitly. The
  method actually used is recorded in `fit$summary$OptimizerMethod`. For
  L-BFGS-B, inspect `OptimizerFactr` and `OptimizerPgtol` rather than
  interpreting `EffectiveReltol` as a native
  [`stats::optim()`](https://rdrr.io/r/stats/optim.html) control.

- mml_engine:

  MML optimization engine for `method = "MML"`: `"direct"` (default)
  uses the selected direct optimizer on the marginal log-likelihood,
  `"em"` uses an EM loop for `RSM` / `PCM` with `population = NULL`, and
  `"hybrid"` uses EM as a warm start before the direct optimizer.
  Unsupported combinations currently fall back to `"direct"` and record
  that fallback in `fit$summary`. Direct, hybrid, and EM engines all
  require the common terminal-gradient gate for the Numerical component
  of fit readiness; EM relative log-likelihood convergence alone does
  not establish numerical readiness. `InferenceReady` is `TRUE` only
  when every stored fit-readiness component passes.

- population_formula:

  Optional one-sided formula for a person-level latent-regression
  population model, for example `~ grade + ses`. Latent regression is
  implemented only for `method = "MML"` with a unidimensional
  conditional-normal population model.

- person_data:

  Optional one-row-per-person data.frame holding background variables
  for `population_formula`. Numeric, logical, factor, ordered factor,
  and character predictors are expanded through
  [`stats::model.matrix()`](https://rdrr.io/r/stats/model.matrix.html);
  categorical xlevels and contrasts are stored for replay and scoring.
  Required when `population_formula` is supplied.

- person_id:

  Optional person-ID column in `person_data`. Defaults to `person` when
  that column exists in `person_data`.

- population_policy:

  How missing background data are handled for a latent-regression fit.
  `"error"` (default) requires complete person-level covariates;
  `"omit"` fits the model on the complete-case subset and records
  omitted persons / omitted response rows in the returned `population`
  metadata while retaining the observed-person-aligned pre-omit table
  for replay/export provenance.

- facet_shrinkage:

  Character. `"none"` (default) keeps the unshrunk fixed-effects
  estimates. `"empirical_bayes"` applies a post-hoc James-Stein /
  empirical-Bayes shrinkage to each non-person facet (Efron & Morris,
  1973); `fit$facets$others` gains `ShrunkEstimate`, `ShrunkSE`, and
  `ShrinkageFactor` columns, and `fit$shrinkage_report` records the
  per-facet prior variance and effective degrees of freedom. `"laplace"`
  is retained as a compatibility alias for `"empirical_bayes"`; it does
  not fit a penalized likelihood.

- facet_prior_sd:

  Optional numeric scalar. When supplied, the shrinkage prior variance
  is fixed at `facet_prior_sd^2` instead of being estimated by method of
  moments. Useful for eliciting a prior from domain knowledge or a
  previous fit.

- shrink_person:

  Logical. When `TRUE` and `facet_shrinkage` is active, the same
  empirical-Bayes shrinkage is applied to `fit$facets$person`. Default
  `FALSE`, since MML already integrates over a normal population
  distribution for theta; the option mainly benefits JML.

- attach_diagnostics:

  Logical. When `TRUE`,
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  is run once after the fit with `residual_pca = "none"`, and the
  per-level `SE`, `Infit`, `Outfit`, `InfitZSTD`, `OutfitZSTD`, and
  `PtMeaCorr` columns from `diagnostics$measures` are merged onto
  `fit$facets$others` (non-person facets) and `fit$facets$person`
  (Person rows). This is convenient when downstream code expects a
  FACETS Table 7 style facet table with fit statistics in one place, and
  lets `summary(fit)` show per-person fit columns alongside the measure.
  For person rows, an existing posterior `SE` (typical for
  `method = "MML"`) is preserved and the diagnostic `SE` is only
  attached when the existing column is empty. Adds diagnostic runtime
  (typically +1-2 s on moderate designs) and sets
  `fit$config$attached_diagnostics = TRUE`. Default `FALSE` preserves
  the minimal `Facet` / `Level` / `Estimate` layout.

- checkpoint:

  Optional `list(file = ..., every_iter = ...)`. When supplied, the MML
  EM engine writes its state to `file` every `every_iter` outer EM
  iterations using [`saveRDS()`](https://rdrr.io/r/base/readRDS.html).
  If the file already exists when the fit starts, the engine resumes
  from the recorded iteration. Only the EM engine (`mml_engine = "em"`
  or the EM warm-start step of `mml_engine = "hybrid"`) honours the
  checkpoint; the direct [`optim()`](https://rdrr.io/r/stats/optim.html)
  engine ignores it. Use this to make long MML EM fits crash-resilient
  on shared compute environments.

- gpcm_mml_identification:

  Scale-identification convention for `model = "GPCM"` with
  `method = "MML"`. `"free_population"` (the default) estimates an
  intercept-only person distribution \\N(\beta_0,\sigma^2)\\ when
  `population_formula` is omitted, while retaining geometric-mean-one
  relative slopes. This restores the common discrimination degree of
  freedom used by a conventional fixed-latent- variance GPCM; in the
  documented item-only overlap it is a one-to-one reparameterization of
  ConQuest `scoresfree` GPCM. An explicitly supplied
  `population_formula` is retained under this convention.
  `"fixed_standard_normal"` is the legacy restricted branch: it requires
  `population_formula = NULL`, fixes the person distribution to
  \\N(0,1)\\, and also fixes the slope geometric mean to one. The latter
  is then a substantive relative-discrimination restriction rather than
  an identification requirement. This argument does not change JML,
  whose geometric-mean-one slope constraint is required to identify its
  freely estimated person coordinates.

## Value

An object of class `mfrm_fit` (named list) with:

- `summary`: one-row model summary including `LogLik`, `Deviance`,
  canonical free dimension `Npar`, response-row/weight/Person counts,
  the versioned information-criterion contract, Person-based MML
  `AIC`/`BIC`/`SABIC`, explicitly descriptive legacy fields when the
  common panel is ineligible, and convergence; it also includes
  user-facing `Method`, engine-facing `MethodUsed`, MML-engine fields,
  terminal-gradient readiness, requested/selected-stage tolerance
  settings, and the actual L-BFGS-B `OptimizerFactr` / `OptimizerPgtol`
  controls when applicable

- `facets$person`: person estimates (`Estimate`; plus `SD` for MML),
  with `SourceFitReadiness`, `SourceInferenceReady`, and `EstimateUse`
  separating a defined Person summary from the source fit's permission
  to interpret it. In particular, a finite prior-regularized MML EAP
  does not become reportable when the source fit is blocked.

- `facets$others`: facet-level estimates for each facet

- `steps`: estimated threshold/step parameters as a one-row-per-step
  `tibble` with `Estimate`. Bare fits keep this table as point
  estimates.
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  exposes MML observed-information step uncertainty in
  `diagnostics$parameter_uncertainty$steps`; when
  `attach_diagnostics = TRUE`, those `SE`, confidence-limit, and status
  columns are attached to `fit$steps` when the Hessian is available. For
  step-structure quality, also use the step-collapse and disordering
  warnings from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  and
  [`category_structure_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_structure_report.md).

- `slopes`: discrimination parameters for `GPCM` fits as a
  one-row-per-slope-element `tibble`. `LogEstimate` and `Estimate`
  retain the finite optimizer values for compatibility and numerical
  diagnosis; `OptimizerLogEstimate` / `OptimizerEstimate` name that role
  explicitly. Read `ParameterStatus`, `PrimaryLogEstimate`,
  `PrimaryEstimate`, `SEEligible`, `CIEligible`, and `ReasonCodes`
  before interpretation. A certified JML slope-only path receives a
  typed extended-real primary boundary. `config$boundary_audit` retains
  the supporting fixed-objective, joint-path, and terminal-gradient
  records. A certified path can establish that a finite JML maximum is
  unattained for the evaluated case. The converse is deliberately not
  used: failure to find a path in the evaluated families, or retention
  of a finite optimizer point, does not establish existence of a finite
  global maximum for the non-concave GPCM likelihood. These technical
  records do not promote readiness, uncertainty, MML, or cross-software
  claims. `config$boundary_audit$gpcm_terminal_gradient_stability`
  reconstructs the same fixed JML objective and analytic terminal
  gradient, checks stored optimizer/polish summaries and deterministic
  central-difference probes, and reports gradient norms by
  free-parameter block. Positive boundary certificates take precedence
  over a finite-point zero or small gradient; otherwise a coherent small
  gradient is retained-point first-order evidence only. The
  implementation threshold is not a frozen scientific criterion and the
  audit does not certify a finite global maximum, boundary absence,
  uncertainty, external comparability, or readiness. The conditional JML
  boundary checks are not reused for MML.
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  may retain observed-information and delta-method values in
  `Optimizer*SE` / `Optimizer*CI` columns, but ordinary `SE` / `CI`
  columns remain unavailable while parameter readiness is not
  established. The identification convention pins the geometric mean of
  finite optimizer slopes at 1.

- `readiness`: the versioned fit record, five component rows, and
  current parameter-level rows. The current parameter slice includes
  GPCM slopes; other non-Person parameter classes remain scheduled for
  later propagation.

- `interactions`: model-estimated facet interaction effects and metadata
  when `facet_interactions` is supplied

- `population`: population-model metadata. Ordinary RSM/PCM and JML fits
  keep an inactive record (`active = FALSE`,
  `posterior_basis = "legacy_mml"`). Default bounded-GPCM MML and active
  latent-regression fits store the fitted design matrix, regression
  coefficients, residual variance, omission review, the complete-case
  estimation table (`person_table`), and the observed-person-aligned
  replay/export provenance table retained before complete-case omission
  (`person_table_replay`), plus stored categorical `xlevels` /
  `contrasts` for model-matrix replay and scoring, together with
  `posterior_basis = "population_model"`. `estimation_converged` records
  optimizer convergence and `inference_ready` records the separate
  formal readiness decision. The older `population$converged` field is
  retained as a compatibility alias of `inference_ready`; its basis is
  recorded in `population$converged_basis`.

- `data_review`: pre-fit Data, Design, Stability, and Reporting
  readiness evidence propagated into summaries and plot-interpretation
  gates

- `config`: resolved model configuration used for estimation, including
  `config$anchor_review` and the recorded estimation controls

- `prep`: preprocessed data/level metadata

- `opt`: optimizer result augmented with `optimizer_diagnostics`, the
  complete `optimizer_polish` stage history, method-selection metadata,
  and evaluation-cache counters. For direct fitting, its core fields
  originate from [`stats::optim()`](https://rdrr.io/r/stats/optim.html);
  EM additionally records engine-specific diagnostics.

## Details

Data must be in **long format** (one row per observed rating event).
Exact duplicate Person-by-facet combinations are retained, warned once,
and propagated as a Data review state. They are not treated as
independent replication evidence. A legitimate re-rating or replicated
scoring event should be represented by an event, occasion, or other
distinguishing facet before fitting.

## Model

`fit_mfrm()` estimates many-facet ordered-response models. The `RSM` and
`PCM` branches follow the many-facet Rasch-family tradition (Linacre,
1989); the bounded `GPCM` branch extends the partial-credit kernel with
estimated positive slopes under the package's documented identification
constraints. For the equal-slope `RSM`/`PCM` branch, a two-facet design
(rater \\j\\, criterion \\i\\) is:

\$\$\ln\frac{P(X\_{nij} = k)}{P(X\_{nij} = k-1)} = \theta_n - \delta_j -
\beta_i - \tau_k\$\$

where \\\theta_n\\ is person ability, \\\delta_j\\ rater severity,
\\\beta_i\\ criterion difficulty, and \\\tau_k\\ the \\k\\-th
Rasch-Andrich threshold. Any number of facets may be specified via the
`facets` argument; each enters as an additive term in the linear
predictor \\\eta\\.

With `model = "RSM"`, thresholds \\\tau_k\\ are shared across all levels
of all facets. With `model = "PCM"`, each level of `step_facet` receives
its own threshold vector \\\tau\_{i,k}\\ on the package's shared
observed score scale.

One response-model family is used per `fit_mfrm()` call. The current
public interface does not combine binary, RSM, PCM, or GPCM observations
in one fit, define multiple independent rating scales, or accept general
threshold/scale anchors and fixed-calibration starting values.

With bounded `model = "GPCM"`, the adjacent-category kernel is
multiplied by a positive slope for the designated slope-facet level:

\$\$\ln\frac{P(X\_{nij} = k)}{P(X\_{nij} = k-1)} = \alpha_g(\eta -
\tau\_{g,k}),\quad \alpha_g \> 0.\$\$

The current implementation requires `slope_facet == step_facet` and
identifies slopes by a sum-to-zero constraint on log slopes, so their
geometric mean is 1. A selected facet owns a vector rather than one
common number: if there are \\G\\ levels, the fit returns \\G\\ positive
slopes with \\G-1\\ free log-slope contrasts. Every other facet remains
additive inside \\\eta\\ and receives no separate slope. Selecting a
rater facet is therefore a different restricted model from selecting a
criterion or task facet. The placement of the slope is part of the model
identity: it multiplies the complete adjacent-category predictor,
including the person coordinate, all additive facet locations and fitted
facet interactions inside \\\eta\\, and the owned step. It is not a
loading-only formulation in which the slope multiplies ability while
rater severity and other intercept terms remain unscaled. Such a
formulation, including TAM multifacet `GPCM.design` constructions with
separate linear intercept and slope designs, is a different model unless
an algebraic reduction establishes equivalence. This is an aligned
single-owner many-facet GPCM: exactly one facet owns both the slope and
step blocks. It is not the broader Uto–Ueno generalized MFRM, whose task
and rater slopes enter multiplicatively and whose step owner must be
stated separately. Setting every current slope to one recovers the
package's equal-discrimination PCM kernel; it does not establish support
for the omitted second slope block, multidimensional traits, or
response-style parameters. Under the default
`gpcm_mml_identification = "free_population"` branch, the population
standard deviation carries the common discrimination scale while the
geometric-mean-one slopes describe relative discrimination.
Equivalently, on a standardized latent variable the absolute slopes are
\\\sigma\alpha_g\\. Under
`gpcm_mml_identification = "fixed_standard_normal"`, both the population
standard deviation and slope geometric mean are fixed to one; that
legacy branch is a narrower relative-discrimination model. Under JML,
the geometric-mean-one constraint is required to resolve the
ability/slope scale because person coordinates are estimated jointly.

Here and elsewhere in the package, "bounded GPCM" means that the
documented model/workflow scope is deliberately narrow. It does not mean
box-constrained estimation. The JML branch maximizes the identified
joint log-likelihood without a statistical penalty or finite bounds on
person, location, step, or slope coordinates. Numerical line-search
rejection of non-representable slope proposals is not regularization.
When a recession direction is certified, the finite optimizer iterate
remains a numerical trace and the primary result uses the appropriate
extended-real or typed boundary status; it is not relabelled as a finite
maximizer of the original JML objective.

With only two ordered categories (\\K = 1\\), the `RSM`/`PCM` branch
reduces to the usual binary Rasch logit for the single category
boundary:

\$\$\ln\frac{P(X\_{n\cdot} = 1)}{P(X\_{n\cdot} = 0)} = \eta - \tau_1\$\$

Bounded `GPCM` uses the slope-scaled counterpart \\\alpha_g(\eta -
\tau\_{g,1})\\.

With `method = "MML"`, person parameters are integrated out using
Gauss-Hermite quadrature and EAP estimates are computed post-hoc. With
`method = "JML"`, all parameters are estimated jointly as fixed effects.
`"JMLE"` remains an accepted compatibility alias, but package output now
uses `"JML"` as the public label. See the "Estimation methods" section
of
[mfrmr-package](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr-package.md)
for details.

## Weighting policy

`mfrmr` treats `RSM` / `PCM` as the equal-weighting reference route for
operational many-facet measurement. In that Rasch-family branch,
discrimination is fixed, so the scoring model does not differentially
reweight item-facet combinations through estimated slopes.

Bounded `GPCM` is supported as an alternative when users explicitly
accept discrimination-based reweighting. This often improves model fit,
but the package does not treat better fit alone as a sufficient reason
to replace an equal-weighting Rasch-family model.

The `weight` argument is separate from that modeling choice. It supplies
an observation-weight column; it does not create a free-form
facet-weighting scheme and does not change the fixed-discrimination
contract of `RSM` / `PCM`.

## Input requirements

Minimum required columns are:

- person identifier (`person`)

- one or more facet identifiers (`facets`)

- observed score (`score`)

Scores are treated as ordered categories. Although the fitted category
probabilities form a multinomial probability vector, category order is
part of the likelihood: unordered nominal/multinomial-logit responses
are not supported. Poisson, negative-binomial, and grouped
binomial-trial counts are also not response families in `fit_mfrm()`.
Integer counts supplied as `score` are interpreted only as ordered
category codes. Non-numeric score labels are dropped with a warning
after coercion, whereas fractional numeric scores are rejected with an
error instead of being silently truncated.

A positive numeric `weight` may encode a replication/likelihood weight
for an ordered-rating row when weighting that conditional contribution
is the intended estimand. It is not a general collapsed-person
frequency-table interface: under MML, powering responses inside one
Person's conditional pattern is not the same as replicating a complete
Person pattern after marginalization. A weight also does not turn the
score into a count outcome or model dependence among repeated ratings.
Non-positive finite weights are excluded during preparation, and
non-unit observation-weight fits are not eligible for the common MML
information-criterion panel in version 0.2.3.

The fitted many-facet ordered-response model assumes conditional
independence of observations given the person and facet parameters
(Linacre, 1989). Repeated ratings of the same person-criterion
combination by the same rater violate this assumption. When such
structures may be present, follow fitting with
`diagnose_mfrm(fit, diagnostic_mode = "both")`; its
`strict_pairwise_local_dependence` screen is an exploratory check for
residual dependence beyond what the additive linear predictor absorbs.

Binary responses are therefore supported as ordered two-category scores
(for example `0/1` or `1/2`) under the same ordered-response interface.
If your observed categories do not start at 0, set
`rating_min`/`rating_max` explicitly to avoid unintended recoding
assumptions. For example, if the intended instrument is a 1-5 scale but
the current sample only uses 2-5, set `rating_min = 1, rating_max = 5`
to retain the zero-count category 1 in the data-support review. That
boundary absence is a review condition for the separate element-boundary
contract, not by itself an unsupported free step contrast. By contrast,
retaining an unobserved internal category in a polytomous fitted ladder
creates an adjacent-step recession direction, so `fit_mfrm()` stops
before optimization rather than reporting finite step estimates for that
ladder. If these bounds are omitted, the observed score range is used
and the provenance is stored in `fit$prep` and
`summary(fit)$settings_overview`. Set
`options(mfrmr.show_inferred_rating_range = TRUE)` when you want an
interactive reminder whenever a bound is inferred. Data-preparation
events such as row drops, ID trimming, duplicate person-by-facet cells,
and single-level facets are stored in `fit$prep$row_retention` and
`fit$prep$preparation_notes`. Routine row-drop/trim/single-level
messages are quiet by default; set
`options(mfrmr.show_preparation_messages = TRUE)` to show them during
interactive checks.

When `keep_original = FALSE`, observed gaps such as `1, 3, 5` are
recoded internally to a contiguous scale (`1, 2, 3`) and the mapping is
stored in `fit$prep$score_map`. To retain zero-count intermediate
categories as part of the original scale, set `keep_original = TRUE` in
addition to supplying the full `rating_min` / `rating_max` range.

## Fixed effects assumption (facets have no prior)

`fit_mfrm()` follows the Linacre (1989) many-facet Rasch specification:
person ability is integrated out under a `N(0, 1)` distribution (or
under the `N(X\beta, \sigma^2)` population model when
`population_formula` is supplied). Bounded GPCM MML instead activates an
intercept-only `N(\beta_0, \sigma^2)` population model by default so its
common discrimination scale is estimable. Every facet parameter
(`Rater`, `Criterion`, `Task`, ...) is estimated as a fixed effect
identified by a sum-to-zero constraint. There is no hierarchical prior,
no shrinkage, and no variance component for the facets.

Practical implication: when a facet has very few observed levels (for
example 3 raters) or some of its levels have very few ratings (for
example 5 ratings per rater), the fixed-effect estimates retain wide
SEs, and extreme estimates are not pulled toward the facet mean. Jones
and Wind (2018) note that rater estimates in particular are "more
sensitive to link reductions" than examinee or task estimates. For a
publication-workflow review of this, use:

- [`facet_small_sample_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_small_sample_review.md)
  for per-level N and SE bands against Linacre (1994) sample-size
  guidelines.

- [`detect_facet_nesting()`](https://ryuya-dot-com.github.io/mfrmr/reference/detect_facet_nesting.md)
  and
  [`analyze_hierarchical_structure()`](https://ryuya-dot-com.github.io/mfrmr/reference/analyze_hierarchical_structure.md)
  when raters are nested in regions, schools, or other strata that the
  additive fixed-effects MFRM cannot partition out.

- [`compute_facet_icc()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_icc.md)
  and
  [`compute_facet_design_effect()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_facet_design_effect.md)
  for descriptive variance- component summaries based on `lme4`
  (optional).

`fit$summary$FacetSampleSizeFlag` summarizes the worst Linacre band
across non-person facet levels (`"sparse"` \< 10, `"marginal"` \< 30,
`"standard"` \< 50, `"strong"` \>= 50).

## Estimator choice and the JML incidental-parameter caveat

Joint maximum likelihood (`method = "JML"` / `"JMLE"`) estimates both
the structural parameters (facets, thresholds, slopes) and every person
measure as fixed parameters in one optimization. This is the
**incidental-parameter problem** of Neyman & Scott (1948):
structural-parameter bias can persist as the number of persons grows
with the number of items per person held fixed. In classical Rasch
settings this bias can be of order \\1/L\\ (where \\L\\ is the number of
items per person) and therefore need not vanish by adding persons alone.
Wright & Stone (1979) and Wright & Masters (1982, ch. 5) document an
empirical \\(L-1)/L\\ correction that approximately removes the bias for
the dichotomous Rasch model; mfrmr does **not** apply that correction
(no `bias_correction` argument exists). The JML branch also does not
produce a profile-likelihood Hessian for the structural parameters: SEs
reported under JML are observation-table approximations (\\1/\sqrt{\sum
\mathrm{Var}(X\_{pi})}\\) and are marked as exploratory in the
diagnostics output.

Practical recommendation:

- For manuscript or operational reporting, choose the estimator from the
  inferential target and assumptions, and report the choice. MML
  integrates person measures under a specified population model and
  provides marginal observed-information SEs; consistency of its
  structural estimates is conditional on an adequate response model,
  population distribution, and regularity conditions.

- JML remains useful for a JMLE-oriented FACETS comparison, descriptive
  or exploratory work, and designs with substantial information per
  person. Report its incidental-parameter limitation and the exploratory
  basis of this package's JML structural SEs rather than treating
  estimator choice as a universal reporting rule.

- For supported Rasch-family formulations, conditional maximum
  likelihood is a distribution-free alternative that conditions out
  person parameters. A third-party CML fit can be imported from `eRm`
  with
  [`import_erm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_erm_fit.md).

## Model-estimated facet interactions

`facet_interactions` adds confirmatory fixed-effect interaction terms to
the linear predictor. For example,
`facet_interactions = "Rater:Criterion"` estimates a rater-by-criterion
deviation matrix in the same likelihood as the main MFRM fit. The
additive reference is

\$\$\eta\_{nij} = \theta_n - \delta_j - \beta_i\$\$

and the interaction extension is

\$\$\eta\_{nij} = \theta_n - \delta_j - \beta_i + \gamma\_{ji}\$\$

where the interaction block is identified by zero marginal sums:

\$\$\sum_j \gamma\_{ji} = 0,\quad \sum_i \gamma\_{ji} = 0.\$\$

With \\J\\ levels of the first facet and \\I\\ levels of the second
facet, this contributes \\(J - 1)(I - 1)\\ free parameters. Positive
interaction estimates indicate scores higher than expected under the
additive main-effects model for that facet-level combination; negative
estimates indicate lower-than-expected scores.

This is a model-estimated interaction term, not the residual screening
reported by
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
or
[`estimate_all_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_all_bias.md).
In line with the MFRM bias-interaction literature, the facet pair should
be named explicitly before fitting. Exploratory use is possible, but
should be reported as screening, with sparse-cell and multiplicity
caveats. The current implementation is intentionally narrow: two-way
non-person facet interactions for `RSM` and `PCM` only, estimated as
fixed effects. GPCM interactions, person interactions, higher-order
interactions, and random-effect facet interactions are deferred.

This is ordered binary support, not a separate nominal-response model.
In `PCM`, a binary fit still uses one threshold per `step_facet` level
on the shared observed-score scale.

Supported model/estimation combinations:

- `model = "RSM"` with `method = "MML"` or `"JML"/"JMLE"`

- `model = "PCM"` with a designated `step_facet` (defaults to first
  facet)

- `facet_interactions` with `model = "RSM"` or `"PCM"` for explicit
  two-way non-person facet interactions

- `model = "GPCM"` is currently implemented only for the narrow bounded
  branch with `slope_facet == step_facet`; `MML` and `JML` fitting, core
  summaries, fixed-calibration posterior scoring,
  [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md),
  Wright/pathway/CCC fit plots,
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
  residual-PCA follow-up,
  [`interrater_agreement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interrater_agreement_table.md),
  [`unexpected_response_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/unexpected_response_table.md),
  [`displacement_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/displacement_table.md),
  [`measurable_summary_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/measurable_summary_table.md),
  [`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rating_scale_table.md),
  [`facet_quality_dashboard()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_quality_dashboard.md),
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md),
  [`category_structure_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_structure_report.md),
  [`category_curves_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/category_curves_report.md),
  and graph/scorefile
  [`facets_output_file_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_output_file_bundle.md)
  routes are available with score-side caveats. Direct simulation
  specifications and data generation are also supported through
  [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md),
  [`extract_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/extract_mfrm_sim_spec.md),
  and
  [`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md)
  when the slope-aware generator contract is stored explicitly; direct
  recovery checks are available through
  [`evaluate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/evaluate_mfrm_recovery.md)
  and
  [`assess_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/assess_mfrm_recovery.md).
  Slope-aware
  [`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md)
  and
  [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
  are available with their documented caveats. Role-based design
  evaluation, population forecasting, diagnostic-screening, and
  signal-detection helpers are available as caveated sensitivity
  evidence. Full FACETS-style score-side contract review, posterior
  predictive checks, and MCMC estimation are not available for bounded
  `GPCM`. Use
  [`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)
  as the formal boundary statement for the current `GPCM` scope.

Latent-regression status:

- `population_formula = NULL` keeps the standard unconditional behavior
  for RSM/PCM and JML. For bounded GPCM MML, the default
  `gpcm_mml_identification = "free_population"` constructs an
  intercept-only population model internally; use
  `"fixed_standard_normal"` only to reproduce the legacy restricted
  likelihood.

- Supplying `population_formula` activates latent regression for
  `method = "MML"` only.

- This implementation assumes a one-dimensional conditional-normal
  population model with person-specific quadrature nodes \\\theta\_{nq}
  = x_n^\top \beta + \sigma z_q\\.

- Background variables must be supplied in `person_data`;
  numeric/logical columns and categorical factor/character columns are
  expanded through
  [`stats::model.matrix()`](https://rdrr.io/r/stats/model.matrix.html).

- Documented overlap with the ConQuest latent-regression model is
  limited to direct estimation from response data under a unidimensional
  `MML` population model with package-built model-matrix covariates. It
  should not be described as numerical equivalence for arbitrary
  imported design matrices, multidimensional models, or the full
  ConQuest plausible-values workflow.

- [`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
  and
  [`sample_mfrm_plausible_values()`](https://ryuya-dot-com.github.io/mfrmr/reference/sample_mfrm_plausible_values.md)
  can score latent-regression fits under the fitted population model,
  but they require one-row-per-person background data for scored units
  when the fitted population model includes covariates. Intercept-only
  latent-regression fits (`population_formula = ~ 1`) can reconstruct
  that minimal person table internally during scoring.

## Latent-regression workflow

For an initial latent-regression run, keep the setup explicit:

1.  Put response data in `data`, with one row per rating event.

2.  Put background variables in `person_data`, with exactly one row per
    person. The ID column must match `person`, or be supplied through
    `person_id`.

3.  Use `method = "MML"` and a one-sided formula such as
    `population_formula = ~ Grade + Group`.

4.  Numeric/logical and factor/character predictors are expanded with
    [`stats::model.matrix()`](https://rdrr.io/r/stats/model.matrix.html).
    After fitting, inspect `summary(fit)$population_coding` to see the
    fitted levels, contrasts, and encoded design columns that will be
    reused for scoring/replay.

5.  Start with `population_policy = "error"` while preparing data. Use
    `"omit"` only when complete-case removal is intended, and then
    inspect `summary(fit)$population_overview` and
    `summary(fit)$caveats` before reporting results.

6.  Report `summary(fit)$population_coefficients` as coefficients of the
    conditional-normal latent population model, not as a post hoc
    regression on EAP or MLE scores.

## Latent-regression standard-error caveat

`summary(fit)$population_coefficients` reports point estimates of
\\\hat{\boldsymbol{\beta}}\\ and \\\hat{\sigma}^2\\ only. mfrmr does
**not** currently compute standard errors, confidence intervals, or
asymptotic z / Wald statistics for the population-model parameters: no
Hessian on \\(\boldsymbol{\beta}, \log\sigma^2)\\ is extracted from the
marginal log-likelihood, and no
[`vcov()`](https://rdrr.io/r/stats/vcov.html) method is exposed for
these coefficients. Treat the coefficient table as point estimates
suitable for descriptive reporting; **do not** quote \\\hat{\beta}\_j
\pm 1.96 \cdot \mathrm{SE}\\ bounds because the SE column is not
provided. A marginal-Hessian-based SE for \\(\boldsymbol{\beta},
\sigma^2)\\ is not available from this function.

Identification: the latent-regression intercept is identifiable only
under the default `noncenter_facet = "Person"` (which sum-to-zero-
centers all non-Person facets). `fit_mfrm()` therefore rejects an active
latent-regression model with a different `noncenter_facet` rather than
returning a confounded intercept.

Anchor inputs are optional:

- `anchors` should contain facet/level/fixed-value information.

- `group_anchors` should contain facet/level/group/group-value
  information. Both are normalized internally, so column names can be
  flexible (`facet`, `level`, `anchor`, `group`, `groupvalue`, etc.).

Anchor review behavior:

- `fit_mfrm()` automatically runs an anchor review.

- invalid rows are removed before estimation.

- duplicate rows keep the last occurrence for each key.

- `anchor_policy` controls whether detected issues are warned, treated
  as errors, or kept silent.

Facet sign orientation:

- facets listed in `positive_facets` are treated as `+1`

- all other facets are treated as `-1` This affects interpretation of
  reported facet measures.

## Estimator-specific estimability preflight

Before optimization, mfrmr builds a sparse adjacent-category-logit
design in the same constrained free coordinates used by the optimizer.
The check includes Person coordinates for JML, integrates them out for
MML, and includes facet anchors, group constraints, signs, supported
two-way interactions, and RSM/PCM step coordinates.

An exactly rank-deficient design stops with a structured
`mfrmr_estimability_error`; its `estimability` field records rank,
nullity, parameter blocks, tolerance checks, and a bounded
null-direction explanation. Optimization is not run. A full-rank MML
fixed-effect design whose corresponding free-Person JML design is rank
deficient returns a fit with an `mfrmr_estimability_warning`: its
cross-panel contrasts rely on the common latent-population assumption
and remain review-only.

Inspect `fit$data_review$estimability`. RSM and PCM use the full linear
free-coordinate check. For bounded GPCM and an active latent-regression
residual variance, the additive block is audited before fitting. A
retained vector also records the analytic free-to-expanded
log/natural-scale transformation Jacobians and a central-difference
check in `fit$data_review$estimability$nonlinear_transformation`. This
verifies the parameterization only; it is not a response-likelihood
Jacobian or a structural-identification result. A stationary retained
solution of modest free dimension also receives a local
observed-information Hessian and a recorded eigenvalue-tolerance ladder
in `fit$data_review$estimability$fitted_information`. Nonstationary or
larger fits retain an explicit not-evaluated status. This
fitted-information layer is diagnostic only: it does not yet classify
weak information, make the nonlinear preflight complete, or turn full
additive rank into a full-model estimability claim. Eligible nonlinear
MML fits also receive bounded observed-pattern and all-response-pattern
score checks. The latter operates on each Person's retained observation
design under unit row weights and records probability-normalization,
zero-expected-score, expected-information, and selected
numerical-derivative summaries. Missing rows are not imputed; nonunit
weights and excessive pattern grids retain explicit not-evaluated
states. Mathematically identical Person observation designs are
evaluated once and reconstructed by exact multiplicity; active
latent-regression covariate rows are part of this identity. Only
conceptual and evaluated workload summaries are retained. These
retained-point diagnostics do not by themselves establish global
structural identification, weak-information status, or readiness.

`fit$data_review$estimability$nonlinear_local_estimability` interprets
only the first-order local rank that these maps support. For JML GPCM,
full column rank of the complete conditional adjacent-logit Jacobian is
a sufficient retained-point local certificate. For fixed-quadrature MML
with unit row weights and finite parameters, the Person-specific
observed- pattern score vectors are part of the positive finite
response-pattern support. If those vectors span every optimizer free
coordinate, the full expected score information is positive definite;
exhaustive enumeration is unnecessary for this sufficient direction. A
rank-deficient observed subset is inconclusive and is classified only
when the all-pattern enumeration is available. The record explicitly
leaves continuous-integral and global identification, boundary status,
weak information, and inference readiness unclassified.

## Choosing maxit without result-driven tuning

Treat `maxit` as a predeclared computational budget, not as a value to
tune until preferred estimates appear.

1.  Choose the model, estimation method, optimizer, tolerance,
    quadrature rule, and initial `maxit` before examining coefficient or
    fit results. The default `maxit = 400` is the package starting point
    for an analysis.

2.  Use estimates substantively only when `FitReadiness == "ready"` and
    `InferenceReady` is `TRUE`. Also inspect purpose-specific Design,
    Stability, Diagnostics, and Reporting workflow rows. Optimizer code
    zero alone is insufficient.

3.  If `ConvergenceStatus == "iteration_limit"`, keep that fit
    review-only. Refit the same data, model, method, anchors, optimizer,
    tolerance, and quadrature rule with the next ceiling in a
    prespecified sequence, such as 400, 800, then 1600. Do not choose
    among runs by coefficient size, statistical significance, fit
    statistics, or agreement with an expected answer.

4.  The first run in that sequence that clears the numerical gate
    becomes eligible for interpretation. If separately ready runs differ
    materially, treat the difference as numerical instability and review
    the model, identification, data support, and optimizer rather than
    selecting the preferred result.

5.  Report the requested `maxit`, actual iteration/evaluation counts,
    convergence status and reason, optimizer, terminal gradient, and any
    polishing stages. These are retained in `fit$summary` and
    `fit$opt$optimizer_polish`.

This rule applies to both JML and MML. JML can require a larger
computation budget because it estimates one fixed effect per person;
increasing `maxit` does not make JML equivalent to MML and must not be
used to switch the estimand after seeing results.

## Performance tips

When JML is the prespecified estimand, it is often faster than MML but
may require a larger `maxit` on larger datasets. Do not switch from MML
to JML only to shorten runtime: integrating over a population
distribution and treating person parameters as fixed effects are
different analysis choices.

For MML runs, `quad_points` is the main accuracy/speed trade-off. The
`@param quad_points` tier table is the authoritative reference; in
short:

- `quad_points = 7` is a lightweight screening setting; do not use its
  IC values for automatic model selection.

- `quad_points = 15` is an intermediate review option when runtime
  matters; automatic IC ranking remains disabled.

- `quad_points = 31` is the package default and a suitable starting
  point for a final analysis; always review convergence and, when
  conclusions are sensitive, compare a denser quadrature rule.

- `quad_points = 61` (or higher) supports sensitivity checks on narrow
  score distributions at additional computational cost.

- `mml_engine = "direct"` remains the most stable general-purpose path.

- `mml_engine = "em"` or `"hybrid"` currently target `RSM` / `PCM` fits
  without a latent-regression population model.

- Benchmark your own workload before using `mml_engine = "em"` or
  `"hybrid"` for final reporting; `direct` remains the documented
  default when you have not compared engines for your data.

- When a direct code-zero stage stops ahead of the terminal-gradient
  gate, bounded polishing is automatic. Inspect
  `fit$opt$optimizer_polish$Stages` rather than repeatedly lowering
  `reltol` without reviewing the retained objective, gradient, and
  parameter changes.

Downstream diagnostics can also be staged:

- use `diagnose_mfrm(fit, residual_pca = "none")` for a quick first pass

- add residual PCA only when you need exploratory residual-structure
  evidence

Downstream diagnostics report `ModelSE` / `RealSE` columns and related
reliability indices. For `MML`, non-person facet `ModelSE` values are
based on the observed information of the marginal log-likelihood and
person rows use posterior SDs from EAP scoring. For `JML`, these
quantities remain exploratory approximations and should not be treated
as equally formal.

For bounded `GPCM`, residual-based mean-square fit screens are also best
treated as exploratory diagnostics rather than strict Rasch-style
invariance tests, because the discrimination parameter is free.

## Interpreting output

A typical first-pass read is:

1.  `fit$summary` for convergence and global fit indicators.

2.  `summary(fit)` for human-readable overviews.

3.  for `RSM` / `PCM`, `diagnose_mfrm(fit)` for element-level fit,
    approximate separation/reliability, and warning tables.

4.  for bounded `GPCM`, use
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
    and the residual-based table helpers as exploratory screens,
    together with posterior scoring /
    [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md)
    where documented.

## Typical workflow

1.  Fit the model with `fit_mfrm(...)`.

2.  Validate convergence and scale structure with `summary(fit)`.

3.  For `RSM` / `PCM`, run
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
    and proceed to reporting with
    [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md).

4.  For bounded `GPCM`, use the fitted object, slope summary,
    [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
    residual-based table helpers, posterior scoring helpers,
    [`compute_information()`](https://ryuya-dot-com.github.io/mfrmr/reference/compute_information.md),
    direct simulation/recovery helpers,
    [`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md),
    and
    [`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md)
    with their documented caveats. Use
    [`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)
    to confirm which helper families are currently supported, caveated,
    blocked, or deferred.

## Information-criterion contract

For an eligible fixed-facet `MML` fit, let `D = -2 * LogLik`, let `k` be
`Npar` (the retained free optimization-vector dimension after
constraints), and let `N_person` be the number of unique prepared
Persons. The canonical panel is `AIC = D + 2 * k`,
`BIC = D + log(N_person) * k`, and
`SABIC = D + log((N_person + 2) / 24) * k`.

`ResponseRows`, `WeightedResponseTotal`, `Persons`, and `ICSampleSize`
are separate fields. The compatibility field `N` retains its earlier
response-row or summed-observation-weight meaning and is not the 0.2.3
BIC sample size. Explicit all-unit weights remain eligible; every
non-unit observation-weight fit, JML fit, and object without the current
contract identity is excluded from the common MML panel. Its canonical
`AIC`/`BIC`/`SABIC` fields are `NA`, while any retained raw values are
explicitly named `LegacyAIC` and `LegacyBIC`. At 22 or fewer Persons,
SABIC is displayed only as sensitivity evidence and
`SABICSelectable = FALSE`.

Integration adequacy is recorded separately from formula eligibility.
`ICIntegrationTier` is `"coarse_screening"` below 15 points,
`"intermediate_review"` at 15–30, `"standard_start"` at 31–60, and
`"dense_sensitivity"` at 61 or more. Raw canonical criteria remain
visible in every eligible MML tier, but `ICSelectable = FALSE` below 31
points; automatic deltas, criterion weights, preferences, and LRT are
suppressed. A close or consequential q\>=31 comparison should still be
reevaluated on a denser common grid.

## References

The ordered-category many-facet formulation follows Linacre (1989), with
the `RSM` and `PCM` branches grounded in Andrich (1978) and Masters
(1982). The bounded `GPCM` branch follows the generalized partial credit
formulation of Muraki (1992) under a package-specific positive log-slope
identification convention. The `MML` route follows the quadrature-based
marginal-likelihood framework of Bock and Aitkin (1981).

- Akaike, H. (1974). *A new look at the statistical model
  identification*. IEEE Transactions on Automatic Control, 19(6),
  716-723.

- Andrich, D. (1978). *A rating formulation for ordered response
  categories*. Psychometrika, 43(4), 561-573.

- Bock, R. D., & Aitkin, M. (1981). *Marginal maximum likelihood
  estimation of item parameters: Application of an EM algorithm*.
  Psychometrika, 46(4), 443-459.

- Linacre, J. M. (1989). *Many-facet Rasch measurement*. MESA Press.

- Masters, G. N. (1982). *A Rasch model for partial credit scoring*.
  Psychometrika, 47(2), 149-174.

- Myford, C. M., & Wolfe, E. W. (2003). Detecting and measuring rater
  effects using many-facet Rasch measurement: Part I. *Journal of
  Applied Measurement*, 4(4), 386-422.

- Myford, C. M., & Wolfe, E. W. (2004). Detecting and measuring rater
  effects using many-facet Rasch measurement: Part II. *Journal of
  Applied Measurement*, 5(2), 189-227.

- Muraki, E. (1992). *A generalized partial credit model: Application of
  an EM algorithm*. Applied Psychological Measurement, 16(2), 159-176.

- Uto, M., & Ueno, M. (2020). *A generalized many-facet Rasch model and
  its Bayesian estimation using Hamiltonian Monte Carlo*.
  Behaviormetrika, 47, 469-496.

- Robitzsch, A., & Steinfeld, J. (2018). *Item response models for human
  ratings: Overview, estimation methods, and implementation in R*.
  Psychological Test and Assessment Modeling, 60(1), 101-139.

- Schwarz, G. (1978). *Estimating the dimension of a model*. Annals of
  Statistics, 6(2), 461-464.

- Sclove, S. L. (1987). *Application of model-selection criteria to some
  problems in multivariate analysis*. Psychometrika, 52(3), 333-343.

## See also

[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md),
[gpcm_capability_matrix](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md),
[mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md),
[mfrmr_reporting_and_apa](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reporting_and_apa.md)

## Examples

``` r
# Lightweight executable mechanics example on the connected teaching data.
# The small quadrature grid keeps CRAN example time short; the tighter
# portable tolerance setting keeps this reduced example numerically stable.
# Use the documented default grid and a sensitivity check for final work.
toy <- load_mfrmr_data("example_operational")
fit_quick <- fit_mfrm(
  toy, "Person", c("Rater", "Criterion"), "Score",
  method = "MML", model = "RSM", quad_points = 7, maxit = 30,
  reltol = 1e-11
)
fit_quick$summary[, c(
  "Model", "Method", "N", "Converged", "FitReadiness",
  "InferenceReady", "ConvergenceSeverity"
)]
#> # A tibble: 1 × 7
#>   Model Method     N Converged FitReadiness InferenceReady ConvergenceSeverity
#>   <chr> <chr>  <dbl> <lgl>     <chr>        <lgl>          <chr>              
#> 1 RSM   MML      282 TRUE      ready        TRUE           pass               

# \donttest{
# Full run with the package default MML estimator. This route integrates
# person parameters under an N(0, 1) population model, so its reporting
# value depends on the response-model and population assumptions. The
# default `quad_points = 31` is a practical starting value; compare a
# larger grid when quadrature sensitivity matters.
fit <- fit_mfrm(
  data = toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  model = "RSM",
  quad_points = 31
)
fit$summary
#> # A tibble: 1 × 87
#>   Model Method MethodUsed ICContractVersion      N ResponseRows
#>   <chr> <chr>  <chr>      <chr>              <dbl>        <int>
#> 1 RSM   MML    MML        mfrmr_ic_person_v2   282          282
#> # ℹ 81 more variables: WeightedResponseTotal <dbl>, Persons <int>, Npar <int>,
#> #   Facets <int>, FacetInteractions <int>, InteractionParameters <int>,
#> #   InteractionCells <int>, InteractionSparseCells <int>, Categories <dbl>,
#> #   LogLik <dbl>, Deviance <dbl>, WeightPolicy <chr>, ICEligible <lgl>,
#> #   ICSelectable <lgl>, ICStatus <chr>, ICSampleSize <dbl>,
#> #   ICSampleSizeBasis <chr>, AIC <dbl>, BIC <dbl>, SABIC <dbl>,
#> #   SABICSelectable <lgl>, AICFormula <chr>, BICFormula <chr>, …
s_fit <- summary(fit)
s_fit$overview[, c("Model", "Method", "Converged", "FitReadiness",
                   "InferenceReady", "ConvergenceSeverity")]
#> # A tibble: 1 × 6
#>   Model Method Converged FitReadiness InferenceReady ConvergenceSeverity
#>   <chr> <chr>  <lgl>     <chr>        <lgl>          <chr>              
#> 1 RSM   MML    TRUE      ready        TRUE           pass               
# `InferenceReady = FALSE` is a conservative fit-level stop signal. The
# stored component states identify whether input, estimability, category,
# boundary, or numerical review caused it.
s_fit$person_overview
#> # A tibble: 1 × 11
#>   Persons DistributionN ReviewExcludedExtremeE…¹ EstimateUse   Mean    SD Median
#>     <int>         <int>                    <int> <chr>        <dbl> <dbl>  <dbl>
#> 1      48            48                        0 source_fit… -0.155 0.824 -0.208
#> # ℹ abbreviated name: ¹​ReviewExcludedExtremeEAPs
#> # ℹ 4 more variables: Min <dbl>, Max <dbl>, Span <dbl>, MeanPosteriorSD <dbl>
# Compare the person distribution with the facet and step locations. The
# scale identification does not create universal targeting thresholds.
s_fit$targeting
#> # A tibble: 2 × 7
#>   Facet     PersonMean FacetMean Targeting PersonSD FacetSD SpreadRatio
#>   <chr>          <dbl>     <dbl>     <dbl>    <dbl>   <dbl>       <dbl>
#> 1 Criterion     -0.155  4.62e-18    -0.155    0.824   0.302        2.72
#> 2 Rater         -0.155  0           -0.155    0.824   0.399        2.07
# Interpret targeting magnitude against the intended population and score
# use rather than a universal pass/fail cutoff.
p_fit <- plot(fit, draw = FALSE)
p_fit$name
#> [1] "wright_map"
head(p_fit$data$locations)
#> # A tibble: 6 × 37
#>   Group Label PlotType    Estimate    SE CI_Level SE_Method        PrecisionTier
#>   <fct> <chr> <chr>          <dbl> <dbl>    <dbl> <chr>            <chr>        
#> 1 Rater R01   Facet level   -0.606 0.181     0.95 Observation-tab… exploratory  
#> 2 Rater R02   Facet level   -0.382 0.166     0.95 Observation-tab… exploratory  
#> 3 Rater R04   Facet level    0.180 0.185     0.95 Observation-tab… exploratory  
#> 4 Rater R05   Facet level    0.184 0.199     0.95 Observation-tab… exploratory  
#> 5 Rater R03   Facet level    0.212 0.179     0.95 Observation-tab… exploratory  
#> 6 Rater R06   Facet level    0.412 0.219     0.95 Observation-tab… exploratory  
#> # ℹ 29 more variables: SupportsFormalInference <lgl>, SEUse <chr>,
#> #   CIBasis <chr>, CIUse <chr>, CIEligible <lgl>, CILabel <chr>,
#> #   Measure_Source <chr>, CI_Lower <dbl>, CI_Upper <dbl>, Step <chr>,
#> #   StepIndex <int>, BoundarySeparated <lgl>, XBase <dbl>, X <dbl>,
#> #   OriginalEstimate <dbl>, BelowRange <lgl>, AboveRange <lgl>,
#> #   DisplayEstimate <dbl>, DisplayLabel <chr>, OriginalCI_Lower <dbl>,
#> #   OriginalCI_Upper <dbl>, DisplayCI_Lower <dbl>, DisplayCI_Upper <dbl>, …
# The bare plot route is the native Wright map and includes available
# facet uncertainty. Use plot(fit, type = "bundle") for the three-plot
# Wright/pathway/category overview.

# JML is a distinct fixed-person-effects route, not a drop-in speed setting:
fit_jml <- fit_mfrm(
  data = toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "JML",
  model = "RSM"
)
summary(fit_jml)$overview[, c(
  "Model", "Method", "Converged", "InferenceReady",
  "ConvergenceSeverity"
)]
#> # A tibble: 1 × 5
#>   Model Method Converged InferenceReady ConvergenceSeverity
#>   <chr> <chr>  <lgl>     <lgl>          <chr>              
#> 1 RSM   JML    TRUE      TRUE           pass               

# Latent regression (MML only) uses person-level background variables:
person_tbl <- unique(toy[c("Person")])
person_tbl$Grade <- seq_len(nrow(person_tbl))
person_tbl$Group <- rep(c("A", "B"), length.out = nrow(person_tbl))
fit_pop <- fit_mfrm(
  data = toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  population_formula = ~ Grade + Group,
  person_data = person_tbl
)
summary(fit_pop)$population_overview
#> # A tibble: 1 × 16
#>   PopulationModel PosteriorBasis   Source  IdentificationRole Formula PersonRows
#>   <lgl>           <chr>            <chr>   <chr>              <chr>        <int>
#> 1 TRUE            population_model user_s… not_applicable     ~Grade…         48
#> # ℹ 10 more variables: DesignColumns <int>, CodingVariables <chr>,
#> #   ContrastVariables <chr>, Policy <chr>, EstimationConverged <lgl>,
#> #   InferenceReady <lgl>, LegacyConvergedBasis <chr>, ResidualVariance <dbl>,
#> #   OmittedPersons <int>, OmittedRows <int>
summary(fit_pop)$population_coding
#> # A tibble: 1 × 6
#>   Variable LevelCount Levels Contrast        EncodedColumns CodingNote          
#>   <chr>         <int> <chr>  <chr>           <chr>          <chr>               
#> 1 Group             2 A, B   contr.treatment GroupB         stored levels and c…

# Binary responses are supported as ordered two-category scores:
set.seed(1)
binary_toy <- expand.grid(
  Person = paste0("P", 1:30),
  Item = paste0("I", 1:4),
  stringsAsFactors = FALSE
)
theta <- stats::rnorm(length(unique(binary_toy$Person)))
beta <- seq(-0.8, 0.8, length.out = length(unique(binary_toy$Item)))
eta <- theta[match(binary_toy$Person, unique(binary_toy$Person))] -
  beta[match(binary_toy$Item, unique(binary_toy$Item))]
binary_toy$Score <- stats::rbinom(nrow(binary_toy), 1, stats::plogis(eta))
fit_binary <- fit_mfrm(
  data = binary_toy,
  person = "Person",
  facets = "Item",
  score = "Score",
  model = "RSM",
  method = "JML",
  maxit = 30
)
#> Warning: Optimization convergence review did not produce an inference-ready numerical solution (code = 1, status = iteration_limit). Optimizer reached the iteration limit before the terminal gradient became small enough for review-only acceptance. Inspect the model specification, data support, and starting values. Do not interpret estimates until the review is resolved.
fit_binary$summary[, c("Model", "Categories", "Converged")]
#> # A tibble: 1 × 3
#>   Model Categories Converged
#>   <chr>      <dbl> <lgl>    
#> 1 RSM            2 FALSE    

# Next steps after fitting:
diag <- diagnose_mfrm(fit, residual_pca = "none")
chk <- reporting_checklist(fit, diagnostics = diag)
head(chk$checklist[, c("Section", "Item", "DraftReady")])
#>          Section                                                      Item
#> 1 Method Section                                       Model specification
#> 2 Method Section                                          Data description
#> 3 Method Section                                           Precision basis
#> 4 Method Section                                               Convergence
#> 5 Method Section                                     Connectivity assessed
#> 6 Method Section Empirical-Bayes shrinkage when small-N facets are present
#>   DraftReady
#> 1       TRUE
#> 2       TRUE
#> 3       TRUE
#> 4       TRUE
#> 5       TRUE
#> 6       TRUE
# }
```
