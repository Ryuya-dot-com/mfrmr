# Fit many-facet ordered-response models with a flexible number of facets

Estimate effects on ordered ratings, such as rater severity and
criterion difficulty, and Person abilities where the estimator supplies
them. A facet is one such source of variation; its levels are the
individual raters or criteria. Each data row is one rating. Supply its
column names with `person`, `facets`, and `score`, as in the complete
example below. The default is `method = "MML"` (marginal maximum
likelihood). The `RSM` / `PCM` branches are the package's many-facet
Rasch-family reference route. `GPCM` adds positive, level-specific
discriminations to one facet, or provisionally to two facets under MML.
With one family, MML permits a different facet to supply category steps;
JML requires the same facet for both roles. Start with "Choose a model
and its population" below; the model-specific sections explain
uncertainty and comparisons. In the example, `ratings` stores the data
and `fit` stores the fitted model. The loading line reads an existing
packaged synthetic dataset; you do not need to generate ratings or
create an empty object first. Quoted column names such as `"Person"`
must match the data, including case. For your own CSV, see the "Use your
own CSV" section of
[`vignette("mfrmr-workflow", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-workflow.md).
If the vignette is not installed,
[mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md)
and
[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
explain the input checks. Pass the reviewed rating data frame to `data`,
not the object returned by
[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md).
Before adapting the example, read "Check defaults before adapting an
example" in
[mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md).
The score ladder, missing-row handling and population distribution are
analysis choices even when arguments are omitted.

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
  method = c("MML", "JML", "JMLE", "CML"),
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
  gpcm_mml_identification = c("free_population", "fixed_standard_normal"),
  mml_integration = c("fixed", "adaptive", "auto"),
  category_policy = NULL,
  em_score_tol = NULL,
  jml_correction_order = NULL,
  jml_correction_sampling = c("fixed_rosters", "random_rosters"),
  gpcm_mml_start = NULL,
  repeated_ratings = c("review", "independent"),
  centering_scope = c("facet", "remainder", "anchor_origin"),
  fit_scope = c("full", "comparisons"),
  comparison_review = NULL,
  mml_accuracy_control = NULL,
  population_sd = NULL,
  jml_penalty = c("none", "jeffreys"),
  progress = FALSE
)

# S3 method for class 'mfrm_cml_fit'
summary(object, ...)

# S3 method for class 'mfrm_cml_fit'
print(x, ...)

# S3 method for class 'mfrm_comparison_fit'
print(x, ...)

# S3 method for class 'mfrm_comparison_fit'
summary(object, ...)
```

## Arguments

- data :

  A data.frame in long format with one row per observed rating event.
  Grouped or rowwise tibbles are analyzed as one table; dplyr grouping
  metadata is ignored. The named model columns define the design.

- person :

  Column name for the person (character scalar).

- facets :

  Character vector of facet column names. Facets cannot be named
  `Person`, `Score`, `Weight`, `score_k`, `theta`, `steps`,
  `interactions`, `log_slopes`, `beta` or `log_sigma2`, which are
  reserved data/parameter names. Rename such facet columns before
  analysis. Similar names such as `beta_group` are supported and matched
  exactly. Data-column names remain available for their intended roles,
  such as `person = "Person"`, `score = "Score"` and
  `weight = "Weight"`.

- score :

  Column name for the observed ordered category score. Values must be
  coercible to real integer category codes within R's integer range.
  Shared preparation rounds values within `1e-6` of an integer to the
  nearest category, recording normalization in
  `fit$prep$preparation_notes`; other fractional values are rejected.
  Corrected JML and two-family GPCM require exact integer inputs;
  normalize roundoff explicitly before those specialized fits. Binary
  `0/1` or `1/2` responses are supported as the ordered two-category
  special case. When `keep_original = FALSE`, unused intermediate
  categories are collapsed to a contiguous internal scale and the
  mapping is recorded in `fit$prep$score_map`. If `rating_min` /
  `rating_max` are supplied and the observed scores are a contiguous
  subset of that range (for example a 1-5 scale with only 2-5 observed),
  the supplied full range is retained so zero-count boundary categories
  remain visible in the data-support review. A zero-count boundary
  category is retained as review evidence. With `keep_original = TRUE`,
  however, an unobserved internal category in a polytomous fitted ladder
  creates an unsupported adjacent-step contrast and fitting stops before
  optimization with a structured category-support error. The explicit
  Jeffreys route below retains empty categories under a different
  estimating equation; it does not certify ordinary finite MLEs.

- rating_min :

  Optional minimum category value. Supply this with `rating_max` when
  the intended score scale includes unobserved boundary categories.

- rating_max :

  Optional maximum category value. Supply this with `rating_min` when
  the intended score scale includes unobserved boundary categories.

- weight :

  Optional weight column name. Numeric weights retain their supplied
  precision; character/factor weights are parsed from their labels.
  Retained weights must have a finite sum and are not automatically
  rescaled.

- keep_original :

  Logical. `FALSE` (the current default) collapses non-consecutive
  observed categories to a contiguous internal scale and records the
  mapping in `fit$prep$score_map` (the downstream Count = 0 rows are
  consequently absent). `TRUE` preserves the declared scale so unused
  intermediate categories remain visible in
  [`rating_scale_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/rating_scale_table.md)
  and APA outputs, which is recommended for preserving the rubric. This
  changes which category steps are fitted, not just their displayed
  labels. Fitting stops if a retained internal category has no
  observations; reviewing or revising that ladder is a substantive
  decision, not a formatting option. Retained for compatibility;
  `category_policy = "preserve"` or `"collapse"` makes the choice
  explicit in new code.

- missing_codes :

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

- model :

  `"RSM"` (default), `"PCM"`, or `"GPCM"`.

- method :

  `"MML"` (default), `"JML"`, or `"CML"`. `"JMLE"` is accepted as a
  backward-compatible alias for the same joint-maximum-likelihood path.
  Native CML supports RSM/PCM with preserved categories and unit
  weights; see "Conditional maximum likelihood" for its distinct result
  class.

- step_facet :

  Facet whose levels receive separate step parameters in `PCM` and
  `GPCM`. Supply exactly one facet name for a final analysis. If it is
  omitted for `PCM`, mfrmr uses a unique item-like facet name (for
  example, `Item`, `Task`, or `Criterion`) when available; otherwise it
  retains the first-facet fallback with a warning. `GPCM` always
  requires an explicit value. CML also requires an explicit PCM step
  owner. This argument is not used by `RSM`, which has one shared set of
  rating-scale thresholds.

- slope_facet :

  Slope facet for the `GPCM` branch. mfrmr estimates one positive slope
  for every level of this designated facet. Thus
  `slope_facet = "Criterion"` gives criterion-specific slopes, whereas
  `slope_facet = "Rater"` gives rater-specific slopes. For one slope
  family, MML allows a distinct `step_facet`; JML requires
  `slope_facet == step_facet`. Criterion and rater slope blocks can also
  be estimated together with an ordered pair of column names; see "Two
  slope families" below for the explicit MML contract. With one family,
  slopes are identified on the log scale with their geometric mean fixed
  to 1, so the table reports relative discrimination across the selected
  facet's levels rather than unrelated absolute weights.

- facet_interactions :

  Optional confirmatory two-way interaction terms between non-person
  facets, supplied as explicit character terms such as
  `"Rater:Criterion"` or as a list of length-two character vectors.
  These interactions are estimated simultaneously as fixed effects in
  `RSM` and `PCM` fits. Person-involving interactions, higher-order
  interactions, and random-effect interaction terms are outside the
  current scope.

- min_obs_per_interaction :

  Minimum weighted observations recommended for each interaction cell.
  Cells below this value are flagged in
  [`interaction_effect_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/interaction_effect_table.md)
  and handled according to `interaction_policy`.

- interaction_policy :

  How to handle sparse interaction cells: `"warn"` (default), `"error"`,
  or `"silent"`.

- anchors :

  Optional table with `Facet`, `Level`, and `Anchor` columns. Each
  retained row fixes a location in internal logit coordinates; it is not
  merely a declaration that an element is common. Person anchors require
  JML; MML rejects them. See **Anchors and scale constraints** below.

- group_anchors :

  Optional group-mean constraint table with facet, level, group, and
  target-value columns. Its use requires a defensible external
  assumption about the group target; it does not create observed
  overlap. Use columns `Facet`, `Level`, `Group`, and `GroupValue`.
  Person group constraints require JML.

- noncenter_facet :

  One facet to leave non-centered (default `"Person"`). Other facets use
  the convention selected by `centering_scope`. To estimate a cohort
  mean while leaving an anchored RSM/PCM facet uncentered, also set
  `population_formula = ~ 1` and `population_sd`; see **Anchor origin
  and cohort means**.

- dummy_facets :

  Facets to fix at zero.

- positive_facets :

  Facets with positive orientation.

- anchor_policy :

  How to handle anchor-review issues: `"warn"` (default), `"error"`, or
  `"silent"`.

- min_common_anchors :

  Minimum directly anchored levels per non-Person facet used in the
  package's local count recommendation. This does not verify cross-run
  element identity, invariance, or empirical connectedness.

- min_obs_per_element :

  Minimum weighted observations per facet level used in anchor-review
  recommendations.

- min_obs_per_category :

  Minimum weighted observations per score category used in anchor-review
  recommendations.

- quad_points :

  Integer number of Gauss-Hermite quadrature points used for MML
  integration over the person distribution. The default is `31`. Useful
  accuracy/runtime settings are:

  |  |  |
  |----|----|
  | `7` | lightweight screening run; information-criterion deltas, weights, preferences, and LRT are disabled. Helpers such as [`predict_mfrm_population()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_population.md) and [`reference_case_benchmark()`](https://ryuya-dot-com.github.io/mfrmr/reference/reference_case_benchmark.md) use this value. |
  | `15` | intermediate review run when runtime matters; automatic model ranking remains disabled. |
  | `31` | package default and a starting grid, not evidence by itself that numerical integration is adequate. |
  | `61+` | user-selected denser grids for same-data sensitivity review; no single order is adequate for every response pattern. |

  Quadrature adequacy depends on the fitted distribution and score
  support. Orders whose weights cannot all be represented as positive
  finite doubles produce an error; increasing the order indefinitely is
  not supported. Use
  [`mml_quadrature_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mml_quadrature_sensitivity.md)
  to compare the same model and data on user-selected grids before
  portable calibration and whenever numerical movement could affect a
  consequential result. The helper reports continuous differences
  without choosing a cutoff. Raw AIC/BIC/SABIC remain visible below 31
  points for diagnosis, but
  [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
  fails closed rather than turning a screening/review grid into
  automatic selection.

- maxit :

  Computational ceiling on optimizer iterations. The default is `400`;
  for two-family EM this counts outer EM iterations. Two-family adaptive
  initialization also allows this many EM seed iterations; it then
  applies separately to every direct optimizer stage at each start. For
  corrected JML it applies separately to each recorded root-solving
  stage. This is not a convergence criterion or a model-selection
  control: a fit that reaches the ceiling remains non-ready until the
  common convergence and terminal-gradient checks pass. Smaller values
  used in brief examples are for demonstration only and should not be
  copied into a substantive analysis without an explicit computational
  protocol.

- reltol :

  Portable tolerance setting for the initial optimizer stage. For
  two-family fixed-grid EM, omit this argument and use `em_score_tol`.
  Adaptive two-family direct MML uses `reltol` and the direct
  optimizer's gradient check. New two-family adaptive fits cap the
  ordinary total-gradient review tolerance at `N * 1e-6`, where N is the
  number of fitted Persons; a stricter ordinary tolerance is retained.
  This aligns optimizer finishing with the subsequent per-Person score
  check. The rule is recorded in the fitted controls; older saved fits
  retain their recorded review convention. Curvature, derivative and
  integration checks remain separate. The default is `1e-9`. For BFGS
  this is passed as `reltol`; for L-BFGS-B it is mapped to `factr` and
  `pgtol`, whose actual values are recorded in the fit. When this
  setting is at least as strict as the public default
  (`reltol <= 1e-9`), optimizer code zero followed by a failed common
  terminal-gradient review triggers a bounded warm-started polish
  ladder. The best non-worsening stage under the recorded selection rule
  is retained. Requested and selected-stage settings remain in
  `fit$summary`, and the complete stage history remains in
  `fit$opt$optimizer_polish`. Ordinary additive RSM/PCM JML without
  shrinkage can finish a remaining stall with at most three sparse
  Newton steps from the exact likelihood information. Each step must
  reduce the gradient without likelihood loss beyond roundoff, pass its
  linear-solve check and move no coordinate by more than one logit.
  Extreme Persons, nonpositive information and failed proposals retain
  their diagnostic state. The final stage is labelled
  `jml_information_polish`, with method `Newton`, `InformationSteps` and
  `InformationSolveResidual`. This does not correct JML bias or qualify
  interval coverage; the original terminal-gradient criterion still
  applies. If ordinary polishing still stalls, fixed-grid RSM/PCM/GPCM
  MML fits (including estimated population parameters) or adaptive GPCM
  MML fits with a fixed population can use one local curvature step to
  restart the selected optimizer, provided there are at most 64 free
  parameters. The step requires positive-definite, well-conditioned
  curvature, a smaller gradient and an objective that does not worsen
  beyond floating-point roundoff. The original convergence and
  terminal-gradient criteria still apply; failed proposals retain their
  reasons in the stage history. Fixed-grid GPCM MML fits with at most 64
  free parameters also check numerical curvature after optimizer code
  zero. Negative curvature can trigger up to three BFGS restarts in
  rescaled search coordinates, even when the raw gradient is small. Each
  restart uses the requested `maxit` ceiling. A replacement must pass
  the original gradient/convergence checks, have no detected negative
  curvature and not worsen the objective beyond roundoff. Failed
  recovery retains the estimate with a numerical warning. This changes
  only the search coordinates, not the model or information matrix used
  for inference. It does not establish a global optimum, adequate
  quadrature, or valid confidence intervals. Inspect the
  `SmallestCurvature`, `CurvatureScale` and `CurvatureReviewError`
  fields in the stage history alongside the objective and terminal
  gradient.

- optimizer :

  Direct-optimization method. `"auto"` (default) uses the BFGS M step
  for the two-family EM route. For other routes it uses the
  limited-memory `"L-BFGS-B"` method for MML and for larger JML
  parameter vectors (at least 200 free parameters), while retaining BFGS
  for smaller JML fits. Use `"BFGS"` or `"L-BFGS-B"` to request one
  method explicitly. The method actually used is recorded in
  `fit$summary$OptimizerMethod`. For L-BFGS-B, inspect `OptimizerFactr`
  and `OptimizerPgtol` rather than interpreting `EffectiveReltol` as a
  native [`stats::optim()`](https://rdrr.io/r/stats/optim.html) control.

- mml_engine :

  MML optimization engine for `method = "MML"`: `"direct"` (default)
  uses the selected direct optimizer on the marginal log-likelihood,
  `"em"` uses an EM loop for `RSM` / `PCM` with `population = NULL`, or
  the explicitly scoped two-family GPCM route described below, and
  `"hybrid"` uses EM as a warm start before the direct optimizer.
  Unsupported one-family combinations fall back to `"direct"` and record
  that fallback in `fit$summary`. Direct, hybrid, and EM engines all
  require the common terminal-gradient check for the Numerical component
  of fit readiness; EM relative log-likelihood convergence alone does
  not establish numerical readiness. `InferenceReady` is `TRUE` only
  when every stored fit-readiness component passes.

- population_formula :

  Optional one-sided formula for a person-level latent-regression
  population model, for example `~ grade + ses`. Latent regression is
  implemented only for `method = "MML"` with a unidimensional
  conditional-normal population model. With `NULL`, RSM/PCM MML uses a
  fixed \\N(0,1)\\ basis; default GPCM MML instead estimates an
  intercept-only normal population. Version 0.2.4 does not accept
  arbitrary fixed normal means or standard deviations: portable RSM/PCM
  calibration and its anchors are defined on the standard-normal basis,
  and a silent change of basis would change the meaning of those stored
  values. A formula-compatible `terms` object returned in
  `attr(simulated_data, "mfrm_population_data")$population_formula` is
  also accepted, preserving the simulation template's transformation
  basis, factor levels and contrasts when refitting generated data.

- person_data :

  Optional one-row-per-person data.frame holding background variables
  for `population_formula`. Numeric, logical, factor, ordered factor,
  and character predictors are expanded through
  [`stats::model.matrix()`](https://rdrr.io/r/stats/model.matrix.html);
  categorical xlevels and contrasts are stored for replay and scoring.
  Prediction-aware transformations such as
  [`scale()`](https://rdrr.io/r/base/scale.html),
  [`poly()`](https://rdrr.io/r/stats/poly.html) and
  [`splines::ns()`](https://rdrr.io/r/splines/ns.html) retain their
  training basis when scoring new persons. Required when
  `population_formula` is supplied.

- person_id :

  Optional person-ID column in `person_data`. Defaults to `person` when
  that column exists in `person_data`.

- population_policy :

  How missing background data are handled for a latent-regression fit.
  `"error"` (default) requires complete person-level covariates;
  `"omit"` fits the model on the complete-case subset and records
  omitted persons / omitted response rows in the returned `population`
  metadata while retaining the observed-person-aligned pre-omit table
  for replay/export provenance.

- facet_shrinkage :

  Character. `"none"` (default) keeps the unshrunk fixed-effects
  estimates. `"empirical_bayes"` applies a post-hoc zero-centered
  normal-model adjustment to each non-person facet (Efron & Morris,
  1973); `fit$facets$others` gains `ShrunkEstimate`, `ShrunkSE`, and
  `ShrinkageFactor` columns, and `fit$shrinkage_report` records the
  per-facet prior variance and sum of retained weights (not model
  degrees of freedom). This descriptive approximation has no general
  James-Stein risk guarantee; see
  [`apply_empirical_bayes_shrinkage()`](https://ryuya-dot-com.github.io/mfrmr/reference/apply_empirical_bayes_shrinkage.md).
  `"laplace"` is retained as a compatibility alias for
  `"empirical_bayes"`; it does not fit a penalized likelihood.

- facet_prior_sd :

  Optional numeric scalar. When supplied, the shrinkage prior variance
  is fixed at `facet_prior_sd^2` instead of being estimated by method of
  moments. Useful for eliciting a prior from domain knowledge or a
  previous fit.

- shrink_person :

  Logical. When `TRUE` and `facet_shrinkage` is active, the same
  descriptive adjustment is applied to ordinary-JML Person estimates
  with available sampling SEs. Default `FALSE`. MML EAP/posterior SDs
  cannot be used as observations/sampling SEs for a second normal-model
  update; use `FALSE` with other estimators.

- attach_diagnostics :

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

- checkpoint :

  Optional `list(file = ..., every_iter = ...)`. When supplied, the MML
  EM engine writes its state to `file` every `every_iter` outer EM
  iterations using checked same-directory replacement. If the file
  already exists when the fit starts, the engine resumes only when its
  versioned identity exactly matches the current data, model, parameter
  layout, constraints, quadrature, package version, and engine stage.
  Legacy, corrupt, or incompatible files fail closed. A non-converged
  pure-EM run may resume with a larger `maxit`; a completed checkpoint
  cannot re-enter the same iteration boundary. Only the EM engine
  (`mml_engine = "em"` or the EM warm-start step of
  `mml_engine = "hybrid"`) honours the checkpoint; the direct
  [`optim()`](https://rdrr.io/r/stats/optim.html) engine ignores it. Use
  this to make long MML EM fits crash-resilient on shared compute
  environments.

- gpcm_mml_identification :

  Scale-identification convention for `model = "GPCM"` with
  `method = "MML"`. `"free_population"` (the default) estimates an
  intercept-only person distribution \\N(\beta_0,\sigma^2)\\ when
  `population_formula` is omitted, while retaining geometric-mean-one
  relative slopes. This restores the common discrimination degree of
  freedom used by a conventional fixed-latent- variance GPCM; in the
  documented item-only overlap it is a one-to-one reparameterization of
  ConQuest `scoresfree` GPCM. An explicitly supplied
  `population_formula` is retained under this convention. With one slope
  family, `"fixed_standard_normal"` is the legacy restricted branch: it
  requires `population_formula = NULL`, fixes the person distribution to
  \\N(0,1)\\, and also fixes the slope geometric mean to one. The latter
  is then a substantive relative-discrimination restriction rather than
  an identification requirement. With two families, fixed N(0,1) instead
  accompanies a geometric-mean-one first family and free second-family
  slopes. This argument does not change JML, whose geometric-mean-one
  slope constraint is required to identify its freely estimated person
  coordinates.

- mml_integration :

  Numerical integration for MML: `"fixed"` (default) uses a common
  Gauss-Hermite grid relative to each person's normal prior;
  `"adaptive"` centers and scales the grid at each person's posterior
  mode on every objective evaluation. Adaptive fitting uses the gradient
  of the moving-node objective, including changes in its center and
  width. It requires `method = "MML"`, `mml_engine = "direct"`, and no
  checkpoint. The choice also controls the fitted likelihood, Hessian,
  posterior person summaries, fitted-object scoring, and supported
  portable calibration. For these two modes `quad_points` remains the
  order; neither guarantees adequate accuracy at a particular order.
  Compare orders before reporting. During adaptive optimization, trial
  values that cause numerical overflow are rejected so the search can
  shorten its step. Starting values must still be evaluable, and final
  estimates must pass the usual convergence checks; rejecting a trial
  does not establish a parameter boundary or impose a discrimination
  upper limit. Adaptive fits with nonlinear coordinates have no
  completed probability- map identification audit; GPCM also lacks an
  adaptive slope-boundary audit. Their overall `InferenceReady` flag
  remains false. Supported native-location and RSM/PCM population
  intervals have separate source and numerical checks; see the MML
  integration workflow section below and
  [`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md).
  Available intervals retain their asymptotic assumptions and coverage
  cautions. ConQuest exports currently require fixed integration.
  `"auto"` first fits the fixed grid at `quad_points`, then checks every
  Person's log marginal likelihood, EAP and posterior SD against two
  adaptive orders. It also checks the change in the full marginal
  gradient and its absolute maximum at the retained and finer rules. If
  any criterion fails, it warm-starts adaptive refits at the orders in
  `mml_accuracy_control`. This fixed-to-adaptive sequence applies to
  ordinary full direct MML (RSM, PCM or one-slope-family GPCM), with no
  checkpoint. Population regression, anchors and interactions retain
  their existing model restrictions. On success the resolved
  fixed/adaptive rule and order control all subsequent fit calculations;
  inspect `fit$config$mml_accuracy` for controls, stage history and
  final Person checks. These checks concern the fitted response
  patterns; scoring new patterns reuses the resolved rule and needs its
  own integration review. The initial fixed rule is retained if its
  checks pass. Requested settings are preserved for replay; explicit
  sensitivity refits use the resolved rule at each requested order. If
  optimization fails or all refinement orders are exhausted, an error of
  class `mfrmr_mml_accuracy_error` carries `history`, `control` and the
  last parameter vector instead of returning a fit. In current errors
  (`provenance_version = 2`), `last_candidate` holds the last returned
  optimizer vector, its parameter-block names and sizes, its matching
  `config`, and its stage diagnostics. These are free optimization
  coordinates, not a table of facet estimates or a precision-qualified
  fit. `last_attempt` records the final attempted stage and failure
  phase; it may describe a later failed optimization. `last_integration`
  and `last_quad_points` now describe `last_parameters`, not that later
  attempt. If no optimizer returned, `last_candidate` is NULL,
  `parameter_source` is `"initial_values"`, and the integration aliases
  are NA. Initial values are retained separately as
  `initial_parameters`. Earlier saved errors lack this provenance
  version; their integration aliases can describe the failed attempt
  rather than the retained vector. Inspect their stage history. Capture
  the condition with
  `tryCatch(fit_mfrm(...), mfrmr_mml_accuracy_error = function(e) e)`
  and inspect both records. Saving the condition preserves the values
  and reasons without converting unsuccessful accuracy checks into a
  successful model fit.

  For two-family GPCM, `"auto"` instead preserves the requested engine:
  `mml_engine="em"` uses fixed integration and `mml_engine="direct"`
  uses adaptive integration at every stage. Each refit retains the
  existing neutral EM start or the specified adaptive `gpcm_mml_start`
  policy; no cross-order warm start or engine switch is introduced. The
  default hard ceiling is 241 points, including the `2*q-1` reference
  checks. Person log marginal likelihood, EAP and posterior SD
  differences must pass, together with the existing two-family
  local-information and stationarity checks described in
  [`confint.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md).
  This conservative automatic route therefore requires more than
  delivery of a point estimate. A sole quadrature-sensitivity failure or
  inaccurate Person moments causes refinement; another failed
  information, convergence or model check stops with its own reason. It
  does not automatically diagnose a boundary. In two-family errors,
  `last_candidate$accuracy` retains available checks and Person
  comparisons. If fitting failed before a candidate was returned,
  `parameter_source="unavailable"` and `last_parameters=NULL`; there is
  no single initial vector to report for a multi-start policy. No
  two-family global optimum or interval-coverage guarantee follows from
  auto success. The latest successful automatic fit can reuse its
  complete qualification for subsequent two-family intervals in the same
  R session, provided the entire fit, information-memory budget and
  numerical backend are unchanged. Source and result retention is
  bounded by that budget. Warning-producing or refused qualification is
  not reused. This transient cache is not saved in the fit; a new
  session recomputes.

- category_policy :

  Optional explicit category choice: `"collapse"` maps gaps in the
  observed categories to consecutive scores; `"preserve"` keeps the
  intended ladder, declared with `rating_min` and `rating_max`. This
  changes the fitted category steps, not just labels. `NULL` (default)
  uses `keep_original`, whose default is `FALSE` (`"collapse"`).
  Supplying both choices is allowed only when they agree. Preservation
  does not estimate unsupported steps: fitting stops if a retained
  internal category has no observations. Use the same policy in
  [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
  and
  [`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md).

- em_score_tol :

  Stopping tolerance for the two-family GPCM MML-EM route only. `NULL`
  selects `1e-6` for that route. Stops when the largest absolute
  derivative of the negative marginal log likelihood, divided by the
  number of Persons, is at most this value. It does not control interval
  eligibility. The ascent-checked BFGS M step allows 100 iterations with
  `reltol = 1e-12`; both the marginal likelihood and EM auxiliary
  objective must not decrease beyond numerical roundoff. If BFGS stops
  before the requested score accuracy, usable positive curvature can
  refine the auxiliary objective with the same E-step counts. The ascent
  checks still apply. Dense curvature refinement is limited to 1–64 free
  parameters; otherwise the ordinary M-step proposal is retained. The
  saved `fit$opt$em_trace` records refinement attempts and failures;
  `mstep_score` is the proposal's auxiliary-objective score before any
  step halving. Other model routes require `NULL`.

- jml_correction_order :

  `NULL` (default) leaves the usual estimator unchanged. A positive
  integer explicitly selects an experimental profile-score adjustment
  for shared-owner `model = "GPCM", method = "JML"`. There is no
  automatic choice of order. See **Corrected JML** for the input
  restrictions, uncertainty meaning and connected outputs.

- jml_correction_sampling :

  Sampling assumption for corrected JML's Person covariance:
  `"fixed_rosters"` (default) centers contributions within each observed
  assignment pattern; `"random_rosters"` centers globally when
  assignment patterns are sampled. This changes covariance, not the
  point equation. The fixed-roster calculation needs at least two
  Persons per pattern. Both describe new independent Persons, including
  variation in their ability composition; neither estimates the variance
  from reassessing the same Persons at fixed abilities. Omit this
  argument when no correction is requested.

- gpcm_mml_start :

  Initial values for two-family adaptive direct MML, including its
  `mml_integration="auto"` refinement stages. `NULL` (default) selects
  `"neutral_em"`: optimize from both the neutral vector and a same-data
  fixed-grid EM vector, and select the lowest finite adaptive negative
  log likelihood, retaining its convergence status. `"neutral"` retains
  the earlier neutral-only initialization. Numerical optimizer repairs
  still apply; exact historical reproduction requires the original
  source. An EM vector is only a start; its fixed-grid likelihood is
  never compared with an adaptive likelihood. The seed uses the
  requested quadrature order, `maxit` outer iterations, 100 M-step
  iterations and per-Person score tolerance `1e-6`. A finite seed need
  not have converged. Each direct start uses the requested optimizer,
  `reltol` and its existing polishing sequence. All starts, errors,
  warnings, stage histories, seed trace and elapsed costs are stored in
  `fit$opt$mml_initialization`; results and reports include its
  comparison table. This comparison does not prove a global optimum or
  interval validity. Alternatively, supply a plain named list of at
  least two finite native free-parameter vectors. For example, reuse
  `p <- previous_fit$opt$par` from the same model coding with
  `list(previous = p, neutral = 0 * p)`. The order is first-owner free
  locations, second-owner locations, second-owner free steps (within
  each level), first-owner free log slopes, and second-owner log slopes,
  using the fitted level order. Vector lengths must match; optional
  parameter names must exactly match the model's native names. Reported
  positive slopes or expanded constrained parameters cannot be supplied
  in place of native coordinates. Explicit starts replace the default
  start roster and do not run an EM initialization. Their values are
  reevaluated and optimized under the requested adaptive objective; no
  likelihood, convergence flag, covariance or scoring eligibility is
  imported from a previous calculation. The roster and vectors remain in
  the saved initialization record and replay inputs, including
  quadrature refits.

- repeated_ratings :

  Treatment of repeated Person-by-facet cells. `"review"` (default)
  retains the duplicate-cell warning and ordinary MML/JML input-review
  state. Use `"independent"` only to declare that the rows are distinct,
  conditionally independent rating events under the specified model.
  Every row and its weight are retained; this argument does not
  aggregate scores, add a facet, change the likelihood or establish
  independence from the data. Other input, numerical and inference
  checks still apply. The declaration is saved in preparation notes,
  configuration and replay settings. Corrected JML already requires
  conditionally independent repeated ratings; the argument records that
  assumption explicitly there. It is not supported by the two-family
  GPCM route.

- centering_scope :

  `"facet"` (default) centers each declared facet across all its levels,
  including direct anchors and group totals. `"remainder"` reproduces
  the earlier convention that centers only levels outside direct and
  group constraints. For ordinary additive RSM/PCM JML,
  `"anchor_origin"` lets direct or group anchors replace centering on
  their facet; select an unanchored, active `noncenter_facet`. Other
  facets remain centered. This option excludes comparison-only fitting.
  None of these conventions changes the population model or category
  steps. Unsupported specialized routes reject an explicit setting. See
  **Anchors and scale constraints**.

- fit_scope :

  `"full"` (default) fits the ordinary model and retains its
  identification guards. `"comparisons"` explicitly fits only the
  targets in `comparison_review`; see **Comparison-only estimation**.

- comparison_review :

  For `fit_scope = "comparisons"`, the result of
  [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
  with `comparisons`, or its `$comparison_review`. Pass the review's
  `fit_arguments` and the same original ratings.

- mml_accuracy_control :

  Named list used only with `mml_integration = "auto"`. To specify only
  a ceiling, use `list(max_points=121)`. It bounds every quadrature rule
  used by automatic fitting and its acceptance checks, including
  reference rules; it does not bound optimizer iterations, total runtime
  or later separately requested inference/scoring. Orders increase
  automatically and stop at the first accepted stage. `max_points` must
  be an integer of at least 7 for ordinary MML, or 3 for two-family
  GPCM; requested rules must be representable. Unused finer rules are
  not constructed. A ceiling and an explicit `adaptive_points` vector
  cannot both be supplied. An explicitly supplied `quad_points` must fit
  within the ceiling (including its finer reference for two-family
  fitting); an omitted starting order is reduced if needed. For example,
  the two-family ceiling 121 permits fitting/checking orders 31/61 and
  61/121. A ceiling of 100 permits 31/61 and 50/99, preserving the same
  reference-order formula. Reaching the ceiling without passing all
  criteria raises `mfrmr_mml_accuracy_error`, retaining the attempted
  rules and source-bound candidate; it does not relax tolerances or
  return a precision-qualified fit.

  For ordinary MML without a ceiling, the retained defaults are
  `adaptive_points = c(31, 61, 121)` (strictly increasing integer refit
  orders, each checked against `2*q+1`), `loglik_tol = 1e-7` (maximum
  absolute log-marginal difference per Person), `posterior_tol = 1e-6`
  (maximum absolute EAP or posterior-SD difference, on the ability
  scale), and `gradient_tol = 1e-4` (maximum absolute gradient or
  gradient difference, in free optimization coordinates for the summed
  negative log likelihood). At the initial fixed fit the first adaptive
  order and its `2*q+1` refinement are used. All criteria and optimizer
  convergence must pass. These are empirical numerical tolerances, not
  certified error bounds, relative tolerances, a bound on parameter
  movement, or a guarantee of a global optimum or interval coverage.
  Weak curvature can amplify small gradient errors. Hessian precision
  and formal inference require their separate checks; automatic
  integration does not qualify previously unavailable identification or
  inference. `maxit` applies to each fit, so refinement increases total
  computation. Two-family controls instead default to `max_points=241`,
  `loglik_tol=1e-7` and `posterior_tol=1e-6`, with `2*q-1` reference
  rules. They do not accept `adaptive_points` or `gradient_tol`: their
  established engine-specific stationarity and information criteria are
  retained. Passing component-interval checks at an order does not
  ensure that its Person likelihood and posterior moments meet these
  additional tolerances. A prerequisite check that stops two-family
  refinement records `history$Status = "check_refused"`. Inspect the
  failed rows of `last_candidate$accuracy$checks`; this status does not
  identify the cause. A failed higher-order information check also stops
  refinement. Earlier saved histories use `"nonintegration_refusal"` for
  the same stopping rule; neither label establishes a boundary or
  whether more points would help.

- population_sd :

  Optional positive residual population SD, fixed during estimation.
  `NULL` preserves the existing behavior: an active population model
  estimates its residual variance; RSM/PCM without a population formula
  uses N(0,1). A numeric value requires `population_formula`, full
  direct RSM/PCM MML, and no interactions. It does not activate a
  population model implicitly. Supplied SD and anchor values are treated
  as fixed, without source-error propagation. GPCM and other estimation
  engines do not support this option.

- jml_penalty :

  `"none"` (default) preserves the ordinary estimator. Explicit
  `"jeffreys"` with additive RSM/PCM `method = "JML"` selects canonical
  information-penalized joint estimation. It returns a separate
  `mfrm_jeffreys_fit` with point estimates and numerical checks, without
  ordinary SEs or FACETS diagnostics. See **Jeffreys-penalized JML**.

- progress :

  Logical; `TRUE` displays a progress indicator with elapsed time.
  Two-family GPCM reports EM iterations, adaptive starts, quadrature
  stages and precision checks; direct optimization reports objective
  evaluations. Other routes may provide only a coarse phase display.
  Iteration/stage limits are budgets, not percent completion or a
  remaining- time forecast: convergence and required refinement are not
  known in advance. Display follows `cli` console settings and is
  cleared on return, error or interruption. The default is silent; it
  does not change numerical controls or become part of saved
  calibration/replay settings.

- object, x :

  A fitted CML result for its summary, print, covariance and
  log-likelihood methods, or a comparison-only result for its summary
  and print methods.

- ... :

  Unused.

## Value

With `method = "JML", jml_penalty = "jeffreys"`, a separate
`mfrm_jeffreys_fit`; see
[`summary.mfrm_jeffreys_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_jeffreys_fit.md)
for its point tables, probabilities, numerical checks and unsupported
inference. With `method = "CML", fit_scope = "full"`, an `mfrm_cml_fit`
with structural estimates, joint `covariance` and `information` (missing
where unavailable), `person_totals`, `checks`, preparation,
configuration and optimizer controls; see "Conditional maximum
likelihood". With `fit_scope = "comparisons"`, an `mfrm_comparison_fit`
containing `comparisons`, the prospective `comparison_review`,
numerical/category/boundary `checks`, preparation/configuration,
controls and audit-only parameter `representation`/`optimization`. CML
adds contrast `covariance` and `person_totals`. Its
[`summary()`](https://rdrr.io/r/base/summary.html) returns the
comparison table. Otherwise, an object of class `mfrm_fit` (named list)
with:

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
  `diagnostics$parameter_uncertainty$steps`. Check `CIEligible` and
  `CIUse`: finite curvature-based bands alone do not establish ordinary
  inference. When `attach_diagnostics = TRUE`, those `SE`,
  confidence-limit, and status columns are attached to `fit$steps` when
  the Hessian is available. For step-structure quality, also use the
  step-collapse and disordering warnings from
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
  global maximum for the non-concave GPCM likelihood. These JML
  diagnostic records do not supply uncertainty estimates, MML results or
  evidence of agreement with other software.
  `config$boundary_audit$gpcm_terminal_gradient_stability` reconstructs
  the same fixed JML objective and analytic terminal gradient, checks
  stored optimizer/polish summaries and deterministic central-difference
  probes, and reports gradient norms by free-parameter block. Positive
  boundary certificates take precedence over a finite-point zero or
  small gradient; otherwise a coherent small gradient is retained-point
  first-order evidence only. The numerical tolerance is not a
  statistical significance threshold. These checks do not establish a
  finite global maximum, boundary absence, uncertainty, external
  comparability, or readiness. The conditional JML boundary checks are
  not reused for MML. `confint(fit, parm = "slopes")` and
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  separately check the current local MML solution before supplying
  approximate pointwise relative-slope intervals. `CIEligible` and
  `InferenceReview` record this output-specific decision, without
  overriding the global boundary audit. Ineligible local calculations
  remain in `Optimizer*SE` / `Optimizer*CI`. Refresh saved fits through
  either function; no refitting is necessary. The identification
  convention pins the geometric mean of finite optimizer slopes at 1.

- `readiness`: the versioned fit record, five component rows, and
  current parameter-level rows. The current parameter slice includes
  GPCM slopes; other non-Person parameter classes remain scheduled for
  later propagation.

- `interactions`: model-estimated facet interaction effects and metadata
  when `facet_interactions` is supplied

- `population`: population-model metadata. Ordinary RSM/PCM and JML fits
  keep an inactive record (`active = FALSE`,
  `posterior_basis = "legacy_mml"`). Default GPCM MML and active
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
  checks

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
and propagated as a Data review state by default. Repeated cell keys
alone do not establish dependence. With
`repeated_ratings = "independent"`, the analyst declares distinct rating
events that are independent conditional on Person ability and the
model's effects. Keep event IDs in the source data for audit. Event IDs
alone do not demonstrate independence; correlated re-ratings require a
suitable dependence model. Adding an estimated occasion facet changes
the response model and is appropriate only when intended. Repeated
ratings do not increase the number of independent Persons.

## Choose a model and its population

For the `Rater` and `Criterion` columns in the Examples, the model
choices are below. A slope family gives one discrimination per level of
its owner; "two families" does not mean two ability dimensions or just
two slopes. No Q matrix is required or accepted by this unidimensional
API.

|  |  |  |  |
|----|----|----|----|
| Model | Step owner | Slope owner | MML population |
| `RSM` | Shared | Fixed at one | Fixed N(0,1) |
| `PCM` | `Criterion` | Fixed at one | Fixed N(0,1) |
| One-family `GPCM` | `Criterion` | `Criterion` | Estimated mean and SD |
| Two-family `GPCM` | `Rater` | `Criterion`, then `Rater` | Explicit fixed N(0,1) |

Supply these owner names through `step_facet` and `slope_facet`; for two
families use `slope_facet = c("Criterion", "Rater")`. The first three
rows show their default MML populations. Two-family settings must be
chosen explicitly; see "Two slope families" below. One-family slopes are
relative.

Changing only `model` therefore need not hold the population assumptions
constant. For RSM/PCM, estimating its mean and SD requires
`population_formula = ~ 1` and
`person_data = unique(ratings["Person"])`. This is a model choice, not a
universal recommendation. Fixing both the population SD and the
one-family GPCM slope geometric mean to one is a narrower model, not
just an alternative reporting scale.

Start with the complete RSM Examples. For PCM, add `step_facet` and
change `model`; for one-family GPCM, also explicitly choose
`slope_facet` and read the population choice above. Keep the data-column
and rubric arguments. The complete two-family call and its narrower
output workflow are in
[`vignette("mfrmr-gpcm-scope", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-gpcm-scope.md),
under "A provisional two-family workflow". Its zero-based scores and
ordered owners require the explicit preparation described there;
changing `slope_facet` alone is insufficient.

## Choose an estimator and the result you need

The ordinary worked example uses RSM/MML. Choose the model and
estimation assumptions for your question before choosing a table or
figure.

- **Abilities, a population model or GPCM inference:** use
  `method = "MML"` and inspect `summary(fit)$decision`. Its
  interpretation depends on the declared ability distribution. Ordinary
  RSM/PCM fixes N(0,1) by default; `population_formula = ~ 1` instead
  estimates its mean and SD. GPCM estimates them by default. See the
  population and estimator sections.

- **RSM/PCM structural effects without an ability distribution:** use
  `method = "CML", category_policy = "preserve"`. Read
  `summary(fit)$locations` and `$steps`, then
  [`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md).
  CML returns no Person abilities or population SD; ordinary diagnostics
  and consolidated reports do not apply. The conditional-likelihood
  section below and the facet-interval vignette give its assumptions.

- **Joint point estimates or FACETS comparisons:** explicitly select JML
  when that estimand is intended. With few ratings per Person, adding
  Persons does not remove incidental-parameter bias. Stored structural
  SEs or corrected-JML root uncertainty are not automatically truth
  intervals.

Facet names are your column names, not fixed roles imposed by the
package. For example, `facets = c("Judge", "Task")` uses those two
columns; it does not require columns called Rater or Criterion. Supply
the same names to follow-up functions and use the fitted level labels
for contrasts or curves. Begin with the Examples section, then read only
the specialist sections for your selected model.
[mfrmr_methods_reference](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_methods_reference.md)
separates measurement, G-theory assessment planning and observed-score
agreement questions.

## Choose the arguments by their purpose

- **Identify the ratings:** `data` is the rating table; `person`,
  `facets` and `score` are quoted column names, not the values in those
  columns.

- **Declare the rubric:** set `rating_min`, `rating_max` and
  `category_policy` consistently with
  [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md).
  The default can collapse gaps; preservation can reveal an unsupported
  category step.

- **Choose the statistical model:** `model`, `step_facet`,
  `slope_facet`, anchors and population arguments determine what is
  estimated. Ordinary RSM/PCM MML with `population_formula = NULL` fixes
  N(0,1); the default GPCM MML instead estimates the normal population
  mean and variance.

- **Control computation:** `quad_points`, `maxit`, `reltol`, `optimizer`
  and `mml_engine` govern numerical fitting. Increasing them does not
  change the model's support or automatically justify statistical
  inference.

- **Choose follow-up output:** `attach_diagnostics = TRUE` computes and
  attaches diagnostics; the default leaves that separate. `summary(fit)`
  explains the result's status;
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
  reviews response fit.

## Corrected JML

When each Person has few ratings, ordinary JML can retain structural
bias even with many Persons. The explicit `jml_correction_order` option
adjusts the profile-score equation to address this source of bias. It
changes the estimator, not the response model. A higher order is not
necessarily more accurate: bias, variance and numerical stability can
change in different directions. Choose the order as part of the analysis
plan and examine sensitivity; neither AIC nor the smallest RootSE
chooses a justified order.

This experimental route requires the optional `nleqslv` package,
observed integer scores, declared `rating_min` and `rating_max`,
additive fixed facets, and a single explicit `step_facet` that also owns
the slopes. Facet names are unrestricted. Use
`category_policy = "preserve"` to retain the declared score ladder. All
facet locations and each step ladder sum to zero; slopes have geometric
mean one. Persons are independent sampling units, with conditionally
independent ratings within Person. Only observed assignments contribute;
unassigned or missing scores are not imputed. Repeated cell rows are
treated as independent responses, not correlated repeated measurements.
Fixed anchors, nonunit weights, interactions, shrinkage, separate
slope/step owners, corrected RSM/PCM, and ordinary optimizer controls
are unavailable. Explicit unsupported arguments produce an error rather
than being ignored.

For an order \\k\\, the equation uses \\U_k=(I-K\_\beta)^k U_0\\, where
\\U_0\\ is the negative profile-likelihood score and \\K\_\beta\\
averages over responses at their profiled Person MLE. This is the MLE
plug-in construction discussed by Dhaene and Weidner (2023, section
8.1), applied here to the declared GPCM structure. Exact owner-total
enumeration is limited to 5,000 joint states per assignment pattern;
larger calculations stop explicitly. No approximate pruning is
substituted. The full equation Jacobian and empirical Person
contributions give a sandwich covariance, with the selected
assignment-sampling assumption. This is not an inverse likelihood
Hessian or a general proof of bias removal.

For example, `"fixed_rosters"` describes new cohorts with the same
number of Persons assigned to each rater/task combination. It does not
hold each Person's ability fixed across repeated cohorts. Ability
distributions are unspecified and may differ between assignment
patterns. With `"random_rosters"`, both Persons and their assignments
are sampled from the same joint population; assignment need not be
independent of ability. Neither option models shared random raters or
dependent Persons. The empirical sandwich has no small-sample
degrees-of-freedom correction. Its fixed-roster interpretation requires
enough independent Persons within each pattern; two Persons is a
computational minimum, not an assurance of accurate uncertainty. Taking
`"random_rosters"` solely to obtain a RootSE changes the sampling
assumption and is not a repair for sparse information.

Use `summary(fit)$tables` for locations, steps, relative slopes and the
uncertainty explanation; `include_person = TRUE` adds Person profiles.
`RootSE` describes local variation around the adjusted-equation
solution, which may remain biased for the true structural parameter.
`LogRootSE` describes log-slope variation. Neither is supplied as a
standard error with established structural coverage; no confidence
limits are constructed. Persons are reprofiled at the adjusted
calibration, with infinite limits for extreme scores and no invented
Person SE. Numerical attempts remain available in
`summary(fit)$attempts` and `fit$jml_adjustment`.

A valid point estimate is retained if covariance is unavailable, with
its reason. Different accepted roots yield missing primary estimates
rather than selection by the ordinary likelihood. Agreement between
starting values is a local check, not proof of a unique global solution.
A failure remains a reportable fitted object with missing estimates and
its attempts.

`plot(fit, type = "slopes")`, `"locations"` (select one `facet`) and
`"steps"` show point estimates. Choose `style = "distribution"` for an
empirical cumulative view; `as_ggplot(plot(fit, draw = FALSE))` is
supported. Use `mfrm_results(fit)` then
[`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md)
or
[`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md)
to retain these meanings through reporting and saved replay. For
conditional probabilities and descriptive residuals on the observed
fitted rows, use
[`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md)
and attach the saved result with
`mfrm_results(fit, response_diagnostics = result)`. This holds corrected
calibration and Person profiles fixed; no posterior averaging,
uncertainty intervals or fit cutoffs are supplied. Extreme-score
probabilities remain available; zero variance prevents standardization,
with separate availability for Infit and Outfit. See that helper's help
before interpreting a summary. For new Persons,
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
and
[`extract_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
provide conditional EAP scoring after their corrected-equation source
checks. These scores add a separate normal reference prior. Their
posterior intervals condition on calibration and do not establish
structural coverage or remove residual bias. The portable artifact omits
training responses and Person estimates; its own summary and score plots
retain the correction order. Ordinary fit tests, Wright/Pathway maps,
structural confidence intervals, likelihood ranking and corrected Person
ML/WLE remain unavailable. The default MML and uncorrected JML workflows
are unchanged.

## Two slope families

To estimate, for example, criterion and assessor discrimination
together, use `slope_facet = c("Criterion", "Assessor")`. The order
declares roles: the first facet has centered locations and slopes with
geometric mean one; the second has free locations/slopes and owns the
centered category steps. The product of their slopes multiplies the
complete adjacent-category predictor. There is still one ability
dimension. Column names and data column order do not select these roles.

This route requires exactly those two non-Person facets,
`model = "GPCM"`, `method = "MML"`,
`gpcm_mml_identification = "fixed_standard_normal"`, either fixed
integration with `mml_engine = "em"` or `mml_integration = "adaptive"`
with `mml_engine = "direct"`, and both `step_facet` and
`noncenter_facet` set to the second slope facet. These options must be
chosen explicitly; the one-family defaults are not silently replaced.
Use observed, unweighted integer scores on a scale from zero to
`rating_max`, without missing IDs, duplicate person-facet rows or
surrounding ID whitespace. Categories are not collapsed; if any are
absent, declare `rating_max` and `category_policy = "preserve"` so
category-support checks can assess that scale. Unobserved assignments
are not zero scores. Anchors, population covariates, shrinkage,
interactions, positive/dummy facets, checkpoints and automatic
diagnostics are not supported in this route; explicitly supplying their
arguments, including unused policy controls, produces an error.
Fixed-grid EM uses `em_score_tol`; adaptive direct MML uses `reltol` and
the direct optimizer's gradient check. Passing the other engine's
tolerance is an error. Adaptive integration preserves the same N(0,1)
population and response equation while moving each Person's grid. It is
direct maximization of the marginal likelihood, not adaptive EM. By
default it compares neutral and EM-derived starts through that same
adaptive objective; see `gpcm_mml_start`. A better unfinished solution
is retained as unfinished, rather than replaced by a worse converged
candidate. If a retained starting point is better than all terminal
candidates beyond roundoff, the returned fit remains numerically
unresolved. A failed alternative is disclosed; if every direct attempt
fails, the error carries an `initialization` record. Neither fixed-grid
likelihoods nor interval outcomes select a candidate. Extreme slopes and
weak information can still prevent inference even after a successful
start comparison. Use
[`mml_quadrature_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mml_quadrature_sensitivity.md)
to compare refits at different orders; it preserves the chosen
integration method, engine and initialization policy.

`summary(fit)` and `print(fit)` retain numerical status and the two
slope references.
[`mfrm_curve_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_curve_intervals.md)
evaluates provisional category or per-rating information curves at
supplied abilities; all their intervals are unavailable. Use
`plot(curves)` and
`mfrm_results(fit, include = c("fit", "plots"), compute = "never", intervals = list(curves = curves))`
to report saved curves. Their values can be inspected even after
nonconvergence, but are not qualified estimates. Separately request
`confint(fit, parm = "slopes")` for experimental component log-Wald
intervals from the full observed marginal information. Their numerical
checks do not qualify global identification or sampling coverage; failed
checks retain missing bounds. Attach the result alongside curves for
saved plots/reports. To profile one component with the fitted
integration method, explicitly request
`confint(fit, parm = "slopes", method = "profile", slope = c(Task = "t1"))`,
replacing the named owner and level with your fitted identifiers. This
reoptimizes other coefficients; it is an experimental local interval
without established coverage.
[`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md)
integrates each Person's ability posterior at the saved calibration for
descriptive residuals. Both slopes are retained; unavailable integration
stays explicit. There are no reference fit cutoffs. Attach this result
through `response_diagnostics` in the results call above. Adaptive
two-family log-Wald checks use the moving-node marginal objective and
compare adaptive quadrature orders. Posterior residuals preserve the
fitted integration method and complete conditioning record, with
separate row-wise integration checks. Adaptive profile searches
recalculate the nodes, scales and Jacobians at every constrained trial
and keep separate checks.
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
separately supplies experimental conditional new-Person EAP and
posterior intervals with the retained N(0,1) prior, known levels, unit
weights and separate source/batch checks; calibration uncertainty is
excluded.
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
separately supplies experimental model-based intervals for either
owner's locations and within-facet contrasts, retaining slope/step
nuisance uncertainty. Failed numerical checks leave missing bounds;
location differences need not imply uniform rating differences. Attach
these intervals to
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
for plots, reports and exports. Step/curve intervals, sandwich
inference, model ranking/LRT, ordinary fit/bias diagnostics and
Wright/Pathway plots remain unavailable.
[`extract_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
provides a separately checked portable two-family route. Matching native
or portable scores can be attached with
`mfrm_results(fit, scores = scores)` without rescoring. Numerical
agreement of the fitting implementation is not a general identification,
convergence or coverage guarantee. See
[`vignette("mfrmr-gpcm-scope")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-gpcm-scope.md)
for a complete example and interpretation.

## GPCM model and inference

One selected facet supplies level-specific positive discriminations.
With MML, a different facet may supply category steps. For example,
`slope_facet = "Criterion", step_facet = "Rater"` estimates a relative
discrimination for each criterion and category-step contrasts for each
rater. It does not simultaneously estimate rater discriminations. JML
requires the same owner for both blocks. The model has one substantive
ability dimension; its structural choices and currently unavailable
inferential outputs are separate considerations.

Free-slope fits retain numerical estimates for review.
[`confint.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md)
with `parm = "slopes"` supplies approximate relative-slope intervals for
eligible MML solutions. MML information-criterion ranking uses separate
likelihood and local-solution checks in
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md).
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
and
[`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_weighting_review.md)
also accept `nested = TRUE` for an equal-slope PCM/GPCM test after
verifying matching population and constraint settings. Fitted-object
scoring and information have their own scope and do not imply a portable
GPCM calibration artifact. Consult
[`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)
for each operation before using its output.

## Model

`fit_mfrm()` estimates many-facet ordered-response models. The `RSM` and
`PCM` branches follow the many-facet Rasch-family tradition (Linacre,
1989); the `GPCM` branch extends the partial-credit kernel with
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

With `model = "GPCM"`, the adjacent-category kernel is multiplied by a
positive slope for the designated slope-facet level:

\$\$\ln\frac{P(X\_{nij} = k)}{P(X\_{nij} = k-1)} = \alpha_g(\eta -
\tau\_{h,k}),\quad \alpha_g \> 0.\$\$

Here \\g\\ indexes the slope facet and \\h\\ the step facet; MML permits
these to differ. Slopes have a sum-to-zero constraint on log slopes, so
their geometric mean is 1. Step contrasts are centered within each step
owner, separately from facet location effects. Crossing the facets and
observing enough categories is necessary to distinguish their effects;
allowing separate owners does not ensure identification in a given
design. A selected facet owns a vector rather than one common number: if
there are \\G\\ levels, the fit returns \\G\\ positive slopes with
\\G-1\\ free log-slope contrasts. Every other facet remains additive
inside \\\eta\\ and receives no separate slope. Selecting a rater facet
is therefore a different restricted model from selecting a criterion or
task facet. The placement of the slope is part of the model identity: it
multiplies the complete adjacent-category predictor, including the
person coordinate, all additive facet locations and fitted facet
interactions inside \\\eta\\, and the owned step. It is not a
loading-only formulation in which the slope multiplies ability while
rater severity and other intercept terms remain unscaled. Such a
formulation, including TAM multifacet `GPCM.design` constructions with
separate linear intercept and slope designs, is a different model unless
an algebraic reduction establishes equivalence. In this one-family
many-facet GPCM, exactly one facet supplies slopes. MML permits a
different step owner; JML requires a shared owner. It is not the broader
Uto–Ueno generalized MFRM, whose task and rater slopes enter
multiplicatively and whose step owner must be stated separately. The
provisional two-family route above fits that product equation with its
own scale and output restrictions. Setting every slope to one recovers
the equal-discrimination PCM kernel; neither route supplies
multidimensional traits or response-style parameters. Under the default
one-family `gpcm_mml_identification = "free_population"` branch, the
population standard deviation carries the common discrimination scale
while the geometric-mean-one slopes describe relative discrimination.
Equivalently, on a standardized latent variable the absolute slopes are
\\\sigma\alpha_g\\. Under
`gpcm_mml_identification = "fixed_standard_normal"`, both the population
standard deviation and slope geometric mean are fixed to one; that
legacy branch is a narrower relative-discrimination model. Under JML,
the geometric-mean-one constraint is required to resolve the
ability/slope scale because person coordinates are estimated jointly.

The model name does not imply finite parameter bounds. The JML branch
maximizes the identified joint log-likelihood without a statistical
penalty or finite bounds on person, location, step, or slope
coordinates. Numerical line-search rejection of non-representable slope
proposals is not regularization. When a recession direction is
certified, the finite optimizer iterate remains a numerical trace and
the primary result uses the appropriate extended-real or typed boundary
status; it is not relabelled as a finite maximizer of the original JML
objective.

With only two ordered categories (\\K = 1\\), the `RSM`/`PCM` branch
reduces to the usual binary Rasch logit for the single category
boundary:

\$\$\ln\frac{P(X\_{n\cdot} = 1)}{P(X\_{n\cdot} = 0)} = \eta - \tau_1\$\$

`GPCM` uses the slope-scaled counterpart \\\alpha_g(\eta -
\tau\_{g,1})\\.

With `method = "MML"`, person parameters are integrated out using
Gauss-Hermite quadrature and EAP estimates are computed post-hoc. With
`method = "JML"`, all parameters are estimated jointly as fixed effects.
`"JMLE"` remains an accepted compatibility alias, but package output now
uses `"JML"` as the public label. See the "Estimation methods" section
of
[mfrmr-package](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr-package.md)
for details.

## Logistic metric (D = 1)

Native `RSM`, `PCM` and `GPCM` models, including two-family GMFRM, use
the logistic metric (L-metric), with scaling constant \\D = 1\\. No
additional normal-ogive approximation factor such as 1.7 or 1.702
multiplies the adjacent-category predictor. This response-scale
convention is separate from the ability distribution: fixing a
population to \\N(0,1)\\ does not change the link to a normal-ogive
model or introduce a 1.7 multiplier.

In `RSM`/`PCM`, increasing ability by one unit, holding everything else
fixed, increases each adjacent-category log odds by one (one logit). In
one-family `GPCM`, the change is \\\alpha_g\\ logits; in two-family
GMFRM it is the product of the two component slopes. Thus a one-unit
change in ability is not universally a one-logit change when slopes
vary.

Before comparing or importing parameter values from other software,
reconcile its scaling constant, slope placement and identification
constraints with this model. Changing only the multiplier while
retaining all parameter values changes response probabilities. An
equivalent reparameterization must also transform any affected
population parameters, anchors and, for Bayesian estimation, priors. See
[`export_mfrm_model()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_model.md)
for the same L-metric in the supported Stan/brms exports.

## Weighting policy

`mfrmr` treats `RSM` / `PCM` as the equal-weighting reference route for
operational many-facet measurement. In that Rasch-family branch,
discrimination is fixed, so the scoring model does not differentially
reweight item-facet combinations through estimated slopes.

`GPCM` is supported as an alternative when users explicitly accept
discrimination-based reweighting. This often improves model fit, but the
package does not treat better fit alone as a sufficient reason to
replace an equal-weighting Rasch-family model.

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
after coercion, whereas fractional numeric scores outside the rounding
tolerance described above are rejected with an error instead of being
silently truncated.

A positive numeric `weight` may encode a replication/likelihood weight
for an ordered-rating row when weighting that conditional contribution
is the intended estimand. It is not a general collapsed-person
frequency-table interface: under MML, powering responses inside one
Person's conditional pattern is not the same as replicating a complete
Person pattern after marginalization. A weight also does not turn the
score into a count outcome or model dependence among repeated ratings.
Non-positive finite weights are excluded during preparation, and
non-unit observation-weight fits are not eligible for ordinary
inference, facet equivalence, or the common MML information-criterion
panel under the current package contract. Normalizing weights to mean
one does not remove this restriction. Point estimates and computed
curvature/posterior precision remain available for diagnostic review;
they do not establish sampling SEs or confidence coverage for the
weighted objective. Omitted weights and explicitly all-unit weights use
the same eligibility rules. Earlier saved fits require refitting or a
current readiness audit; their old inference flags are not carried
forward.

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

## Facet effects and rating counts

In MML, person ability is integrated out under a `N(0, 1)` distribution
(or under the `N(X\beta, \sigma^2)` population model when
`population_formula` is supplied). GPCM MML instead activates an
intercept-only `N(\beta_0, \sigma^2)` population model by default so its
common discrimination scale is estimable. JML instead estimates person
parameters; native CML conditions on person totals. Non-person facet
parameters (`Rater`, `Criterion`, `Task`, ...) are fitted as fixed
effects, identified by the configured centering or anchor constraints.
By default, these facets have no hierarchical prior or shrinkage.
Optional `facet_shrinkage` applies a separate post-estimation
adjustment; see its argument documentation for scope and uncertainty
limitations.

Few ratings can limit information about an individual facet level; few
distinct raters also limit what can be learned about a wider rater
population. These are different concerns, and neither is resolved by a
count threshold. Precision depends on targeting, connectedness, category
use, dependence and the estimator. Jones and Wind (2018) examine
repeated ratings in incomplete designs, finding particular sensitivity
in examinee estimates. Useful reviews include:

- [`facet_small_sample_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/facet_small_sample_review.md)
  for per-level retained rating counts, count-screening labels and
  available SEs.

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

`fit$summary$FacetSampleSizeFlag` summarizes the lowest rating-count
band across non-person facet levels (`"sparse"` \< 10, `"marginal"` \<
30, `"standard"` \< 50, `"strong"` \>= 50). These package screening
bands are not guarantees of precision, interval coverage or sample
adequacy.

## Jeffreys-penalized JML

`jml_penalty = "jeffreys"` minimizes
\\-\ell(\beta)-\tfrac12\log\|I(\beta)\|\\ in the actual affine free
canonical coordinates, with anchor offsets retained. Here \\I\\ is the
full joint expected response information, including free Person
parameters. The optimizer starts at the free-coordinate origin, uses
BFGS with `reltol = min(reltol, 1e-14)` and the requested `maxit`, and
requires maximum penalized gradient at most `1e-4`, positive information
with checked solves, and numerically interior category probabilities. It
uses no probability clipping, parameter box, ridge or ordinary
extreme-score replacement. If BFGS stops on objective change before
satisfying the gradient criterion, at most three local Newton steps use
the analytic penalized Jacobian. Steps must be numerically identified,
at most one in every free coordinate, not increase the same objective
and reduce the full penalized gradient; backtracking is bounded.
`checks$polish` records an attempted finish. The original gradient
criterion and failure status remain in force if finishing fails.

The supported scope is an identified additive RSM/PCM design, unit
weights, explicitly declared `rating_min` and `rating_max`, and
unchanged full score coding (`category_policy = "preserve"`). Direct
finite anchors and ordinary centering conventions are supported; group
anchors, interactions, GPCM, population models, shrinkage, corrected-JML
arguments and attached ordinary diagnostics are not. `optimizer` must be
`"auto"` or `"BFGS"`. Repeated cells require the explicit
independent-occasion declaration when substantively justified. Missing
categories and constant outcomes are retained on the declared rubric;
rank deficiency is still refused.

[`summary.mfrm_jeffreys_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/summary.mfrm_jeffreys_fit.md)
describes Person, facet and step points, category probabilities and
numerical diagnostics. For common-plan Person expected scores use
[`fair_average_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md)
with `reference_plan`, followed by
[`confint.mfrm_fair_average()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fair_average.md)
for experimental refit or delta intervals. Calibration, scoring and
generating fits must all select this estimator; every replicate
re-estimates its calibration and anchors using the same equation. The
ordinary delta derivative and inverse information SEs do not describe
this estimator; its delta route uses analytic penalized score/anchor
derivatives and shared categorical response covariance. It is not an
inverse-curvature interval. Parameter covariance, Wald intervals, AIC,
likelihood-ratio inference, ordinary FairM/FairZ diagnostics and FACETS
export are not supplied.

This is an opt-in alternative to ordinary FACETS-oriented JML, separate
from both the generator-only Jeffreys option and corrected GPCM. Firth's
(1993) fixed-dimensional canonical bias result does not establish
unbiased nonlinear expected scores, coverage, or incidental-parameter
consistency when the number of Person parameters grows. The binomial
finiteness theorem of Kosmidis and Firth (2021) is not asserted as a
general many-facet PCM theorem. A qualified local stationary point does
not establish a global optimum. Small-sample, sparse and weak-link
bias/coverage remain to be qualified independently. References: Firth
(1993),
[doi:10.1093/biomet/80.1.27](https://doi.org/10.1093/biomet/80.1.27) ;
Kosmidis and Firth (2021),
[doi:10.1093/biomet/asaa052](https://doi.org/10.1093/biomet/asaa052) .

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
(no `bias_correction` argument exists). A common positive multiplier is
not a correction for relative GPCM slopes: multiplying all slopes by the
same factor leaves their ratios unchanged, and rescaling them to
geometric mean one returns the original slopes. A correction for
relative slopes therefore needs its own justification.

Uncorrected JML facet/location SEs use observation-table information:
\$\$\mathrm{SE}\_{g} \approx \left\[\sum\_{r \in g} w_r a_r^2
\mathrm{Var}(X_r \mid \widehat\eta_r)\right\]^{-1/2}.\$\$ Here \\g\\ is
a facet level, \\r\\ an observed response row, \\w_r\\ its weight, and
\\a_r\\ its GPCM slope (one for RSM/PCM). Only finite information
contributions are used. These exploratory SEs treat the other fitted
parameters as fixed; they are not slope SEs or a joint covariance
adjusted for estimating Person and structural parameters together. The
local joint-curvature check used for portable GPCM JML scoring does not
supply such an inferential covariance. Values fixed by anchors or
identification constraints are not estimated: diagnostic tables mark
them `Fixed = TRUE` and leave their sampling SEs and intervals missing,
rather than assigning an observation-information SE.

Nuisance-parameter adjustment and estimation bias are separate issues.
Haberman (2004, Sections 1.4-1.5) shows for a binary Rasch setting that,
with fixed test length, JML can concentrate around a biased limit as the
number of persons grows. Even a variance appropriate to that limit does
not establish coverage of the true parameter. This result motivates
checking test length separately from sample size; it does not validate a
correction or an interval for sparse many-facet GPCM. Formal JML slope
intervals are not currently available in mfrmr.

When comparing software, report response-score adjustment and post-fit
bias correction separately, including how the correction defines
exposure when responses are missing or unequal across Persons. Matching
the label "JML" alone does not establish matching estimates or
uncertainty.

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

- Native RSM/PCM CML conditions out Person parameters, requiring no
  ability population distribution. It supplies structural-parameter
  intervals under conditional-likelihood regularity; see "Conditional
  maximum likelihood". General GPCM inference uses MML. JML remains a
  point-estimation/FACETS comparison route, not a fixed-exposure
  truth-centered Wald procedure. Third-party CML fits can still be
  imported with
  [`import_erm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/import_erm_fit.md).

## MML integration workflow

Choose integration together with the result you need. The default
remains `mml_integration = "fixed"`, `quad_points = 31`; this order does
not certify accuracy.
[`mml_quadrature_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mml_quadrature_sensitivity.md)
compares refits at specified orders. Review changes in estimates and
uncertainty before reporting a fixed-grid fit.

For ordinary full direct RSM/PCM or one-family GPCM fitting, `"auto"`
checks the fitted response patterns and refines integration when needed.
Read `fit$config$mml_accuracy` and the resolved rule in
`fit$config$estimation_control$mml_integration`. Downstream support
depends on this resolved rule, which can be adaptive even when the
initial rule was fixed. Check the intended output's model and
integration scope before fitting:

- Ordinary fixed-N(0,1) RSM/PCM model and sandwich facet intervals
  require fixed integration, as do joint cell intervals requested with
  `interaction` and independent anchor-source propagation. See
  [`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md).

- Native-location intervals for estimated-normal RSM/PCM and one-family
  GPCM accept fixed or adaptive direct MML within their stated scope.
  RSM/PCM population-coefficient and residual-variance intervals use the
  same qualification; see
  [`mfrm_population_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_population_intervals.md).
  GPCM latent-regression location intervals are unavailable.

- Automatic integration does not support EM/hybrid engines, checkpoints,
  comparison-only fitting or two slope families. ConQuest overlap export
  currently requires a resolved fixed rule.

Overall fit readiness, interval eligibility and coverage are different
statements. A supported target-specific interval can have
`CIEligible = TRUE` while its unchanged source fit has
`InferenceReady = FALSE`. Inspect the interval's `Status`, `checks`,
`numerical_checks` and cautions. Eligibility means the procedure's
checks passed; it does not establish global identification, nominal
finite-sample coverage or availability of other inference procedures.
Automatic likelihood/gradient/posterior checks also do not replace the
interval's full-information and finer-order review.

## MML inference conditions

There is no ten-response-row minimum. Full RSM/PCM JML, native CML and
fixed-population MML can accept one Person when their model-specific
checks pass. One-Person JML/MML also requires `lpSolve` for a pre-fit
additive recession check; a detected or unresolved boundary returns no
finite estimate. Separate rating events must satisfy the assumed
conditional independence; explicitly declared repeated ratings are not
evidence that independence holds. The returned preparation note,
interval cautions and summary explain the single-Person limitation. Any
available model-information interval remains an unqualified normal
approximation; one Person supplies neither independent- Person sandwich
uncertainty nor empirical between-Person variation. Estimated-population
MML, GPCM, corrected JML and comparison-only fitting retain their
at-least-two-Person software scope. Data and anchor review can inspect
one Person. The calibration interface still requires two observed score
categories; these input checks do not establish identification or
precision. Scoring one Person against saved calibration is a separate
task; see
[`score_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md).
Small supported datasets can return point estimates and asymptotic
uncertainty when the model-specific checks pass. A singleton category
count alone need not prevent RSM/PCM model-information intervals:
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
performs a separate joint-information and quadrature review and retains
the small-sample caution.

MML integrates the joint response vector for each Person under the
declared ability distribution. Model-based structural SEs use the
inverse full marginal observed information, including estimated
population and other nuisance coordinates. Holding these coordinates
fixed gives a different uncertainty calculation. EAP Person scores are
predictions under the fitted model, not additional free parameters in
this information matrix.

Regular likelihood inference requires the response and population models
to be correct for the actual assignments and covariates, independent
Persons, a fixed-dimensional identifiable model, a consistent interior
solution, smooth derivatives and growing information in every free
direction. This permits fixed exposure per Person under suitable
designs; it does not establish consistency merely by increasing Person
count. For an estimated normal population, zero variance is a boundary
outside this regular argument. Numerical convergence or a positive local
Hessian does not prove global identification, exclude a boundary
solution or verify the population model.

Finite quadrature approximates the continuous-normal likelihood.
Optimizer and integration errors must be small relative to sampling
uncertainty; a fixed quadrature order does not automatically maintain
this property as sample size grows. Comparing quadrature orders
diagnoses sensitivity but does not provide a continuous-integral error
bound. See
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
for the assumptions, available checks and the joint delta method for
contrasts divided by the same fit's estimated population SD.

## All-minimum and all-maximum Persons

`fit_mfrm()` has no public option to remove Persons before fitting
because all their responses are at the minimum or maximum. Both JML and
MML retain those observed responses. Extreme-response flags use the
usable rows after data preparation; missing responses do not count as
intermediate scores. Declare `rating_min` and `rating_max` from the
rubric so that an observed maximum is not mistaken for the intended
scale maximum. Inspect `fit$facets$person$Extreme` for `"low"`,
`"high"`, or `"none"`.

**Ordinary JML.** `fit_mfrm()` does not replace extreme response scores
before JML fitting. For an independently free Person with all-minimum or
all-maximum responses, the primary `Estimate` is `-Inf` or `Inf`;
`OptimizerEstimate` retains the finite computational trace, not a finite
Person MLE. Fixed Person anchors retain their supplied values, and
coupled constraints require their own boundary review. The Person
audit's `BoundaryState = "has_exclusions"` identifies nonfinite
parameters; it does not mean that these Persons or their input rows were
deleted. Finite structural estimates alone do not establish a finite
joint maximum.

**Corrected JML.** In the supported shared-owner GPCM route, extreme
Persons also remain in the data and assignment-pattern accounting. Their
profiled abilities have infinite limits and their structural estimating-
equation contributions are zero at those limits. This boundary
calculation is not an input filter or a general proof of bias removal.

**MML.** Extreme Persons contribute to the marginal likelihood through
integration over the specified or estimated population distribution.
Their reported abilities are posterior EAPs, with posterior SDs rather
than frequentist Person-MLE standard errors. A proper normal population
model with finite parameters gives finite EAPs, subject to valid
numerical integration; an extreme response pattern alone does not
require deletion. This does not guarantee convergence, identification or
valid structural intervals for the fitted model. Removing these Persons
would change the observed sample and marginal likelihood.

New-Person scoring with
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md)
is a separate operation. With an eligible calibration and an admitted
scoring prior, it can return finite EAPs for extreme new Persons,
including after JML calibration. Those scores do not replace the
original JML Person MLEs. Calibration-source checks and scoring-batch
integration checks must both pass; increasing scoring nodes does not
resolve a boundary in the source calibration. A finite display from
`fair_average_table(..., xtreme = ...)`, or placement at the end of a
Wright map, likewise does not change the fitted model or correct JML
bias.

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
interactions, and random-effect facet interactions are deferred. This is
ordered binary support, not a separate nominal-response model. In `PCM`,
a binary fit still uses one threshold per `step_facet` level on the
shared observed-score scale.

Supported model/estimation combinations:

- `model = "RSM"` with `method = "MML"`, `"JML"`/`"JMLE"`, or `"CML"`

- `model = "PCM"` with a designated `step_facet`; CML requires it
  explicitly

- Native CML returns a separate structural-parameter result with
  conditional-information intervals; ordinary fit/scoring/diagnostic
  methods below apply to MML/JML results

- `facet_interactions` with `model = "RSM"` or `"PCM"` for explicit
  two-way non-person facet interactions

- `model = "GPCM"` uses one positive slope family. MML permits separate
  slope/step owners; JML requires `slope_facet == step_facet`. Core
  summaries, fitted-object posterior scoring,
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
  routes are available with score-side caveats. Separate-owner MML
  supports slope and curve intervals, same-design
  [`bootstrap_mfrm_gpcm()`](https://ryuya-dot-com.github.io/mfrmr/reference/bootstrap_mfrm_gpcm.md),
  and matched PCM comparison.
  [`build_weighting_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_weighting_review.md)
  and the following simulation/design workflows still require the same
  slope/step owner. Direct simulation specifications and data generation
  are also supported through
  [`build_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_mfrm_sim_spec.md),
  [`extract_mfrm_sim_spec()`](https://ryuya-dot-com.github.io/mfrmr/reference/extract_mfrm_sim_spec.md),
  and
  [`simulate_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_data.md)
  when the slope-aware generator contract is stored explicitly; direct
  recovery checks are available through
  [`simulate_mfrm_recovery()`](https://ryuya-dot-com.github.io/mfrmr/reference/simulate_mfrm_recovery.md)
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
  predictive checks, and MCMC estimation are not available for `GPCM`.
  Use
  [`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)
  as the formal boundary statement for the current `GPCM` scope.

Latent-regression status:

- `population_formula = NULL` keeps the standard unconditional behavior
  for RSM/PCM and JML. For GPCM MML, the default
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

With covariates, the estimated `sigma2` is the residual variance of
ability conditional on those covariates, not the marginal population
variance. Marginal variance also depends on the distribution of the
covariates. Standardization and polynomial/spline bases learned during
fitting are reused for new persons; changing the scoring cohort does not
redefine them. For custom transformations, supply a prediction-aware R
transformation or precompute predictors with fixed training constants.
Older saved fits can reconstruct transformed terms only from retained
person data that reproduce the training design; otherwise scoring
requests a new calibration fit.

For an intercept-only model, `population_formula = ~ 1` estimates a
single population mean and variance by default. In supported RSM/PCM
direct MML, `population_sd = 1` instead fixes the SD and estimates only
the mean. Training still requires a one-row-per-person ID table in
`person_data`. Adjusting these two moments retains a normal population
shape; it does not learn skewness or establish that the training
population represents the people who will receive scores. New-Person
intervals condition on the estimated calibration and population
parameters and exclude uncertainty from estimating them. Current
population-model scoring remains a review workflow; see
[`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md).

## Latent-regression standard-error caveat

`summary(fit)$population_coefficients` reports point estimates of
\\\hat{\boldsymbol{\beta}}\\; `population_overview` reports the
estimated population variance. These tables do **not** provide standard
errors, confidence intervals, or asymptotic z / Wald statistics for the
population parameters. For an estimated normal RSM/PCM population,
[`mfrm_population_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_population_intervals.md)
separately requests experimental pointwise coefficient, prespecified
coefficient-contrast and log-variance intervals after full joint
numerical checks. Its result has a
[`vcov()`](https://rdrr.io/r/stats/vcov.html) method on
coefficient/log-variance coordinates; the ordinary fit summary does not
acquire automatic intervals. The internal MML observed-information
calculation includes \\(\boldsymbol{\beta}, \log\sigma^2)\\ when
computing joint covariance for structural-parameter SEs. With explicit
`population_sd`, variance is fixed and its log-variance coordinate is
excluded from that covariance; coefficient and structural uncertainty
are conditional on the supplied SD. Population intervals for GPCM remain
unavailable through this new helper. Sampling coverage is not
established by numerical checks. Treat the population summary tables as
descriptive point estimates; use the separately saved interval result
when reporting the experimental approximation and its limitations.

The default latent-regression identification uses
`noncenter_facet = "Person"`. Without anchors, this sum-to-zero-centers
all non-Person facets. With anchors, `centering_scope = "facet"`
includes their contributions in each facet's zero sum; `"remainder"`
retains the earlier restriction on the unconstrained remainder. The
population model is never changed implicitly to accommodate anchors. The
restricted anchor-origin alternative below uses an explicitly fixed
population SD.

## Anchor origin and cohort means

When an old rater panel is anchored, leaving Rater uncentered allows new
raters to have a nonzero mean severity. Fixing the Person mean to zero
can nevertheless distort estimates when the receiving cohort differs.
For RSM/PCM direct MML, `population_formula = ~ 1` with
`population_sd = 1` estimates the receiving mean on an explicitly
fixed-SD normal population. Set `noncenter_facet = "Rater"` and supply a
retained direct Rater anchor. An anchor on another facet does not
resolve the mean/Rater alias. The complete constrained design must still
have full rank; one anchor is sufficient only in an otherwise identified
design. Group anchors, dummy facets, population covariates and
interactions are outside this alternative.

For example, begin with the bundled ratings and an externally supplied
anchor value (0.3 below is illustrative, not a validated calibration):

    ratings <- load_mfrmr_data("example_core")
    fixed_rater <- data.frame(Facet = "Rater", Level = "R01", Anchor = 0.3)
    cohort_fit <- fit_mfrm(
      ratings, person = "Person", facets = c("Rater", "Criterion"), score = "Score",
      model = "RSM", method = "MML", anchors = fixed_rater,
      noncenter_facet = "Rater", population_formula = ~ 1,
      person_data = unique(ratings["Person"]), population_sd = 1
    )
    summary(cohort_fit)$population_coefficients # Estimated receiving-cohort mean
    summary(cohort_fit)$population_overview     # Fixed versus estimated variance

Use
[`mfrm_population_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_population_intervals.md)
for the mean and
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
for rater uncertainty after their independent numerical checks. The
fixed variance remains visible without an inferential CI. Covariance
includes all free calibration coordinates and the population mean, but
excludes uncertainty in the supplied anchors and SD. No general coverage
guarantee follows from agreement with another program.

Other facets retain their declared centering. Rater anchors do not
establish item invariance: a changed item pool or its difficulty
distribution can change the mean's substantive interpretation. Report
the anchored panel, item/criterion reference, fixed SD, and assumed
stability across cohorts.

## Anchors and scale constraints

Anchor inputs are optional and have distinct roles:

- `anchors` contains facet/level/fixed-value information and imposes
  direct equality constraints on selected parameters.

- `group_anchors` contains facet/level/group/group-value information and
  constrains each declared group mean. Its interpretation is conditional
  on the externally justified target or equal-mean assumption.

- Common Persons, raters, items, or rating events are properties of the
  observed design. Neither constraint type creates empirical overlap or
  proves that disconnected subsets are substantively comparable. Both
  are normalized internally, so column names can be flexible (`facet`,
  `level`, `anchor`, `group`, `groupvalue`, etc.).

Direct anchors fix facet locations, not thresholds or GPCM slopes.
Values must use the source model's internal metric and orientation, not
transformed display units.
[`make_anchor_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/make_anchor_table.md)
exports this metric. For reuse of a complete fixed calibration, see
[`extract_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md)
and
[`score_mfrm_calibration()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_calibration_workflow.md).

With the default `noncenter_facet = "Person"`, a partial Rater anchor
such as R01 = 0.7 makes the other Rater levels sum to -0.7 under the
default `centering_scope = "facet"`. With one remaining level, it is
fixed at -0.7. Group means contribute their target multiplied by the
group's size, including directly fixed members. If anchors/groups cover
all levels, their total must agree with the facet's zero sum.
Contradictions stop review and fitting even with
`anchor_policy = "silent"`.

Use `centering_scope = "remainder"` to reproduce earlier partial
anchoring: the ungrouped, unanchored levels sum to zero and a singleton
is fixed at zero. Saved results retain their original constraints;
reloading does not migrate estimates. Changing conventions requires
refitting.

For ordinary additive RSM/PCM JML, `centering_scope = "anchor_origin"`
implements the FACETS convention that a directly or group-anchored facet
is not additionally centered. With a Person anchor, choose an unanchored
facet such as `noncenter_facet = "Rater"`; other unanchored facets
remain centered. A Rater anchor can instead retain the default noncenter
Person facet. The noncenter facet must be active and have neither direct
nor group anchors. A single direct anchor or group mean supplies its
facet's origin; multiple fixed values can impose additional substantive
constraints. Without Person group constraints, if all retained responses
of the directly anchored Persons are at the same declared minimum or
maximum, fitting stops before optimization, without requiring `lpSolve`:
free Person and noncenter-facet locations can diverge together while
preserving every fixed value. FACETS 4.5.0 can report finite values for
such inputs, but these are not an ordinary finite JML solution and are
not reproduced by this route. An extreme anchor does not alone trigger
this rule when another Person anchor supplies interior or
opposite-boundary responses. Other detected joint additive recession
directions affecting calibration also stop this route; passing the
checks does not certify every boundary configuration. General
extreme-score exclusion and every FACETS option are not equivalent. See
the FACETS [centering
specification](https://www.winsteps.com/facetman64/centerfacet.htm).
Match category support, signs, the response design and population
assumptions for TAM/ConQuest comparisons; an anchor value alone does not
establish equivalence. All these routes condition on supplied anchor
values and do not propagate error from an external estimated
calibration.

If an old zero-sum panel is fully anchored and new raters are added,
whole-facet centering also forces the new raters to sum to zero. This is
an additional constraint, not evidence that the new panel has the same
average severity. In supported fixed-population MML models, choosing
`noncenter_facet = "Rater"` can leave that facet uncentered. This is not
a general remedy: only one facet can be noncentered. The RSM/PCM
intercept-only, fixed-SD alternative is described above. Other latent
regression, including the usual one-family GPCM population model,
requires `noncenter_facet = "Person"`. Review the complete
identification and population assumptions before using anchors to
compare cohorts.

A group target is an unweighted arithmetic mean of its declared levels,
including any directly anchored members. It is not weighted by rating
counts. FACETS `G` supplies per-element contributions to a group total;
convert their arithmetic mean to one repeated `GroupValue`. For example,
contributions 0.2 and 1.0 become `GroupValue = 0.6` for both members.
Unequal `GroupValue` entries are conflicting targets, not contributions;
use `anchor_policy = "error"` to stop on review issues. FACETS group 0
denotes direct anchors and must be translated to `anchors`; mfrmr treats
`Group = "0"` as an ordinary group identifier. The FACETS `X` convention
that removes extreme members is not applied automatically. See [FACETS
element
specifications](https://www.winsteps.com/facetman64/elements.htm).

Group-origin support retains constrained maximum likelihood, not every
native FACETS update. Matched interior RSM/PCM examples agree when a
single group only sets the origin. With additional restrictions, FACETS
4.5.0 can satisfy the group means while leaving a nonzero likelihood
derivative along a constraint-preserving direction. mfrmr optimizes that
likelihood rather than reproducing those numerical differences. Matching
means alone does not establish parameter, SE or interval equivalence;
group-anchor extreme extrapolation remains unsupported. In MML,
individual abilities are integrated out: Person direct and group anchors
are unsupported and rejected even with `anchor_policy = "silent"`.
Sharing Persons across raters requires no fixed Person values.

Ordinary fit summaries condition on supplied anchor values. Independent
source-anchor covariance can be propagated explicitly in the bounded
fixed-SD RSM/PCM route through
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
and
[`mfrm_population_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_population_intervals.md);
it is not added automatically. By default, downstream SEs and intervals
condition on those values and retain the selected estimator's other
limitations. A missing SE for a fixed value does not mean its source
calibration was error-free. See
[mfrmr_linking_and_dff](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_linking_and_dff.md)
for the theoretical background and a loading-first example, and
[`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md)
for receiving-data checks.

Anchor review behavior:

- `fit_mfrm()` automatically runs an anchor review.

- invalid rows are removed before estimation.

- duplicate rows keep the last occurrence for each key.

- `anchor_policy` controls whether detected issues are warned, treated
  as errors, or kept silent.

- the review checks table/data compatibility and local support counts;
  it does not establish source-fit readiness, cross-run identity,
  parameter invariance, or the validity of a group-mean assumption.

Facet sign orientation:

- facets listed in `positive_facets` are treated as `+1`

- all other facets are treated as `-1` This affects interpretation of
  reported facet measures.

## Estimator-specific checks before fitting

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
free-coordinate check. For GPCM and an active latent-regression residual
variance, the additive block is audited before fitting. A retained
vector also records the analytic free-to-expanded log/natural-scale
transformation Jacobians and a central-difference check in
`fit$data_review$estimability$nonlinear_transformation`. This verifies
the parameterization only; it is not a response-likelihood Jacobian or a
structural-identification result. A stationary retained solution of
modest free dimension also receives a local observed-information Hessian
and a recorded eigenvalue-tolerance ladder in
`fit$data_review$estimability$fitted_information`. Nonstationary or
larger fits retain an explicit not-evaluated status. This
fitted-information layer is diagnostic only: it does not yet classify
weak information, make the nonlinear check complete, or turn full
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

2.  Inspect `FitReadiness` and `InferenceReady`, together with the
    eligibility and reasons for the specific calculation. RSM/PCM model
    intervals can pass their own singleton-category and information
    checks while the fit retains its category review; see
    [`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md).
    This exception does not waive numerical convergence. Also inspect
    purpose-specific Design, Stability, Diagnostics, and Reporting
    workflow rows. Optimizer code zero alone is insufficient. A missing,
    nonfinite or incomplete terminal gradient produces
    `ConvergenceReason = "code_zero_unavailable_gradient"` and review
    status, even when the optimizer reports code zero. Resolve the
    numerical evaluation before using the fit for inference; more
    iterations alone do not establish a valid gradient.

3.  If `ConvergenceStatus == "iteration_limit"`, keep that fit
    review-only. Refit the same data, model, method, anchors, optimizer,
    tolerance, and quadrature rule with the next ceiling in a
    prespecified sequence, such as 400, 800, then 1600. Do not choose
    among runs by coefficient size, statistical significance, fit
    statistics, or agreement with an expected answer.

4.  The first run in that sequence that satisfies the
    numerical-readiness criteria becomes eligible for interpretation. If
    separately ready runs differ materially, treat the difference as
    numerical instability and review the model, identification, data
    support, and optimizer rather than selecting the preferred result.

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

- `quad_points = 31` is the package default and a starting point, not a
  guarantee that integration error is negligible.

- `quad_points = 61` (or higher) supplies candidate denser grids at
  additional computational cost; no fixed order is sufficient for every
  response pattern.

- Use
  [`mml_quadrature_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mml_quadrature_sensitivity.md)
  to inspect same-data movement without an automatic stable/unstable
  decision.

- `mml_engine = "direct"` remains the most stable general-purpose path.

- `mml_engine = "em"` or `"hybrid"` currently target `RSM` / `PCM` fits
  without a latent-regression population model.

- Benchmark your own workload before using `mml_engine = "em"` or
  `"hybrid"` for final reporting; `direct` remains the documented
  default when you have not compared engines for your data.

- When a direct code-zero stage stops ahead of the terminal-gradient
  check, bounded polishing is automatic. Inspect
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

For `GPCM`, residual-based mean-square fit screens are also best treated
as exploratory diagnostics rather than strict Rasch-style invariance
tests, because the discrimination parameter is free.

## Interpreting output

Start with `summary(fit)` and the estimator selected above. For ordinary
MML/JML results, read its `$decision` before interpreting the Person and
facet overviews. For CML, read `$locations` and `$steps`, or
`$comparisons` for a comparison-only fit; those results do not contain
Person abilities. A reported estimate, numerical convergence and an
eligible confidence interval are different claims. Read the associated
checks and limitations.

## Typical workflow

1.  Fit the prespecified model and inspect `summary(fit)`.

2.  For ordinary MML/JML RSM/PCM, collect `res <- mfrm_results(fit)` and
    inspect `summary(res)$triage` and `$next_actions`. Pass already
    computed diagnostics through `diagnostics = diagnostics` to reuse
    them.

3.  Choose `plot(res, ...)`,
    [`mfrm_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_report.md),
    [`export_mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_results.md)
    or `saveRDS(res, file)` according to the output you need. See
    [mfrmr_reports_and_tables](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reports_and_tables.md)
    for the complete example.

4.  For CML, use
    [`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
    and its own summary, plot,
    [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
    and RDS saving. For GPCM or extended models, use
    [`gpcm_capability_matrix()`](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md)
    and
    [`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md)
    to select supported outputs. Shared function names do not make
    ordinary diagnostics or scoring available for every estimator or
    result class.

## Information-criterion contract

For an eligible fixed-facet `MML` fit, let `D = -2 * LogLik`, let `k` be
`Npar` (the retained free optimization-vector dimension after
constraints), and let `N_person` be the number of unique prepared
Persons. The canonical panel is `AIC = D + 2 * k`,
`BIC = D + log(N_person) * k`, and
`SABIC = D + log((N_person + 2) / 24) * k`.

`ResponseRows`, `WeightedResponseTotal`, `Persons`, and `ICSampleSize`
are separate fields. The compatibility field `N` retains its earlier
response-row or summed-observation-weight meaning and is not the BIC
sample size. Explicit all-unit weights remain eligible; every non-unit
observation-weight fit, JML fit, and object without the current contract
identity is excluded from the common MML panel. Its canonical
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
(1982). The `GPCM` branch follows the generalized partial credit
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

- Dhaene, G., & Weidner, M. (2023). *Approximate functional
  differencing*. SERIEs, 14, 379-416.
  [doi:10.1007/s13209-023-00283-1](https://doi.org/10.1007/s13209-023-00283-1)
  .

- Haberman, S. J. (2004). *Joint and conditional maximum likelihood
  estimation for the Rasch model for binary responses*. ETS Research
  Report RR-04-20.
  [doi:10.1002/j.2333-8504.2004.tb01947.x](https://doi.org/10.1002/j.2333-8504.2004.tb01947.x)
  .

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

## Conditional maximum likelihood

Set `method = "CML"` and `category_policy = "preserve"` for native
many-facet RSM/PCM estimation. Declare the rubric range with
`rating_min` and `rating_max`; PCM requires `step_facet`. Non-person
facets and category steps have the ordinary sum-to-zero constraints.
Supported two-way facet interactions keep zero marginal sums. Unit
observation weights are required. The default `fit_scope = "full"`
estimates the full identified structural model; the comparison-only
route below reports selected contrasts in deficient models. The
suggested package `lpSolve` supplies the finite-MLE check. Repeated
Person-by-facet cells require correction or an explicit justified
`repeated_ratings = "independent"` declaration before CML intervals are
supplied.

For Person \\p\\, let \\s_p=\sum_j y\_{pj}\\ and let \\x\_{pjk}\\ be the
cumulative structural design vector for category \\k\\, with
\\x\_{pj0}=0\\. Conditioning on the observed roster and \\s_p\\ gives
\$\$\ell_c(\beta)=\sum\_{p,j}x\_{pj,y\_{pj}}^T\beta- \sum_p\log
\[t^{s_p}\]\prod_j\sum\_{k=0}^K \exp(x\_{pjk}^T\beta)t^k.\$\$ A
generalized ESF recursion computes the coefficients in log scale,
conditional sufficient-statistic means and covariances. The score is
observed minus conditional expected statistics; information is their
conditional covariance. It contains cross-information for all estimated
structural coordinates. No ability quadrature or ability population
model is used.

Person-constant effects disappear on conditioning. The information at
zero checks identification for the actual rosters and totals; an
unidentified or numerically rank-sensitive full model is refused. A
dynamic-program graph represents conditional support for a
linear-program recession check without enumerating response patterns. A
detected or inconclusive recession check, or failed stationarity check
prevents delivery of a full fit. If those checks pass but the fitted
information cannot be evaluated or safely inverted, the finite numerical
point estimates and conditional likelihood are retained with a warning.
`checks$information_status` is `"unavailable"` and
`checks$information_reason` explains why; the joint covariance is an
`NA` matrix, not a regularized substitute. Non-fixed targets have
missing SE and bounds, `CIEligible = FALSE` and an `InferenceReview`
reason in summaries and facet intervals. Small score residuals alone do
not certify accurate points in weak directions; examine the information
warning before interpreting them. Inverse information, when available,
is unregularized. Extreme-total Persons have zero conditional likelihood
contribution and remain in `person_totals`.

The full-scope result is an `mfrm_cml_fit`. `summary(fit)` contains
`locations`, `steps`, `interactions` and checks; these tables use
pointwise 95 percent normal intervals.
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
accepts locations or named contrasts at another confidence level, with
`method = "model"`. Plot the interval object with `plot(ci)` and retain
it with [`saveRDS()`](https://rdrr.io/r/base/readRDS.html). `vcov(fit)`
is the covariance in free structural coordinates, or an `NA` matrix with
an `unavailable_reason` attribute when information fails. Default
`confint(fit)` retains missing bounds and reasons in its `diagnostics`
attribute. `logLik(fit)` is the conditional log likelihood. Conditional
and marginal/joint likelihood values are different objectives.

The conditional model must hold for the actual rating roster:
conditional on ability and the roster, ratings follow the specified
independent RSM/PCM response law. A prespecified incomplete assignment
is compatible with this assumption. Response-dependent assignment,
stopping or missingness requires a separate justification that the
conditional law is preserved. Conditioning alone does not supply that
justification or repair local dependence.

One sufficient regular regime has independent Persons, fixed structural
dimension and category range, bounded ratings per Person, a finite true
parameter, and conditional information \\I_N(\beta_0)/N\\ converging to
a positive-definite matrix. For example, the proportions of roster/total
strata can stabilize while their combined support identifies every free
direction. Then CML is consistent as Person count \\N\\ grows, even with
fixed ratings per Person, and inverse-information Wald intervals are
asymptotically valid. Increasing the total number of Persons alone is
insufficient: extreme totals add no information, and a direction
supported by only a few Persons can remain imprecise. Growing numbers of
facet levels/parameters require a separate asymptotic argument.
Numerical checks on one fit do not establish these sampling conditions
or guarantee finite-sample coverage. It does not estimate abilities,
population means or a population SD. In particular, it cannot supply a
contrast divided by that fit's estimated population SD; the MML
delta-method route remains separate.

Anchors, population regression, shrinkage, corrected JML and GPCM are
outside this CML route. Full-scope CML also excludes dummy/uncentered
facets; the comparison route uses the review's zero origin main facet.
Unsupported explicit arguments are rejected even when equal to a
default. Ordinary `mfrm_fit` scoring, diagnostics and consolidated
reports are not attached to this separate class. These restrictions do
not affect imported eRm fits. See Mair and Hatzinger (2007),
<https://www.jstatsoft.org/article/view/v020i09>, for the linear
Rasch-family CML framework.

## Comparison-only estimation

An incomplete assignment can identify a contrast even when the full
model has aliased parameters. Set `fit_scope = "comparisons"` and supply
an explicit `comparison_review` to estimate such contrasts. This route
supports the review's unadjusted RSM/PCM models, unit-weight retained
ratings, preserved categories, one facet-by-origin interaction, zero
origin main effect and centered other facets/interaction margins. JML
has free Person locations; MML uses the declared fixed normal or normal
population regression model. CML conditions out Person abilities and
requires no population distribution. PCM requires an explicit step
owner. Repeated ratings retain their declared treatment and every
response; a repeated row is not another independent Person.

The retained responses, score map and actual model constraints must
match the review. Its map is rebuilt. For JML/MML, a column-scaled SVD
removes only null directions of the conditional adjacent-logit map.
Every observed probability and invariant contrast is preserved; no
substantive effect is fixed to zero to identify a previously
unidentified target. For MML the transformation preserves the
conditional law at every latent node and leaves the variance coordinate
free. It therefore preserves the marginal likelihood, but does not prove
global marginal identification. The bounded review requires
`nrow(A) * ncol(A)` and `ncol(A)^2` no greater than two million, where
`A` is the conditional adjacent-logit design matrix. Numerically
sensitive or unevaluated maps yield unavailable estimates.

JML first checks the observed-category recession cone using the optional
`lpSolve` package. A detected recession or an inconclusive/unavailable
check withholds all estimates. This route does not deliver extended-MLE
contrasts when some parameters diverge. Unsupported category information
also blocks estimates. Numerical acceptance requires optimizer
convergence, full native gradient sup norm at most
`max(1e-4, 10 * reltol)` and reduced observed information eigenvalues
with minimum/maximum ratio greater than `1e-8` (the maximum is floored
at one). No covariance is inferred from this check. MML population fits
use three deterministic starting variances, requiring all starts to
converge, target agreement within `1e-4` logits and objective agreement
per Person within `1e-6`. Fixed-population MML has one start. MML also
checks `2 * quad_points + 1` nodes at the retained point, requiring the
same gradient tolerance and objective change per Person at most `1e-6`.
These numerical criteria are not sampling-precision guarantees or a
search proof of the global maximum. There is no automatic finer-grid
refit.

`interaction_effect_table(fit)` and `summary(fit)` return the declared
comparisons, retaining unidentified and failed rows with `Estimate = NA`
and `EstimateReason`. Available JML/MML estimates are
`descriptive_only`, in logits. Positive MML conditional ranks keep
primary `State = "not_evaluated"`. JML/MML SEs and interval endpoints
remain missing; `FormalInferenceEligible` is false. Save the full object
or table as RDS to retain weights, empty cells, assumptions and checks.
CSV retains visible columns only.

For CML, declare `method = "CML"` in the prospective review.
Identification uses differences between every possible response pattern
at the observed Person totals and rosters, constructed by a dynamic
program. A target is identifiable only if its coefficient vector is in
that row space. The same dense size bound applies to the
support-difference matrix and intermediate state vectors. Extreme totals
add no information. The zero origin main facet is coding for an effect
eliminated by conditioning, not an equal-ability population assumption.
`FreePersonState` remains a separate response-map audit.

CML optimizes the conditional likelihood in the identified subspace.
This preserves probabilities given the Person total, not arbitrary
unconditional category probabilities. If \\\beta=T\gamma+v\\, where
\\v\\ is a conditional null direction, an identified target \\C\beta\\
satisfies \\Cv=0\\. Its covariance is \$\$CT(T^T I_N T)^{-1}T^T C^T.\$\$
This expression is invariant to the choice of basis \\T\\ for the
identified coordinates and includes covariance with all estimable
nuisance directions. The asymptotic argument above applies in that
subspace when it stabilizes and its normalized information has a
positive-definite limit. Numerical identification in one sample does not
establish those conditions. It checks finite-MLE existence on the
complete conditional support and refuses all estimates if any recession
is detected or cannot be checked; extended-MLE target inference is
outside scope. Stationarity and unregularized information checks match
full-scope CML. If all checks pass, identified targets have
`EstimateStatus = "conditional_wald"`, `FormalInferenceEligible = TRUE`,
`SE`, and pointwise 95 percent `Lower`/`Upper` limits. If only
information fails, identified finite numerical points instead have
`EstimateStatus = "conditional_point"`,
`FormalInferenceEligible = FALSE`, missing SE/bounds and an
`EstimateReason` explaining the failure. Unidentified, boundary or
unqualified-stationarity targets do not acquire point estimates.
`$covariance` retains available joint covariance; unidentified or failed
covariance entries remain `NA`. The result also retains `person_totals`.
These are asymptotic intervals under the CML assumptions above, not a
finite-sample coverage guarantee or a calibrated DFF classification. CML
comparison fits estimate no population SD and cannot standardize by one.
Use `mfrm_facet_intervals(fit, level = .95)` to reuse their saved
targets through the existing interval plots and APA tables, preserving
unavailable rows; changing the confidence level does not refit the
model. Population and quadrature arguments are rejected for CML.

The result is an `mfrm_comparison_fit`, not an ordinary `mfrm_fit`.
Individual cell estimates, Person scoring, ordinary fit diagnostics and
prediction are not exposed through this class. `representation` and
`optimization` retain numerical coordinates for auditing only; their
representatives are not identified parameter estimates. Additional
anchors, shrinkage, corrected JML, GPCM, alternate MML
engines/integration, checkpoints and attached diagnostics are outside
this route. Explicit arguments outside data preparation, the reviewed
model and basic optimizer/quadrature controls are rejected, including
unsupported arguments set to their default values.

The estimable-function criterion is discussed by Lenth (2015),
<https://journal.r-project.org/articles/RJ-2015-016/>. Recession
directions and finite-MLE existence in exponential families are
distinguished by Geyer (2009), <https://www.stat.umn.edu/geyer/gdor/>.
These principles do not establish global MML identification or
finite-sample inference here.

## See also

[mfrm_fit_extractors](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md),
[mfrm_fit_responses](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_responses.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`estimate_bias()`](https://ryuya-dot-com.github.io/mfrmr/reference/estimate_bias.md),
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md),
[gpcm_capability_matrix](https://ryuya-dot-com.github.io/mfrmr/reference/gpcm_capability_matrix.md),
[mfrmr_workflow_methods](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_workflow_methods.md),
[mfrmr_reporting_and_apa](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reporting_and_apa.md)

## Examples

``` r
# Load the package
library(mfrmr)

# Load example ratings and look at the first six rows
ratings <- load_mfrmr_data("example_operational")
head(ratings)
#>                Study Person Rater    Criterion Score Group
#> 1 OperationalExample   P001   R01     Language     4     A
#> 2 OperationalExample   P001   R01 Organization     2     A
#> 3 OperationalExample   P001   R02      Content     4     A
#> 4 OperationalExample   P001   R02     Language     3     A
#> 5 OperationalExample   P001   R02 Organization     2     A
#> 6 OperationalExample   P002   R01      Content     3     A

# Fit the model
fit <- fit_mfrm(
  data = ratings,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  rating_min = 1, rating_max = 4, category_policy = "preserve",
  method = "MML",
  model = "RSM"
)

# Plot the results (Wright map)
plot(fit)


# Save the summary, then display its tables
results <- summary(fit)
results$person_overview # One row summarizing person ability estimates
#> # A tibble: 1 × 11
#>   Persons DistributionN ReviewExcludedExtremeE…¹ EstimateUse   Mean    SD Median
#>     <int>         <int>                    <int> <chr>        <dbl> <dbl>  <dbl>
#> 1      48            48                        0 source_fit… -0.155 0.824 -0.208
#> # ℹ abbreviated name: ¹​ReviewExcludedExtremeEAPs
#> # ℹ 4 more variables: Min <dbl>, Max <dbl>, Span <dbl>, MeanPosteriorSD <dbl>
results$facet_overview  # One row per facet: number of levels, mean, SD, range
#> # A tibble: 2 × 7
#>   Facet     Levels MeanEstimate SDEstimate MinEstimate MaxEstimate  Span
#>   <chr>      <int>        <dbl>      <dbl>       <dbl>       <dbl> <dbl>
#> 1 Criterion      3            0      0.302      -0.344       0.224 0.568
#> 2 Rater          6            0      0.399      -0.606       0.412 1.02 

# Check the interpretation status and recommended next step
results$decision
#>                                                           Interpretation
#> 1 Fit-readiness requirements satisfied; formal precision review required
#>   FormalInference FitReadiness                                              Why
#> 1              No        ready Formal precision support has not been evaluated.
#>                                                                                                                                                   NextAction
#> 1 Run `diagnose_mfrm()` and pass its result as `diagnostics =` to evaluate formal precision support; fit readiness alone is not a formal-inference decision.
```
