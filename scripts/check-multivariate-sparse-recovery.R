# Run from the package root: Rscript scripts/check-multivariate-sparse-recovery.R
# Optional arguments: repetitions (default 1000), output directory, profile.
# Profiles other than baseline evaluate only the Rotating roster, retaining
# the 960-rating budget; they do not repeat the original six conditions.
# This bounded Gaussian experiment evaluates the public MINQUE(0) API. It is
# not a release test, a missingness correction, or a sparse-roster D-study.
args <- commandArgs(trailingOnly = TRUE)
repetitions <- if (length(args)) as.integer(args[1]) else 1000L
stopifnot(length(repetitions) == 1L, !is.na(repetitions), repetitions >= 2L)
profile <- if (length(args) >= 3L) args[3] else "baseline"
settings <- switch(profile,
  baseline = c(Raters = 12L, Tasks = 8L, RTScale = 1),
  raters6 = c(Raters = 6L, Tasks = 8L, RTScale = 1),
  raters24 = c(Raters = 24L, Tasks = 8L, RTScale = 1),
  tasks4 = c(Raters = 12L, Tasks = 4L, RTScale = 1),
  tasks12 = c(Raters = 12L, Tasks = 12L, RTScale = 1),
  small_rt = c(Raters = 12L, Tasks = 8L, RTScale = .05),
  zero_rt = c(Raters = 12L, Tasks = 8L, RTScale = 0),
  stop("Unknown profile."))
output_dir <- if (length(args) >= 2L) args[2] else
  paste0("validation-results/multivariate-sparse-recovery-20260921",
    if (profile != "baseline") paste0("-", profile) else "")
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
if (file.exists(file.path(output_dir, "results.rds"))) stop("Choose a new output directory; results already exist.")
pkgload::load_all(quiet = TRUE)

# Reuse the covariance model already checked by independent ANOVA calculations;
# evaluate only the fixture definition, without running its test file.
fixture <- new.env()
eval(parse("tests/testthat/test-multivariate-gtheory.R")[[1]], fixture)
components <- fixture$mvgt_fixture()$components
components$`Rater:Task` <- components$`Rater:Task` * settings[["RTScale"]]
scores <- c("Content", "Organization")
n_person <- 120L
n_rater <- as.integer(settings[["Raters"]])
n_task <- as.integer(settings[["Tasks"]])
full <- expand.grid(Person = seq_len(n_person), Rater = seq_len(n_rater), Task = seq_len(n_task))
groups <- list(Person = full$Person, Rater = full$Rater, Task = full$Task,
  `Person:Rater` = full$Person + n_person * (full$Rater - 1L),
  `Person:Task` = full$Person + n_person * (full$Task - 1L),
  `Rater:Task` = full$Rater + n_rater * (full$Task - 1L),
  Residual = seq_len(nrow(full)))
stopifnot(identical(names(groups), names(components)))
roots <- lapply(components, function(a) if (all(a == 0)) a else chol(a))
stopifnot(all(vapply(seq_along(roots), function(i)
  isTRUE(all.equal(crossprod(roots[[i]]), components[[i]])), logical(1))))

# All three incomplete rosters have 120 persons, four tasks per person,
# two distinct raters per performance, and exactly 960 assigned ratings.
slots <- expand.grid(Person = seq_len(n_person), Slot = 0:3, Second = 0:1)
# Retain the reference's Person/Task assignments when varying rater counts.
# Twelve-person task cohorts are fixed independently of the rater pool size.
task <- (floor((slots$Person - 1L) / 12L) + slots$Slot) %% n_task + 1L
rotating_rater <- ((slots$Person - 1L) + (slots$Slot + slots$Second) %% 4L) %% n_rater + 1L
paired_rater <- ((slots$Person - 1L) + slots$Second) %% n_rater + 1L
concentrated_rater <- ifelse(slots$Person <= n_person / 2L, slots$Second + 1L,
  ((slots$Person - 1L) + slots$Second) %% (n_rater - 2L) + 3L)
row_index <- function(person, rater, task) person + n_person * (rater - 1L) +
  n_person * n_rater * (task - 1L)
rosters <- list(Complete = seq_len(nrow(full)),
  Rotating = row_index(slots$Person, rotating_rater, task),
  RepeatedPair = row_index(slots$Person, paired_rater, task),
  Concentrated = row_index(slots$Person, concentrated_rater, task))
rosters <- lapply(rosters, sort)
for (idx in rosters[-1L]) {
  rows <- full[idx, ]
  stopifnot(length(idx) == 960L, !anyDuplicated(idx),
    length(unique(rows$Rater)) == n_rater, length(unique(rows$Task)) == n_task,
    all(table(rows$Person) == 8L), all(table(paste(rows$Person, rows$Task)) == 2L))
}
layout_summary <- do.call(rbind, lapply(names(rosters), function(name) {
  rows <- full[rosters[[name]], ]
  person_raters <- vapply(split(rows$Rater, rows$Person), function(r) length(unique(r)), integer(1))
  data.frame(Case = name, AssignedRows = nrow(rows),
    MinRaterLoad = min(table(rows$Rater)), MaxRaterLoad = max(table(rows$Rater)),
    MinTaskLoad = min(table(rows$Task)), MaxTaskLoad = max(table(rows$Task)),
    MinRatersPerPerson = min(person_raters), MaxRatersPerPerson = max(person_raters))
}))

