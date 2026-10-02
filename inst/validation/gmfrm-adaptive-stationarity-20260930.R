# Diagnose the two retained refusals before changing optimization or inference.
# Reuse the independent Louis reference; no simulated data or threshold tuning.
pkgload::load_all('.', quiet = TRUE, compile = FALSE)
source('tests/testthat/helper-gmfrm-information.R')
out <- 'validation-results/gmfrm-adaptive-stationarity-20260930'
baseline <- 'validation-results/gmfrm-adaptive-start-20260930'
jobs <- c('001-rotating_pairs-0.5.rds', '026-rotating_pairs-0.5.rds')
inputs <- file.path(baseline, jobs)
dir.create(out, recursive = TRUE, showWarnings = FALSE)
stopifnot(!file.exists(file.path(out, 'diagnosis.rds')))
sources <- c('R/core-optimizer.R', 'R/core-adaptive-quadrature.R', 'R/mfrm_core.R',
  'R/core-gpcm-product-slopes.R', 'tests/testthat/helper-gmfrm-information.R',
  'inst/validation/gmfrm-adaptive-stationarity-20260930.R')
for (file in sources) {
  dest <- file.path(out, 'diagnostic-source', file)
  dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
  stopifnot(file.copy(file, dest, overwrite = TRUE))
}
diagnose <- function(input) {
  fit <- readRDS(input)$stages[['31']]$fitting$value
  problem <- do.call(mfrm_gmfrm_problem, fit$gmfrm$specification)
  setup <- problem$common; par <- fit$opt$par; config <- fit$config
  parameters <- expand_params(par, setup$sizes, config)
  reference <- lapply(c(31L, 61L), function(q) {
    basis <- mfrmr_adaptive_quadrature_basis(setup$idx, config, parameters,
      gauss_hermite_normal(q), compute_base_eta(setup$idx, parameters, config))
    gmfrm_louis_reference(fit$gmfrm$specification, par, basis$nodes, basis$log_weights)
  })
  names(reference) <- c('q31', 'q61')
  evaluate <- mfrmr_make_adaptive_mml_evaluator(setup$idx, config, setup$sizes, 31L)
  value <- function(p) evaluate(p)$value
  gradient <- function(p) evaluate(p)$gradient
  at <- evaluate(par)
  ref <- reference$q61
  eig <- eigen(ref$information, symmetric = TRUE)
  direction <- data.frame(Parameter = names(problem$start),
    Value = as.numeric(par), WeakDirection = eig$vectors[, length(par)])
  root <- tryCatch(chol(ref$information), error = function(e) NULL)
  summary <- data.frame(Job = basename(input), NLL = at$value,
    LiteralNLLDifference = abs(at$value + sum(ref$log_marginal)),
    Gradient = max(abs(at$gradient)),
    IndependentGradientDifference = max(abs(at$gradient + colSums(ref$scores))),
    SmallestCurvature = min(eig$values), LargestCurvature = max(eig$values),
    ReciprocalCondition = rcond(ref$information),
    CurvatureScaledGradient = if (is.null(root)) NA_real_ else
      sqrt(sum(forwardsolve(t(root), at$gradient)^2)),
    HessianQuadratureDifference = max(abs(reference$q31$information - ref$information)))
  proposal <- mfrm_optimizer_curvature_proposal(par, value, gradient)
  proposal$evaluation <- if (is.null(proposal$par)) NULL else evaluate(proposal$par)
  information <- if (startsWith(basename(input), '026-'))
    compute_mml_parameter_covariance(fit) else NULL
  list(summary = summary, reference = reference, weak_direction = direction,
    proposal = proposal, information = information)
}
elapsed <- system.time(results <- parallel::mclapply(inputs, diagnose,
  mc.cores = 2L, mc.set.seed = FALSE))[["elapsed"]]
names(results) <- jobs
saveRDS(list(results = results, elapsed = elapsed, input_hashes = tools::md5sum(inputs),
  source_hashes = tools::md5sum(sources),
  baseline_manifest = readRDS(file.path(baseline, 'manifest.rds'))),
  file.path(out, 'diagnosis.rds'))
stopifnot(all(vapply(results, is.list, TRUE)))
for (job in jobs) {
  x <- results[[job]]
  print(x$summary, row.names = FALSE, digits = 12)
  print(x$weak_direction[order(abs(x$weak_direction$WeakDirection), decreasing = TRUE)[1:5], ], digits = 10)
  cat('Curvature proposal:', x$proposal$error, '\n')
  if (!is.null(x$proposal$evaluation)) cat('Proposed NLL:',
    format(x$proposal$evaluation$value, digits = 15), 'gradient:',
    max(abs(x$proposal$evaluation$gradient)), '\n')
  if (!is.null(x$information)) print(x$information$solution_information$inverse_review)
}
cat('Elapsed:', elapsed, 'seconds\n')
