# Fixed-calibration assumption sensitivity, not refitting or a coverage study.
# Run after pkgload::load_all('.', compile = FALSE), from the development root.
run_gpcm_prior_sensitivity <- function(output_dir) {
  source("inst/validation/adaptive-quadrature-review-0.2.4.R", local = TRUE)
  input <- "tests/testthat/fixtures/mfrm-conditional-scoring-gpcm.rds"
  fixture <- readRDS(input)
  fit <- fixture$fit
  original <- serialize(fit, NULL)
  stopifnot(isTRUE(prediction_source_scoring_readiness(fit)$ready))
  mu <- unname(fit$population$coefficients[1L])
  sigma <- sqrt(fit$population$sigma2)
  scenarios <- data.frame(
    Scenario = c("retained", "lower_mean", "higher_mean", "narrower", "wider"),
    PriorMean = mu + sigma * c(0, -0.5, 0.5, 0, 0),
    PriorSD = sigma * c(1, 1, 1, 0.7, 1.5))
  # Sort and rotate by person index, without looking at scores. The 1/3/6-row
  # designs are nested; their facet mix also differs, so count is not isolated.
  people <- unique(as.character(fixture$data$Person))
  ordered <- lapply(seq_along(people), function(i) {
    d <- fixture$data[as.character(fixture$data$Person) == people[i], ]
    d <- d[order(d$Rater, d$Criterion), ]
    stopifnot(nrow(d) == 6L, all(d$Weight == 1))
    d[(seq_len(6L) + i - 2L) %% 6L + 1L, ]
  })
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  write.csv(scenarios, file.path(output_dir, "scenarios.csv"), row.names = FALSE)
  results <- list()
  designs <- list()
  params <- expand_params(fit$opt$par, build_param_sizes(fit$config), fit$config)
  started <- Sys.time()
  for (n in c(1L, 3L, 6L)) {
    data <- do.call(rbind, lapply(ordered, function(d) head(d, n)))
    designs[[as.character(n)]] <- data
    prepared <- prepare_mfrm_prediction_data(fit, data)
    population <- prepare_mfrm_prediction_population(fit, prepared)
    labels <- prepared$prep$levels$Person
    idx <- build_indices(prepared$prep, step_facet = fit$config$step_facet,
      slope_facet = fit$config$slope_facet,
      interaction_specs = fit$config$interaction_specs)
    base <- compute_base_eta(idx, params, fit$config)
    for (s in seq_len(nrow(scenarios))) {
      spec <- population$spec
      spec$coefficients[] <- scenarios$PriorMean[s]
      spec$sigma2 <- scenarios$PriorSD[s]^2
      scored <- compute_person_posterior_summary(idx, fit$config, params,
        gauss_hermite_normal(31L), labels, spec)$estimates
      refined <- compute_person_posterior_summary(idx, fit$config, params,
        gauss_hermite_normal(61L), labels, spec)$estimates
      stopifnot(identical(scored$Person, refined$Person))
      rows <- lapply(seq_len(nrow(scored)), function(i) {
        ids <- which(idx$person == match(scored$Person[i], labels))
        args <- list(scores = idx$score_k[ids], base = base[ids],
          steps = params$steps_mat[idx$step_idx[ids], , drop = FALSE],
          slopes = params$slopes[idx$slope_idx[ids]], weights = rep(1, length(ids)),
          mu = scenarios$PriorMean[s], sigma = scenarios$PriorSD[s],
          cdf_at = c(scored$Lower[i], scored$Upper[i]))
        reference <- do.call(aq_continuous_reference, args)
        reference64 <- do.call(aq_continuous_reference, c(args, list(limit = 64)))
        data.frame(Scenario = scenarios$Scenario[s], Ratings = n, scored[i, ],
          CalibrationMean = mu, CalibrationSD = sigma,
          QuadratureChange = max(abs(unlist(scored[i, c("Estimate", "SD")]) -
            unlist(refined[i, c("Estimate", "SD")]))),
          EAPError = abs(scored$Estimate[i] - reference["eap"]),
          SDError = abs(scored$SD[i] - reference["sd"]),
          IntervalCDFError = max(abs(reference[c("cdf1", "cdf2")] - c(0.025, 0.975))),
          ReferenceChange = max(abs(reference[c(1:3, 6:7)] - reference64[c(1:3, 6:7)])),
          ReferenceRelativeError = max(reference["relative_error"], reference64["relative_error"]),
          ReferenceLogTail = max(reference["log_relative_tail_bound"], reference64["log_relative_tail_bound"]),
          row.names = NULL)
      })
      result <- do.call(rbind, rows)
      results[[paste(n, s)]] <- result
      write.csv(result, file.path(output_dir, paste0("scores-", n, "-", scenarios$Scenario[s], ".csv")), row.names = FALSE)
      cat("Completed", n, "ratings /", scenarios$Scenario[s], "\n")
      flush.console()
    }
  }
  scores <- do.call(rbind, results)
  baseline <- scores[scores$Scenario == "retained", ]
  key <- function(d) paste(d$Ratings, d$Person)
  match_baseline <- match(key(scores), key(baseline))
  scores$EAPChange <- scores$Estimate - baseline$Estimate[match_baseline]
  scores$EAPChangeInBaselineSD <- scores$EAPChange / baseline$SD[match_baseline]
  scores$WidthChange <- (scores$Upper - scores$Lower) -
    (baseline$Upper - baseline$Lower)[match_baseline]
  summary <- do.call(rbind, lapply(split(scores, interaction(scores$Ratings, scores$Scenario)), function(d) {
    data.frame(Scenario = d$Scenario[1], Ratings = d$Ratings[1], Persons = nrow(d),
      MedianAbsEAPChange = median(abs(d$EAPChange)), MaxAbsEAPChange = max(abs(d$EAPChange)),
      MedianAbsChangeInBaselineSD = median(abs(d$EAPChangeInBaselineSD)),
      MaxAbsChangeInBaselineSD = max(abs(d$EAPChangeInBaselineSD)),
      MedianWidthChange = median(d$WidthChange),
      MinWidthChange = min(d$WidthChange), MaxWidthChange = max(d$WidthChange))
  }))
  write.csv(scores, file.path(output_dir, "scores.csv"), row.names = FALSE)
  write.csv(summary, file.path(output_dir, "summary.csv"), row.names = FALSE)
  stopifnot(identical(serialize(fit, NULL), original))
  saveRDS(list(scenarios = scenarios, designs = designs,
    calibration = list(input_md5 = tools::md5sum(input), mean = mu, sd = sigma,
      parameters = fit$opt$par, config = fit$config),
    source_md5 = tools::md5sum(c(list.files("R", "[.]R$", full.names = TRUE),
      "inst/validation/gpcm-prior-sensitivity-20260926.R",
      "inst/validation/adaptive-quadrature-review-0.2.4.R")),
    scores = scores, summary = summary, elapsed = Sys.time() - started,
    session = sessionInfo()), file.path(output_dir, "audit.rds"))
  # Accuracy tolerances are numerical checks, not substantive sensitivity cutoffs.
  stopifnot(nrow(scores) == 1800L, all(is.finite(as.matrix(scores[vapply(scores, is.numeric, TRUE)]))),
    max(scores$QuadratureChange, scores$EAPError, scores$SDError) < 1e-5,
    max(scores$IntervalCDFError) < 1e-8, max(scores$ReferenceChange) < 1e-8,
    max(scores$ReferenceRelativeError) < 1e-9,
    max(scores$ReferenceLogTail) < log(1e-12))
  print(summary, row.names = FALSE, digits = 5)
  invisible(scores)
}