# A same-budget counterexample: all eight tasks but one rater per performance.
# Person:Task and Residual have identical kernels; do not repeat this known
# structural failure in every Monte Carlo replication.
single_failure <- NULL
if (profile == "baseline") {
  single <- expand.grid(Person = seq_len(n_person), Task = seq_len(n_task))
  single$Rater <- ((single$Person - 1L) + (single$Task - 1L) %% 4L) %% n_rater + 1L
  single$Content <- sin(seq_len(nrow(single)))
  single_failure <- tryCatch({
    mfrm_multivariate_gstudy(single, "Content", method = "minque0")
    NA_character_
  }, error = function(e) conditionMessage(e))
  stopifnot(nrow(single) == 960L, grepl("Cannot separate covariance components", single_failure))
}

# Target: future COMPLETE design, two common raters and six common tasks.
# Compute truth directly, independently of the production projection code.
design_grid <- data.frame(Raters = 2L, Tasks = 6L)
weights <- cbind(Equal = c(Content = .5, Organization = .5),
  Difference = c(Content = 1, Organization = -1))
vectors <- cbind(diag(2), weights)
colnames(vectors) <- c(scores, colnames(weights))
relative <- components[[4]] / 2 + components[[5]] / 6 + components[[7]] / 12
absolute <- relative + components[[2]] / 2 + components[[3]] / 6 + components[[6]] / 12
measures <- c("UniverseVariance", "RelativeErrorVariance", "AbsoluteErrorVariance",
  "G", "Phi", "RelativeSEM", "AbsoluteSEM")
projection_truth <- t(vapply(seq_len(ncol(vectors)), function(j) {
  w <- vectors[, j]
  u <- drop(crossprod(w, components$Person %*% w))
  r <- drop(crossprod(w, relative %*% w))
  a <- drop(crossprod(w, absolute %*% w))
  c(u, r, a, u / (u + r), u / (u + a), sqrt(r), sqrt(a))
}, numeric(7)))
upper <- upper.tri(components[[1]], diag = TRUE)
metric_names <- c(unlist(lapply(names(components), function(s)
  paste("Component", s, c("Content", "Content,Organization", "Organization"), sep = "/"))),
  unlist(lapply(colnames(vectors), function(s) paste("D", s, measures, sep = "/"))))
truth <- setNames(c(unlist(lapply(components, function(a) a[upper])),
  as.vector(t(projection_truth))), metric_names)
cases <- if (profile == "baseline") c(names(rosters), "MCAR25", "HighScoreMissing25") else "Rotating"
trial_rows <- vector("list", repetitions * length(cases))
estimates <- matrix(NA_real_, repetitions * length(cases), length(truth),
  dimnames = list(NULL, names(truth)))
