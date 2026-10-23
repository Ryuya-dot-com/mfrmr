# Run Rscript run.R after reviewing README.txt and priors.
# Run Rscript run.R --summarize to review fit.rds without compiling or sampling.
summarize_mfrm_stan <- function(fit) {
  variables <- grep(paste0("^(theta|locations|steps|location_free|step_free|",
    "component_slopes|log_component_slopes|log_slope_free)\\["),
    fit$metadata()$variables, value = TRUE)
  if (!length(variables)) stop("No exported model parameters found in fit.rds.")
  draws <- fit$draws(variables, format = "draws_array")
  parameters <- as.data.frame(posterior::summarise_draws(draws,
    mean = base::mean, median = stats::median, sd = stats::sd,
    lower = function(x) unname(stats::quantile(x, .025)),
    upper = function(x) unname(stats::quantile(x, .975)),
    rhat = posterior::rhat, ess_bulk = posterior::ess_bulk,
    ess_tail = posterior::ess_tail,
    mcse_lower = function(x) unname(posterior::mcse_quantile(x, .025)),
    mcse_upper = function(x) unname(posterior::mcse_quantile(x, .975))))
  parameters$role <- ifelse(grepl("_free\\[", parameters$variable),
    "free_coordinate", "reported_parameter")
  parameters$interval_computed <- is.finite(parameters$lower) & is.finite(parameters$upper)
  width <- parameters$upper - parameters$lower
  parameters$endpoint_mcse_fraction <- ifelse(is.finite(width) & width > 0,
    pmax(parameters$mcse_lower, parameters$mcse_upper) / width, NA_real_)
  sampler <- as.data.frame(fit$diagnostic_summary())
  sampler$chain <- fit$metadata()$id
  result <- list(parameters = parameters, sampler = sampler,
    interval = "equal-tailed posterior credible interval", level = .95,
    notes = c(
      "Computed bounds are retained when diagnostics warn; computation is not qualification.",
      "Endpoint MCSE is simulation error, not posterior uncertainty or a coverage measure.",
      "Review all free coordinates and chain diagnostics as well as the target of interest.",
      "NA diagnostics for constant draws can reflect a fixed constraint or stuck sampling.",
      "Inspect prior sensitivity and model fit; these intervals do not validate MML coverage."))
  utils::write.csv(parameters, "parameter-summary.csv", row.names = FALSE)
  utils::write.csv(sampler, "sampler-diagnostics.csv", row.names = FALSE)
  saveRDS(result, "posterior-summary.rds")
  print(parameters, row.names = FALSE)
  print(sampler, row.names = FALSE)
  cat(paste(result$notes, collapse = "\n"), "\n")
  invisible(result)
}

run_mfrm_stan <- function(args = commandArgs(trailingOnly = TRUE)) {
  if (length(args) && !identical(args, "--summarize")) {
    stop("Usage: Rscript run.R [--summarize]")
  }
  if (!requireNamespace("cmdstanr", quietly = TRUE)) stop("Install CmdStanR first.")
  if (identical(args, "--summarize")) {
    fit <- readRDS("fit.rds")
  } else {
    bundle <- readRDS("model-data.rds")
    model <- cmdstanr::cmdstan_model("model.stan")
    fit <- model$sample(data = bundle$stan_data, seed = 20261010,
      chains = 4, parallel_chains = 4, iter_warmup = 1000, iter_sampling = 1000,
      adapt_delta = 0.95, output_dir = ".")
    # Preserve draws before reporting so a reporting error never requires refitting.
    fit$save_object("fit.rds")
    saveRDS(fit$draws(c("y_rep", "log_lik")), "predictive-draws.rds")
    # Map y_rep categories back to scores with bundle$categories.
  }
  summarize_mfrm_stan(fit)
}

if (sys.nframe() == 0L) run_mfrm_stan()
