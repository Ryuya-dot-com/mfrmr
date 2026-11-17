# Technical Reference for fit_mfrm() Specifications, Controls, and Estimators

Offline specification dictionary for
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md):
`spec` and `control` keys, model equations, scale identification,
estimator scopes, information criteria, and return-object provenance.
Use
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
for the signature and first analysis,
[mfrmr_api_migration_030](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md)
for call migration, and
[mfrmr_methods_reference](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_methods_reference.md)
for primary methodological literature.

Every specification key below can be passed in `spec = list(...)`
(shared across
[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md),
[`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md),
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
and
[`export_mfrm_model()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_model.md)
within each function's supported scope) or as a named argument to
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md);
every control key below can be passed in `control = list(...)` or as a
named argument in `...`. Only `data`, `person`, `facets`, and `score`
retain positional order. Input data must be in long format (one row per
observed rating event).

## Specification entries (`spec = list(...)`)

- `person`:

  Character scalar naming the Person identifier column.

- `facets`:

  Character vector of non-Person facet column names. Reserved names
  (`Person`, `Score`, `Weight`, `score_k`, `theta`, `steps`,
  `interactions`, `log_slopes`, `beta`, `log_sigma2`) are rejected as
  facet names; rename colliding facet columns before analysis.

- `score`:

  Ordered integer category column (including binary `0/1` or `1/2`).
  Shared preparation rounds values within `1e-6` of an integer
  (`fit$prep$preparation_notes`) and rejects other fractions; corrected
  JML and two-family GPCM require exact integers. Empty boundary
  categories can imply a nonfinite MLE
  (`BoundaryState = "nonfinite_maximum"`); an unused preserved internal
  category stops ordinary fitting with a structured category-support
  error.

- `weight`:

  Optional positive observation-weight column powering each row's
  conditional likelihood contribution. Non-positive weights are dropped;
  non-unit weights exclude ordinary formal inference, facet equivalence,
  and the common MML IC panel.

- `rating_min`, `rating_max`:

  Optional intended rubric bounds, supplied together when boundary
  categories may be unobserved.

- `category_policy`:

  `"collapse"` (default when `keep_original = FALSE`) maps observed gaps
  to consecutive categories; `"preserve"` retains the declared
  `rating_min:rating_max` ladder (`fit$prep$score_map`).

- `keep_original`:

  Compatibility alias for category policy (`FALSE` = `"collapse"`,
  `TRUE` = `"preserve"`); must agree if both are supplied.

- `missing_codes`:

  Optional sentinel recoding to `NA` before preparation: `NULL` (none),
  `TRUE`/`"default"` (standard sentinel set on `score` only), or an
  explicit character vector across person, facet, and score columns
  (`fit$prep$missing_recoding`).

- `repeated_ratings`:

  `"review"` (default) warns on duplicate Person-by-facet cells and
  records an input-review state; `"independent"` records an analyst
  declaration of conditionally independent rating events without
  aggregating rows or altering the likelihood (unsupported in two-family
  GPCM).

- `model`:

  `"RSM"` (default), `"PCM"`, or `"GPCM"`.

- `method`:

  `"MML"` (default), `"JML"` (alias `"JMLE"`), or `"CML"` (native
  RSM/PCM with preserved categories and unit weights).

- `step_facet`:

  Single facet owning category-step vectors in `PCM` and `GPCM`
  (explicitly required for `GPCM` and `CML`; unused in `RSM`).

- `slope_facet`:

  Facet(s) owning positive discriminations in `GPCM`. One-family MML
  allows `slope_facet != step_facet`; JML requires equality; an ordered
  length-2 vector selects two-family GPCM MML.

