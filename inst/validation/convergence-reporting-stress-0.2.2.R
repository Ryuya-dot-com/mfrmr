# Convergence-reporting stress review for the 0.2.2 program.
#
# This script is intentionally outside the CRAN-time test suite. It stress-tests
# the reporting contract around stats::optim() results:
#   * Iterations remains function evaluations for direct BFGS fits.
#   * BFGSIterations mirrors GradientEvaluations as the closest iteration count.
#   * code-0 plateau stops with large terminal gradients are surfaced as review.
#   * low-maxit failures and EM iteration-basis rows remain distinguishable.
#
# Run from the package root:
#   Rscript inst/validation/convergence-reporting-stress-0.2.2.R [reps] [out_dir]
#
# By default, generated files are written under validation-results/ so short
# smoke runs do not look like curated release evidence.

`%||%` <- function(x, y) {
  if (is.null(x) || length(x) == 0L) y else x
}

load_mfrmr_for_validation <- function() {
  if (requireNamespace("pkgload", quietly = TRUE) && file.exists("DESCRIPTION")) {
    suppressMessages(pkgload::load_all(".", quiet = TRUE))
  } else if (requireNamespace("mfrmr", quietly = TRUE)) {
    suppressPackageStartupMessages(library(mfrmr))
  } else {
    stop("mfrmr is not available. Run from the package root or install mfrmr.",
         call. = FALSE)
  }
}

args <- commandArgs(trailingOnly = TRUE)
REPS <- if (length(args) >= 1L) as.integer(args[1]) else 8L
OUT_DIR <- if (length(args) >= 2L && nzchar(args[2])) {
  args[2]
} else {
  file.path("validation-results", "convergence-reporting-stress-0.2.2")
}
if (!is.finite(REPS) || REPS < 1L) {
  stop("`reps` must be a positive integer.", call. = FALSE)
}
dir.create(OUT_DIR, recursive = TRUE, showWarnings = FALSE)

load_mfrmr_for_validation()
old_options <- options(mfrmr.warn_large_gradient = TRUE)
on.exit(options(old_options), add = TRUE)

