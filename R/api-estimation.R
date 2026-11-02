# Validate the shared native observation route without computing unused diagnostics.
.mfrm_validate_diagnostic_fit <- function(fit) {
  stop_if_product_slopes(fit, "diagnose_mfrm()")
  if (inherits(fit, c("mfrm_testlet", "mfrm_random_rater"))) {
    stop("Use mfrm_response_diagnostics() for descriptive testlet/shared-rater posterior predictive residuals. Ordinary diagnose_mfrm() indices are unsupported; numerical checks are not model-fit diagnostics.", call. = FALSE)
  }
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an mfrm_fit object from fit_mfrm(). ",
         "Got: ", paste(class(fit), collapse = "/"), ".", call. = FALSE)
  }
  if (inherits(fit, "mfrm_imported_fit")) {
    stop("Native response-level diagnostics require a fit_mfrm() result. For imported fit statistics, re-import the source fit with compute_fit = TRUE.", call. = FALSE)
  }
  fit$config$method <- public_mfrm_method_label(fit$config$method)
  fit
}

# Shared canonical argument contracts for fit_mfrm(), describe_mfrm_data(),
# review_mfrm_anchors(), fit_mfrm_imputed(), and export_mfrm_model().
.mfrm_fit_spec_keys <- function() {
  c(
    "person", "facets", "score", "weight",
    "rating_min", "rating_max", "category_policy", "keep_original",
    "missing_codes", "repeated_ratings",
    "model", "method", "step_facet", "slope_facet", "slope_reference", "gpcm_mml_identification",
    "anchors", "group_anchors", "anchor_policy",
    "min_common_anchors", "min_obs_per_element", "min_obs_per_category",
    "noncenter_facet", "centering_scope", "positive_facets", "dummy_facets",
    "facet_interactions", "min_obs_per_interaction", "interaction_policy",
    "population_formula", "person_data", "person_id", "population_policy",
    "population_sd"
  )
}

.mfrm_fit_control_keys <- function() {
  c(
    "quad_points", "mml_engine", "mml_integration", "mml_accuracy_control",
    "mml_starts", "gpcm_mml_start", "em_score_tol", "checkpoint",
    "maxit", "reltol", "optimizer", "progress",
    "jml_penalty", "jml_correction_order", "jml_correction_sampling",
    "facet_shrinkage", "facet_prior_sd", "shrink_person", "attach_diagnostics",
    "fit_scope", "comparison_review"
  )
}

.mfrm_fit_canonical_defaults <- function() {
  list(
    data = NULL,
    person = NULL,
    facets = NULL,
    score = NULL,
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
    reltol = 1e-9,
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
    progress = FALSE,
    mml_starts = NULL,
    slope_reference = NULL
  )
}

.mfrm_fit_canonical_names <- function() {
  names(.mfrm_fit_canonical_defaults())
}

.mfrm_argument_hint <- function(bad_names) {
  canonical <- setdiff(.mfrm_fit_canonical_names(), "data")
  spec_keys <- .mfrm_fit_spec_keys()
  hints <- character(0)
  for (nm in bad_names) {
    if (!nzchar(nm)) next
    d <- utils::adist(nm, canonical, ignore.case = TRUE)[1L, ]
    best_i <- which.min(d)
    if (length(best_i) == 1L && is.finite(d[best_i]) && d[best_i] <= 3) {
      cand <- canonical[best_i]
      bucket <- if (cand %in% spec_keys) "`spec = list(...)`" else "`control = list(...)`"
      hints <- c(hints, sprintf("Did you mean `%s` (in %s)?", cand, bucket))
    }
  }
  if (length(hints)) paste0(" ", paste(unique(hints), collapse = " ")) else ""
}

.mfrm_validate_spec_list <- function(spec, caller = "fit_mfrm()") {
  if (is.null(spec)) return(list())
  if (!is.list(spec) || is.data.frame(spec)) {
    stop("`spec` in ", caller, " must be NULL or a named list of measurement-model specification settings.",
         call. = FALSE)
  }
  if (!length(spec)) return(list())
  nm <- names(spec)
  if (is.null(nm) || anyNA(nm) || any(!nzchar(nm)) || anyDuplicated(nm)) {
    stop("`spec` in ", caller, " must have unique non-empty names.", call. = FALSE)
  }
  extra <- setdiff(nm, .mfrm_fit_spec_keys())
  if (length(extra) > 0L) {
    in_ctrl <- intersect(extra, .mfrm_fit_control_keys())
    if (length(in_ctrl) > 0L) {
      stop("`spec` in ", caller, " contains estimation/numerical control entries (",
           paste(in_ctrl, collapse = ", "),
           "); pass them in `control = list(...)` instead of `spec`.",
           call. = FALSE)
    }
    stop("Unsupported or unknown entries in `spec`: ",
         paste(extra, collapse = ", "), ".", .mfrm_argument_hint(extra),
         call. = FALSE)
  }
  spec
}

.mfrm_validate_control_list <- function(control, caller = "fit_mfrm()") {
  if (is.null(control)) return(list())
  if (!is.list(control) || is.data.frame(control)) {
    stop("`control` in ", caller, " must be a named list of estimation/numerical control settings.",
         call. = FALSE)
  }
  if (!length(control)) return(list())
  nm <- names(control)
  if (is.null(nm) || anyNA(nm) || any(!nzchar(nm)) || anyDuplicated(nm)) {
    stop("`control` in ", caller, " must have unique non-empty names.", call. = FALSE)
  }
  extra <- setdiff(nm, .mfrm_fit_control_keys())
  if (length(extra) > 0L) {
    in_spec <- intersect(extra, .mfrm_fit_spec_keys())
    if (length(in_spec) > 0L) {
      stop("`control` in ", caller, " contains model/data specification entries (",
           paste(in_spec, collapse = ", "),
           "); pass them as top-level arguments or in `spec = list(...)` instead of `control`.",
           call. = FALSE)
    }
    stop("Unsupported or unknown entries in `control`: ",
         paste(extra, collapse = ", "), ".", .mfrm_argument_hint(extra),
         call. = FALSE)
  }
  control
}

#' Fit many-facet ordered-response models with a flexible number of facets
#'
#' Estimate effects on ordered ratings—such as rater severity, task or criterion
#' difficulty, category thresholds, and supported discriminations—together with
#' Person abilities where the estimator supplies them. Each row of `data` is one
#' observed rating event.
#'
#' Use the named arguments for a first analysis. A reusable
#' `spec = list(...)` groups model and identification choices across
#' [describe_mfrm_data()], [review_mfrm_anchors()], [fit_mfrm()], and
#' [export_mfrm_model()]; `control = list(...)` groups estimation and
#' post-fit settings. Historical
#' flat arguments remain supported when their full names are supplied, including
#' through `do.call()`. Only the first four positional arguments (`data`,
#' `person`, `facets`, `score`) retain their old positions. Use full names for
#' later arguments; abbreviations of names routed through `...` are rejected.
#' See [mfrmr_api_migration_030] for before/after calls and export scope limits.
#'
#' For help choosing an analysis, read the bundled guide with
#' `vignette("mfrmr-model-choice", package = "mfrmr")`. For exact specification
#' keys, estimator assumptions and numerical checks, use
#' [fit_mfrm_technical_details]; both guides are available offline in a standard
#' package installation.
#'
#' @param data A `data.frame` in long format with one row per observed rating
#'   event. Grouped or rowwise tibbles are analyzed as one table; dplyr grouping
#'   metadata is ignored. The named model columns define the design.
#'   Pass the rating table itself, not the result of
#'   [describe_mfrm_data()].
#' @param person Column name for Person identifiers (character scalar; may be
#'   supplied via `spec$person`).
#' @param facets Character vector of one or more non-Person facet column names
#'   (may be supplied via `spec$facets`). Reserved internal names (`Person`,
#'   `Score`, `Weight`, `score_k`, `theta`, `steps`, `interactions`,
#'   `log_slopes`, `beta`, `log_sigma2`) cannot be used as facet names.
#' @param score Column name for observed integer category scores (character
#'   scalar; may be supplied via `spec$score`).
#' @param model Measurement model: `"RSM"` (default; shared category
#'   thresholds), `"PCM"` (facet-specific thresholds via `step_facet`), or
#'   `"GPCM"` (positive facet-level discriminations via `slope_facet`).
#' @param method Estimator: `"MML"` (default marginal maximum likelihood),
#'   `"JML"` (`"JMLE"` alias; joint maximum likelihood), or `"CML"`
#'   (conditional maximum likelihood on Person totals for unit-weight RSM/PCM
#'   with preserved categories).
#' @param step_facet Facet whose levels own separate step ladders in `PCM` and
#'   `GPCM` (omit for `RSM`; required explicitly for `GPCM` and `CML` `PCM`).
#' @param slope_facet Facet whose levels own positive discriminations in `GPCM`
#'   (single facet name for one-family `GPCM`, or ordered length-two character
#'   vector for the experimental two-family MML route). Use
#'   `spec$slope_reference` to name the geometric-mean-one family (default:
#'   first slope facet); `step_facet` and `noncenter_facet` select their roles
#'   independently among declared non-Person facets. See
#'   [fit_mfrm_technical_details].
#' @param rating_min,rating_max Optional intended minimum and maximum category
#'   scores. Supply together (often with `spec = list(category_policy =
#'   "preserve")`) when boundary categories may be unobserved.
#' @param weight Optional column name of positive observation weights.
#' @param anchors Optional direct-anchor `data.frame` with columns `Facet`,
#'   `Level`, and `Anchor` fixing logit coordinates (non-Person facets in MML;
#'   JML also permits Person anchors).
#' @param group_anchors Optional group-mean constraint `data.frame` with
#'   columns `Facet`, `Level`, `Group`, and `GroupValue`.
#' @param population_formula Optional one-sided Person-level latent-regression
#'   formula (e.g., `~ group + pretest`) for unidimensional conditional-normal
#'   `method = "MML"`.
#' @param person_data Optional one-row-per-Person `data.frame` supplying
#'   covariates referenced by `population_formula`.
#' @param facet_interactions Optional confirmatory two-way non-Person
#'   interaction terms (e.g., `"Rater:Criterion"`) for `RSM` and `PCM`.
#' @param spec Optional named `list` of measurement-model, data-scale, and
#'   identification settings (see **Reusable model
#'   specification (`spec`)** below). Explicit top-level arguments override
#'   matching entries in `spec`, so a shared `base_spec` can be reused across
#'   [describe_mfrm_data()], [review_mfrm_anchors()], [fit_mfrm()], and
#'   [export_mfrm_model()] or varied across candidate models.
#' @param control Named `list` of numerical integration, optimizer, JML
#'   adjustment, post-fit shrinkage, and subfit controls (21 supported keys;
#'   see **Numerical and post-fit controls (`control`)** below).
#' @param ... Fully named legacy flat arguments from the supported `spec` and
#'   `control` settings. Unnamed arguments, abbreviated or unknown
#'   names, and duplicate specifications across `spec`/`control` and `...`
#'   fail immediately. Unused by the CML and comparison-fit summary/print methods.
#'
#' @section Core five-step workflow:
#' New analyses can reach the package's three pillars—measurement, G-theory
#' planning, and rater feedback—through five entry points:
#' 1. **Check the data and rubric:** `describe_mfrm_data(ratings, spec = spec)`
#'    (and `review_mfrm_anchors(ratings, spec = spec)` when anchoring).
#' 2. **Fit the measurement model:** `fit <- fit_mfrm(ratings, spec = spec)`.
#' 3. **Audit response fit and rater behavior:** `diag <- diagnose_mfrm(fit)`
#'    (followed by [estimate_bias()] or [analyze_dff()] when needed).
#' 4. **Evaluate rating-plan generalizability:** [mfrm_g_study()] and
#'    [mfrm_d_study()] on observed scores.
#' 5. **Visualize and report:** `plot(fit)` / `plot(res)` and
#'    `mfrm_report(mfrm_results(fit, diagnostics = diag))` (or
#'    `mfrmr_output_guide("core_workflow")` for the route map).
#'
#' @section Choose a model and its population:
#' For the `Rater` and `Criterion` columns in the Examples, the model choices
#' are below. A slope family gives one discrimination per level of its owner;
#' "two families" does not mean two ability dimensions or just two slopes.
#' No Q matrix is required or accepted by this unidimensional API.
#'
#' | Model | Step owner | Slope owner | MML population |
#' | --- | --- | --- | --- |
#' | `RSM` | Shared | Fixed at one | Fixed N(0,1) |
#' | `PCM` | `Criterion` | Fixed at one | Fixed N(0,1) |
#' | One-family `GPCM` | `Criterion` | `Criterion` | Estimated mean and SD |
#' | Two-family `GPCM` | `Rater` | `Criterion`, then `Rater` | Explicit fixed N(0,1) |
#'
#' Supply these owner names through `step_facet` and `slope_facet`; for two
#' families use `slope_facet = c("Criterion", "Rater")`. The first three rows
#' show their default MML populations. Two-family settings must be chosen
#' explicitly; see "Two slope families" in [fit_mfrm_technical_details].
#' One-family slopes are relative.
#'
#' Changing only `model` therefore need not hold the population assumptions
#' constant. For RSM/PCM, estimating its mean and SD requires
#' `population_formula = ~ 1` and `person_data = unique(ratings["Person"])`.
#' This is a model choice, not a universal recommendation. Fixing both the
#' population SD and the one-family GPCM slope geometric mean to one is a
#' narrower model, not just an alternative reporting scale.
#'
#' In ordinary RSM/PCM, fixed N(0,1) together with the default
#' `noncenter_facet = "Person"` centers all non-Person locations and every
#' step ladder. Without anchors changing these constraints, this also fixes
#' the overall ability-to-difficulty location; it is not merely identification.
#' For a complete binary two-rater by two-item design, symmetry forces the
#' average model-implied population success probability to 0.5. Unit Rasch
#' slopes already set the logit scale, so fixing the population SD to one is
#' an additional distributional assumption. For ordinary cohort calibration,
#' explicitly estimate the mean and SD using `population_formula = ~1` and
#' matching `person_data`; inspect the reported inference limits. To estimate
#' only the mean, additionally set `population_sd = 1` in supported direct MML.
#' Alternatively, a non-Person `noncenter_facet` permits an overall difficulty
#' location while retaining fixed N(0,1). These choices are different models.
#' Existing defaults remain for compatibility. Ordinary RSM/PCM export currently
#' requires a fixed N(0,1) population and rejects estimated-population fits;
#' do not drop `population_formula` to make an export run.
#'
#' Start with the complete RSM Examples. For PCM, add `step_facet` and change
#' `model`; for one-family GPCM, also explicitly choose `slope_facet` and
#' read the population choice above. Keep the data-column and rubric arguments.
#' The complete two-family call and its narrower output workflow are in
#' [online two-family workflow](https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-gpcm-scope.html#a-provisional-two-family-workflow).
#' Its zero-based scores and ordered owners require
#' the explicit preparation described there; changing `slope_facet` alone
#' is insufficient.
#'
#' @section Choose an estimator and the result you need:
#' The ordinary worked example uses RSM/MML. Choose the model and estimation
#' assumptions for your question before choosing a table or figure.
#' - **Abilities, a population model or GPCM inference:** use `method = "MML"`
#'   and inspect `summary(fit)$decision`. Its interpretation depends on the
#'   declared ability distribution. Ordinary RSM/PCM fixes N(0,1) by default;
#'   `population_formula = ~ 1` instead estimates its mean and SD. GPCM
#'   estimates them by default for one slope family; two families use fixed
#'   N(0,1). See "Choose a model and its population" above.
#' - **RSM/PCM structural effects without an ability distribution:** use
#'   `method = "CML", category_policy = "preserve"`. Read
#'   `summary(fit)$locations` and `$steps`, then [mfrm_facet_intervals()].
#'   CML returns no Person abilities or population SD; ordinary diagnostics
#'   and consolidated reports do not apply. See "Conditional maximum likelihood"
#'   in [fit_mfrm_technical_details] for assumptions and supported outputs.
#' - **Joint point estimates or FACETS comparisons:** explicitly select JML
#'   when that estimand is intended. With few ratings per Person, adding
#'   Persons does not remove incidental-parameter bias. Stored structural
#'   SEs or corrected-JML root uncertainty are not automatically truth intervals.
#'
#' Facet names are your column names, not fixed roles imposed by the package.
#' For example, `facets = c("Judge", "Task")` uses those two columns; it does
#' not require columns called Rater or Criterion. Supply the same names to
#' follow-up functions and use the fitted level labels for contrasts or curves.
#' Begin with the Examples section, then use the technical reference map below
#' for your selected model. [mfrmr_methods_reference] separates measurement,
#' G-theory assessment planning and observed-score agreement questions.
#'
#'
#' @section Reusable model specification (`spec`):
#' A single named `spec` list can be shared across [describe_mfrm_data()],
#' [review_mfrm_anchors()], [fit_mfrm()], and [export_mfrm_model()] (note that
#' [export_mfrm_model()] defaults omitted `anchor_policy` to `"error"` before
#' writing files, whereas [fit_mfrm()] defaults to `"warn"`):
#'
#' | Group | Supported `spec` keys (34 total) |
#' | --- | --- |
#' | Data & category ladder (10) | `person`, `facets`, `score`, `weight`, `rating_min`, `rating_max`, `category_policy` (`"collapse"` or `"preserve"`), `keep_original`, `missing_codes`, `repeated_ratings` (`"review"` or `"independent"`) |
#' | Model & slope/step owners (6) | `model` (`"RSM"`, `"PCM"`, `"GPCM"`), `method` (`"MML"`, `"JML"`, `"CML"`), `step_facet`, `slope_facet`, `slope_reference`, `gpcm_mml_identification` (`"free_population"` or `"fixed_standard_normal"`) |
#' | Anchors, orientation & centering (10) | `anchors`, `group_anchors`, `anchor_policy` (`"warn"`, `"error"`, `"silent"`), `min_common_anchors`, `min_obs_per_element`, `min_obs_per_category`, `noncenter_facet`, `centering_scope` (`"facet"`, `"remainder"`, `"anchor_origin"`), `positive_facets`, `dummy_facets` |
#' | Interactions & latent regression (8) | `facet_interactions`, `min_obs_per_interaction`, `interaction_policy`, `population_formula`, `person_data`, `person_id`, `population_policy` (`"error"` or `"omit"`), `population_sd` |
#'
#' @section Numerical and post-fit controls (`control`):
#' Pass computational and post-processing controls in `control = list(...)`
#' using the groups below. Numerical accuracy settings differ from choices
#' that change the estimator or output, such as JML penalties, shrinkage and
#' comparison-only fitting; choose those for the intended analysis.
#'
#' | Group | Supported `control` keys (21 total) |
#' | --- | --- |
#' | MML quadrature & engine (8) | `quad_points` (`31`), `mml_engine` (`"direct"`, `"em"`, `"hybrid"`), `mml_integration` (`"fixed"`, `"adaptive"`, `"auto"`), `mml_accuracy_control`, `mml_starts`, `gpcm_mml_start`, `em_score_tol`, `checkpoint` |
#' | Optimizer & console (4) | `maxit` (`400`), `reltol` (`1e-9`), `optimizer` (`"auto"`, `"BFGS"`, `"L-BFGS-B"`), `progress` (`FALSE`) |
#' | JML penalty & bias adjustment (3) | `jml_penalty` (`"none"`, `"jeffreys"`), `jml_correction_order`, `jml_correction_sampling` (`"fixed_rosters"`, `"random_rosters"`) |
#' | Post-fit shrinkage & diagnostics (4) | `facet_shrinkage` (`"none"`, `"empirical_bayes"`, `"laplace"`), `facet_prior_sd`, `shrink_person` (`FALSE`), `attach_diagnostics` (`FALSE`) |
#' | Comparison-only subfit (2) | `fit_scope` (`"full"`, `"comparisons"`), `comparison_review` |
#'
#' @section Technical reference map:
#' Every specialist mathematical and algorithmic section is preserved in full in
#' [fit_mfrm_technical_details]:
#' - **Scale & response equations:** *Model*, *Logistic metric (D = 1)*,
#'   *Weighting policy*, *Input requirements*, *Facet effects and rating counts*.
#' - **MML & GPCM identification / quadrature:** *GPCM model and inference*,
#'   *Two slope families*, *MML integration workflow*, *MML inference conditions*,
#'   *Information-criterion contract*.
#' - **JML, Jeffreys & CML estimators:** *Estimator choice and the JML
#'   incidental-parameter caveat*, *Corrected JML*, *Jeffreys-penalized JML*,
#'   *Conditional maximum likelihood*, *All-minimum and all-maximum Persons*.
#' - **Anchors, interactions, latent regression & subfits:** *Anchors and
#'   scale constraints*, *Anchor origin and cohort means*, *Model-estimated
#'   facet interactions*, *Comparison-only estimation*, *Latent-regression
#'   workflow*, *Latent-regression standard-error caveat*, *References*.
#'
#' @return
#' - Ordinary `MML` / `JML` (`fit_scope = "full"`, `jml_penalty = "none"`):
#'   an object of class `mfrm_fit` containing `summary`, `facets$person`,
#'   `facets$others`, `steps`, `slopes` (for `GPCM`), `readiness`,
#'   `interactions`, `population`, `data_review`, `config`, `prep`, and `opt`.
#'   Always inspect `summary(fit)$decision` and parameter eligibility columns
#'   (`EstimateUse`, `SEEligible`, `CIEligible`) before substantive reporting.
#' - `method = "JML", control = list(jml_penalty = "jeffreys")`: a separate
#'   `mfrm_jeffreys_fit` point-estimate object ([summary.mfrm_jeffreys_fit()]).
#' - `method = "CML"` (`fit_scope = "full"`): an `mfrm_cml_fit` object for
#'   structural locations/steps and [mfrm_facet_intervals()] contrasts.
#' - `control = list(fit_scope = "comparisons", comparison_review = ...)`: an
#'   `mfrm_comparison_fit` object extracted with [interaction_effect_table()].
#'
#' See **Detailed return-object provenance** in [fit_mfrm_technical_details] for
#' every column, boundary-audit record, and replay metadata field.
#'
#' @seealso [fit_mfrm_technical_details], [describe_mfrm_data()],
#'   [review_mfrm_anchors()], [export_mfrm_model()], [diagnose_mfrm()],
#'   [mfrm_results()], [mfrm_report()], [mfrmr_output_guide()],
#'   [mfrmr_gpcm_scope], [mfrmr_workflow_methods]
#' @examples
#' library(mfrmr)
#' ratings <- load_mfrmr_data("example_operational")
#' head(ratings)
#'
#' # 1. Reusable specification shared from data check to model fitting
#' spec <- list(
#'   person = "Person",
#'   facets = c("Rater", "Criterion"),
#'   score = "Score",
#'   rating_min = 1,
#'   rating_max = 4,
#'   category_policy = "preserve",
#'   model = "RSM",
#'   method = "MML"
#' )
#' data_check <- describe_mfrm_data(ratings, spec = spec)
#' data_check$row_retention
#'
#' fit <- fit_mfrm(ratings, spec = spec, control = list(quad_points = 31))
#' plot(fit)
#'
#' results <- summary(fit)
#' results$person_overview
#' results$facet_overview
#' results$decision
#'
#' # 2. Direct top-level override on the same shared spec (e.g., PCM)
#' fit_pcm <- fit_mfrm(
#'   ratings, spec = spec, model = "PCM", step_facet = "Criterion",
#'   control = list(quad_points = 15, maxit = 120)
#' )
#' summary(fit_pcm, profile = "fit", detail = "brief")
#'
#' \dontrun{
#' # Optional repeated fitting: compare specified starting values via control
#' reviewed <- fit_mfrm(
#'   ratings, spec = spec,
#'   control = list(mml_starts = c(0, 0.5, -0.5))
#' )
#' summary(reviewed)$starting_values
#' }
#' @export
fit_mfrm <- function(data,
                     person = NULL,
                     facets = NULL,
                     score = NULL,
                     model = c("RSM", "PCM", "GPCM"),
                     method = c("MML", "JML", "JMLE", "CML"),
                     step_facet = NULL,
                     slope_facet = NULL,
                     rating_min = NULL,
                     rating_max = NULL,
                     weight = NULL,
                     anchors = NULL,
                     group_anchors = NULL,
                     population_formula = NULL,
                     person_data = NULL,
                     facet_interactions = NULL,
                     spec = NULL,
                     control = list(),
                     ...) {
  mc <- match.call(expand.dots = FALSE)
  formal_supplied <- setdiff(names(as.list(mc)[-1L]), c("...", "spec", "control"))
  spec_list <- .mfrm_validate_spec_list(spec, "fit_mfrm()")
  ctrl_list <- .mfrm_validate_control_list(control, "fit_mfrm()")
  core_formal_names <- c(
    "data", "person", "facets", "score",
    "model", "method", "step_facet", "slope_facet",
    "rating_min", "rating_max", "weight",
    "anchors", "group_anchors",
    "population_formula", "person_data", "facet_interactions"
  )
  legacy_allowed <- setdiff(.mfrm_fit_canonical_names(), core_formal_names)
  dot_len <- ...length()
  dots <- if (dot_len > 0L) {
    dot_nms <- ...names()
    if (is.null(dot_nms) || length(dot_nms) != dot_len || anyNA(dot_nms) || any(!nzchar(dot_nms))) {
      stop("Unnamed extra arguments in `...` are not supported in `fit_mfrm()`. ",
           "Supply core arguments by name, or pass advanced settings via `spec = list(...)` or `control = list(...)`.",
           call. = FALSE)
    }
    if (anyDuplicated(dot_nms)) {
      stop("Duplicate argument(s) in `...`: ",
           paste(unique(dot_nms[duplicated(dot_nms)]), collapse = ", "), ".",
           call. = FALSE)
    }
    bad_dots <- setdiff(dot_nms, legacy_allowed)
    if (length(bad_dots) > 0L) {
      stop("Unknown argument(s) in `fit_mfrm()`: ",
           paste(bad_dots, collapse = ", "), ".", .mfrm_argument_hint(bad_dots),
           call. = FALSE)
    }
    list(...)
  } else {
    list()
  }
  dup_spec_dots <- intersect(names(spec_list), names(dots))
  if (length(dup_spec_dots) > 0L) {
    stop("Duplicate specification in both `spec` and `...`: ",
         paste(dup_spec_dots, collapse = ", "),
         ". Specify each setting in one place.",
         call. = FALSE)
  }
  dup_ctrl_dots <- intersect(names(ctrl_list), names(dots))
  if (length(dup_ctrl_dots) > 0L) {
    stop("Duplicate specification in both `control` and `...`: ",
         paste(dup_ctrl_dots, collapse = ", "),
         ". Specify each control setting in one place.",
         call. = FALSE)
  }
  resolved <- .mfrm_fit_canonical_defaults()
  if (length(spec_list) > 0L) resolved[names(spec_list)] <- spec_list
  if (length(ctrl_list) > 0L) resolved[names(ctrl_list)] <- ctrl_list
  if (length(dots) > 0L) resolved[names(dots)] <- dots
  for (nm in setdiff(formal_supplied, "data")) {
    resolved[nm] <- list(get(nm, envir = environment(), inherits = FALSE))
  }
  # Bind resolved arguments explicitly so static checks can see local names.
  # Defaults and precedence are determined above, before any binding changes.
  person <- resolved$person
  facets <- resolved$facets
  score <- resolved$score
  rating_min <- resolved$rating_min
  rating_max <- resolved$rating_max
  weight <- resolved$weight
  keep_original <- resolved$keep_original
  missing_codes <- resolved$missing_codes
  model <- resolved$model
  method <- resolved$method
  step_facet <- resolved$step_facet
  slope_facet <- resolved$slope_facet
  slope_reference <- resolved$slope_reference
  facet_interactions <- resolved$facet_interactions
  min_obs_per_interaction <- resolved$min_obs_per_interaction
  interaction_policy <- resolved$interaction_policy
  anchors <- resolved$anchors
  group_anchors <- resolved$group_anchors
  noncenter_facet <- resolved$noncenter_facet
  dummy_facets <- resolved$dummy_facets
  positive_facets <- resolved$positive_facets
  anchor_policy <- resolved$anchor_policy
  min_common_anchors <- resolved$min_common_anchors
  min_obs_per_element <- resolved$min_obs_per_element
  min_obs_per_category <- resolved$min_obs_per_category
  quad_points <- resolved$quad_points
  maxit <- resolved$maxit
  reltol <- resolved$reltol
  optimizer <- resolved$optimizer
  mml_engine <- resolved$mml_engine
  population_formula <- resolved$population_formula
  person_data <- resolved$person_data
  person_id <- resolved$person_id
  population_policy <- resolved$population_policy
  facet_shrinkage <- resolved$facet_shrinkage
  facet_prior_sd <- resolved$facet_prior_sd
  shrink_person <- resolved$shrink_person
  attach_diagnostics <- resolved$attach_diagnostics
  checkpoint <- resolved$checkpoint
  gpcm_mml_identification <- resolved$gpcm_mml_identification
  mml_integration <- resolved$mml_integration
  category_policy <- resolved$category_policy
  em_score_tol <- resolved$em_score_tol
  jml_correction_order <- resolved$jml_correction_order
  jml_correction_sampling <- resolved$jml_correction_sampling
  gpcm_mml_start <- resolved$gpcm_mml_start
  repeated_ratings <- resolved$repeated_ratings
  centering_scope <- resolved$centering_scope
  fit_scope <- resolved$fit_scope
  comparison_review <- resolved$comparison_review
  mml_accuracy_control <- resolved$mml_accuracy_control
  population_sd <- resolved$population_sd
  jml_penalty <- resolved$jml_penalty
  progress <- resolved$progress
  mml_starts <- resolved$mml_starts
  supplied_canonical <- unique(c(formal_supplied, names(spec_list), names(ctrl_list), names(dots)))
  close_progress <- mfrmr_start_fit_progress(progress)
  on.exit(close_progress(), add = TRUE)
  supplied_arguments <- setdiff(supplied_canonical, "progress")
  if (is.null(mml_starts)) supplied_arguments <- setdiff(supplied_arguments, "mml_starts")
  fit_scope <- match.arg(fit_scope, c("full", "comparisons"))
  if (fit_scope == "full" && !is.null(comparison_review))
    stop("Use fit_scope = 'comparisons' to fit a comparison review, or extract comparisons from a full fit with interaction_effect_table().", call. = FALSE)
  centering_scope <- match.arg(centering_scope, c("facet", "remainder", "anchor_origin"))
  repeated_ratings <- match.arg(repeated_ratings, c("review", "independent"))
  keep_original <- resolve_mfrm_category_policy(
    keep_original, category_policy, "keep_original" %in% supplied_canonical)
  # If users opt in to preparation messages, suppress duplicates that would
  # otherwise fire once in review_mfrm_anchors() and again in mfrm_estimate()
  # -> prepare_mfrm_data(). By default, preparation provenance is stored in the
  # returned object and displayed by summary/data-description helpers instead
  # of being emitted as routine messages.
  prior_announce_opt <- getOption("mfrmr._rating_range_announced")
  options(mfrmr._rating_range_announced = FALSE)
  on.exit(options(mfrmr._rating_range_announced = prior_announce_opt),
          add = TRUE)
  prior_prep_message_opt <- getOption("mfrmr._preparation_messages_announced")
  options(mfrmr._preparation_messages_announced = FALSE)
  on.exit(options(mfrmr._preparation_messages_announced = prior_prep_message_opt),
          add = TRUE)
  prior_score_recode_opt <- getOption("mfrmr._score_recode_announced")
  options(mfrmr._score_recode_announced = FALSE)
  on.exit(options(mfrmr._score_recode_announced = prior_score_recode_opt),
          add = TRUE)
  prior_duplicate_warning_opt <- getOption("mfrmr._duplicate_warning_announced")
  options(mfrmr._duplicate_warning_announced = FALSE)
  on.exit(options(mfrmr._duplicate_warning_announced = prior_duplicate_warning_opt),
          add = TRUE)
  # -- input validation --
  if (!is.data.frame(data)) {
    stop("`data` must be a data.frame. Got: ", class(data)[1], ". ",
         "Convert with as.data.frame() if needed.", call. = FALSE)
  }
  if (nrow(data) == 0) {
    stop("`data` has zero rows. ",
         "Supply a data.frame with at least one observation.", call. = FALSE)
  }
  if (!is.character(person) || length(person) != 1 || !nzchar(person)) {
    stop("`person` must be a single non-empty character string ",
         "naming the person column.", call. = FALSE)
  }
  if (!is.character(facets) || length(facets) == 0) {
    stop("`facets` must be a character vector of one or more facet column names.",
         call. = FALSE)
  }
  if (!is.character(score) || length(score) != 1 || !nzchar(score)) {
    stop("`score` must be a single non-empty character string ",
         "naming the score column.", call. = FALSE)
  }
  if (!is.null(weight) && (!is.character(weight) || length(weight) != 1)) {
    stop("`weight` must be NULL or a single character string ",
         "naming the weight column.", call. = FALSE)
  }
  integer_tolerance <- sqrt(.Machine$double.eps)
  if (!is.numeric(maxit) || length(maxit) != 1 ||
      !is.finite(maxit) || maxit < 1 ||
      abs(maxit - round(maxit)) > integer_tolerance) {
    stop("`maxit` must be a finite positive integer. Got: ",
         deparse(maxit), ".", call. = FALSE)
  }
  if (!is.numeric(reltol) || length(reltol) != 1 ||
      !is.finite(reltol) || reltol <= 0) {
    stop("`reltol` must be a finite positive number. Got: ",
         deparse(reltol), ".", call. = FALSE)
  }
  if (!is.numeric(quad_points) || length(quad_points) != 1 ||
      !is.finite(quad_points) || quad_points < 1 ||
      abs(quad_points - round(quad_points)) > integer_tolerance) {
    stop("`quad_points` must be a finite positive integer. Got: ",
         deparse(quad_points), ".", call. = FALSE)
  }
  if (!is.logical(attach_diagnostics) || length(attach_diagnostics) != 1L ||
      is.na(attach_diagnostics)) {
    stop("`attach_diagnostics` must be a single logical value (TRUE or FALSE).",
         call. = FALSE)
  }
  if (!is.null(person_id) && (!is.character(person_id) || length(person_id) != 1 || !nzchar(person_id))) {
    stop("`person_id` must be NULL or a single non-empty character string naming the person column in `person_data`.",
         call. = FALSE)
  }
  if (!is.null(slope_facet) && (!is.character(slope_facet) || !length(slope_facet) ||
                              anyNA(slope_facet) || any(!nzchar(slope_facet)))) {
    stop("`slope_facet` must be NULL or non-empty character strings naming facet columns.",
         call. = FALSE)
  }

  model <- toupper(match.arg(model, c("RSM", "PCM", "GPCM")))
  method_input <- public_mfrm_method_label(toupper(match.arg(method, c("MML", "JML", "JMLE", "CML"))))
  method <- method_input
  if (identical(centering_scope, "anchor_origin") &&
      (!identical(method, "JML") || !model %in% c("RSM", "PCM") ||
       length(facet_interactions) > 0L || fit_scope != "full")) {
    stop("`centering_scope = 'anchor_origin'` requires ordinary additive RSM/PCM JML with fit_scope = 'full'.",
         call. = FALSE)
  }
  optimizer <- normalize_mfrm_optimizer(match.arg(optimizer, c("auto", "BFGS", "L-BFGS-B")))
  mml_engine <- tolower(match.arg(mml_engine, c("direct", "em", "hybrid")))
  mml_integration <- match.arg(mml_integration, c("fixed", "adaptive", "auto"))
  jml_penalty <- match.arg(jml_penalty, c("none", "jeffreys"))
  if (!is.null(population_sd)) {
    if (!is.numeric(population_sd) || is.complex(population_sd) ||
        length(population_sd) != 1L || !is.finite(population_sd) ||
        population_sd <= 0 || !is.finite(population_sd^2) || population_sd^2 <= 0)
      stop("`population_sd` must be NULL or one positive finite number with a representable positive variance.", call. = FALSE)
    if (!model %in% c("RSM", "PCM") || method != "MML" ||
        mml_engine != "direct" || is.null(population_formula) ||
        fit_scope != "full" || length(facet_interactions))
      stop("`population_sd` requires a population_formula with full direct RSM/PCM MML and no interactions.", call. = FALSE)
    population_sd <- as.numeric(population_sd)
  }
  if (identical(mml_integration, "auto")) {
    product_auto <- identical(model, "GPCM") && length(slope_facet) == 2L &&
      is.null(jml_correction_order) && identical(jml_penalty, "none")
    if (!identical(method, "MML") || !is.null(checkpoint) || fit_scope != "full" ||
        (!product_auto && (!identical(mml_engine, "direct") || length(slope_facet) > 1L)) ||
        (product_auto && !mml_engine %in% c("em", "direct"))) {
      stop("`mml_integration = 'auto'` requires ordinary full MML with the direct engine, or two-family GPCM with the em/direct engine, and no checkpoint.",
        call. = FALSE)
    }
    mml_accuracy_control <- if (product_auto) mfrmr_gmfrm_accuracy_control(mml_accuracy_control) else
      mfrmr_mml_accuracy_control(mml_accuracy_control)
    if (!is.null(mml_accuracy_control$max_points)) {
      maximum_initial <- if (product_auto) floor((mml_accuracy_control$max_points + 1) / 2) else
        mml_accuracy_control$max_points
      if ("quad_points" %in% supplied_arguments && quad_points > maximum_initial)
        stop("`quad_points` exceeds the initial order allowed by `max_points`, including reference checks.", call. = FALSE)
      quad_points <- min(quad_points, maximum_initial)
    }
  } else if (!is.null(mml_accuracy_control)) {
    stop("`mml_accuracy_control` requires `mml_integration = 'auto'`.", call. = FALSE)
  }
  if (identical(mml_integration, "adaptive") &&
      (!identical(method, "MML") || !identical(mml_engine, "direct") || !is.null(checkpoint))) {
    stop("`mml_integration = 'adaptive'` requires MML with the direct engine and no checkpoint.",
         call. = FALSE)
  }
  if (!is.null(mml_starts) &&
      (method != "MML" || fit_scope != "full" || length(slope_facet) > 1L ||
       !is.null(jml_correction_order) || jml_penalty != "none" ||
       !is.null(checkpoint) || mml_integration == "auto"))
    stop("`mml_starts` requires ordinary full MML, fixed/adaptive integration and no checkpoint; two-family GPCM uses gpcm_mml_start.", call. = FALSE)
  gpcm_mml_identification <- match.arg(gpcm_mml_identification, c("free_population", "fixed_standard_normal"))
  interaction_policy <- tolower(match.arg(interaction_policy, c("warn", "error", "silent")))
  anchor_policy <- tolower(match.arg(anchor_policy, c("warn", "error", "silent")))
  population_policy <- tolower(match.arg(population_policy, c("error", "omit")))
  facet_shrinkage <- match.arg(facet_shrinkage, c("none", "empirical_bayes", "laplace"))
  if (jml_penalty != "none") {
    arguments <- mget(.mfrm_fit_canonical_names(), envir = environment(), inherits = FALSE)
    return(mfrm_fit_jeffreys(arguments, supplied_arguments))
  }
  if (!is.null(facet_prior_sd)) {
    if (!is.numeric(facet_prior_sd) || length(facet_prior_sd) != 1L ||
        !is.finite(facet_prior_sd) || facet_prior_sd < 0 ||
        !is.finite(facet_prior_sd^2) ||
        (facet_prior_sd > 0 && facet_prior_sd^2 == 0)) {
      stop("`facet_prior_sd` must be NULL or a non-negative finite scalar whose square is representable (positive when the SD is positive).",
           call. = FALSE)
    }
  }
  if (!is.logical(shrink_person) || length(shrink_person) != 1L ||
      is.na(shrink_person)) {
    stop("`shrink_person` must be a single logical value.", call. = FALSE)
  }
  if (!identical(facet_shrinkage, "none") && isTRUE(shrink_person) &&
      (!identical(method, "JML") || !is.null(jml_correction_order))) {
    stop("`shrink_person = TRUE` requires ordinary JML estimates with sampling SEs. EAP posterior SDs are not sampling SEs. Use shrink_person = FALSE to retain the original Person estimates.", call. = FALSE)
  }

  if (method == "CML" && fit_scope == "full") {
    arguments <- mget(.mfrm_fit_canonical_names(), envir = environment(), inherits = FALSE)
    return(mfrmr_fit_cml(arguments, supplied_arguments))
  }

  if (fit_scope == "comparisons") {
    arguments <- mget(.mfrm_fit_canonical_names(), envir = environment(), inherits = FALSE)
    return(mfrmr_fit_comparisons(arguments, supplied_arguments))
  }

  supplied_arguments <- setdiff(supplied_arguments, c("fit_scope", "comparison_review"))

  if (!is.null(gpcm_mml_start) &&
      !(length(slope_facet) == 2L && identical(model, "GPCM") &&
        identical(method_input, "MML") && identical(mml_engine, "direct") &&
        mml_integration %in% c("adaptive", "auto") && is.null(jml_correction_order)))
    stop("`gpcm_mml_start` applies only to two-family adaptive direct MML.", call. = FALSE)
  if (!is.null(slope_reference) &&
      (!identical(model, "GPCM") || !identical(method, "MML") || length(slope_facet) != 2L))
    stop("`slope_reference` applies only to two-family GPCM MML.", call. = FALSE)
  if (!is.null(jml_correction_order)) {
    arguments <- mget(.mfrm_fit_canonical_names(), envir = environment(), inherits = FALSE)
    return(mfrm_fit_adjusted_jml(arguments, supplied_arguments))
  }
  if ("jml_correction_sampling" %in% supplied_canonical)
    stop("`jml_correction_sampling` requires an explicit `jml_correction_order`.", call. = FALSE)
  if (length(slope_facet) > 1L) {
    arguments <- mget(.mfrm_fit_canonical_names(), envir = environment(), inherits = FALSE)
    if (identical(mml_integration, "auto"))
      return(mfrm_fit_product_slopes_auto(arguments, supplied_arguments))
    return(mfrm_fit_product_slopes(arguments, supplied_arguments))
  }
  if (!is.null(em_score_tol)) {
    stop("`em_score_tol` applies only to the two-family GPCM MML-EM route.", call. = FALSE)
  }

  gpcm_mml_active <- identical(model, "GPCM") && identical(method_input, "MML")
  if (gpcm_mml_active &&
      identical(gpcm_mml_identification, "fixed_standard_normal") &&
      !is.null(population_formula)) {
    stop(
      "`gpcm_mml_identification = \"fixed_standard_normal\"` requires ",
      "`population_formula = NULL`. Use `\"free_population\"` when estimating ",
      "a GPCM population model.",
      call. = FALSE
    )
  }

  auto_gpcm_population <- gpcm_mml_active &&
    identical(gpcm_mml_identification, "free_population") &&
    is.null(population_formula)
  effective_population_formula <- population_formula
  effective_person_data <- person_data
  effective_person_id <- person_id
  population_scaffold_data <- data
  estimation_person_ids <- as.character(data[[person]])
  if (auto_gpcm_population) {
    auto_in <- prepare_mfrm_auto_gpcm_scaffold_inputs(data, person, missing_codes)
    estimation_person_ids <- auto_in$estimation_person_ids
    population_scaffold_data <- auto_in$scaffold_data
    effective_population_formula <- auto_in$population_formula
    effective_person_data <- auto_in$person_data
    effective_person_id <- auto_in$person_id
  }

  population <- prepare_mfrm_population_scaffold(
    data = population_scaffold_data,
    person = person,
    population_formula = effective_population_formula,
    person_data = effective_person_data,
    person_id = effective_person_id,
    population_policy = population_policy
  )
  population <- annotate_mfrm_population_scaffold(
    population = population,
    data = data,
    scaffold_data = population_scaffold_data,
    gpcm_mml_active = gpcm_mml_active,
    auto_gpcm_population = auto_gpcm_population,
    population_sd = population_sd
  )
  if (isTRUE(population$active)) {
    if (!identical(method_input, "MML")) {
      stop("Latent-regression estimation requires `method = 'MML'`. ",
           "The requested population model is not available with JML.",
           call. = FALSE)
    }
    if (!identical(as.character(noncenter_facet[1]), "Person")) {
      if (auto_gpcm_population) {
        stop(
          "Default GPCM MML identification estimates an intercept-only ",
          "population model and therefore requires `noncenter_facet = \"Person\"`. ",
          "Use the default centering, or request ",
          "`gpcm_mml_identification = \"fixed_standard_normal\"` only when ",
          "the legacy restricted likelihood is intended.",
          call. = FALSE
        )
      }
      if (!model %in% c("RSM", "PCM") || is.null(population_sd) ||
          !identical(population$design_columns, "(Intercept)") ||
          any(population$design_matrix != 1) || length(dummy_facets) ||
          (!is.null(group_anchors) && NROW(group_anchors) > 0L))
        stop("Latent-regression identification requires `noncenter_facet = \"Person\"`, or an intercept-only RSM/PCM population with explicit `population_sd` and a direct anchor on the noncentered facet, without groups or dummy facets.", call. = FALSE)
      population$identification_role <- "direct_anchor_origin_fixed_population_sd"
    }
  }
  estimation_data <- data
  if (isTRUE(population$active) && !auto_gpcm_population &&
      length(population$included_persons) > 0) {
    estimation_mask <- estimation_person_ids %in% population$included_persons
    estimation_data <- data[estimation_mask, , drop = FALSE]
  }

  prep <- prepare_mfrm_data(
    data = estimation_data,
    person_col = person,
    facet_cols = facets,
    score_col = score,
    rating_min = rating_min,
    rating_max = rating_max,
    weight_col = weight,
    keep_original = keep_original,
    missing_codes = missing_codes,
    repeated_ratings = repeated_ratings,
    allow_single_person = TRUE
  )
  anchor_bundle <- review_mfrm_prepared_anchors(
    prep = prep,
    anchors = anchors,
    group_anchors = group_anchors,
    min_common_anchors = min_common_anchors,
    min_obs_per_element = min_obs_per_element,
    min_obs_per_category = min_obs_per_category,
    noncenter_facet = noncenter_facet,
    dummy_facets = dummy_facets,
    centering_scope = centering_scope
  )
  anchor_review <- anchor_bundle$anchor_review
  enforce_mfrm_anchor_review_policy(anchor_review, anchor_policy)
  anchors <- anchor_review$anchors
  group_anchors <- anchor_review$group_anchors

  fit <- mfrm_estimate(
    data = estimation_data,
    person_col = person,
    facet_cols = facets,
    score_col = score,
    rating_min = rating_min,
    rating_max = rating_max,
    weight_col = weight,
    keep_original = keep_original,
    missing_codes = missing_codes,
    model = model,
    method = method,
    step_facet = step_facet,
    slope_facet = slope_facet,
    facet_interactions = facet_interactions,
    min_obs_per_interaction = min_obs_per_interaction,
    interaction_policy = interaction_policy,
    anchor_df = anchors,
    group_anchor_df = group_anchors,
    noncenter_facet = noncenter_facet,
    dummy_facets = dummy_facets,
    positive_facets = positive_facets,
    population = population,
    quad_points = quad_points,
    maxit = maxit,
    reltol = reltol,
    optimizer = optimizer,
    mml_engine = mml_engine,
    mml_integration = mml_integration,
    mml_accuracy_control = mml_accuracy_control,
    mml_starts = mml_starts,
    checkpoint = checkpoint,
    repeated_ratings = repeated_ratings,
    centering_scope = centering_scope,
    prep = prep,
    anchor_review = anchor_review,
    constraint_specs = anchor_bundle$constraint_specs
  )

  fit$config$anchor_review <- anchor_review
  fit$config$method_input <- method_input
  fit$population <- finalize_mfrm_population_fit(fit, population)
  fit$config$population_spec <- compact_population_spec(fit$population, fit$prep$levels$Person)
  fit$config$population_active <- isTRUE(population$active)
  fit$config$posterior_basis <- as.character(fit$population$posterior_basis %||% "legacy_mml")
  fit$config$population_policy <- fit$population$policy %||% NULL
  fit$config$gpcm_mml_identification_requested <-
    as.character(gpcm_mml_identification)
  fit$config$gpcm_mml_identification <- if (gpcm_mml_active) {
    as.character(gpcm_mml_identification)
  } else if (identical(model, "GPCM") && identical(method_input, "JML")) {
    "not_applicable_jml"
  } else {
    "not_applicable"
  }
  fit$config$gpcm_common_discrimination <- if (
    gpcm_mml_active && identical(gpcm_mml_identification, "free_population")
  ) {
    "estimated_via_population_sd"
  } else if (gpcm_mml_active) {
    "fixed_to_one_legacy_restriction"
  } else {
    "not_applicable"
  }
  fit$config$gpcm_estimator_family <- if (!identical(model, "GPCM")) {
    "not_applicable"
  } else if (identical(method_input, "JML")) {
    "unpenalized_identified_jml"
  } else {
    "marginal_maximum_likelihood"
  }
  gpcm_identity <- mfrmr_gpcm_model_identity(model)
  fit$config$gpcm_model_family <- gpcm_identity$model_family
  fit$config$gpcm_slope_action <- gpcm_identity$slope_action
  fit$config$gpcm_slope_composition <- gpcm_identity$slope_composition
  fit$config$gpcm_latent_dimension_count <-
    gpcm_identity$latent_dimension_count
  # These fields describe the statistical objective, not numerical line-search
  # safeguards. The current GPCM routes use neither a regularization penalty
  # nor finite box constraints on person, location, step, or slope coordinates.
  fit$config$gpcm_statistical_penalty <- if (identical(model, "GPCM")) {
    "none"
  } else {
    "not_applicable"
  }
  fit$config$gpcm_finite_parameter_box <- if (identical(model, "GPCM")) {
    FALSE
  } else {
    NA
  }
  fit$config$gpcm_extreme_person_policy <- if (!identical(model, "GPCM")) {
    "not_applicable"
  } else if (identical(method_input, "JML")) {
    "extended_real_primary_when_certified"
  } else {
    "posterior_eap_under_population_model"
  }
  fit$config$population_formula <- if (!is.null(fit$population$formula)) {
    paste(deparse(fit$population$formula), collapse = " ")
  } else {
    NULL
  }

  if (identical(model, "GPCM") && identical(method_input, "MML") &&
      nrow(fit$slopes %||% data.frame()) > 0L) {
    fitted_population_sd <- if (isTRUE(fit$population$active)) {
      sqrt(as.numeric(fit$population$sigma2 %||% NA_real_)[1])
    } else {
      1
    }
    optimizer_relative <- as.numeric(
      fit$slopes$OptimizerEstimate %||% fit$slopes$Estimate
    )
    primary_relative <- as.numeric(
      fit$slopes$PrimaryEstimate %||% rep(NA_real_, nrow(fit$slopes))
    )
    fit$slopes$PopulationSD <- rep(fitted_population_sd, nrow(fit$slopes))
    fit$slopes$FixedLatentSDOptimizerEstimate <-
      fitted_population_sd * optimizer_relative
    fit$slopes$FixedLatentSDPrimaryEstimate <-
      fitted_population_sd * primary_relative
    fit$slopes$FixedLatentSDBasis <- if (isTRUE(fit$population$active)) {
      "population_sd_times_relative_slope"
    } else {
      "legacy_unit_population_sd_times_relative_slope"
    }
  }

  class(fit) <- c("mfrm_fit", class(fit))

  # Optional empirical-Bayes / Laplace shrinkage applied post-fit
  # post-hoc on the fitted facet estimates. The `"none"` default
  # preserves the no-shrinkage behavior; other choices add
  # `ShrunkEstimate` / `ShrunkSE` / `ShrinkageFactor` columns and a
  # `shrinkage_report` table. See `?apply_empirical_bayes_shrinkage`
  # and the "Empirical-Bayes shrinkage" section of `?fit_mfrm`.
  if (!identical(facet_shrinkage, "none")) {
    fit <- .apply_shrinkage_to_fit(
      fit = fit,
      method = facet_shrinkage,
      facet_prior_sd = facet_prior_sd,
      shrink_person = isTRUE(shrink_person)
    )
  } else {
    fit$config$facet_shrinkage <- "none"
    fit$config$facet_prior_sd <- NULL
  }

  # Capture every `fit_mfrm()` argument that affects the fit so that
  # `export_mfrm_bundle()` can write a complete replay script. We
  # store inputs as supplied (post `match.arg`) rather than rederiving
  # them from `fit$config`, because some arguments (e.g.
  # `missing_codes`, `min_obs_per_*`, `anchor_policy`) only take
  # effect during preparation and are not otherwise echoed back.
  fit$config$replay_inputs <- list(
    person = as.character(person),
    facets = as.character(facets),
    score = as.character(score),
    weight = if (is.null(weight)) NULL else as.character(weight),
    rating_min = rating_min,
    rating_max = rating_max,
    keep_original = isTRUE(keep_original),
    missing_codes = missing_codes,
    model = as.character(model),
    method = as.character(method_input),
    step_facet = if (is.null(step_facet)) NULL else as.character(step_facet),
    slope_facet = if (is.null(slope_facet)) NULL else as.character(slope_facet),
    gpcm_mml_identification = as.character(gpcm_mml_identification),
    facet_interactions = facet_interactions,
    min_obs_per_interaction = as.numeric(min_obs_per_interaction),
    interaction_policy = as.character(interaction_policy),
    anchors = anchors,
    group_anchors = group_anchors,
    noncenter_facet = as.character(noncenter_facet),
    centering_scope = centering_scope,
    dummy_facets = if (length(dummy_facets) > 0L) as.character(dummy_facets) else NULL,
    positive_facets = if (length(positive_facets) > 0L) as.character(positive_facets) else NULL,
    anchor_policy = as.character(anchor_policy),
    min_common_anchors = as.integer(min_common_anchors),
    min_obs_per_element = as.numeric(min_obs_per_element),
    min_obs_per_category = as.numeric(min_obs_per_category),
    quad_points = as.integer(quad_points),
    maxit = as.integer(maxit),
    reltol = as.numeric(reltol),
    optimizer = as.character(optimizer),
    mml_engine = as.character(mml_engine),
    mml_integration = mml_integration,
    mml_accuracy_control = mml_accuracy_control,
    population_formula = population_formula,
    population_sd = population_sd,
    person_id = if (is.null(person_id)) NULL else as.character(person_id),
    population_policy = as.character(population_policy),
    facet_shrinkage = as.character(facet_shrinkage),
    facet_prior_sd = facet_prior_sd,
    shrink_person = isTRUE(shrink_person),
    attach_diagnostics = isTRUE(attach_diagnostics),
    repeated_ratings = repeated_ratings,
    package_version = as.character(utils::packageVersion("mfrmr"))
  )

  if (!is.null(mml_starts)) fit$config$replay_inputs$mml_starts <- mml_starts

  if (isTRUE(attach_diagnostics)) {
    fit <- attach_diagnostics_to_fit(fit)
  } else {
    fit$config$attached_diagnostics <- FALSE
  }

  fit
}

