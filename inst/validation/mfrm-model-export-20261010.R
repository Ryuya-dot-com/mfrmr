# Bounded exporter checks, not a coverage or model-recovery study.
# Run from the package root. Candidate source preserves the active RSM freeze.
root <- normalizePath("validation-results/mfrm-model-export-20261010")
candidate <- file.path(root, "candidate-source")
pkgload::load_all(candidate, quiet = TRUE, compile = FALSE)
source_fit <- readRDS(file.path(root, "source-fit.rds"))
direct <- cmdstanr::cmdstan_model(file.path(root, "stan", "model.stan"),
  exe_file = file.path(root, "stan", "model"), compile = FALSE)

log_density <- function(exe, data, parameters, prefix) {
  data_file <- paste0(prefix, "-data.json")
  param_file <- paste0(prefix, "-parameters.json")
  output_file <- paste0(prefix, "-density.csv")
  cmdstanr::write_stan_json(data, data_file)
  cmdstanr::write_stan_json(parameters, param_file)
  status <- system2(exe, shQuote(c("log_prob", paste0("constrained_params=", param_file),
    "data", paste0("file=", data_file), "output", paste0("file=", output_file), "sig_figs=18")),
    stdout = paste0(prefix, ".log"), stderr = paste0(prefix, ".log"))
  stopifnot(status == 0L)
  read.csv(output_file, comment.char = "#", check.names = FALSE)
}

records <- list()
for (case in c("rsm", "pcm_signed", "binary_singletons", "unused_category")) {
  f <- source_fit
  if (case == "pcm_signed") {
    f$config$model <- "PCM"
    f$config$step_facet <- "Criterion"
    f$config$facet_signs[["Rater"]] <- 1
    f$config$facet_specs$Rater$centered <- FALSE
    f$config$facet_specs$Rater$n_params <- length(f$config$facet_levels$Rater)
  }
  if (case == "binary_singletons") {
    f$config$n_cat <- 2L
    f$config$rating_max <- f$config$rating_min + 1L
    f$config$score_map <- f$config$score_map[1:2, ]
    f$prep$data$score_k <- f$prep$data$score_k %% 2L
    f$config$person_levels <- f$config$person_levels[1]
    f$config$n_person <- 1L
    f$prep$data$Person <- f$config$person_levels
    for (facet in f$config$facet_names) {
      label <- f$config$facet_levels[[facet]][1]
      f$config$facet_levels[[facet]] <- label
      f$config$facet_specs[[facet]] <- mfrmr:::build_facet_constraint(label)
      f$prep$data[[facet]] <- label
    }
  }
  if (case == "unused_category") {
    f$config$n_cat <- 5L
    f$config$rating_max <- f$config$rating_min + 4L
    f$config$score_map <- data.frame(OriginalScore = 1:5, InternalScore = 1:5)
  }
  f$config$step_specs <- mfrmr:::mfrmr_default_step_specs(f$config)
  out <- file.path(root, paste0("exact-", case))
  export_mfrm_model(f, out, "brms", location_prior_sd = 1.3, step_prior_sd = 0.7,
                    overwrite = TRUE, acknowledge_sensitive = TRUE)
  env <- new.env(parent = globalenv())
  old <- setwd(out)
  sys.source("model.R", env)
  setwd(old)
  s <- env$d
  bd <- brms::make_standata(env$formula, data = env$model_data, family = env$family,
                            prior = env$prior, stanvars = env$stanvars)
  code <- brms::make_stancode(env$formula, data = env$model_data, family = env$family,
                              prior = env$prior, stanvars = env$stanvars)
  stanfile <- file.path(out, "generated.stan")
  if (!file.exists(stanfile) || !identical(readLines(stanfile), strsplit(code, "\n")[[1]])) {
    writeLines(code, stanfile)
  }
  bm <- cmdstanr::cmdstan_model(stanfile, cpp_options = list(PRECOMPILED_HEADERS = FALSE))
  # Four deterministic vectors, including unordered steps and extreme abilities.
  deltas <- list()
  for (point in 0:3) {
    theta <- sin(seq_len(s$J) + point) * if (point == 3) 100 else 1.2
    free <- cos(seq_len(s$P) + point) * 0.7
    step <- matrix(sin(seq_len(s$G * s$Q) * 1.3 + point), s$G, s$Q)
    pars <- list(theta = as.array(theta), location_free = as.array(free), step_free = step)
    bpars <- list(b = as.array(c(theta, free)))
    for (q in seq_len(s$Q)) {
      nm <- if (s$G == 1L) paste0("Intercept_", env$step_names[q]) else
        paste0("b_", env$step_names[q])
      bpars[[nm]] <- if (s$G == 1L) step[1, q] else as.array(step[, q])
    }
    # Both parameter orders are theta, locations, then step coordinates by owner.
    a <- log_density(direct$exe_file(), s, pars, file.path(out, paste0(point, "-stan")))
    b <- log_density(bm$exe_file(), bd, bpars, file.path(out, paste0(point, "-brms")))
    gradient_difference <- max(abs(as.numeric(a[1, -1]) - as.numeric(b[1, -1])))
    stopifnot(gradient_difference < 1e-9)
    eta <- theta[s$person] + drop(s$X %*% free)
    steps <- step %*% t(s$step_basis)
    logits <- outer(eta, 0:(s$C - 1)) -
      t(apply(cbind(0, steps[s$owner, , drop = FALSE]), 1, cumsum))
    centered <- logits - apply(logits, 1, max)
    lp <- centered[cbind(seq_len(s$N), s$y)] - log(rowSums(exp(centered)))
    reference <- sum(lp) + sum(dnorm(theta, log = TRUE)) +
      sum(dnorm(free, sd = s$location_sd, log = TRUE)) +
      sum(dnorm(step, sd = s$step_sd, log = TRUE))
    if (point == 0) baseline <- c(a[1, 1], b[1, 1], reference)
    differences <- c(a[1, 1], b[1, 1], reference) - baseline
    stopifnot(max(abs(differences - differences[1])) < 1e-9)
    deltas[[length(deltas) + 1]] <- data.frame(Case = case, Point = point,
      MaxGradientDifference = gradient_difference,
      MaxLogDensityDifference = max(abs(differences - differences[1])))
  }
  records[[case]] <- do.call(rbind, deltas)
}
result <- do.call(rbind, records)
write.csv(result, file.path(root, "exact-equivalence.csv"), row.names = FALSE)
saveRDS(list(results = result, session = sessionInfo(),
             source = tools::md5sum(c(file.path(candidate, "R/api-model-export.R"),
               list.files(file.path(candidate, "inst/model-export"), full.names = TRUE)))),
        file.path(root, "exact-equivalence.rds"))
print(result, row.names = FALSE)
