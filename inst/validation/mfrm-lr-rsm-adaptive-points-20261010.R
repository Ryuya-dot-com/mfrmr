# Fixed-parameter accuracy only: no new optimizer, profile or coverage claim.
# Run from development/ in the documented single-threaded validation runtime.
# An optional integer argument selects a planned point; completed points resume.
script <- 'inst/validation/mfrm-lr-rsm-adaptive-points-20261010.R'
prior <- 'validation-results/mfrm-lr-rsm-profile-20261010'
out <- 'validation-results/mfrm-lr-rsm-adaptive-points-20261010'
audit_path <- file.path(prior, 'verification.rds')
stopifnot(unname(tools::md5sum(audit_path)) == '53685d88f9841801ba2848dcd1f5436f')
audit <- readRDS(audit_path)
verify <- function(h) stopifnot(length(h) > 0L, !anyNA(h),
  identical(unname(tools::md5sum(names(h))), unname(h)))
stopifnot(isTRUE(audit$passed)); verify(audit$manifest); verify(audit$retained)
old <- readRDS(names(audit$manifest)); verify(old$inputs)
cases <- lapply(file.path(prior, sprintf('case-%02d.rds', 1:6)), readRDS)
stopifnot(cases[[6]]$status == 'source_refused')
fit_paths <- names(old$inputs)[endsWith(names(old$inputs), '-fit.rds')][1:5]
fits <- lapply(fit_paths, function(path) readRDS(path)$payload$value)
points <- list()
for (i in 1:5) {
  case <- cases[[i]]; par <- fits[[i]]$opt$par
  stopifnot(identical(par, case$source_terminal$parameters))
  points[[sprintf('case%02d-source', i)]] <- list(case = i, role = 'source', par = par,
    reused_reference = case$source_terminal$continuous)
  if (is.null(case$search)) next
  bad <- subset(case$search$profile, !Passed)
  for (j in seq_len(nrow(bad))) {
    key <- sprintf('%.17g', bad$LogVariance[j]); a <- case$search$attempts[[key]]
    difference <- max(abs(a$retained$parameters-a$neutral$parameters))
    stopifnot(difference <= 1e-12, diff(range(vapply(a, function(x) x$check$NLL, 0.))) <= 1e-5)
    points[[sprintf('case%02d-failed%02d', i, j)]] <- list(case = i,
      role = 'failed_profile_trial', par = a$retained$parameters,
      duplicate_start_difference = difference)
  }
}
stopifnot(length(points) == 15L, all(vapply(points, function(x) length(x$par), 0L) == 9L))
pkgload::load_all('.', quiet = TRUE, compile = FALSE)
source('inst/validation/mfrm-lr-rsm-boundary-20261009.R')
paths <- c(script, 'inst/validation/mfrm-lr-rsm-boundary-20261009.R',
  list.files('R', full.names = TRUE), 'DESCRIPTION', 'NAMESPACE',
  getLoadedDLLs()[['mfrmr']][['path']])
hashes <- tools::md5sum(paths); names(hashes)[length(hashes)] <- 'loaded_mfrmr_DLL'
common <- intersect(names(hashes), names(old$source))
stopifnot(identical(hashes[common], old$source[common]))
controls <- list(orders = c(15L,31L), fd_step = 2e-4, nll = 1e-5,
  gradient = 1e-4, reference = 1e-5)
manifest <- list(points = points, controls = controls, inputs = old$inputs,
  prior_audit = tools::md5sum(audit_path), source = hashes, session = sessionInfo(),
  threads = Sys.getenv(c('OMP_NUM_THREADS', 'OPENBLAS_NUM_THREADS',
    'MKL_NUM_THREADS', 'VECLIB_MAXIMUM_THREADS')))
stopifnot(all(manifest$threads == '1'))
dir.create(out, recursive = TRUE, showWarnings = FALSE)
manifest_path <- file.path(out, 'manifest.rds')
if (file.exists(manifest_path)) stopifnot(identical(readRDS(manifest_path), manifest)) else
  saveRDS(manifest, manifest_path)
writeLines(capture.output(sessionInfo()), file.path(out, 'session-info.txt'))
writeLines(tail(paths,1L), file.path(out, 'loaded-dll-path.txt'))

# Build each case's designs once; all subsequent parameter vectors are fixed.
contexts <- vector('list', 5L)
context <- function(i) {
  if (!is.null(contexts[[i]])) return(contexts[[i]])
  fit <- fits[[i]]; cfg <- fit$config; sizes <- mfrmr:::build_param_sizes(cfg)
  idx <- mfrmr:::build_indices(fit$prep, cfg$step_facet, cfg$slope_facet,
    cfg$interaction_specs, gpcm_spec = cfg$gpcm_spec)
  fixed <- mfrmr:::make_mfrm_direct_evaluator('MML',
    mfrmr:::make_param_cache(sizes, cfg, idx, is_mml = TRUE), idx, cfg, sizes,
    mfrmr:::gauss_hermite_normal(cases[[i]]$case$Order))
  adaptive <- lapply(controls$orders, function(q)
    mfrmr:::mfrmr_make_adaptive_mml_evaluator(idx, cfg, sizes, q))
  ctx <- rsm_lr_boundary_context(fit)
  contexts[[i]] <<- list(fixed = fixed, adaptive = adaptive, independent = ctx)
  contexts[[i]]
}

