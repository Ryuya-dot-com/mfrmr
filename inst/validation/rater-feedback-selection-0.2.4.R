# A12: bounded evaluation of a screening -> removal -> refit procedure.
# Run from the package root. This is not an automatic-exclusion recommendation.
pkgload::load_all('.', quiet = TRUE)
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else
  'validation-results/roadmap-followthrough-20260922/selection-study'
dir.create(out, recursive = TRUE, showWarnings = FALSE)
protocol <- list(
  seeds = 2026092301:2026092400, persons = 120L,
  rater_truth = setNames(c(-.8, -.4, -.1, .1, .4, .8), paste0('R', 1:6)),
  criterion_truth = c(-.3, 0, .3), thresholds = c(-1, 0, 1),
  designs = c('crossed', 'rotating'), scenarios = c('null', 'inconsistent_R6'),
  contamination_probability = .5, misfit_band = c(.5, 1.5),
  method = 'MML', model = 'RSM', quad_points = 61L, maxit = 400L,
  estimand = 'Centered Person EAP error against generated ability; no absolute decision target',
  rule = 'Remove raters with Infit or Outfit outside the fixed band, then refit retained rows',
  stopping = '100 fixed seeds per condition; retain failures; no retuning or optional stopping',
  uncertainty = 'MCSE and binomial intervals across independent replications; raters within a replication are not independent units'
)
source_files <- c(list.files('R', '[.]R$', full.names = TRUE),
  'inst/validation/rater-feedback-selection-0.2.4.R')
identity <- list(protocol = protocol, source = tools::md5sum(source_files))
protocol_path <- file.path(out, 'protocol.rds')
if (file.exists(protocol_path)) {
  if (!identical(readRDS(protocol_path), identity)) {
    stop('The saved study has different source or settings. Use a new output directory.')
  }
} else saveRDS(identity, protocol_path)
writeLines(capture.output(str(protocol)), file.path(out, 'protocol.txt'))
writeLines(capture.output(sessionInfo()), file.path(out, 'session-info.txt'))

generate <- function(seed) {
  set.seed(seed)
  people <- sprintf('P%03d', seq_len(protocol$persons))
  theta <- setNames(rnorm(length(people)), people)
  d <- expand.grid(Person = people, Rater = names(protocol$rater_truth),
    Criterion = paste0('C', 1:3), stringsAsFactors = FALSE)
  p <- match(d$Person, people); r <- match(d$Rater, names(protocol$rater_truth))
  eta <- theta[p] - protocol$rater_truth[r] - protocol$criterion_truth[match(d$Criterion, paste0('C',1:3))]
  logw <- cbind(0, eta + 1, 2 * eta + 1, 3 * eta)
  prob <- exp(logw - apply(logw, 1, max)); prob <- prob / rowSums(prob)
  d$Score <- rowSums(runif(nrow(d)) > t(apply(prob, 1, cumsum)))
  contaminated <- d
  replace <- d$Rater == 'R6' & runif(nrow(d)) < protocol$contamination_probability
  contaminated$Score[replace] <- sample(0:3, sum(replace), replace = TRUE)
  first <- (p - 1L) %% 6L + 1L
  rotating <- r == first | r == first %% 6L + 1L
  list(null = d, inconsistent_R6 = contaminated, rotating = rotating, theta = theta)
}

fit_ratings <- function(d) fit_mfrm(d, 'Person', c('Rater','Criterion'), 'Score',
  model = protocol$model, method = protocol$method, rating_min = 0, rating_max = 3,
  quad_points = protocol$quad_points, maxit = protocol$maxit)
centered_error <- function(fit, theta, persons) {
  t <- fit$facets$person
  values <- t$Estimate[match(persons, t$Person)]
  truth <- theta[persons]
  sqrt(mean(((values - mean(values)) - (truth - mean(truth)))^2))
}