scenario_table <- list(
  list(
    Scenario = "sample_tight_jml_rsm",
    DataSource = "sample_mfrm_data",
    Model = "RSM", Method = "JML", Engine = "direct",
    NPerson = NA_integer_, NRater = NA_integer_, NCriterion = NA_integer_,
    ScoreLevels = NA_integer_, Maxit = 500L, Reltol = 1e-12,
    QuadPoints = 7L, StepFacet = NA_character_, SlopeFacet = NA_character_,
    ThetaSD = NA_real_, RaterSD = NA_real_, CriterionSD = NA_real_,
    StepSpan = NA_real_
  ),
  list(
    Scenario = "generated_loose_jml_rsm",
    DataSource = "simulate_mfrm_data",
    Model = "RSM", Method = "JML", Engine = "direct",
    NPerson = 80L, NRater = 4L, NCriterion = 4L,
    ScoreLevels = 5L, Maxit = 100L, Reltol = 1e-3,
    QuadPoints = 7L, StepFacet = NA_character_, SlopeFacet = NA_character_,
    ThetaSD = 1.2, RaterSD = 0.50, CriterionSD = 0.35,
    StepSpan = 1.8
  ),
  list(
    Scenario = "generated_default_jml_rsm",
    DataSource = "simulate_mfrm_data",
    Model = "RSM", Method = "JML", Engine = "direct",
    NPerson = 80L, NRater = 4L, NCriterion = 4L,
    ScoreLevels = 5L, Maxit = 120L, Reltol = 1e-6,
    QuadPoints = 7L, StepFacet = NA_character_, SlopeFacet = NA_character_,
    ThetaSD = 1.2, RaterSD = 0.50, CriterionSD = 0.35,
    StepSpan = 1.8
  ),
  list(
    Scenario = "generated_tight_jml_rsm",
    DataSource = "simulate_mfrm_data",
    Model = "RSM", Method = "JML", Engine = "direct",
    NPerson = 80L, NRater = 4L, NCriterion = 4L,
    ScoreLevels = 5L, Maxit = 400L, Reltol = 1e-10,
    QuadPoints = 7L, StepFacet = NA_character_, SlopeFacet = NA_character_,
    ThetaSD = 1.2, RaterSD = 0.50, CriterionSD = 0.35,
    StepSpan = 1.8
  ),
  list(
    Scenario = "generated_lowmax_jml_rsm",
    DataSource = "simulate_mfrm_data",
    Model = "RSM", Method = "JML", Engine = "direct",
    NPerson = 80L, NRater = 4L, NCriterion = 4L,
    ScoreLevels = 5L, Maxit = 3L, Reltol = 1e-10,
    QuadPoints = 7L, StepFacet = NA_character_, SlopeFacet = NA_character_,
    ThetaSD = 1.2, RaterSD = 0.50, CriterionSD = 0.35,
    StepSpan = 1.8
  ),
  list(
    Scenario = "generated_loose_jml_pcm",
    DataSource = "simulate_mfrm_data",
    Model = "PCM", Method = "JML", Engine = "direct",
    NPerson = 80L, NRater = 4L, NCriterion = 4L,
    ScoreLevels = 5L, Maxit = 120L, Reltol = 1e-3,
    QuadPoints = 7L, StepFacet = "Criterion", SlopeFacet = NA_character_,
    ThetaSD = 1.2, RaterSD = 0.50, CriterionSD = 0.35,
    StepSpan = 1.8
  ),
  list(
    Scenario = "generated_loose_mml_direct_rsm",
    DataSource = "simulate_mfrm_data",
    Model = "RSM", Method = "MML", Engine = "direct",
    NPerson = 40L, NRater = 3L, NCriterion = 3L,
    ScoreLevels = 5L, Maxit = 80L, Reltol = 1e-3,
    QuadPoints = 7L, StepFacet = NA_character_, SlopeFacet = NA_character_,
    ThetaSD = 1.2, RaterSD = 0.45, CriterionSD = 0.30,
    StepSpan = 1.8
  ),
  list(
    Scenario = "generated_mml_em_rsm",
    DataSource = "simulate_mfrm_data",
    Model = "RSM", Method = "MML", Engine = "em",
    NPerson = 40L, NRater = 3L, NCriterion = 3L,
    ScoreLevels = 5L, Maxit = 40L, Reltol = 1e-4,
    QuadPoints = 7L, StepFacet = NA_character_, SlopeFacet = NA_character_,
    ThetaSD = 1.2, RaterSD = 0.45, CriterionSD = 0.30,
    StepSpan = 1.8
  ),
  list(
    Scenario = "generated_loose_mml_direct_gpcm",
    DataSource = "simulate_mfrm_data",
    Model = "GPCM", Method = "MML", Engine = "direct",
    NPerson = 30L, NRater = 3L, NCriterion = 3L,
    ScoreLevels = 4L, Maxit = 80L, Reltol = 1e-3,
    QuadPoints = 7L, StepFacet = "Criterion", SlopeFacet = "Criterion",
    ThetaSD = 1.1, RaterSD = 0.40, CriterionSD = 0.30,
    StepSpan = 1.5
  )
)

scenario_df <- do.call(rbind, lapply(scenario_table, as.data.frame))
scenario_df$ScenarioIndex <- seq_len(nrow(scenario_df))

make_stress_data <- function(sc, seed) {
  if (identical(sc$DataSource, "sample_mfrm_data")) {
    return(mfrmr:::sample_mfrm_data(seed = seed))
  }

  args <- list(
    n_person = sc$NPerson,
    n_rater = sc$NRater,
    n_criterion = sc$NCriterion,
    raters_per_person = sc$NRater,
    score_levels = sc$ScoreLevels,
    theta_sd = sc$ThetaSD,
    rater_sd = sc$RaterSD,
    criterion_sd = sc$CriterionSD,
    step_span = sc$StepSpan,
    model = sc$Model,
    seed = seed
  )
  if (!is.na(sc$StepFacet)) args$step_facet <- sc$StepFacet
  if (!is.na(sc$SlopeFacet)) args$slope_facet <- sc$SlopeFacet
  if (identical(sc$Model, "GPCM")) {
    args$slopes <- data.frame(
      SlopeFacet = paste0("C0", seq_len(sc$NCriterion)),
      Estimate = seq(0.8, 1.25, length.out = sc$NCriterion),
      stringsAsFactors = FALSE
    )
  }
  do.call(simulate_mfrm_data, args)
}