- `gpcm_mml_identification`:

  Scale identification for one-family GPCM MML: `"free_population"`
  (default) estimates \\N(\beta_0,\sigma^2)\\ when
  `population_formula = NULL` with geometric-mean-one relative slopes
  (absolute standardized slopes \\\sigma\alpha_g\\);
  `"fixed_standard_normal"` fixes \\N(0,1)\\ alongside
  geometric-mean-one slopes (or reference-family geometric mean 1 in
  two-family GPCM).

- `anchors`:

  Optional direct location-anchor table (`Facet`, `Level`, `Anchor`) in
  internal logit coordinates. Person anchors require JML.

- `group_anchors`:

  Optional unweighted group-mean constraint table (`Facet`, `Level`,
  `Group`, `GroupValue` repeated across group members). Person group
  constraints require JML.

- `anchor_policy`:

  Issue handling in anchor review: `"warn"` (default in fitting),
  `"error"` (default in model export), or `"silent"`. Contradictory
  constraints always stop.

- `min_common_anchors`, `min_obs_per_element`, `min_obs_per_category`:

  Local count thresholds used by anchor-review recommendations (`5`,
  `10`, `10` by default); counts do not establish cross-run invariance.

- `slope_reference`:

  For two-family GPCM MML, names which member of `slope_facet` is
  constrained to geometric mean 1 (`NULL` selects the first supplied
  slope facet).

- `noncenter_facet`:

  Single facet left uncentered (default `"Person"`).

- `centering_scope`:

  `"facet"` (default) centers across all levels including
  anchors/groups; `"remainder"` centers unconstrained levels only;
  `"anchor_origin"` (ordinary additive RSM/PCM JML) replaces centering
  on anchored facets when an active unanchored `noncenter_facet` is
  chosen.

- `positive_facets`:

  Character vector of facets oriented `+1` (higher location = higher
  expected coded score); others use `-1`.

- `dummy_facets`:

  Character vector of facets fixed at `0`.

- `facet_interactions`:

  Optional confirmatory two-way non-Person interaction terms (e.g.,
  `"Rater:Criterion"`) in `RSM`/`PCM`, identified by zero row and column
  marginal sums.

- `min_obs_per_interaction`, `interaction_policy`:

  Minimum weighted cell count (`10`) and sparse-cell policy (`"warn"`,
  `"error"`, or `"silent"`) for `facet_interactions`.

- `population_formula`:

  Optional one-sided latent-regression formula (e.g., `~ grade + ses` or
  `~ 1`) for unidimensional conditional-normal `method = "MML"`
  (\\\theta \mid x \sim N(x^\top\beta,\sigma^2)\\).

