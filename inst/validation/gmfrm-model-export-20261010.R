# Exact likelihood/gradient and short execution checks; no coverage allocation.
root <- normalizePath("validation-results/gmfrm-model-export-20261010")
pkgload::load_all(quiet = TRUE, compile = FALSE)
inputs <- c(small = "validation-results/gmfrm-adaptive-profile-20261010/small-fit.rds",
  large = "validation-results/gmfrm-adaptive-profile-20261010/large-fit.rds")
files <- c("R/api-model-export.R", list.files("inst/model-export", full.names = TRUE), inputs)
write.csv(data.frame(Path = files, MD5 = unname(tools::md5sum(files))),
  file.path(root, "inputs-source.csv"), row.names = FALSE)
for (name in c("fit_mfrm", "mfrm_gpcm_product_inference", "mfrm_gpcm_profile_search"))
  assignInNamespace(name, function(...) stop("Unexpected MML computation"), ns = "mfrmr")

# Literal cumulative-category probabilities and analytic complete-data scores.
reference <- function(s, p) {
  theta <- p$theta; b <- p$location_free; t <- p$step_free; g <- p$log_slope_free
  h <- rbind(0, apply(s$step_basis, 2L, cumsum))
  if (!s$Q) h <- matrix(numeric(), s$C, 0L)
  eta <- theta[s$person] + drop(s$X %*% b)
  a <- exp(drop(s$slope_X %*% g))
  cumulative <- (t %*% t(h))[s$owner, , drop = FALSE]
  logits <- (outer(eta, 0:(s$C - 1L)) - cumulative) * a
  centered <- logits - apply(logits, 1L, max)
  logp <- centered - log(rowSums(exp(centered)))
  probs <- exp(logp)
  at <- cbind(seq_len(s$N), s$y)
  r <- s$y - 1L - drop(probs %*% (0:(s$C - 1L)))
  score_theta <- vapply(seq_len(s$J), function(j) sum((a * r)[s$person == j]), 0) - theta
  score_b <- drop(crossprod(s$X, a * r)) - b / s$location_sd^2
  score_t <- matrix(0, s$G, s$Q)
  if (s$Q) {
    residual <- (h[s$y, , drop = FALSE] - probs %*% h) * a
    for (owner in seq_len(s$G)) score_t[owner, ] <- -colSums(residual[s$owner == owner, , drop = FALSE])
  }
  score_t <- score_t - t / s$step_sd^2
  score_g <- drop(crossprod(s$slope_X, logits[at] - rowSums(probs * logits))) - g / s$log_slope_sd^2
  list(value = sum(logp[at]) + sum(dnorm(theta, log = TRUE)) +
      sum(dnorm(b, sd = s$location_sd, log = TRUE)) + sum(dnorm(t, sd = s$step_sd, log = TRUE)) +
      sum(dnorm(g, sd = s$log_slope_sd, log = TRUE)),
    gradient = c(score_theta, score_b, as.vector(score_t), score_g), probabilities = probs)
}

log_density <- function(model, s, p, prefix) {
  data_file <- paste0(prefix, "-data.json"); pars_file <- paste0(prefix, "-pars.json")
  output_file <- paste0(prefix, "-density.csv")
  cmdstanr::write_stan_json(s, data_file); cmdstanr::write_stan_json(p, pars_file)
  status <- system2(model$exe_file(), shQuote(c("log_prob", paste0("constrained_params=", pars_file),
    "data", paste0("file=", data_file), "output", paste0("file=", output_file), "sig_figs=18")),
    stdout = paste0(prefix, ".log"), stderr = paste0(prefix, ".log"))
  stopifnot(status == 0L)
  read.csv(output_file, comment.char = "#", check.names = FALSE)
}

records <- list(); model <- NULL
for (case in c("small", "binary", "large")) {
  f <- readRDS(inputs[if (case == "binary") "small" else case])
  if (case == "binary") {
    f$config$n_cat <- 2L; f$config$rating_max <- f$config$rating_min + 1L
    f$config$score_map <- f$config$score_map[1:2, ]
    f$config$step_specs <- mfrmr:::mfrmr_default_step_specs(f$config)
    f$prep$data$score_k <- f$prep$data$score_k %% 2L
    f$config$facet_signs[1] <- 1
  }
  destination <- file.path(root, case)
  exported <- export_mfrm_model(f, destination, log_slope_prior_sd = .7,
    acknowledge_sensitive = TRUE)
  s <- readRDS(exported$files[["model-data.rds"]])$stan_data
  if (is.null(model)) model <- cmdstanr::cmdstan_model(exported$files[["model.stan"]],
    cpp_options = list(PRECOMPILED_HEADERS = FALSE))
  for (point in 0:3) {
    p <- list(theta = as.array(sin(seq_len(s$J) + point) * if (point == 3) 40 else 1.2),
      location_free = as.array(cos(seq_len(s$P) + point) * .7),
      step_free = matrix(sin(seq_len(s$G * s$Q) + point), s$G, s$Q),
      log_slope_free = as.array(if (point == 0) rep(0, s$S) else sin(seq_len(s$S) + point) * .6))
    ref <- reference(s, p)
    stan <- log_density(model, s, p, file.path(destination, paste0("point-", point)))
    if (point == 0) baseline <- c(stan[1, 1], ref$value)
    gradient_error <- max(abs(as.numeric(stan[1, -1]) - ref$gradient))
    delta_error <- abs(diff(c(stan[1, 1], ref$value) - baseline))
    records[[length(records) + 1L]] <- data.frame(Case = case, Point = point, Persons = s$J,
      GradientError = gradient_error, DensityDeltaError = delta_error)
    write.csv(do.call(rbind, records), file.path(root, "exact.csv"), row.names = FALSE)
    stopifnot(gradient_error < 1e-7, delta_error < 1e-7)
  }
  if (case != "binary") {
    start <- proc.time()["elapsed"]
    sampled <- model$sample(data = s, seed = if (case == "small") 20261011 else 20261012,
      chains = 2, parallel_chains = 2, iter_warmup = 300, iter_sampling = 300,
      adapt_delta = .95, refresh = 0, output_dir = destination, sig_figs = 18)
    sampled$save_object(file.path(destination, "fit.rds"))
    saveRDS(list(seconds = unname(proc.time()["elapsed"] - start),
      diagnostic = sampled$diagnostic_summary(),
      summary = sampled$summary(c("component_slopes", "locations", "steps"))),
      file.path(destination, "sampling-check.rds"))
    stopifnot(all(is.finite(sampled$summary("log_lik")$mean)))
  }
}
writeLines(capture.output(sessionInfo()), file.path(root, "session-info.txt"))
stopifnot(identical(unname(tools::md5sum(files)), read.csv(file.path(root, "inputs-source.csv"))$MD5))
cat("Exact checks and both retained-data sampler execution checks completed.\n")
