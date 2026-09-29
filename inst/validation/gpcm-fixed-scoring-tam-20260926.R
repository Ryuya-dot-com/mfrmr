# Repository-only fixed-calibration comparison; no calibration is reestimated.
# Run from the package root after pkgload::load_all(compile = FALSE).
# Includes portable replay for JML; not a coverage or free-estimation comparison.
run_gpcm_fixed_scoring_tam <- function(output_dir, paths = c(
    shared = "validation-results/gpcm-probability-refit-20260925/refit-788.rds",
    separate = "validation-results/gpcm-separated-owner-pilot-20260926/n120-complete-01.rds"
  ), scoring_prior = NULL, native_nodes = c(101L, 141L)) {
  stopifnot(requireNamespace("TAM", quietly = TRUE))
  stopifnot(all(file.exists(paths)))
  stopifnot(length(native_nodes) == 2L, all(is.finite(native_nodes)),
    all(native_nodes == as.integer(native_nodes)), all(native_nodes >= 2L),
    native_nodes[2L] > native_nodes[1L])
  # Numerical agreement criteria, declared before comparison; not accuracy or
  # coverage claims. Both integrations must stabilize more tightly than scores.
  tolerance <- c(probability = 1e-11, score = 1e-6, integration = 1e-7)
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  manifest <- list(
    source_commit = system2("git", c("rev-parse", "HEAD"), stdout = TRUE),
    source_md5 = tools::md5sum(c(list.files("R", "[.]R$", full.names = TRUE),
      "inst/validation/gpcm-fixed-scoring-tam-20260926.R")),
    fixture_md5 = tools::md5sum(paths), tolerance = tolerance,
    scoring_prior = scoring_prior, native_nodes = native_nodes,
    TAM = as.character(utils::packageVersion("TAM")), session = sessionInfo()
  )
  saveRDS(manifest, file.path(output_dir, "manifest.rds"))
  compare_one <- function(path) {
    payload <- readRDS(path)
    fit <- if (inherits(payload, "mfrm_fit")) payload else payload$fit
    cfg <- fit$config
    stopifnot(cfg$model == "GPCM", cfg$method %in% c("MML", "JML"),
      identical(cfg$facet_names, c("Rater", "Criterion")),
      all(cfg$facet_signs == -1), length(cfg$interaction_specs) == 0L)
    if (cfg$method == "MML") stopifnot(length(fit$population$coefficients) == 1L,
      isTRUE(fit$population$active))
    if (cfg$method == "JML") stopifnot(cfg$slope_facet == cfg$step_facet,
      !isTRUE(fit$population$active))
    contexts <- expand.grid(cfg$facet_levels[c("Rater", "Criterion")],
      stringsAsFactors = FALSE)
    ni <- nrow(contexts); nk <- cfg$n_cat; k <- seq_len(nk) - 1L
    mu <- if (cfg$method == "JML") 0 else unname(fit$population$coefficients[[1L]])
    sigma <- if (cfg$method == "JML") 1 else sqrt(fit$population$sigma2)
    if (!is.null(scoring_prior)) {mu <- scoring_prior$mean; sigma <- scoring_prior$sd}
    slope <- fit$slopes$Estimate[match(contexts[[cfg$slope_facet]],
      fit$slopes$SlopeFacet)]
    location <- Reduce(`+`, lapply(cfg$facet_names, function(facet) {
      tab <- fit$facets$others[fit$facets$others$Facet == facet, ]
      tab$Estimate[match(contexts[[facet]], tab$Level)]
    }))
    steps <- t(vapply(contexts[[cfg$step_facet]], function(owner) {
      tab <- fit$steps[fit$steps$StepFacet == owner, ]
      tab$Estimate[match(paste0("Step_", seq_len(nk - 1L)), tab$Step)]
    }, numeric(nk - 1L)))
    stopifnot(all(is.finite(c(mu, sigma, slope, location, steps))), sigma > 0,
      all(slope > 0))
    # theta = mu + sigma*z. TAM uses AXsi[j,k] + B[j,k]*z.
    ax <- t(vapply(seq_len(ni), function(j)
      slope[j] * (k * (mu - location[j]) - c(0, cumsum(steps[j, ]))), numeric(nk)))
    b <- array(outer(slope * sigma, k), c(ni, nk, 1L))
    a <- array(0, c(ni, nk, ni * (nk - 1L)))
    xsi <- numeric(dim(a)[3L])
    pos <- 0L
    for (j in seq_len(ni)) for (cat in 2:nk) {
      pos <- pos + 1L; a[j, cat, pos] <- 1; xsi[pos] <- ax[j, cat]
    }
    # New synthetic respondents: category endpoints, mixed complete responses,
    # and an incomplete known assignment. No training responses are reused.
    response <- rbind(lower = rep(0L, ni), upper = rep(nk - 1L, ni),
      mixed = (seq_len(ni) - 1L) %% nk,
      incomplete = seq_len(ni) %% nk)
    response[4L, seq.int(2L, ni, by = 2L)] <- NA
    colnames(response) <- paste0("context", seq_len(ni))
    new_rows <- do.call(rbind, lapply(seq_len(nrow(response)), function(p) {
      d <- contexts; d$Person <- rownames(response)[p]
      d$Score <- cfg$score_map$OriginalScore[match(response[p, ] + cfg$rating_min,
        cfg$score_map$InternalScore)]
      stopifnot(identical(is.na(d$Score), is.na(as.vector(response[p, ]))))
      d[!is.na(d$Score), ]
    }))
    fit_tam <- function(nodes) {
      ans <- TAM::tam.mml(response, A = a, B = b,
        xsi.fixed = cbind(seq_along(xsi), xsi), beta.fixed = matrix(c(1, 1, 0), 1, 3),
        variance.fixed = matrix(c(1, 1, 1), 1, 3), est.variance = FALSE,
        item.elim = FALSE, verbose = FALSE,
        control = list(nodes = seq(-9, 9, length.out = nodes), maxiter = 2L,
          progress = FALSE))
      # Verify that the external engine actually held the full scoring model.
      stopifnot(max(abs(ans$AXsi - ax)) < tolerance["probability"],
        max(abs(ans$B - b)) < tolerance["probability"],
        max(abs(ans$beta)) < tolerance["probability"],
        max(abs(ans$variance - 1)) < tolerance["probability"])
      ans
    }
    tam <- lapply(c(121L, 181L), fit_tam)
    # The original MML comparison uses 101/141. JML refinement orders are
    # recorded separately without relaxing the predeclared stability criterion.
    native <- lapply(native_nodes, function(q)
      mfrmr::predict_mfrm_units(fit, new_rows, scoring_quad_points = q,
        n_draws = 0, scoring_prior = scoring_prior,
        readiness_policy = if (cfg$method == "JML") "error" else "review"))
    portable <- NULL
    if (cfg$method == "JML") {
      artifact <- mfrmr::freeze_mfrm_calibration(mfrmr::validate_mfrm_calibration(
        mfrmr::extract_mfrm_calibration(fit, scoring_quad_points = native_nodes[2L])))
      artifact_path <- file.path(output_dir, paste0(basename(path), "-calibration.rds"))
      mfrmr::save_mfrm_calibration(artifact, artifact_path)
      portable <- mfrmr::score_mfrm_calibration(mfrmr::load_mfrm_calibration(artifact_path),
        new_rows, scoring_prior = scoring_prior)
      saveRDS(list(portable = portable, native = native[[2L]]),
        file.path(output_dir, paste0(basename(path), "-scores.rds")))
      at <- match(native[[2L]]$estimates$Person, portable$estimates$Person)
      stopifnot(!anyNA(at), !anyDuplicated(portable$estimates$Person),
        max(abs(as.matrix(portable$estimates[at, c("Estimate", "SD", "Lower", "Upper")]) -
          as.matrix(native[[2L]]$estimates[c("Estimate", "SD", "Lower", "Upper")]))) < 1e-10)
    }
    # Independent scalar adjacent-logit calculation, with native-scale theta.
    oracle <- array(NA_real_, dim(tam[[2L]]$rprobs))
    z <- as.vector(tam[[2L]]$theta)
    for (j in seq_len(ni)) for (h in seq_along(z)) {
      logit <- c(0, cumsum(slope[j] *
        (mu + sigma * z[h] - location[j] - steps[j, ])))
      p <- exp(logit - max(logit)); oracle[j, , h] <- p / sum(p)
    }
    loglik_difference <- max(vapply(seq_len(nrow(response)), function(p) {
      observed <- which(!is.na(response[p, ]))
      likelihood <- function(prob) Reduce(`+`, lapply(observed, function(j)
        log(prob[j, response[p, j] + 1L, ])))
      max(abs(likelihood(oracle) - likelihood(tam[[2L]]$rprobs)))
    }, numeric(1)))
    stopifnot(is.finite(loglik_difference), loglik_difference < 1e-10)
    external_scores <- lapply(tam, function(x)
      cbind(Estimate = mu + sigma * x$person$EAP,
        SD = sigma * x$person$SD.EAP))
    native_scores <- lapply(native, function(x)
      as.matrix(x$estimates[match(rownames(response), x$estimates$Person), c("Estimate", "SD")]))
    stopifnot(all(vapply(c(external_scores, native_scores), function(x)
      identical(dim(x), c(4L, 2L)) && all(is.finite(x)), logical(1))))
    metrics <- c(probability = max(abs(oracle - tam[[2L]]$rprobs)),
      EAP = max(abs(external_scores[[2L]][, 1] - native_scores[[2L]][, 1])),
      SD = max(abs(external_scores[[2L]][, 2] - native_scores[[2L]][, 2])),
      TAM_grid = max(abs(external_scores[[2L]] - external_scores[[1L]])),
      mfrmr_grid = max(abs(native_scores[[2L]] - native_scores[[1L]])))
    list(metrics = metrics, passed = all(metrics < tolerance[c(
      "probability", "score", "score", "integration", "integration")]),
      context_map = contexts, AXsi = ax, B = b, mean = mu, sd = sigma,
      response = response, external_scores = external_scores,
      native_scores = native_scores, tam = tam, native = native, portable = portable,
      calibration_method = cfg$method, loglik_difference = loglik_difference)
  }
  results <- lapply(paths, compare_one)
  saveRDS(results, file.path(output_dir, "results.rds"))
  summary <- do.call(rbind, lapply(names(results), function(n)
    data.frame(Owner = n, t(results[[n]]$metrics), Passed = results[[n]]$passed)))
  write.csv(summary, file.path(output_dir, "summary.csv"), row.names = FALSE)
  print(summary)
  stopifnot(all(summary$Passed))
  invisible(results)
}
