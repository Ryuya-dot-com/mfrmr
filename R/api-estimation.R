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

#' Fit many-facet models to ordered ratings
#'
#' Estimate rater severity, task or criterion difficulty, and category thresholds
#' from a rating table. Person abilities are also returned when supported by the
#' estimator. Supply your column names through `person`, `facets` and `score`;
#' the Examples show one RSM analysis from data to results.
#' @param data A data.frame with one row per rating. Grouping metadata is ignored.
#'   Supply the rating table, not a [describe_mfrm_data()] result.
#' @param person Column name for Person identifiers (character scalar).
#' @param facets Character vector of non-Person facet column names. Reserved names
#'   include `Person`, `Score`, `Weight`, `score_k`, `theta`, `steps`,
#'   `interactions`, `log_slopes`, `beta` and `log_sigma2`.
#' @param score Column name for integer category scores, including binary scores.
#'   Near-integer normalization and specialized input rules are documented in
#'   [fit_mfrm_technical_details].
#' @param rating_min Intended minimum category score; supply with `rating_max`.
#' @param rating_max Intended maximum category score; supply with `rating_min`.
#' @param weight Optional column name for observation weights. Retained weights
#'   must have a finite sum and are not automatically rescaled.
#' @param category_policy `"collapse"` maps category gaps to consecutive scores;
#'   `"preserve"` retains the ladder declared by `rating_min` and `rating_max`.
#'   This changes the fitted steps. `NULL` uses `keep_original` (default: collapse).
#'   A preserved, unobserved internal category prevents ordinary fitting.
#'   Use the same policy in data and anchor review.
#' @param keep_original Compatibility option: `TRUE` preserves categories; `FALSE`
#'   collapses gaps. Prefer explicit `category_policy` in new code. If both are
#'   supplied, they must agree.
#' @param missing_codes Optional sentinel recoding: `TRUE` or `"default"` uses
#'   standard missing codes in the score column only; a character vector supplies
#'   codes to recode in all model columns. `NULL` performs no recoding.
#'   See [recode_missing_codes()].
#' @param model `"RSM"` (shared thresholds), `"PCM"` (separate step ladders), or
#'   `"GPCM"` (also estimates relative discriminations).
#' @param method `"MML"` (default marginal maximum likelihood), `"JML"` (joint
#'   maximum likelihood; `"JMLE"` is an alias), or `"CML"` (conditional maximum
#'   likelihood). See Model and inference choices below.
#' @param step_facet Facet whose levels own the PCM/GPCM step ladders. Specify it
#'   explicitly for analysis; GPCM and CML PCM require it. Unused for RSM.
#' @param slope_facet Facet whose levels own GPCM discriminations. For one family,
#'   JML requires the same owner as `step_facet`; MML also allows distinct owners.
#'   An ordered pair selects the specialized two-family MML route; see
#'   [fit_mfrm_technical_details] before using it.
#' @param gpcm_mml_identification GPCM MML population convention: `"free_population"`
#'   estimates a normal population with relative slopes; `"fixed_standard_normal"`
#'   fixes N(0,1). Their constraints differ; see [fit_mfrm_technical_details].
#' @param facet_interactions Confirmatory two-way non-Person interactions for
#'   RSM/PCM, e.g., `"Rater:Criterion"`, or a list of length-two character vectors.
#' @param min_obs_per_interaction Weighted count below which interaction cells
#'   are flagged; this is a review threshold, not an inference guarantee.
#' @param interaction_policy Sparse-cell handling: `"warn"`, `"error"`, or `"silent"`.
#' @param anchors Direct-anchor data.frame with `Facet`, `Level`, `Anchor` columns.
#'   Values fix logit coordinates; Person anchors require JML.
#' @param group_anchors Group-mean constraints with `Facet`, `Level`, `Group`,
#'   `GroupValue` columns. Targets require external justification and do not
#'   create observed overlap. Person constraints require JML.
#' @param noncenter_facet Facet left uncentered (default `"Person"`). See the
#'   centering and anchor-origin conditions in [fit_mfrm_technical_details].
#' @param population_sd Optional positive residual population SD, treated as fixed.
#'   Requires `population_formula`, full direct RSM/PCM MML and no interactions.
#'   `NULL` retains the chosen model's default; it does not activate a population model.
#' @param centering_scope `"facet"` centers all levels, including anchors;
#'   `"remainder"` centers levels outside direct/group constraints.
#'   `"anchor_origin"` lets anchors replace centering for additive RSM/PCM JML.
#'   Supported combinations are given in [fit_mfrm_technical_details].
#' @param fit_scope `"full"` fits the declared model; `"comparisons"` fits only
#'   the targets in `comparison_review` under its separate conditions.
#' @param comparison_review For comparison-only fitting, [describe_mfrm_data()]
#'   output requested with `comparisons`, or its `$comparison_review`.
#'   Use its `fit_arguments` and the same original ratings.
#' @param dummy_facets Facets to fix at zero.
#' @param repeated_ratings `"review"` retains repeated-cell warnings; `"independent"`
#'   declares distinct conditionally independent events without changing the
#'   likelihood. It does not demonstrate independence. Unsupported for two-family GPCM.
#' @param positive_facets Facets with positive orientation.
#' @param anchor_policy Anchor-review handling: `"warn"`, `"error"`, or `"silent"`.
#' @param min_common_anchors Minimum anchored levels used in count recommendations;
#'   it does not establish invariance or empirical connectedness.
#' @param min_obs_per_element Minimum weighted count per facet level for anchor review.
#' @param min_obs_per_category Minimum weighted count per category for anchor review.
#' @param quad_points Gauss-Hermite quadrature points for MML (default `31`).
#'   Accuracy settings and sensitivity checks are in [fit_mfrm_technical_details].
#' @param maxit Optimizer iteration ceiling (default `400`), not a convergence guarantee.
#' @param reltol Initial optimizer tolerance; accepted solutions undergo additional
#'   numerical checks. See [fit_mfrm_technical_details] for engine-specific controls.
#' @param gpcm_mml_start Starting values for two-family adaptive direct MML.
#'   Required structure and supported scope are in [fit_mfrm_technical_details].
#' @param em_score_tol Score stopping tolerance for two-family GPCM MML-EM;
#'   does not replace the final numerical and inference checks.
#' @param optimizer `"auto"`, `"BFGS"`, or `"L-BFGS-B"` for direct optimization.
#' @param mml_integration `"fixed"`, `"adaptive"`, or `"auto"` quadrature. Supported
#'   models, accuracy checks and fallbacks are in [fit_mfrm_technical_details].
#' @param mml_accuracy_control Named accuracy-control list for supported adaptive
#'   two-family MML; see [fit_mfrm_technical_details] for entries and defaults.
#' @param progress Logical; show elapsed time, stage and evaluation progress.
#' @param mml_starts Optional starting-value review for full ordinary RSM/PCM MML.
#'   Accepted specifications and selection rules are in [fit_mfrm_technical_details].
#' @param mml_engine `"direct"`, `"em"`, or `"hybrid"`. Supported combinations and
#'   recorded direct-engine fallbacks are in [fit_mfrm_technical_details].
#' @param population_formula One-sided Person-level latent-regression formula for
#'   MML, e.g., `~ group + pretest`; `~ 1` estimates an intercept-only population.
#'   This changes the model, not just the display scale.
#' @param person_data One-row-per-Person data.frame, required with
#'   `population_formula`; includes the Person ID and formula covariates.
#' @param person_id ID column in `person_data`; defaults to `person` when present.
#' @param population_policy Missing covariate handling: `"error"` or complete-case
#'   `"omit"`. Omitted Persons and ratings are recorded.
#' @param facet_shrinkage `"none"` or post-hoc `"empirical_bayes"` shrinkage.
#'   `"laplace"` is a compatibility alias, not penalized likelihood.
#'   See [apply_empirical_bayes_shrinkage()].
#' @param facet_prior_sd Optional shrinkage prior SD; fixes its variance to the square.
#' @param shrink_person Apply active post-hoc shrinkage to ordinary-JML Person
#'   estimates with sampling SEs. Use `FALSE` with MML posterior SDs.
#' @param attach_diagnostics Run [diagnose_mfrm()] once without residual PCA
#'   and attach supported per-level diagnostics (default `FALSE`).
#' @param checkpoint Optional `list(file = ..., every_iter = ...)` for EM
#'   checkpoint/resume; direct optimization ignores it. Resuming requires an
#'   exactly compatible saved state; see [fit_mfrm_technical_details].
#' @param jml_penalty `"none"` or explicit `"jeffreys"` for additive RSM/PCM JML.
#'   Jeffreys fitting returns a separate point-estimate class without ordinary SEs.
#' @param jml_correction_order Explicit positive order of experimental profile-score
#'   adjustment for shared-owner GPCM JML; `NULL` leaves JML unchanged.
#'   Input restrictions and uncertainty targets are in [fit_mfrm_technical_details].
#' @param jml_correction_sampling `"fixed_rosters"` or `"random_rosters"` for
#'   corrected-JML Person covariance. Changes covariance, not the point equation.
#'   Omit when no correction is requested; see [fit_mfrm_technical_details].
#' @details
#' Each row represents one rating. Ordinary fitting omits rows missing required
#' model values; review [describe_mfrm_data()] before fitting your own data. Repeated
#' Person-by-facet cells are retained and flagged for review. Declaring them
#' independent does not establish conditional independence.
#'
#' Choose the intended category ladder explicitly. The default can collapse gaps
#' in observed categories, changing the fitted steps. The example preserves a
#' 1--4 rubric; a preserved, unobserved internal category prevents ordinary fitting.
#'
#' @section Model and inference choices:
#' `RSM` shares category thresholds; `PCM` gives each level of `step_facet` its own
#' ladder. `GPCM` also estimates relative discriminations for `slope_facet`.
#' The default RSM/PCM MML model fixes the Person distribution to N(0,1).
#' Together with centered non-Person facets and steps, this fixes the overall
#' ability-to-difficulty location as well as the population SD. These are
#' substantive assumptions, not just a reporting scale. To estimate the mean and
#' SD, use `population_formula = ~ 1` and matching `person_data` (one row per
#' Person). One-family GPCM MML estimates them by default; two-family GPCM
#' requires different explicit settings. See [fit_mfrm_technical_details] for
#' population, anchoring and slope constraints before comparing models.
#'
#' MML assumes the specified population distribution. JML estimates Person and
#' structural effects jointly; many Persons do not remove incidental-parameter
#' bias when each has few ratings. CML conditions on Person totals and returns
#' structural effects without Person abilities. Its supported RSM/PCM route
#' requires unit weights and preserved categories.
#'
#' Point estimates and intervals have separate availability checks. Failure to
#' obtain an interval does not by itself invalidate an available point estimate;
#' inspect the reported status and reason. A finite optimizer value is not
#' automatically an interpretable estimate, and a finite SE does not establish
#' interval coverage. [mfrm_facet_intervals()] documents structural intervals;
#' [fit_mfrm_technical_details] gives estimator-specific conditions and references.
#' @return
#' Ordinary MML/JML returns an `mfrm_fit` (a named list). Start with
#' `results <- summary(fit)`:
#' - `results$person_overview` summarizes Person ability estimates.
#' - `results$facet_overview` summarizes each non-Person facet.
#' - `results$decision` reports interpretation limits and suggested actions.
#'
#' Individual estimates are in `fit$facets$person`, `fit$facets$others`,
#' `fit$steps` and, for GPCM, `fit$slopes`. Check `EstimateUse` or
#' `ParameterStatus` for points, and `CIEligible` with its accompanying reason
#' for intervals, where provided. Unavailable uncertainty is not zero.
#' See [summary.mfrm_fit()] and [mfrm_fit_extractors] for extraction.
#'
#' CML returns an `mfrm_cml_fit`: `summary(fit)$locations` and `$steps` contain
#' structural estimates. Jeffreys-penalized JML returns an `mfrm_jeffreys_fit`
#' ([summary.mfrm_jeffreys_fit()]); comparison-only fitting returns an
#' `mfrm_comparison_fit` ([interaction_effect_table()]). These classes have
#' different supported outputs. Full field descriptions are in
#' [fit_mfrm_technical_details].
#'
#' @seealso [fit_mfrm_technical_details], [describe_mfrm_data()],
#'   [summary.mfrm_fit()], [diagnose_mfrm()], [plot.mfrm_fit()]
#' @examples
#' # Load the package
#' library(mfrmr)
#'
#' # Load example ratings and look at the first six rows
#' ratings <- load_mfrmr_data("example_operational")
#' head(ratings)
#'
#' # RSM with a preserved 1--4 rubric and fixed N(0,1) Person distribution
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
#' # Wright map: Person abilities, facet effects and thresholds
#' plot(fit)
#'
#' # Save the summary, then display its tables
#' results <- summary(fit)
#' results$person_overview # One row summarizing person ability estimates
#' results$facet_overview  # One row per facet: number of levels, mean, SD, range
#'
#' # Check the interpretation status and recommended next step
#' results$decision
#'
#' \dontrun{
#' # Optional repeated fitting: compare specified starting values.
#' reviewed <- fit_mfrm(ratings, "Person", c("Rater", "Criterion"), "Score",
#'   mml_starts = c(0, 0.5, -0.5))
#' summary(reviewed)$starting_values # Every attempt, including warnings/failures
#' reviewed$opt$start_review$parameter_map # Meaning and constraints of coordinates
#' write.csv(summary(reviewed)$starting_values, "starting-values.csv", row.names = FALSE)
#' }
#' @export
fit_mfrm <- function(data,
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
                     mml_starts = NULL) {
  close_progress <- mfrmr_start_fit_progress(progress)
  on.exit(close_progress(), add = TRUE)
  supplied_arguments <- setdiff(names(as.list(match.call())[-1L]), "progress")
  if (is.null(mml_starts)) supplied_arguments <- setdiff(supplied_arguments, "mml_starts")
  fit_scope <- match.arg(fit_scope)
  if (fit_scope == "full" && !is.null(comparison_review))
    stop("Use fit_scope = 'comparisons' to fit a comparison review, or extract comparisons from a full fit with interaction_effect_table().", call. = FALSE)
  centering_scope <- match.arg(centering_scope)
  repeated_ratings <- match.arg(repeated_ratings)
  keep_original <- resolve_mfrm_category_policy(
    keep_original, category_policy, !missing(keep_original))
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

  model <- toupper(match.arg(model))
  method_input <- public_mfrm_method_label(toupper(match.arg(method)))
  method <- method_input
  if (identical(centering_scope, "anchor_origin") &&
      (!identical(method, "JML") || !model %in% c("RSM", "PCM") ||
       length(facet_interactions) > 0L || fit_scope != "full")) {
    stop("`centering_scope = 'anchor_origin'` requires ordinary additive RSM/PCM JML with fit_scope = 'full'.",
         call. = FALSE)
  }
  optimizer <- normalize_mfrm_optimizer(match.arg(optimizer))
  mml_engine <- tolower(match.arg(mml_engine))
  mml_integration <- match.arg(mml_integration)
  jml_penalty <- match.arg(jml_penalty)
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
  gpcm_mml_identification <- match.arg(gpcm_mml_identification)
  interaction_policy <- tolower(match.arg(interaction_policy))
  anchor_policy <- tolower(match.arg(anchor_policy))
  population_policy <- tolower(match.arg(population_policy))
  facet_shrinkage <- match.arg(facet_shrinkage)
  if (jml_penalty != "none") {
    arguments <- mget(names(formals(fit_mfrm)), envir = environment(), inherits = FALSE)
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
    arguments <- mget(names(formals(fit_mfrm)), envir = environment(), inherits = FALSE)
    return(mfrmr_fit_cml(arguments, supplied_arguments))
  }

  if (fit_scope == "comparisons") {
    arguments <- mget(names(formals(fit_mfrm)), envir = environment(), inherits = FALSE)
    return(mfrmr_fit_comparisons(arguments, supplied_arguments))
  }

  supplied_arguments <- setdiff(supplied_arguments, c("fit_scope", "comparison_review"))

  if (!is.null(gpcm_mml_start) &&
      !(length(slope_facet) == 2L && identical(model, "GPCM") &&
        identical(method_input, "MML") && identical(mml_engine, "direct") &&
        mml_integration %in% c("adaptive", "auto") && is.null(jml_correction_order)))
    stop("`gpcm_mml_start` applies only to two-family adaptive direct MML.", call. = FALSE)
  if (!is.null(jml_correction_order)) {
    arguments <- mget(names(formals(fit_mfrm)), envir = environment(), inherits = FALSE)
    return(mfrm_fit_adjusted_jml(arguments, supplied_arguments))
  }
  if (!missing(jml_correction_sampling))
    stop("`jml_correction_sampling` requires an explicit `jml_correction_order`.", call. = FALSE)
  if (length(slope_facet) > 1L) {
    arguments <- mget(names(formals(fit_mfrm)), envir = environment(), inherits = FALSE)
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
    estimation_person_ids <- trimws(estimation_person_ids)
    default_missing_codes <- isTRUE(missing_codes) ||
      (is.character(missing_codes) && length(missing_codes) == 1L &&
       identical(tolower(missing_codes), "default"))
    if (!is.null(missing_codes) && !isFALSE(missing_codes) &&
        !default_missing_codes) {
      estimation_person_ids[
        estimation_person_ids %in% trimws(as.character(missing_codes))
      ] <- NA_character_
    }
    population_scaffold_data[[person]] <- estimation_person_ids
    population_scaffold_data <- population_scaffold_data[
      !is.na(estimation_person_ids), , drop = FALSE
    ]
    effective_population_formula <- stats::as.formula("~ 1")
    effective_person_data <- data.frame(
      .mfrmr_person_id = unique(estimation_person_ids[!is.na(estimation_person_ids)]),
      stringsAsFactors = FALSE
    )
    names(effective_person_data) <- person
    effective_person_id <- person
  }

  population <- prepare_mfrm_population_scaffold(
    data = population_scaffold_data,
    person = person,
    population_formula = effective_population_formula,
    person_data = effective_person_data,
    person_id = effective_person_id,
    population_policy = population_policy
  )
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
    population$response_rows_retained <- as.integer(nrow(population_scaffold_data))
    population$response_rows_omitted <- as.integer(
      nrow(data) - nrow(population_scaffold_data)
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

  anchor_review <- review_mfrm_anchors(
    data = estimation_data,
    person = person,
    facets = facets,
    score = score,
    rating_min = rating_min,
    rating_max = rating_max,
    weight = weight,
    keep_original = keep_original,
    missing_codes = missing_codes,
    anchors = anchors,
    group_anchors = group_anchors,
    min_common_anchors = min_common_anchors,
    min_obs_per_element = min_obs_per_element,
    min_obs_per_category = min_obs_per_category,
    noncenter_facet = noncenter_facet,
    dummy_facets = dummy_facets,
    repeated_ratings = repeated_ratings,
    centering_scope = centering_scope
  )

  schema_issues <- anchor_review$issues[c("anchor_schema_mismatch", "group_anchor_schema_mismatch")]
  if (any(vapply(schema_issues, nrow, integer(1)) > 0L))
    stop("Malformed anchor schema: nonempty constraints cannot be discarded. Direct anchors require facet, level and anchor/value/measure; group anchors also require group/subset and groupvalue/value/anchor.", call. = FALSE)
  anchors <- anchor_review$anchors
  group_anchors <- anchor_review$group_anchors

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
    centering_scope = centering_scope
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
#' their partial-fit checks. Extraction does not fit again. See [fit_mfrm_technical_details]
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
#' # Optional workflow; run the example explicitly as shown below.
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
    method = as.character(cfg$method %||% NA_character_),
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
#'   near-integer normalization rules are in [fit_mfrm_technical_details].
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
#' @inheritParams fit_mfrm
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
#' those different effects. See [mfrmr-linking-and-dff](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-linking-and-dff.html) for a
#' school-assignment example and [mfrmr_linking_and_dff] for interpretation.
#' A matching, fully supported joint fit can return descriptive contrasts via
#' [interaction_effect_table()] or `summary(fit, comparison_review = review)`.
#' These explicit calls add retained-point numerical checks, not partial
#' estimation or formal uncertainty. To fit selected CML contrasts and obtain
#' conditional-information Wald intervals, use `fit_mfrm(fit_scope = "comparisons",
#' comparison_review = review)` with the CML review's `$fit_arguments`; see
#' the comparison-only section of [fit_mfrm_technical_details].
#'
#' @details
#' Set `rating_min`/`rating_max` from the rubric, including unused categories;
#' `keep_original = TRUE` preserves the intended category structure. Score/weight
#' descriptives use [psych::describe()]. Start with `summary(data_review)` and
#' consult the full tables when its default `top_n = 10` previews are insufficient.
#' Neither review nor summary contains model estimates or changes the input.
#'
#' @section Reading the data review:
#' - `overview` describes retained observations, Persons, facets and category
#'   span; `row_retention` compares input/retained `Rows` and `DroppedRows`.
#'   `CategoryPolicy` records the requested handling, `ScoreRecoded` actual changes.
#'   Old results without these records use `"not_recorded"` and `NA`, respectively.
#' - `missing_by_column` counts original input NAs, even when `missing_codes`
#'   recodes additional markers. Its summary preview is named `missing`; also
#'   inspect `missing_recoding` and `preparation_notes`. A missing required value
#'   excludes that rating row, not every rating from its Person; nothing is imputed.
#' - `structural_missingness` compares observed cells with `expected_design`.
#'   Without a roster it is unassessed/`not_declared`, not zero missing assignments.
#' - `score_distribution` shows sparse/unused categories; `notes`/printed
#'   `Caveats` retain support warnings. Review rubric and post-fit category
#'   diagnostics before collapsing categories. A retained unused internal
#'   category stops fitting; more optimizer iterations cannot supply information.
#' - `facet_level_summary` and `linkage_summary` describe exposure, shared
#'   Persons and sparse levels. Summary `facet_overview` reports minimum/maximum
#'   weighted counts; very low `MinWeightedN` warns of unstable estimation.
#'   `design_connectivity` separately counts Person-facet graph components.
#'   Disconnected levels lack shared-Person links; this conservative check alone
#'   does not establish full model identification.
#' - Optional `agreement` describes exact agreement, correlations and mean
#'   differences for the selected scorer facet, not model-based severity.
#'
#' MML supplies posterior scores for extreme Persons through a population model.
#' It does not give extreme non-Person facets a prior or automatic shrinkage;
#' review fitted boundary/precision evidence separately.
#'
#' @section Resolving input problems:
#' Check `names(ratings)` against the requested columns, including spelling/case.
#' For unexpected row loss, inspect retention, missingness and preparation notes;
#' correct invalid scores/IDs or use [recode_missing_codes()] with explicit
#' columns/codes. Review `duplicate_cell_detail`: correct accidental duplicates,
#' declare distinct conditionally independent events with
#' `repeated_ratings = "independent"`, or model dependence. Tasks/occasions that
#' distinguish events belong in the design.
#'
#' After correction, repeat the review and fit the same data with [fit_mfrm()],
#' using matching columns, category bounds, `keep_original` and `missing_codes`.
#' Review-time recoding does not edit the original data. For import, mapping and
#' the complete workflow, see `vignette("mfrmr-workflow", package = "mfrmr")`.
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
                               person,
                               facets,
                               score,
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
                               comparisons = NULL) {
  keep_original <- resolve_mfrm_category_policy(
    keep_original, category_policy, !missing(keep_original))
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
#' @details `summary()` provides compact previews; the reading order and field
#' differences are described under "Reading the data review".
#'
#' @param object Output from [describe_mfrm_data()].
#' @param digits Number of digits for numeric rounding.
#' @param top_n Maximum rows shown in preview blocks.
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
#' @examples # Optional workflow; run the example explicitly as shown below.
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
#' @section Reading data-review plots:
#' - `"score_distribution"` plots `WeightedN`, the sum of weights per category.
#'   Sparse categories limit threshold information, but uniformity/unimodality
#'   is not required. Read floor/ceiling concentrations against rubric,
#'   assignments and target population; this is not a sample-adequacy test.
#' - `"facet_levels"` shows distinct levels per facet. Check expected levels,
#'   ratings per level and crossings: more levels increase parameter dimension,
#'   while more optimizer iterations cannot repair missing identification.
#' - `"missing"` plots input missing counts. Investigate them using the tables
#'   above; missing scores/Persons/facet IDs cause row exclusions in fitting.
#'
#' @return For `plot()`: A plotting-data object of class `mfrm_plot_data`.
#' @seealso [describe_mfrm_data()], `plot()`
#' @examples # Optional workflow; run the example explicitly as shown below.
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
  pal <- resolve_palette(
    palette = palette,
    defaults = c(
      score = "#2b8cbe",
      facet = "#31a354",
      missing = "#756bb1"
    )
  )

  if (type == "score_distribution") {
    tbl <- as.data.frame(x$score_distribution %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(tbl) == 0 || !all(c("Score", "WeightedN") %in% names(tbl))) {
      stop("Score distribution is not available. Ensure describe_mfrm_data() was run on valid data.", call. = FALSE)
    }
    if (isTRUE(draw)) {
      barplot_rot45(
        height = suppressWarnings(as.numeric(tbl$WeightedN)),
        labels = as.character(tbl$Score),
        col = pal["score"],
        main = if (is.null(main)) "Score distribution" else as.character(main[1]),
        ylab = "Weighted N",
        label_angle = label_angle,
        mar_bottom = 7.8
      )
    }
    return(invisible(new_mfrm_plot_data(
      "data_description",
      list(plot = "score_distribution", table = tbl)
    )))
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
    if (isTRUE(draw)) {
      barplot_rot45(
        height = suppressWarnings(as.numeric(agg$Levels)),
        labels = as.character(agg$Facet),
        col = pal["facet"],
        main = if (is.null(main)) "Facet levels" else as.character(main[1]),
        ylab = "Levels",
        label_angle = label_angle,
        mar_bottom = 7.8
      )
    }
    return(invisible(new_mfrm_plot_data(
      "data_description",
      list(plot = "facet_levels", table = as.data.frame(agg, stringsAsFactors = FALSE))
    )))
  }

  tbl <- as.data.frame(x$missing_by_column %||% data.frame(), stringsAsFactors = FALSE)
  if (nrow(tbl) == 0 || !all(c("Column", "Missing") %in% names(tbl))) {
    stop("Missing-by-column table is not available. Ensure describe_mfrm_data() was run on valid data.", call. = FALSE)
  }
  if (isTRUE(draw)) {
    barplot_rot45(
      height = suppressWarnings(as.numeric(tbl$Missing)),
      labels = as.character(tbl$Column),
      col = pal["missing"],
      main = if (is.null(main)) "Missing values by column" else as.character(main[1]),
      ylab = "Missing",
      label_angle = label_angle,
      mar_bottom = 8.0
    )
  }
  invisible(new_mfrm_plot_data(
    "data_description",
    list(plot = "missing", table = tbl)
  ))
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
#' @inheritParams fit_mfrm
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
#' @inheritParams fit_mfrm
#' @param dummy_facets Facets to fix at zero.
#'
#' @details
#' Check candidate direct/group constraints against the receiving data before
#' estimation, using the preprocessing and key-resolution rules of [fit_mfrm()].
#' Such constraints can transfer coordinates from a defensible reference; they
#' do not create the observed overlap required for a common-element link.
#' The review does not verify source-fit readiness or invariant cross-run meaning
#' of element labels.
#'
#' There is no estimation-method argument: even a clean review can request an
#' unsupported model combination. In particular, MML rejects Person direct/group
#' anchors. See the scale-constraint section of [fit_mfrm_technical_details]
#' before using partial anchors.
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
#' @section Reviewing constraints before fitting:
#' Start with `summary(review)$issue_counts`, inspect the full `issues` and
#' `recommendations`, and resolve their stated problems before fitting.
#' `facet_summary` describes constraint coverage: `FreeLevels` counts levels
#' outside direct and group constraints, not free parameters. Group members
#' can vary, while centering removes a degree of freedom outside groups.
#' `design_checks` records support checks; the summary's
#' `level_observation_summary` and `category_counts` show support relative to
#' the requested screening counts.
#'
#' Build candidates with [make_anchor_table()] when appropriate, revise them
#' after review, then pass the intended constraints to [fit_mfrm()].
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
#' # Optional workflow; run the example explicitly as shown below.
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
                                person,
                                facets,
                                score,
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
                                centering_scope = c("facet", "remainder", "anchor_origin")) {
  centering_scope <- match.arg(centering_scope)
  keep_original <- resolve_mfrm_category_policy(
    keep_original, category_policy, !missing(keep_original))
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
  # Check the same equalities as fitting, reusing the cleaned tables.
  prepare_constraint_specs(prep, noncenter_facet = noncenter_facet,
    dummy_facets = dummy_facets, centering_scope = centering_scope,
    anchor_review = review)
  class(review) <- unique(c("mfrm_anchor_review", class(review)))
  review
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
#' @details For `summary()`: Compact constraint coverage, support counts and
#' recommendations; follow "Reviewing constraints before fitting" for reading order.
#'
#' @return For `summary()`: An object of class `summary.mfrm_anchor_review`.
#' @seealso [review_mfrm_anchors()], [fit_mfrm()]
#' @examples # Optional workflow; run the example explicitly as shown below.
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
#' @param draw If `TRUE`, draw using base graphics.
#' @param ... Reserved for generic compatibility.
#' @details For `plot()`: Start with `"issue_counts"` for counts by issue class.
#' `"facet_constraints"` shows anchored, grouped and free levels;
#' `"level_observations"` shows observation support. Interpret these alongside
#' the constraint definitions and screening limits above, before fitting.
#'
#' @return For `plot()`: A plotting-data object of class `mfrm_plot_data`.
#' @seealso [review_mfrm_anchors()], [make_anchor_table()]
#' @examples # Optional workflow; run the example explicitly as shown below.
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
  pal <- resolve_palette(
    palette = palette,
    defaults = c(
      issues = "#cb181d",
      anchored = "#756bb1",
      grouped = "#9ecae1",
      levels = "#2b8cbe"
    )
  )

  if (type == "issue_counts") {
    tbl <- as.data.frame(x$issue_counts %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(tbl) == 0 || !all(c("Issue", "N") %in% names(tbl))) {
      stop("Issue-count table is not available. Ensure review_mfrm_anchors() was run with valid anchor inputs.", call. = FALSE)
    }
    tbl <- tbl |>
      dplyr::arrange(dplyr::desc(.data$N), .data$Issue)
    if (isTRUE(draw)) {
      barplot_rot45(
        height = suppressWarnings(as.numeric(tbl$N)),
        labels = as.character(tbl$Issue),
        col = pal["issues"],
        main = if (is.null(main)) "Anchor-review issue counts" else as.character(main[1]),
        ylab = "Rows",
        label_angle = label_angle,
        mar_bottom = 9.2
      )
    }
    return(invisible(new_mfrm_plot_data(
      "anchor_review",
      list(plot = "issue_counts", table = tbl)
    )))
  }

  if (type == "facet_constraints") {
    tbl <- as.data.frame(x$facet_summary %||% data.frame(), stringsAsFactors = FALSE)
    if (nrow(tbl) == 0 || !all(c("Facet", "AnchoredLevels", "GroupedLevels", "FreeLevels") %in% names(tbl))) {
      stop("Facet summary with constraint columns is not available. Ensure review_mfrm_anchors() was run with valid anchor inputs.", call. = FALSE)
    }
    if (isTRUE(draw)) {
      old_mar <- graphics::par("mar")
      on.exit(graphics::par(mar = old_mar), add = TRUE)
      mar <- old_mar
      mar[1] <- max(mar[1], 8.8)
      graphics::par(mar = mar)
      mat <- rbind(
        Anchored = suppressWarnings(as.numeric(tbl$AnchoredLevels)),
        Grouped = suppressWarnings(as.numeric(tbl$GroupedLevels)),
        Free = suppressWarnings(as.numeric(tbl$FreeLevels))
      )
      mids <- graphics::barplot(
        height = mat,
        beside = FALSE,
        names.arg = FALSE,
        col = c(pal["anchored"], pal["grouped"], "#d9d9d9"),
        border = "white",
        ylab = "Levels",
        main = ""
      )
      draw_rotated_x_labels(
        at = mids,
        labels = as.character(tbl$Facet),
        srt = label_angle,
        cex = 0.82,
        line_offset = 0.085
      )
      graphics::legend(
        "topright",
        legend = c("Anchored", "Grouped", "Free"),
        fill = c(pal["anchored"], pal["grouped"], "#d9d9d9"),
        bty = "n",
        cex = 0.85
      )
    }
    return(invisible(new_mfrm_plot_data(
      "anchor_review",
      list(plot = "facet_constraints", table = tbl)
    )))
  }

  tbl <- as.data.frame(x$design_checks$level_observation_summary %||% data.frame(), stringsAsFactors = FALSE)
  if (nrow(tbl) == 0 || !all(c("Facet", "MinObsPerLevel") %in% names(tbl))) {
    stop("Level observation summary is not available. Ensure review_mfrm_anchors() was run with valid anchor inputs.", call. = FALSE)
  }
  if (isTRUE(draw)) {
    barplot_rot45(
      height = suppressWarnings(as.numeric(tbl$MinObsPerLevel)),
      labels = as.character(tbl$Facet),
      col = pal["levels"],
      main = if (is.null(main)) "Minimum observations per level" else as.character(main[1]),
      ylab = "Min observations",
      label_angle = label_angle,
      mar_bottom = 8.0
    )
    if ("RecommendedMinObs" %in% names(tbl)) {
      r <- suppressWarnings(as.numeric(tbl$RecommendedMinObs))
      r <- r[is.finite(r)]
      if (length(r) > 0) graphics::abline(h = unique(r)[1], lty = 2, col = "gray45")
    }
  }
  invisible(new_mfrm_plot_data(
    "anchor_review",
    list(plot = "level_observations", table = tbl)
  ))
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
#' Convert fitted estimates to candidate direct constraints in the
#' `Facet`/`Level`/`Anchor` schema. `Anchor` is the internal, untransformed location;
#' fixing it in a new fit does not propagate source uncertainty. Thresholds,
#' GPCM slopes, model settings and source SEs are excluded; use
#' [extract_mfrm_calibration()] for a complete saved calibration.
#'
#' Export is refused unless the source fit is inference-ready under the current
#' contract. `readiness_policy = "review"` allows inspection, not approval for
#' reuse. Check cross-run element identity, substantive invariance and observed
#' connectedness separately, then use [review_mfrm_anchors()] on the receiving
#' data. That review checks constraints and data support, not source-fit quality
#' or invariance.
#'
#' Keep `digits = NULL` for recalibration. Rounding individual anchors can
#' break their joint sum or group-mean constraint, even at six decimal places.
#' Explicitly rounded values are different constraints and must be reviewed
#' before reuse; the fitter does not silently recenter supplied anchors.
#'
#' @section Using the candidates:
#' `Facet` names the facet, `Level` its element, and `Anchor` the fixed value
#' (rounded only when `digits` is supplied). After reviewing the reference fit
#' and receiving data, pass selected rows to `fit_mfrm(..., anchors = ...)`.
#'
#' @return A data.frame with `Facet`, `Level`, and `Anchor`.
#' @seealso [fit_mfrm()], [review_mfrm_anchors()]
#' @examples
#' # Optional workflow; run the example explicitly as shown below.
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

#' Review response fit and the support for uncertainty summaries
#'
#' Use an existing fit to locate unexpected ratings, inspect element-level
#' Infit/Outfit and review available SE, interval and reliability evidence.
#' Save `diagnostics <- diagnose_mfrm(fit)`, then read
#' `summary(diagnostics)$decision` and `summary(diagnostics)$top_fit`. Diagnostic flags guide
#' follow-up; they do not establish rater quality or justify automatic exclusions.
#' @param fit An ordinary RSM/PCM or one-family GPCM result from [fit_mfrm()].
#'   Testlet, shared-rater and corrected-JML response summaries use
#'   [mfrm_response_diagnostics()] instead. Two-family GPCM has its own
#'   diagnostic route; see [fit_mfrm_technical_details].
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
#'   Both engine and FACETS-style transformations require df >= 1.
#' @param diagnostic_mode `"both"` (default) computes residual-based diagnostics
#'   and posterior-integrated marginal category-count screens. `"legacy"` keeps
#'   only the residual bundle; `"marginal_fit"` keeps only marginal screens.
#'   Their targets differ; inspect `diagnostic_basis`. Marginal computation adds
#'   cost and enables the marginal plot types below.
#' @section Saved diagnostic definitions:
#' New diagnostics carry `calculation_version = 2L`. Recreate older diagnostics
#' with `diagnose_mfrm(fit, ...)` and the original diagnostic settings before
#' using current reports; no refit is needed.
#' For historical ZSTD use `fit_df_method = "engine"` and, if applicable,
#' `whexact = "legacy_linear"`. PTMEA, displacement, eligible chi-square df,
#' fair scores and unexpected-response defaults use the corrected definitions.
#'
#' @param residual_pca Residual PCA mode: `"none"`, `"overall"`, `"facet"`, or `"both"`.
#' @param pca_max_factors Maximum number of PCA factors to retain per matrix.
#'
#' @details
#' Start with `summary(diagnostics)$decision` and `$key_warnings`. Inspect
#' `diagnostics$overall_fit` for global fit and `diagnostics$fit` for affected
#' elements, then trace unusual results to ratings in `diagnostics$obs`.
#' `FitReason` and response-level status explain missing values; `NA` does not
#' mean no misfit. `diagnostic_basis` separates residual and marginal evidence.
#'
#' Pass the same `fit` and `diagnostics` to [mfrm_results()] for reporting.
#' Diagnostic computation does not override source-fit restrictions. Several
#' flags can reuse the same residuals and are not independent evidence.
#'
#' @section Diagnostic calculations:
#' **Response basis.** MML uses saved EAPs matched by Person ID; JML uses
#' optimizer-coordinate probabilities for legacy diagnostics. `obs$PersonMeasure`
#' records that ability, `PrimaryPersonMeasure` the primary estimate (possibly
#' infinite), and `PersonMeasureBasis` the calculation. A finite optimizer proxy
#' does not make a boundary estimate finite. For supported ordinary fits,
#' [fitted()][mfrm_fit_responses] uses primary JML limits; posterior and
#' corrected-JML diagnostics have separate [mfrm_response_diagnostics()] routes.
#'
#' `ConditionalVariance` retains the actual variance. Legacy `Var`, `StdResidual`
#' and `StdSq` are withheld at variance <= `1e-10`. This screening cutoff is
#' distinct from mathematical availability: [residuals()][mfrm_fit_responses]
#' retains representable positive variances for Pearson residuals within its
#' scope; zero variance makes them undefined. Expected ratings and raw residuals
#' may remain available. `PearsonAvailable`, `ResponseStatus` and `ResponseReason`
#' explain rows and accompany score/residual exports.
#'
#' **Mean squares and standardization.** Overall/element mean squares require
#' standardized residuals, variance and positive weights for every contributing
#' row. Any unavailable contribution withholds the aggregate and df (`NA`),
#' without dropping rows or treating missing residuals as zero. `FitResponseRows`,
#' `FitAvailableRows` and `FitUnavailableRows` are row counts, not weight totals;
#' `FitStatus`/`FitReason` explain availability in `overall_fit`, `fit` and
#' `measures`. FACETS-style df also require complete fourth moments.
#'
#' ZSTD is withheld if any row uses a finite JML proxy for an infinite primary
#' estimate (`FitBoundaryRows` counts these), or df < 1 under either convention.
#' Mean squares and row counts retain their legacy basis. `FitStatus` describes
#' mean-square availability, not ZSTD availability. These safeguards do not
#' calibrate a hypothesis test.
#'
#' - **Infit MnSq** is the information-weighted mean-square residual, sensitive
#'   to on-target misfit; **Outfit MnSq** is unweighted, sensitive to outliers.
#'   Their reference is 1, not a finite-sample expectation guaranteed after
#'   parameter estimation or EAP substitution.
#' - **ZSTD** applies a Wilson-Hilferty cube-root transformation to approximate
#'   a standard-normal deviate. The default uses fourth-moment df;
#'   `fit_df_method = "both"` gives engine primary and FACETS companion columns.
#'   Changing df changes standardization, not MnSq or the residual basis.
#' - **PTMEA** is the within-element correlation of scores with the oriented
#'   measure sum (`obs$MeasureSum`), including Person rows. Positive values agree
#'   with the fitted orientation; they are not confirmatory evidence.
#'
#' MML EAP shrinkage changes expected scores and fit statistics relative to
#' JMLE engines such as FACETS, especially at extreme raw scores. Neither df
#' convention makes these posterior-integrated statistics. A JMLE-style external
#' comparison requires a JML refit; see [facets_fit_review()]. ConQuest MML
#' parameter fit instead aggregates residuals through the response design, then
#' averages over posterior ability. Its Infit averages a ratio, not separately
#' averaged residual sums divided by variances. Integrating row residuals alone
#' does not reproduce it; native marginal category counts are another target.
#' See the [ConQuest technical manual](https://conquestmanual.acer.org/s3-00.html).
#'
#' **Marginal counts.** Expectations condition on the same observed responses
#' and fixed calibration, not independent replication or a prior-only population
#' margin. First-order scales use `sum(w^2 * p * (1-p))`; pairwise scales use
#' the analogous products of row weights. Cross-response/opportunity covariance
#' and calibration uncertainty are omitted: these are descriptive screens.
#'
#' Invalid/missing contributing probabilities, scores or weights withhold the
#' complete-scope aggregate. Missing standardized residuals/flags remain `NA`;
#' a known cutoff crossing stays flagged even if a companion rule is unavailable.
#' `marginal_fit$coverage` records classified/unclassified cells, groups and level
#' pairs. Row/opportunity counts stay visible; zero-weight opportunities add no
#' information. Available maxima include classification/residual counts, and
#' RMSDs require complete scope. PCM/GPCM step-group summaries retain `step_facet`.
#' GPCM uses the same slope-aware kernel for residual and marginal tables;
#' neither screen establishes Rasch invariance or a calibrated inferential test.
#'
#' **Heuristic interpretation.** Bond and Fox (2015) describe MnSq < 0.5 as
#' overfit (too predictable; potentially inflated reliability), 0.5--1.5 as
#' productive, and > 1.5 as underfit (noise). The package's
#' \eqn{|\mathrm{ZSTD}| \ge 2} flag uses approximate normality, not a calibrated
#' 5 percent test after parameter estimation and repeated screening. Large Outfit
#' with acceptable Infit can suggest isolated outliers; examine responses before
#' attributing a cause.
#'
#' `interaction_pairs` selects facet pairs, with `NULL` choosing top interactions.
#' `residual_pca` defaults to `"none"`; overall PCA uses the Person \eqn{\times}
#' combined-facet residual matrix, and facet PCA uses Person \eqn{\times}
#' facet-level matrices to locate residual structure. These are exploratory,
#' not DIMTEST/UNIDIM implementations or proofs of unidimensionality. Item-response
#' tests would require explicit decisions about collapsing, conditioning or
#' adjusting many-facet ratings. Interpret PCA with global/element fit and
#' local dependence under the specified facet structure.
#' @section Reliability and uncertainty:
#' **Element uncertainty.** `SE` is an alias for `ModelSE`, whose meaning
#' depends on the row. For MML Persons it is the posterior SD conditional on
#' fitted calibration and the population model, not a repeated-sampling SE
#' of the EAP. For structural facet levels it comes from observed information
#' when available; `SE_Method` identifies fallback or regularized calculations.
#' Read `SEUse`/`CIUse` before reporting. `CI_Lower`/`CI_Upper` are symmetric
#' 95 percent normal bands from `Estimate +/- qnorm(.975) * SE`, not posterior
#' quantiles. Person bands do not propagate calibration uncertainty.
#'
#' `RealSE = ModelSE * sqrt(max(Infit, 1))` inflates uncertainty for underfit
#' and never rewards overfit with a smaller SE. Missing Infit uses a factor
#' of one; it does not establish good fit. "Real" denotes this adjustment,
#' not known true error or a confidence bound. JML entries remain exploratory.
#'
#' **Facet separation.** In `reliability`, `SD` is the sample SD of finite
#' level estimates (denominator `n - 1`), `RMSE` is the root mean squared
#' `ModelSE` on those same levels, and `TrueSD` is the square root of
#' `max(SD^2 - RMSE^2, 0)`. RMSE here is not prediction error against observed
#' ratings; `TrueSD` is an error-subtracted estimate, not known population truth.
#' `Reliability`/`Separation` alias `ModelReliability`/`ModelSeparation`;
#' `Real*` repeats the calculation using `RealSE`. The separate `facet_precision`
#' table also offers a `population` distribution basis (denominator `n`),
#' describing these levels, not the MML ability-population model.
#' Separation, strata, and reliability follow the Wright & Masters (1982) conventions:
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
#' The variance subtraction uses marginal SEs without propagating covariance
#' between level estimates. `ReliabilityBasis`/`ReliabilityUse` identify this
#' approximation; `SourceSupportsFormalInference` concerns the source uncertainty,
#' while the reliability summary itself has `SupportsFormalInference = FALSE`.
#'
#' Facet SEs from a regularized information matrix or an observation-table
#' fallback remain diagnostic approximations. They are labelled explicitly and
#' cannot authorize ordinary confidence-interval reporting. Numerical convergence
#' is reviewed separately from support for inference; switching from JML to MML
#' does not by itself establish valid SEs or intervals. Recompute older diagnostic
#' objects with `diagnose_mfrm(fit)` before reporting; the existing fit can be used
#' without refitting the model.
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
#' diagnostic_summary <- summary(diagnostics)
#' diagnostic_summary$decision
#'
#' diagnostic_summary$key_warnings # Issues to investigate, if present
#' diagnostic_summary$top_fit      # Most unusual residual-based fit statistics
#'
#' # Distinguish residual-based checks from marginal model checks
#' diagnostic_summary$diagnostic_basis[, c("DiagnosticPath", "Status", "Basis")]
#'
#' # Check each residual's basis and the coverage of aggregate fit statistics
#' head(diagnostics$obs[, c("PersonMeasureBasis", "ConditionalVariance",
#'   "PearsonAvailable", "ResponseReason")])
#' diagnostics$overall_fit[, c("Infit", "Outfit", "FitUnavailableRows", "FitReason")]
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
    # A local rater need not use every category of a shared step ladder.
    # Require fitted-scope support and retain the joint-information checks.
    local_sparse <- rasch_singleton && is.data.frame(local) && nrow(local) > 0L &&
      all(!is.na(local$MissingCategories)) &&
      isTRUE(any(nzchar(local$MissingCategories) | local$MinimumObservedCategoryCount == 1L))
    singleton_review <- isTRUE(audit$readiness$Complete) &&
      identical(audit$readiness$CategoryState, "weak_information") &&
      identical(audit$readiness$ReasonCodes, "weak_category_information") &&
      isTRUE(audit$readiness$UnsupportedStepCoordinates == 0L) &&
      isTRUE(audit$readiness$UnsupportedCategoryContrasts == 0L) &&
      length(counts) > 0L && all(is.finite(counts)) &&
      all(counts > 0L) && (any(counts == 1L) || local_sparse)
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
      "Some fitted category counts are singletons or some local category cells are empty/singletons. All categories remain supported in their fitted step scopes. Model-information intervals remain asymptotic approximations; sparse support can affect bias and coverage. The source fit retains its category-support review."
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
#' @details
#' IC ranking requires eligible MML solutions using the same prepared rows,
#' Person/facet columns, score coding, constraints, formula and integration
#' evaluation identity. Counts alone are insufficient; mismatched counts trigger
#' a warning. All-unit weights are eligible; any non-unit observation weights
#' exclude ranking. For fixed-facet MML, `ICSampleSize` counts independent Persons
#' (`ICSampleSizeBasis = "person_count"`); response counts and weight totals
#' are separate.
#'
#' Canonical AIC/BIC/SABIC use the retained objective, free optimizer dimension
#' and Person count. Stale values, legacy fits without current contract identity
#' and JML fits cannot enter ranking; old values may appear as `LegacyAIC` and
#' `LegacyBIC`.
#'
#' **Integration.** Canonical criteria remain visible at valid quadrature orders,
#' but q < 15 is screening-only and q = 15--30 review-only. Automatic deltas,
#' weights, preferences and LRT require q >= 31 (`ICSelectable` and
#' `ICIntegrationSelectable`). This is a starting grid, not guaranteed adequacy;
#' check close or consequential comparisons at a denser shared grid, normally
#' q >= 61. Common coarse grids and `nested = TRUE` do not bypass this guard.
#'
#' **Nesting.** A restricted model is a special case of a larger model under
#' equality constraints. Automatic review supports:
#' - RSM inside PCM with explicit `step_facet`. PCM must retain every RSM
#'   `facet_interactions` term, but may add terms; freeing steps cannot compensate
#'   for dropped interactions.
#' - PCM inside GPCM with the same step facet, population design, constraints
#'   and interactions, adding only G-1 relative log-slope contrasts for G levels.
#'   The slope owner may differ from the step owner.
#' - Same-family additive/interaction models when the smaller interaction set
#'   is a subset of the larger, with all other structural settings matched.
#'
#' Changing estimation method is not nesting or a common MML likelihood basis.
#' Changed anchors/dummying/centering and other same-family relations require
#' separate review; requesting nesting does not grant it. Population specifications
#' must both be fixed N(0,1), or share an estimated-normal design with the same
#' declared columns/values aligned by Person. Coefficient/variance estimates may
#' differ; row/column permutations are aligned. Recodings, changed designs or
#' missing metadata need review. This alignment does not grant inference readiness.
#'
#' Default PCM fixes N(0,1), whereas default GPCM estimates mean/variance;
#' changing `model` alone does not isolate slopes. For an estimated-normal
#' PCM/GPCM comparison use `population_formula = ~1` and the same `person_data`.
#' After structural, dimension and numerical checks, `PCM_in_GPCM` tests equal
#' relative slopes. Unit slopes are interior positive values, so its asymptotic
#' reference is chi-square with G-1 df, not a boundary mixture. Local-solution
#' checks are separate from slope-interval availability; IC eligibility alone
#' establishes neither nesting nor slope inference.
#'
#' **Likelihood-ratio test.** Exactly two fits, `nested = TRUE`, passing review
#' and a positive free-parameter difference are required:
#'
#' \deqn{\Lambda = -2 (\ell_{\mathrm{restricted}} - \ell_{\mathrm{full}})
#'   \sim \chi^2_{\Delta p}}
#'
#' Small samples, boundaries or singularities can invalidate this asymptotic
#' reference. At large Person counts, small practical gains can dominate ICs or
#' be significant. Assess effect sizes, stability, interpretation and score
#' consequences separately; neither result establishes subscore usefulness.
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
#' @section Reading and using the comparison:
#' Start with `table$ICComparable`, `ICSelectable`, `ICIntegrationTier` and
#' `ICStatus`; interpret lower AIC/BIC only for comparable candidates, and SABIC
#' only when `SABICComparable` is also true. `summary()` explains withheld rankings
#' or tests. `preferred` is the minimum within the supplied candidate set, not
#' an unconditional verdict. `evidence_ratios` compares Akaike weights when at
#' least two are available; it does not adjust for multiple comparisons.
#'
#' Inspect `comparison_basis`, including `nesting_review$relation` and `reason`,
#' before interpreting `lrt`. Revise mismatched data, step owners, populations or
#' constraints before using IC/LRT claims. For matched PCM/GPCM fits,
#' [build_weighting_review()] shows which facet levels and information shares
#' the slopes reweight; use this alongside statistical comparison to assess
#' consequences for scores.
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
#' @examples # Optional workflow; run the example explicitly as shown below.
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
#' # https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-gpcm-scope.html
#' # Request compare_mfrm(..., nested = TRUE).
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