run_point <- function(point) {
  ctx <- context(point$case); par <- point$par
  reference_calls <- 0L
  continuous <- function(p) {
    reference_calls <<- reference_calls + 1L
    rsm_lr_continuous_value(ctx$independent, head(p,-1L), exp(tail(p,1L)))
  }
  baseline <- point$reused_reference
  if (is.null(baseline)) baseline <- continuous(par)
  # Differentiate the independently coded, continuously integrated likelihood,
  # not the adaptive objective itself or a fixed-posterior approximation.
  fd <- lapply(seq_along(par), function(j) {
    h <- controls$fd_step*(1+abs(par[j]))
    trial <- lapply(c(h,-h,h/2,-h/2), function(d) {
      p <- par; p[j] <- p[j]+d; continuous(p)
    })
    value <- vapply(trial, `[[`, 0., 'value')
    error <- vapply(trial, `[[`, 0., 'summed_relative_error')
    coarse <- (value[1]-value[2])/(2*h); fine <- (value[3]-value[4])/h
    extrapolated <- (4*fine-coarse)/3
    reported_error <- (4*sum(error[3:4])/h+sum(error[1:2])/(2*h))/3
    list(step = h, values = value, reported_errors = error, coarse = coarse,
      fine = fine, extrapolated = extrapolated, refinement = abs(extrapolated-fine),
      reported_gradient_error = reported_error)
  })
  gradient <- vapply(fd, `[[`, 0., 'extrapolated')
  refinement <- max(vapply(fd, `[[`, 0., 'refinement'))
  reported_error <- max(vapply(fd, `[[`, 0., 'reported_gradient_error'))
  reference_pass <- refinement <= controls$reference && reported_error <= controls$reference
  timed <- function(fn) {
    start <- proc.time()[['elapsed']]; value <- fn()
    list(result = value, elapsed = proc.time()[['elapsed']]-start)
  }
  evaluations <- c(list(fixed = timed(function() list(value = ctx$fixed$value(par),
    gradient = ctx$fixed$gradient(par)))), setNames(lapply(ctx$adaptive,
      function(fn) timed(function() fn(par))), paste0('adaptive', controls$orders)))
  rows <- lapply(names(evaluations), function(name) {
    x <- evaluations[[name]]; nll_error <- abs(x$result$value-baseline$value)
    gradient_error <- max(abs(x$result$gradient-gradient))
    data.frame(Method = name, NLLDifference = nll_error, GradientDifference = gradient_error,
      ReferenceRefinement = refinement, ReferenceReportedGradientError = reported_error,
      ReferencePassed = reference_pass,
      Passed = reference_pass && nll_error+baseline$summed_relative_error <= controls$nll &&
        gradient_error+refinement+reported_error <= controls$gradient,
      MaxGradient = max(abs(x$result$gradient)),
      MaxNuisanceGradient = max(abs(head(x$result$gradient,-1L))),
      ElapsedEvaluation = x$elapsed)
  })
  a <- evaluations$adaptive15$result; b <- evaluations$adaptive31$result
  agreement <- c(NLL = abs(a$value-b$value), Gradient = max(abs(a$gradient-b$gradient)))
  rows <- do.call(rbind, rows)
  agreement_pass <- agreement[1] <= controls$nll && agreement[2] <= controls$gradient
  list(status = if (all(rows$Passed[rows$Method != 'fixed']) && agreement_pass)
    'adaptive_accuracy_pass' else 'adaptive_accuracy_unresolved',
    rows = rows, agreement = agreement, reference = baseline, finite_difference = fd,
    reference_gradient = gradient, evaluations = evaluations,
    reference_calls = reference_calls)
}

args <- commandArgs(TRUE)
chosen <- if (length(args)) as.integer(args) else seq_along(points)
stopifnot(length(chosen) > 0L, !anyNA(chosen), all(chosen %in% seq_along(points)))
for (i in chosen) {
  name <- names(points)[i]; point <- points[[i]]
  file <- file.path(out, paste0(name,'.rds'))
  if (file.exists(file)) {
    stopifnot(identical(readRDS(file)$point, point))
    next
  }
  started <- proc.time()[['elapsed']]
  result <- tryCatch(run_point(point), error = function(e)
    list(status = 'error', reason = conditionMessage(e)))
  result$elapsed <- proc.time()[['elapsed']]-started
  result$point <- point
  saveRDS(result, file)
  cat(sprintf('%s: %s (%.3f s)\n', name, result$status, result$elapsed))
  flush.console()
}
files <- file.path(out, paste0(names(points),'.rds')); files <- files[file.exists(files)]
results <- lapply(files, readRDS)
summary <- do.call(rbind, lapply(seq_along(results), function(i) {
  z <- results[[i]]; point <- z$point; row <- z$rows
  if (is.null(row)) row <- data.frame(Method = 'unavailable',
    NLLDifference = NA_real_, GradientDifference = NA_real_, ReferenceRefinement = NA_real_,
    ReferenceReportedGradientError = NA_real_, ReferencePassed = FALSE, Passed = FALSE,
    MaxGradient = NA_real_, MaxNuisanceGradient = NA_real_, ElapsedEvaluation = NA_real_)
  cbind(data.frame(Point = sub('[.]rds$','',basename(files[i])),
    ParentId = cases[[point$case]]$case$ParentId,
    Role = point$role, LogVariance = tail(point$par,1L), Status = z$status), row)
}))
write.csv(summary, file.path(out, 'accuracy.csv'), row.names = FALSE)
print(summary[c('Point','Method','Status','Passed')], row.names = FALSE)
