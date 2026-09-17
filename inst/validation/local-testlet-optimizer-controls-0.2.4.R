# Frozen optimizer-control comparison; see the companion plan.
source('inst/validation/local-testlet-estimation-0.2.4.R')

# Original search driver, with only the optim control list exposed.
testlet_controlled_fit <- function(fixture, start, control, fixed_variance = NULL,
                                orders = c(61L, 121L, 181L, 241L)) {
  input <- testlet_estimation_input(fixture)
  if (input != 'ready_for_bounded_search') stop(input)
  history <- list()
  last_par <- last_value <- NULL
  evaluate <- function(par) {
    if (identical(par, last_par)) return(last_value)
    prior <- NULL
    converged <- FALSE
    for (order in orders) {
      current <- testlet_estimation_evaluate(fixture, par, order)
      differences <- rep(NA_real_, 3)
      if (!is.null(prior)) {
        differences <- c(abs(current$loglik - prior$loglik),
          max(abs(current$moments - prior$moments)), max(abs(current$gradient - prior$gradient)))
        converged <- all(is.finite(differences)) && all(differences <= c(1e-7, 1e-7, 1e-6))
      }
      history[[length(history) + 1L]] <<- c(par, Order = order, LogLik = current$loglik,
        LogLikDifference = differences[1], MomentDifference = differences[2],
        ScoreDifference = differences[3], Qualified = as.numeric(converged))
      if (converged) break
      prior <- current
    }
    if (!converged) stop('quadrature_unresolved_at_trial')
    last_par <<- par
    last_value <<- current
    current
  }
  free <- if (is.null(fixed_variance)) 1:6 else 1:5
  expand <- function(x) if (is.null(fixed_variance)) x else c(x, variance = fixed_variance)
  captured <- stress_capture({
    fit <- stats::optim(start[free], function(x) -evaluate(expand(x))$loglik,
      function(x) -evaluate(expand(x))$gradient[free], method = 'L-BFGS-B',
      lower = c(rep(-8, 5), 0)[free], upper = c(rep(8, 5), 16)[free],
      control = control)
    par <- expand(fit$par)
    value <- evaluate(par)
    list(par = par, loglik = value$loglik, gradient = value$gradient, moments = value$moments,
      projected_score = testlet_projected_score(par, value$gradient),
      nuisance_score = max(abs(value$gradient[1:5])), convergence = fit$convergence,
      message = fit$message, counts = fit$counts,
      search_boundary = any(abs(par[1:5]) >= 8 - 1e-8) || par[6] >= 16 - 1e-8)
  })
  list(captured = captured, history = do.call(rbind, history), start = start,
    fixed_variance = fixed_variance, orders = orders)
}

