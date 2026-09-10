# Targeted follow-up; preserve the original run and reuse its evaluators.
source('inst/validation/population-variance-profile-0.2.4.R')

population_profile_refinement <- function(input, directory) {
  pkgload::load_all('.', quiet = TRUE)
  main <- readRDS(input)
  stopifnot(identical(main$payload, tools::md5sum(names(main$payload))))
  paths <- c(names(main$payload), 'inst/validation/population-variance-profile-refinement-0.2.4.R')
  payload <- tools::md5sum(paths)
  dir.create(directory, recursive = TRUE, showWarnings = FALSE)
  plan <- expand.grid(Case = names(main$cases), Variance = c(16, 64),
    Q = c(481L, 961L), Start = c('retained', 'zero'), stringsAsFactors = FALSE)
  stopifnot(nrow(plan) == 32L)
  write.csv(plan, file.path(directory, 'plan.csv'), row.names = FALSE)
  started <- Sys.time(); rows <- results <- list()
  for (i in seq_len(nrow(plan))) {
    p <- plan[i, ]; case <- main$cases[[p$Case]]; fit <- case$fit
    context <- population_profile_context(fit, p$Variance, p$Q)
    dense <- population_profile_context(fit, p$Variance, 1921L)
    start <- if (p$Start == 'retained') fit$opt$par else rep(0, length(fit$opt$par))
    warnings <- errors <- character()
    z <- tryCatch(withCallingHandlers({
      opt <- mfrmr_gzb_p1c_optimize_boundary(context, start, maxit = 400L, reltol = 1e-12)
      if (!opt$returned) stop('No finite nuisance vector returned.')
      par <- context$embed(opt$par)
      list(opt = opt, par = par, objective = context$fn(par), dense = dense$fn(par),
        reference = population_profile_reference(case, par, p$Variance),
        dense_gradient = dense$gr(par)[opt$nuisance_index])
    }, warning = function(w) {warnings <<- c(warnings, conditionMessage(w)); invokeRestart('muffleWarning')}),
      error = function(e) {errors <<- conditionMessage(e); NULL})
    row <- cbind(Row = i, p, Returned = !is.null(z), Objective = NA_real_,
      ReferenceObjective = NA_real_, Q1921Objective = NA_real_, NuisanceGradient = NA_real_,
      Q1921NuisanceGradient = NA_real_, NativePass = FALSE, ReferenceValueAgreement = FALSE,
      Seconds = NA_real_, Warnings = 0L, Error = '')
    if (!is.null(z)) {
      warnings <- c(warnings, z$opt$warnings); errors <- c(errors, z$opt$errors[nzchar(z$opt$errors)])
      row$Objective <- z$objective; row$ReferenceObjective <- z$reference; row$Q1921Objective <- z$dense
      row$NuisanceGradient <- z$opt$selected$diagnostics$TerminalGradientSupNorm
      row$Q1921NuisanceGradient <- max(abs(z$dense_gradient))
      row$NativePass <- identical(z$opt$selected$diagnostics$ConvergenceSeverity, 'pass')
      row$ReferenceValueAgreement <- abs(z$objective - z$reference) <= 1e-6
      row$Seconds <- z$opt$elapsed
    }
    row$Warnings <- length(warnings); row$Error <- paste(errors, collapse = ' | ')
    rows[[i]] <- row; results[[i]] <- list(result = z, warnings = warnings, errors = errors)
    saveRDS(results[[i]], file.path(directory, paste0('row-', i, '.rds')))
    cat(i, '/', nrow(plan), p$Case, p$Variance, p$Q, p$Start,
      row$NativePass, row$ReferenceValueAgreement, row$Error, '\n'); flush.console()
  }
  summary <- do.call(rbind, rows); envelope <- derivatives <- list()
  keys <- unique(summary[c('Case', 'Variance', 'Q')])
  for (k in seq_len(nrow(keys))) {
    key <- keys[k, ]; at <- which(summary$Case == key$Case & summary$Variance == key$Variance &
      summary$Q == key$Q & summary$Returned)
    if (!length(at)) next
    best <- at[which.min(summary$Objective[at])]; z <- results[[best]]$result
    row <- summary[best, ]; row$StartObjectiveRange <- diff(range(summary$Objective[at]))
    row$IndependentGradient <- row$DerivativeStepDifference <- row$DerivativeVsQ1921Difference <- NA_real_
    row$ContinuousNuisanceQualified <- FALSE
    if (key$Q == 961L) {
      fn <- function(nuisance) {
        par <- z$par; par[z$opt$nuisance_index] <- nuisance
        population_profile_reference(main$cases[[key$Case]], par, key$Variance)
      }
      n <- z$par[z$opt$nuisance_index]
      d <- tryCatch(list(coarse = mfrmr_num_central_gradient(fn, n, 1e-4),
        fine = mfrmr_num_central_gradient(fn, n, 5e-5)), error = identity)
      derivatives[[as.character(best)]] <- d
      if (!inherits(d, 'error')) {
        row$IndependentGradient <- max(abs(d$fine))
        row$DerivativeStepDifference <- max(abs(d$fine - d$coarse))
        row$DerivativeVsQ1921Difference <- max(abs(d$fine - z$dense_gradient))
        row$ContinuousNuisanceQualified <- row$NativePass && row$ReferenceValueAgreement &&
          row$IndependentGradient <= 1e-4 && row$DerivativeStepDifference <= 1e-7 &&
          row$DerivativeVsQ1921Difference <= 1e-7
      }
    }
    envelope[[k]] <- row
    cat('Envelope', key$Case, key$Variance, key$Q, row$ContinuousNuisanceQualified, '\n'); flush.console()
  }
  stopifnot(identical(payload, tools::md5sum(paths)))
  evidence <- list(plan = plan, summary = summary, envelope = do.call(rbind, envelope),
    results = results, derivatives = derivatives, input_md5 = tools::md5sum(input),
    payload = payload, source = readLines(tail(paths, 1)),
    design = readLines('inst/validation/population-variance-profile-record-0.2.4.md'),
    started = started, completed = Sys.time(), session = sessionInfo())
  saveRDS(evidence, file.path(directory, 'evidence.rds'), compress = 'xz')
  for (name in c('summary', 'envelope'))
    write.csv(evidence[[name]], file.path(directory, paste0(name, '.csv')), row.names = FALSE)
  invisible(evidence)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE); stopifnot(length(args) == 2L)
  population_profile_refinement(args[1], args[2])
}