fit_stress_case <- function(sc, rep) {
  seed <- 730000L + sc$ScenarioIndex * 1000L + rep
  warnings <- character(0)
  start <- proc.time()[["elapsed"]]
  err <- NULL
  fit <- tryCatch(
    withCallingHandlers({
      dat <- make_stress_data(sc, seed)
      fit_args <- list(
        data = dat,
        person = "Person",
        facets = if (identical(sc$DataSource, "sample_mfrm_data")) {
          c("Rater", "Task", "Criterion")
        } else {
          c("Rater", "Criterion")
        },
        score = "Score",
        model = sc$Model,
        method = sc$Method,
        maxit = sc$Maxit,
        reltol = sc$Reltol,
        quad_points = sc$QuadPoints
      )
      if (!is.na(sc$StepFacet)) fit_args$step_facet <- sc$StepFacet
      if (!is.na(sc$SlopeFacet)) fit_args$slope_facet <- sc$SlopeFacet
      if (identical(sc$Method, "MML")) fit_args$mml_engine <- sc$Engine
      do.call(fit_mfrm, fit_args)
    }, warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w))
      invokeRestart("muffleWarning")
    }),
    error = function(e) {
      err <<- conditionMessage(e)
      NULL
    }
  )
  elapsed <- proc.time()[["elapsed"]] - start

  if (is.null(fit)) {
    return(data.frame(
      Scenario = sc$Scenario, Rep = rep, Seed = seed,
      Model = sc$Model, Method = sc$Method, Engine = sc$Engine,
      Maxit = sc$Maxit, Reltol = sc$Reltol, QuadPoints = sc$QuadPoints,
      Completed = FALSE, Error = err %||% NA_character_,
      WarningCount = length(warnings), Warnings = paste(warnings, collapse = " | "),
      ElapsedSec = elapsed,
      Converged = NA, ConvergenceStatus = NA_character_,
      ConvergenceSeverity = NA_character_, ConvergenceCode = NA_integer_,
      Iterations = NA_integer_, IterationsBasis = NA_character_,
      BFGSIterations = NA_integer_, FunctionEvaluations = NA_integer_,
      GradientEvaluations = NA_integer_, TerminalGradientSupNorm = NA_real_,
      TerminalGradientRMS = NA_real_, GradientReviewTolerance = NA_real_,
      LargeGradientWarning = NA, ReviewableWarning = NA,
      stringsAsFactors = FALSE
    ))
  }

  s <- fit$summary
  data.frame(
    Scenario = sc$Scenario, Rep = rep, Seed = seed,
    Model = sc$Model, Method = sc$Method, Engine = sc$Engine,
    Maxit = sc$Maxit, Reltol = sc$Reltol, QuadPoints = sc$QuadPoints,
    Completed = TRUE, Error = NA_character_,
    WarningCount = length(warnings), Warnings = paste(warnings, collapse = " | "),
    ElapsedSec = elapsed,
    Converged = isTRUE(s$Converged[1]),
    ConvergenceStatus = as.character(s$ConvergenceStatus[1] %||% NA_character_),
    ConvergenceSeverity = as.character(s$ConvergenceSeverity[1] %||% NA_character_),
    ConvergenceCode = as.integer(s$ConvergenceCode[1] %||% NA_integer_),
    Iterations = as.integer(s$Iterations[1] %||% NA_integer_),
    IterationsBasis = as.character(s$IterationsBasis[1] %||% NA_character_),
    BFGSIterations = as.integer(s$BFGSIterations[1] %||% NA_integer_),
    FunctionEvaluations = as.integer(s$FunctionEvaluations[1] %||% NA_integer_),
    GradientEvaluations = as.integer(s$GradientEvaluations[1] %||% NA_integer_),
    TerminalGradientSupNorm = as.numeric(s$TerminalGradientSupNorm[1] %||% NA_real_),
    TerminalGradientRMS = as.numeric(s$TerminalGradientRMS[1] %||% NA_real_),
    GradientReviewTolerance = as.numeric(s$GradientReviewTolerance[1] %||% NA_real_),
    LargeGradientWarning = isTRUE(s$LargeGradientWarning[1]),
    ReviewableWarning = isTRUE(s$ReviewableWarning[1]),
    stringsAsFactors = FALSE
  )
}

