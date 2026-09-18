# Repository-only saved-data preflight; bounds are fixed in the DRF protocol.
source('inst/validation/drf-joint-null-information-0.2.4.R')
source('inst/validation/numerical-stationarity-pilot-0.2.3.R')
source('inst/validation/gpcm-solution-stability-p0-0.2.3.R')
source('inst/validation/gpcm-zero-variance-boundary-p1c-0.2.3.R')

drf_joint_fit_stability <- function(input, output) {
  stopifnot(dir.exists(input), !dir.exists(output))
  dir.create(output, recursive = TRUE)
  pkgload::load_all('.', quiet = TRUE)
  cells <- c('RSM-group_mean_only', 'PCM-group_mean_only', 'RSM-drf', 'PCM-drf')
  paths <- file.path(input, paste0(cells, '-joint.rds'))
  helpers <- paste0('inst/validation/', c('drf-joint-fit-stability-0.2.4.R',
    'drf-joint-null-information-0.2.4.R', 'numerical-stationarity-pilot-0.2.3.R',
    'gpcm-solution-stability-p0-0.2.3.R', 'gpcm-zero-variance-boundary-p1c-0.2.3.R'))
  protocol <- 'inst/validation/interval-drf-preflight-protocol-0.2.4.md'
  identities <- tools::md5sum(c(paths, list.files('R', '[.]R$', full.names = TRUE), helpers, protocol))
  saveRDS(list(hashes = identities, protocol = readLines(protocol),
    sources = setNames(lapply(helpers, readLines), helpers)), file.path(output, 'source.rds'))
  write.csv(data.frame(File = names(identities), MD5 = unname(identities)),
    file.path(output, 'source-input-md5.csv'), row.names = FALSE)
  bundles <- setNames(lapply(paths, readRDS), cells)
  plan <- do.call(rbind, lapply(cells, function(cell) do.call(rbind,
    lapply(c('null', 'alternative'), function(hypothesis) {
      starts <- c('retained', 'zero', if (hypothesis == 'alternative') 'embedded_null')
      data.frame(Cell = cell, Hypothesis = hypothesis,
        Stage = c('saved', rep('refit', length(starts)), rep('boundary', 2L)),
        Q = c(61L, rep(121L, length(starts)), 1L, 1L),
        Start = c('retained', starts, 'retained', 'zero'))
    }))))
  plan$Row <- seq_len(nrow(plan)); stopifnot(nrow(plan) == 44L)
  write.csv(plan, file.path(output, 'plan.csv'), row.names = FALSE)

  # Build indices with the interaction specification, including for the null embedding.
  context <- function(fit, q) {
    view <- fit; view$config$estimation_control$quad_points <- q
    mfrmr_num_fit_context(view)
  }
  embedding <- function(bundle) {
    null <- bundle$fits$null; alt <- bundle$fits$alternative
    nm <- null$config$estimability_audit$mml_observed_pattern_score$parameter_map
    am <- alt$config$estimability_audit$mml_observed_pattern_score$parameter_map
    at <- match(nm$Coordinate, am$Coordinate)
    stopifnot(!anyNA(at), !anyDuplicated(am$Coordinate),
      identical(nm$Constraint, am$Constraint[at]),
      identical(nm$ReferenceLevel, am$ReferenceLevel[at]))
    p <- numeric(length(alt$opt$par))
    p[am$OptimizerIndex[at]] <- null$opt$par[nm$OptimizerIndex]
    stopifnot(sum(am$Block == 'interactions') == 2L,
      all(p[am$OptimizerIndex[am$Block == 'interactions']] == 0))
    p
  }
  embedded <- lapply(bundles, embedding)
  embed_error <- vapply(cells, function(cell) max(vapply(c(61L, 121L), function(q) {
    b <- bundles[[cell]]
    abs(context(b$fits$null, q)$fn(b$fits$null$opt$par) -
      context(b$fits$alternative, q)$fn(embedded[[cell]]))
  }, numeric(1))), numeric(1))

  design <- expand.grid(Rater = 1:3, Criterion = 1:2)
  patterns <- as.matrix(expand.grid(rep(list(0:2), 6L)))
  results <- rows <- list()
  for (i in seq_len(nrow(plan))) {
    spec <- plan[i, ]; fit <- bundles[[spec$Cell]]$fits[[spec$Hypothesis]]
    boundary <- spec$Stage == 'boundary'
    ctx <- context(fit, spec$Q)
    map <- fit$config$estimability_audit$mml_observed_pattern_score$parameter_map
    sigma <- ctx$slices$log_sigma2
    free <- if (boundary) setdiff(seq_along(fit$opt$par), sigma) else seq_along(fit$opt$par)
    start <- switch(spec$Start, retained = fit$opt$par,
      zero = numeric(length(fit$opt$par)), embedded_null = embedded[[spec$Cell]])
    warnings <- character(); begun <- Sys.time(); opt <- NULL
    result <- tryCatch(withCallingHandlers({
      opt <- if (spec$Stage == 'saved') fit$opt else if (boundary)
        mfrmr_gzb_p1c_optimize_boundary(ctx, start, maxit = 400L, reltol = 1e-12) else
        mfrmr:::run_mfrm_direct_optimization(start, 'MML', ctx$idx, ctx$config,
          ctx$sizes, spec$Q, maxit = 400L, reltol = 1e-12, optimizer = 'L-BFGS-B')
      if (boundary && !opt$returned) stop('No finite boundary nuisance vector returned.')
      par <- opt$par
      stopifnot(length(par) == nrow(map), all(is.finite(par)), length(sigma) == 1L,
        identical(sort(map$OptimizerIndex), seq_along(par)),
        !mfrmr:::mfrm_inference_ready(fit))
      d <- fit$prep$data; persons <- unique(d[c('Person', 'Group')])
      stopifnot(nrow(persons) == 80L, all(table(d$Person) == 6L), all(d$Weight == 1),
        fit$config$n_cat == 3L, identical(fit$prep$levels$Group, c('A', 'B')))
      design_key <- paste(fit$prep$levels$Rater[design$Rater], fit$prep$levels$Criterion[design$Criterion])
      count <- matrix(0, nrow(patterns), 2L, dimnames = list(NULL, c('A', 'B')))
      for (p in seq_len(nrow(persons))) {
        dp <- d[d$Person == persons$Person[p], ]
        at <- match(design_key, paste(dp$Rater, dp$Criterion))
        stopifnot(!anyNA(at), !anyDuplicated(at))
        k <- as.integer(1 + sum(dp$score_k[at] * 3^(0:5)))
        g <- as.character(persons$Group[p]); count[k, g] <- count[k, g] + 1
      }
      ref <- function(p) as.vector(vapply(c('A', 'B'), function(g)
        pattern_logp(p, map, fit$config$model, design, patterns, g,
          zero_variance = boundary), numeric(nrow(patterns))))
      weights <- as.vector(count)
      logp <- ref(par); nll <- -sum(weights * logp)
      gradient <- vapply(c(1e-4, 5e-5, 2.5e-5), function(h)
        -as.vector(crossprod(weights, score_difference(ref, par, h))), numeric(length(par)))
      analytic <- ctx$gr(par)
      grid <- if (boundary) NULL else do.call(rbind, lapply(c(61L, 121L), function(q) {
        evaluated <- context(fit, q)
        data.frame(Q = q, NLL = evaluated$fn(par),
          ReferenceNLLError = abs(evaluated$fn(par) - nll),
          ReferenceGradientError = max(abs(evaluated$gr(par) - gradient[, 3L])))
      }))
      placeholder_error <- if (boundary) max(abs(vapply(c(-32, 0, 32), function(s) {
        p <- par; p[sigma] <- s; ctx$fn(p)
      }, numeric(1)) - ctx$fn(par))) else NA_real_
      list(par = par, map = map, nll = nll, gradient = gradient, analytic = analytic,
        grid = grid, placeholder_error = placeholder_error, objective = ctx$fn(par))
    }, warning = function(w) {warnings <<- c(warnings, conditionMessage(w)); invokeRestart('muffleWarning')}),
    error = identity)
    failed <- inherits(result, 'error')
    native <- if (is.null(opt)) NULL else if (boundary) opt$selected$diagnostics else opt$optimizer_diagnostics
    row <- cbind(spec, data.frame(Returned = !failed,
      Seconds = as.numeric(difftime(Sys.time(), begun, units = 'secs')),
      NativePass = identical(native$ConvergenceSeverity, 'pass'),
      NLL = NA_real_, Variance = NA_real_, ObjectiveError = NA_real_,
      GradientNorm = NA_real_, LogVarianceGradient = NA_real_,
      GradientStepError = NA_real_, GradientAgreement = NA_real_,
      NumericalAgreement = FALSE, PlaceholderError = NA_real_,
      Error = if (failed) conditionMessage(result) else ''))
    if (!failed) {
      row$NLL <- result$nll
      row$Variance <- if (boundary) 0 else exp(result$par[sigma])
      row$ObjectiveError <- abs(result$objective - result$nll)
      row$GradientNorm <- max(abs(result$gradient[free, 3L]))
      row$LogVarianceGradient <- if (boundary) NA_real_ else result$gradient[sigma, 3L]
      row$GradientStepError <- max(abs(result$gradient[free, 3L] - result$gradient[free, 2L]))
      row$GradientAgreement <- max(abs(result$analytic[free] - result$gradient[free, 3L]))
      row$PlaceholderError <- result$placeholder_error
      row$NumericalAgreement <- row$NativePass && row$ObjectiveError <= 1e-6 &&
        row$GradientNorm <= 1e-4 && row$GradientStepError <= 1e-7 &&
        row$GradientAgreement <= 1e-7 && (!boundary || row$PlaceholderError <= 1e-12)
    }
    rows[[i]] <- row
    results[[i]] <- list(result = result, optimizer = opt, start = start, warnings = warnings)
    saveRDS(results[[i]], file.path(output, paste0('row-', i, '.rds')))
    write.csv(do.call(rbind, rows), file.path(output, 'rows.csv'), row.names = FALSE)
    cat(i, '/', nrow(plan), spec$Cell, spec$Hypothesis, spec$Stage, spec$Start,
      'agreement', row$NumericalAgreement, 'gradient', row$GradientNorm, row$Error, '\n')
    flush.console()
  }
  rows <- do.call(rbind, rows)
  models <- do.call(rbind, lapply(cells, function(cell) do.call(rbind,
    lapply(c('null', 'alternative'), function(hypothesis) {
      r <- subset(rows, Cell == cell & Hypothesis == hypothesis)
      f <- subset(r, Stage == 'refit'); b <- subset(r, Stage == 'boundary'); s <- subset(r, Stage == 'saved')
      good <- all(r$Returned)
      data.frame(Cell = cell, Hypothesis = hypothesis,
        AllReturned = good, DenseRefitsQualified = all(f$NumericalAgreement),
        BoundaryRefitsQualified = all(b$NumericalAgreement),
        SavedQ61Qualified = s$NumericalAgreement,
        DenseNLLRange = if (good) diff(range(f$NLL)) else NA_real_,
        BoundaryNLLRange = if (good) diff(range(b$NLL)) else NA_real_,
        BoundaryNLLGap = if (good) min(b$NLL) - min(f$NLL) else NA_real_,
        SavedToDenseNLLChange = if (good) s$NLL - min(f$NLL) else NA_real_,
        SavedToDenseParameterChange = if (good) max(abs(results[[s$Row]]$result$par -
          results[[f$Row[f$Start == 'retained']]]$result$par)) else NA_real_)
    }))))
  pairs <- do.call(rbind, lapply(cells, function(cell) {
    m <- subset(models, Cell == cell); r <- subset(rows, Cell == cell)
    ll_change <- function(stage, start) {
      z <- subset(r, Stage == stage & Start == start)
      2 * (z$NLL[z$Hypothesis == 'null'] - z$NLL[z$Hypothesis == 'alternative'])
    }
    changes <- c(ll_change('saved', 'retained'), ll_change('refit', 'retained'), ll_change('refit', 'zero'))
    dense <- subset(r, Stage == 'refit')
    dense_changes <- as.vector(2 * outer(dense$NLL[dense$Hypothesis == 'null'],
      dense$NLL[dense$Hypothesis == 'alternative'], '-'))
    data.frame(Cell = cell, EmbeddingError = embed_error[[cell]],
      SavedTwiceLLChange = changes[1], DenseRetainedTwiceLLChange = changes[2],
      DenseZeroTwiceLLChange = changes[3], DenseTwiceLLRange = diff(range(dense_changes)),
      SavedToDenseTwiceLLChange = abs(changes[1] - changes[2]),
      DenseNumericalPreflight = isTRUE(all(m$AllReturned & m$DenseRefitsQualified &
        m$BoundaryRefitsQualified & m$DenseNLLRange <= 1e-6 & m$BoundaryNLLRange <= 1e-6 &
        m$BoundaryNLLGap > 1e-6) && embed_error[[cell]] <= 1e-8 &&
        diff(range(dense_changes)) <= 4e-6), PublicInferenceReady = FALSE)
  }))
  write.csv(models, file.path(output, 'models.csv'), row.names = FALSE)
  write.csv(pairs, file.path(output, 'pairs.csv'), row.names = FALSE)
  writeLines(capture.output(sessionInfo()), file.path(output, 'session-info.txt'))
  saveRDS(list(plan = plan, rows = rows, models = models, pairs = pairs,
    embedding_error = embed_error, hashes = identities, completed = Sys.time()), file.path(output, 'summary.rds'))
  stopifnot(identical(identities, tools::md5sum(names(identities))))
  print(pairs)
  invisible(pairs)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(TRUE); stopifnot(length(args) == 2L)
  drf_joint_fit_stability(args[1], args[2])
}
