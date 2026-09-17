# Aggregate saved fits and higher-order evaluations without rerunning either.
source('inst/validation/local-testlet-optimizer-controls-0.2.4.R')

summarize_testlet_optimizer_controls <- function() {
  prefix <- 'inst/validation/local-testlet-optimizer-controls-0.2.4'
  output <- 'validation-results/local-testlet-optimizer-controls-20260917'
  plan <- readRDS(file.path(output, 'plan.rds'))
  keys <- unlist(lapply(plan$settings$Setting, function(s) paste(plan$selected$ID, s, sep = '-')))
  paths <- file.path(output, paste0(keys, '-result.rds'))
  stopifnot(all(file.exists(paths)))
  records <- lapply(paths, readRDS)
  bridges <- lapply(file.path(output, paste0('bridge-', c('cell-02-rep-01', 'cell-04-rep-06'), '.rds')), readRDS)
  rows <- do.call(rbind, lapply(records, function(x) {
    j <- match(x$spec$ID, plan$selected$ID)
    old <- plan$original[[j]]$fit$value$captured$value
    value <- x$fit$value$captured$value
    ref <- x$reference$value
    errors <- c(x$fit$error, x$fit$value$captured$error)
    warnings <- c(x$fit$warnings, x$fit$value$captured$warnings)
    fit_ready <- !is.null(value) && !any(nzchar(errors)) && !length(warnings) &&
      value$convergence == 0 && is.finite(value$projected_score) &&
      value$projected_score <= 1e-5 && !value$search_boundary
    differences <- if (is.null(value) || is.null(ref)) rep(NA_real_, 3) else
      c(abs(value$loglik - ref$loglik), max(abs(value$moments - ref$moments)),
        max(abs(value$gradient - ref$gradient)))
    ref_score <- if (is.null(ref)) NA_real_ else testlet_projected_score(value$par, ref$gradient)
    ref_ready <- !is.null(ref) && !nzchar(x$reference$error) && !length(x$reference$warnings) &&
      all(is.finite(differences)) && all(differences <= c(1e-7, 1e-7, 1e-6)) &&
      is.finite(ref_score) && ref_score <= 1e-5
    loglik_change <- par_change <- moment_change <- NA_real_
    same_boundary <- NA
    if (!is.null(old) && !is.null(value)) {
      loglik_change <- value$loglik - old$loglik
      par_change <- max(abs(value$par - old$par))
      moment_change <- max(abs(value$moments - old$moments))
      same_boundary <- (value$par[6] == 0) == (old$par[6] == 0)
    }
    control_agreement <- if (x$spec$FitReady) isTRUE(fit_ready && ref_ready &&
      abs(loglik_change) <= 1e-7 && par_change <= 1e-4 && moment_change <= 1e-5 && same_boundary) else NA
    history <- x$fit$value$history
    points <- if (is.null(history)) matrix(numeric(), 0, 6) else unique(history[, 1:6, drop = FALSE])
    first <- if (nrow(points) >= 2) points[2, ] else rep(NA_real_, 6)
    errors <- c(errors, x$reference$error)
    warnings <- c(warnings, x$reference$warnings)
    data.frame(ID = x$spec$ID, Cell = x$spec$Cell, N = x$spec$N, TrueVariance = x$spec$Variance,
      Setting = x$setting$Setting, Role = if (x$spec$FitReady) 'successful_control' else 'original_nonready',
      FitReady = fit_ready, ReferenceReady = ref_ready, Ready = fit_ready && ref_ready,
      ControlAgreement = control_agreement, NativeCode = if (is.null(value)) NA_integer_ else value$convergence,
      ProjectedScore = if (is.null(value)) NA_real_ else value$projected_score,
      EstimatedVariance = if (is.null(value)) NA_real_ else value$par[6],
      BoundaryZero = if (is.null(value)) NA else value$par[6] == 0,
      Stop = if (is.null(value)) '' else value$message,
      Error = paste(errors[nzchar(errors)], collapse = ' | '), Warnings = paste(warnings, collapse = ' | '),
      FitSeconds = x$fit$elapsed, ReferenceSeconds = if (is.null(x$reference)) 0 else x$reference$elapsed,
      FunctionCalls = if (is.null(value)) NA_integer_ else unname(value$counts['function']),
      GradientCalls = if (is.null(value)) NA_integer_ else unname(value$counts['gradient']),
      UniqueTrialPoints = nrow(points),
      ArtificialTrialPoints = if (!nrow(points)) 0L else sum(apply(abs(points[, 1:5, drop = FALSE]) >= 8 - 1e-8, 1, any) |
        points[, 6] >= 16 - 1e-8),
      FirstTrialAlpha = first[1], FirstTrialBeta1 = first[2], FirstTrialBeta2 = first[3],
      FirstTrialRater1 = first[4], FirstTrialTau1 = first[5], FirstTrialVariance = first[6],
      ReferenceOrder = x$reference_order, ReferenceLogLikDifference = differences[1],
      ReferenceMomentDifference = differences[2], ReferenceScoreDifference = differences[3],
      ReferenceProjectedScore = ref_score, LogLikChange = loglik_change, ParameterChange = par_change,
      MomentChange = moment_change, SameBoundary = same_boundary)
  }))
  counts <- do.call(rbind, lapply(plan$settings$Setting, function(s) {
    z <- rows[rows$Setting == s, ]
    controls <- z$Role == 'successful_control'
    data.frame(Setting = s, Planned = 23L, Completed = nrow(z), Ready = sum(z$Ready),
      ResolvedOriginalFailures = sum(z$Ready[!controls]), ReadyControls = sum(z$Ready[controls]),
      PreservedControls = sum(z$ControlAgreement[controls]),
      CaptureErrors = sum(nzchar(z$Error)), WarningTrials = sum(nzchar(z$Warnings)),
      NativeNonzero = sum(z$NativeCode != 0, na.rm = TRUE),
      ScoreNotReady = sum(z$ProjectedScore > 1e-5, na.rm = TRUE),
      LowerLikelihood = sum(z$LogLikChange < -1e-7, na.rm = TRUE),
      TrialsTouchingArtificialBounds = sum(z$ArtificialTrialPoints > 0),
      MedianFitSeconds = median(z$FitSeconds),
      CandidateForIndependentPilot = nrow(z) == 23L && all(z$Ready) &&
        all(z$ControlAgreement[controls]) && !any(z$LogLikChange < -1e-7, na.rm = TRUE))
  }))
  check <- function(label, condition) data.frame(Check = label, Pass = isTRUE(condition))
  audit <- do.call(rbind, list(
    check('frozen sources and input unchanged', identical(plan$sources, tools::md5sum(names(plan$sources))) &&
      identical(plan$inputs, tools::md5sum(names(plan$inputs)))),
    check('two unchanged-control bridges agree exactly', all(vapply(bridges, function(x) x$identical_numerics, logical(1)))),
    check('record lineage retained', all(vapply(c(bridges, records), function(x)
      identical(x$sources, plan$sources) && identical(x$inputs, plan$inputs), logical(1)))),
    check('all 69 unique planned outcomes retained', nrow(rows) == 69L && !anyDuplicated(rows[c('ID', 'Setting')]) &&
      identical(paste(rows$ID, rows$Setting, sep = '-'), keys)),
    check('six controls and seventeen original failures per setting', all(vapply(plan$settings$Setting, function(s) {
      z <- rows[rows$Setting == s, ]; sum(z$Role == 'successful_control') == 6L && sum(z$Role == 'original_nonready') == 17L
    }, logical(1)))),
    check('total projected-gradient target preserved under scaling', all(vapply(records, function(x)
      abs(x$control$pgtol * x$control$fnscale - x$setting$TotalPGTol) <= 1e-15, logical(1)))),
    check('all attempts retain the original common start', all(vapply(records, function(x)
      is.null(x$fit$value) || identical(x$fit$value$start, plan$start), logical(1)))),
    check('every returned point gets its higher-order evaluation', all(vapply(records, function(x)
      is.null(x$fit$value$captured$value) || (!is.null(x$reference) &&
        x$reference_order == tail(x$fit$value$history[, 'Order'], 1) + 60L), logical(1)))),
    check('final ready label includes native, score and reference gates', all(!rows$Ready |
      (rows$FitReady & rows$ReferenceReady & rows$NativeCode == 0 & rows$ProjectedScore <= 1e-5 &
        rows$ReferenceProjectedScore <= 1e-5 & !nzchar(rows$Error) & !nzchar(rows$Warnings))))))
  for (name in c('rows', 'counts', 'audit')) write.csv(get(name), paste0(prefix, '-', name, '.csv'), row.names = FALSE)
  evidence <- list(plan = plan, bridges = bridges, records = records, rows = rows, counts = counts, audit = audit,
    summary_source = tools::md5sum(paste0(prefix, '-summary.R')), completed = Sys.time())
  saveRDS(evidence, paste0(prefix, '-evidence.rds'))
  print(counts)
  print(audit)
  stopifnot(all(audit$Pass))
}

if (sys.nframe() == 0L) summarize_testlet_optimizer_controls()
