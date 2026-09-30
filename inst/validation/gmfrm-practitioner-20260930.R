# Applied workflow review on an external empirical dataset, not a recovery study.
# Run from the package root. No download, score simulation, or automatic model ranking.
out <- "validation-results/gmfrm-practitioner-20260930"
path <- file.path(out, "joint-fit.rds")
if (file.exists(path)) stop("A fitted case already exists; retain it instead of silently refitting.")
pkgload::load_all(".", quiet = TRUE)
stopifnot(requireNamespace("sirt", quietly = TRUE))
dir.create(out, recursive = TRUE, showWarnings = FALSE)
env <- new.env(parent = emptyenv())
utils::data("data.ratings1", package = "sirt", envir = env)
wide <- env$data.ratings1
criteria <- paste0("k", 1:5)
ratings <- do.call(rbind, lapply(criteria, function(criterion) data.frame(
  Person = as.character(wide$idstud), Rater = as.character(wide$rater),
  Criterion = criterion, Score = wide[[criterion]], stringsAsFactors = FALSE)))
rownames(ratings) <- NULL
stopifnot(nrow(wide) == 274L, nrow(ratings) == 1370L,
  !anyNA(ratings), !anyDuplicated(ratings[c("Person", "Rater", "Criterion")]),
  all(ratings$Score %in% 0:3), length(unique(ratings$Person)) == 135L,
  length(unique(ratings$Rater)) == 7L)
# Preserve the complete external table and source version. Its unused factor
# levels are not observed raters; no empirical rows are removed or fabricated.
saveRDS(wide, file.path(out, "sirt-data.ratings1.rds"))
sources <- c("DESCRIPTION", list.files("R", pattern = "[.]R$", full.names = TRUE),
  "inst/validation/gmfrm-practitioner-20260930.R")
manifest <- list(source = "sirt::data.ratings1",
  version = as.character(utils::packageVersion("sirt")),
  provenance = "2009 Austrian grade-8 German writing survey; sirt data.ratings help",
  empirical = TRUE, known_generating_parameters = FALSE,
  planned_assignment_roster_available = FALSE,
  source_hash = tools::md5sum(sources),
  data_hash = tools::md5sum(file.path(out, "sirt-data.ratings1.rds")))
saveRDS(manifest, file.path(out, "manifest.rds"))
writeLines(capture.output(sessionInfo()), file.path(out, "session-info.txt"))
review <- describe_mfrm_data(ratings, person = "Person",
  facets = c("Criterion", "Rater"), score = "Score", rating_min = 0,
  rating_max = 3, category_policy = "preserve", rater_facet = "Rater")
saveRDS(review, file.path(out, "data-review.rds"))
assignment <- xtabs(~ Person + Rater, unique(ratings[c("Person", "Rater")]))
overlap <- crossprod(assignment > 0)
roster <- apply(assignment > 0, 1, function(x) paste(colnames(assignment)[x], collapse = "+"))
write.csv(as.data.frame(table(Roster = roster)), file.path(out, "observed-rosters.csv"), row.names = FALSE)
write.csv(overlap, file.path(out, "rater-overlap.csv"))
write.csv(as.data.frame(xtabs(~ Rater + Score, ratings)), file.path(out, "rater-categories.csv"), row.names = FALSE)
write.csv(as.data.frame(xtabs(~ Rater + Criterion + Score, ratings)),
  file.path(out, "cell-categories.csv"), row.names = FALSE)
design <- data.frame(Persons = nrow(assignment), Raters = ncol(assignment),
  Criteria = length(criteria), ObservedRatings = nrow(ratings),
  PossibleCells = nrow(assignment) * ncol(assignment) * length(criteria),
  MinRatersPerPerson = min(rowSums(assignment)), MaxRatersPerPerson = max(rowSums(assignment)),
  MinPersonsPerRater = min(colSums(assignment)), MaxPersonsPerRater = max(colSums(assignment)),
  UnusedRaterFactorLevels = nlevels(wide$rater) - ncol(assignment),
  ZeroRaterCategories = sum(xtabs(~ Rater + Score, ratings) == 0),
  ZeroRaterCriterionCategories = sum(xtabs(~ Rater + Criterion + Score, ratings) == 0),
  SingletonRosters = sum(table(roster) == 1L))
