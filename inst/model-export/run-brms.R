# Run Rscript run.R from this directory after reviewing README.txt and priors.
if (!requireNamespace("cmdstanr", quietly = TRUE)) stop("Install CmdStanR and CmdStan first.")
source("model.R")
fit <- brms::brm(formula, data = model_data, family = family, prior = prior,
                 stanvars = stanvars, backend = "cmdstanr", seed = 20261010,
                 chains = 4, cores = 4, iter = 2000, warmup = 1000,
                 control = list(adapt_delta = 0.95))
print(summary(fit))
sampler <- brms::nuts_params(fit)
print(stats::aggregate(Value ~ Chain,
  data = sampler[sampler$Parameter == "divergent__", ], FUN = sum))
saveRDS(fit, "fit.rds")
saveRDS(extract_mfrm_parameters(fit), "parameters.rds")
saveRDS(list(y_rep = brms::posterior_predict(fit), log_lik = brms::log_lik(fit)),
        "predictive-draws.rds")
# Map y_rep categories back to scores with bundle$categories.
