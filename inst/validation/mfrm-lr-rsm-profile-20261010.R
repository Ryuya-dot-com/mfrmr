# Retained-case numerical feasibility only; not coverage confirmation or API.
# Run from the package root, using the documented R 4.6.1 validation library.
# Optional argument: one case number (1:6). Completed cases resume unchanged.
script <- 'inst/validation/mfrm-lr-rsm-profile-20261010.R'
root <- 'validation-results/mfrm-lr-rsm-confirmation-20261009'
out <- 'validation-results/mfrm-lr-rsm-profile-20261010'
audit_path <- file.path(root, 'summary-verification-20261010.rds')
stopifnot(unname(tools::md5sum(audit_path)) == '381320c691947d7f3bf3f12564eb7afb')
audit <- readRDS(audit_path)
verify <- function(h) stopifnot(length(h) > 0L, !anyNA(h),
  identical(unname(tools::md5sum(names(h))), unname(h)))
verify(audit$outputs[file.path(root, 'summary.rds')])
saved <- readRDS(file.path(root, 'summary.rds'))$payload
records <- subset(saved$records, Output == 'interval' & Selection == 'selected' &
  Target == 'log_residual_variance')
cases <- data.frame(Job = c(2L, 15L, 31L, 278L, 801L, 1L),
  Role = c('first_available', 'first_rescued', 'first_rescued_above_truth',
    'smallest_available_variance', 'larger_sample_control', 'category_refusal_control'))
cases <- cbind(cases, records[match(cases$Job,
  records$Replicate + ifelse(records$N == 240L, 800L, 0L)), ])
rownames(cases) <- NULL
stopifnot(nrow(cases) == 6L, identical(cases$Available, c(rep(TRUE, 5L), FALSE)),
  cases$Replicate[4] == subset(records, N == 20 & Available)$Replicate[
    which.min(subset(records, N == 20 & Available)$Estimate)])
paths <- file.path(root, 'jobs', sprintf('parent-%04d', cases$Job), 'selected.rds')
fit_paths <- file.path(root, 'jobs', sprintf('parent-%04d', cases$Job),
  sprintf('q%d-fit.rds', cases$Order))
inputs <- audit$retained_hashes[c(paths, fit_paths)]
verify(inputs)
pkgload::load_all('.', quiet = TRUE, compile = FALSE)
source('inst/validation/mfrm-lr-rsm-boundary-20261009.R')
sources <- c(script, 'inst/validation/mfrm-lr-rsm-boundary-20261009.R',
  list.files('R', full.names = TRUE), 'DESCRIPTION', 'NAMESPACE',
  getLoadedDLLs()[['mfrmr']][['path']])
source_hashes <- tools::md5sum(sources)
# pkgload copies the same DLL to a fresh temporary path in each session.
# Bind the actual loaded bytes to a stable label, retaining the observed path.
names(source_hashes)[length(source_hashes)] <- 'loaded_mfrmr_DLL'
manifest <- list(cases = cases, inputs = inputs,
  aggregate = audit$outputs[file.path(root, 'summary.rds')],
  source = source_hashes, session = sessionInfo(),
  threads = Sys.getenv(c('OMP_NUM_THREADS', 'OPENBLAS_NUM_THREADS',
    'MKL_NUM_THREADS', 'VECLIB_MAXIMUM_THREADS')),
  controls = list(level = .95, maxit = 400L, max_steps = 8L, initial_step = .5),
  scope = 'Selected development cases: numerical endpoints, not confidence coverage.')
stopifnot(all(manifest$threads == '1'))
dir.create(out, recursive = TRUE, showWarnings = FALSE)
manifest_path <- file.path(out, 'manifest.rds')
if (file.exists(manifest_path)) stopifnot(identical(readRDS(manifest_path), manifest)) else
  saveRDS(manifest, manifest_path)
writeLines(capture.output(sessionInfo()), file.path(out, 'session-info.txt'))
writeLines(tail(sources, 1L), file.path(out, 'loaded-dll-path.txt'))
write.csv(cases, file.path(out, 'cases.csv'), row.names = FALSE)