write.csv(design, file.path(out, "design.csv"), row.names = FALSE)
print(design, row.names = FALSE)

# Predeclared numerical procedure for this single applied case. Keep failures;
# no subset chosen after fitting and no retry until a result looks favorable.
args <- list(data = ratings, person = "Person", facets = c("Criterion", "Rater"),
  score = "Score", model = "GPCM", method = "MML",
  slope_facet = c("Criterion", "Rater"), step_facet = "Rater",
  noncenter_facet = "Rater", gpcm_mml_identification = "fixed_standard_normal",
  mml_engine = "em", rating_min = 0, rating_max = 3,
  category_policy = "preserve", quad_points = 61L, maxit = 500L, em_score_tol = 1e-7)
saveRDS(args, file.path(out, "fit-call.rds"))
capture <- function(expr) {
  warnings <- character()
  elapsed <- system.time(value <- tryCatch(withCallingHandlers(expr,
    warning = function(w) { warnings <<- c(warnings, conditionMessage(w)); invokeRestart("muffleWarning") }),
    error = function(e) e))[["elapsed"]]
  list(value = value, warnings = warnings, elapsed = elapsed)
}
fitted <- capture(do.call(fit_mfrm, args))
saveRDS(fitted, path)
if (inherits(fitted$value, "error")) stop(conditionMessage(fitted$value))
fit <- fitted$value
write.csv(fit$summary, file.path(out, "fit-summary.csv"), row.names = FALSE)
write.csv(fit$slopes, file.path(out, "slopes.csv"), row.names = FALSE)
print(fit$summary[c("Converged", "Persons", "LogLik")], row.names = FALSE)
if (!isTRUE(fit$summary$Converged)) stop("Empirical case did not converge; downstream results not computed.")

# One explicit matched grid refit checks integration dependence on the same data.
# A different grid is not a second empirical dataset or independent validation.
quadrature <- capture(mml_quadrature_sensitivity(fit, ratings,
  quad_points = c(61L, 121L)))
saveRDS(quadrature, file.path(out, "quadrature-review.rds"))
if (!inherits(quadrature$value, "error")) {
  write.csv(quadrature$value$summary, file.path(out, "quadrature-summary.csv"), row.names = FALSE)
  write.csv(quadrature$value$runs, file.path(out, "quadrature-runs.csv"), row.names = FALSE)
}
diagnostics <- capture(mfrm_response_diagnostics(fit,
  group_by = c("Criterion", "Rater"), quad_points = 121L))
saveRDS(diagnostics, file.path(out, "response-diagnostics.rds"))
if (!inherits(diagnostics$value, "error")) {
  write.csv(diagnostics$value$measures, file.path(out, "descriptive-measures.csv"), row.names = FALSE)
  write.csv(diagnostics$value$rows, file.path(out, "descriptive-rows.csv"), row.names = FALSE)
}
stopifnot(identical(manifest$source_hash, tools::md5sum(sources)))
cat("Applied case retained; empirical truth, predictive validity and rater competence are not established.\n")

# Retain unavailable empirical outputs through the existing report and RDS path.
if (!inherits(diagnostics$value, "error")) {
  context <- expand.grid(Theta = seq(-2, 2, length.out = 41L),
    Criterion = unique(ratings$Criterion), Rater = unique(ratings$Rater))
  curves <- mfrm_curve_intervals(fit, context)
  intervals <- list(curves = curves)
  if (!inherits(quadrature$value, "error"))
    intervals$slopes <- quadrature$value$intervals$q61
  results <- mfrm_results(fit, include = c("fit", "plots"), compute = "never",
    intervals = intervals, response_diagnostics = diagnostics$value)
  report <- mfrm_report(results)
  saveRDS(results, file.path(out, "results.rds"))
  saveRDS(report, file.path(out, "report.rds"))
  writeLines(report$markdown, file.path(out, "report.md"))
  reopened <- readRDS(file.path(out, "results.rds"))
  stopifnot(identical(reopened$tables, results$tables),
    identical(reopened$response_diagnostics, diagnostics$value))
}
