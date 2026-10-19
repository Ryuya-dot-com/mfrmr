# Saved-only external-template regression. Run from the development root.
# Needs CmdStanR/posterior, but never a compiler, sampler or new responses.
root <- normalizePath(".")
directory <- file.path(root, "validation-results/stan-reporting-20261013")
dir.create(directory, recursive = TRUE, showWarnings = FALSE)
source <- file.path(root, "inst/model-export/run-stan.R")
env <- new.env(parent = globalenv())
sys.source(source, envir = env)
blocked <- function(...) stop("Reporting regression cannot compile, fit or generate.")
assignInNamespace("cmdstan_model", blocked, "cmdstanr")
for (name in c("rnorm", "runif", "rbinom", "optim", "nlminb", "integrate"))
  assignInNamespace(name, blocked, "stats")
check_hash <- function(x) stopifnot(identical(x, tools::md5sum(names(x))))
old_dir <- "validation-results/gmfrm-posterior-feasibility-20261012"
old <- readRDS(file.path(old_dir, "summary.rds"))
check_hash(old$manifest); check_hash(old$draws)
targets <- old$targets
targets$fraction <- pmax(targets$mcse_lower, targets$mcse_upper) /
  (targets$upper - targets$lower)
rows <- aggregate(fraction ~ Case + Prior, targets,
  function(x) c(misses = sum(x > .025), maximum = max(x), count = length(x)))
print(rows, row.names = FALSE)
write.csv(rows, file.path(directory, "retained-target-precision.csv"), row.names = FALSE)

run_case <- function(fit, name) {
  path <- file.path(directory, name)
  dir.create(path, showWarnings = FALSE)
  old_wd <- setwd(path); on.exit(setwd(old_wd))
  fit$save_object("fit.rds")
  hashes <- tools::md5sum("fit.rds")
  invisible(capture.output(answer <- env$run_mfrm_stan("--summarize"),
    file = "summary.log"))
  stopifnot(identical(hashes, tools::md5sum("fit.rds")),
    identical(answer, readRDS("posterior-summary.rds")), answer$level == .95,
    nrow(answer$sampler) == length(fit$metadata()$id),
    identical(answer$sampler$chain, fit$metadata()$id),
    any(answer$parameters$role == "free_coordinate"))
  draws <- fit$draws(answer$parameters$variable, format = "draws_array")
  # Pooling retained draws independently checks quantile probabilities and scale.
  bounds <- vapply(seq_len(dim(draws)[3]), function(j)
    quantile(as.numeric(draws[, , j]), c(.025, .975)), numeric(2))
  stopifnot(isTRUE(all.equal(unname(bounds[1, ]), answer$parameters$lower)),
    isTRUE(all.equal(unname(bounds[2, ]), answer$parameters$upper)),
    all(answer$parameters$interval_computed),
    !any(grepl("^(eta|y_rep|log_lik|effective_slopes)", answer$parameters$variable)))
  csv <- read.csv("parameter-summary.csv")
  stopifnot(identical(csv$variable, answer$parameters$variable),
    isTRUE(all.equal(csv$lower, answer$parameters$lower)),
    isTRUE(all.equal(csv$upper, answer$parameters$upper)))
  invisible(answer)
}

for (name in c("N20-observed-main", "N240-observed-half", "N20-b19-double")) {
  x <- readRDS(file.path(old_dir, name, "draws.rds")); check_hash(x$csv)
  fit <- cmdstanr::as_cmdstan_fit(normalizePath(names(x$csv)))
  answer <- run_case(fit, name)
  native <- old$targets[old$targets$Case == x$job$Case &
    old$targets$Prior == x$job$Prior, ]
  m <- readRDS(file.path(old_dir, "manifest.rds"))
  variables <- m$cases[[x$job$Case]]$native_variables
  z <- answer$parameters[match(variables, answer$parameters$variable), ]
  reference <- native[match(colnames(m$contrasts), native$Target), ]
  stopifnot(!anyNA(z$variable), !anyNA(reference$Target),
    isTRUE(all.equal(z$lower, reference$lower, tolerance = 1e-12)),
    isTRUE(all.equal(z$upper, reference$upper, tolerance = 1e-12)),
    isTRUE(all.equal(z$mcse_lower, reference$mcse_lower, tolerance = 1e-12)),
    isTRUE(all.equal(z$mcse_upper, reference$mcse_upper, tolerance = 1e-12)),
    isTRUE(all.equal(answer$sampler[names(x$diagnostics)],
      as.data.frame(x$diagnostics), tolerance = 1e-12)))
  cat(name, ": retained native bounds/MCSE and chain diagnostics agree.\n")
}

# The shared template must also handle an ordinary PCM export without slopes.
fit <- readRDS("validation-results/mfrm-model-export-20261010/stan/test-fit.rds")
ordinary <- run_case(fit, "ordinary")
stopifnot(!any(grepl("slope", ordinary$parameters$variable)))

# A binary/singleton component is fixed, not an estimable zero-width interval.
# Keep diagnostic NA rather than manufacturing perfect ESS or zero MCSE.
draws <- fit$draws("theta[1]", format = "draws_array")
constant <- draws
constant[] <- 0
dimnames(constant)[[3]] <- "steps[1,1]"
both <- posterior::bind_draws(draws, constant, along = "variable")
stub <- list(metadata = function() list(variables = posterior::variables(both), id = c(1L, 2L)),
  draws = function(variables, format) posterior::subset_draws(both, variable = variables),
  diagnostic_summary = function() fit$diagnostic_summary())
setwd(directory)
invisible(capture.output(fixed <- env$summarize_mfrm_stan(stub), file = "constant.log"))
z <- fixed$parameters[fixed$parameters$variable == "steps[1,1]", ]
stopifnot(z$lower == 0, z$upper == 0, z$interval_computed,
  is.na(z$rhat), is.na(z$mcse_lower), is.na(z$endpoint_mcse_fraction))
setwd(root)
check_hash(old$manifest); check_hash(old$draws)
cat("Ordinary export and fixed-component reporting pass; no compilation or fitting.\n")