cat("Running convergence-reporting stress review with ", REPS,
    " replication(s) per scenario...\n", sep = "")
run_rows <- list()
row_i <- 0L
for (s_i in seq_len(nrow(scenario_df))) {
  sc <- scenario_df[s_i, , drop = FALSE]
  cat("  - ", sc$Scenario, "\n", sep = "")
  for (rep in seq_len(REPS)) {
    row_i <- row_i + 1L
    run_rows[[row_i]] <- fit_stress_case(sc, rep)
  }
}
runs <- do.call(rbind, run_rows)

is_direct <- runs$Completed & runs$Engine == "direct"
is_em <- runs$Completed & runs$Engine == "em"
large_gradient_condition <- runs$Completed & is_direct & runs$Converged &
  is.finite(runs$TerminalGradientSupNorm) &
  is.finite(runs$GradientReviewTolerance) &
  runs$TerminalGradientSupNorm > runs$GradientReviewTolerance
large_gradient_status <- runs$ConvergenceStatus %in% "converged_plateau_large_gradient"
large_gradient_observed <- any(large_gradient_condition, na.rm = TRUE)
large_gradient_status_observed <- any(large_gradient_status, na.rm = TRUE)
pass_direct <- runs$Completed & is_direct & runs$ConvergenceSeverity %in% "pass"
runs$LargeGradientStatus <- large_gradient_status
runs$FunctionEvaluationsGTMaxit <- runs$FunctionEvaluations > runs$Maxit
runs$DirectFunctionEvaluationsGTMaxit <- is_direct &
  runs$FunctionEvaluationsGTMaxit
runs$IterationLimitStatus <- runs$ConvergenceStatus %in% "iteration_limit"

check_row <- function(Check, Passed, Detail) {
  data.frame(Check = Check, Passed = isTRUE(Passed), Detail = Detail,
             stringsAsFactors = FALSE)
}

checks <- rbind(
  check_row(
    "all_runs_completed",
    all(runs$Completed),
    paste0(sum(runs$Completed), "/", nrow(runs), " fits completed")
  ),
  check_row(
    "direct_iterations_are_function_evaluations",
    all(runs$Iterations[is_direct] == runs$FunctionEvaluations[is_direct], na.rm = TRUE) &&
      all(runs$IterationsBasis[is_direct] == "function_evaluations", na.rm = TRUE),
    "Direct BFGS rows keep Iterations == FunctionEvaluations and basis == function_evaluations."
  ),
  check_row(
    "bfgs_iterations_mirror_gradient_evaluations",
    all(runs$BFGSIterations[is_direct] == runs$GradientEvaluations[is_direct], na.rm = TRUE),
    "Direct BFGS rows expose BFGSIterations as GradientEvaluations."
  ),
  check_row(
    "bfgs_iterations_do_not_exceed_maxit",
    all(runs$BFGSIterations[is_direct] <= runs$Maxit[is_direct], na.rm = TRUE),
    "BFGSIterations stayed within maxit while FunctionEvaluations could exceed it."
  ),
  check_row(
    "function_evaluations_can_exceed_maxit_observed",
    any(runs$FunctionEvaluations[is_direct] > runs$Maxit[is_direct], na.rm = TRUE),
    paste0(sum(runs$FunctionEvaluations[is_direct] > runs$Maxit[is_direct], na.rm = TRUE),
           " direct rows had FunctionEvaluations > maxit.")
  ),
  check_row(
    "large_gradient_plateau_mapping",
    large_gradient_observed &&
      all(large_gradient_status[large_gradient_condition], na.rm = TRUE) &&
      all(runs$ConvergenceSeverity[large_gradient_condition] == "review", na.rm = TRUE) &&
      all(runs$LargeGradientWarning[large_gradient_condition], na.rm = TRUE),
    paste0(sum(large_gradient_condition, na.rm = TRUE),
           " code-0 large-gradient direct rows were mapped to review.")
  ),
  check_row(
    "large_gradient_status_is_well_formed",
    large_gradient_status_observed &&
      all(runs$Converged[large_gradient_status], na.rm = TRUE) &&
      all(runs$ConvergenceSeverity[large_gradient_status] == "review", na.rm = TRUE) &&
      all(runs$TerminalGradientSupNorm[large_gradient_status] >
            runs$GradientReviewTolerance[large_gradient_status], na.rm = TRUE),
    paste0(sum(large_gradient_status, na.rm = TRUE),
           " rows carried converged_plateau_large_gradient status.")
  ),
  check_row(
    "pass_direct_rows_have_small_terminal_gradient",
    all(!is.finite(runs$TerminalGradientSupNorm[pass_direct]) |
          runs$TerminalGradientSupNorm[pass_direct] <=
            runs$GradientReviewTolerance[pass_direct], na.rm = TRUE),
    paste0(sum(pass_direct, na.rm = TRUE),
           " direct rows had pass severity.")
  ),
  check_row(
    "iteration_limit_stress_observed",
    any(runs$Scenario == "generated_lowmax_jml_rsm" &
          runs$ConvergenceStatus == "iteration_limit" &
          runs$ConvergenceSeverity == "fail", na.rm = TRUE),
    "Low-maxit generated RSM rows exercised the iteration-limit failure path."
  ),
  check_row(
    "em_basis_rows_remain_distinct",
    all(runs$IterationsBasis[is_em] == "em_iterations", na.rm = TRUE) &&
      all(is.na(runs$BFGSIterations[is_em])),
    "MML EM rows use em_iterations and do not report BFGSIterations."
  )
)