run_case <- function(i) {
  row <- cases[i, ]; selected <- readRDS(paths[i])$payload
  phase <- readRDS(fit_paths[i]); fit <- phase$payload$value
  stopifnot(identical(phase$checksum, selected$interval$fit_hash),
    identical(fit$opt$par, selected$interval$population$value$fit$opt$par))
  if (!row$Available) return(list(status = 'source_refused', reason = row$Reason))
  cfg <- fit$config; sizes <- mfrmr:::build_param_sizes(cfg)
  slices <- mfrmr:::build_param_slices(sizes); p <- fit$opt$par
  stopifnot(length(slices$log_sigma2) == 1L,
    abs(p[slices$log_sigma2] - row$Estimate) < 1e-12)
  idx <- mfrmr:::build_indices(fit$prep, cfg$step_facet, cfg$slope_facet,
    cfg$interaction_specs, gpcm_spec = cfg$gpcm_spec)
  context <- function(q) {
    config <- cfg; config$estimation_control$quad_points <- q
    mfrmr:::make_mfrm_direct_evaluator('MML',
      mfrmr:::make_param_cache(sizes, config, idx, is_mml = TRUE),
      idx, config, sizes, mfrmr:::gauss_hermite_normal(q))
  }
  low <- context(row$Order); high <- context(2L * row$Order - 1L)
  ctx <- rsm_lr_boundary_context(fit)
  zero <- selected$zero$value
  stopifnot(isTRUE(zero$qualified),
    abs(rsm_lr_boundary_eval(ctx, zero$eta)$value - zero$nll) <= 1e-8)
  contrast <- rep(0, length(p)); contrast[slices$log_sigma2] <- 1
  # Terminal independent likelihood and local nuisance-curvature checks.
  terminal <- function(par, target, baseline, baseline_continuous, endpoint) {
    map <- mfrmr:::mfrm_gpcm_profile_constraint(par, contrast, target)
    continuous <- rsm_lr_continuous_value(ctx, par[-slices$log_sigma2],
      exp(par[slices$log_sigma2]))
    H <- optimHess(par[map$free],
      function(z) high$value(map$embed(z)),
      function(z) drop(crossprod(map$basis, high$gradient(map$embed(z)))))
    positive <- !is.null(tryCatch(chol(H), error = function(e) NULL))
    nll <- low$value(par); independent_lr <- 2*(continuous$value-baseline_continuous)
    check <- data.frame(ConstraintError = abs(sum(contrast*par)-target),
      IndependentNLLDifference = abs(continuous$value-nll),
      IndependentLR = independent_lr,
      LRChange = abs(independent_lr-2*(nll-baseline)),
      CutoffError = if (endpoint) abs(independent_lr-qchisq(.95,1)) else NA_real_,
      MinimumNuisanceEigenvalue = min(eigen(H, symmetric = TRUE, only.values = TRUE)$values),
      PositiveNuisanceHessian = positive)
    check$Passed <- check$ConstraintError <= 1e-10 &&
      check$IndependentNLLDifference <= 1e-5 && check$LRChange <= 1e-4 && positive &&
      (!endpoint || check$CutoffError <= 1e-4)
    list(check = check, continuous = continuous, hessian = H, parameters = par)
  }
  baseline <- low$value(p)
  baseline_continuous <- rsm_lr_continuous_value(ctx, p[-slices$log_sigma2],
    exp(p[slices$log_sigma2]))
  source_check <- c(NLLChange = abs(baseline-high$value(p)),
    GradientChange = max(abs(low$gradient(p)-high$gradient(p))),
    ReferenceGradient = max(abs(high$gradient(p))))
  source_terminal <- terminal(p, row$Estimate, baseline, baseline_continuous$value, FALSE)
  zero_lr <- 2*(zero$nll-baseline_continuous$value)
  result <- list(status = 'source_numerical_failure', source_check = source_check,
    source_terminal = source_terminal, zero_lr = zero_lr,
    zero_in_candidate_set = zero_lr <= qchisq(.95,1))
  if (source_check[1] <= 1e-5 && all(source_check[-1] <= 1e-4) &&
      source_terminal$check$Passed) {
    result$search <- do.call(mfrmr:::mfrm_gpcm_profile_search,
      c(list(evaluator = low, reference = high, start = p, contrast = contrast),
        manifest$controls))
    names(result$search$profile)[1:2] <- c('LogVariance', 'Variance')
    result$terminal <- list()
    for (j in which(result$search$endpoints$Status == 'computed')) {
      target <- log(result$search$endpoints$Bound[j])
      keys <- names(result$search$attempts)
      key <- keys[which.min(abs(as.numeric(keys)-target))]
      stopifnot(abs(as.numeric(key)-target) <= 1e-12)
      attempts <- result$search$attempts[[key]]
      best <- which.min(vapply(attempts, function(a) a$check$NLL, 0.))
      check <- terminal(attempts[[best]]$parameters, target, baseline,
        baseline_continuous$value, TRUE)
      side <- result$search$endpoints$Side[j]
      result$terminal[[side]] <- check
      if (!check$check$Passed) {
        result$search$endpoints$Bound[j] <- NA_real_
        result$search$endpoints$Status[j] <- 'independent_terminal_failure'
      }
    }
    result$status <- if (all(result$search$endpoints$Status == 'computed'))
      'two_numerical_endpoints' else 'incomplete_numerical_endpoints'
  }
  result$evaluations <- list(search_order = low$diagnostics(), reference = high$diagnostics())
  result
}

args <- commandArgs(TRUE)
chosen <- if (length(args)) as.integer(args) else seq_len(nrow(cases))
stopifnot(length(chosen) > 0L, !anyNA(chosen), all(chosen %in% seq_len(nrow(cases))))
for (i in chosen) {
  path <- file.path(out, sprintf('case-%02d.rds', i))
  if (file.exists(path)) next
  started <- proc.time()[['elapsed']]
  result <- tryCatch(run_case(i), error = function(e)
    list(status = 'error', reason = conditionMessage(e)))
  result$elapsed <- proc.time()[['elapsed']] - started
  result$case <- cases[i, ]
  saveRDS(result, path)
  cat(sprintf('%s: %s (%.3f s)\n', cases$ParentId[i], result$status, result$elapsed))
  if (!is.null(result$search)) print(result$search$endpoints)
}
results <- lapply(list.files(out, '^case-[0-9]+[.]rds$', full.names = TRUE), readRDS)
summary <- do.call(rbind, lapply(results, function(z) {
  ends <- if (is.null(z$search)) data.frame(Side = c('Lower','Upper'),
    Bound = NA_real_, Status = z$status) else z$search$endpoints
  cbind(data.frame(ParentId = z$case$ParentId, N = z$case$N, Role = z$case$Role,
    Order = z$case$Order, WaldLower = exp(z$case$Lower), WaldUpper = exp(z$case$Upper),
    ZeroLR = if (is.null(z$zero_lr)) NA_real_ else z$zero_lr,
    ProfilePoints = if (is.null(z$search)) 0L else nrow(z$search$profile),
    FailedPoints = if (is.null(z$search)) 0L else sum(!z$search$profile$Passed),
    Elapsed = z$elapsed), ends)
}))
write.csv(summary, file.path(out, 'endpoints.csv'), row.names = FALSE)
print(summary, row.names = FALSE)