- `person_data`, `person_id`:

  One-row-per-Person covariate `data.frame` (expanded via
  [`stats::model.matrix()`](https://rdrr.io/r/stats/model.matrix.html),
  storing `xlevels` and `contrasts`) and its Person ID column (defaults
  to `person`).

- `population_policy`:

  Missing-covariate policy for latent regression: `"error"` (default) or
  `"omit"` (records omitted Persons/rows in `fit$population`).

- `population_sd`:

  Optional positive fixed residual SD for direct additive RSM/PCM MML
  with an explicit `population_formula`.

## Estimation and numerical control entries (`control = list(...)`)

- `quad_points`:

  Gauss-Hermite quadrature order for MML (default `31`; automatic IC
  selection requires `>= 31`; check sensitivity with
  [`mml_quadrature_sensitivity()`](https://ryuya-dot-com.github.io/mfrmr/reference/mml_quadrature_sensitivity.md)).

- `mml_engine`:

  `"direct"` (default marginal-likelihood optimizer), `"em"` (fixed-grid
  RSM/PCM without covariates and two-family GPCM), or `"hybrid"` (EM
  warm-start followed by direct optimization).

- `mml_integration`:

  `"fixed"` (default), `"adaptive"` (moving posterior-mode Gauss-Hermite
  nodes in direct MML without checkpoints), or `"auto"` (checks Person
  log-marginal, EAP, SD, and gradient tolerances against refined rules;
  raises `mfrmr_mml_accuracy_error` on failure, recording
  `last_candidate` under `provenance_version = 2`).

- `mml_accuracy_control`:

  Named list for `mml_integration = "auto"`: ordinary MML defaults
  `adaptive_points = c(31, 61, 121)` (checked against `2*q + 1`),
  `loglik_tol = 1e-7`, `posterior_tol = 1e-6`, `gradient_tol = 1e-4`, or
  `max_points`; two-family defaults `max_points = 241` (`2*q - 1`
  reference).

- `mml_starts`:

  Optional deterministic offset vector or named list of free-coordinate
  starting vectors for ordinary RSM/PCM or one-family GPCM MML
  (`fit$opt$start_review`).

- `gpcm_mml_start`:

  Starting-value policy for two-family adaptive direct MML:
  `NULL`/`"neutral_em"` (compares neutral and fixed-grid EM seed under
  the adaptive objective), `"neutral"`, or a named list of `>= 2` native
  free-parameter vectors (`fit$opt$mml_initialization`).

- `em_score_tol`:

  Per-Person marginal score stopping tolerance for two-family GPCM
  MML-EM (`1e-6` when `NULL`; `NULL` required elsewhere).

- `checkpoint`:

  Optional `list(file = ..., every_iter = ...)` for resumable
  identity-checked MML EM runs.

- `maxit`:

  Iteration ceiling per optimization stage (default `400`), not a
  convergence guarantee.

- `reltol`:

  Optimizer tolerance (default `1e-9`). With `reltol <= 1e-9`, code-zero
  terminal-gradient shortfalls trigger bounded non-worsening polishing
  (`fit$opt$optimizer_polish`), including up to three sparse
  exact-information Newton steps in additive RSM/PCM JML
  (`jml_information_polish`) and curvature restarts (`<= 64` free
  parameters) in supported MML routes.

- `optimizer`:

  `"auto"` (default: L-BFGS-B for MML and JML with `>= 200` free
  parameters, BFGS otherwise), `"BFGS"`, or `"L-BFGS-B"` (see
  `OptimizerFactr` and `OptimizerPgtol` in `fit$summary`).

- `progress`:

  Logical (`FALSE` default) enabling `cli` elapsed-time display without
  changing numerical controls.

- `jml_penalty`:

  `"none"` (default) or `"jeffreys"` for additive RSM/PCM JML, returning
  `mfrm_jeffreys_fit`.

- `jml_correction_order`:

  `NULL` (default) or positive integer `k` selecting experimental
  profile-score bias adjustment for shared-owner GPCM JML (`nleqslv`
  required).

- `jml_correction_sampling`:

  Sandwich Person-covariance centering for corrected JML:
  `"fixed_rosters"` (default; `>= 2` Persons per pattern) or
  `"random_rosters"`.

- `facet_shrinkage`, `facet_prior_sd`, `shrink_person`:

  Post-fit descriptive Empirical Bayes adjustment (`"none"` default,
  `"empirical_bayes"`, or alias `"laplace"`), optional fixed prior SD,
  and ordinary-JML Person flag (`FALSE` default; see
  [`apply_empirical_bayes_shrinkage()`](https://ryuya-dot-com.github.io/mfrmr/reference/apply_empirical_bayes_shrinkage.md)).

- `attach_diagnostics`:

  Logical (`FALSE` default); if `TRUE`, runs
  `diagnose_mfrm(fit, residual_pca = "none")` once and attaches
  measure/step diagnostic columns.

- `fit_scope`, `comparison_review`:

  `"full"` (default) or `"comparisons"` with a matching
  [`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md)
  `comparison_review` returning `mfrm_comparison_fit`.

## Model and Logistic metric (D = 1)

All native models use the logistic metric with \\D = 1\\ (no
`1.7`/`1.702` multiplier). For additive `RSM`/`PCM` with Person \\n\\,
rater \\j\\, and criterion \\i\\: \$\$\ln\frac{P(X\_{nij} =
k)}{P(X\_{nij} = k-1)} = \theta_n - \delta_j - \beta_i - \tau_k\$\$
(`RSM` shares \\\tau_k\\; `PCM` estimates \\\tau\_{i,k}\\ per
`step_facet` level; binary `K = 1` reduces to \\\eta - \tau_1\\).
Confirmatory `facet_interactions` add \\+\gamma\_{ji}\\ with
\\\sum_j\gamma\_{ji} = 0\\ and \\\sum_i\gamma\_{ji} = 0\\. One-family
`GPCM` scales the complete adjacent-category predictor:
\$\$\ln\frac{P(X\_{nij} = k)}{P(X\_{nij} = k-1)} = \alpha_g(\eta -
\tau\_{h,k}),\quad \alpha_g \> 0,\quad \prod\_{g=1}^G \alpha_g^{1/G} =
1.\$\$ Because \\\alpha_g\\ multiplies \\\theta_n\\, all facet
locations, and \\\tau\_{h,k}\\, it differs from loading-only
formulations where slopes multiply \\\theta_n\\ alone.

Uncorrected JML jointly maximizes fixed Person and structural parameters
without finite bounds or the dichotomous \\(L-1)/L\\ heuristic, subject
to Neyman-Scott incidental-parameter bias at fixed ratings per Person
(Haberman, 2004). Exploratory JML location SEs use observation-table
information \\\mathrm{SE}\_g \approx \[\sum\_{r \in g} w_r a_r^2
\mathrm{Var}(X_r \mid \widehat\eta_r)\]^{-1/2}\\ (`Fixed = TRUE` rows
keep `NA` SEs). Extreme free JML Persons return `-Inf`/`Inf` in
`Estimate` (with computational trace in `OptimizerEstimate`); MML
integrates Persons over the declared normal prior and reports post-hoc
EAPs and posterior SDs.

## Two slope families

Setting `model = "GPCM"`, `method = "MML"`, `slope_facet = c(F1, F2)`,
`gpcm_mml_identification = "fixed_standard_normal"`, and explicit
`step_facet` and `noncenter_facet` fits the multiplicative Uto and Ueno
(2020) predictor \\\alpha\_{1,g}\alpha\_{2,m}(\eta - \tau\_{h,k})\\ on
one fixed \\N(0,1)\\ ability dimension using unweighted zero-based
integer scores (`0:rating_max`), with either fixed-grid `"em"` or
adaptive `"direct"` MML. `slope_reference` fixes one slope family's
geometric mean to `1` while the second family is free. Experimental
component-slope, step, and location intervals
([`confint.mfrm_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/confint.mfrm_fit.md),
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)),
fixed-calibration posterior residuals
([`mfrm_response_diagnostics()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_response_diagnostics.md)),
and conditional scoring
([`predict_mfrm_units()`](https://ryuya-dot-com.github.io/mfrmr/reference/predict_mfrm_units.md))
retain separate numerical checks; Wright maps, ordinary fit diagnostics,
and IC ranking remain unavailable (see
[mfrmr_gpcm_scope](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_gpcm_scope.md)).

## Corrected JML

Positive integer `jml_correction_order = k` solves the adjusted
profile-score equation \\U_k = (I - K\_\beta)^k U_0 = 0\\ (Dhaene &
Weidner, 2023, Section 8.1) for additive shared-owner GPCM JML with
preserved integer categories (`<= 5,000` joint owner-total states per
assignment pattern; no anchors, weights, interactions, or shrinkage).
Empirical Person-contribution Jacobians yield `RootSE` and `LogRootSE`
under `"fixed_rosters"` or `"random_rosters"`; these describe local root
variation rather than coverage-qualified structural confidence
intervals.

## Jeffreys-penalized JML

Setting `method = "JML", jml_penalty = "jeffreys"` on identified
unit-weight additive RSM/PCM with preserved `rating_min:rating_max`
minimizes \\-\ell(\beta) - \tfrac12\log\|I(\beta)\|\\ in affine free
canonical coordinates (Firth, 1993; Kosmidis & Firth, 2021), returning
`mfrm_jeffreys_fit`
([`summary.mfrm_jeffreys_fit()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_fit_extractors.md))
with point estimates and numerical checks (`checks$polish`), connecting
to common-plan expected-score intervals in
[`confint.mfrm_fair_average()`](https://ryuya-dot-com.github.io/mfrmr/reference/fair_average_table.md)
without Wald parameter SEs or ICs.

## Conditional maximum likelihood

Setting `method = "CML", category_policy = "preserve"` on unit-weight
additive or two-way-interaction RSM/PCM conditions on Person totals
\\s_p = \sum_j y\_{pj}\\: \$\$\ell_c(\beta) = \sum\_{p,j}
x\_{pj,y\_{pj}}^\top\beta - \sum_p \log \[t^{s_p}\] \prod_j
\sum\_{k=0}^K \exp(x\_{pjk}^\top\beta)t^k,\$\$ evaluated via log-scale
generalized ESF recursions with dynamic-programming LP recession checks
(`lpSolve`). Full-scope CML returns `mfrm_cml_fit` with unregularized
inverse conditional-information `covariance` (`NA` matrix with
`checks$information_status = "unavailable"` if singular) and connects to
[`mfrm_facet_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_facet_intervals.md)
without Person or population parameters (Mair & Hatzinger, 2007).

## Comparison-only estimation

Setting `fit_scope = "comparisons"` with a prospective
`comparison_review` returns `mfrm_comparison_fit` for identifiable
facet-by-origin contrasts in rank-deficient designs
(`nrow(A)*ncol(A) <= 2e6`, `ncol(A)^2 <= 2e6`). JML and MML project onto
the column-scaled SVD range and report `descriptive_only` contrast
points (`FormalInferenceEligible = FALSE`). CML optimizes in the
conditional support-difference subspace \\\beta = T\gamma + v\\ (\\Cv =
0\\) with basis-invariant covariance \\CT(T^\top I_N T)^{-1}T^\top
C^\top\\ (`EstimateStatus = "conditional_wald"` or
`"conditional_point"`), distinguishing estimability (Lenth, 2015) from
exponential-family recession cones (Geyer, 2009,
[doi:10.1214/08-EJS349](https://doi.org/10.1214/08-EJS349) ).

## Latent-regression workflow

With `method = "MML"`, `population_formula`, and one-row-per-Person
`person_data`, Person quadrature nodes follow \\\theta\_{nq} =
x_n^\top\beta + \sigma z_q\\. `summary(fit)$population_coefficients` and
`$population_overview` report point estimates without automatic SEs;
request experimental joint-information intervals via
[`mfrm_population_intervals()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_population_intervals.md)
(RSM/PCM). In anchored RSM/PCM cohorts, `noncenter_facet = "Rater"` with
a direct Rater anchor and `population_formula = ~ 1` (optionally fixed
`population_sd`) estimates the receiving-cohort mean without forcing new
raters to sum to zero.

## Pre-fit estimability and Information-criterion contract

Before optimization, sparse adjacent-logit rank checks stop exact rank
deficiency with `mfrmr_estimability_error` and warn
(`mfrmr_estimability_warning`) when MML cross-panel contrasts rely
solely on a shared population (`fit$data_review$estimability`, including
`normal_population_identification` and `nonlinear_local_estimability`).

For eligible unit-weight `MML` fits with `D = -2 * LogLik`, free
dimension `k = Npar`, and unique prepared Persons `N_person`
(`ICSampleSize`), the canonical panel is `AIC = D + 2*k`,
`BIC = D + log(N_person)*k`, and `SABIC = D + log((N_person + 2)/24)*k`
(`SABICSelectable = FALSE` when `N_person <= 22`). Ineligible fits set
canonical `AIC`/`BIC`/`SABIC` to `NA` (`LegacyAIC`/`LegacyBIC` retained
separately). `ICIntegrationTier` classifies `quad_points` (`< 15`
`"coarse_screening"`, `15:30` `"intermediate_review"`, `31:60`
`"standard_start"`, `>= 61` `"dense_sensitivity"`), with
`ICSelectable = FALSE` below `31` points in
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md).

## Detailed return-object provenance

Depending on estimator and scope,
[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
returns `mfrm_jeffreys_fit`, `mfrm_cml_fit`, `mfrm_comparison_fit`, or a
named `mfrm_fit` list with: `summary` (fit metrics, IC contract,
convergence, optimizer controls), `facets$person` (`Estimate`, MML `SD`,
`Extreme`, `SourceFitReadiness`, `EstimateUse`), `facets$others`,
`steps`, `slopes` (`OptimizerEstimate`, `PrimaryEstimate`,
`ParameterStatus`, `SEEligible`, `CIEligible`, `ReasonCodes`, plus
`point_limit` and `config$boundary_audit` records), `readiness`,
`interactions`, `population` (`person_table`, `person_table_replay`,
`xlevels`, `contrasts`, `estimation_converged`, `inference_ready`),
`data_review`, `config`, `prep`, and `opt` (`optimizer_diagnostics`,
`optimizer_polish`, `start_review`, `mml_initialization`).

## References

- Andrich, D. (1978). *Psychometrika*, 43(4), 561–573.

- Bock, R. D., & Aitkin, M. (1981). *Psychometrika*, 46(4), 443–459.

- Dhaene, G., & Weidner, M. (2023). *SERIEs*, 14, 379–416.
  [doi:10.1007/s13209-023-00283-1](https://doi.org/10.1007/s13209-023-00283-1)
  .

- Firth, D. (1993). *Biometrika*, 80(1), 27–38.
  [doi:10.1093/biomet/80.1.27](https://doi.org/10.1093/biomet/80.1.27) .

- Geyer, C. J. (2009). *Electronic Journal of Statistics*, 3, 259–289.
  [doi:10.1214/08-EJS349](https://doi.org/10.1214/08-EJS349) .

- Haberman, S. J. (2004). ETS Research Report RR-04-20.
  [doi:10.1002/j.2333-8504.2004.tb01947.x](https://doi.org/10.1002/j.2333-8504.2004.tb01947.x)
  .

- Kosmidis, I., & Firth, D. (2021). *Biometrika*, 108(1), 71–82.
  [doi:10.1093/biomet/asaa052](https://doi.org/10.1093/biomet/asaa052) .

- Linacre, J. M. (1989). *Many-facet Rasch measurement*. MESA Press.

- Mair, P., & Hatzinger, R. (2007). *Journal of Statistical Software*,
  20(9), 1–20.
  [doi:10.18637/jss.v020.i09](https://doi.org/10.18637/jss.v020.i09) .

- Masters, G. N. (1982). *Psychometrika*, 47(2), 149–174.

- Muraki, E. (1992). *Applied Psychological Measurement*, 16(2),
  159–176.

- Uto, M., & Ueno, M. (2020). *Behaviormetrika*, 47, 469–496.

## See also

[`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md),
[`describe_mfrm_data()`](https://ryuya-dot-com.github.io/mfrmr/reference/describe_mfrm_data.md),
[`review_mfrm_anchors()`](https://ryuya-dot-com.github.io/mfrmr/reference/review_mfrm_anchors.md),
[`export_mfrm_model()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_model.md),
[`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md),
[`mfrm_results()`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrm_results.md),
[mfrmr_gpcm_scope](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_gpcm_scope.md),
[mfrmr_api_migration_030](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_api_migration_030.md),
[mfrmr_methods_reference](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_methods_reference.md)
