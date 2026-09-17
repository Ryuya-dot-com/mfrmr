# Bounded allocation follow-up. The explicit-target scoring driver is copied from
# the frozen pilot, with only its signature/target assignment changed. Keep that
# historical source identity intact; all numerical kernels remain shared.
source('inst/validation/local-testlet-calibration-pilot-0.2.4.R')

testlet_allocation_score <- function(generated, par, method, targets, unavailable = '') {
  rows <- attempts <- list()
  rules <- rbind(c(61L, 41L), c(121L, 81L), c(181L, 121L), c(241L, 181L))
  values <- list()
  get_value <- function(order) {
    key <- as.character(order)
    if (is.null(values[[key]])) values[[key]] <<- testlet_estimation_evaluate(generated$fixture, par, order)
    values[[key]]
  }
  for (i in seq_len(nrow(targets))) {
    target_row <- targets[i, ]
    members <- na.omit(c(target_row$P1, target_row$P2))
    previous <- chosen <- NULL
    target_attempts <- list()
    if (!nzchar(unavailable)) for (k in seq_len(nrow(rules))) {
      captured <- stress_capture({
        point <- get_value(rules[k, 1])
        moments <- point$moments[members, 1:2, drop = FALSE]
        center <- if (length(members) == 1) moments[1, 1] else moments[1, 1] - moments[2, 1]
        target <- list(fixture = generated$fixture, par = par, persons = members,
          lognormalizer = sum(point$person_loglik[members]))
        density <- testlet_posterior_density_function(target, rules[k, 1], rules[k, 2])
        integrals <- lapply(list(c(-Inf, center), c(center, Inf),
          if (target_row$Truth <= center) c(-Inf, target_row$Truth) else c(target_row$Truth, Inf)),
          function(bounds) {
            z <- integrate(density, bounds[1], bounds[2], rel.tol = 1e-8, abs.tol = 1e-8, subdivisions = 200L)
            list(bounds = bounds, value = z$value, error = z$abs.error,
              subdivisions = z$subdivisions, message = z$message)
          })
        mass <- integrals[[1]]$value + integrals[[2]]$value
        stopifnot(is.finite(mass), mass > 0)
        tail <- integrals[[3]]$value / mass
        cdf <- if (target_row$Truth <= center) tail else 1 - tail
        integration_error <- (integrals[[3]]$error + integrals[[1]]$error + integrals[[2]]$error) / mass
        changes <- if (is.null(previous)) c(Inf, Inf) else c(abs(cdf - previous$cdf), abs(center - previous$mean))
        ambiguous <- min(abs(cdf - c(.025, .975))) <= 1e-6
        list(cdf = cdf, mass = mass, mean = center, sd = sqrt(sum(moments[, 2]^2)),
          integration_error = integration_error, changes = changes, ambiguous = ambiguous, integrals = integrals,
          ready = all(is.finite(c(cdf, center, changes, integration_error))) &&
            cdf >= 0 && cdf <= 1 && abs(mass - 1) <= 1e-7 &&
            all(changes <= 1e-6) && integration_error <= 1e-6 && !ambiguous)
      })
      target_attempts[[k]] <- list(rule = rules[k, ], captured = captured)
      if (!is.null(captured$value) && !length(captured$warnings)) {
        if (captured$value$ready) { chosen <- target_attempts[[k]]; break }
        previous <- captured$value
      }
    }
    ready <- !is.null(chosen)
    rows[[i]] <- cbind(target_row, Method = method, Available = ready,
      CDF = if (ready) chosen$captured$value$cdf else NA_real_,
      Mean = if (ready) chosen$captured$value$mean else NA_real_,
      SD = if (ready) chosen$captured$value$sd else NA_real_,
      Covered = if (ready) chosen$captured$value$cdf >= .025 && chosen$captured$value$cdf <= .975 else NA,
      LocalOrder = if (ready) chosen$rule[1] else NA_integer_,
      MidpointOrder = if (ready && length(members) == 2) chosen$rule[2] else NA_integer_,
      Reason = if (ready) '' else if (nzchar(unavailable)) unavailable else 'cdf_unresolved')
    attempts[[target_row$Target]] <- target_attempts
  }
  list(rows = do.call(rbind, rows), attempts = attempts)
}