seed_base <- 921260000L
RNGkind("L'Ecuyer-CMRG", "Inversion", "Rejection")
started <- proc.time()[["elapsed"]]
for (replicate in seq_len(repetitions)) {
  set.seed(seed_base + replicate)
  y <- matrix(0, nrow(full), length(scores))
  for (j in seq_along(groups)) {
    g <- groups[[j]]
    effects <- matrix(rnorm(max(g) * length(scores)), ncol = length(scores)) %*% roots[[j]]
    y <- y + effects[g, , drop = FALSE]
  }
  full[scores] <- sweep(y, 2L, c(10, 20), "+")
  # Shared generated ratings pair the layout comparisons. Neither design nor
  # MCAR uses the scores. Outcome-dependent deletion deliberately does.
  random_missing <- sample.int(length(rosters$Rotating), 240L)
  high_missing <- order(full$Content[rosters$Rotating], decreasing = TRUE)[seq_len(240L)]
  for (case in cases) {
    idx <- rosters[[if (case %in% names(rosters)) case else "Rotating"]]
    data <- full[idx, ]
    if (case == "MCAR25") data$Content[random_missing] <- NA_real_
    if (case == "HighScoreMissing25") data$Content[high_missing] <- NA_real_
    # Organization stays observed in these rows; omission must use one shared
    # multivariate sample. No support repair or replacement sampling is used.
    position <- (replicate - 1L) * length(cases) + match(case, cases)
    g <- tryCatch(mfrm_multivariate_gstudy(data, scores, method = "minque0", missing = "omit"),
      error = function(e) e)
    returned <- !inherits(g, "error")
    result <- data.frame(Replicate = replicate, Seed = seed_base + replicate, Case = case,
      AssignedRows = nrow(data), UsedRows = sum(complete.cases(data)), FitReturned = returned,
      Persons = NA_integer_, Raters = NA_integer_, Tasks = NA_integer_, Rank = NA_integer_,
      ConditionNumber = NA_real_, NonPSD = NA,
      EqualGAvailable = FALSE, EqualPhiAvailable = FALSE,
      DifferenceGAvailable = FALSE, DifferencePhiAvailable = FALSE,
      Error = if (returned) "" else conditionMessage(g))
    if (returned) {
      if (replicate == 1L && case == "Complete") {
        anova <- mfrm_multivariate_gstudy(data, scores)
        stopifnot(isTRUE(all.equal(g$components, anova$components, tolerance = 1e-10)))
      }
      d <- mfrm_multivariate_d_study(g, design_grid, weights)$coefficients
      stopifnot(identical(d$Score, colnames(vectors)),
        g$data_usage$counts[["UsedRows"]] == result$UsedRows)
      result[c("Persons", "Raters", "Tasks")] <- as.list(unname(g$design$counts))
      result$Rank <- g$estimation$rank
      result$ConditionNumber <- g$estimation$condition_number
      result$NonPSD <- !all(g$component_diagnostics$PositiveSemidefinite)
      # A partially available row can still supply one coefficient. Do not
      # use its overall Status to count either G or Phi.
      for (composite in colnames(weights)) for (metric in c("G", "Phi")) {
        result[[paste0(composite, metric, "Available")]] <-
          d[[paste0(metric, "Status")]][d$Kind == "Composite" & d$Score == composite] == "Available"
      }
      estimates[position, ] <- c(unlist(lapply(g$components, function(a) a[upper])),
        as.vector(t(as.matrix(d[measures]))))
    }
    trial_rows[[position]] <- result
  }
  if (replicate %% 100L == 0L) cat(profile, ": completed", replicate, "of", repetitions, "replications\n")
}
trials <- do.call(rbind, trial_rows)
case_summary <- do.call(rbind, lapply(cases, function(case) {
  rows <- trials[trials$Case == case, ]
  data.frame(Case = case, Repetitions = nrow(rows), AssignedRows = rows$AssignedRows[1],
    UsedRows = rows$UsedRows[1], FitsReturned = sum(rows$FitReturned),
    NonPSD = sum(rows$NonPSD, na.rm = TRUE),
    EqualGAvailable = sum(rows$EqualGAvailable), EqualPhiAvailable = sum(rows$EqualPhiAvailable),
    DifferenceGAvailable = sum(rows$DifferenceGAvailable),
    DifferencePhiAvailable = sum(rows$DifferencePhiAvailable),
    MinCondition = min(rows$ConditionNumber, na.rm = TRUE),
    MaxCondition = max(rows$ConditionNumber, na.rm = TRUE),
    MinPersons = min(rows$Persons, na.rm = TRUE), MinRaters = min(rows$Raters, na.rm = TRUE),
    MinTasks = min(rows$Tasks, na.rm = TRUE))
}))
metric_summary <- do.call(rbind, lapply(cases, function(case) {
  ids <- which(trials$Case == case)
  do.call(rbind, lapply(seq_along(truth), function(j) {
    values <- estimates[ids, j]
    ok <- is.finite(values)
    error <- values[ok] - truth[j]
    n <- sum(ok)
    rmse <- if (n) sqrt(mean(error^2)) else NA_real_
    data.frame(Case = case, Metric = names(truth)[j], Truth = unname(truth[j]),
      Repetitions = length(ids), Returned = n, Missing = length(ids) - n,
      Bias = if (n) mean(error) else NA_real_, SD = if (n > 1L) sd(values[ok]) else NA_real_,
      BiasMCSE = if (n > 1L) sd(error) / sqrt(n) else NA_real_, RMSE = rmse,
      RMSEMCSE = if (n > 1L && rmse > 0) sd(error^2) / (2 * rmse * sqrt(n)) else NA_real_)
  }))
}))
source_files <- c("scripts/check-multivariate-sparse-recovery.R", "R/api-multivariate-gtheory.R",
  "tests/testthat/test-multivariate-gtheory.R")
results <- list(profile = profile, settings = settings,
  repetitions = repetitions, seed_base = seed_base, rng = RNGkind(),
  dimensions = c(Person = n_person, Rater = n_rater, Task = n_task), components = components,
  rosters = rosters, layout_summary = layout_summary, single_rater_failure = single_failure,
  design_grid = design_grid, weights = weights, truth = truth, trials = trials, estimates = estimates,
  case_summary = case_summary, metric_summary = metric_summary,
  seconds = proc.time()[["elapsed"]] - started, source_md5 = tools::md5sum(source_files),
  session = sessionInfo())
saveRDS(results, file.path(output_dir, "results.rds"))
write.csv(case_summary, file.path(output_dir, "case-summary.csv"), row.names = FALSE)
write.csv(metric_summary, file.path(output_dir, "metric-summary.csv"), row.names = FALSE)
print(case_summary, row.names = FALSE)
cat("Elapsed seconds:", results$seconds, "\nResults:", normalizePath(output_dir), "\n")