one <- function(generated, design, scenario, seed) {
  d <- generated[[scenario]]
  if (design == 'rotating') d <- d[generated$rotating, ]
  result <- data.frame(Seed = seed, Design = design, Scenario = scenario,
    Ratings = nrow(d), ScreenAvailable = FALSE, FitReady = FALSE,
    AnyFalseFlag = NA, TargetFlag = NA, RemovedRaters = NA_integer_,
    RetainedPersons = NA_integer_, RefitAvailable = FALSE, RefitReady = FALSE,
    BeforeRMSE = NA_real_, AfterRMSE = NA_real_, PairedRMSEChange = NA_real_,
    Stage = 'fit', Error = '', Seconds = NA_real_)
  warnings <- character(); start <- proc.time()[['elapsed']]
  error <- tryCatch(withCallingHandlers({
    fit <- fit_ratings(d)
    result$FitReady <- isTRUE(fit$summary$InferenceReady)
    result$Stage <- 'diagnostics'
    dx <- diagnose_mfrm(fit, residual_pca = 'none')
    tab <- dx$measures[dx$measures$Facet == 'Rater', ]
    stopifnot(nrow(tab) == 6L, all(is.finite(tab$Infit)), all(is.finite(tab$Outfit)))
    flag <- tab$Infit < .5 | tab$Infit > 1.5 | tab$Outfit < .5 | tab$Outfit > 1.5
    result$ScreenAvailable <- TRUE
    null_raters <- if (scenario == 'null') rep(TRUE, 6) else tab$Level != 'R6'
    result$AnyFalseFlag <- any(flag[null_raters])
    result$TargetFlag <- flag[tab$Level == 'R6']
    removed <- tab$Level[flag]
    result$RemovedRaters <- length(removed)
    retained <- d[!d$Rater %in% removed, ]
    persons <- sort(unique(retained$Person))
    result$RetainedPersons <- length(persons)
    result$Stage <- 'refit'
    refit <- if (length(removed)) fit_ratings(retained) else fit
    result$RefitAvailable <- TRUE
    result$RefitReady <- isTRUE(refit$summary$InferenceReady)
    result$BeforeRMSE <- centered_error(fit, generated$theta, persons)
    result$AfterRMSE <- centered_error(refit, generated$theta, persons)
    result$PairedRMSEChange <- result$AfterRMSE - result$BeforeRMSE
    stopifnot(is.finite(result$PairedRMSEChange))
    result$Stage <- 'complete'
    NULL
  }, warning = function(w) {
    warnings <<- c(warnings, conditionMessage(w)); invokeRestart('muffleWarning')
  }), error = function(e) e)
  if (inherits(error, 'error')) result$Error <- conditionMessage(error)
  result$Seconds <- proc.time()[['elapsed']] - start
  list(result = result, warnings = unique(warnings))
}

for (seed in protocol$seeds) {
  generated <- generate(seed)
  for (design in protocol$designs) for (scenario in protocol$scenarios) {
    path <- file.path(out, paste(seed, design, scenario, 'rds', sep = '.'))
    if (file.exists(path)) {
      stopifnot(identical(readRDS(path)$identity, identity))
    } else {
      value <- one(generated, design, scenario, seed)
      value$identity <- identity
      staging <- tempfile('cell-', tmpdir = out)
      saveRDS(value, staging)
      stopifnot(file.rename(staging, path))
    }
  }
  cat(seed, 'complete\n'); flush.console()
}
paths <- list.files(out, '^2026.*[.]rds$', full.names = TRUE)
rows <- do.call(rbind, lapply(paths, function(path) readRDS(path)$result))
write.csv(rows, file.path(out, 'replicates.csv'), row.names = FALSE)
summary_rows <- lapply(split(rows, list(rows$Design, rows$Scenario), drop = TRUE), function(x) {
  result <- data.frame(Design = x$Design[1], Scenario = x$Scenario[1], Attempts = nrow(x),
    Screens = sum(x$ScreenAvailable), ReadyFits = sum(x$FitReady),
    CompletedProcedures = sum(x$RefitAvailable), ReadyPostSelectionFits = sum(x$RefitReady),
    RefittedRuns = sum(x$RefitAvailable & x$RemovedRaters > 0, na.rm = TRUE),
    UnchangedRuns = sum(x$RemovedRaters == 0, na.rm = TRUE),
    RunsLosingPersons = sum(x$RetainedPersons < protocol$persons, na.rm = TRUE),
    MinimumRetainedPersons = min(x$RetainedPersons, na.rm = TRUE))
  for (metric in c('AnyFalseFlag', 'TargetFlag')) {
    values <- x[[metric]][!is.na(x[[metric]])]; n <- length(values); k <- sum(values)
    result[[metric]] <- if (n) k / n else NA_real_
    result[[paste0(metric,'MCSE')]] <- if (n) sqrt(k/n*(1-k/n)/n) else NA_real_
    interval <- if (n) binom.test(k,n)$conf.int else c(NA,NA)
    result[[paste0(metric,'Lower')]] <- interval[1]
    result[[paste0(metric,'Upper')]] <- interval[2]
  }
  values <- x$PairedRMSEChange[is.finite(x$PairedRMSEChange)]
  result$ScorePairs <- length(values)
  result$MeanRMSEChange <- mean(values)
  result$RMSEChangeMCSE <- sd(values)/sqrt(length(values))
  result
})
write.csv(do.call(rbind, summary_rows), file.path(out,'summary.csv'), row.names = FALSE)
print(do.call(rbind, summary_rows), row.names = FALSE)
