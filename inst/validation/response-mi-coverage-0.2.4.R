# Rscript inst/validation/response-mi-coverage-0.2.4.R preflight|run <directory> [worker] [workers]
.libPaths(c(normalizePath(".r-library"), .libPaths()))
pkgload::load_all(".", quiet = TRUE)
source("inst/validation/facet-sandwich-0.2.4.R")

mi_trial <- function(id, mask, directory, model, preflight = FALSE) {
  path <- file.path(directory, sprintf("%s-%04d-%s.rds", if (preflight) "preflight" else "trial", id, mask))
  if (file.exists(path)) stop("Refusing to replace ", path)
  started <- proc.time()[["elapsed"]]
  seed <- if (preflight) 92391001L else 92231000L + id
  d <- sandwich_generate(sandwich_case("RSM", FALSE), 80L, seed)
  d$Event <- paste0("E", seq_len(nrow(d)))
  d$Assigned <- !(d$Rater == "R2" & d$Criterion == "C2" & d$Person <= "P0020")
  truth <- d$Score
  r1 <- tapply(d$Score[d$Rater == "R1"], d$Person[d$Rater == "R1"], mean)
  eligible <- which(d$Assigned & d$Rater == "R3")
  logit <- -.5 + .8 * (1 - r1[d$Person[eligible]])
  if (mask == "MNAR") logit <- logit + 1.5 * (1 - d$Score[eligible])
  set.seed(if (preflight) 92392001L else 92392000L + id)
  missing <- eligible[runif(length(eligible)) < plogis(logit)]
  d$Score[!d$Assigned | seq_len(nrow(d)) %in% missing] <- NA_integer_
  observed <- which(d$Assigned & !is.na(d$Score))
  ids <- lapply(d[c("Person", "Rater", "Criterion")], function(z) sort(unique(z)))
  ix <- lapply(names(ids), function(n) match(d[[n]], ids[[n]])); names(ix) <- names(ids)
  q <- function(n) { a <- contr.helmert(n); sweep(a, 2, sqrt(colSums(a^2)), "/") }
  stan_data <- list(P = 80L, R = 3L, C = 2L, K = 3L,
    N_obs = length(observed), N_mis = length(missing),
    person_obs = ix$Person[observed], rater_obs = ix$Rater[observed],
    criterion_obs = ix$Criterion[observed], y_obs = d$Score[observed] + 1L,
    person_mis = ix$Person[missing], rater_mis = ix$Rater[missing],
    criterion_mis = ix$Criterion[missing], Q_rater = q(3), Q_criterion = q(2),
    Q_step = q(2), prior_sd = 2.5)
  contrast <- matrix(c(1, 0, -1), 1, dimnames = list("R1 minus R3", ids$Rater))
  result <- list(id = id, mask = mask, preflight = preflight, seed = seed,
    data = d, generating_scores = truth, missing = missing, stan_data = stan_data,
    errors = list(), warnings = list(), methods = list(), timing = list())
  attempt <- function(stage, expression) {
    t <- proc.time()[["elapsed"]]
    out <- tryCatch(withCallingHandlers(force(expression), warning = function(w) {
      result$warnings[[stage]] <<- c(result$warnings[[stage]], conditionMessage(w))
      invokeRestart("muffleWarning")
    }), error = function(e) { result$errors[[stage]] <<- conditionMessage(e); NULL })
    result$timing[[stage]] <<- proc.time()[["elapsed"]] - t
    out
  }
  fit <- function(data, order) fit_mfrm(data, "Person", c("Rater", "Criterion"), "Score",
    model = "RSM", method = "MML", rating_min = 0, rating_max = 2,
    keep_original = TRUE, quad_points = order, maxit = 400, reltol = 1e-10,
    attach_diagnostics = FALSE)
  for (order in c(61L, 121L)) {
    key <- paste0("observed", order)
    result[[key]] <- attempt(key, fit(d[observed, ], order))
    if (!is.null(result[[key]])) result[[paste0(key, "_interval")]] <- attempt(paste0(key, "_interval"),
      mfrm_facet_intervals(result[[key]], "Rater", contrasts = contrast))
  }
  if (!is.null(result$observed61_interval) && !is.null(result$observed121_interval)) {
    a <- summary(result$observed61_interval); b <- summary(result$observed121_interval)
    result$grid <- abs(unlist(a[c("Estimate", "SE")]) - unlist(b[c("Estimate", "SE")]))
    if (all(result$grid <= 1e-4)) result$methods$MML <- a
    else result$errors$grid <- "Observed contrast/SE Q61-Q121 difference exceeds 1e-4"
  }
  scratch <- tempfile(sprintf("mi-%04d-%s-", id, mask)); dir.create(scratch)
  settings <- list(chains = 4L, parallel_chains = 1L, iter_warmup = 1000L,
    iter_sampling = 1000L, seed = 92400000L + id * 2L + (mask == "MNAR") + if (preflight) 10000L else 0L,
    adapt_delta = .9, max_treedepth = 10L, refresh = 0L, sig_figs = 18L,
    output_dir = scratch)
  sampled <- attempt("sampling", do.call(model$sample, c(list(data = stan_data), settings)))
  result$settings <- settings[setdiff(names(settings), "output_dir")]
  if (!is.null(sampled)) {
    latent <- c("theta", "rater_free", "criterion_free", "step_free", "severity", "difficulty", "step")
    result$draws <- sampled$draws(c(latent, "y_mis", "log_likelihood"))
    result$sampler_draws <- sampled$sampler_diagnostics()
    result$return_codes <- sampled$return_codes()
    result$diagnostics <- sampled$summary(latent)
    result$sampler <- sampled$diagnostic_summary()
    draws <- as.array(result$draws)
    difference <- draws[, , "severity[1]"] - draws[, , "severity[3]"]
    result$contrast_diagnostics <- c(Rhat = posterior::rhat(difference),
      BulkESS = posterior::ess_bulk(difference), TailESS = posterior::ess_tail(difference))
    dg <- result$diagnostics; sampler <- result$sampler; cd <- result$contrast_diagnostics
    ready <- all(result$return_codes == 0) && all(is.finite(dg$rhat) & dg$rhat < 1.01) &&
      all(dg$ess_bulk >= 400 & dg$ess_tail >= 400) &&
      all(sampler$num_divergent == 0 & sampler$num_max_treedepth == 0 & sampler$ebfmi >= .3) &&
      is.finite(cd[1]) && cd[1] < 1.01 && all(cd[2:3] >= 400)
    result$sampling_ready <- isTRUE(ready)
    if (isTRUE(ready)) {
      result$methods$Bayes <- data.frame(Estimate = mean(difference), SE = sd(as.vector(difference)),
        Lower = unname(quantile(difference, .025)), Upper = unname(quantile(difference, .975)))
      selected_seed <- 92500000L + id * 2L + (mask == "MNAR") + if (preflight) 10000L else 0L
      set.seed(selected_seed)
      all_draws <- posterior::as_draws_df(result$draws)
      selected <- sample.int(nrow(all_draws), 40L)
      scores <- t(as.matrix(as.data.frame(all_draws)[selected, paste0("y_mis[", seq_along(missing), "]")])) - 1L
      storage.mode(scores) <- "integer"
      completions <- lapply(seq_len(40L), function(i) { a <- d; a$Score[missing] <- scores[, i]; a })
      specification <- list(method = "Joint RSM posterior predictive completion", data = stan_data,
        settings = result$settings, completion_seed = selected_seed,
        draw_ids = as.data.frame(all_draws)[selected, c(".chain", ".iteration", ".draw")],
        diagnostics = result$diagnostics, contrast_diagnostics = cd, sampler = sampler)
      review <- attempt("import", mfrm_response_imputations(d, completions, "Person", c("Rater", "Criterion"),
        "Score", "Event", d$Event[missing], 0:2, assigned = "Assigned", imputation_model = specification))
      if (!is.null(review)) result$analyses <- attempt("analyses", fit_mfrm_imputed(review, model = "RSM",
        quad_points = 61L, maxit = 400, reltol = 1e-10))
      if (!is.null(result$analyses)) result$pooled <- attempt("pool", pool_mfrm_imputed(result$analyses,
        "Rater", contrasts = contrast))
      if (!is.null(result$pooled)) result$methods$MI <- summary(result$pooled)
      if (preflight && !is.null(result$pooled)) {
        result$completion121 <- attempt("completion121", fit(completions[[1]][d$Assigned, ], 121L))
        ci121 <- attempt("completion121_interval", mfrm_facet_intervals(result$completion121, "Rater", contrasts = contrast))
        ci61 <- attempt("completion61_interval", mfrm_facet_intervals(result$analyses$fits[[1]], "Rater", contrasts = contrast))
        if (!is.null(ci121) && !is.null(ci61)) result$completion_grid <- abs(
          unlist(summary(ci121)[c("Estimate", "SE")]) - unlist(summary(ci61)[c("Estimate", "SE")]))
      }
    } else result$errors$sampler_diagnostics <- "Prespecified MCMC diagnostics not satisfied"
  }
  result$seconds <- proc.time()[["elapsed"]] - started
  saveRDS(result, path)
  restored <- readRDS(path)
  stopifnot(identical(restored, result))
  if (!is.null(result$draws)) unlink(scratch, recursive = TRUE)
  else cat("Unarchived sampler files retained:", scratch, "\n")
  cat(basename(path), "seconds", round(result$seconds, 2), "available",
    paste(names(result$methods), collapse = ","), "errors", length(result$errors), "\n")
  invisible(result)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(TRUE); action <- args[1]; directory <- args[2]
  dir.create(directory, recursive = TRUE, showWarnings = FALSE)
  model_path <- file.path(directory, "response-imputation.stan")
  if (!file.exists(model_path)) file.copy("inst/examples/response-imputation.stan", model_path)
  stopifnot(identical(readLines(model_path), readLines("inst/examples/response-imputation.stan")))
  model <- cmdstanr::cmdstan_model(model_path, cpp_options = list(PRECOMPILED_HEADERS = "false"))
  if (action == "preflight") {
    for (mask in c("MAR", "MNAR")) mi_trial(1L, mask, directory, model, TRUE)
  } else if (action == "run") {
    plan <- readRDS(file.path(directory, "plan.rds"))
    stopifnot(identical(plan$hashes, tools::md5sum(names(plan$hashes))))
    worker <- as.integer(args[3]); workers <- as.integer(args[4])
    ids <- seq_len(plan$replications)
    for (id in ids[(ids - 1L) %% workers == worker - 1L]) for (mask in c("MAR", "MNAR")) {
      path <- file.path(directory, sprintf("trial-%04d-%s.rds", id, mask))
      if (file.exists(path)) next
      marker <- paste0(path, ".started")
      if (file.exists(marker)) stop("Inspect interrupted trial before resuming: ", marker)
      saveRDS(list(time = Sys.time(), hashes = plan$hashes), marker)
      mi_trial(id, mask, directory, model)
    }
  } else stop("Unknown action")
}