#' Extract model-estimated facet interaction effects
#'
#' `interaction_effect_table()` returns the fixed-effect interaction block
#' estimated by [fit_mfrm()] when `facet_interactions` is supplied. These are
#' model-estimated deviations from the additive main-effects MFRM, not the
#' residual screening statistics returned by [estimate_bias()].
#'
#' @param fit An `mfrm_fit` or `mfrm_comparison_fit` returned by [fit_mfrm()].
#' @param comparison_review Optional result of [describe_mfrm_data()] with
#'   `comparisons`, or its `$comparison_review` component. Returns the declared
#'   interaction contrasts from a matching joint fit instead of individual cells.
#'
#' @details
#' mfrmr supports two-way interactions between non-person facets,
#' for example `facet_interactions = "Rater:Criterion"`. Each interaction matrix
#' is identified by zero marginal sums across both participating facets, so the
#' interaction estimates are separable from the two main effects. Positive values
#' indicate higher-than-expected scores for the facet-level combination under the
#' additive model; negative values indicate lower-than-expected scores.
#'
#' Use this table for confirmatory model review after specifying the facet pair
#' of substantive interest. For exploratory screening without adding parameters
#' to the fitted model, use [estimate_bias()] or [estimate_all_bias()].
#'
#' With `comparison_review`, first fit the declared model using the review's
#' `fit_arguments` and the original ratings. The fit must match the retained
#' responses, origins, score coding, model, constraints, facet orientation,
#' step owner and population design. Only native, unadjusted RSM/PCM fits
#' without shrinkage are supported. The contrast is the declared weighted
#' sum of Group1-minus-Group2 interaction effects, in logits. Positive means
#' a relative shift toward higher coded scores; it is not an absolute school
#' effect or evidence of unfairness. Location and step effects are not added.
#'
#' This route reevaluates the retained likelihood and full gradient without
#' optimization. Objective agreement must be within `1e-6` and the gradient
#' sup norm within `max(1e-4, 10 * reltol)`, matching the ordinary numerical
#' stopping tolerance. For MML it also evaluates `2 * q + 1` quadrature nodes,
#' requiring the finer-grid gradient to meet that tolerance and the absolute
#' negative-log-likelihood change per Person to be at most `1e-6`.
#' These are numerical checks, not statistical precision criteria. A failed
#' check retains the row with `Estimate = NA` and an explanation; the separate
#' `OptimizerEstimate` is a diagnostic trace. No refit or partial fit is run.
#'
#' `EstimateStatus = "descriptive_only"` requires full conditional-map rank,
#' numerical convergence, current readiness information and no recorded
#' blocking condition or boundary exclusion. It does not certify finite-MLE
#' existence, global marginal identification or sampling performance. MML
#' retains `State = "not_evaluated"` for positive conditional ranks even when
#' a descriptive fitted contrast is available. `BoundaryState`,
#' `FitReadiness`, `NumericalState` and `QuadratureState` remain separate.
#' `SE`, `Lower`, `Upper` remain missing and `FormalInferenceEligible` remains
#' false. A target-only identified contrast in a rejected full model remains
#' unavailable through this route. Save the returned table with `saveRDS()`
#' to preserve its review and checks without recalculation; CSV retains the
#' visible columns but not the attributes.
#'
#' For a `mfrm_comparison_fit` created with `fit_scope = "comparisons"`, omit
#' `comparison_review`: the table already contains the declared targets and
#' their partial-fit checks. Extraction does not fit again. See [fit_mfrm()]
#' for its likelihood-preserving parameterization, availability requirements
#' and limits. For full RSM/PCM MML fits, [mfrm_facet_intervals()] with the same
#' `comparison_review` separately supplies model-information intervals and
#' supported population-SD standardization; extraction here stays descriptive.
#' CML comparison fits add conditional-information SEs and pointwise
#' 95 percent Wald limits for identified targets, with `conditional_wald` status;
#' unidentified rows remain missing. The ordinary full-fit route above remains unchanged.
#'
#' @return A tibble with one row per interaction cell. Returns an empty tibble
#'   when the fit has no model-estimated facet interactions. With
#'   `comparison_review`, one row per requested contrast with availability,
#'   numerical and readiness fields; attributes `comparison_review`,
#'   `fit_checks` and `notes` preserve the prospective question, source
#'   fingerprint and numerical evidence, and interpretation limits.
#' @seealso [fit_mfrm()], [describe_mfrm_data()], [summary.mfrm_fit()],
#'   [estimate_bias()], [compare_mfrm()], [mfrmr_linking_and_dff]
#' @examples
#' # Supplementary workflow: run explicitly to keep routine checks brief.
#' # example("interaction_effect_table", run.dontrun = TRUE)
#' \dontrun{
#' toy <- load_mfrmr_data("example_operational")
#' fit <- fit_mfrm(
#'   toy, person = "Person", facets = c("Rater", "Criterion"),
#'   score = "Score", method = "MML", model = "RSM",
#'   facet_interactions = "Rater:Criterion",
#'   quad_points = 7, maxit = 30
#' )
#' head(interaction_effect_table(fit))
#' }
#' @seealso [mfrm_facet_intervals()] with `interaction` for supported
#'   fixed-population RSM/PCM MML cell intervals from full joint information.
#' @export
interaction_effect_table <- function(fit, comparison_review = NULL) {
  if (inherits(fit, "mfrm_comparison_fit")) {
    if (!is.null(comparison_review))
      stop("A comparison fit retains its declared targets; omit comparison_review when extracting it.", call. = FALSE)
    return(fit$comparisons)
  }
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an mfrm_fit object returned by fit_mfrm().",
         call. = FALSE)
  }
  if (!is.null(comparison_review)) {
    return(mfrmr_fitted_comparison_table(fit, comparison_review))
  }
  tbl <- fit$interactions$effects
  if (is.null(tbl)) {
    return(tibble::tibble())
  }
  tibble::as_tibble(tbl)
}

# Internal: merge per-level fit statistics from diagnose_mfrm() onto
# fit$facets$others so downstream code can read SE / Infit / Outfit
# alongside Estimate without re-running the diagnostics pass.
attach_diagnostics_to_fit <- function(fit) {
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an mfrm_fit.", call. = FALSE)
  }
  others <- fit$facets$others
  person <- fit$facets$person
  if ((is.null(others) || nrow(others) == 0L) &&
      (is.null(person) || nrow(person) == 0L)) {
    fit$config$attached_diagnostics <- TRUE
    return(fit)
  }
  diag <- tryCatch(
    suppressMessages(suppressWarnings(
      diagnose_mfrm(fit, residual_pca = "none")
    )),
    error = function(e) NULL
  )
  if (is.null(diag) || is.null(diag$measures)) {
    fit$config$attached_diagnostics <- FALSE
    fit$config$attached_diagnostics_note <-
      "diagnose_mfrm() did not return a measures table; attach skipped."
    return(fit)
  }
  structural_uncertainty <- diag$parameter_uncertainty %||% list()
  m <- as.data.frame(diag$measures, stringsAsFactors = FALSE)
  # diagnose_mfrm() exposes the point-measure correlation under the key
  # `PTMEA` (FACETS fixed-width label); the attach layer renames it to
  # `PtMeaCorr` so fit$facets$others matches the FACETS Table 7 column
  # naming the user most often expects.
  merge_cols <- intersect(
    c("ModelSE", "Infit", "Outfit", "InfitZSTD", "OutfitZSTD",
      "PTMEA", "PtMeaCorr", "InferenceReady", "SupportsFormalInference",
      "SEUse", "CIEligible", "CIUse", "CIBasis", "CILabel"),
    names(m)
  )
  if (length(merge_cols) == 0L) {
    fit$config$attached_diagnostics <- FALSE
    return(fit)
  }
  keep <- c("Facet", "Level", merge_cols)
  m <- m[, keep, drop = FALSE]
  m$Facet <- as.character(m$Facet)
  m$Level <- as.character(m$Level)
  # Rename to FACETS Table 7 conventions: ModelSE -> SE, PTMEA -> PtMeaCorr.
  if ("ModelSE" %in% names(m)) {
    names(m)[names(m) == "ModelSE"] <- "SE"
  }
  if ("PTMEA" %in% names(m)) {
    names(m)[names(m) == "PTMEA"] <- "PtMeaCorr"
  }
  attached_cols <- setdiff(names(m), c("Facet", "Level"))

  # Non-person facets table.
  if (!is.null(others) && nrow(others) > 0L) {
    others$Facet <- as.character(others$Facet)
    others$Level <- as.character(others$Level)
    others_m <- m[m$Facet != "Person", , drop = FALSE]
    # Drop any columns that are being newly attached to avoid duplicates
    # when the helper is called a second time (idempotent merge).
    others[, intersect(attached_cols, names(others))] <- NULL
    others <- merge(others, others_m, by = c("Facet", "Level"),
                    all.x = TRUE, sort = FALSE)
    fit$facets$others <- others
  }

  # Person facet table (added so summary(fit) can show per-person fit).
  if (!is.null(person) && nrow(person) > 0L) {
    person_df <- as.data.frame(person, stringsAsFactors = FALSE)
    person_df$Person <- as.character(person_df$Person)
    person_m <- m[m$Facet == "Person", , drop = FALSE]
    if (nrow(person_m) > 0L) {
      person_m$Person <- as.character(person_m$Level)
      person_m <- person_m[, c("Person", attached_cols), drop = FALSE]
      # When the existing person table already carries a model SE column,
      # prefer it (e.g. MML posterior SE) and only attach the diagnostic
      # SE if the existing column is empty / NA.
      person_attach_cols <- attached_cols
      if ("SE" %in% person_attach_cols && "SE" %in% names(person_df) &&
          any(is.finite(suppressWarnings(as.numeric(person_df$SE))))) {
        person_attach_cols <- setdiff(person_attach_cols, "SE")
        person_m$SE <- NULL
      }
      person_df[, intersect(person_attach_cols, names(person_df))] <- NULL
      person_df <- merge(person_df, person_m, by = "Person",
                         all.x = TRUE, sort = FALSE)
      fit$facets$person <- tibble::as_tibble(person_df)
    }
  }

  step_unc <- as.data.frame(structural_uncertainty$steps %||% data.frame(), stringsAsFactors = FALSE)
  if (!is.null(fit$steps) && nrow(fit$steps) > 0L && nrow(step_unc) > 0L) {
    step_keys <- intersect(c("StepFacet", "Step"), names(fit$steps))
    if (!"StepFacet" %in% names(fit$steps) && "Step" %in% names(fit$steps)) {
      step_keys <- "Step"
    }
    if (length(step_keys) > 0L && all(step_keys %in% names(step_unc))) {
      attach_step_cols <- setdiff(names(step_unc), c(step_keys, "Estimate"))
      if (length(attach_step_cols) > 0L) {
        step_df <- as.data.frame(fit$steps, stringsAsFactors = FALSE)
        step_df[, intersect(attach_step_cols, names(step_df))] <- NULL
        fit$steps <- merge(
          step_df,
          step_unc[, c(step_keys, attach_step_cols), drop = FALSE],
          by = step_keys,
          all.x = TRUE,
          sort = FALSE
        )
      }
    }
  }

  slope_unc <- as.data.frame(structural_uncertainty$slopes %||% data.frame(), stringsAsFactors = FALSE)
  if (!is.null(fit$slopes) && nrow(fit$slopes) > 0L && nrow(slope_unc) > 0L &&
      "SlopeFacet" %in% names(fit$slopes) && "SlopeFacet" %in% names(slope_unc)) {
    attach_slope_cols <- setdiff(names(slope_unc), c("SlopeFacet", "LogEstimate", "Estimate"))
    if (length(attach_slope_cols) > 0L) {
      slope_df <- as.data.frame(fit$slopes, stringsAsFactors = FALSE)
      slope_df[, intersect(attach_slope_cols, names(slope_df))] <- NULL
      fit$slopes <- merge(
        slope_df,
        slope_unc[, c("SlopeFacet", attach_slope_cols), drop = FALSE],
        by = "SlopeFacet",
        all.x = TRUE,
        sort = FALSE
      )
    }
  }

  if (!is.null(fit$readiness$parameters)) {
    fit$readiness$parameters <- mfrm_update_slope_readiness_parameters(
      fit$readiness$parameters, slope_unc)
  }
  fit$config$attached_diagnostics <- TRUE
  fit$config$attached_diagnostics_cols <- attached_cols
  fit
}

finalize_mfrm_population_fit <- function(fit, population) {
  pop <- population %||% list()
  if (!isTRUE(pop$active)) {
    return(pop)
  }

  sizes <- build_param_sizes(fit$config)
  params <- expand_params(fit$opt$par, sizes, fit$config)
  coeff <- as.numeric(params$population$coefficients %||% numeric(0))
  coeff_names <- names(params$population$coefficients %||% NULL)
  if (!is.null(coeff_names) && length(coeff_names) == length(coeff)) {
    names(coeff) <- coeff_names
  }

  notes <- as.character(pop$notes %||% character(0))
  notes <- c(
    notes,
    "Latent-regression parameters were estimated under the MML population-model branch."
  )

  pop$coefficients <- coeff
  pop$sigma2 <- as.numeric(params$population$sigma2[1] %||% NA_real_)
  convergence <- mfrm_convergence_state(fit)
  pop$estimation_converged <- isTRUE(convergence$code_converged)
  pop$inference_ready <- isTRUE(convergence$inference_ready)
  # Retain the historical field without allowing its ambiguous name to hide
  # the distinction between optimizer convergence and inference readiness.
  pop$converged <- pop$inference_ready
  pop$converged_basis <- "legacy_alias_of_inference_ready"
  pop$logLik_component <- as.numeric(fit$summary$LogLik[1] %||% NA_real_)
  pop$posterior_basis <- "population_model"
  pop$design_columns <- pop$design_columns %||% names(coeff)
  pop$notes <- unique(notes)
  pop
}

