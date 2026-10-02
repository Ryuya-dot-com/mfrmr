# Inspect retained pilot points; no data generation, structural refit or CI claim.
# Rscript THIS_FILE OUTPUT
source('inst/validation/mfrm-facet-structure-pilot-20261001.R')
out <- commandArgs(trailingOnly = TRUE)[1L]
m <- pilot_load(out)
stopifnot(all(file.exists(file.path(out, 'fits', paste0(m$jobs$Job, '.status')))))
tolerances <- list(probability = 1e-12, covariance_relative = 1e-5,
  adaptive_log_marginal = 1e-7, fixed_log_marginal = 1e-4)
saveRDS(list(tolerances = tolerances, source_md5 = tools::md5sum(c(
  'inst/validation/mfrm-facet-structure-checks-20261001.R',
  file.path(out, c('manifest.rds','run.py')))),
  fit_md5 = tools::md5sum(list.files(file.path(out,'fits'), '\\.rds$', full.names=TRUE)),
  created = Sys.time()), file.path(out, 'checks-manifest.rds'))
stopifnot(file.copy('inst/validation/mfrm-facet-structure-checks-20261001.R',
  file.path(out,'source/checks.R'), overwrite=FALSE))
results <- list()
for (i in seq_len(nrow(m$jobs))) {
  job <- m$jobs[i, ]; path <- file.path(out, 'fits', paste0(job$Job, '.rds'))
  if (!file.exists(path)) next
  x <- readRDS(file.path(out, 'inputs', paste0(job$Input, '.rds')))
  z <- readRDS(path); fit <- z$fit
  if (!is.null(fit[['pilot_error', exact = TRUE]])) next
  result <- tryCatch({
    if (job$Method == 'MML') {
      config <- fit$config
      sizes <- mfrmr:::build_param_sizes(config)
      idx <- mfrmr:::build_indices(fit$prep, config$step_facet, config$slope_facet,
        config$interaction_specs, gpcm_spec = config$gpcm_spec)
      params <- mfrmr:::expand_params(fit$opt$par, sizes, config)
      review <- mfrmr:::mfrmr_adaptive_quadrature_review(idx, config, params,
        mfrmr:::gauss_hermite_normal(31L), fit$prep$levels$Person, c(31L, 61L))
      gradients <- lapply(c(31L,61L), function(q) mfrmr:::mfrm_grad_mml(
        fit$opt$par, idx, config, sizes, mfrmr:::gauss_hermite_normal(q)))
      likelihood <- vapply(c(31L,61L), function(q) mfrmr:::mfrm_loglik_mml(
        fit$opt$par, idx, config, sizes, mfrmr:::gauss_hermite_normal(q)), 0)
      # Compare the literal generating formula with native probability evaluation.
      # Assign true effects by labels, rather than reusing the native parameter vector.
      tc <- config; tc$population_spec <- list(active = FALSE)
      tp <- params
      for (f in x$facets) tp$facets[[f]] <- x$truth[[f]][as.integer(config$facet_levels[[f]])]
      tp$steps_mat <- x$truth$steps
      tp$log_slopes <- x$truth$log_slopes; tp$slopes <- exp(tp$log_slopes)
      nodes <- c(-3, 0, 3)
      native <- mfrmr:::mfrm_mml_logprob_bundle_r(idx, tc,
        list(nodes = nodes, weights = rep(1/3,3)), tp,
        mfrmr:::compute_base_eta(idx, tp, tc), include_probs = TRUE)$prob_list
      d <- fit$prep$data
      location <- Reduce(`+`, lapply(x$facets, function(f) x$truth[[f]][as.integer(as.character(d[[f]]))]))
      owner <- as.integer(as.character(d$Criterion))
      discrepancy <- vapply(seq_along(nodes), function(q) {
        step <- cbind(0, x$truth$steps[,1], rowSums(x$truth$steps))[owner,,drop=FALSE]
        logits <- (outer(nodes[q]-location, 0:2)-step) * exp(x$truth$log_slopes[owner])
        mass <- exp(logits - apply(logits,1,max)); mass <- mass/rowSums(mass)
        max(abs(mass-native[[q]]))
      }, 0)
      stopifnot(max(discrepancy) < tolerances$probability,
        abs(likelihood[1]-fit$opt$value) < 1e-8,
        isTRUE(fit$population$active), length(fit$population$coefficients) == 1L)
      high <- review[review$AdaptiveNodes == 61L, ]
      row <- data.frame(Job = job$Job, ProbabilityError = max(discrepancy),
        PopulationMean = unname(fit$population$coefficients), PopulationSD = sqrt(fit$population$sigma2),
        ReviewAvailable = all(review$Status == 'computed'),
        MaxFixedAdaptiveLogChange = max(abs(high$LogMarginalChange)),
        MaxAdaptiveRefinementLogChange = max(abs(high$AdaptiveLogMarginalChangeFromPrevious)),
        Fixed61ObjectiveChange = likelihood[2]-likelihood[1],
        Gradient31 = max(abs(gradients[[1]])), Gradient61 = max(abs(gradients[[2]])),
        GradientChange = max(abs(gradients[[2]]-gradients[[1]])))
      list(kind = 'MML', row = row, review = review, gradients = gradients,
        interpretation = 'Integration checks at unchanged q31 point; no refit or coverage statement.')
    } else {
      p <- pilot_problem(x); beta <- pilot_beta(fit, x$parameters)
      k <- if (job$Method == 'JML') 0L else as.integer(sub('JML','',job$Method))
      if (!all(is.finite(beta))) stop('No finite retained point for equation inspection.')
      U <- p$evaluate(beta,k)$value
      centered <- U
      for (g in unique(p$roster)) {
        ix <- which(p$roster == g)
        centered[ix,] <- sweep(U[ix,,drop=FALSE],2,colMeans(U[ix,,drop=FALSE]))
      }
      row <- data.frame(Job = job$Job, Order = k, ProfileMeanResidual = max(abs(colMeans(U))),
        CenteredScoreRank = qr(centered)$rank, Parameters = ncol(U),
        CenteredRankCeiling = x$N-length(unique(p$roster)),
        JacobianDifference = NA_real_, MeatDifference = NA_real_, CovarianceRelativeDifference = NA_real_)
      stopifnot(row$CenteredScoreRank <= row$CenteredRankCeiling)
      cv <- fit$jml_adjustment$covariance
      A <- V <- NULL
      if (isTRUE(cv$available)) {
        # A smaller independent finite-difference step for the complete equation;
        # score evaluations still use the native implementation (not a second DGP).
        A <- vapply(seq_along(beta), function(j) {
          h <- 2.5e-5 * max(1,abs(beta[j])); step <- numeric(length(beta)); step[j] <- h
          (p$mean_score(beta+step,k)-p$mean_score(beta-step,k))/(2*h)
        }, numeric(length(beta)))
        meat <- crossprod(centered)/x$N
        V <- solve(A) %*% meat %*% t(solve(A))/x$N
        row$JacobianDifference <- max(abs(A-cv$result$jacobian))/max(1,max(abs(A)))
        row$MeatDifference <- max(abs(meat-cv$result$meat))
        row$CovarianceRelativeDifference <- max(abs(V-cv$result$vcov))/max(abs(V))
        stopifnot(row$JacobianDifference < 1e-5, row$MeatDifference < 1e-12,
          row$CovarianceRelativeDifference < tolerances$covariance_relative)
      }
      list(kind = 'JML', row = row, derivative = A, covariance = V,
        interpretation = 'Unchanged public structural point; ordinary order-0 residual is not a structural-root refit or error bound.')
    }
  }, error = function(e) list(error = conditionMessage(e)))
  results[[job$Job]] <- result
  saveRDS(results, file.path(out, 'checks.rds'))
  cat(job$Job, if (is.null(result[['error',exact=TRUE]])) 'checked' else result$error, '\n')
}
for (kind in c('MML','JML')) {
  rows <- lapply(results, function(x) if (identical(x$kind, kind)) x$row else NULL)
  write.csv(do.call(rbind, rows), file.path(out, paste0(tolower(kind), '-checks.csv')), row.names=FALSE)
}