run_testlet_pair_allocation <- function(plan_only = FALSE) {
  prefix <- 'inst/validation/local-testlet-pair-allocation-0.2.4'
  output <- 'validation-results/local-testlet-pair-allocation-20260917'
  dir.create(output, recursive = TRUE, showWarnings = FALSE)
  input <- 'inst/validation/local-testlet-independent-pilot-0.2.4-evidence.rds'
  x <- readRDS(input)
  stopifnot(nrow(x$status) == 40L, all(x$status$FitReady), all(x$rows$Available), all(x$audit$Pass),
    identical(x$plan$sources, tools::md5sum(names(x$plan$sources))))
  inputs <- tools::md5sum(input)
  sources <- tools::md5sum(c(paste0(prefix, '.R'), names(x$plan$sources)))
  plan_path <- file.path(output, 'plan.rds')
  if (file.exists(plan_path)) {
    plan <- readRDS(plan_path)
    stopifnot(identical(plan$inputs, inputs), identical(plan$sources, sources))
  } else {
    targets <- lapply(x$generated, function(g) {
      k <- seq_len(length(g$theta) %/% 2L)
      p <- 2L * k - 1L; q <- 2L * k
      data.frame(Target = paste0('P', p, '_minus_P', q), Kind = 'difference',
        P1 = p, P2 = q, Truth = g$theta[p] - g$theta[q])
    })
    plan <- list(inputs = inputs, sources = sources, manifest = x$plan$manifest,
      data_hashes = x$plan$data_hashes, targets = targets,
      pair_counts = list('24' = c(4L, 8L, 12L), '120' = c(4L, 12L, 30L, 60L)),
      bridge_indices = which(x$plan$manifest$Replicate == 1L),
      design = readLines(paste0(prefix, '.md')), created = Sys.time(),
      parent = system2('git', 'rev-parse HEAD', stdout = TRUE), session = sessionInfo())
    saveRDS(plan, plan_path)
  }
  if (plan_only) { cat('FROZEN: 40 retained datasets; 2560 new method/pair rows\n'); return(invisible(plan)) }
  bridge_path <- file.path(output, 'bridge.rds')
  if (file.exists(bridge_path)) {
    bridge <- readRDS(bridge_path)
    stopifnot(identical(bridge$sources, sources), identical(bridge$inputs, inputs))
  } else {
    bridge_records <- list()
    for (j in plan$bridge_indices) for (method in c('oracle', 'plugin')) {
      r <- x$records[[j]]; g <- x$generated[[j]]
      par <- if (method == 'oracle') g$par else r$fit$value$captured$value$par
      scored <- testlet_allocation_score(g, par, method, plan$targets[[j]][1, ])
      old <- r[[method]]$rows
      old <- old[old$Target == scored$rows$Target, ]
      rownames(old) <- rownames(scored$rows) <- NULL
      # Compare the entire row and each retained integral, excluding elapsed time.
      old_attempts <- r[[method]]$attempts[[old$Target]]
      new_attempts <- scored$attempts[[old$Target]]
      clean <- function(attempts) lapply(attempts, function(a) {
        a$captured$elapsed <- NULL; a
      })
      bridge_records[[length(bridge_records) + 1L]] <- list(spec = r$spec, method = method,
        scored = scored, rows_equal = identical(old, scored$rows),
        attempts_equal = identical(clean(old_attempts), clean(new_attempts)))
    }
    bridge <- list(records = bridge_records, sources = sources, inputs = inputs, completed = Sys.time())
    saveRDS(bridge, bridge_path)
  }
  stopifnot(all(vapply(bridge$records, function(b) b$rows_equal && b$attempts_equal, logical(1))))
  cat('BRIDGE: 8 saved pair/method comparisons exact\n')
  for (j in seq_len(nrow(plan$manifest))) {
    spec <- plan$manifest[j, ]
    path <- file.path(output, paste0(spec$ID, '-result.rds'))
    if (file.exists(path)) {
      old <- readRDS(path)
      stopifnot(identical(old$sources, sources), identical(old$inputs, inputs),
        identical(old$data_hash, plan$data_hashes[j]), identical(old$spec, spec))
      cat('REUSE', spec$ID, '\n'); next
    }
    r <- x$records[[j]]; g <- x$generated[[j]]
    targets <- plan$targets[[j]][-(1:4), ]
    cat('SCORE', spec$ID, 'additional pairs', nrow(targets), '\n')
    start <- proc.time()[['elapsed']]
    oracle <- testlet_allocation_score(g, g$par, 'oracle', targets)
    plugin <- testlet_allocation_score(g, r$fit$value$captured$value$par, 'plugin', targets)
    result <- list(spec = spec, sources = sources, inputs = inputs, data_hash = plan$data_hashes[j],
      oracle = oracle, plugin = plugin, elapsed = proc.time()[['elapsed']] - start, finished = Sys.time())
    saveRDS(result, path)
    cat('DONE', spec$ID, 'oracle', sum(oracle$rows$Available), 'plugin', sum(plugin$rows$Available),
      'seconds', result$elapsed, '\n')
  }
  stopifnot(identical(inputs, tools::md5sum(names(inputs))),
    identical(sources, tools::md5sum(names(sources))))
  cat('ALLOCATION SCORING COMPLETE: no calibration fits or person scores recomputed\n')
}

if (sys.nframe() == 0L) run_testlet_pair_allocation('plan' %in% commandArgs(TRUE))