prepare_mfrm_population_scaffold <- function(data,
                                             person,
                                             population_formula = NULL,
                                             person_data = NULL,
                                             person_id = NULL,
                                             population_policy = c("error", "omit"),
                                             population_xlevels = NULL,
                                             population_contrasts = NULL,
                                             require_full_rank = TRUE,
                                             population_terms = NULL) {
  if (is.null(population_formula)) {
    return(list(
      active = FALSE,
      formula = NULL,
      person_id = if (is.null(person_id)) person else person_id,
      person_table = NULL,
      person_table_replay = NULL,
      person_table_replay_scope = NULL,
      design_matrix = NULL,
      design_columns = NULL,
      xlevels = NULL,
      contrasts = NULL,
      coefficients = NULL,
      sigma2 = NULL,
      converged = FALSE,
      posterior_basis = "legacy_mml",
      policy = NULL,
      included_persons = character(0),
      omitted_persons = character(0),
      response_rows_retained = nrow(data),
      response_rows_omitted = 0L,
      notes = "No population model was requested; this fit uses an unconditional normal person distribution."
    ))
  }

  population_policy <- match.arg(population_policy)
  if (inherits(population_formula, "terms")) {
    population_contrasts <- population_contrasts %||%
      attr(population_formula, "mfrm_population_contrasts", exact = TRUE)
    population_xlevels <- population_xlevels %||%
      attr(population_formula, "mfrm_population_xlevels", exact = TRUE)
  }
  population_formula <- tryCatch(
    stats::as.formula(population_formula),
    error = function(e) {
      stop("`population_formula` must be coercible to a one-sided formula such as `~ grade + ses`. ",
           "Original error: ", conditionMessage(e), call. = FALSE)
    }
  )
  if (length(population_formula) != 2L) {
    stop("`population_formula` must be a one-sided formula such as `~ grade + ses`.",
         call. = FALSE)
  }
  if (!is.data.frame(person_data)) {
    stop("`person_data` must be a data.frame with one row per person when `population_formula` is supplied.",
         call. = FALSE)
  }
  if (is.null(person_id)) {
    if (!person %in% names(person_data)) {
      stop("`person_data` must contain the person column `", person,
           "` or you must supply `person_id` explicitly when `population_formula` is used.",
           call. = FALSE)
    }
    person_id <- person
  }
  if (!person_id %in% names(person_data)) {
    stop("`person_id = '", person_id, "'` is not a column in `person_data`.",
         call. = FALSE)
  }

  observed_persons <- unique(as.character(data[[person]]))
  person_tbl <- as.data.frame(person_data, stringsAsFactors = FALSE)
  person_tbl[[person_id]] <- as.character(person_tbl[[person_id]])
  if (anyNA(person_tbl[[person_id]]) || any(!nzchar(person_tbl[[person_id]]))) {
    stop("`person_data` contains missing or empty person IDs in column `", person_id, "`.",
         call. = FALSE)
  }
  dup_ids <- unique(person_tbl[[person_id]][duplicated(person_tbl[[person_id]])])
  if (length(dup_ids) > 0) {
    preview <- paste(utils::head(dup_ids, 5), collapse = ", ")
    stop("`person_data` must contain one unique row per person. Duplicate IDs detected in `",
         person_id, "`: ", preview, if (length(dup_ids) > 5) ", ..." else ".", call. = FALSE)
  }
  missing_persons <- setdiff(observed_persons, person_tbl[[person_id]])
  if (length(missing_persons) > 0) {
    preview <- paste(utils::head(missing_persons, 5), collapse = ", ")
    stop("`person_data` is missing ", length(missing_persons), " person(s) observed in `data`: ",
         preview, if (length(missing_persons) > 5) ", ..." else ".", call. = FALSE)
  }

  keep_idx <- match(observed_persons, person_tbl[[person_id]])
  person_tbl <- person_tbl[keep_idx, , drop = FALSE]
  rownames(person_tbl) <- NULL
  person_tbl_replay <- person_tbl

  model_frame_args <- list(
    formula = population_terms %||% population_formula,
    data = person_tbl,
    na.action = stats::na.pass
  )
  if (!is.null(population_xlevels)) {
    model_frame_args$xlev <- population_xlevels
  }
  mf <- tryCatch(
    do.call(stats::model.frame, model_frame_args),
    error = function(e) {
      stop("Could not build the latent-regression model frame from `person_data`. ",
           "Original error: ", conditionMessage(e), call. = FALSE)
    }
  )
  mf_names <- names(mf)
  if (length(mf_names) > 0) {
    unsupported <- mf_names[vapply(mf[mf_names], function(x) is.list(x) || is.data.frame(x), logical(1))]
    if (length(unsupported) > 0) {
      stop("Variables referenced in `population_formula` must be atomic columns usable by stats::model.matrix(). ",
           "Numeric, logical, factor, ordered factor, and character predictors are supported; unsupported columns: ",
           paste(unsupported, collapse = ", "), ".", call. = FALSE)
    }
  }

  complete_mask <- if (ncol(mf) == 0) rep(TRUE, nrow(person_tbl)) else stats::complete.cases(mf)
  omitted_persons <- person_tbl[[person_id]][!complete_mask]
  if (length(omitted_persons) > 0 && identical(population_policy, "error")) {
    preview <- paste(utils::head(omitted_persons, 5), collapse = ", ")
    stop("`person_data` contains missing covariate values for persons referenced by `population_formula`. ",
         "Use `population_policy = 'omit'` to fit the complete-case analysis set instead. Affected IDs: ",
         preview, if (length(omitted_persons) > 5) ", ..." else ".", call. = FALSE)
  }
  if (length(omitted_persons) > 0) {
    person_tbl <- person_tbl[complete_mask, , drop = FALSE]
    mf <- mf[complete_mask, , drop = FALSE]
    rownames(person_tbl) <- NULL
    rownames(mf) <- NULL
  }
  if (nrow(person_tbl) == 0) {
    stop("No persons remain in `person_data` after applying the latent-regression covariate policy.",
         call. = FALSE)
  }

  included_persons <- as.character(person_tbl[[person_id]])
  response_keep <- as.character(data[[person]]) %in% included_persons
  response_rows_retained <- sum(response_keep)
  response_rows_omitted <- sum(!response_keep)

  terms_obj <- attr(mf, "terms") %||% stats::terms(population_formula)
  mm <- tryCatch(
    stats::model.matrix(terms_obj, data = mf, contrasts.arg = population_contrasts),
    error = function(e) {
      stop("Could not build the latent-regression design matrix from `person_data`. ",
           "Original error: ", conditionMessage(e), call. = FALSE)
    }
  )
  xlevels <- tryCatch(stats::.getXlevels(terms_obj, mf), error = function(e) NULL)
  mm_contrasts <- attr(mm, "contrasts", exact = TRUE)
  qr_mm <- qr(mm)
  if (isTRUE(require_full_rank) && qr_mm$rank < ncol(mm)) {
    stop("The latent-regression design matrix is rank-deficient. ",
         "Adjust `population_formula` or the coding of `person_data` before fitting.",
         call. = FALSE)
  }
  # Rank-deficiency alone will not catch near-singular designs (e.g. two
  # covariates with correlation 0.9999). Warn when the reciprocal condition
  # number is very small so users are not silently handed a fit whose
  # coefficients are dominated by numerical noise.
  mm_rcond <- tryCatch(suppressWarnings(rcond(mm)), error = function(e) NA_real_)
  if (isTRUE(require_full_rank) && is.finite(mm_rcond) && mm_rcond < 1e-8) {
    warning(sprintf(
      paste0("Latent-regression design matrix is near-singular (rcond = %.1e). ",
             "Estimated coefficients may be unstable; consider dropping ",
             "redundant covariates or rescaling `person_data`."),
      mm_rcond
    ), call. = FALSE)
  }

  notes <- c(
    "Latent-regression covariates are active.",
    "Person-level covariates and their design matrix were prepared for MML estimation."
  )
  if (length(omitted_persons) > 0) {
    notes <- c(
      notes,
      paste0("Complete-case preparation retained ", nrow(person_tbl), " person(s) and omitted ",
             length(omitted_persons), " person(s) under `population_policy = 'omit'`.")
    )
  }
  if (response_rows_omitted > 0) {
    notes <- c(
      notes,
      paste0("For latent-regression estimation, ", response_rows_omitted,
             " response row(s) would be excluded because their persons lack complete background data.")
    )
  }

  list(
    active = TRUE,
    formula = population_formula,
    terms = terms_obj,
    person_id = person_id,
    person_table = person_tbl,
    person_table_replay = person_tbl_replay,
    person_table_replay_scope = "observed_person_subset_pre_omit",
    design_matrix = mm,
    design_columns = colnames(mm),
    xlevels = xlevels,
    contrasts = mm_contrasts,
    coefficients = NULL,
    sigma2 = NULL,
    converged = FALSE,
    posterior_basis = "population_model",
    policy = population_policy,
    included_persons = included_persons,
    omitted_persons = as.character(omitted_persons),
    response_rows_retained = as.integer(response_rows_retained),
    response_rows_omitted = as.integer(response_rows_omitted),
    notes = notes
  )
}

format_anchor_review_message <- function(anchor_review) {
  if (is.null(anchor_review$issue_counts) || nrow(anchor_review$issue_counts) == 0) {
    return("Anchor review detected no issues.")
  }
  nonzero <- anchor_review$issue_counts |>
    dplyr::filter(.data$N > 0)
  if (nrow(nonzero) == 0) {
    return("Anchor review detected no issues.")
  }
  labels <- paste0(nonzero$Issue, "=", nonzero$N)
  paste0(
    "Anchor review detected ", sum(nonzero$N), " issue row(s): ",
    paste(labels, collapse = "; "),
    ". Invalid rows, if any, were removed; duplicate keys keep the last row.",
    if (any(nonzero$Issue == "overlap_anchor_group"))
      " Overlapping direct and group anchors retain both constraints." else ""
  )
}

normalize_expected_mfrm_design <- function(expected_design, person, facets) {
  if (is.null(expected_design)) return(NULL)
  if (!is.data.frame(expected_design)) {
    stop("`expected_design` must be a data.frame.", call. = FALSE)
  }
  required <- c(person, facets)
  missing_cols <- setdiff(required, names(expected_design))
  if (length(missing_cols) > 0L) {
    stop(
      "`expected_design` is missing required column(s): ",
      paste(missing_cols, collapse = ", "), ".",
      call. = FALSE
    )
  }
  if (nrow(expected_design) == 0L) {
    stop("`expected_design` must contain at least one planned rating cell.", call. = FALSE)
  }

  out <- as.data.frame(expected_design[, required, drop = FALSE], stringsAsFactors = FALSE)
  names(out)[1L] <- "Person"
  out[] <- lapply(out, function(x) trimws(as.character(x)))
  invalid <- vapply(out, function(x) any(is.na(x) | !nzchar(x)), logical(1))
  if (any(invalid)) {
    stop(
      "`expected_design` contains missing or blank IDs in: ",
      paste(names(out)[invalid], collapse = ", "), ".",
      call. = FALSE
    )
  }
  duplicate_rows <- duplicated(out) | duplicated(out, fromLast = TRUE)
  if (any(duplicate_rows)) {
    stop(
      "`expected_design` must contain one row per planned Person x ",
      paste(facets, collapse = " x "),
      " cell; duplicate planned cells were found.",
      call. = FALSE
    )
  }
  out
}

audit_mfrm_expected_design <- function(df, expected_design, facets) {
  key_cols <- c("Person", facets)
  observed <- unique(as.data.frame(df[, key_cols, drop = FALSE], stringsAsFactors = FALSE))
  empty_cells <- observed[0, , drop = FALSE]

  if (is.null(expected_design)) {
    level_coverage <- purrr::map_dfr(facets, function(facet) {
      tibble::tibble(
        Facet = facet,
        ExpectedLevels = NA_integer_,
        ObservedLevels = dplyr::n_distinct(observed[[facet]]),
        ExpectedOnlyLevels = NA_integer_,
        UnexpectedLevels = NA_integer_
      )
    })
    return(list(
      summary = data.frame(
        Status = "not_declared",
        ExpectedCells = NA_integer_,
        ObservedCells = nrow(observed),
        MatchedCells = NA_integer_,
        MissingExpectedCells = NA_integer_,
        UnexpectedObservedCells = NA_integer_,
        CoverageRate = NA_real_,
        ExpectedOnlyPersons = NA_integer_,
        UnexpectedPersons = NA_integer_,
        stringsAsFactors = FALSE
      ),
      missing_expected_cells = empty_cells,
      unexpected_observed_cells = empty_cells,
      level_coverage = as.data.frame(level_coverage, stringsAsFactors = FALSE),
      settings = list(
        declared = FALSE,
        key = key_cols,
        note = paste0(
          "Structural missingness was not assessed because `expected_design` was not supplied. ",
          "Absent rows cannot be distinguished from cells that were never assigned."
        )
      )
    ))
  }

  matched <- dplyr::semi_join(expected_design, observed, by = key_cols)
  missing_expected <- dplyr::anti_join(expected_design, observed, by = key_cols)
  unexpected_observed <- dplyr::anti_join(observed, expected_design, by = key_cols)
  level_coverage <- purrr::map_dfr(facets, function(facet) {
    expected_levels <- unique(expected_design[[facet]])
    observed_levels <- unique(observed[[facet]])
    tibble::tibble(
      Facet = facet,
      ExpectedLevels = length(expected_levels),
      ObservedLevels = length(observed_levels),
      ExpectedOnlyLevels = length(setdiff(expected_levels, observed_levels)),
      UnexpectedLevels = length(setdiff(observed_levels, expected_levels))
    )
  })

  list(
    summary = data.frame(
      Status = "declared",
      ExpectedCells = nrow(expected_design),
      ObservedCells = nrow(observed),
      MatchedCells = nrow(matched),
      MissingExpectedCells = nrow(missing_expected),
      UnexpectedObservedCells = nrow(unexpected_observed),
      CoverageRate = nrow(matched) / nrow(expected_design),
      ExpectedOnlyPersons = length(setdiff(expected_design$Person, observed$Person)),
      UnexpectedPersons = length(setdiff(observed$Person, expected_design$Person)),
      stringsAsFactors = FALSE
    ),
    missing_expected_cells = as.data.frame(missing_expected, stringsAsFactors = FALSE),
    unexpected_observed_cells = as.data.frame(unexpected_observed, stringsAsFactors = FALSE),
    level_coverage = as.data.frame(level_coverage, stringsAsFactors = FALSE),
    settings = list(
      declared = TRUE,
      key = key_cols,
      note = "Observed unique cells were compared with the explicitly declared assignment roster."
    )
  )
}

