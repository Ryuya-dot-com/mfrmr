# Run Rscript run.R after reviewing README.txt and priors.
# Run Rscript run.R --summarize to review fit.rds without compiling or sampling.
summarize_mfrm_stan <- function(fit) {
  source("summarize.R", local = TRUE)
  bundle <- readRDS("model-data.rds")
  variables <- grep(paste0("^(lp__$|population_(?:mean|sd|log_sd)$|(?:theta|theta_raw|locations|steps|location_free|step_free|",
    "component_slopes|log_component_slopes|log_slope_free)\\[)"),
    fit$metadata()$variables, value = TRUE, perl = TRUE)
  if (!length(variables)) stop("No exported model parameters found in fit.rds.")
  sampler <- as.data.frame(fit$diagnostic_summary())
  sampler$chain <- fit$metadata()$id
  summarize_mfrm_draws(fit$draws(variables, format = "draws_array"), bundle, sampler, "Stan")
}

run_mfrm_stan <- function(args = commandArgs(trailingOnly = TRUE), sample_args = list()) {
  if (length(args) && !identical(args, "--summarize")) {
    stop("Usage: Rscript run.R [--summarize]")
  }
  if (!is.list(sample_args) || is.data.frame(sample_args)) {
    stop("`sample_args` must be a named list of CmdStanR `$sample()` arguments.")
  }
  if (length(sample_args)) {
    nm <- names(sample_args)
    if (is.null(nm) || anyNA(nm) || any(!nzchar(nm)) || anyDuplicated(nm)) {
      stop("`sample_args` must have unique non-empty argument names.")
    }
    if (any(c("data", "output_dir") %in% nm)) {
      stop("`sample_args` cannot override `data` or `output_dir`.")
    }
    if (identical(args, "--summarize")) {
      stop("`sample_args` cannot be combined with `--summarize`.")
    }
  }
  if (!requireNamespace("cmdstanr", quietly = TRUE)) stop("Install CmdStanR first.")
  if (identical(args, "--summarize")) {
    fit <- readRDS("fit.rds")
  } else {
    cmdstan_dir <- tryCatch(cmdstanr::cmdstan_path(), error = function(e) NULL)
    if (!is.character(cmdstan_dir) || length(cmdstan_dir) != 1L ||
        is.na(cmdstan_dir) || !nzchar(cmdstan_dir) || !dir.exists(cmdstan_dir)) {
      stop("Configure CmdStan first (cmdstanr::install_cmdstan() or cmdstanr::set_cmdstan_path()).")
    }
    bundle <- readRDS("model-data.rds")
    model <- cmdstanr::cmdstan_model("model.stan")
    defaults <- list(seed = 20261010, chains = 4, parallel_chains = 4,
                     iter_warmup = 1000, iter_sampling = 1000, adapt_delta = 0.95)
    if (length(sample_args)) {
      defaults[names(sample_args)] <- sample_args
    }
    call_args <- c(list(data = bundle$stan_data), defaults, list(output_dir = "."))
    fit <- do.call(model$sample, call_args)
    # Preserve draws before reporting so a reporting error never requires refitting.
    fit$save_object("fit.rds")
    saveRDS(fit$draws(c("y_rep", "log_lik")), "predictive-draws.rds")
    # Map y_rep categories back to scores with bundle$categories.
  }
  summarize_mfrm_stan(fit)
}

if (sys.nframe() == 0L) run_mfrm_stan()