run_testlet_optimizer_controls <- function() {
  prefix <- 'inst/validation/local-testlet-optimizer-controls-0.2.4'
  output <- 'validation-results/local-testlet-optimizer-controls-20260917'
  dir.create(output, recursive = TRUE, showWarnings = FALSE)
  input_path <- 'inst/validation/local-testlet-calibration-pilot-0.2.4-evidence.rds'
  old <- readRDS(input_path)
  inputs <- tools::md5sum(input_path)
  sources <- tools::md5sum(c(paste0(prefix, '.R'), names(old$plan$sources)))
  stopifnot(identical(old$plan$sources, tools::md5sum(names(old$plan$sources))))
  plan_path <- file.path(output, 'plan.rds')
  if (file.exists(plan_path)) {
    plan <- readRDS(plan_path)
    stopifnot(identical(plan$sources, sources), identical(plan$inputs, inputs))
  } else {
    controls <- c('cell-01-rep-02', 'cell-02-rep-01', 'cell-03-rep-01',
      'cell-04-rep-01', 'cell-03-rep-03', 'cell-03-rep-05')
    selected <- which(!old$status$FitReady | old$status$ID %in% controls)
    stopifnot(length(selected) == 23L, sum(old$status$FitReady[selected]) == 6L)
    settings <- data.frame(Setting = c('scaled', 'gradient', 'scaled_gradient'),
      ScaleByN = c(TRUE, FALSE, TRUE), Factr = c(1e3, 0, 0), TotalPGTol = c(1e-6, 5e-6, 5e-6))
    plan <- list(selected = old$status[selected, ],
      original = lapply(old$records[selected], function(x) x[c('spec', 'status', 'fit')]),
      generated = old$generated[selected], settings = settings, start = old$plan$start,
      sources = sources, inputs = inputs, design = readLines(paste0(prefix, '.md')),
      parent = system2('git', 'rev-parse HEAD', stdout = TRUE), started = Sys.time(), session = sessionInfo())
    saveRDS(plan, plan_path)
    write.csv(plan$selected, paste0(prefix, '-selection.csv'), row.names = FALSE)
  }
  # Two unchanged-control bridges verify the retained driver before new controls.
  for (id in c('cell-02-rep-01', 'cell-04-rep-06')) {
    j <- match(id, plan$selected$ID)
    path <- file.path(output, paste0('bridge-', id, '.rds'))
    if (file.exists(path)) {
      record <- readRDS(path)
      stopifnot(identical(record$sources, sources), identical(record$inputs, inputs))
    } else {
      cat('BRIDGE', id, '\n')
      fit <- stress_capture(testlet_controlled_fit(plan$generated[[j]]$fixture,
        plan$start, list(maxit = 250L, factr = 1e3, pgtol = 1e-6)))
      previous <- plan$original[[j]]$fit
      equal <- identical(fit$value$history, previous$value$history) &&
        identical(fit$value$captured$value, previous$value$captured$value) &&
        identical(fit$error, previous$error) && identical(fit$warnings, previous$warnings) &&
        identical(fit$value$captured$error, previous$value$captured$error) &&
        identical(fit$value$captured$warnings, previous$value$captured$warnings)
      record <- list(id = id, fit = fit, identical_numerics = equal, sources = sources, inputs = inputs)
      saveRDS(record, path)
    }
    stopifnot(record$identical_numerics)
  }
  for (k in seq_len(nrow(plan$settings))) for (j in seq_len(nrow(plan$selected))) {
    setting <- plan$settings[k, ]
    spec <- plan$selected[j, ]
    key <- paste(spec$ID, setting$Setting, sep = '-')
    path <- file.path(output, paste0(key, '-result.rds'))
    if (file.exists(path)) {
      record <- readRDS(path)
      stopifnot(identical(record$sources, sources), identical(record$inputs, inputs))
      cat('REUSE', key, '\n'); next
    }
    divisor <- if (setting$ScaleByN) spec$N else 1
    control <- list(maxit = 250L, fnscale = divisor, factr = setting$Factr,
      pgtol = setting$TotalPGTol / divisor)
    fixture <- plan$generated[[j]]$fixture
    fit_path <- file.path(output, paste0(key, '-fit.rds'))
    if (file.exists(fit_path)) {
      checkpoint <- readRDS(fit_path)
      stopifnot(identical(checkpoint$sources, sources), identical(checkpoint$inputs, inputs),
        identical(checkpoint$control, control))
      fit <- checkpoint$fit
    } else {
      cat('FIT', key, '\n')
      fit <- stress_capture(testlet_controlled_fit(fixture, plan$start, control))
      saveRDS(list(fit = fit, control = control, sources = sources, inputs = inputs), fit_path)
    }
    value <- fit$value$captured$value
    reference <- NULL
    order <- NA_integer_
    if (!is.null(value)) {
      order <- as.integer(tail(fit$value$history[, 'Order'], 1)) + 60L
      reference <- stress_capture(testlet_estimation_evaluate(fixture, value$par, order))
    }
    record <- list(spec = spec, setting = setting, control = control, fit = fit,
      reference = reference, reference_order = order, sources = sources, inputs = inputs, finished = Sys.time())
    saveRDS(record, path)
    cat('DONE', key, 'code', if (is.null(value)) NA else value$convergence,
      'score', if (is.null(value)) NA else value$projected_score,
      'error', fit$error, fit$value$captured$error, '\n')
  }
  stopifnot(identical(sources, tools::md5sum(names(sources))), identical(inputs, tools::md5sum(names(inputs))))
  cat('COMPLETE: two bridges and 69 new fits retained\n')
}

if (sys.nframe() == 0L) run_testlet_optimizer_controls()