summarize_duplicate_mfrm_cells <- function(df, facets) {
  key_cols <- c("Person", facets)
  detail <- df |>
    dplyr::group_by(dplyr::across(dplyr::all_of(key_cols))) |>
    dplyr::summarise(
      Observations = dplyr::n(),
      WeightedN = sum(.data$Weight, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::filter(.data$Observations > 1L) |>
    dplyr::arrange(dplyr::desc(.data$Observations)) |>
    as.data.frame(stringsAsFactors = FALSE)

  list(
    summary = data.frame(
      DuplicateCells = nrow(detail),
      RowsInDuplicateCells = if (nrow(detail) > 0L) sum(detail$Observations) else 0L,
      ExtraRows = if (nrow(detail) > 0L) sum(detail$Observations - 1L) else 0L,
      HasDuplicates = nrow(detail) > 0L,
      stringsAsFactors = FALSE
    ),
    detail = detail
  )
}

mfrm_bipartite_components <- function(cells, facet, basis, include_persons = FALSE) {
  edges <- unique(as.data.frame(cells[, c("Person", facet), drop = FALSE], stringsAsFactors = FALSE))
  edges$Person <- as.character(edges$Person)
  edges[[facet]] <- as.character(edges[[facet]])
  persons_to_levels <- split(edges[[facet]], edges$Person)
  levels_to_persons <- split(edges$Person, edges[[facet]])
  unseen <- unique(edges$Person)
  components <- list()

  while (length(unseen) > 0L) {
    component_persons <- unseen[1L]
    component_levels <- character(0)
    repeat {
      next_levels <- unique(unname(unlist(
        persons_to_levels[component_persons], use.names = FALSE
      )))
      next_persons <- unique(unname(unlist(
        levels_to_persons[next_levels], use.names = FALSE
      )))
      expanded_persons <- union(component_persons, next_persons)
      expanded_levels <- union(component_levels, next_levels)
      if (setequal(expanded_persons, component_persons) &&
          setequal(expanded_levels, component_levels)) break
      component_persons <- expanded_persons
      component_levels <- expanded_levels
    }
    component_edges <- sum(
      edges$Person %in% component_persons & edges[[facet]] %in% component_levels
    )
    components[[length(components) + 1L]] <- data.frame(
      Basis = basis,
      Facet = facet,
      Component = length(components) + 1L,
      Persons = length(component_persons),
      FacetLevels = length(component_levels),
      Edges = component_edges,
      LevelLabels = paste(sort(component_levels), collapse = ", "),
      PersonLabels = if (isTRUE(include_persons)) {
        paste(sort(component_persons), collapse = ", ")
      } else {
        ""
      },
      stringsAsFactors = FALSE
    )
    unseen <- setdiff(unseen, component_persons)
  }

  component_table <- do.call(rbind, components)
  largest_index <- which.max(component_table$Persons)
  summary <- data.frame(
    Basis = basis,
    Facet = facet,
    PersonNodes = length(unique(edges$Person)),
    FacetLevelNodes = length(unique(edges[[facet]])),
    Edges = nrow(edges),
    Components = nrow(component_table),
    LargestComponentPersons = component_table$Persons[largest_index],
    LargestComponentLevels = component_table$FacetLevels[largest_index],
    LargestComponentPercent = 100 * component_table$Persons[largest_index] /
      length(unique(edges$Person)),
    Connected = nrow(component_table) == 1L,
    stringsAsFactors = FALSE
  )
  list(summary = summary, components = component_table)
}

audit_mfrm_connectivity <- function(df, expected_design, facets, include_persons = FALSE) {
  bases <- list(observed = df)
  if (!is.null(expected_design)) bases$declared_expected <- expected_design
  audits <- unlist(lapply(names(bases), function(basis) {
    lapply(facets, function(facet) {
      mfrm_bipartite_components(
        bases[[basis]], facet, basis, include_persons = include_persons
      )
    })
  }), recursive = FALSE)

  list(
    summary = do.call(rbind, lapply(audits, `[[`, "summary")),
    components = do.call(rbind, lapply(audits, `[[`, "components"))
  )
}

summarize_linkage_by_facet <- function(df, facet, min_linking_persons = 2L) {
  by_level <- df |>
    dplyr::group_by(.data[[facet]]) |>
    dplyr::summarize(
      PersonsPerLevel = dplyr::n_distinct(.data$Person),
      Observations = dplyr::n(),
      WeightedN = sum(.data$Weight, na.rm = TRUE),
      .groups = "drop"
    )

  by_person <- df |>
    dplyr::group_by(.data$Person) |>
    dplyr::summarize(
      LevelsPerPerson = dplyr::n_distinct(.data[[facet]]),
      .groups = "drop"
    )

  tibble::tibble(
    Facet = facet,
    Levels = nrow(by_level),
    Persons = nrow(by_person),
    MinPersonsPerLevel = min(by_level$PersonsPerLevel, na.rm = TRUE),
    MedianPersonsPerLevel = stats::median(by_level$PersonsPerLevel, na.rm = TRUE),
    MinLevelsPerPerson = min(by_person$LevelsPerPerson, na.rm = TRUE),
    MedianLevelsPerPerson = stats::median(by_person$LevelsPerPerson, na.rm = TRUE),
    LinkingPersons = sum(by_person$LevelsPerPerson > 1L),
    LinkingPersonRate = mean(by_person$LevelsPerPerson > 1L),
    SingleLevelPersons = sum(by_person$LevelsPerPerson == 1L),
    SparseLevels = sum(by_level$PersonsPerLevel < min_linking_persons),
    SparseLevelThreshold = min_linking_persons
  )
}

canonical_compare_interaction_terms <- function(x) {
  x <- as.character(x %||% character(0))
  if (length(x) == 0L) return(character(0))
  out <- vapply(strsplit(x, ":", fixed = TRUE), function(parts) {
    paste(sort(parts), collapse = ":")
  }, character(1))
  sort(unique(out))
}

normalize_compare_signature <- function(fit) {
  cfg <- fit$config %||% list()
  anchor_tables <- extract_anchor_tables(cfg)

  anchor_tbl <- as.data.frame(anchor_tables$anchors %||% data.frame(), stringsAsFactors = FALSE)
  if (nrow(anchor_tbl) > 0) {
    anchor_tbl <- anchor_tbl[, intersect(c("Facet", "Level", "Anchor"), names(anchor_tbl)), drop = FALSE]
    anchor_tbl <- anchor_tbl[do.call(order, c(anchor_tbl[intersect(c("Facet", "Level"), names(anchor_tbl))], na.last = TRUE)), , drop = FALSE]
  }

  group_tbl <- as.data.frame(anchor_tables$groups %||% data.frame(), stringsAsFactors = FALSE)
  if (nrow(group_tbl) > 0) {
    group_tbl <- group_tbl[, intersect(c("Facet", "Level", "Group", "GroupValue"), names(group_tbl)), drop = FALSE]
    group_tbl <- group_tbl[do.call(order, c(group_tbl[intersect(c("Facet", "Level", "Group"), names(group_tbl))], na.last = TRUE)), , drop = FALSE]
  }

  signature <- list(
    model = as.character(cfg$model %||% NA_character_),
    method = public_mfrm_method_label(cfg$method),
    person = as.character(cfg$person_col %||% NA_character_),
    facets = sort(as.character(cfg$facet_cols %||% fit$prep$facet_names %||% character(0))),
    score = as.character(cfg$score_col %||% NA_character_),
    rating_min = suppressWarnings(as.numeric(
      cfg$rating_min %||% fit$prep$rating_min %||% NA_real_
    )),
    rating_max = suppressWarnings(as.numeric(
      cfg$rating_max %||% fit$prep$rating_max %||% NA_real_
    )),
    score_map = cfg$score_map %||% fit$prep$score_map %||% NULL,
    weight = as.character(cfg$weight_col %||% NA_character_),
    step_facet = as.character(cfg$step_facet %||% NA_character_),
    slope_facet = as.character(cfg$slope_facet %||% NA_character_),
    facet_interactions = canonical_compare_interaction_terms(
      cfg$facet_interactions
    ),
    noncenter_facet = as.character(cfg$noncenter_facet %||% "Person"),
    centering_scope = cfg$centering_scope %||% "remainder",
    dummy_facets = sort(as.character(cfg$dummy_facets %||% character(0))),
    positive_facets = sort(as.character(cfg$positive_facets %||% character(0))),
    anchors = anchor_tbl,
    group_anchors = group_tbl
  )
  # Preserve saved legacy identities when the constraint equations are unchanged.
  if (nrow(anchor_tbl) + nrow(group_tbl) == 0L ||
      identical(signature$centering_scope, "remainder")) {
    signature$centering_scope <- NULL
  }
  signature
}

same_signature_component <- function(x, y) {
  if (is.data.frame(x) || is.data.frame(y)) {
    return(identical(
      as.data.frame(x %||% data.frame(), stringsAsFactors = FALSE),
      as.data.frame(y %||% data.frame(), stringsAsFactors = FALSE)
    ))
  }
  identical(x, y)
}

mfrm_population_design <- function(fit) {
    pop <- fit$config$population_spec %||% list()
    if (!isTRUE(pop$active)) return(list(active = FALSE))
    persons <- as.character(fit$prep$levels$Person %||% character(0))
    design <- pop$design_matrix
    columns <- pop$design_columns
    lookup <- pop$person_lookup
    if (!is.matrix(design) || !is.numeric(design) || ncol(design) == 0L ||
        length(persons) == 0L || anyNA(persons) || anyDuplicated(persons) ||
        !is.character(columns) || length(columns) != ncol(design) ||
        anyNA(columns) || anyDuplicated(columns) ||
        !is.numeric(lookup) || length(lookup) != length(persons) ||
        any(!is.finite(lookup)) || any(lookup != floor(lookup)) ||
        any(lookup < 1L | lookup > nrow(design))) return(NULL)
    design <- design[lookup[order(persons, method = "radix")],
                     order(columns, method = "radix"), drop = FALSE]
    if (any(!is.finite(design))) return(NULL)
    out <- list(active = TRUE, persons = sort(persons, method = "radix"),
         columns = sort(columns, method = "radix"),
         design = matrix(as.numeric(design), nrow = length(persons)))
    if (!is.null(pop$fixed_sd)) out$fixed_sd <- pop$fixed_sd
    out
}

audit_compare_mfrm_nesting <- function(fits, labels) {
  if (length(fits) != 2L) {
    return(list(
      eligible = FALSE,
      reason = "Likelihood-ratio tests are only reviewed for two-model comparisons.",
      simpler = NA_character_,
      complex = NA_character_,
      relation = "unsupported"
    ))
  }

  sigs <- lapply(fits, normalize_compare_signature)
  lbls <- as.character(labels)

  same_components <- c(
    person = same_signature_component(sigs[[1]]$person, sigs[[2]]$person),
    facets = same_signature_component(sigs[[1]]$facets, sigs[[2]]$facets),
    score = same_signature_component(sigs[[1]]$score, sigs[[2]]$score),
    rating_min = same_signature_component(sigs[[1]]$rating_min, sigs[[2]]$rating_min),
    rating_max = same_signature_component(sigs[[1]]$rating_max, sigs[[2]]$rating_max),
    score_map = same_signature_component(sigs[[1]]$score_map, sigs[[2]]$score_map),
    weight = same_signature_component(sigs[[1]]$weight, sigs[[2]]$weight),
    noncenter_facet = same_signature_component(sigs[[1]]$noncenter_facet, sigs[[2]]$noncenter_facet),
    centering_scope = same_signature_component(sigs[[1]]$centering_scope, sigs[[2]]$centering_scope),
    dummy_facets = same_signature_component(sigs[[1]]$dummy_facets, sigs[[2]]$dummy_facets),
    positive_facets = same_signature_component(sigs[[1]]$positive_facets, sigs[[2]]$positive_facets),
    anchors = same_signature_component(sigs[[1]]$anchors, sigs[[2]]$anchors),
    group_anchors = same_signature_component(sigs[[1]]$group_anchors, sigs[[2]]$group_anchors)
  )

  if (!all(same_components)) {
    mismatch <- names(same_components)[!same_components]
    return(list(
      eligible = FALSE,
      reason = paste0(
        "Models differ in structural comparison settings: ",
        paste(mismatch, collapse = ", "),
        "."
      ),
      simpler = NA_character_,
      complex = NA_character_,
      relation = "unsupported"
    ))
  }

  # For the supported response-model restrictions, require a shared population
  # model. Compare the declared design at the same Persons; coefficients and
  # variance are reestimated under each hypothesis.
  population_designs <- lapply(fits, mfrm_population_design)
  if (any(vapply(population_designs, is.null, logical(1))) ||
      !identical(population_designs[[1]], population_designs[[2]])) {
    return(list(
      eligible = FALSE,
      reason = paste(
        "A shared population model could not be verified.",
        "Automatic nesting requires the same fixed population or the same",
        "estimated-normal population design (declared columns and values",
        "aligned by Person). Changed or unavailable designs require separate review."
      ),
      simpler = NA_character_,
      complex = NA_character_,
      relation = "population_model_unverified"
    ))
  }

  model_pair <- toupper(c(sigs[[1]]$model, sigs[[2]]$model))
  interaction_sets <- lapply(sigs, function(sig) {
    sort(unique(as.character(sig$facet_interactions %||% character(0))))
  })
  if (identical(model_pair[1], model_pair[2])) {
    same_family_components <- c(
      step_facet = same_signature_component(sigs[[1]]$step_facet, sigs[[2]]$step_facet),
      slope_facet = same_signature_component(sigs[[1]]$slope_facet, sigs[[2]]$slope_facet)
    )
    if (!all(same_family_components)) {
      mismatch <- names(same_family_components)[!same_family_components]
      return(list(
        eligible = FALSE,
        reason = paste0(
          "Same-family fits differ in structural model settings: ",
          paste(mismatch, collapse = ", "),
          "."
        ),
        simpler = NA_character_,
        complex = NA_character_,
        relation = "same_model"
      ))
    }

    int_1 <- interaction_sets[[1]]
    int_2 <- interaction_sets[[2]]
    first_in_second <- all(int_1 %in% int_2)
    second_in_first <- all(int_2 %in% int_1)
    if (length(int_1) < length(int_2) && first_in_second) {
      added <- setdiff(int_2, int_1)
      return(list(
        eligible = TRUE,
        reason = paste0(
          "Supported nesting review passed: shared model family and constraints; ",
          "the complex fit adds fixed facet interaction term(s): ",
          paste(added, collapse = ", "),
          "."
        ),
        simpler = lbls[1],
        complex = lbls[2],
        relation = "facet_interaction_extension"
      ))
    }
    if (length(int_2) < length(int_1) && second_in_first) {
      added <- setdiff(int_1, int_2)
      return(list(
        eligible = TRUE,
        reason = paste0(
          "Supported nesting review passed: shared model family and constraints; ",
          "the complex fit adds fixed facet interaction term(s): ",
          paste(added, collapse = ", "),
          "."
        ),
        simpler = lbls[2],
        complex = lbls[1],
        relation = "facet_interaction_extension"
      ))
    }
    if (!identical(int_1, int_2)) {
      return(list(
        eligible = FALSE,
        reason = "Both fits use the same model family, but their fixed facet-interaction sets are not nested.",
        simpler = NA_character_,
        complex = NA_character_,
        relation = "same_model"
      ))
    }

    return(list(
      eligible = FALSE,
      reason = "Both fits use the same model family, so there is no supported nested restriction to test.",
      simpler = lbls[1],
      complex = lbls[2],
      relation = "same_model"
    ))
  }

  if (setequal(model_pair, c("RSM", "PCM"))) {
    idx_simple <- which(model_pair == "RSM")[1]
    idx_complex <- which(model_pair == "PCM")[1]
    step_facet <- sigs[[idx_complex]]$step_facet
    missing_interactions <- setdiff(interaction_sets[[idx_simple]], interaction_sets[[idx_complex]])
    if (length(missing_interactions)) {
      return(list(
        eligible = FALSE,
        reason = paste0("RSM interaction terms are absent from the PCM: ",
          paste(missing_interactions, collapse = ", "),
          ". Freeing category steps does not preserve these interaction effects."),
        simpler = NA_character_, complex = NA_character_,
        relation = "RSM_PCM_interactions_not_nested"
      ))
    }
    if (!is.na(step_facet) && nzchar(step_facet)) {
      return(list(
        eligible = TRUE,
        reason = paste0(
          "Supported nesting review passed: shared design/constraints with RSM nested inside PCM on step facet '",
          step_facet,
          "'."
        ),
        simpler = lbls[idx_simple],
        complex = lbls[idx_complex],
        relation = "RSM_in_PCM"
      ))
    }
  }

  if (setequal(model_pair, c("PCM", "GPCM"))) {
    idx_pcm <- which(model_pair == "PCM")[1]
    idx_gpcm <- which(model_pair == "GPCM")[1]
    pcm_step <- sigs[[idx_pcm]]$step_facet
    gpcm_step <- sigs[[idx_gpcm]]$step_facet
    gpcm_slope <- sigs[[idx_gpcm]]$slope_facet
    aligned_owner <- !is.na(pcm_step) && nzchar(pcm_step) &&
      identical(pcm_step, gpcm_step) && !is.na(gpcm_slope) && nzchar(gpcm_slope)
    review <- list(
      eligible = FALSE,
      reason = paste(
        "PCM and GPCM must share an explicit step owner and GPCM must name its slope owner,",
        "so even the unit-slope response-kernel reduction is not established."
      ),
      simpler = if (aligned_owner) lbls[idx_pcm] else NA_character_,
      complex = if (aligned_owner) lbls[idx_gpcm] else NA_character_,
      relation = "PCM_GPCM_owner_mismatch"
    )
    if (!aligned_owner) return(review)
    review$relation <- "PCM_GPCM_restriction_unverified"
    pcm <- fits[[idx_pcm]]$config
    gpcm <- fits[[idx_gpcm]]$config
    if (!identical(pcm$method, "MML") || !identical(gpcm$method, "MML")) {
      review$reason <- "The PCM/GPCM chi-square approximation requires MML fits; JML is not supported."
      return(review)
    }
    # Only slopes may differ: equal parameter counts alone cannot establish
    # matching step anchors, interactions or facet constraints.
    shared <- c("facet_names", "facet_levels", "facet_signs", "facet_specs", "step_specs")
    if (!identical(interaction_sets[[1]], interaction_sets[[2]]) ||
        !all(vapply(shared, function(nm) {
          !is.null(pcm[[nm]]) && identical(pcm[[nm]], gpcm[[nm]])
        }, logical(1))) ||
        !identical(pcm$interaction_specs, gpcm$interaction_specs)) {
      review$reason <- "PCM/GPCM testing requires identical facet constraints, step constraints and fixed interactions."
      return(review)
    }
    spec <- gpcm$gpcm_spec
    levels <- gpcm$facet_levels[[gpcm_slope]]
    sizes <- tryCatch(lapply(list(pcm, gpcm), build_param_sizes), error = function(e) NULL)
    restrictions <- length(levels) - 1L
    if (is.null(sizes) || restrictions < 1L ||
        !isTRUE(spec$active) || !identical(spec$levels, levels) ||
        !identical(spec$slope_facet, gpcm_slope) || !identical(spec$step_facet, gpcm_step) ||
        !identical(spec$identification, "sum_to_zero_log_slopes") ||
        !identical(spec$scale_reference, "geometric_mean_one") ||
        !identical(as.integer(sizes[[2]][["log_slopes"]]), restrictions) ||
        !identical(sizes[[1]], sizes[[2]][names(sizes[[2]]) != "log_slopes"])) {
      review$reason <- "The G-1 free relative-slope restrictions and otherwise identical free-parameter blocks could not be verified."
      return(review)
    }
    review$eligible <- TRUE
    review$relation <- "PCM_in_GPCM"
    review$df <- restrictions
    review$reason <- paste0(
      "PCM is the unit-slope response-kernel reduction on facet '", pcm_step,
      "' with slopes on facet '", gpcm_slope, "', a shared population model and ", restrictions,
      " independent log-slope restrictions. Unit slopes are interior; the",
      " reference is an ordinary asymptotic chi-square distribution. Numerical",
      " solution and likelihood-comparison checks are required separately."
    )
    return(review)
  }

  list(
    eligible = FALSE,
    reason = paste0(
      "Automatic nesting review supports RSM nested inside PCM, aligned PCM inside GPCM, ",
      "or same-family fixed facet-interaction extensions under shared design ",
      "and constraints."
    ),
    simpler = NA_character_,
    complex = NA_character_,
    relation = "unsupported"
  )
}

resolve_mfrm_category_policy <- function(keep_original, category_policy,
                                         keep_original_supplied) {
  if (!is.logical(keep_original) || length(keep_original) != 1L || is.na(keep_original)) {
    stop("`keep_original` must be a single logical value (TRUE or FALSE).", call. = FALSE)
  }
  if (is.null(category_policy)) return(keep_original)
  if (!is.character(category_policy) || length(category_policy) != 1L || is.na(category_policy)) {
    stop("`category_policy` must be NULL, 'collapse' or 'preserve'.", call. = FALSE)
  }
  category_policy <- match.arg(category_policy, c("collapse", "preserve"))
  preserve <- identical(category_policy, "preserve")
  if (keep_original_supplied && keep_original != preserve) {
    stop("`category_policy` and `keep_original` conflict; supply one choice or matching values.",
         call. = FALSE)
  }
  preserve
}

#' Check rating data before fitting an MFRM
#'
#' Inspect how many rating rows can be used, how often each score category
#' occurs, and whether facet levels connect through shared persons. This
#' function prepares descriptive checks; it does not fit a model or change
#' the data object supplied by the caller. Each row should represent one
#' rating, and `person`, `facets`, and `score` name its columns.
#'
#' @param data A data.frame in long format (one row per rating event).
#'   Grouped or rowwise tibbles are treated as one table; only the selected
#'   model columns enter row filtering and the design review.
#' @param person Column name for person IDs.
#' @param facets Character vector of facet column names. The reserved data
#'   and parameter names listed in [fit_mfrm()] cannot name facets; rename
#'   such columns before analysis.
#' @param score Column name for observed score. The category-code and
#'   near-integer normalization rules are the same as in [fit_mfrm()].
#' @param weight Optional weight/frequency column name, with the numeric
#'   precision and finite-sum rules of [fit_mfrm()].
#' @param rating_min Optional minimum category value. Supply with
#'   `rating_max` to retain unused boundary categories in the intended score
#'   support.
#' @param rating_max Optional maximum category value. Supply with
#'   `rating_min` to retain unused boundary categories in the intended score
#'   support.
#' @param keep_original Keep original category values. Use this with
#'   `rating_min` / `rating_max` when the intended scale has unused
#'   intermediate categories such as `1, 2, 4, 5` on a 1-5 scale.
#'   New code can instead use `category_policy = "preserve"`.
#' @param category_policy Optional explicit category choice: `"collapse"`
#'   maps gaps in observed categories to consecutive scores; `"preserve"`
#'   keeps the declared ladder (`rating_min` to `rating_max`). `NULL` uses
#'   `keep_original`.
#' @param repeated_ratings Treatment of repeated Person-by-facet cells:
#'   `"review"` (default) or `"independent"`.
#' @param missing_codes Optional. `NULL` (default) is a no-op;
#'   `TRUE` or `"default"` activates the FACETS / SPSS / SAS
#'   convention (`c("99", "999", "-1", "N", "NA", "n/a", ".", "")`)
#'   for the score column while preserving person/facet identifiers;
#'   supply a character vector to apply a custom code set across all model
#'   columns. Replacement
#'   counts are returned in the `missing_recoding` component when
#'   supported by the calling helper. See [recode_missing_codes()]
#'   for the standalone version.
#' @param include_person_facet If `TRUE`, include person-level rows in
#'   `facet_level_summary`.
#' @param include_agreement If `TRUE`, include an observed-score agreement
#'   bundle (summary/pairs/settings) for a selected non-person facet.
#' @param rater_facet Optional facet name used to identify repeated scorers for
#'   agreement summaries. If `NULL`, a rater-like name such as `Rater`, `Judge`,
#'   or `Scorer` is inferred. No agreement analysis is run when such a name is
#'   absent; set this argument explicitly only when another facet genuinely
#'   represents repeated scorers.
#' @param context_facets Optional facets used to define matched contexts for
#'   agreement. If `NULL`, all remaining facets (including `Person`) are used.
#' @param agreement_top_n Optional maximum number of agreement pair rows.
#' @param expected_design Optional data frame declaring the planned assignment
#'   roster. It must contain the columns named by `person` and `facets`, with
#'   one row per planned Person x facet cell. Extra columns are ignored. When
#'   supplied, observed cells are compared with the roster so planned omissions
#'   can be distinguished from cells that were never assigned.
#' @param min_linking_persons Positive integer used as a descriptive sparse-link
#'   flag. A facet level observed for fewer than this many distinct persons is
#'   counted in `linkage_summary$SparseLevels`. This is a review threshold, not
#'   a model-acceptance rule.
#' @param comparisons Optional named specification for a prospective
#'   facet-by-origin interaction review. See "Comparison-specific review".
#'   Default `NULL` performs no model/target review or fitting.
#' @param spec Optional named `list` of shared model-specification settings
#'   (the same 33-key `spec` accepted by [fit_mfrm()],
#'   [review_mfrm_anchors()], and [export_mfrm_model()]). Data-description
#'   keys in `spec` (`person`, `facets`, `score`, `weight`, `rating_min`,
#'   `rating_max`, `category_policy`, `keep_original`, `missing_codes`,
#'   `repeated_ratings`) are applied unless overridden by explicit top-level
#'   arguments; model-only keys in `spec` (such as `model` or `step_facet`)
#'   are validated and permitted so one `spec` can be reused unchanged.
#'
#' @section Comparison-specific review:
#' Use `comparisons = list(facet = ..., group = ..., groups = c("A", "B"),
#' contrasts = W, model = "RSM", method = "JML")` to review explicitly
#' declared interaction comparisons before estimation. Both `facet` and
#' `group` must occur in `facets`; each Person/recording must keep one origin
#' group. `groups` gives the subtraction order, including when additional
#' neutral origins are present. Unit weights and preserved categories are
#' required. `W` is a numeric matrix with unique comparison row names and
#' every reviewed facet level as a named column, including zero weights.
#' Each nonzero row must sum to zero. For four raters, weights
#' `c(.75, -.25, -.25, -.25)` compare the first rater's A-minus-B
#' interaction with the equal-weight panel; `c(1, -1, 0, 0)` compares the
#' first two raters' A-minus-B interactions. These are different targets.
#'
#' The prospective model has centered measurement facets, a zero-valued
#' group main facet, and the named facet-by-group interaction with zero
#' marginal sums. JML has free Person locations. Choose `model = "PCM"`
#' with an explicit `step_facet` for facet-owned steps. Optional
#' `positive_facets` records the location orientation. Anchors, extra
#' interactions and nonunit weights are outside this review. GPCM interaction
#' requests return `unsupported`, not an additive-model substitute.
#'
#' `method = "MML"` uses a fixed common standard-normal population unless
#' `population_formula` is supplied (an intercept or the origin group only).
#' `ConditionalState` refers to the linear response map; `FreePersonState`
#' reviews the same response structure with unrestricted Persons. A same-law
#' alias remains unidentified after mixing. A positive conditional rank alone
#' does not certify the marginal model: those MML rows have
#' `State = "not_evaluated"`. No fit or numerical marginal-rank calculation
#' is performed. JML rows distinguish `all_parameters_identified`,
#' `target_identified_only`, and `target_unidentified`. Numerically sensitive
#' or oversized dense maps remain `not_evaluated`.
#'
#' `IdentificationBasis` interprets these checks for each requested target:
#' `free_person_response_model` means the declared response map identifies
#' it even with unrestricted Person locations. `population_restriction` means
#' an unrestricted-Person alias is removed only after imposing the declared
#' population restrictions in the conditional map. This does **not** certify
#' marginal identification, and the corresponding MML `State` stays
#' `not_evaluated`. `conditional_support` identifies a CML target from response
#' patterns at the observed totals. `unidentified`, `not_evaluated` and
#' `unsupported` remain separate. `IdentificationDetail` explains the scope;
#' `Basis` retains the broader estimator/model basis.
#'
#' A fixed common N(0,1) population or estimated common normal population
#' (`~1`) restricts origin groups to the same ability distribution. This is
#' substantive, not arbitrary scale coding. Origin regression relaxes only
#' the means allowed by its design and retains a common residual SD. Interpret
#' the zero origin main effect jointly with those restrictions. A contrast
#' identified in a free-Person response map does not make its MML estimator
#' distribution-free. All conclusions still depend on the declared response
#' model, including equal slopes and shared/facet-owned step restrictions.
#'
#' `method = "CML"` instead reviews conditional support at the actual Person
#' totals and rating rosters. A dynamic program spans differences between all
#' possible patterns at those totals, so extreme scores and unavailable category
#' combinations do not manufacture information. `State` and `ConditionalState`
#' distinguish full identification, target-only identification and unidentified
#' targets; `FreePersonState` is the separate unrestricted-Person response-map
#' review. Person-constant main effects disappear, and no population distribution
#' or SD is estimated. Population formulas are not accepted for CML.
#'
#' Read `$comparison_review$table`, `$weights`, `$cells` and `$notes` together.
#' The table preserves group direction, model, step owner and counts; counts
#' cover nonzero-weight facet levels, while `cells` includes empty cells.
#' `$fit_arguments` records the prospective structural settings; use matching
#' input preparation when fitting. An identified target does not permit fitting
#' a rejected full parameterization. `Estimate` stays missing and formal
#' inference is unavailable. Save the review with its retained response rows.
#' Pass it as `comparison_review` to [analyze_dff()] to preserve this separate
#' prospective question alongside residual/refit effects; it does not certify
#' those different effects. See [online linking and DFF guide](https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-linking-and-dff.html) for a
#' school-assignment example and [mfrmr_linking_and_dff] for interpretation.
#' A matching, fully supported joint fit can return descriptive contrasts via
#' [interaction_effect_table()] or `summary(fit, comparison_review = review)`.
#' These explicit calls add retained-point numerical checks, not partial
#' estimation or formal uncertainty. To fit selected CML contrasts and obtain
#' conditional-information Wald intervals, use `fit_mfrm(fit_scope = "comparisons",
#' comparison_review = review)` with the CML review's `$fit_arguments`; see
#' the comparison-only section of [fit_mfrm()].
#'
#' @details
#' Set `rating_min` and `rating_max` from the rubric, including categories
#' nobody received. Use `keep_original = TRUE` to preserve its category
#' structure in the review. Numeric descriptives of score and weight use
#' `psych::describe()`.
#'
#' **Key data-quality checks to perform before fitting:**
#' - *Sparse categories*: review categories with little weighted support because
#'   their threshold estimates may be imprecise. Do not collapse categories
#'   solely from a package warning; also consider the rubric, intended score
#'   interpretation, and category diagnostics after fitting.
#' - *Unlinked elements*: inspect `design_connectivity` for the observed
#'   Person-facet graph. More than one component means that the levels of that
#'   facet are not connected through shared persons. This facet-specific check
#'   is conservative and does not by itself prove full model identification.
#' - *Extreme scores*: MML uses a person distribution to obtain posterior
#'   person scores, including for persons with all-minimum or all-maximum
#'   scores. Non-person facets remain fixed effects: an extreme rater or
#'   criterion is not given a prior or automatically shrunk by choosing MML.
#'   Review the fitted boundary and precision evidence before interpretation.
#'
#' @section Interpreting output:
#' Recommended order:
#' - `overview`: confirms retained ratings (`Observations`), persons, facets,
#'   and category span. Use `row_retention` to compare input and retained
#'   `Rows`; `DroppedRows` counts exclusions during preparation.
#' - `missing_by_column`: counts `NA` values in the input columns. A missing
#'   score or required identifier excludes that rating row, not automatically
#'   the person's other ratings. The package does not fill missing ratings.
#'   When `missing_codes` is supplied, these counts still describe the original
#'   input; inspect `missing_recoding` and `preparation_notes` as well.
#' - `structural_missingness`: compares observed rating cells with
#'   `expected_design`, when supplied. Without a declared roster, structural
#'   missingness is reported as not assessed rather than assumed to be zero.
#' - `score_distribution`: checks sparse/unused score categories.
#'   Skew can be substantively expected, but weakly supported or unused
#'   categories need explicit interpretation.
#' - `facet_level_summary` and `linkage_summary`: checks per-level support,
#'   shared-person counts, and sparse levels. Use `design_connectivity` for the
#'   separate graph-component result.
#' - `agreement`: optional observed agreement summary for the selected scorer
#'   facet (exact agreement, correlation, and mean differences per pair).
#'
#' `data_review <- describe_mfrm_data(...)` saves all these checks.
#' `review <- summary(data_review)` provides a compact view; its missingness
#' table is named `review$missing`, while the original full table is
#' `data_review$missing_by_column`. Summary previews use `top_n = 10` by
#' default. Use the original tables to inspect all rows or categories.
#'
#' @section If the input needs attention:
#' - **Column name not found:** run `names(ratings)` and match spelling,
#'   spaces, and case in `person`, `facets`, and `score`.
#' - **Unexpected row loss:** inspect `row_retention`, `missing_by_column`,
#'   and `preparation_notes`. Resolve unintended missing IDs and invalid score
#'   text in the input data. For documented score markers such as `99` or `.`,
#'   use [recode_missing_codes()] with explicit `columns` and `codes`.
#' - **Repeated person-by-facet cells:** inspect `duplicate_cell_detail`.
#'   Correct accidental duplicates; declare `repeated_ratings = "independent"`
#'   for distinct conditionally independent events, or model dependence.
#'   Include a task or occasion facet when
#'   ratings represent distinct events in the design.
#' - **Unused category or disconnected design:** inspect
#'   `score_distribution` and `design_connectivity`. Review the rubric and
#'   assignments before changing the model. A retained internal zero-count
#'   category stops fitting; extra optimizer iterations cannot supply the
#'   missing category information.
#'
#' After editing or recoding ratings, rerun this review on the corrected data
#' and pass that same data to [fit_mfrm()], using the same columns, score
#' bounds, and `keep_original` setting. If you use `missing_codes` within the
#' review instead of recoding first, supply the same option to the fit:
#' reviewing does not modify the original data. For CSV import, column mapping,
#' and a complete worked example, see
#' `vignette("mfrmr-workflow", package = "mfrmr")`.
#'
#' @section Typical workflow:
#' 1. Run `data_review <- describe_mfrm_data(...)` on the rating data.
#' 2. Inspect row retention, category counts, and design connectivity.
#' 3. Correct input issues, repeat the review, and fit the reviewed data with
#'    [fit_mfrm()].
#'
#' @return A list of class `mfrm_data_description` with:
#' - `overview`: one-row run-level summary
#'   including `CategoryPolicy` and `ScoreRecoded`. The former records the
#'   selected category handling; the latter indicates whether original score
#'   values actually changed. A `"collapse"` policy can leave a contiguous
#'   scale unchanged. Inspect `score_support$score_map` for the mapping.
#' - `missing_by_column`: missing counts in selected input columns
#' - `missing_rate_summary`: per-column missingness rate summary
#'   (one row per input column, with raw and proportion-of-N columns)
#' - `score_descriptives`: output from [psych::describe()] for score
#' - `weight_descriptives`: output from [psych::describe()] for weight
#' - `score_distribution`: weighted and raw score frequencies over the prepared
#'   score support. Unused boundary categories are retained when the rating
#'   range was supplied explicitly; unused intermediate categories require
#'   `keep_original = TRUE`.
#' - `facet_level_summary`: per-level usage and score summaries
#' - `facet_crosstabs`: pairwise observation-count crosstabs between
#'   non-person facets (named list keyed `"facetA__facetB"`) for optional
#'   downstream coverage displays
#' - `linkage_summary`: person-facet connectivity diagnostics
#' - `structural_missingness`: declared-design comparison bundle containing a
#'   one-row summary, missing expected cells, unexpected observed cells,
#'   per-facet level coverage, and settings
#' - `design_connectivity`: component counts for each observed Person-facet
#'   graph and, when declared, each expected Person-facet graph
#' - `design_components`: component-level counts and facet-level labels;
#'   person labels are included only when `include_person_facet = TRUE`
#' - `duplicate_cell_summary`: counts of duplicate Person x facet cells
#' - `duplicate_cell_detail`: duplicate-cell keys and row counts
#' - `agreement`: observed-score agreement bundle for the selected scorer facet
#' - `row_retention`: row counts before and after preparation filters
#' - `preparation_notes`: structured notes for row drops, ID trimming, and
#'   design conditions detected during preparation
#' - `missing_recoding`: per-column counts of declared missing-code values
#'   replaced with `NA` before row filtering
#' - `score_support`: minimal prepared score-support metadata used by
#'   `summary(ds)$caveats`
#' - `comparison_review`: optional prospective interaction review, including
#'   all requested rows and their explicit weights; also retained by `summary()`.
#'
#' @seealso [fit_mfrm()], [summary.mfrm_data_description()],
#'   [recode_missing_codes()], [mfrmr_workflow_methods], [review_mfrm_anchors()]
#' @examples
#' library(mfrmr)
#' ratings <- load_mfrmr_data("example_operational")
#' head(ratings)
#'
#' # Check the data before fitting; the intended score categories are 1 to 4
#' data_review <- describe_mfrm_data(
#'   data = ratings,
#'   person = "Person",
#'   facets = c("Rater", "Criterion"),
#'   score = "Score",
#'   rating_min = 1,
#'   rating_max = 4,
#'   category_policy = "preserve"
#' )
#' data_review$row_retention       # Input and retained rows; check DroppedRows
#' data_review$missing_by_column   # Missing input values in each model column
#' data_review$score_distribution  # RawN is the number of ratings per category
#' data_review$design_connectivity # Components = 1 means connected for that facet
#' # Here all 282 rows are retained, and all four categories have observations
#'
#' # Save a compact summary when you want the overview and review notes
#' review <- summary(data_review)
#' review$overview
#' review$notes
#' # For the next fit, use data = ratings; data_review is a set of checks, not ratings
#' @export
#' @order 1
describe_mfrm_data <- function(data,
                               person = NULL,
                               facets = NULL,
                               score = NULL,
                               weight = NULL,
                               rating_min = NULL,
                               rating_max = NULL,
                               keep_original = FALSE,
                               missing_codes = NULL,
                               include_person_facet = FALSE,
                               include_agreement = TRUE,
                               rater_facet = NULL,
                               context_facets = NULL,
                               agreement_top_n = NULL,
                               expected_design = NULL,
                               min_linking_persons = 2L,
                               category_policy = NULL,
                               repeated_ratings = c("review", "independent"),
                               comparisons = NULL,
                               spec = NULL) {
  mc <- match.call(expand.dots = FALSE)
  formal_supplied <- setdiff(names(as.list(mc)[-1L]), "spec")
  spec_list <- .mfrm_validate_spec_list(spec, "describe_mfrm_data()")
  desc_spec_keys <- c(
    "person", "facets", "score", "weight",
    "rating_min", "rating_max", "keep_original",
    "missing_codes", "category_policy", "repeated_ratings"
  )
  for (nm in intersect(names(spec_list), desc_spec_keys)) {
    if (!nm %in% formal_supplied) {
      assign(nm, spec_list[[nm]], envir = environment())
    }
  }
  if ("keep_original" %in% formal_supplied && !"category_policy" %in% formal_supplied) {
    category_policy <- NULL
  }
  keep_original_supplied <- ("keep_original" %in% formal_supplied) ||
    ("keep_original" %in% names(spec_list) && !"category_policy" %in% formal_supplied)
  if (!is.character(person) || length(person) != 1L || is.na(person) || !nzchar(person)) {
    stop("`person` must be a single non-empty character string naming the person column.",
         call. = FALSE)
  }
  if (!is.character(facets) || length(facets) == 0L || anyNA(facets) || any(!nzchar(facets))) {
    stop("`facets` must be a character vector of one or more facet column names.",
         call. = FALSE)
  }
  if (!is.character(score) || length(score) != 1L || is.na(score) || !nzchar(score)) {
    stop("`score` must be a single non-empty character string naming the score column.",
         call. = FALSE)
  }
  repeated_ratings <- match.arg(repeated_ratings, c("review", "independent"))
  keep_original <- resolve_mfrm_category_policy(
    keep_original, category_policy, keep_original_supplied)
  if (!is.numeric(min_linking_persons) || length(min_linking_persons) != 1L ||
      !is.finite(min_linking_persons) || min_linking_persons < 1L ||
      abs(min_linking_persons - round(min_linking_persons)) > 1e-8) {
    stop("`min_linking_persons` must be a positive integer.", call. = FALSE)
  }
  min_linking_persons <- as.integer(round(min_linking_persons))
  expected_design_normalized <- normalize_expected_mfrm_design(
    expected_design = expected_design,
    person = person,
    facets = facets
  )
  prep <- prepare_mfrm_data(
    data = data,
    person_col = person,
    facet_cols = facets,
    score_col = score,
    rating_min = rating_min,
    rating_max = rating_max,
    weight_col = weight,
    keep_original = keep_original,
    missing_codes = missing_codes,
    repeated_ratings = repeated_ratings,
    allow_single_person = TRUE
  )

  df <- prep$data |>
    dplyr::mutate(
      Person = as.character(.data$Person),
      dplyr::across(dplyr::all_of(prep$facet_names), as.character)
    )
  selected_cols <- unique(c(person, facets, score, if (!is.null(weight)) weight))
  missing_by_column <- tibble::tibble(
    Column = selected_cols,
    Missing = vapply(selected_cols, function(col) sum(is.na(data[[col]])), integer(1))
  )

  score_desc <- psych::describe(df$Score, fast = TRUE)
  weight_desc <- psych::describe(df$Weight, fast = TRUE)

  total_weight <- sum(df$Weight, na.rm = TRUE)
  observed_score_distribution <- df |>
    dplyr::group_by(.data$Score) |>
    dplyr::summarize(
      RawN = dplyr::n(),
      WeightedN = sum(.data$Weight, na.rm = TRUE),
      Percent = ifelse(total_weight > 0, 100 * .data$WeightedN / total_weight, NA_real_),
      .groups = "drop"
    ) |>
    dplyr::arrange(.data$Score)
  score_distribution <- tibble::tibble(Score = seq(prep$rating_min, prep$rating_max)) |>
    dplyr::left_join(observed_score_distribution, by = "Score") |>
    dplyr::mutate(
      RawN = tidyr::replace_na(.data$RawN, 0L),
      WeightedN = tidyr::replace_na(.data$WeightedN, 0),
      Percent = tidyr::replace_na(.data$Percent, 0)
    )

  report_facets <- prep$facet_names
  if (isTRUE(include_person_facet)) {
    report_facets <- c("Person", report_facets)
  }

  facet_level_summary <- purrr::map_dfr(report_facets, function(facet) {
    df |>
      dplyr::group_by(.data[[facet]]) |>
      dplyr::summarize(
        RawN = dplyr::n(),
        WeightedN = sum(.data$Weight, na.rm = TRUE),
        MeanScore = weighted_mean(.data$Score, .data$Weight),
        SDScore = stats::sd(.data$Score, na.rm = TRUE),
        MinScore = min(.data$Score, na.rm = TRUE),
        MaxScore = max(.data$Score, na.rm = TRUE),
        .groups = "drop"
      ) |>
      dplyr::rename(Level = dplyr::all_of(facet)) |>
      dplyr::mutate(
        Facet = facet,
        Level = as.character(.data$Level),
        .before = 1
      )
  })

  linkage_summary <- if (length(prep$facet_names) == 0) {
    tibble::tibble()
  } else {
    purrr::map_dfr(prep$facet_names, function(facet) {
      summarize_linkage_by_facet(
        df,
        facet,
        min_linking_persons = min_linking_persons
      )
    })
  }
  structural_missingness <- audit_mfrm_expected_design(
    df = df,
    expected_design = expected_design_normalized,
    facets = prep$facet_names
  )
  connectivity <- audit_mfrm_connectivity(
    df = df,
    expected_design = expected_design_normalized,
    facets = prep$facet_names,
    include_persons = include_person_facet
  )
  duplicate_cells <- summarize_duplicate_mfrm_cells(df, prep$facet_names)

  agreement_bundle <- list(
    summary = data.frame(),
    pairs = data.frame(),
    settings = list(
      included = FALSE,
      status = if (isTRUE(include_agreement)) "not_computed" else "not_requested",
      rater_facet = NA_character_,
      context_facets = character(0),
      expected_exact_from_model = FALSE,
      top_n = if (is.null(agreement_top_n)) NA_integer_ else max(1L, as.integer(agreement_top_n)),
      note = if (isTRUE(include_agreement)) {
        "No rater-like facet was detected. Set `rater_facet` explicitly to request facet-agreement summaries."
      } else {
        "Agreement summaries were not requested."
      }
    )
  )

  if (isTRUE(include_agreement) && length(prep$facet_names) > 0) {
    known_facets <- c("Person", prep$facet_names)
    if (is.null(rater_facet) || !nzchar(as.character(rater_facet[1]))) {
      rater_facet <- infer_default_rater_facet(
        prep$facet_names,
        fallback_first = FALSE
      )
    } else {
      rater_facet <- as.character(rater_facet[1])
    }
    if (is.null(rater_facet)) {
      rater_facet <- NULL
    } else if (!rater_facet %in% known_facets) {
      stop("`rater_facet` must match one of: ", paste(known_facets, collapse = ", "))
    }
    if (!is.null(rater_facet) && identical(rater_facet, "Person")) {
      stop("`rater_facet = 'Person'` is not supported. Use a non-person facet.")
    }

    if (!is.null(rater_facet) && is.null(context_facets)) {
      facet_cols <- known_facets
      resolved_context <- setdiff(facet_cols, rater_facet)
    } else if (!is.null(rater_facet)) {
      context_facets <- unique(as.character(context_facets))
      unknown <- setdiff(context_facets, known_facets)
      if (length(unknown) > 0) {
        stop("Unknown `context_facets`: ", paste(unknown, collapse = ", "))
      }
      resolved_context <- setdiff(context_facets, rater_facet)
      if (length(resolved_context) == 0) {
        stop("`context_facets` must include at least one facet different from `rater_facet`.")
      }
      facet_cols <- c(rater_facet, resolved_context)
    }

    if (!is.null(rater_facet)) {
      obs_agreement <- df |>
      dplyr::select(dplyr::all_of(unique(c("Person", prep$facet_names, "Score", "Weight")))) |>
      dplyr::rename(Observed = "Score")

      agreement <- calc_interrater_agreement(
        obs_df = obs_agreement,
        facet_cols = facet_cols,
        rater_facet = rater_facet,
        res = NULL
      )
      agreement_pairs <- as.data.frame(agreement$pairs, stringsAsFactors = FALSE)
      if (!is.null(agreement_top_n) && nrow(agreement_pairs) > 0) {
        agreement_pairs <- agreement_pairs |>
          dplyr::slice_head(n = max(1L, as.integer(agreement_top_n)))
      }

      agreement_bundle <- list(
        summary = as.data.frame(agreement$summary, stringsAsFactors = FALSE),
        pairs = agreement_pairs,
        settings = list(
          included = TRUE,
          status = "computed",
          rater_facet = rater_facet,
          context_facets = resolved_context,
          expected_exact_from_model = FALSE,
          top_n = if (is.null(agreement_top_n)) NA_integer_ else max(1L, as.integer(agreement_top_n)),
          note = "Observed-score agreement was computed for the selected scorer facet."
        )
      )
    }
  }

  overview <- tibble::tibble(
    Observations = nrow(df),
    TotalWeight = total_weight,
    Persons = length(prep$levels$Person),
    Facets = length(prep$facet_names),
    Categories = prep$rating_max - prep$rating_min + 1,
    RatingMin = prep$rating_min,
    RatingMax = prep$rating_max,
    RatingRangeSource = prep$rating_range_source %||% "unknown",
    RatingMinSource = prep$rating_min_source %||% "unknown",
    RatingMaxSource = prep$rating_max_source %||% "unknown",
    !!!mfrm_category_settings(prep)
  )

  # Cross-tabulations between facet pairs give the
  # raw per-cell observation count for each pair of facets, which is
  # a heatmap-ready structure for downstream dashboards.
  facet_crosstabs <- list()
  if (length(prep$facet_names) >= 2L) {
    for (i in seq_len(length(prep$facet_names) - 1L)) {
      for (j in seq(i + 1L, length(prep$facet_names))) {
        a <- prep$facet_names[i]; b <- prep$facet_names[j]
        ctab <- df |>
          dplyr::count(
            LevelA = as.character(.data[[a]]),
            LevelB = as.character(.data[[b]]),
            name = "N"
          ) |>
          dplyr::mutate(FacetA = a, FacetB = b)
        facet_crosstabs[[paste(a, b, sep = "__")]] <-
          as.data.frame(ctab, stringsAsFactors = FALSE)
      }
    }
  }

  # Missing-rate summary at both column and facet-cell level.
  n_total <- nrow(data)
  missing_rate_summary <- data.frame(
    Column = missing_by_column$Column,
    Missing = as.integer(missing_by_column$Missing),
    NonMissing = n_total - as.integer(missing_by_column$Missing),
    MissingRate = ifelse(
      rep(n_total > 0, nrow(missing_by_column)),
      missing_by_column$Missing / n_total,
      NA_real_
    ),
    stringsAsFactors = FALSE
  )

  out <- list(
    overview = overview,
    comparison_review = mfrmr_build_comparison_review(prep, comparisons),
    missing_by_column = missing_by_column,
    missing_rate_summary = missing_rate_summary,
    score_descriptives = score_desc,
    weight_descriptives = weight_desc,
    score_distribution = score_distribution,
    facet_level_summary = facet_level_summary,
    facet_crosstabs = facet_crosstabs,
    linkage_summary = linkage_summary,
    structural_missingness = structural_missingness,
    design_connectivity = as.data.frame(connectivity$summary, stringsAsFactors = FALSE),
    design_components = as.data.frame(connectivity$components, stringsAsFactors = FALSE),
    repeated_ratings = prep$repeated_ratings,
    duplicate_cell_summary = duplicate_cells$summary,
    duplicate_cell_detail = duplicate_cells$detail,
    agreement = agreement_bundle,
    row_retention = as.data.frame(prep$row_retention %||% data.frame(), stringsAsFactors = FALSE),
    preparation_notes = as.data.frame(prep$preparation_notes %||% data.frame(), stringsAsFactors = FALSE),
    missing_recoding = if (is.data.frame(prep$missing_recoding)) {
      as.data.frame(prep$missing_recoding, stringsAsFactors = FALSE)
    } else {
      prep$missing_recoding
    },
    score_support = list(
      keep_original = prep$keep_original,
      data = data.frame(Score = sort(unique(df$Score))),
      rating_min = prep$rating_min,
      rating_max = prep$rating_max,
      rating_range_source = prep$rating_range_source %||% "unknown",
      rating_min_source = prep$rating_min_source %||% "unknown",
      rating_max_source = prep$rating_max_source %||% "unknown",
      unused_score_categories = prep$unused_score_categories,
      score_map = prep$score_map
    )
  )
  class(out) <- c("mfrm_data_description", class(out))
  out
}

#' Recode common missing-value sentinels to `NA`
#'
#' Convenience helper that replaces the standard non-`NA` missing-code
#' sentinels used in SPSS / SAS / FACETS exports (`99`, `999`, `-1`,
#' `"N"`, `"NA"`, `"n/a"`, `"."`, `""`) with `NA` across the columns
#' you select. It is useful before calling [fit_mfrm()] on data exported with
#' those conventions.
#' A sentinel is a value used to mean "missing" instead of an actual score.
#' Only recode values that your data documentation defines as missing. For
#' custom score markers, specify both `columns = "Score"` and `codes`; this
#' preserves a person or rater identifier such as `99`.
#'
#' @param data A data frame.
#' @param columns Character vector of column names to recode. Defaults
#'   to `NULL`, in which case all columns are scanned.
#' @param codes Character vector of code values to convert to `NA`.
#'   Defaults to the FACETS / SPSS / SAS conventions; override when
#'   your instrument uses different sentinels.
#' @param numeric_codes Logical; if `TRUE` (default), numeric columns
#'   are also compared against the numeric conversion of `codes`.
#' @param verbose Logical; if `TRUE`, emits a `message()` summary of
#'   per-column replacement counts.
#'
#' @return The input `data` with the specified missing sentinels
#'   replaced by `NA`. A `mfrm_missing_recoding` attribute records the
#'   per-column replacement counts for traceability logs.
#'
#' @details
#' Save the returned data, for example `cleaned <- recode_missing_codes(...)`.
#' The original object is unchanged. This helper replaces cells and retains
#' every row; later, [describe_mfrm_data()] and [fit_mfrm()] exclude rating rows
#' with missing scores or required identifiers. Inspect the replacement counts
#' with `attr(cleaned, "mfrm_missing_recoding")`, then review and fit `cleaned`.
#'
#' The defaults differ across entry points: this helper scans all columns when
#' `columns` is omitted. In `describe_mfrm_data()` and `fit_mfrm()`,
#' `missing_codes = TRUE` uses the conventional code set on the score column
#' only; an explicit `missing_codes` vector applies to the person, facet, and
#' score columns. Use this helper with an explicit score column when your custom code
#' could also be a legitimate identifier.
#'
#' @seealso [describe_mfrm_data()], [fit_mfrm()].
#'
#' @examples
#' library(mfrmr)
#'
#' # A small input example: 99 and . mean missing only in the Score column
#' ratings <- data.frame(
#'   Person = c("001", "001", "002", "002"),
#'   Rater = c("R1", "99", "R1", "99"),
#'   Score = c("3", "99", ".", "2")
#' )
#' cleaned <- recode_missing_codes(
#'   ratings,
#'   columns = "Score",
#'   codes = c("99", ".")
#' )
#' cleaned # Two scores become NA; rater ID 99 and all four rows remain
#' attr(cleaned, "mfrm_missing_recoding") # Score: Replaced = 2
#' # Use the returned cleaned data for subsequent data review and fitting
#' @export
recode_missing_codes <- function(data,
                                 columns = NULL,
                                 codes = c("99", "999", "-1", "N", "NA",
                                           "n/a", ".", ""),
                                 numeric_codes = TRUE,
                                 verbose = FALSE) {
  if (!is.data.frame(data)) stop("`data` must be a data.frame.", call. = FALSE)
  if (is.null(columns)) columns <- names(data)
  bad_cols <- setdiff(columns, names(data))
  if (length(bad_cols) > 0L) {
    stop("Unknown column(s): ", paste(bad_cols, collapse = ", "), call. = FALSE)
  }
  codes <- as.character(codes)
  num_codes <- if (isTRUE(numeric_codes)) {
    suppressWarnings(as.numeric(codes))
  } else {
    numeric(0)
  }
  num_codes <- num_codes[is.finite(num_codes)]

  counts <- integer(length(columns))
  names(counts) <- columns
  for (col in columns) {
    x <- data[[col]]
    if (is.character(x)) {
      hit <- trimws(x) %in% codes
    } else if (is.numeric(x)) {
      hit <- x %in% num_codes
    } else {
      # factor or other: compare as character
      hit <- trimws(as.character(x)) %in% codes
    }
    n_hit <- sum(hit, na.rm = TRUE)
    counts[col] <- as.integer(n_hit)
    if (n_hit > 0L) {
      data[[col]][hit] <- NA
    }
  }
  attr(data, "mfrm_missing_recoding") <- data.frame(
    Column = columns,
    Replaced = as.integer(counts),
    stringsAsFactors = FALSE
  )
  if (isTRUE(verbose)) {
    total <- sum(counts, na.rm = TRUE)
    message(sprintf(
      "recode_missing_codes(): replaced %d cell(s) across %d column(s).",
      total, sum(counts > 0L, na.rm = TRUE)
    ))
  }
  data
}

#' @export
print.mfrm_data_description <- function(x, ...) {
  cat("mfrm data description\n")
  mfrmr_print_comparison_review(x$comparison_review)
  if (!is.null(x$overview) && nrow(x$overview) > 0) {
    print(x$overview, row.names = FALSE)
  }
  structural <- as.data.frame(
    x$structural_missingness$summary %||% data.frame(),
    stringsAsFactors = FALSE
  )
  if (nrow(structural) > 0L) {
    cat("\nPlanned assignment coverage\n")
    print(structural, row.names = FALSE)
  }
  if (!is.null(x$design_connectivity) && nrow(x$design_connectivity) > 0L) {
    cat("\nPerson-facet connectivity\n")
    print(as.data.frame(x$design_connectivity), row.names = FALSE)
  }
  if (!is.null(x$score_distribution) && nrow(x$score_distribution) > 0) {
    cat("\nScore distribution\n")
    print(x$score_distribution, row.names = FALSE)
  }
  if (!is.null(x$agreement$summary) && nrow(x$agreement$summary) > 0) {
    agreement_facet <- as.character(x$agreement$settings$rater_facet %||% "selected facet")
    cat("\nObserved agreement by ", agreement_facet, "\n", sep = "")
    print(x$agreement$summary, row.names = FALSE)
  }
  invisible(x)
}

collect_mfrm_design_caveats <- function(object) {
  out <- empty_mfrm_caveats()
  add_caveat <- function(area, severity, condition, facets, message, action, details = "") {
    out <<- rbind(
      out,
      data.frame(
        Area = area,
        Severity = severity,
        Condition = condition,
        Categories = paste(as.character(facets), collapse = ", "),
        CategoryType = "design",
        Message = message,
        RecommendedAction = action,
        Details = details,
        stringsAsFactors = FALSE
      )
    )
    invisible(NULL)
  }

  structural <- as.data.frame(
    object$structural_missingness$summary %||% data.frame(),
    stringsAsFactors = FALSE
  )
  if (nrow(structural) > 0L && identical(as.character(structural$Status[1L]), "declared")) {
    missing_n <- suppressWarnings(as.integer(structural$MissingExpectedCells[1L]))
    unexpected_n <- suppressWarnings(as.integer(structural$UnexpectedObservedCells[1L]))
    if (is.finite(missing_n) && missing_n > 0L) {
      add_caveat(
        area = "structural_missingness",
        severity = "review",
        condition = "planned_cells_not_observed",
        facets = object$structural_missingness$settings$key %||% character(0),
        message = paste0(
          missing_n,
          " planned rating cell(s) in `expected_design` were not observed."
        ),
        action = "Inspect the returned object's `structural_missingness$missing_expected_cells` table and document whether each absence was planned, unavailable, or lost."
      )
    }
    if (is.finite(unexpected_n) && unexpected_n > 0L) {
      add_caveat(
        area = "structural_missingness",
        severity = "warning",
        condition = "observed_cells_not_in_design",
        facets = object$structural_missingness$settings$key %||% character(0),
        message = paste0(
          unexpected_n,
          " observed rating cell(s) were not present in `expected_design`."
        ),
        action = "Reconcile the assignment roster and observed data before fitting."
      )
    }
  }

  connectivity <- as.data.frame(object$design_connectivity %||% data.frame(), stringsAsFactors = FALSE)
  if (nrow(connectivity) > 0L && all(c("Connected", "Basis", "Facet", "Components") %in% names(connectivity))) {
    disconnected <- connectivity[!as.logical(connectivity$Connected), , drop = FALSE]
    for (i in seq_len(nrow(disconnected))) {
      basis <- as.character(disconnected$Basis[i])
      facet <- as.character(disconnected$Facet[i])
      components <- suppressWarnings(as.integer(disconnected$Components[i]))
      add_caveat(
        area = "design_connectivity",
        severity = "warning",
        condition = paste0("disconnected_", basis, "_person_facet_graph"),
        facets = facet,
        message = paste0(
          "The ", gsub("_", " ", basis), " Person-", facet,
          " graph has ", components, " disconnected components."
        ),
        action = paste0(
          "Inspect the returned object's `design_components` table for ", facet,
          " and add defensible linking observations or analyze components separately."
        )
      )
    }
  }

  duplicates <- as.data.frame(object$duplicate_cell_summary %||% data.frame(), stringsAsFactors = FALSE)
  if (nrow(duplicates) > 0L && isTRUE(duplicates$HasDuplicates[1L])) {
    add_caveat(
      area = "duplicate_cells",
      severity = if (identical(object$repeated_ratings, "independent")) "info" else "warning",
      condition = if (identical(object$repeated_ratings, "independent"))
        "independent_repeated_ratings_declared" else "duplicate_person_facet_cells",
      facets = object$structural_missingness$settings$key %||% character(0),
      message = paste0(
        duplicates$DuplicateCells[1L],
        " Person x facet cell(s) contain multiple observed rows."
      ),
      action = if (identical(object$repeated_ratings, "independent"))
        "Conditional independence was declared by the analyst; the data check does not verify it." else
        "Review repeated events: correct accidental copies, model dependence, or explicitly declare conditional independence."
    )
  }

  linkage <- as.data.frame(object$linkage_summary %||% data.frame(), stringsAsFactors = FALSE)
  if (nrow(linkage) > 0L && all(c("Facet", "SparseLevels", "SparseLevelThreshold") %in% names(linkage))) {
    sparse <- linkage[suppressWarnings(as.integer(linkage$SparseLevels)) > 0L, , drop = FALSE]
    for (i in seq_len(nrow(sparse))) {
      add_caveat(
        area = "design_linkage",
        severity = "review",
        condition = "sparse_facet_levels",
        facets = sparse$Facet[i],
        message = paste0(
          sparse$SparseLevels[i], " level(s) of ", sparse$Facet[i],
          " were observed for fewer than ", sparse$SparseLevelThreshold[i],
          " distinct persons."
        ),
        action = "Review the affected level support and intended inference; the threshold is descriptive, not an automatic exclusion rule."
      )
    }
  }
  out
}

#' @rdname describe_mfrm_data
#' @details `summary()` method: Summarize a data-description object
#'
#' Read a compact summary of the checks from [describe_mfrm_data()] before
#' fitting a model. Save it with `review <- summary(data_review)` and select
#' the tables you need with `$`, as in the example.
#' @param object Output from [describe_mfrm_data()].
#' @param digits Number of digits for numeric rounding.
#' @param top_n Maximum rows shown in preview blocks.
#' @details For `summary()`: `data_review` holds the complete data checks; `review` holds summary tables
#' and notes. Neither object contains model estimates. The default `top_n = 10`
#' limits the missing-column and score-distribution previews; use
#' `data_review$missing_by_column` and `data_review$score_distribution` to see
#' the complete tables.
#' @section Interpreting output:
#' For `summary()`:
#'
#' Recommended read order:
#' - `overview`: retained ratings (`Observations`), persons, facets, and
#'   categories. Compare input and retained `Rows` in `row_retention` and
#'   investigate unexpected `DroppedRows`.
#'   `CategoryPolicy` and `ScoreRecoded` distinguish the selected policy from
#'   actual changes to score values. Older results without the policy record
#'   report `"not_recorded"`; an absent map gives `NA` for recoding.
#' - `missing`: input `NA` counts by column. This table is named
#'   `missing_by_column` in the original `data_review` object. Declared
#'   missing-code replacements and invalid score text can cause additional
#'   row loss; inspect `data_review$missing_recoding` and `preparation_notes`.
#' - `score_distribution`: category usage balance.
#' - `notes` / printed `Caveats`: retained zero-count score categories and
#'   related score-support caveats. With `keep_original = TRUE`, a retained
#'   unused internal category stops fitting; review the data and rubric first.
#' - `facet_overview`: coverage per facet (minimum/maximum weighted counts).
#' - `agreement`: observed-score agreement for the selected scorer facet (when
#'   available).
#' - `design_connectivity`: check for more than one observed component before
#'   comparing facet levels. `structural_missingness` reports planned omissions
#'   only when an assignment roster was supplied; `not_declared` does not mean
#'   that no ratings are missing.
#'
#' Very low `MinWeightedN` in `facet_overview` is a practical warning for
#' unstable downstream facet estimates.
#' @section Typical workflow:
#' For `summary()`:
#'
#' 1. Run [describe_mfrm_data()] on raw long-format data.
#' 2. Inspect `review <- summary(data_review)` before model fitting.
#' 3. Correct input issues and repeat the review, then pass the corrected
#'    rating data to [fit_mfrm()] with the same preparation settings.
#' @return For `summary()`: An object of class `summary.mfrm_data_description`.
#' - `overview`: design/sample counts
#' - `missing`: top columns by missingness
#' - `score_distribution`: compact score-usage table, including zero-count
#'   categories retained by the prepared score support
#' - `facet_overview`: facet-level coverage summary
#' - `structural_missingness`: declared assignment coverage summary; status is
#'   `"not_declared"` when no assignment roster was supplied
#' - `structural_level_coverage`: expected versus observed level counts
#' - `design_connectivity`: Person-facet component counts for observed and
#'   declared-expected designs
#' - `design_components`: component sizes and facet-level labels; person labels
#'   are suppressed unless explicitly requested in [describe_mfrm_data()]
#' - `linkage_summary`: sparse-support and shared-person counts by facet
#' - `duplicate_cell_summary`: aggregate duplicate-cell counts
#' - `agreement`: selected-facet agreement summary when available
#' - `agreement_settings`: selected scorer facet, matching context, and status
#' - `row_retention`: row counts before and after preparation filters
#' - `preparation_notes`: structured preparation notes retained from
#'   [describe_mfrm_data()]
#' - `reporting_map`: manuscript-oriented guide to what is covered here versus
#'   which companion outputs should be consulted
#' - `caveats`: structured warning/review rows for score-support issues;
#'   `print(summary(ds))` shows a compact `Caveats` block when rows are present
#' - `notes`: plain-language explanations of missingness, preparation, score
#'   support, and design-review findings
#' @seealso [describe_mfrm_data()], [summary.mfrm_fit()]
#' @examples # Supplementary workflow: run explicitly to keep routine checks brief.
#' # example("summary.mfrm_data_description", run.dontrun = TRUE)
#' \dontrun{
#' library(mfrmr)
#' ratings <- load_mfrmr_data("example_operational")
#'
#' # Demonstrate two missing scores in a copy of the example data
#' ratings$Score[1:2] <- NA
#' data_review <- describe_mfrm_data(
#'   data = ratings,
#'   person = "Person",
#'   facets = c("Rater", "Criterion"),
#'   score = "Score",
#'   rating_min = 1,
#'   rating_max = 4,
#'   category_policy = "preserve"
#' )
#' review <- summary(data_review)
#' review$row_retention # 282 input rows, 280 retained rows
#' review$missing       # Score has 2 missing input values
#' review$overview      # Counts describe the retained ratings
#' review$notes         # Explanations to read before fitting
#'
#' # The original description retains the full missingness table
#' data_review$missing_by_column
#' # Investigate missingness before using ratings in fit_mfrm()
#' }
#' @export
summary.mfrm_data_description <- function(object, digits = 3, top_n = 10, ...) {
  digits <- max(0L, as.integer(digits))
  top_n <- max(1L, as.integer(top_n))

  overview <- as.data.frame(object$overview %||% data.frame(), stringsAsFactors = FALSE)
  if (nrow(overview) > 0L) {
    category_settings <- mfrm_category_settings(object$score_support %||% object$prep)
    for (field in setdiff(names(category_settings), names(overview))) {
      overview[[field]] <- category_settings[[field]]
    }
  }
  missing_tbl <- as.data.frame(object$missing_by_column %||% data.frame(), stringsAsFactors = FALSE)
  if (nrow(missing_tbl) > 0 && all(c("Column", "Missing") %in% names(missing_tbl))) {
    missing_tbl <- missing_tbl |>
      dplyr::arrange(dplyr::desc(.data$Missing), .data$Column) |>
      dplyr::slice_head(n = top_n)
  }

  score_dist_full <- as.data.frame(object$score_distribution %||% data.frame(), stringsAsFactors = FALSE)
  score_dist <- score_dist_full
  if (nrow(score_dist) > 0) {
    score_dist <- utils::head(score_dist, n = top_n)
  }

  facet_tbl <- as.data.frame(object$facet_level_summary %||% data.frame(), stringsAsFactors = FALSE)
  facet_overview <- data.frame()
  if (nrow(facet_tbl) > 0 && all(c("Facet", "Level", "WeightedN") %in% names(facet_tbl))) {
    facet_overview <- facet_tbl |>
      dplyr::group_by(.data$Facet) |>
      dplyr::summarise(
        Levels = dplyr::n_distinct(.data$Level),
        TotalWeightedN = sum(.data$WeightedN, na.rm = TRUE),
        MeanWeightedN = mean(.data$WeightedN, na.rm = TRUE),
        MinWeightedN = min(.data$WeightedN, na.rm = TRUE),
        MaxWeightedN = max(.data$WeightedN, na.rm = TRUE),
        .groups = "drop"
      ) |>
      dplyr::arrange(.data$Facet) |>
      as.data.frame(stringsAsFactors = FALSE)
  }

  agreement_tbl <- as.data.frame(object$agreement$summary %||% data.frame(), stringsAsFactors = FALSE)
  row_retention <- as.data.frame(object$row_retention %||% data.frame(), stringsAsFactors = FALSE)
  preparation_notes <- as.data.frame(object$preparation_notes %||% data.frame(), stringsAsFactors = FALSE)
  structural_missingness <- as.data.frame(
    object$structural_missingness$summary %||% data.frame(),
    stringsAsFactors = FALSE
  )
  structural_level_coverage <- as.data.frame(
    object$structural_missingness$level_coverage %||% data.frame(),
    stringsAsFactors = FALSE
  )
  design_connectivity <- as.data.frame(object$design_connectivity %||% data.frame(), stringsAsFactors = FALSE)
  design_components <- as.data.frame(object$design_components %||% data.frame(), stringsAsFactors = FALSE)
  linkage_summary <- as.data.frame(object$linkage_summary %||% data.frame(), stringsAsFactors = FALSE)
  duplicate_cell_summary <- as.data.frame(object$duplicate_cell_summary %||% data.frame(), stringsAsFactors = FALSE)
  reporting_map <- data.frame(
    Area = c(
      "Sample / design counts",
      "Missingness review",
      "Planned assignment coverage",
      "Person-facet connectivity",
      "Score usage / category distribution",
      "Facet coverage",
      "Rater-facet agreement",
      "Fit / reliability / residual PCA"
    ),
    CoveredHere = c(
      "yes", "yes",
      if (nrow(structural_missingness) > 0L &&
          identical(as.character(structural_missingness$Status[1L]), "declared")) "yes" else "not declared",
      "yes", "yes", "yes",
      if (nrow(agreement_tbl) > 0) "yes" else "no", "no"
    ),
    CompanionOutput = c(
      "summary(describe_mfrm_data(...))",
      "summary(describe_mfrm_data(...))",
      "data_review$structural_missingness$missing_expected_cells",
      "data_review$design_components",
      "summary(describe_mfrm_data(...))",
      "summary(describe_mfrm_data(...))",
      "summary(describe_mfrm_data(...)) / plot(x, type = \"agreement\")",
      "summary(diagnose_mfrm(fit))"
    ),
    stringsAsFactors = FALSE
  )
  notes <- character(0)
  if (nrow(missing_tbl) > 0 && any(suppressWarnings(as.numeric(missing_tbl$Missing)) > 0, na.rm = TRUE)) {
    notes <- c(notes, "Missing values were detected in one or more input columns.")
  } else {
    notes <- c(notes, "No missing values were detected in selected input columns.")
  }
  caveat_prep <- object$score_support %||% object$prep %||% NULL
  caveats <- collect_mfrm_caveats(
    prep = caveat_prep,
    score_distribution = score_dist_full,
    include_recode = TRUE,
    context = "data"
  )
  if (nrow(caveats) > 0 && "Message" %in% names(caveats)) {
    notes <- c(notes, as.character(caveats$Message))
  }
  design_caveats <- collect_mfrm_design_caveats(object)
  caveats <- rbind(caveats, design_caveats)
  if (nrow(design_caveats) > 0L && "Message" %in% names(design_caveats)) {
    notes <- c(notes, as.character(design_caveats$Message))
  }
  structural_note <- as.character(object$structural_missingness$settings$note %||% "")
  if (nzchar(structural_note)) notes <- c(notes, structural_note)
  prep_review_messages <- if (nrow(preparation_notes) > 0L &&
                              all(c("Severity", "Message") %in% names(preparation_notes))) {
    preparation_notes$Message[
      tolower(as.character(preparation_notes$Severity)) %in% c("review", "warning", "error")
    ]
  } else {
    character(0)
  }
  notes <- c(notes, prep_review_messages)

  out <- list(
    overview = overview,
    comparison_review = object$comparison_review,
    missing = missing_tbl,
    score_distribution = score_dist,
    facet_overview = facet_overview,
    structural_missingness = structural_missingness,
    structural_level_coverage = structural_level_coverage,
    design_connectivity = design_connectivity,
    design_components = design_components,
    linkage_summary = linkage_summary,
    duplicate_cell_summary = duplicate_cell_summary,
    agreement = agreement_tbl,
    agreement_settings = object$agreement$settings %||% list(),
    row_retention = row_retention,
    preparation_notes = preparation_notes,
    reporting_map = reporting_map,
    caveats = caveats,
    notes = notes,
    digits = digits
  )
  class(out) <- "summary.mfrm_data_description"
  out
}

#' @export
print.summary.mfrm_data_description <- function(x, ...) {
  digits <- as.integer(x$digits %||% 3L)
  if (!is.finite(digits)) digits <- 3L
  cat("mfrm Data Description Summary\n")
  mfrmr_print_comparison_review(x$comparison_review)
  if (!is.null(x$overview) && nrow(x$overview) > 0) {
    cat("\nOverview\n")
    print(round_numeric_df(as.data.frame(x$overview), digits = digits), row.names = FALSE)
  }
  if (!is.null(x$missing) && nrow(x$missing) > 0) {
    cat("\nMissing by column\n")
    print(round_numeric_df(as.data.frame(x$missing), digits = digits), row.names = FALSE)
  }
  if (!is.null(x$structural_missingness) && nrow(x$structural_missingness) > 0) {
    cat("\nPlanned assignment coverage\n")
    print(round_numeric_df(as.data.frame(x$structural_missingness), digits = digits), row.names = FALSE)
  }
  if (!is.null(x$design_connectivity) && nrow(x$design_connectivity) > 0) {
    cat("\nPerson-facet connectivity\n")
    print(round_numeric_df(as.data.frame(x$design_connectivity), digits = digits), row.names = FALSE)
  }
  if (!is.null(x$linkage_summary) && nrow(x$linkage_summary) > 0) {
    cat("\nFacet linkage support\n")
    print(round_numeric_df(as.data.frame(x$linkage_summary), digits = digits), row.names = FALSE)
  }
  if (!is.null(x$score_distribution) && nrow(x$score_distribution) > 0) {
    cat("\nScore distribution\n")
    print(round_numeric_df(as.data.frame(x$score_distribution), digits = digits), row.names = FALSE)
  }
  if (!is.null(x$facet_overview) && nrow(x$facet_overview) > 0) {
    cat("\nFacet coverage\n")
    print(round_numeric_df(as.data.frame(x$facet_overview), digits = digits), row.names = FALSE)
  }
  if (!is.null(x$row_retention) && nrow(x$row_retention) > 0 &&
      "DroppedRows" %in% names(x$row_retention) &&
      any(suppressWarnings(as.numeric(x$row_retention$DroppedRows)) > 0, na.rm = TRUE)) {
    cat("\nRow retention\n")
    print(round_numeric_df(as.data.frame(x$row_retention), digits = digits), row.names = FALSE)
  }
  print_preparation_section(x$preparation_notes)
  if (!is.null(x$agreement) && nrow(x$agreement) > 0) {
    agreement_facet <- as.character(x$agreement_settings$rater_facet %||% "selected facet")
    cat("\nObserved agreement by ", agreement_facet, "\n", sep = "")
    print(round_numeric_df(as.data.frame(x$agreement), digits = digits), row.names = FALSE)
  }
  print_caveat_section(x$caveats)
  if (!is.null(x$reporting_map) && nrow(x$reporting_map) > 0) {
    cat("\nPaper reporting map\n")
    print(as.data.frame(x$reporting_map), row.names = FALSE)
  }
  note_lines <- as.character(x$notes %||% character(0))
  note_lines <- note_lines[nzchar(note_lines)]
  if (length(note_lines) > 0L) {
    cat("\nNotes\n")
    cat(paste0(" - ", note_lines, collapse = "\n"), "\n", sep = "")
  }
  invisible(x)
}

#' @rdname describe_mfrm_data
#' @details `plot()` method: Plot a data-description object
#' @param x Output from [describe_mfrm_data()].
#' @param y Reserved for generic compatibility.
#' @param type Plot type: `"score_distribution"`, `"facet_levels"`, or `"missing"`.
#' @param main Optional title override.
#' @param palette Optional named colors (`score`, `facet`, `missing`).
#' @param label_angle X-axis label angle for bar plots.
#' @param draw If `TRUE`, draw using base graphics.
#' @param ... Reserved for generic compatibility.
#' @details For `plot()`: This method draws quick pre-fit quality views from [describe_mfrm_data()]:
#' - score distribution balance
#' - facet-level structure size
#' - missingness by selected columns
#' @section Interpreting output:
#' For `plot()`:
#'
#' - `"score_distribution"`: bar chart of weighted observation counts per
#'   score category.  Y-axis is `WeightedN` (sum of weights for each
#'   category).  Categories with very few observations (< 10) may produce
#'   unstable threshold estimates.  A roughly uniform or unimodal
#'   distribution is ideal; heavy floor/ceiling effects compress the
#'   measurement range.
#' - `"facet_levels"`: bar chart showing the number of distinct levels
#'   per facet.  Useful for verifying that the design structure matches
#'   expectations (e.g., expected number of raters or criteria).  Very
#'   large numbers of levels increase computation time and may require
#'   higher `maxit` in [fit_mfrm()].
#' - `"missing"`: bar chart of missing-value counts per input column.
#'   Columns with non-zero counts should be investigated before
#'   fitting---rows with missing scores, persons, or facet IDs are
#'   dropped during estimation.
#' @section Typical workflow:
#' For `plot()`:
#'
#' 1. Run [describe_mfrm_data()] before fitting.
#' 2. Inspect `summary(ds)` and `plot(ds, type = "missing")`.
#' 3. Check category/facet balance with other plot types.
#' 4. Fit model after resolving obvious data issues.
#' @return For `plot()`: A `ggplot` object (invisibly), with underlying plot
#'   tables accessible via [plot_data()].
#' @seealso [describe_mfrm_data()], [plot_data()]
#' @examples # Supplementary workflow: run explicitly to keep routine checks brief.
#' # example("plot.mfrm_data_description", run.dontrun = TRUE)
#' \dontrun{
#' toy <- load_mfrmr_data("example_core")
#' ds <- describe_mfrm_data(toy, "Person", c("Rater", "Criterion"), "Score")
#' p <- plot(ds, draw = FALSE)
#' }
#' @export
plot.mfrm_data_description <- function(x,
                                       y = NULL,
                                       type = c("score_distribution", "facet_levels", "missing"),
                                       main = NULL,
                                       palette = NULL,
                                       label_angle = 45,
                                       draw = TRUE,
                                       ...) {
  type <- match.arg(tolower(as.character(type[1])), c("score_distribution", "facet_levels", "missing"))

  if (type == "score_distribution") {
    tbl <- as.data.frame(x$score_distribution %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(tbl) == 0 || !all(c("Score", "WeightedN") %in% names(tbl))) {
      stop("Score distribution is not available. Ensure describe_mfrm_data() was run on valid data.", call. = FALSE)
    }
    out <- new_mfrm_plot_data(
      "data_description",
      list(plot = "score_distribution", table = tbl)
    )
    return(.mfrm_finalize_ggplot(out, draw = draw))
  }

  if (type == "facet_levels") {
    tbl <- as.data.frame(x$facet_level_summary %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(tbl) == 0 || !all(c("Facet", "Level") %in% names(tbl))) {
      stop("Facet level summary is not available. Ensure describe_mfrm_data() was run on valid data.", call. = FALSE)
    }
    agg <- tbl |>
      dplyr::group_by(.data$Facet) |>
      dplyr::summarise(Levels = dplyr::n_distinct(.data$Level), .groups = "drop") |>
      dplyr::arrange(.data$Facet)
    out <- new_mfrm_plot_data(
      "data_description",
      list(plot = "facet_levels", table = as.data.frame(agg, stringsAsFactors = FALSE))
    )
    return(.mfrm_finalize_ggplot(out, draw = draw))
  }

  tbl <- as.data.frame(x$missing_by_column %||% data.frame(), stringsAsFactors = FALSE)
  if (nrow(tbl) == 0 || !all(c("Column", "Missing") %in% names(tbl))) {
    stop("Missing-by-column table is not available. Ensure describe_mfrm_data() was run on valid data.", call. = FALSE)
  }
  out <- new_mfrm_plot_data(
    "data_description",
    list(plot = "missing", table = tbl)
  )
  .mfrm_finalize_ggplot(out, draw = draw)
}

#' Review and normalize anchor/group-anchor tables
#'
#' @param data A data.frame in long format (one row per rating event).
#' @param person Column name for person IDs.
#' @param facets Character vector of facet column names.
#' @param score Column name for observed score.
#' @param anchors Optional direct-anchor table (Facet, Level, Anchor). Retained
#'   values are fixed during estimation.
#' @param group_anchors Optional group-anchor table
#'   (Facet, Level, Group, GroupValue) defining group-mean constraints.
#' @param weight Optional weight/frequency column name.
#' @param rating_min Optional minimum category value.
#' @param rating_max Optional maximum category value.
#' @param keep_original Keep original category values.
#'   New code can instead use `category_policy = "preserve"`.
#' @param category_policy Optional explicit category choice: `"collapse"`
#'   or `"preserve"` (`NULL` uses `keep_original`).
#' @param missing_codes Optional. `NULL` (default) is a no-op;
#'   `TRUE` or `"default"` converts the FACETS / SPSS / SAS sentinel
#'   set to `NA` on the score column before review while preserving person and
#'   facet identifiers. Supply a character vector to apply a custom code set
#'   across the person, facet, and score columns.
#' @param min_common_anchors Minimum directly anchored levels per non-Person
#'   facet used in the package count recommendation (default `5`). The function
#'   cannot verify that those levels have invariant cross-run identity.
#' @param min_obs_per_element Minimum weighted observations per facet level used
#'   in recommendations (default `30`).
#' @param min_obs_per_category Minimum weighted observations per score category
#'   used in recommendations (default `10`).
#' @param noncenter_facet One facet to leave non-centered. Other facets use
#'   `centering_scope`, as in [fit_mfrm()].
#' @param repeated_ratings Treatment of repeated Person-by-facet cells:
#'   `"review"` (default) or `"independent"`.
#' @param centering_scope Facet-centering convention: `"facet"` (default),
#'   `"remainder"`, or `"anchor_origin"` (see [fit_mfrm_technical_details]).
#' @param dummy_facets Facets to fix at zero.
#' @param spec Optional named `list` of shared model-specification settings
#'   (the same 33-key `spec` accepted by [describe_mfrm_data()],
#'   [fit_mfrm()], and [export_mfrm_model()]). Explicit top-level arguments
#'   override matching entries in `spec`.
#'
#' @details
#' This helper reviews computational constraints. A *direct anchor* fixes an
#' individual parameter to a supplied value. A *group anchor* constrains the
#' mean of declared elements to a supplied target. A *common-element link* is
#' different: it is observed overlap among administrations or subsets. Direct
#' or group constraints can transfer coordinates from a defensible reference,
#' but they do not manufacture empirical overlap.
#'
#' This function applies the same preprocessing and key-resolution rules
#' as `fit_mfrm()`, but returns a review object so constraints can be
#' checked *before* estimation. Running the review first helps avoid
#' estimation failures caused by misspecified or data-incompatible
#' anchors. It does not inspect source-fit readiness or establish that labels
#' denote the same invariant elements across runs. Those substantive checks
#' remain the caller's responsibility.
#' This review has no estimation-method argument. A clean table can still
#' request an unsupported model combination: in particular, `fit_mfrm()`
#' rejects Person direct/group anchors with MML. See the scale-constraint
#' section of [fit_mfrm()] before using partial anchors.
#'
#' **Anchor types:**
#' - *Direct anchors* fix individual element measures to specific logit
#'   values (e.g., Rater R01 anchored at 0.35 logits). Use internal coordinates,
#'   not values transformed for display with `Umean` or `Uscale`.
#' - *Group anchors* constrain the mean of a set of elements to a
#'   target value, allowing individual elements to vary freely around
#'   that mean. The target requires an external justification such as a
#'   defensible equal-mean or known-scale assumption.
#'   The mean is unweighted over declared levels, not over rating rows.
#'   `GroupValue` repeats one target per group. It is not a FACETS per-element
#'   contribution: values 0.2 and 1.0 in a native two-member group translate
#'   to 0.6 for both rows. See [fit_mfrm()] for group-origin centering and
#'   FACETS group 0 / extreme-exclusion differences.
#' - When both types include the same element, both constraints are retained:
#'   the direct anchor fixes that element and the group constraint still fixes
#'   the declared group mean. Incompatible combinations are rejected by the
#'   constraint/estimability checks.
#'
#' **Design checks** report whether each observed facet level has at least
#' `min_obs_per_element` weighted observations (default 30) and each
#' score category has at least `min_obs_per_category` (default 10).
#' These user-configurable counts are package screening recommendations, not
#' universal adequacy thresholds and not tests of connectedness or invariance.
#'
#' @section Interpreting output:
#' - `issue_counts`/`issues`: concrete data or specification problems.
#' - `facet_summary`: constraint coverage by facet. `FreeLevels` counts levels
#'   outside direct and group constraints, not free parameters. A group member
#'   may still vary, whereas centering removes a degree of freedom outside groups.
#' - `design_checks`: observation counts against the requested screening values.
#' - `recommendations`: action items before estimation.
#'
#' @section Typical workflow:
#' 1. Build candidate anchors (e.g., with [make_anchor_table()]).
#' 2. Run `review_mfrm_anchors(...)`.
#' 3. Resolve issues, then fit with [fit_mfrm()].
#'
#' @return A list of class `mfrm_anchor_review` with:
#' - `anchors`: cleaned direct constraints used by estimation
#' - `group_anchors`: cleaned group-mean constraints used by estimation
#' - `centering_scope`: the reviewed `"facet"`, `"remainder"` or
#'   `"anchor_origin"` convention
#' - `facet_summary`: counts of levels inside/outside declared constraints,
#'   `Centered` indicating the declared centering constraint, and `OriginBasis`
#'   describing how the facet's origin is set
#' - `design_checks`: observation-count checks by level/category
#' - `thresholds`: active threshold settings used for recommendations
#' - `issue_counts`: issue-type counts
#' - `issues`: list of issue tables
#' - `recommendations`: package-native anchor guidance strings
#'
#' @seealso [fit_mfrm()], [describe_mfrm_data()], [make_anchor_table()],
#'   [mfrmr_linking_and_dff]
#' @examples
#' # Supplementary workflow: run explicitly to keep routine checks brief.
#' # example("review_mfrm_anchors", run.dontrun = TRUE)
#' \dontrun{
#' ratings <- load_mfrmr_data("example_operational")
#' # Illustrative external value, not an estimate supplied with this dataset.
#' anchors <- data.frame(Facet = "Rater", Level = "R01", Anchor = 0.35)
#' review <- review_mfrm_anchors(
#'   data = ratings,
#'   person = "Person",
#'   facets = c("Rater", "Criterion"),
#'   score = "Score",
#'   anchors = anchors,
#'   rating_min = 1, rating_max = 4, category_policy = "preserve"
#' )
#' review$anchors                 # Check the retained value and matching ID.
#' review$issue_counts
#' review$recommendations         # Explains the selected centering convention.
#'
#' # A duplicate is a separate input problem: resolve it before fitting.
#' duplicate <- rbind(anchors, transform(anchors, Anchor = 0.10))
#' problem <- review_mfrm_anchors(
#'   ratings, "Person", c("Rater", "Criterion"), "Score",
#'   anchors = duplicate
#' )
#' problem$issues$duplicate_anchors
#' # Normalization retains the last value; it does not decide which is correct.
#' }
#' @name review_mfrm_anchors
#' @export
#' @order 1
review_mfrm_anchors <- function(data,
                                person = NULL,
                                facets = NULL,
                                score = NULL,
                                anchors = NULL,
                                group_anchors = NULL,
                                weight = NULL,
                                rating_min = NULL,
                                rating_max = NULL,
                                keep_original = FALSE,
                                missing_codes = NULL,
                                min_common_anchors = 5L,
                                min_obs_per_element = 30,
                                min_obs_per_category = 10,
                                noncenter_facet = "Person",
                                dummy_facets = NULL,
                                category_policy = NULL,
                                repeated_ratings = c("review", "independent"),
                                centering_scope = c("facet", "remainder", "anchor_origin"),
                                spec = NULL) {
  mc <- match.call(expand.dots = FALSE)
  formal_supplied <- setdiff(names(as.list(mc)[-1L]), "spec")
  spec_list <- .mfrm_validate_spec_list(spec, "review_mfrm_anchors()")
  rev_spec_keys <- c(
    "person", "facets", "score", "anchors", "group_anchors",
    "weight", "rating_min", "rating_max", "keep_original",
    "missing_codes", "min_common_anchors", "min_obs_per_element",
    "min_obs_per_category", "noncenter_facet", "dummy_facets",
    "category_policy", "repeated_ratings", "centering_scope"
  )
  for (nm in intersect(names(spec_list), rev_spec_keys)) {
    if (!nm %in% formal_supplied) {
      assign(nm, spec_list[[nm]], envir = environment())
    }
  }
  if ("keep_original" %in% formal_supplied && !"category_policy" %in% formal_supplied) {
    category_policy <- NULL
  }
  keep_original_supplied <- ("keep_original" %in% formal_supplied) ||
    ("keep_original" %in% names(spec_list) && !"category_policy" %in% formal_supplied)
  if (!is.character(person) || length(person) != 1L || is.na(person) || !nzchar(person)) {
    stop("`person` must be a single non-empty character string naming the person column.",
         call. = FALSE)
  }
  if (!is.character(facets) || length(facets) == 0L || anyNA(facets) || any(!nzchar(facets))) {
    stop("`facets` must be a character vector of one or more facet column names.",
         call. = FALSE)
  }
  if (!is.character(score) || length(score) != 1L || is.na(score) || !nzchar(score)) {
    stop("`score` must be a single non-empty character string naming the score column.",
         call. = FALSE)
  }
  centering_scope <- match.arg(centering_scope, c("facet", "remainder", "anchor_origin"))
  repeated_ratings <- match.arg(repeated_ratings, c("review", "independent"))
  keep_original <- resolve_mfrm_category_policy(
    keep_original, category_policy, keep_original_supplied)
  prep <- prepare_mfrm_data(
    data = data,
    person_col = person,
    facet_cols = facets,
    score_col = score,
    rating_min = rating_min,
    rating_max = rating_max,
    weight_col = weight,
    keep_original = keep_original,
    missing_codes = missing_codes,
    repeated_ratings = repeated_ratings,
    allow_single_person = TRUE
  )
  review_mfrm_prepared_anchors(
    prep = prep,
    anchors = anchors,
    group_anchors = group_anchors,
    min_common_anchors = min_common_anchors,
    min_obs_per_element = min_obs_per_element,
    min_obs_per_category = min_obs_per_category,
    noncenter_facet = noncenter_facet,
    dummy_facets = dummy_facets,
    centering_scope = centering_scope
  )$anchor_review
}

review_mfrm_prepared_anchors <- function(prep,
                                         anchors = NULL,
                                         group_anchors = NULL,
                                         min_common_anchors = 5L,
                                         min_obs_per_element = 30,
                                         min_obs_per_category = 10,
                                         noncenter_facet = "Person",
                                         dummy_facets = NULL,
                                         centering_scope = c("facet", "remainder", "anchor_origin")) {
  centering_scope <- match.arg(centering_scope)
  noncenter_facet <- sanitize_noncenter_facet(noncenter_facet, prep$facet_names)
  dummy_facets <- sanitize_dummy_facets(dummy_facets, prep$facet_names)

  review <- audit_anchor_tables(
    prep = prep,
    anchor_df = anchors,
    group_anchor_df = group_anchors,
    min_common_anchors = min_common_anchors,
    min_obs_per_element = min_obs_per_element,
    min_obs_per_category = min_obs_per_category,
    noncenter_facet = noncenter_facet,
    dummy_facets = dummy_facets,
    centering_scope = centering_scope
  )
  class(review) <- unique(c("mfrm_anchor_review", class(review)))
  # Check the same equalities as fitting, reusing the cleaned tables.
  constraint_specs <- prepare_constraint_specs(
    prep,
    noncenter_facet = noncenter_facet,
    dummy_facets = dummy_facets,
    centering_scope = centering_scope,
    anchor_review = review
  )
  list(anchor_review = review, constraint_specs = constraint_specs)
}

prepare_mfrm_auto_gpcm_scaffold_inputs <- function(data, person, missing_codes) {
  estimation_person_ids <- enc2utf8(trimws(as.character(data[[person]])))
  default_missing_codes <- isTRUE(missing_codes) ||
    (is.character(missing_codes) && length(missing_codes) == 1L &&
     identical(tolower(missing_codes), "default"))
  if (!is.null(missing_codes) && !isFALSE(missing_codes) &&
      !default_missing_codes) {
    estimation_person_ids[
      estimation_person_ids %in% enc2utf8(trimws(as.character(missing_codes)))
    ] <- NA_character_
  }
  scaffold_data <- data
  scaffold_data[[person]] <- estimation_person_ids
  scaffold_data <- scaffold_data[!is.na(estimation_person_ids), , drop = FALSE]
  person_tbl <- data.frame(
    .mfrmr_person_id = unique(estimation_person_ids[!is.na(estimation_person_ids)]),
    stringsAsFactors = FALSE
  )
  names(person_tbl) <- person
  list(
    estimation_person_ids = estimation_person_ids,
    scaffold_data = scaffold_data,
    population_formula = stats::as.formula("~ 1"),
    person_data = person_tbl,
    person_id = person
  )
}

annotate_mfrm_population_scaffold <- function(population,
                                              data,
                                              scaffold_data,
                                              gpcm_mml_active,
                                              auto_gpcm_population,
                                              population_sd = NULL) {
  if (!is.null(population_sd)) population$fixed_sd <- population_sd
  population$source <- if (auto_gpcm_population) {
    "gpcm_mml_default_identification"
  } else if (isTRUE(population$active)) {
    "user_supplied"
  } else {
    "none"
  }
  population$identification_role <- if (gpcm_mml_active &&
                                         isTRUE(population$active)) {
    "free_population_scale_with_geometric_mean_one_relative_slopes"
  } else if (gpcm_mml_active) {
    "fixed_standard_normal_with_geometric_mean_one_relative_slopes"
  } else {
    "not_applicable"
  }
  if (auto_gpcm_population) {
    population$response_rows_retained <- as.integer(nrow(scaffold_data))
    population$response_rows_omitted <- as.integer(
      nrow(data) - nrow(scaffold_data)
    )
    population$notes <- unique(c(
      as.character(population$notes %||% character(0)),
      paste(
        "An intercept-only person population model was activated automatically",
        "to identify GPCM MML without fixing both latent variance and",
        "the slope geometric mean."
      ),
      if (population$response_rows_omitted > 0L) {
        paste0(
          population$response_rows_omitted,
          " response row(s) with missing person IDs were excluded from the ",
          "automatic population scaffold; ordinary response preparation ",
          "applies the same exclusion."
        )
      } else {
        character(0)
      }
    ))
  }
  population
}

enforce_mfrm_anchor_review_policy <- function(anchor_review,
                                              anchor_policy = c("warn", "error", "silent")) {
  anchor_policy <- match.arg(tolower(anchor_policy), c("warn", "error", "silent"))
  schema_issues <- anchor_review$issues[c("anchor_schema_mismatch", "group_anchor_schema_mismatch")]
  if (any(vapply(schema_issues, nrow, integer(1)) > 0L))
    stop("Malformed anchor schema: nonempty constraints cannot be discarded. Direct anchors require facet, level and anchor/value/measure; group anchors also require group/subset and groupvalue/value/anchor.", call. = FALSE)
  issue_counts <- anchor_review$issue_counts
  issue_total <- if (is.null(issue_counts) || nrow(issue_counts) == 0) 0L else sum(issue_counts$N, na.rm = TRUE)
  if (issue_total > 0) {
    msg <- format_anchor_review_message(anchor_review)
    if (anchor_policy == "error") {
      stop(msg, call. = FALSE)
    } else if (anchor_policy == "warn") {
      warning(msg, call. = FALSE)
    }
  }
  invisible(anchor_review)
}

#' @export
print.mfrm_anchor_review <- function(x, ...) {
  issue_total <- if (!is.null(x$issue_counts) && nrow(x$issue_counts) > 0) sum(x$issue_counts$N) else 0
  cat("mfrm anchor review\n")
  cat("  issue rows: ", issue_total, "\n", sep = "")

  if (!is.null(x$issue_counts) && nrow(x$issue_counts) > 0) {
    nonzero <- x$issue_counts |>
      dplyr::filter(.data$N > 0)
    if (nrow(nonzero) > 0) {
      cat("\nIssue counts\n")
      print(nonzero, row.names = FALSE)
    }
  }

  if (!is.null(x$facet_summary) && nrow(x$facet_summary) > 0) {
    cat("\nFacet summary\n")
    print(x$facet_summary, row.names = FALSE)
  }

  if (!is.null(x$design_checks) &&
      !is.null(x$design_checks$level_observation_summary) &&
      nrow(x$design_checks$level_observation_summary) > 0) {
    cat("\nLevel observation summary\n")
    print(x$design_checks$level_observation_summary, row.names = FALSE)
  }

  invisible(x)
}

#' @rdname review_mfrm_anchors
#' @details `summary()` method: Summarize an anchor-review object
#' @param object Output from [review_mfrm_anchors()].
#' @param digits Number of digits for numeric rounding.
#' @param top_n Maximum rows shown in issue previews.
#' @details For `summary()`: This summary provides a compact pre-estimation review of anchor and
#' group-anchor specifications.
#' @section Interpreting output:
#' For `summary()`:
#'
#' Recommended order:
#' - `issue_counts`: primary triage table (non-zero issues first).
#' - `facet_summary`: anchored/grouped/free-level balance by facet.
#' - `level_observation_summary` and `category_counts`: sparse-cell diagnostics.
#' - `recommendations`: concrete remediation suggestions.
#'
#' If `issue_counts` is non-empty, treat anchor constraints as provisional and
#' resolve issues before final estimation.
#' @section Typical workflow:
#' For `summary()`:
#'
#' 1. Run [review_mfrm_anchors()] with intended anchors/group anchors.
#' 2. Review `summary(review)` and recommendations.
#' 3. Revise anchor tables, then call [fit_mfrm()].
#' @return For `summary()`: An object of class `summary.mfrm_anchor_review`.
#' @seealso [review_mfrm_anchors()], [fit_mfrm()]
#' @examples # Supplementary workflow: run explicitly to keep routine checks brief.
#' # example("summary.mfrm_anchor_review", run.dontrun = TRUE)
#' \dontrun{
#' toy <- load_mfrmr_data("example_core")
#' review <- review_mfrm_anchors(toy, "Person", c("Rater", "Criterion"), "Score")
#' summary(review)
#' }
#' @export
summary.mfrm_anchor_review <- function(object, digits = 3, top_n = 10, ...) {
  digits <- max(0L, as.integer(digits))
  top_n <- max(1L, as.integer(top_n))

  issue_counts <- as.data.frame(object$issue_counts %||% data.frame(), stringsAsFactors = FALSE)
  if (nrow(issue_counts) > 0 && all(c("Issue", "N") %in% names(issue_counts))) {
    issue_counts <- issue_counts |>
      dplyr::filter(.data$N > 0) |>
      dplyr::arrange(dplyr::desc(.data$N), .data$Issue) |>
      dplyr::slice_head(n = top_n)
  }

  facet_summary <- as.data.frame(object$facet_summary %||% data.frame(), stringsAsFactors = FALSE)
  level_summary <- as.data.frame(object$design_checks$level_observation_summary %||% data.frame(), stringsAsFactors = FALSE)
  category_summary <- as.data.frame(object$design_checks$category_counts %||% data.frame(), stringsAsFactors = FALSE)

  recommendations <- as.character(object$recommendations %||% character(0))
  if (length(recommendations) > top_n) {
    recommendations <- recommendations[seq_len(top_n)]
  }

  notes <- if (nrow(issue_counts) > 0) {
    "Anchor-review issues were detected. Review issue counts and recommendations."
  } else {
    "No anchor-table issue rows were detected."
  }

  out <- list(
    issue_counts = issue_counts,
    facet_summary = facet_summary,
    level_observation_summary = level_summary,
    category_counts = category_summary,
    recommendations = recommendations,
    notes = notes,
    digits = digits
  )
  class(out) <- "summary.mfrm_anchor_review"
  out
}

#' @export
print.summary.mfrm_anchor_review <- function(x, ...) {
  digits <- as.integer(x$digits %||% 3L)
  if (!is.finite(digits)) digits <- 3L

  cat("mfrm Anchor Review Summary\n")
  if (!is.null(x$issue_counts) && nrow(x$issue_counts) > 0) {
    cat("\nIssue counts\n")
    print(round_numeric_df(as.data.frame(x$issue_counts), digits = digits), row.names = FALSE)
  }
  if (!is.null(x$facet_summary) && nrow(x$facet_summary) > 0) {
    cat("\nFacet summary\n")
    print(round_numeric_df(as.data.frame(x$facet_summary), digits = digits), row.names = FALSE)
  }
  if (!is.null(x$level_observation_summary) && nrow(x$level_observation_summary) > 0) {
    cat("\nLevel observation summary\n")
    print(round_numeric_df(as.data.frame(x$level_observation_summary), digits = digits), row.names = FALSE)
  }
  if (!is.null(x$category_counts) && nrow(x$category_counts) > 0) {
    cat("\nCategory counts\n")
    print(round_numeric_df(as.data.frame(x$category_counts), digits = digits), row.names = FALSE)
  }
  if (length(x$recommendations) > 0) {
    cat("\nRecommendations\n")
    for (line in x$recommendations) cat(" - ", line, "\n", sep = "")
  }
  if (!is.null(x$notes) && nzchar(x$notes)) {
    cat("\nNotes\n")
    cat(" - ", x$notes, "\n", sep = "")
  }
  invisible(x)
}

#' @rdname review_mfrm_anchors
#' @details `plot()` method: Plot an anchor-review object
#' @param x Output from [review_mfrm_anchors()].
#' @param y Reserved for generic compatibility.
#' @param type Plot type: `"issue_counts"`, `"facet_constraints"`,
#'   or `"level_observations"`.
#' @param main Optional title override.
#' @param palette Optional named colors.
#' @param label_angle X-axis label angle for bar plots.
#' @param draw If `TRUE`, print the `ggplot` figure on the active graphics device.
#' @param ... Reserved for generic compatibility.
#' @details For `plot()`: `ggplot2` visualization helper for anchor-review outputs.
#' @section Interpreting output:
#' For `plot()`:
#'
#' - `"issue_counts"`: volume of each issue class.
#' - `"facet_constraints"`: anchored/grouped/free mix by facet.
#' - `"level_observations"`: observation support across levels.
#' @section Typical workflow:
#' For `plot()`:
#'
#' 1. Run [review_mfrm_anchors()].
#' 2. Start with `plot(review, type = "issue_counts")`.
#' 3. Inspect constraint and support plots before fitting.
#' @return For `plot()`: A `ggplot` object (invisibly), with underlying plot
#'   tables accessible via [plot_data()].
#' @seealso [review_mfrm_anchors()], [make_anchor_table()], [plot_data()]
#' @examples # Supplementary workflow: run explicitly to keep routine checks brief.
#' # example("plot.mfrm_anchor_review", run.dontrun = TRUE)
#' \dontrun{
#' toy <- load_mfrmr_data("example_core")
#' review <- review_mfrm_anchors(toy, "Person", c("Rater", "Criterion"), "Score")
#' p <- plot(review, draw = FALSE)
#' }
#' @export
plot.mfrm_anchor_review <- function(x,
                                    y = NULL,
                                    type = c("issue_counts", "facet_constraints", "level_observations"),
                                    main = NULL,
                                    palette = NULL,
                                    label_angle = 45,
                                    draw = TRUE,
                                    ...) {
  type <- match.arg(tolower(as.character(type[1])), c("issue_counts", "facet_constraints", "level_observations"))

  if (type == "issue_counts") {
    tbl <- as.data.frame(x$issue_counts %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(tbl) == 0 || !all(c("Issue", "N") %in% names(tbl))) {
      stop("Issue-count table is not available. Ensure review_mfrm_anchors() was run with valid anchor inputs.", call. = FALSE)
    }
    tbl <- tbl |>
      dplyr::arrange(dplyr::desc(.data$N), .data$Issue)
    out <- new_mfrm_plot_data(
      "anchor_review",
      list(plot = "issue_counts", table = tbl)
    )
    return(.mfrm_finalize_ggplot(out, draw = draw))
  }

  if (type == "facet_constraints") {
    tbl <- as.data.frame(x$facet_summary %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(tbl) == 0 || !all(c("Facet", "AnchoredLevels", "GroupedLevels", "FreeLevels") %in% names(tbl))) {
      stop("Facet summary with constraint columns is not available. Ensure review_mfrm_anchors() was run with valid anchor inputs.", call. = FALSE)
    }
    out <- new_mfrm_plot_data(
      "anchor_review",
      list(plot = "facet_constraints", table = tbl)
    )
    return(.mfrm_finalize_ggplot(out, draw = draw))
  }

  tbl <- as.data.frame(x$design_checks$level_observation_summary %||% data.frame(), stringsAsFactors = FALSE)
  if (nrow(tbl) == 0 || !all(c("Facet", "MinObsPerLevel") %in% names(tbl))) {
    stop("Level observation summary is not available. Ensure review_mfrm_anchors() was run with valid anchor inputs.", call. = FALSE)
  }
  out <- new_mfrm_plot_data(
    "anchor_review",
    list(plot = "level_observations", table = tbl)
  )
  .mfrm_finalize_ggplot(out, draw = draw)
}

#' Build a candidate direct-anchor table from fitted estimates
#'
#' @param fit Output from [fit_mfrm()].
#' @param facets Optional subset of facets to include.
#' @param include_person Include person estimates as candidate anchors. Use only
#'   when cross-run person identity and the intended longitudinal constraint
#'   are substantively justified. Fixed Person values are supported only by
#'   a receiving JML fit; MML rejects Person anchors.
#' @param digits `NULL` (default) preserves the fitted numeric values. A
#'   nonnegative integer explicitly rounds them for display or external use.
#' @param readiness_policy How a source fit that is not inference-ready is
#'   handled. `"error"` (default) refuses anchor export or reuse. `"review"`
#'   permits explicit review-only extraction; those values must not be used as
#'   operational anchors.
#'
#' @details
#' This function performs a mechanical conversion from fitted estimates to the
#' `Facet`/`Level`/`Anchor` schema accepted by `fit_mfrm()`. The returned rows
#' are candidate direct constraints, not an approved anchor set.
#' `Anchor` uses the internal, untransformed location metric. The table does
#' not include category thresholds, GPCM slopes, model settings or source SEs;
#' it is not a complete saved calibration. See [extract_mfrm_calibration()] for that
#' separate workflow. Fixing an estimated value does not propagate its source
#' uncertainty into the new fit.
#'
#' By default, the function refuses export when the source fit is not
#' inference-ready under the current readiness contract. Set
#' `readiness_policy = "review"` only to inspect candidate values; this does not
#' make them eligible for reuse. The function cannot verify cross-run element
#' identity or invariance. Before reuse, document why selected elements retain
#' the same meaning, check the observed design's connectedness, and run
#' [review_mfrm_anchors()] on the receiving data. That review checks schema and
#' receiving-data support; it does not validate the source fit or the
#' substantive invariance assumption.
#'
#' Keep `digits = NULL` for recalibration. Rounding individual anchors can
#' break their joint sum or group-mean constraint, even at six decimal places.
#' Explicitly rounded values are different constraints and must be reviewed
#' before reuse; the fitter does not silently recenter supplied anchors.
#'
#' @section Interpreting output:
#' - `Facet`: facet name to be anchored in later runs.
#' - `Level`: specific element/level name inside that facet.
#' - `Anchor`: fixed logit value (rounded only when `digits` is supplied).
#'
#' @section Typical workflow:
#' 1. Fit and diagnose a defensible reference run with [fit_mfrm()].
#' 2. Confirm source readiness, element identity, and the intended link.
#' 3. Export candidates with `make_anchor_table(fit)` and review them.
#' 4. Pass selected rows back into `fit_mfrm(..., anchors = ...)`.
#'
#' @return A data.frame with `Facet`, `Level`, and `Anchor`.
#' @seealso [fit_mfrm()], [review_mfrm_anchors()]
#' @examples
#' # Supplementary workflow: run explicitly to keep routine checks brief.
#' # example("make_anchor_table", run.dontrun = TRUE)
#' \dontrun{
#' ratings <- load_mfrmr_data("example_operational")
#' fit <- fit_mfrm(
#'   ratings, "Person", c("Rater", "Criterion"), "Score",
#'   method = "MML", rating_min = 1, rating_max = 4,
#'   category_policy = "preserve"
#' )
#' # Select a facet deliberately; matching labels alone do not prove invariance.
#' anchors_tbl <- make_anchor_table(fit, facets = "Rater")
#' anchors_tbl
#' }
#' @export
make_anchor_table <- function(fit,
                              facets = NULL,
                              include_person = FALSE,
                              digits = NULL,
                              readiness_policy = c("error", "review")) {
  stop_if_product_slopes(fit, "make_anchor_table()")
  if (!inherits(fit, "mfrm_fit")) {
    stop("`fit` must be an mfrm_fit object from fit_mfrm().", call. = FALSE)
  }

  readiness_policy <- match.arg(readiness_policy)
  source_readiness <- mfrm_convergence_state(fit)
  fit_readiness <- as.character(
    source_readiness$fit_readiness %||% "legacy_unknown"
  )[1]
  if (is.na(fit_readiness) || !nzchar(fit_readiness)) {
    fit_readiness <- "legacy_unknown"
  }
  if (!isTRUE(source_readiness$inference_ready) &&
      identical(readiness_policy, "error")) {
    stop(
      "`fit` is not eligible for anchor export or reuse (FitReadiness = '",
      fit_readiness,
      "', InferenceReady = FALSE). Resolve the source fit or use ",
      "`readiness_policy = \"review\"` only to inspect review-only ",
      "candidate values.",
      call. = FALSE
    )
  }

  if (!is.null(digits) && (!is.numeric(digits) || is.complex(digits) ||
      length(digits) != 1L || !is.finite(digits) || digits < 0 || digits != floor(digits))) {
    stop("`digits` must be NULL or one nonnegative integer.", call. = FALSE)
  }
  anchor_values <- function(x) {
    if (is.null(digits)) as.numeric(x) else round(as.numeric(x), digits = digits)
  }
  out <- tibble::tibble()

  if (isTRUE(include_person) && !is.null(fit$facets$person) && nrow(fit$facets$person) > 0) {
    per <- tibble::as_tibble(fit$facets$person)
    if ("Person" %in% names(per) && "Estimate" %in% names(per)) {
      out <- dplyr::bind_rows(
        out,
        per |>
          dplyr::transmute(
            Facet = "Person",
            Level = as.character(.data$Person),
            Anchor = anchor_values(.data$Estimate)
          )
      )
    }
  }

  others <- tibble::as_tibble(fit$facets$others)
  if (nrow(others) > 0 && all(c("Facet", "Level", "Estimate") %in% names(others))) {
    out <- dplyr::bind_rows(
      out,
      others |>
        dplyr::transmute(
          Facet = as.character(.data$Facet),
          Level = as.character(.data$Level),
          Anchor = anchor_values(.data$Estimate)
        )
    )
  }

  if (!is.null(facets)) {
    keep <- as.character(facets)
    out <- out |>
      dplyr::filter(.data$Facet %in% keep)
  }

  out <- out |>
    dplyr::arrange(.data$Facet, .data$Level)
  attr(out, "source_fit_readiness") <- fit_readiness
  attr(out, "source_inference_ready") <-
    isTRUE(source_readiness$inference_ready)
  attr(out, "readiness_policy") <- readiness_policy
  out
}

#' Compute diagnostics for an `mfrm_fit` object
#'
#' @param fit Output from [fit_mfrm()].
#' @param interaction_pairs Optional list of facet pairs.
#' @param top_n_interactions Number of top interactions.
#' @param whexact ZSTD transformation. `FALSE` (default) uses
#'   Wilson-Hilferty with the q/3 term (FACETS `WHEXACT=YES`);
#'   `TRUE` omits that term (FACETS `WHEXACT=NO`), where
#'   q = sqrt(2/df). The historical logical names are retained.
#'   `"legacy_linear"` explicitly requests the former TRUE calculation,
#'   (MnSq - 1) * sqrt(df/2), which is not FACETS WHEXACT=NO.
#' @param fit_df_method Degrees-of-freedom convention used for fit ZSTD.
#'   `"facets"` (default) uses the Wright-Masters fourth-moment approximation
#'   `df = 2 / q^2` and caps reported ZSTD at +/-9. `"engine"` retains
#'   `DF_Infit = sum(Var * Weight)` and `DF_Outfit = sum(Weight)`.
#'   `"both"` uses engine primary columns and adds `*_FACETS` companions.
#'   Engine transformations require df >= 1; the FACETS route admits df > 0.
#' @param diagnostic_mode Diagnostic basis to compute: `"both"` (the
#'   current default) computes both the residual/EAP-based stack and
#'   the strict latent-integrated first-order marginal-fit companion;
#'   `"legacy"` keeps the residual/EAP-based stack only;
#'   `"marginal_fit"` returns only the marginal-fit companion. The
#'   `"both"` path adds a posterior-integrated pass that typically
#'   doubles to quintuples wall-clock time relative to `"legacy"`;
#'   pass `"legacy"` explicitly when iterating on large designs and
#'   only the residual stack is needed. Use `"both"` for RSM/PCM
#'   reporting fits because it enables [plot(x, type = "marginal_fit")][plot.mfrm_fit] and
#'   [plot(x, type = "marginal_pairwise")][plot.mfrm_fit] follow-up.
#' @section Saved diagnostic definitions:
#' New diagnostics carry `calculation_version = 2L`. Recreate older diagnostics
#' with `diagnose_mfrm(fit)` before using current reports; no refit is needed.
#' For historical ZSTD use `fit_df_method = "engine"` and, if applicable,
#' `whexact = "legacy_linear"`. PTMEA, displacement, eligible chi-square df,
#' fair scores and unexpected-response defaults use the corrected definitions.
#'
#' @param residual_pca Residual PCA mode: `"none"`, `"overall"`, `"facet"`, or `"both"`.
#' @param pca_max_factors Maximum number of PCA factors to retain per matrix.
#'
#' @details
#' This function computes a diagnostic bundle used by downstream reporting.
#' It calculates element-level fit statistics, approximate facet
#' separation/reliability summaries, residual-based QC diagnostics, and
#' optionally residual PCA for
#' exploratory residual-structure screening.
#'
#' `diagnostic_mode` keeps the legacy residual fit path explicit rather than
#' silently replacing it. The legacy path is a compatibility-oriented
#' residual/EAP stack, whereas the strict marginal path targets
#' latent-integrated first-order category counts. When `diagnostic_mode =
#' "both"`, the output includes a `diagnostic_basis` guide so downstream
#' tables and summaries can distinguish these targets.
#'
#' **Legacy response calculations.** Saved MML EAPs are matched to responses
#' by Person identifier. JML retains optimizer-coordinate probabilities for
#' compatibility diagnostics. In `obs`, `PersonMeasure` records the ability
#' used, `PrimaryPersonMeasure` records the primary estimate (possibly
#' infinite), and `PersonMeasureBasis` identifies the calculation. A finite
#' JML optimizer value is not a finite primary estimate at a boundary.
#' For supported ordinary fits, [fitted()][mfrm_fit_responses] instead uses
#' primary JML limits. The posterior/corrected-JML targets have their own
#' documented routes in [mfrm_response_diagnostics()].
#'
#' `obs$ConditionalVariance` retains the actual conditional variance.
#' Legacy `Var`, `StdResidual` and `StdSq` are withheld when that variance is
#' at or below `1e-10`. A positive value below this cutoff is a diagnostic
#' screening convention, not a mathematically undefined Pearson residual;
#' [residuals(fit, "pearson")][mfrm_fit_responses] retains representable positive
#' variances within its supported scope. A zero variance makes the Pearson
#' residual undefined. Expected ratings and raw residuals can remain available
#' in either case. `PearsonAvailable`, `ResponseStatus` and `ResponseReason`
#' explain each row, and are retained in score/residual file tables.
#'
#' Overall and element-level mean squares require every contributing row's
#' standardized residual, variance and positive weight. If any is unavailable,
#' the aggregate and its degrees of freedom remain `NA`; missing residuals
#' are not counted as zero misfit or silently excluded. `FitResponseRows`,
#' `FitAvailableRows` and `FitUnavailableRows` count rows (not weight totals),
#' while `FitStatus` and `FitReason` explain availability. These fields accompany
#' `overall_fit`, `fit` and `measures`. FACETS-style degrees of freedom also
#' require complete fourth moments. Regenerate older diagnostics and exports
#' from the saved fit to obtain these explanations; model refitting is not
#' required.
#'
#' Marginal expected counts integrate over each Person's posterior conditioned
#' on the same observed responses, holding fitted calibration fixed. They are
#' not expectations from an independent replication or a prior-only population
#' margin. First-order residual scales use `sum(w^2 * p * (1-p))`; pairwise
#' scales use the analogous formula with products of row weights. These scales
#' omit cross-response/opportunity covariance and calibration-parameter
#' uncertainty. They are descriptive screens, not calibrated residual tests.
#'
#' Missing/invalid contributing probabilities, scores or weights withhold the
#' affected complete-scope aggregate rather than selecting usable rows. Missing
#' standardized residuals and flags remain `NA`. A known cutoff crossing stays
#' flagged when a companion rule is unavailable. `marginal_fit$coverage` records
#' classified/unclassified cells, groups and level pairs. Row/opportunity counts
#' remain visible; zero-weight opportunities contribute no information.
#' Available maxima are accompanied by classification/residual counts; they
#' are not maxima over unavailable values. RMSDs require the complete scope.
#' In PCM and GPCM, step-group summaries retain the declared `step_facet`.
#' Regenerate older marginal diagnostics and downstream summaries/plots/exports
#' from the existing fit and original diagnostic settings; no model refit is
#' required.
#'
#' Choosing `diagnostic_mode`:
#' - `"legacy"`: use when continuity with historical residual-based workflows is
#'   the priority.
#' - `"marginal_fit"`: use when you want the strict latent-integrated screen
#'   without the extra legacy bundle.
#' - `"both"`: recommended when you want continuity with the legacy residual
#'   stack while making the strict marginal path explicit for `RSM`, `PCM`,
#'   and `GPCM` fits.
#'
#' For `GPCM`, the same generalized partial credit kernel now
#' drives both the residual/probability tables and the strict marginal
#' category-fit companion. Residual-based MnSq summaries should still be read
#' as exploratory screening tools rather than strict Rasch-style invariance
#' tests because discrimination is free, and the strict marginal companion
#' should likewise be treated as a slope-aware screen rather than a finalized
#' inferential test family.
#'
#' **Key fit statistics computed for each element:**
#' - **Infit MnSq**: information-weighted mean-square residual; sensitive
#'   to on-target misfitting patterns.  Expected value = 1.0.
#' - **Outfit MnSq**: unweighted mean-square residual; sensitive to
#'   off-target outliers.  Expected value = 1.0.
#' - **ZSTD**: Wilson-Hilferty cube-root transformation of MnSq to an
#'   approximate standard normal deviate.
#' - **PTMEA**: within-element point-measure correlation between observed
#'   scores and the oriented sum of model measures (`obs$MeasureSum`),
#'   including Person rows. A positive value is directionally
#'   consistent with the fitted orientation; it is not a confirmatory test.
#'
#' The MnSq values and the ZSTD values should be read separately. `mfrmr` keeps
#' the fourth-moment df convention by default. The former engine convention
#' remains explicit. This changes some ZSTD screening decisions, not the
#' underlying MnSq. MML residual diagnostics remain EAP plug-in quantities;
#' this standardization does not make them posterior-integrated fit tests. Use
#' `fit_df_method = "both"` to review these two standardization conventions
#' side by side, using engine primary columns and FACETS companion columns.
#'
#' **Residual basis under MML.** For `method = "MML"` fits, residuals,
#' MnSq, and ZSTD are computed at the EAP person measures from the
#' marginal model. EAP measures are shrunken toward the population mean,
#' so expected scores -- and therefore fit statistics -- differ
#' systematically from JMLE-based engines such as FACETS, especially for
#' persons with extreme raw scores. The df conventions above do not remove
#' this difference: it is a residual-basis difference, not a
#' standardization difference. Refit with `method = "JML"` when an
#' external FACETS fit comparison requires a JMLE-style residual basis
#' (see [facets_fit_review()]).
#' ConQuest MML parameter fit also has a different target: residuals are
#' aggregated through the response design for each parameter, then averaged
#' over posterior ability distributions. Its Infit averages a ratio, rather
#' than dividing separately averaged residual sums and variances. Posterior
#' integration of row residuals alone does not reproduce that statistic. Native
#' marginal category-count diagnostics are another target. See the
#' [ConQuest technical manual](https://conquestmanual.acer.org/s3-00.html).
#'
#' **Heuristic misfit-screening guidelines (Bond & Fox, 2015):**
#' - MnSq < 0.5: overfit (too predictable; may inflate reliability)
#' - MnSq 0.5--1.5: productive for measurement
#' - MnSq > 1.5: underfit (noise degrades measurement)
#' - \eqn{|\mathrm{ZSTD}| \ge 2}: package convention for the approximate-normal review flag;
#'   not a calibrated 5\% hypothesis test, especially after parameter estimation
#'   and repeated screening across elements
#'
#' When Infit and Outfit disagree, Infit is generally more informative
#' because it downweights extreme observations.  Large Outfit with
#' acceptable Infit typically indicates a few outlying responses rather
#' than systematic misfit.
#'
#' `interaction_pairs` controls which facet interactions are summarized.
#' Each element can be:
#' - a length-2 character vector such as `c("Rater", "Criterion")`, or
#' - omitted (`NULL`) to let the function select top interactions automatically.
#'
#' Residual PCA behavior:
#' - `"none"`: skip PCA (fastest; recommended for initial exploration)
#' - `"overall"`: compute overall residual PCA across all facets
#' - `"facet"`: compute facet-specific residual PCA for each facet
#' - `"both"`: compute both overall and facet-specific PCA
#'
#' Overall PCA examines the person \eqn{\times} combined-facet residual
#' matrix; facet-specific PCA examines person \eqn{\times} facet-level
#' matrices. These summaries are exploratory screens for residual
#' structure, not standalone proofs for or against unidimensionality.
#' Facet-specific PCA can help localise where a stronger residual signal
#' is concentrated.
#'
#' These residual-PCA summaries are not a DIMTEST/UNIDIM implementation.
#' DIMTEST-style essential-unidimensionality tests work at an item-response
#' layer and require an explicit decision about how many-facet rating data are
#' collapsed, conditioned, or adjusted for rater/task/facet effects. For
#' manuscripts, combine global/element fit, residual PCA, and local-dependence
#' screens, and use limited wording such as "evidence consistent with essential
#' unidimensionality under the specified facet structure" rather than
#' "unidimensionality was established."
#'
#' @section Reading key components:
#' Practical interpretation often starts with:
#' - `overall_fit`: global infit/outfit and degrees of freedom.
#' - `reliability`: facet-level model/real separation and reliability. `MML`
#'   uses model-based `ModelSE` values where available; `JML` keeps these
#'   quantities as exploratory approximations.
#' - `fit`: element-level misfit scan (`Infit`, `Outfit`, `ZSTD`).
#' - `unexpected`, `fair_average`, `displacement`: targeted QC bundles.
#'   For `GPCM`, `fair_average` is retained with an unavailable
#'   status because that compatibility calculation is outside the documented
#'   generalized-model contract.
#' - `approximation_notes`: method notes for SE/CI/reliability summaries.
#'
#' @section Interpreting output:
#' Testlet and shared-rater fits use [mfrm_response_diagnostics()] instead of
#' this ordinary-model route. Their same-data posterior predictive residual
#' summaries do not inherit ordinary fit cutoffs, ZSTD or p-values.
#'
#' Start with `overall_fit` and `reliability`, then move to element-level
#' diagnostics (`fit`) and targeted bundles (`unexpected`, `displacement`,
#' `interrater`, `facets_chisq`). Treat `fair_average` as available only for
#' the `RSM` / `PCM` branch.
#'
#' Consistent signals across multiple components are typically more robust than
#' a single isolated warning.  For example, an element flagged for both high
#' Outfit and high displacement is more concerning than one flagged on a
#' single criterion.
#'
#' `SE` is kept as a compatibility alias for `ModelSE`. `RealSE` is a
#' fit-adjusted companion defined as `ModelSE * sqrt(max(Infit, 1))`.
#' Reliability tables report model and fit-adjusted indices from observed
#' variance minus mean squared SE, truncated at zero. Fit-adjusted values are
#' not confidence bounds; `JML` entries remain exploratory. Separation, strata, and reliability follow the
#' Wright & Masters (1982) conventions:
#' \eqn{G = \mathrm{TrueSD}/\mathrm{RMSE}},
#' \eqn{R = G^2 / (1 + G^2)}, and \eqn{H = (4G + 1) / 3}.
#'
#' Tables record finite-estimate counts and the available SEs on those same
#' levels. Non-finite estimates are excluded from the spread and SE summaries.
#' If any finite estimate lacks a valid SE, reliability, separation, strata and
#' error-adjusted spread are unavailable, rather than combining different sets
#' of levels. Excluded levels or incomplete uncertainty prevent a facet summary
#' from supporting formal reporting. A facet containing fixed values also has
#' no aggregate reliability, separation or strata: a fixed anchor's zero
#' conditional variance is not evidence of perfect measurement. Fixing a group
#' mean alone does not fix each group member. For EAP Persons, this separation-based
#' index is distinct from posterior-variance EAP reliability. High rater
#' separation means distinguishable rater measures, not high rater agreement.
#'
#' Facet SEs from a regularized information matrix or an observation-table
#' fallback remain diagnostic approximations. They are labelled explicitly and
#' cannot authorize ordinary confidence-interval reporting. Numerical convergence
#' is reviewed separately from support for inference; switching from JML to MML
#' does not by itself establish valid SEs or intervals. Recompute older diagnostic
#' objects with `diagnose_mfrm(fit)` before reporting; the existing fit can be used
#' without refitting the model.
#'
#' @section Typical workflow:
#' 1. Start with `diagnose_mfrm(fit, diagnostic_mode = "both", residual_pca = "none")`.
#' 2. Inspect `summary(diag)` and use `diagnostic_basis` to separate legacy residual evidence from strict marginal evidence.
#' 3. If needed, rerun with residual PCA (`"overall"` or `"both"`).
#'
#' @return
#' An object of class `mfrm_diagnostics` including:
#' - `obs`: observed/expected/residual-level table
#' - `measures`: facet/person fit table (`Infit`, `Outfit`, `ZSTD`,
#'   `PTMEA`, `ModelSE`, `RealSE`, `CI_Lower`, `CI_Upper`, `CI_Level`,
#'   `CI_Method`). `Fixed = TRUE` identifies location values fixed by anchors
#'   or identification constraints. Their sampling SEs and normal intervals
#'   are `NA` (not estimated, not a numerical failure). Free levels retain
#'   their estimator-specific SEs. Aggregate reliability/separation and facet
#'   variability tests are unavailable for facets containing fixed values;
#'   response-fit diagnostics remain available. This convention differs from
#'   [mfrm_facet_intervals()], which represents a fixed target's conditional
#'   covariance as zero, also without an interval. Neither route propagates
#'   uncertainty in supplied anchor values.
#' - `overall_fit`: overall fit summary
#' - `fit`: element-level fit diagnostics
#' - `reliability`: facet-level model/real separation and reliability
#' - `precision_profile`: one-row summary of the active precision tier and its
#'   recommended use
#' - `precision_review`: package-native checks for SE, CI, and reliability
#' - `parameter_uncertainty`: MML observed-information uncertainty for
#'   structural parameters when available (`steps`, and `GPCM`
#'   `slopes` on both log and positive scales), plus covariance status metadata.
#'   Step `CIEligible` and `CIUse` retain the source fit's restrictions;
#'   non-unit observation-weight bands are diagnostic only. GPCM MML relative
#'   slopes use the separate [confint.mfrm_fit()] checks and pointwise log-Wald
#'   approximation; inspect `CIEligible`, `CIUse` and `InferenceReview`.
#' - `facet_precision`: facet-level precision summary by distribution basis and
#'   SE mode
#' - `facets_chisq`: fixed/random facet variability summary
#' - `interactions`: top interaction diagnostics
#' - `interrater`: inter-rater agreement bundle (`summary`, `pairs`) including
#'   agreement and rater-severity spread indices
#' - `unexpected`: unexpected-response bundle
#' - `fair_average`: adjusted-score reference bundle (reported as unavailable
#'   for `GPCM`)
#' - `displacement`: displacement diagnostics bundle
#' - `approximation_notes`: method notes for SE/CI/reliability summaries
#' - `diagnostic_basis`: guide to the statistical target of each diagnostic path
#' - `fit_standardization`: guide to the df convention behind fit ZSTD values
#' - `fit_readiness`, `fit_readiness_components`, and
#'   `fit_readiness_parameters`: the source fit's versioned readiness decision;
#'   diagnostic computation does not override global fit readiness. GPCM slope
#'   parameter rows additionally retain the output-specific interval decision
#' - `marginal_fit`: optional strict marginal-fit companion based on
#'   posterior-expected first-order category counts, with classification coverage
#' - `residual_pca_overall`: optional overall PCA object
#' - `residual_pca_by_facet`: optional facet PCA objects
#' - `replay_inputs`: diagnostic settings retained for reproducible export,
#'   including fit standardization, interaction selection, and PCA limits
#'
#' @seealso [fit_mfrm()], [analyze_residual_pca()], [build_visual_summaries()],
#'   [mfrmr_visual_diagnostics], [mfrmr_reporting_and_apa]
#' @examples
#' # Long-running workflow; run explicitly when needed.
#' # example("diagnose_mfrm", run.dontrun = TRUE)
#' \dontrun{
#' # Load the package and example ratings
#' library(mfrmr)
#' ratings <- load_mfrmr_data("example_operational")
#'
#' # Fit the model
#' fit <- fit_mfrm(
#'   data = ratings,
#'   person = "Person",
#'   facets = c("Rater", "Criterion"),
#'   score = "Score",
#'   rating_min = 1, rating_max = 4, category_policy = "preserve",
#'   method = "MML",
#'   model = "RSM"
#' )
#'
#' # Check model fit and the support for standard errors and intervals
#' diagnostics <- diagnose_mfrm(fit)
#' # Check each residual's basis and the coverage of aggregate fit statistics
#' head(diagnostics$obs[, c("PersonMeasureBasis", "ConditionalVariance",
#'   "PearsonAvailable", "ResponseReason")])
#' diagnostics$overall_fit[, c("Infit", "Outfit", "FitUnavailableRows", "FitReason")]
#' diagnostic_summary <- summary(diagnostics)
#' diagnostic_summary$decision
#'
#' diagnostic_summary$key_warnings # Issues to investigate, if present
#' diagnostic_summary$top_fit      # Most unusual residual-based fit statistics
#'
#' # Distinguish residual-based checks from marginal model checks
#' diagnostic_summary$diagnostic_basis[, c("DiagnosticPath", "Status", "Basis")]
#' }
#' @section References:
#' - Wright, B. D., & Masters, G. N. (1982). *Rating scale analysis*.
#'   MESA Press. (G/R/H separation, reliability, and strata
#'   formulas summarized in `s_diag$reliability` follow this
#'   convention.)
#' - Wright, B. D., & Linacre, J. M. (1994). Reasonable mean-square
#'   fit values. *Rasch Measurement Transactions, 8*(3), 370.
#'   (Source for the 0.5-1.5 Infit / Outfit heuristic review interval that
#'   `s_diag$key_warnings` and `misfit_thresholds` apply.)
#' - Linacre, J. M. (1989). *Many-Facet Rasch Measurement*. MESA
#'   Press. (FACETS Tables 6 + 7 correspond to the per-facet
#'   element measures, fit, and chi-square heterogeneity screen
#'   exposed via `s_diag$reliability` and `s_diag$facets_chisq`.)
#' - Bond, T. G., & Fox, C. M. (2015). *Applying the Rasch model:
#'   Fundamental measurement in the human sciences* (3rd ed.).
#'   Routledge. (Reference text for the Rasch-family fit
#'   conventions exposed by this helper.)
#' - Linacre, J. M. (2002). What do Infit and Outfit, Mean-square
#'   and Standardized mean? *Rasch Measurement Transactions,
#'   16*(2), 878.
#' - Linacre, J. M. (2026). *A user's guide to Facets Rasch-model computer
#'   programs*. Winsteps.com. (WHEXACT / FACETS standardized fit df notes.)
#' @export
#' @order 1
diagnose_mfrm <- function(fit,
                          interaction_pairs = NULL,
                          top_n_interactions = 20,
                          whexact = FALSE,
                          fit_df_method = "facets",
                          diagnostic_mode = c("both", "legacy", "marginal_fit"),
                          residual_pca = c("none", "overall", "facet", "both"),
                          pca_max_factors = 10L) {
  fit <- .mfrm_validate_diagnostic_fit(fit)
  fit_df_method <- match_fit_df_method(fit_df_method)
  diagnostic_mode <- match.arg(diagnostic_mode)
  residual_pca <- match.arg(tolower(residual_pca), c("none", "overall", "facet", "both"))

  out <- mfrm_diagnostics(
    fit,
    interaction_pairs = interaction_pairs,
    top_n_interactions = top_n_interactions,
    whexact = whexact,
    fit_df_method = fit_df_method,
    diagnostic_mode = diagnostic_mode,
    residual_pca = residual_pca,
    pca_max_factors = pca_max_factors
  )
  out$parameter_uncertainty$source <- mfrm_native_location_identity(fit)
  class(out) <- c("mfrm_diagnostics", class(out))
  out
}

mfrm_ic_contract_required_fields <- function() {
  c(
    "ICContractVersion", "N", "ResponseRows", "WeightedResponseTotal",
    "Persons", "Npar", "LogLik", "Deviance", "WeightPolicy",
    "ICEligible", "ICSelectable", "ICStatus", "ICSampleSize",
    "ICSampleSizeBasis",
    "AIC", "BIC", "SABIC", "SABICSelectable", "AICFormula",
    "BICFormula", "SABICFormula", "IntegrationEvaluationId",
    "ICQuadraturePoints", "ICIntegrationTier", "ICIntegrationStatus",
    "ICIntegrationSelectable"
  )
}

mfrm_ic_stored_value_matches <- function(actual,
                                         expected,
                                         tolerance = 1e-10) {
  if (length(actual) == 0L || length(expected) == 0L) return(FALSE)
  actual <- actual[1]
  expected <- expected[1]
  if (is.numeric(expected) || is.integer(expected)) {
    actual <- suppressWarnings(as.numeric(actual))
    expected <- suppressWarnings(as.numeric(expected))
    if (is.na(actual) && is.na(expected)) return(TRUE)
    if (!is.finite(actual) || !is.finite(expected)) {
      return(identical(actual, expected))
    }
    return(abs(actual - expected) <=
             tolerance * max(1, abs(expected)))
  }
  if (is.logical(expected)) {
    actual <- suppressWarnings(as.logical(actual))
    if (is.na(actual) && is.na(expected)) return(TRUE)
    return(identical(actual, expected))
  }
  actual <- as.character(actual)
  expected <- as.character(expected)
  if (is.na(actual) && is.na(expected)) return(TRUE)
  identical(actual, expected)
}

mfrm_extract_fit_ic_contract <- function(fit, tolerance = 1e-10) {
  summary_row <- as.data.frame(fit$summary %||% data.frame(),
                               stringsAsFactors = FALSE)
  if (nrow(summary_row) > 0L) summary_row <- summary_row[1, , drop = FALSE]
  config <- fit$config %||% list()
  prep <- fit$prep %||% list()
  method <- public_mfrm_method_label(toupper(as.character(
    config$method %||%
      if ("Method" %in% names(summary_row)) summary_row$Method[1] else NA_character_
  )[1]))
  model <- toupper(as.character(
    config$model %||%
      if ("Model" %in% names(summary_row)) summary_row$Model[1] else NA_character_
  )[1])
  current_contract <- nrow(summary_row) > 0L &&
    "ICContractVersion" %in% names(summary_row) &&
    identical(
      as.character(summary_row$ICContractVersion[1]),
      mfrm_ic_contract_version()
    )
  can_rebuild <- !is.null(fit$opt$value) && length(fit$opt$value) > 0L &&
    !is.null(fit$opt$par) && is.list(prep) && is.data.frame(prep$data)

  expected <- if (can_rebuild) {
    tryCatch(
      build_mfrm_ic_contract(
        loglik = -as.numeric(fit$opt$value[1]),
        npar = length(fit$opt$par),
        prep = prep,
        config = config,
        method = method
      ),
      error = function(e) NULL
    )
  } else {
    NULL
  }

  if (current_contract && !is.null(expected)) {
    required <- mfrm_ic_contract_required_fields()
    missing_fields <- setdiff(required, names(summary_row))
    comparable_fields <- intersect(required, names(expected))
    field_checks <- vapply(comparable_fields, function(field) {
      field %in% names(summary_row) && mfrm_ic_stored_value_matches(
        summary_row[[field]][1], expected[[field]], tolerance = tolerance
      )
    }, logical(1))
    stored_consistent <- length(missing_fields) == 0L && all(field_checks)
    mismatch <- c(missing_fields, names(field_checks)[!field_checks])
    contract_state <- if (stored_consistent) "current" else "current_inconsistent"
    values <- expected
  } else {
    stored_consistent <- NA
    mismatch <- if (current_contract) "contract_rebuild_unavailable" else
      "missing_current_contract"
    contract_state <- "legacy_or_unknown"
    response_rows <- if (is.data.frame(prep$data)) nrow(prep$data) else NA_integer_
    weighted_total <- if (is.data.frame(prep$data) && "Weight" %in% names(prep$data)) {
      legacy_weights <- suppressWarnings(as.numeric(prep$data$Weight))
      if (length(legacy_weights) > 0L && all(is.finite(legacy_weights))) {
        sum(legacy_weights)
      } else {
        NA_real_
      }
    } else {
      as.numeric(response_rows)
    }
    persons <- if (is.data.frame(prep$data) && "Person" %in% names(prep$data)) {
      person_values <- as.character(prep$data$Person)
      length(unique(person_values[!is.na(person_values)]))
    } else {
      suppressWarnings(as.integer(config$n_person %||% NA_integer_))
    }
    stored_loglik <- if ("LogLik" %in% names(summary_row)) {
      suppressWarnings(as.numeric(summary_row$LogLik[1]))
    } else if (!is.null(fit$opt$value)) {
      -suppressWarnings(as.numeric(fit$opt$value[1]))
    } else {
      NA_real_
    }
    stored_aic <- if ("LegacyAIC" %in% names(summary_row)) {
      suppressWarnings(as.numeric(summary_row$LegacyAIC[1]))
    } else if ("AIC" %in% names(summary_row)) {
      suppressWarnings(as.numeric(summary_row$AIC[1]))
    } else {
      NA_real_
    }
    stored_bic <- if ("LegacyBIC" %in% names(summary_row)) {
      suppressWarnings(as.numeric(summary_row$LegacyBIC[1]))
    } else if ("BIC" %in% names(summary_row)) {
      suppressWarnings(as.numeric(summary_row$BIC[1]))
    } else {
      NA_real_
    }
    legacy_n <- if ("N" %in% names(summary_row)) {
      suppressWarnings(as.numeric(summary_row$N[1]))
    } else {
      NA_real_
    }
    values <- list(
      ICContractVersion = "legacy_or_unknown",
      N = legacy_n,
      ResponseRows = as.integer(response_rows),
      WeightedResponseTotal = as.numeric(weighted_total),
      Persons = as.integer(persons),
      Npar = if (!is.null(fit$opt$par)) length(fit$opt$par) else NA_integer_,
      LogLik = stored_loglik,
      Deviance = if (is.finite(stored_loglik)) -2 * stored_loglik else NA_real_,
      WeightPolicy = if (is.data.frame(prep$data)) {
        mfrm_ic_weight_policy(prep, config)
      } else {
        "unknown"
      },
      ICEligible = FALSE,
      ICSelectable = FALSE,
      ICStatus = "suppressed_legacy_contract",
      ICSampleSize = NA_real_,
      ICSampleSizeBasis = "legacy_or_unknown",
      AIC = NA_real_,
      BIC = NA_real_,
      SABIC = NA_real_,
      SABICSelectable = FALSE,
      AICFormula = NA_character_,
      BICFormula = NA_character_,
      SABICFormula = NA_character_,
      IntegrationEvaluationId = mfrm_ic_integration_evaluation_id(method, config),
      ICQuadraturePoints = NA_integer_,
      ICIntegrationTier = "legacy_or_unknown",
      ICIntegrationStatus = "legacy_or_unknown",
      ICIntegrationSelectable = FALSE,
      LegacyAIC = stored_aic,
      LegacyBIC = stored_bic,
      LegacyICSampleSize = legacy_n,
      LegacyICSampleSizeBasis = if (!is.null(config$weight_col)) {
        "sum_weights"
      } else {
        "row_count"
      }
    )
  }

  tibble::tibble(
    Model = model,
    Method = method,
    nobs = values$ResponseRows,
    ResponseRows = values$ResponseRows,
    WeightedN = values$WeightedResponseTotal,
    WeightedResponseTotal = values$WeightedResponseTotal,
    Persons = values$Persons,
    ICSampleSize = values$ICSampleSize,
    ICSampleSizeBasis = values$ICSampleSizeBasis,
    Npar = values$Npar,
    npar = values$Npar,
    LogLik = values$LogLik,
    Deviance = values$Deviance,
    AIC = values$AIC,
    BIC = values$BIC,
    SABIC = values$SABIC,
    SABICSelectable = values$SABICSelectable,
    WeightPolicy = values$WeightPolicy,
    ICEligible = values$ICEligible,
    ICSelectable = values$ICSelectable,
    ICStatus = values$ICStatus,
    ICContractVersion = values$ICContractVersion,
    AICFormula = values$AICFormula,
    BICFormula = values$BICFormula,
    SABICFormula = values$SABICFormula,
    IntegrationEvaluationId = values$IntegrationEvaluationId,
    ICQuadraturePoints = values$ICQuadraturePoints,
    ICIntegrationTier = values$ICIntegrationTier,
    ICIntegrationStatus = values$ICIntegrationStatus,
    ICIntegrationSelectable = values$ICIntegrationSelectable,
    LegacyAIC = values$LegacyAIC,
    LegacyBIC = values$LegacyBIC,
    LegacyICSampleSize = values$LegacyICSampleSize,
    LegacyICSampleSizeBasis = values$LegacyICSampleSizeBasis,
    ICContractState = contract_state,
    StoredICConsistent = stored_consistent,
    StoredICMismatch = paste(unique(mismatch), collapse = ";")
  )
}

mfrm_ic_fit_check <- function(fit, contract, information = NULL, allow_singleton = FALSE) {
  readiness <- mfrmr_get_readiness_record(fit)$fit
  ordinary_ready <- mfrm_inference_ready(fit)
  out <- list(
    eligible = ordinary_ready,
    basis = "fit_inference_readiness",
    review = if (ordinary_ready) "" else as.character(mfrm_fit_decision_summary(readiness)$Why[1])
  )
  rasch_singleton <- isTRUE(allow_singleton) && fit$config$model %in% c("RSM", "PCM") &&
    identical(as.character(readiness$CategoryState[1]), "weak_information")
  if ((!identical(fit$config$model, "GPCM") &&
       !isTRUE(fit$config$population_spec$active) && !rasch_singleton) ||
      !identical(fit$config$method, "MML")) return(out)

  out$eligible <- FALSE
  out$basis <- "mml_local_solution_information"
  refuse <- function(reason) {
    out$review <- reason
    out
  }
  if (!isTRUE(contract$StoredICConsistent[1]) ||
      !isTRUE(contract$ICSelectable[1])) {
    return(refuse("Current, consistent MML likelihood metadata and a sufficiently resolved quadrature grid are required."))
  }
  identification <- mfrm_mml_inference_identification(fit)
  if (isTRUE(identification$excluded)) return(refuse(identification$detail))
  category_ready <- identical(as.character(readiness$CategoryState[1]), "adequate")
  singleton_review <- FALSE
  if (!category_ready && isTRUE(allow_singleton) &&
      fit$config$model %in% c("RSM", "PCM", "GPCM") &&
      identical(as.character(readiness$CategoryState[1]), "weak_information")) {
    # Count-based warnings do not replace a likelihood/information check.
    # GPCM retains its bootstrap-only exception; Rasch locations admit Wald
    # approximations after the separate full-information and quadrature review.
    audit <- tryCatch(audit_mfrm_category_support(fit$prep, fit$config,
      build_param_sizes(fit$config)), error = function(e) NULL)
    counts <- audit$category_table$WithinScopeCount
    local <- audit$local_support
    local_singleton <- rasch_singleton && is.data.frame(local) && nrow(local) > 0L &&
      all(local$MissingCategories == "") && any(local$MinimumObservedCategoryCount == 1L)
    singleton_review <- isTRUE(audit$readiness$Complete) &&
      identical(audit$readiness$CategoryState, "weak_information") &&
      identical(audit$readiness$ReasonCodes, "weak_category_information") &&
      isTRUE(audit$readiness$UnsupportedStepCoordinates == 0L) &&
      isTRUE(audit$readiness$UnsupportedCategoryContrasts == 0L) &&
      length(counts) > 0L && all(is.finite(counts)) &&
      all(counts > 0L) && (any(counts == 1L) || local_singleton)
    if (rasch_singleton) singleton_review <- singleton_review &&
      is.data.frame(local) && nrow(local) > 0L && all(local$MissingCategories == "")
  }
  if (!identical(as.character(readiness$InputState[1]), "pass") ||
      !(category_ready || singleton_review)) {
    return(refuse("Input or category support requires review before MML inference."))
  }
  if (!identical(as.character(readiness$NumericalState[1]), "ready") ||
      !identical(fit$opt$optimizer_diagnostics$ConvergenceSeverity, "pass")) {
    return(refuse("The MML optimizer has not passed the numerical convergence checks."))
  }
  gradient_tolerance <- as.numeric(fit$opt$optimizer_diagnostics$GradientReviewTolerance)
  if (length(gradient_tolerance) != 1L || !is.finite(gradient_tolerance) ||
      gradient_tolerance <= 0 || gradient_tolerance > 1e-4) gradient_tolerance <- 1e-4
  # Reevaluate the retained solution; a saved positive-curvature label must
  # not authorize comparison after the data or parameter vector has changed.
  information <- information %||% tryCatch({
    covariance <- compute_mml_parameter_covariance(fit,
      solution_tolerance = gradient_tolerance)
    covariance$solution_information %||% list(status = "unavailable", detail = covariance$detail)
  }, error = function(e) list(status = "unavailable", detail = conditionMessage(e)))
  if (identical(information$status, "rejected_local_solution")) {
    return(refuse(information$detail))
  }
  if (!identical(information$status, "evaluated_diagnostic_only")) {
    return(refuse(paste("MML solution information is unavailable:", information$detail)))
  }
  evaluation <- information$evaluation_summary
  eigenvalues <- information$eigenvalue_summary
  objective <- fit$opt$value
  reevaluated <- evaluation$ReevaluatedObjective
  gradient <- evaluation$GradientMaxAbs
  smallest <- eigenvalues$Smallest
  scale <- eigenvalues$AbsoluteScale
  scalars <- list(objective, reevaluated, gradient, smallest, scale, information$free_dimension)
  if (!all(vapply(scalars, function(x) is.numeric(x) && !is.complex(x) &&
      length(x) == 1L && is.finite(x), logical(1))) ||
      length(fit$opt$par) != information$free_dimension || gradient < 0 || smallest > scale) {
    return(refuse("Finite, dimensionally consistent likelihood, gradient and information are required."))
  }
  if (abs(reevaluated - objective) > 1e-10 * max(1, abs(objective))) {
    return(refuse("The retained objective does not match reevaluation at the supplied data and parameters."))
  }
  if (gradient > gradient_tolerance) {
    return(refuse("The reevaluated MML gradient exceeds the numerical convergence tolerance."))
  }
  # Weak raw-coordinate conditioning alone need not reject a freshly verified,
  # unregularized inverse. Indefinite/zero curvature still cannot be admitted.
  inverse_review <- information$inverse_review
  refined <- isTRUE(inverse_review$Verified) &&
    all(c("RelativeChange", "InverseResidual", "CurvatureScaledGradient") %in% names(inverse_review)) &&
    all(vapply(inverse_review[c("RelativeChange", "InverseResidual", "CurvatureScaledGradient")],
               length, integer(1)) == 1L) &&
    all(is.finite(c(inverse_review$RelativeChange, inverse_review$InverseResidual,
                    inverse_review$CurvatureScaledGradient))) &&
    min(inverse_review$RelativeChange, inverse_review$InverseResidual,
        inverse_review$CurvatureScaledGradient) >= 0 &&
    inverse_review$RelativeChange <= 1e-3 && inverse_review$InverseResidual <= 1e-6 &&
    inverse_review$CurvatureScaledGradient <= 1e-4
  if (!is.null(inverse_review) && !isTRUE(refined)) {
    return(refuse(inverse_review$Detail %||% "Information refinement did not pass."))
  }
  if (scale <= 0 || smallest <= 0 ||
      (smallest <= scale * sqrt(.Machine$double.eps) && !refined)) {
    return(refuse("MML information is singular, indefinite or too ill-conditioned for ordinary inference."))
  }
  out$eligible <- TRUE
  if (refined) out$caution <- inverse_review$Detail
  if (singleton_review) out$caution <- trimws(paste(out$caution %||% "",
    if (rasch_singleton)
      "Some score categories occur only once within a fitted or local scope. Model-information intervals remain asymptotic approximations; small samples can affect bias and coverage. The source fit retains its category-support review."
    else paste("Singleton score categories: the point estimate is retained for the basic bootstrap",
      "after numerical and information checks. Sparse category support may affect accuracy;",
      "this does not establish Wald-interval eligibility.")))
  out$review <- paste(
    "The retained MML solution has matching likelihood, a small gradient and",
    "positive unregularized local information. Check starting-value and",
    "integration sensitivity when comparing close criteria; this is not a",
    "global-maximum certificate or permission for slope intervals or an LRT.", out$caution %||% ""
  )
  out
}

#' Compare two or more fitted MFRM models
#'
#' Produce a side-by-side comparison of multiple [fit_mfrm()] results using
#' AIC, Person-based BIC, Sclove SABIC, log-likelihood, and free-parameter
#' counts. An ordinary RSM paired with a testlet or shared-rater fit instead
#' follows a descriptive facet-effect route, with no automatic ranking.
#' For ordinary models, when exactly
#' two models are supplied and the current conservative nesting review passes,
#' a likelihood-ratio test is included.
#'
#' GPCM MML and RSM/PCM MML with an estimated normal population use a separate
#' local-solution check for information criteria, without refitting. It checks
#' the retained likelihood, terminal gradient and positive unregularized
#' observed information. `ICFitEligible`, `ICFitBasis` and `ICFitReview` record
#' that decision; `ICComparable` also requires the common data/likelihood and
#' integration checks. This can allow IC comparison while `InferenceReady`
#' remains false for intervals or tests. It shares the joint-information
#' calculation and workspace budget with [confint.mfrm_fit()]. Unknown, unstable or unavailable results
#' remain ineligible with a reason. A local check does not prove a global
#' maximum or negligible integration error; examine starting-value and
#' [mml_quadrature_sensitivity()] results when the decision is close.
#' Known marginal response-dimension deficits and complete-pattern first-order
#' rank failures also prevent inferential model comparison, even with a positive
#' numerical Hessian. More Persons with the same response designs improve
#' precision but cannot repair a structural dimension deficit.
#' Positive but ill-conditioned information may pass with a caution after
#' numerical refinement, unregularized inversion and curvature-scaled gradient
#' checks. A warning is emitted and retained in `ICFitCaution`, `ICFitReview`
#' and the requested LRT's interpretation; it does not establish
#' finite-sample accuracy for model ranking or tests.
#' @param ... For `compare_mfrm()`: Two or more `mfrm_fit` objects, or exactly one ordinary
#'   `mfrm_fit` and one [fit_mfrm_testlet()] or [fit_mfrm_random_rater()] result.
#'   The latter route is descriptive; see the extended-model section.
#'
#' For `plot()`: Unused.
#' @param object An extended-model comparison returned by `compare_mfrm()`.
#' @param labels Optional character vector of labels for each model.
#'   If `NULL`, labels are generated from model/method combinations.
#' @param warn_constraints Logical. If `TRUE` (the default), emit a warning
#'   when models use different score coding or constraint settings. Ranking is
#'   suppressed whenever this basis differs, regardless of whether the warning
#'   is displayed.
#' @param nested Logical. Set to `TRUE` only when the supplied models are
#'   known to be nested and fitted with the same likelihood basis on the same
#'   observations. The default is `FALSE`, in which case no likelihood-ratio
#'   test is reported. When `TRUE`, the function still runs a conservative
#'   structural nesting review and computes the LRT only for supported nesting patterns.
#' @param response_diagnostics Optional list of two saved
#'   [mfrm_response_diagnostics()] outputs in the same order as the fits.
#'   Supported for an ordinary RSM paired with a testlet or shared-rater fit.
#'   This adds descriptive predictive comparisons without computing integrals.
#' @param person_scores Optional list of two saved [score_mfrm_persons()]
#'   results in fit order for an ordinary versus extended RSM comparison.
#'   Both must score the same complete source roster, return the same Person
#'   IDs and use the same conditional interval level. No scoring is run here.
#' @details Models should be fit to the **same data** (same rows, same person/facet
#' columns) for the comparison to be meaningful. The function checks that
#' observation counts match and warns otherwise.
#'
#' Information-criterion ranking is reported only when all candidates are
#' eligible solutions under the package's current `MML` contract, use the same
#' prepared observations, score coding, constraints, formula contract, and
#' integration-evaluation identity, are eligible under the weighting policy,
#' and have a selectable integration tier. For fixed-facet MML,
#' `ICSampleSize` is the number of independent
#' Persons and `ICSampleSizeBasis` is `"person_count"`; response rows and their
#' weighted total are retained separately. Explicit all-unit weights are
#' eligible, whereas every non-unit observation-weight fit fails closed under
#' the current package contract.
#'
#' Canonical `AIC`, `BIC`, and `SABIC` are recomputed from the retained
#' objective, optimizer-vector dimension, and Person count. A stale stored
#' value, a legacy object without the current contract identity, a JML fit, or
#' an ineligible weighted fit cannot enter ranking. Earlier raw values may be
#' shown only as explicitly labelled `LegacyAIC` and `LegacyBIC` fields.
#'
#' **Integration selection guard**: raw canonical criteria are retained at
#' every valid MML quadrature count, but automatic comparison is screening-only
#' below 15 points and review-only at 15--30 points. `ICSelectable` and
#' `ICIntegrationSelectable` become `TRUE` at q>=31. q=31 is a starting grid,
#' not a universal guarantee: close or consequential comparisons should be
#' reevaluated at a denser shared grid (normally q>=61). The guard also applies
#' to `nested = TRUE`, so a coarse-grid LRT cannot bypass it.
#'
#' **Nesting**: Two models are *nested* when one is a special case of the
#' other obtained by imposing equality constraints.  The most common
#' nesting in MFRM is RSM (shared thresholds) inside PCM
#' (item-specific thresholds).  Models that differ only in estimation
#' method (MML vs JML) on the same specification are not nested in the
#' usual sense, and their information criteria do not share the common MML
#' contract. Do not use either the LRT or IC ranking as a direct cross-method
#' comparison.
#'
#' In the **current `mfrmr` model space**, the automatic nesting review is
#' intentionally conservative. It currently supports the following
#' restrictions under shared data and shared constraints:
#' - `RSM` nested inside `PCM` when the `PCM` fit has an explicit
#'   `step_facet` and retains every `facet_interactions` term in the RSM.
#'   The PCM may add interaction terms; omitting an RSM interaction is not
#'   repaired by freeing category steps;
#' - `PCM` nested inside `GPCM` with the same step facet, population
#'   design, other facet/step constraints and interactions. The only additional
#'   parameters must be G-1 relative log-slope contrasts for G slope levels.
#'   The GPCM slope owner may differ from the shared step owner;
#' - same-family additive-vs-interaction comparisons when the smaller fit's
#'   `facet_interactions` set is a subset of the larger fit's set.
#'
#' Cross-method comparisons, comparisons that change anchors/dummying/centering,
#' and same-family comparisons that do not add fixed interaction terms are not
#' automatically promoted to LRT claims.
#'
#' Automatic nesting also requires a shared population specification: either
#' both fits use the fixed standard-normal population or both use the same
#' estimated-normal design, with the same declared columns and design values
#' aligned by Person. Coefficient and variance estimates may differ. Row and
#' column permutations are aligned; other recodings, changed designs, and
#' unavailable design metadata require separate review. Passing this check
#' does not grant inference readiness to an estimated-population fit. For a
#' matched PCM/GPCM pair, the local-solution checks described above supply
#' the numerical requirement independently of slope-interval availability.
#'
#' The **likelihood-ratio test (LRT)** is reported only when exactly two
#' models are supplied, `nested = TRUE`, the structural nesting review passes, and the
#' difference in the number of parameters is positive:
#'
#' \deqn{\Lambda = -2 (\ell_{\mathrm{restricted}} - \ell_{\mathrm{full}})
#'   \sim \chi^2_{\Delta p}}
#'
#' The LRT is asymptotically valid only under its regularity assumptions.
#' With small samples or boundary/singular conditions, the reference
#' chi-square p-value can be incorrect. At large Person counts, a very small
#' practical improvement can also become statistically significant. Read the
#' p-value as formal nested-fit evidence, not as an automatic practical model
#' preference or evidence that a subscore is useful.
#' @section Ordinary versus extended RSMs:
#' Exactly one ordinary RSM MML fit and one testlet/shared-rater fit return an
#' `mfrm_extended_comparison`, with `models`, `checks`, `effects` and `notes`.
#' The information-criterion and LRT sections describe ordinary `mfrm_fit`
#' comparisons only. This route does not rank models, compute difference
#' intervals, or provide an AIC/BIC preference. `nested = TRUE` is refused.
#'
#' Both fits must use identical observed rating events, including repeated
#' events, category coding, unit weights and fixed facets except for the
#' deliberately changed rater treatment. Use unanchored additive severity
#' facets, `noncenter_facet = "Person"`, no facet shrinkage, and matching
#' person/score column roles. Category recoding must preserve the same
#' consecutive adjacent-category scale. These checks cannot be disabled by
#' `warn_constraints = FALSE`.
#'
#' Match the population assumption: ordinary `population_formula = ~1` with
#' both extension defaults estimates a common normal ability SD; the ordinary
#' default and extension `person_sd = 1` impose known N(0,1). Covariate-dependent
#' populations and fixed nonunit SDs have no matching ordinary route here.
#' Population intercepts and free step locations may use different origins;
#' they are recorded, not compared as substantive mean differences.
#'
#' The source roster and omitted counts must agree. New ordinary fits retain
#' `prep$omitted_data` and `prep$omitted_input_rows`. When scores were omitted,
#' their identities must match, including repeated events. Older fits without
#' this provenance require refitting from the complete assigned-score roster.
#' Missing IDs, excluded weights and population-data omissions are unsupported.
#'
#' Effects are centered at the unweighted mean of the same complete set of
#' levels within each facet. This preserves pairwise contrasts while removing
#' arbitrary facet origins. `SourceReference`/`SourceComparison` retain raw
#' values and `CenterReference`/`CenterComparison` retain the subtracted means.
#' `Difference` is comparison minus reference. Conditional rater modes and
#' fixed coefficients are labeled separately; shrinkage is not evidence of
#' greater accuracy or rater quality. Failed numerical checks or a missing
#' level estimate withhold affected differences without dropping source rows.
#' Native inference readiness remains explicit even when descriptive numerical
#' checks pass. No SE or confidence interval for model differences is implied.
#'
#' With `response_diagnostics`, `responses` retains matched category
#' probabilities, means, full mixture variances and grouped descriptive
#' Infit/Outfit. Both saved diagnostics must use the same probability target,
#' selected event multiset and shared `group_by` identifier columns. Matching
#' uses event contents, including repeated-event multiplicities and missing
#' scores, rather than assuming row numbers agree. Identical repeated events
#' match in source occurrence order. `responses$events` and `responses$rows`
#' retain the matching and original row numbers. Missing or unavailable rows
#' remain explicit and differences involving them are withheld.
#'
#' All observed source events condition each model; selecting a Person's rows
#' does not remove other Persons from shared-rater inference. These are
#' same-data descriptive comparisons with calibration held fixed, not
#' held-out predictive performance. A smaller Infit/Outfit is not evidence
#' of improvement. Do not substitute ordinary plug-in diagnostics or their
#' reference cutoffs. See [plot.mfrm_extended_comparison()] for predictive
#' paired and difference displays.
#'
#' With `person_scores`, `persons$table` compares conditional EAPs after
#' subtracting each fitted population mean, retaining original estimates,
#' origins, posterior SDs and aligned conditional endpoints. Unit Rasch slopes
#' retain the logit unit; centering removes the arbitrary origin, not shrinkage
#' or changes in the assumed population variance. Prior-only and unavailable
#' differences are withheld. Separate conditional intervals are not intervals
#' for model differences or tests of Person differences. Use `metric = "person"`
#' in [plot.mfrm_extended_comparison()] for a paired/difference display.
#'
#' The default facet-only output does not compare Person scores, steps,
#' predictive Infit/Outfit or replacement-rater predictions. For testlets, zero local
#' variance retains the fixed facets; zero shared-rater variance removes rater
#' differences and is not the fixed-rater model. Numerical zero-reduction
#' agreement does not establish model adequacy or variance-boundary inference.
#'
#' Use `plot(comparison, style = "paired")` for matched effects, or
#' `style = "difference"` for differences versus means. See
#' [plot.mfrm_extended_comparison()] for display and accessibility controls.
#' Attach saved results with `mfrm_results(extended_fit, comparison = comparison)`
#' for static reports, tables, figures and replay. No comparison/report step
#' fits, scores or resamples either model.
#' @section Information-criterion diagnostics:
#' In addition to the canonical criteria, the function computes:
#' - **Delta_AIC / Delta_BIC / Delta_SABIC**: difference from the minimum
#'   value in the supplied candidate set.
#'   For AIC, the often-used Delta ranges below 2, 4--7, and above 10 are
#'   rough descriptions of decreasing relative support (Burnham & Anderson,
#'   2002), not significance thresholds, adequacy checks, or universal rules
#'   for BIC and SABIC.
#' - **AkaikeWeight / BICWeight / SABICWeight**: relative candidate-set
#'   weights derived from `exp(-0.5 * Delta)` and normalized only across the
#'   supplied models. They are not posterior probabilities, probabilities of
#'   model truth, or guarantees that the candidate set is adequate.
#' - **Evidence ratios**: pairwise ratios of Akaike weights, quantifying
#'   relative support within this candidate set. A ratio of 5 means only that
#'   one normalized Akaike weight is five times the other; it does not mean
#'   that one model is five times more likely to be true.
#'   Ratios are computed from AIC differences, so they remain available when
#'   both normalized weights round to zero. `LogEvidenceRatio` retains the
#'   natural log ratio; `RatioReason` explains `NA` ratios outside numeric range
#'   (`"overflow"`, `"underflow"`, or `"nonfinite_difference"`, otherwise
#'   `"available"`).
#'
#' AIC, BIC, and SABIC answer different approximation/penalty questions. SABIC
#' is a sensitivity criterion, not a universal tie-breaker. At 22 or fewer
#' Persons its Sclove penalty is non-positive, so `SABICSelectable` and
#' `SABICComparable` are `FALSE` and no automatic SABIC preference is returned.
#' @section What this comparison means:
#' `compare_mfrm()` is a same-basis model-comparison helper. Its strongest
#' claims apply only when the models were fit to the same response data,
#' under a compatible likelihood basis, and with compatible constraint
#' structure.
#' @section What this comparison does not justify:
#' - Do not treat AIC/BIC/SABIC differences as primary evidence when
#'   `table$ICComparable` is `FALSE`.
#' - Do not infer numerical adequacy merely because all models share the same
#'   coarse quadrature identity. Below q=31, raw criteria are diagnostic only
#'   and automatic deltas, weights, preferences, and LRT are suppressed.
#' - Do not interpret the LRT unless `nested = TRUE` and the structural nesting review
#'   in `comparison_basis$nesting_review` passes.
#' - Same-family additive-vs-interaction fits are considered nested only when
#'   all other structural settings match and the smaller model's
#'   `facet_interactions` set is a subset of the larger model's set.
#' - Do not assume that `nested = TRUE` overrides the package's conservative
#'   nesting boundary; unsupported relations remain unsupported.
#' - PCM is the unit-slope reduction of an aligned GPCM. `nested = TRUE` tests
#'   equal relative slopes only after population, constraint, free-dimension
#'   and numerical checks pass. The relation is recorded as `PCM_in_GPCM`.
#'   Default PCM uses a fixed standard-normal population, whereas default GPCM
#'   estimates its mean and variance: changing only `model` does not isolate
#'   slope differences. Supply `population_formula = ~1` and the same
#'   `person_data` to both fits for an estimated-normal comparison.
#'   Unit slopes are interior positive values; the reference is ordinary
#'   asymptotic chi-square with G-1 degrees of freedom, not a boundary mixture.
#'   IC eligibility alone does not establish nesting or qualify slope intervals.
#' - Do not compare models fit to different datasets, different score codings,
#'   or materially different constraint systems as if they were commensurate.
#' - At large Person counts, a small systematic likelihood gain can dominate an
#'   IC difference; boundary or singular fits can also invalidate routine
#'   asymptotics. Evaluate effect size, stability, interpretability, and score
#'   consequences separately.
#' @section Interpreting output:
#' - Lower AIC/BIC values indicate relative support only when
#'   `table$ICComparable` is `TRUE`; use SABIC ranking only when
#'   `table$SABICComparable` is also `TRUE`.
#' - A significant LRT p-value is formal evidence against the restricted
#'   model under the stated assumptions; practical gain, score utility, and
#'   dimensional interpretation require separate checks.
#' - `preferred` identifies the minimum criterion within the supplied
#'   candidate set; it is not an unconditional model verdict.
#' - `evidence_ratios` gives pairwise Akaike-weight ratios (returned only
#'   when Akaike weights can be computed for at least two models).
#' - When comparing more than two models, interpret evidence ratios
#'   cautiously---they do not adjust for multiple comparisons.
#' @section How to read the main outputs:
#' - `table`: first-pass comparison table; start with `ICComparable`,
#'   `ICSelectable`, `ICIntegrationTier`, `Model`, `Method`, `ICStatus`, `AIC`,
#'   `BIC`, and `SABIC`.
#' - `comparison_basis`: records whether IC and LRT claims are defensible for
#'   the supplied models. Inspect `comparison_basis$nesting_review$relation`
#'   and `reason` before reading any LRT output.
#' - `lrt`: nested-model test summary, present only when the requested and
#'   reviewed conditions are met.
#' - `preferred`: candidate preferred by each criterion when those summaries
#'   are available.
#' @section Recommended next step:
#' Inspect `comparison_basis` before writing conclusions. If comparability is
#' weak, treat the result as descriptive and revise the model setup (for
#' example, explicit `step_facet`, common data, or common constraints) before
#' using IC or LRT results in reporting.
#' @section Typical workflow:
#' 1. Fit two models with [fit_mfrm()] (e.g., PCM and GPCM) on the
#'    same prepared rows, explicit step owner, constraints, and MML quadrature
#'    setting. Use at least 31 common quadrature points for selectable ICs.
#' 2. Compare with `compare_mfrm(fit_pcm, fit_gpcm)` and start by checking
#'    `comparison$table$ICComparable`.
#' 3. Inspect `summary(comparison)` for AIC/BIC/SABIC diagnostics and the reasons
#'    for withholding ranking or tests. GPCM IC ranking has separate solution
#'    checks; request the matched PCM/GPCM test with `nested = TRUE`.
#' 4. Use `build_weighting_review(fit_pcm, fit_gpcm)` to inspect which selected
#'    facet levels and information shares were reweighted by the slopes.
#' @return With one extended model, an `mfrm_extended_comparison` containing `models`,
#' `checks`, centered `effects`, `notes`, and source/omission metadata.
#' With ordinary models only, an object of class `mfrm_comparison` (named list) with:
#' - `table`: data.frame of model-level statistics including `LogLik`,
#'   `Deviance`, `Npar` (and equal compatibility alias `npar`), `AIC`, `BIC`,
#'   `SABIC`, criterion deltas and candidate-set weights, `ResponseRows`,
#'   `WeightedResponseTotal`, `Persons`, `ICSampleSize`, formula and integration
#'   identities, integration tier/selectability, stored-value consistency
#'   fields, convergence fields,
#'   `ICComparable`, `SABICComparable`, and `ConstraintComparable`.
#' - `lrt`: data.frame with likelihood-ratio test result (only when two models
#'   are supplied and `nested = TRUE`). Contains `ChiSq`, `df`, `p_value`.
#' - `evidence_ratios`: data.frame of pairwise Akaike-weight ratios (Model1,
#'   Model2, EvidenceRatio, LogEvidenceRatio, RatioReason). `NULL` when
#'   comparison is ineligible. Extremely small normalized weights can round to zero.
#' - `preferred`: named list with the preferred model label by each criterion.
#' - `comparison_basis`: list describing whether IC and LRT comparisons were
#'   considered comparable. Includes a conservative `nesting_review` plus
#'   `lrt_status` / `lrt_reason` so withheld LRTs are explicit rather than
#'   silently absent.
#' @seealso [fit_mfrm()], [diagnose_mfrm()]
#' @examples # Supplementary workflow: run explicitly to keep routine checks brief.
#' # example("compare_mfrm", run.dontrun = TRUE)
#' \dontrun{
#' # Load one dataset for both models
#' library(mfrmr)
#' toy <- load_mfrmr_data("example_operational")
#'
#' # RSM: shared category thresholds
#' fit_rsm <- fit_mfrm(
#'   data = toy,
#'   person = "Person",
#'   facets = c("Rater", "Criterion"),
#'   score = "Score",
#'   method = "MML",
#'   model = "RSM"
#' )
#'
#' # PCM: separate category thresholds for each criterion
#' fit_pcm <- fit_mfrm(
#'   data = toy,
#'   person = "Person",
#'   facets = c("Rater", "Criterion"),
#'   score = "Score",
#'   method = "MML",
#'   model = "PCM",
#'   step_facet = "Criterion"
#' )
#'
#' # Check that the fitted models can be compared
#' comparison <- compare_mfrm(fit_rsm, fit_pcm, labels = c("RSM", "PCM"))
#' comparison$table[, c("Label", "Converged", "ICComparable", "ICSelectable")]
#'
#' # Smaller AIC/BIC indicates better relative support among these models
#' comparison$table[, c("Label", "AIC", "Delta_AIC", "BIC", "Delta_BIC")]
#' # Delta is the difference from the lowest value of that criterion
#' # For close or consequential comparisons, check a denser shared grid with
#' # mml_quadrature_sensitivity() before choosing a model
#' # For a PCM/GPCM equal-slope test, see the matched-population example in
#' # https://ryuya-dot-com.github.io/mfrmr/dev/articles/mfrmr-gpcm-scope.html; request compare_mfrm(..., nested = TRUE).
#' }
#' @section References:
#' - Burnham, K. P., & Anderson, D. R. (2002). *Model selection and
#'   multimodel inference: A practical information-theoretic
#'   approach* (2nd ed.). Springer.
#' - Akaike, H. (1974). A new look at the statistical model
#'   identification. *IEEE Transactions on Automatic Control,
#'   19*(6), 716-723.
#' - Schwarz, G. (1978). Estimating the dimension of a model.
#'   *Annals of Statistics, 6*(2), 461-464.
#' - Sclove, S. L. (1987). Application of model-selection criteria to some
#'   problems in multivariate analysis. *Psychometrika, 52*(3), 333-343.
#' @export
#' @order 1
compare_mfrm <- function(..., labels = NULL, warn_constraints = TRUE, nested = FALSE,
    response_diagnostics = NULL, person_scores = NULL) {
  if (!is.logical(nested) || length(nested) != 1L || is.na(nested)) {
    stop("`nested` must be a single logical value (TRUE or FALSE).", call. = FALSE)
  }
  fits <- list(...)
  for (fit in fits) stop_if_product_slopes(fit, "compare_mfrm()")
  if (any(vapply(fits, mfrm_extended_fit, logical(1)))) return(mfrm_compare_extended(fits, labels, nested, response_diagnostics, person_scores))
  if (!is.null(response_diagnostics) || !is.null(person_scores)) stop("Predictive or Person comparison currently requires one ordinary RSM MML and one testlet/shared-rater fit.", call. = FALSE)
  if (length(fits) < 2) {
    stop("`compare_mfrm()` requires at least two `mfrm_fit` objects.",
         call. = FALSE)
  }
  for (i in seq_along(fits)) {
    if (!inherits(fits[[i]], "mfrm_fit")) {
      stop("Argument ", i, " is not an `mfrm_fit` object. Got: ",
           class(fits[[i]])[1], ".", call. = FALSE)
    }
  }

  # -- build labels --
  if (is.null(labels)) {
    labels <- vapply(fits, function(f) {
      m <- if (!is.null(f$config$model)) toupper(f$config$model[1]) else "?"
      e <- if (!is.null(f$config$method)) toupper(f$config$method[1]) else "?"
      paste0(m, "/", e)
    }, character(1))
    if (anyDuplicated(labels)) {
      labels <- paste0(labels, " (", seq_along(labels), ")")
    }
  }
  if (length(labels) != length(fits)) {
    stop("`labels` must have the same length as the number of models (",
         length(fits), ").", call. = FALSE)
  }

  normalize_compare_col <- function(col) {
    if (is.factor(col)) return(as.character(col))
    if (inherits(col, "POSIXt")) return(format(col, tz = "UTC", usetz = TRUE))
    if (is.numeric(col)) return(format(col, digits = 17, trim = TRUE, scientific = FALSE))
    if (is.logical(col)) return(ifelse(is.na(col), "NA", ifelse(col, "TRUE", "FALSE")))
    if (is.character(col)) return(col)
    as.character(col)
  }

  canonicalize_compare_data <- function(dat) {
    if (is.null(dat) || !is.data.frame(dat)) return(NULL)
    dat <- as.data.frame(dat, stringsAsFactors = FALSE)
    dat <- dat[, sort(names(dat)), drop = FALSE]
    dat[] <- lapply(dat, normalize_compare_col)
    if (nrow(dat) > 0 && ncol(dat) > 0) {
      ord <- do.call(order, c(dat, list(na.last = TRUE, method = "radix")))
      dat <- dat[ord, , drop = FALSE]
    }
    rownames(dat) <- NULL
    dat
  }

  compare_data_equal <- function(fit_a, fit_b) {
    dat_a <- canonicalize_compare_data(fit_a$prep$data %||% NULL)
    dat_b <- canonicalize_compare_data(fit_b$prep$data %||% NULL)
    if (is.null(dat_a) || is.null(dat_b)) return(FALSE)
    identical(dat_a, dat_b)
  }

  # -- constraint and score-coding compatibility check --
  comparison_signatures <- lapply(fits, normalize_compare_signature)
  constraint_component_names <- c(
    "person", "facets", "score", "rating_min", "rating_max", "score_map",
    "noncenter_facet", "dummy_facets", "positive_facets", "anchors",
    "group_anchors", "centering_scope"
  )
  constraint_components <- vapply(constraint_component_names, function(nm) {
    all(vapply(comparison_signatures[-1], function(sig) {
      same_signature_component(comparison_signatures[[1]][[nm]], sig[[nm]])
    }, logical(1)))
  }, logical(1))
  same_constraint_basis <- all(constraint_components)

  if (isTRUE(warn_constraints) && !same_constraint_basis) {
    mismatch <- names(constraint_components)[!constraint_components]
    if ("noncenter_facet" %in% mismatch) {
      noncenter <- vapply(comparison_signatures, function(sig) {
        as.character(sig$noncenter_facet[1])
      }, character(1))
      warning(
        "Models use different centering constraints (",
        paste(unique(noncenter), collapse = ", "),
        "). Information-criterion ranking is suppressed.",
        call. = FALSE
      )
    }
    if ("dummy_facets" %in% mismatch) {
      dummy_sigs <- vapply(comparison_signatures, function(sig) {
        paste(sig$dummy_facets, collapse = ",")
      }, character(1))
      warning(
        "Models use different dummy-facet constraints (",
        paste(unique(dummy_sigs), collapse = " vs "),
        "). Information-criterion ranking is suppressed.",
        call. = FALSE
      )
    }
    other_mismatch <- setdiff(mismatch, c("noncenter_facet", "dummy_facets"))
    if (length(other_mismatch) > 0L) {
      warning(
        "Models differ in likelihood-basis coding or constraint settings: ",
        paste(other_mismatch, collapse = ", "),
        ". Information-criterion ranking is suppressed.",
        call. = FALSE
      )
    }
  }

  # -- extract summary statistics --
  rows <- lapply(seq_along(fits), function(i) {
    f <- fits[[i]]
    convergence <- mfrm_convergence_state(f)
    contract <- mfrm_extract_fit_ic_contract(f)
    ic_fit <- mfrm_ic_fit_check(f, contract)
    readiness <- mfrmr_get_readiness_record(f)$fit
    tibble::add_column(
      contract,
      Label = labels[i],
      Converged = convergence$code_converged,
      InferenceReady = convergence$inference_ready,
      ICFitEligible = ic_fit$eligible,
      ICFitBasis = ic_fit$basis,
      ICFitReview = ic_fit$review,
      ICFitCaution = ic_fit$caution %||% "",
      InferenceReview = if (convergence$inference_ready) "" else
        as.character(mfrm_fit_decision_summary(readiness)$Why[1]),
      ReadinessReasonCodes = as.character(readiness$ReasonCodes[1]),
      ConvergenceSeverity = convergence$severity,
      .before = 1L
    )
  })
  tbl <- bind_rows(rows)
  ic_cautions <- unique(tbl$ICFitCaution[nzchar(tbl$ICFitCaution)])
  if (length(ic_cautions)) warning(paste(ic_cautions, collapse = " "), call. = FALSE)

  method_vals <- tbl$Method[!is.na(tbl$Method)]
  same_method <- length(unique(method_vals)) <= 1
  all_mml <- length(method_vals) > 0 && all(method_vals == "MML")
  obs_vals <- tbl$nobs[is.finite(tbl$nobs)]
  same_nobs <- length(unique(obs_vals)) <= 1
  same_data <- if (length(fits) >= 2) {
    all(vapply(fits[-1], function(f) compare_data_equal(fits[[1]], f), logical(1)))
  } else {
    TRUE
  }
  conv_vals <- tbl$InferenceReady
  all_converged <- length(conv_vals) > 0 && all(!is.na(conv_vals) & as.logical(conv_vals))
  all_ic_fit_eligible <- nrow(tbl) > 0L && all(!is.na(tbl$ICFitEligible) & tbl$ICFitEligible)
  ic_fit_review_reason <- if (!all_ic_fit_eligible) {
    pending <- which(is.na(tbl$ICFitEligible) | !tbl$ICFitEligible)
    paste0("IC solution checks are not satisfied: ",
           paste(paste0(labels[pending], ": ", tbl$ICFitReview[pending]), collapse = "; "))
  } else ""
  inference_review_reason <- if (!all_converged) {
    pending <- which(is.na(conv_vals) | !as.logical(conv_vals))
    details <- vapply(pending, function(i) {
      paste0(labels[i], ": ", sub("[.]$", "", tbl$InferenceReview[i]))
    }, character(1))
    paste0("Inference readiness is not satisfied: ",
           paste(details, collapse = "; "), ".")
  } else {
    ""
  }
  all_current_contract <- nrow(tbl) > 0L &&
    all(!is.na(tbl$ICContractVersion) &
          tbl$ICContractVersion == mfrm_ic_contract_version())
  all_stored_consistent <- nrow(tbl) > 0L &&
    all(!is.na(tbl$StoredICConsistent) & tbl$StoredICConsistent)
  all_ic_eligible <- nrow(tbl) > 0L &&
    all(!is.na(tbl$ICEligible) & tbl$ICEligible)
  all_ic_selectable <- nrow(tbl) > 0L &&
    all(!is.na(tbl$ICSelectable) & tbl$ICSelectable) &&
    all(!is.na(tbl$ICIntegrationSelectable) & tbl$ICIntegrationSelectable)
  contract_vals <- tbl$ICContractVersion[!is.na(tbl$ICContractVersion)]
  same_contract <- length(contract_vals) > 0L &&
    length(unique(contract_vals)) == 1L &&
    identical(unique(contract_vals), mfrm_ic_contract_version())
  integration_vals <- tbl$IntegrationEvaluationId[
    !is.na(tbl$IntegrationEvaluationId) & nzchar(tbl$IntegrationEvaluationId)
  ]
  same_integration <- length(integration_vals) == nrow(tbl) &&
    length(unique(integration_vals)) == 1L
  same_formula <- length(unique(tbl$AICFormula)) == 1L &&
    length(unique(tbl$BICFormula)) == 1L &&
    length(unique(tbl$SABICFormula)) == 1L
  ic_comparable <- same_method && same_nobs && same_data && all_ic_fit_eligible &&
    all_mml && all_current_contract && all_stored_consistent &&
    all_ic_eligible && all_ic_selectable && same_contract && same_integration &&
    same_formula && same_constraint_basis
  sabic_comparable <- ic_comparable &&
    all(!is.na(tbl$SABICSelectable) & tbl$SABICSelectable)

  if (!isTRUE(nested)) {
    if (!same_method) {
      warning(
        "Models use different estimation methods (",
        paste(unique(method_vals), collapse = ", "),
        "). Canonical IC ranking, deltas, weights, ",
        "and automatic preferences are suppressed.",
        call. = FALSE
      )
    } else if (!all_mml) {
      warning(
        "Information-criterion ranking is limited to converged MML fits in this package. ",
        "Legacy descriptive values remain separately labelled for ",
        paste(unique(method_vals), collapse = ", "),
        " models, but deltas, weights, automatic preferences, and LRT were suppressed.",
        call. = FALSE
      )
    }

    # -- warn if observation counts differ --
    if (!same_nobs) {
      warning("Models were fit to different numbers of observations (",
              paste(obs_vals, collapse = ", "),
              "). Cross-sample deltas, weights, ",
              "and automatic preferences are suppressed.", call. = FALSE)
    }
    if (!same_data) {
      warning(
        "Models were not fit to the same prepared response data. ",
        "Deltas, weights, automatic preferences, and likelihood-ratio testing were suppressed.",
        call. = FALSE
      )
    }
    if (!all_ic_fit_eligible) {
      warning(
        ic_fit_review_reason, " ",
        "IC ranking, weights, and likelihood-ratio testing were suppressed.",
        call. = FALSE
      )
    }
    if (!all_current_contract) {
      warning(
        "At least one fit lacks current, complete information for comparing its information criteria. ",
        "LegacyAIC/LegacyBIC remain descriptive, but canonical ranking was suppressed; ",
        "refit under the current package before comparison.",
        call. = FALSE
      )
    } else if (!all_stored_consistent) {
      warning(
        "At least one stored information-criterion value or identity does not match ",
        "the retained objective, parameter vector, prepared data, or integration setting. ",
        "Canonical ranking was suppressed.",
        call. = FALSE
      )
    }
    if (all_mml && all_current_contract && !all_ic_eligible) {
      warning(
        "At least one MML fit cannot be ranked by information criteria. ",
        "Check for non-unit observation weights or incomplete likelihood information.",
        call. = FALSE
      )
    }
    if (all_mml && all_current_contract && all_ic_eligible &&
        !all_ic_selectable) {
      warning(
        "Information-criterion ranking is unavailable at the supplied ",
        "quadrature resolution. Raw criteria remain visible, but deltas, weights, preferences, and ",
        "LRT are suppressed below q = 31. Refit every candidate with a common ",
        "q >= 31 grid and check a denser grid when the decision is close.",
        call. = FALSE
      )
    }
    if (all_current_contract && all_mml && !same_integration) {
      warning(
        "Models do not share one integration-evaluation identity. Refit or reevaluate ",
        "all candidates with the same locked quadrature setting before IC ranking.",
        call. = FALSE
      )
    }
  }

  tbl$ICComparable <- ic_comparable
  tbl$SABICComparable <- sabic_comparable
  tbl$ConstraintComparable <- same_constraint_basis
  preferred <- list()

  # -- Delta AIC and Akaike Weights --
  if (ic_comparable && any(is.finite(tbl$AIC))) {
    min_aic <- min(tbl$AIC, na.rm = TRUE)
    tbl$Delta_AIC <- tbl$AIC - min_aic
    raw_w <- exp(-0.5 * tbl$Delta_AIC)
    tbl$AkaikeWeight <- ifelse(is.finite(raw_w),
                               raw_w / sum(raw_w, na.rm = TRUE),
                               NA_real_)
    preferred$AIC <- tbl$Label[which.min(tbl$AIC)]
  } else {
    tbl$Delta_AIC <- NA_real_
    tbl$AkaikeWeight <- NA_real_
  }

  # -- Delta BIC and BIC Weights --
  if (ic_comparable && any(is.finite(tbl$BIC))) {
    min_bic <- min(tbl$BIC, na.rm = TRUE)
    tbl$Delta_BIC <- tbl$BIC - min_bic
    raw_bw <- exp(-0.5 * tbl$Delta_BIC)
    tbl$BICWeight <- ifelse(is.finite(raw_bw),
                            raw_bw / sum(raw_bw, na.rm = TRUE),
                            NA_real_)
    preferred$BIC <- tbl$Label[which.min(tbl$BIC)]
  } else {
    tbl$Delta_BIC <- NA_real_
    tbl$BICWeight <- NA_real_
  }

  # -- Delta SABIC and adjusted-BIC candidate-set weights --
  if (sabic_comparable && any(is.finite(tbl$SABIC))) {
    min_sabic <- min(tbl$SABIC, na.rm = TRUE)
    tbl$Delta_SABIC <- tbl$SABIC - min_sabic
    raw_sw <- exp(-0.5 * tbl$Delta_SABIC)
    tbl$SABICWeight <- ifelse(
      is.finite(raw_sw),
      raw_sw / sum(raw_sw, na.rm = TRUE),
      NA_real_
    )
    preferred$SABIC <- tbl$Label[which.min(tbl$SABIC)]
  } else {
    tbl$Delta_SABIC <- NA_real_
    tbl$SABICWeight <- NA_real_
  }

  # -- likelihood-ratio test (two models only) --
  lrt <- NULL
  lrt_status <- if (isTRUE(nested)) "requested" else "not_requested"
  lrt_reason <- if (isTRUE(nested)) {
    "Likelihood-ratio test was requested but not yet evaluated."
  } else {
    "Likelihood-ratio test was not requested; set `nested = TRUE` only for supported nested comparisons."
  }
  nesting_review <- audit_compare_mfrm_nesting(fits, labels = labels)
  pcm_gpcm_regular <- isTRUE(nesting_review$eligible) &&
    identical(nesting_review$relation, "PCM_in_GPCM") && all_ic_fit_eligible
  if (isTRUE(nested)) {
    if (length(fits) != 2L) {
      lrt_status <- "not_computed"
      lrt_reason <- "Likelihood-ratio testing requires exactly two fitted models."
      warning("`nested = TRUE` was requested, but LRT requires exactly two fitted models. LRT was not computed.",
              call. = FALSE)
    } else if (!ic_comparable || (!all_converged && !pcm_gpcm_regular)) {
      lrt_status <- "not_computed"
      lrt_reason <- paste(
        "Not all comparison requirements are satisfied: formal MML likelihood basis,",
        "verified information criteria, common response data, constraints and",
        "integration settings, and adequate support for inference."
      )
      if (!all_ic_fit_eligible) lrt_reason <- paste(lrt_reason, ic_fit_review_reason)
      if (!all_converged && !pcm_gpcm_regular) lrt_reason <- paste(lrt_reason, inference_review_reason)
      warning(
        "`nested = TRUE` was requested. ", lrt_reason, " LRT was not computed.",
        call. = FALSE
      )
    } else if (!isTRUE(nesting_review$eligible)) {
      lrt_status <- "not_computed"
      lrt_reason <- paste0("Structural nesting review did not pass: ", nesting_review$reason)
      warning(
        "`nested = TRUE` was requested, but the structural nesting review did not pass. ",
        nesting_review$reason,
        " LRT was not computed.",
        call. = FALSE
      )
    } else {
      ll <- tbl$LogLik
      np <- tbl$npar
      if (!all(is.finite(ll)) || !all(is.finite(np))) {
        lrt_status <- "not_computed"
        lrt_reason <- "Log-likelihoods or parameter counts were non-finite."
        warning(
          "`nested = TRUE` was requested, but at least one log-likelihood or parameter count was non-finite. LRT was not computed.",
          call. = FALSE
        )
      } else if (np[1] == np[2]) {
        lrt_status <- "not_computed"
        lrt_reason <- "Compared models have the same number of free parameters."
        warning(
          "`nested = TRUE` was requested, but the compared models have the same number of free parameters. LRT was not computed.",
          call. = FALSE
        )
      } else {
        # User labels need not be unique. Identify the PCM null by model, not
        # by matching its display label or guessing from a possibly bad count.
        idx_simple <- if (pcm_gpcm_regular) which(tbl$Model == "PCM")[1L] else which.min(np)
        idx_complex <- if (pcm_gpcm_regular) which(tbl$Model == "GPCM")[1L] else which.max(np)
        chi_sq <- 2 * (ll[idx_complex] - ll[idx_simple])
        df_diff <- np[idx_complex] - np[idx_simple]
        df_verified <- is.null(nesting_review$df) || identical(as.numeric(df_diff), as.numeric(nesting_review$df))
        if (is.finite(chi_sq) && chi_sq >= 0 && df_diff > 0 && df_verified) {
          p_val <- stats::pchisq(chi_sq, df = df_diff, lower.tail = FALSE)
          lrt <- tibble(
            Simple   = tbl$Label[idx_simple],
            Complex  = tbl$Label[idx_complex],
            ChiSq    = chi_sq,
            df       = df_diff,
            p_value  = p_val,
            ReferenceDistribution = "asymptotic_chi_square",
            Interpretation = "nested_fit_evidence_not_practical_preference"
          )
          lrt_status <- "computed"
          lrt_reason <- paste(
            "Likelihood-ratio test computed after the structural nesting review passed;",
            "the chi-square reference is asymptotic and assumes independent Persons,",
            "a correctly specified population/response model and regular interior solutions.",
            "Check starting-value and integration sensitivity; the p-value is not an automatic practical model preference."
          )
        } else {
          lrt_status <- "not_computed"
          lrt_reason <- if (!is.finite(chi_sq) || !is.finite(df_diff)) {
            "Likelihood-ratio statistic or parameter-count difference was non-finite."
          } else if (!df_verified) {
            "The parameter-count difference does not equal the verified number of null restrictions."
          } else if (df_diff <= 0) {
            "Parameter-count difference was not positive."
          } else {
            "The more complex model had a lower log-likelihood, producing a negative likelihood-ratio statistic."
          }
          warning(
            "`nested = TRUE` was requested, but the LRT statistic was not interpretable. ",
            lrt_reason,
            " LRT was not computed.",
            call. = FALSE
          )
        }
      }
    }
  }

  if (isTRUE(nested) && length(ic_cautions)) {
    lrt_reason <- paste(lrt_reason, paste(ic_cautions, collapse = " "))
  }

  # -- evidence ratios (pairwise Akaike-weight ratios) --
  evidence_ratios <- NULL
  if (ic_comparable && "AkaikeWeight" %in% names(tbl) && nrow(tbl) >= 2) {
    er_rows <- list()
    for (i in 1:(nrow(tbl) - 1)) {
      for (j in (i + 1):nrow(tbl)) {
        log_er <- (tbl$AIC[j] - tbl$AIC[i]) / 2
        if (!is.finite(log_er)) log_er <- tbl$AIC[j] / 2 - tbl$AIC[i] / 2
        er <- exp(log_er)
        ratio_reason <- if (!is.finite(log_er)) "nonfinite_difference" else
          if (!is.finite(er)) "overflow" else
          if (er == 0) "underflow" else "available"
        if (ratio_reason != "available") er <- NA_real_
        er_rows[[length(er_rows) + 1]] <- tibble(
          Model1        = tbl$Label[i],
          Model2        = tbl$Label[j],
          EvidenceRatio = er,
          LogEvidenceRatio = log_er,
          RatioReason = ratio_reason
        )
      }
    }
    evidence_ratios <- bind_rows(er_rows)
  }

  comparison_basis <- list(
    same_method = same_method,
    all_mml = all_mml,
    same_nobs = same_nobs,
    same_data = same_data,
    all_inference_ready = all_converged,
    all_ic_fit_eligible = all_ic_fit_eligible,
    all_converged = all_converged,
    all_current_contract = all_current_contract,
    all_stored_ic_consistent = all_stored_consistent,
    all_ic_eligible = all_ic_eligible,
    all_ic_selectable = all_ic_selectable,
    same_ic_contract = same_contract,
    same_integration_evaluation = same_integration,
    same_formula_contract = same_formula,
    same_constraint_basis = same_constraint_basis,
    constraint_components = constraint_components,
    ic_comparable = ic_comparable,
    sabic_comparable = sabic_comparable,
    nested_requested = isTRUE(nested),
    nesting_review = nesting_review,
    lrt_status = lrt_status,
    lrt_reason = lrt_reason
  )

  out <- list(
    table           = tbl,
    lrt             = lrt,
    evidence_ratios = evidence_ratios,
    preferred       = preferred,
    comparison_basis = comparison_basis
  )
  class(out) <- c("mfrm_comparison", class(out))
  out
}

#' @export
summary.mfrm_comparison <- function(object, ...) {
  out <- list(
    table           = object$table,
    lrt             = object$lrt,
    evidence_ratios = object$evidence_ratios,
    preferred       = object$preferred,
    comparison_basis = object$comparison_basis
  )
  class(out) <- "summary.mfrm_comparison"
  out
}

print_mfrm_lrt <- function(lrt) {
  cat("\nLikelihood-ratio test:\n")
  p_text <- trimws(format.pval(lrt$p_value[1], digits = 4, eps = 1e-4))
  cat(sprintf("  Chi-sq = %.3f, df = %d, p %s%s\n",
              lrt$ChiSq[1], lrt$df[1],
              if (startsWith(p_text, "<")) "" else "= ", p_text))
  cat(sprintf("  %s vs %s\n", lrt$Simple[1], lrt$Complex[1]))
  cat("  Reference: asymptotic chi-square; small or sparse samples may need further calibration.\n")
  cat("  Interpretation: formal nested-fit evidence; practical gain and score utility require separate checks.\n")
  invisible(lrt)
}

#' @export
print.summary.mfrm_comparison <- function(x, ...) {
  cat("--- MFRM Model Comparison ---\n\n")

  # -- main comparison table --
  tbl <- x$table
  # Format weight columns with 4 decimal places for readability
  fmt_tbl <- as.data.frame(tbl)
  weight_cols <- intersect(
    c("AkaikeWeight", "BICWeight", "SABICWeight"),
    names(fmt_tbl)
  )
  for (wc in weight_cols) {
    fmt_tbl[[wc]] <- ifelse(is.na(fmt_tbl[[wc]]), NA_character_,
                            sprintf("%.4f", fmt_tbl[[wc]]))
  }
  delta_cols <- intersect(
    c("Delta_AIC", "Delta_BIC", "Delta_SABIC"),
    names(fmt_tbl)
  )
  for (dc in delta_cols) {
    fmt_tbl[[dc]] <- ifelse(is.na(fmt_tbl[[dc]]), NA_character_,
                            sprintf("%.2f", fmt_tbl[[dc]]))
  }
  display_cols <- c(
    "Label", "Model", "Method", "Persons", "Npar", "LogLik",
    "AIC", "BIC", "SABIC"
  )
  if (isTRUE(x$comparison_basis$ic_comparable)) {
    display_cols <- c(
      display_cols, "Delta_AIC", "AkaikeWeight", "Delta_BIC", "BICWeight",
      "Delta_SABIC", "SABICWeight"
    )
  }
  display_cols <- intersect(display_cols, names(fmt_tbl))
  print(fmt_tbl[, display_cols, drop = FALSE], row.names = FALSE)
  print_wrapped_line("Full statistics, eligibility and numerical settings remain in `$table`.")

  if (!isTRUE(x$comparison_basis$ic_comparable)) {
    cat("\nInformation-criterion ranking is unavailable. Displayed criteria are descriptive only.\n")
    reasons <- c(
      all_mml = "Ranking requires MML fits; JML criteria are descriptive only.",
      same_data = "Models must use the same response data.",
      same_constraint_basis = "Models must use compatible score coding and constraints.",
      all_current_contract = "Stored comparison information is incomplete or outdated; refit before comparing.",
      all_stored_ic_consistent = "Stored criteria do not match the fitted values or numerical settings.",
      all_ic_eligible = "One or more likelihoods are ineligible, for example because of non-unit observation weights.",
      all_ic_selectable = "One or more fits lack eligible information criteria or sufficient quadrature resolution.",
      same_integration_evaluation = "Models must use the same integration settings.",
      all_ic_fit_eligible = "One or more models lack adequate numerical or identification checks for IC comparison."
    )
    for (field in names(reasons)) {
      if (field %in% c("all_ic_eligible", "all_ic_selectable") &&
          !isTRUE(x$comparison_basis$all_mml)) next
      if (identical(x$comparison_basis[[field]], FALSE)) print_wrapped_line(reasons[[field]])
    }
    review_column <- if ("ICFitReview" %in% names(tbl)) "ICFitReview" else "InferenceReview"
    if (review_column %in% names(tbl)) {
      for (i in which(!is.na(tbl[[review_column]]) & nzchar(tbl[[review_column]]))) {
        print_wrapped_line(paste0(tbl$Label[i], ": ", tbl[[review_column]][i]))
      }
    }
  } else if (!isTRUE(x$comparison_basis$sabic_comparable)) {
    cat("\nSABIC is displayed for sensitivity only; automatic SABIC selection is disabled\n")
    cat("at 22 or fewer Persons.\n")
  }

  if (!is.null(x$lrt)) {
    print_mfrm_lrt(x$lrt)
  } else if (isTRUE(x$comparison_basis$nested_requested)) {
    cat("\nLikelihood-ratio test was not reported.\n")
    if (!is.null(x$comparison_basis$lrt_status) &&
        !is.null(x$comparison_basis$lrt_reason)) {
      if (nrow(tbl) != 2L || isTRUE(x$comparison_basis$ic_comparable)) {
        print_wrapped_line(paste0("Reason: ", x$comparison_basis$lrt_reason))
      }
    }
    review <- x$comparison_basis$nesting_review %||% list()
    if (!is.null(review$reason) && nzchar(review$reason)) {
      cat("  Nesting review:", review$reason, "\n")
    }
  }

  # -- evidence ratios --
  for (caution in unique(tbl$ICFitCaution[nzchar(tbl$ICFitCaution)])) {
    print_wrapped_line(paste0("Caution: ", caution))
  }
  if (!is.null(x$evidence_ratios) && nrow(x$evidence_ratios) > 0) {
    cat("\nRelative candidate-set ratios (Akaike weights; not model probabilities):\n")
    er <- x$evidence_ratios
    for (k in seq_len(nrow(er))) {
      ratio_str <- if (is.finite(er$EvidenceRatio[k])) {
        format(signif(er$EvidenceRatio[k], 3), trim = TRUE)
      } else if (all(c("RatioReason", "LogEvidenceRatio") %in% names(er))) {
        sprintf("NA (%s; log ratio = %s)", er$RatioReason[k],
                format(signif(er$LogEvidenceRatio[k], 4), trim = TRUE))
      } else {
        "NA"
      }
      cat(sprintf("  %s / %s = %s\n",
                  er$Model1[k], er$Model2[k], ratio_str))
    }
  }

  if (length(x$preferred) > 0) {
    cat("\nMinimum criterion within this candidate set:\n")
    for (nm in names(x$preferred)) {
      cat(sprintf("  By %s: %s\n", nm, x$preferred[[nm]]))
    }
  }
  invisible(x)
}

#' @export
print.mfrm_comparison <- function(x, ...) {
  print(summary(x))
  invisible(x)
}