scenario_summary <- aggregate(
  cbind(
    Completed = runs$Completed,
    Converged = runs$Converged,
    LargeGradient = runs$LargeGradientStatus,
    DirectFunctionEvaluationsGTMaxit = runs$DirectFunctionEvaluationsGTMaxit,
    IterationLimit = runs$IterationLimitStatus
  ) ~ Scenario + Model + Method + Engine + Maxit + Reltol,
  data = runs,
  FUN = function(x) sum(x %in% TRUE, na.rm = TRUE)
)
scenario_summary$Runs <- as.integer(vapply(
  split(runs$Completed, runs$Scenario),
  length,
  integer(1)
)[scenario_summary$Scenario])

write.csv(runs,
          file.path(OUT_DIR, "convergence-reporting-stress-0.2.2-runs.csv"),
          row.names = FALSE)
write.csv(checks,
          file.path(OUT_DIR, "convergence-reporting-stress-0.2.2-checks.csv"),
          row.names = FALSE)
write.csv(scenario_summary,
          file.path(OUT_DIR, "convergence-reporting-stress-0.2.2-summary.csv"),
          row.names = FALSE)

status <- if (all(checks$Passed)) "PASS" else "REVIEW"
md <- c(
  "# Convergence-reporting stress review 0.2.2",
  "",
  paste0("- Status: ", status),
  paste0("- Repetitions per scenario: ", REPS),
  paste0("- Fits completed: ", sum(runs$Completed), "/", nrow(runs)),
  paste0("- Direct rows with FunctionEvaluations > maxit: ",
         sum(runs$FunctionEvaluations[is_direct] > runs$Maxit[is_direct], na.rm = TRUE)),
  paste0("- Direct code-0 large-gradient review rows: ",
         sum(large_gradient_status, na.rm = TRUE)),
  paste0("- Direct pass-severity rows: ", sum(pass_direct, na.rm = TRUE)),
  "",
  "## Checks",
  "",
  paste0("- ", ifelse(checks$Passed, "PASS", "REVIEW"), " `", checks$Check,
         "`: ", checks$Detail),
  "",
  "## Scenario Summary",
  "",
  paste(
    utils::capture.output(print(scenario_summary, row.names = FALSE)),
    collapse = "\n"
  ),
  "",
  "## Output Files",
  "",
  "- `convergence-reporting-stress-0.2.2-runs.csv`",
  "- `convergence-reporting-stress-0.2.2-checks.csv`",
  "- `convergence-reporting-stress-0.2.2-summary.csv`"
)
writeLines(md, file.path(OUT_DIR, "convergence-reporting-stress-0.2.2.md"))

cat("\nStress review status: ", status, "\n", sep = "")
print(checks, row.names = FALSE)
cat("\nWrote outputs to: ", OUT_DIR, "\n", sep = "")

if (!all(checks$Passed)) {
  quit(status = 1L)
}
