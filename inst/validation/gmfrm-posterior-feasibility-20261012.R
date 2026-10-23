# Fifteen prespecified posterior arms on five retained datasets; no coverage claim.
args <- commandArgs(TRUE)
stopifnot(length(args) == 1L, args %in% c("prepare", "run", "summarize", "replay"))
action <- args[[1L]]
directory <- "validation-results/gmfrm-posterior-feasibility-20261012"
script <- "inst/validation/gmfrm-posterior-feasibility-20261012.R"
manifest <- file.path(directory, "manifest.rds")
check <- function(x) stopifnot(length(x) > 0L, !anyNA(x), identical(x, tools::md5sum(names(x))))
blocked <- function(...) stop("Posterior replay cannot fit, integrate or generate.")
read_fit <- function(path) {
  x <- readRDS(path)
  if (inherits(x, "mfrm_fit")) x else x$payload$value
}
if (action == "prepare") {
  stopifnot(!file.exists(manifest))
  dir.create(directory, recursive = TRUE, showWarnings = FALSE)
  pkgload::load_all(quiet = TRUE, compile = FALSE)
  for (n in c("fit_mfrm", "mfrm_gmfrm_em", "mfrm_gpcm_product_inference"))
    assignInNamespace(n, blocked, "mfrmr")
  old_path <- "validation-results/gmfrm-complete-procedure-20261011/manifest.rds"
  old <- readRDS(old_path); check(old$inputs)
  wpath <- "validation-results/gmfrm-complete-procedure-20261011/N20-observed-answer.rds"
  w <- readRDS(wpath)$value$wald$value
  C <- w$contrasts
  stopifnot(nrow(C) == 56L, ncol(C) == 22L)
  cases <- lapply(old$cases, function(case) {
    f <- read_fit(case$parent_path)
    b <- mfrmr:::mfrm_model_export_data(f, 1, 1, .7)
    s <- case$specification
    stopifnot(all(vapply(c("Person", "Task", "Rater"), function(k)
      identical(as.character(f$prep$data[[k]]), as.character(s$data[[k]])), TRUE)))
    y <- match(s$data[[s$score]], b$categories$Score)
    stopifnot(!anyNA(y), length(y) == b$stan_data$N)
    b$stan_data$y <- as.array(y)
    # Exported design only: the parent MML estimates never initialize NUTS.
    native <- vapply(strsplit(colnames(C), ":", fixed = TRUE), function(k) {
      if (k[1L] == "location") {
        rows <- b$levels$Facet == k[2L] & b$levels$Level == k[3L]
        return(b$levels$Parameter[rows])
      }
      if (k[1L] == "log_slope") {
        rows <- b$slope_levels$Owner == k[2L] & b$slope_levels$Level == k[3L]
        return(b$slope_levels$LogParameter[rows])
      }
      stopifnot(k[1L] == "step", k[2L] == "Rater")
      paste0("steps[", match(k[3L], b$step_owners), ",", as.integer(k[4L]), "]")
    }, "")
    stopifnot(length(native) == 22L, !anyNA(native), !anyDuplicated(native))
    list(bundle = b, native_variables = native)
  })
  stan <- "validation-results/gmfrm-model-export-20261010/small/model.stan"
  exe <- "validation-results/gmfrm-model-export-20261010/small/model"
  stopifnot(file.exists(exe), identical(unname(tools::md5sum(stan)),
    unname(tools::md5sum("inst/model-export/model-gmfrm.stan"))))
  plan <- expand.grid(Prior = c("main", "half", "double"), Case = names(cases),
    stringsAsFactors = FALSE)
  plan$Multiplier <- c(main = 1, half = .5, double = 2)[plan$Prior]
  plan$Seed <- 2026101200L + seq_len(nrow(plan))
  inputs <- unique(c(old_path, wpath, vapply(old$cases, `[[`, "", "parent_path"),
    names(old$inputs)[grepl("b(09|19)-generation[.]rds$", names(old$inputs))],
    "validation-results/gmfrm-model-export-20261010/exact.csv"))
  m <- list(cases = cases, plan = plan, contrasts = C,
    exponentiate = w$intervals$Scale == "exp_native", inputs = tools::md5sum(inputs),
    source = tools::md5sum(c(script, "R/api-model-export.R", "inst/model-export/model-gmfrm.stan", stan, exe)),
    stan = normalizePath(stan), exe = normalizePath(exe),
    controls = list(chains = 4L, parallel_chains = 1L, iter_warmup = 1000L,
      iter_sampling = 1000L, adapt_delta = .95, max_treedepth = 12L, init = .5),
    R = R.version, cmdstan = as.character(cmdstanr::cmdstan_version()),
    packages = vapply(c("cmdstanr", "posterior"), function(p) as.character(packageVersion(p)), ""),
    threads = Sys.getenv(c("OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS", "VECLIB_MAXIMUM_THREADS")))
  saveRDS(m, manifest)
  cat("Prepared 15 arms, five unchanged rating datasets and 56 common targets.\n")
  quit(save = "no")
}
m <- readRDS(manifest); check(m$inputs); check(m$source)
seal <- tools::md5sum(manifest)
stopifnot(identical(m$R, R.version), identical(m$packages,
  vapply(names(m$packages), function(p) as.character(packageVersion(p)), "")))
path <- function(job) file.path(directory, paste0(job$Case, "-", job$Prior))
if (action == "run") {
  stopifnot(identical(m$threads, Sys.getenv(names(m$threads))),
    identical(m$cmdstan, as.character(cmdstanr::cmdstan_version())))
  model <- cmdstanr::cmdstan_model(stan_file = m$stan, exe_file = m$exe, compile = FALSE)
  for (i in seq_len(nrow(m$plan))) {
    job <- m$plan[i, ]; dest <- path(job); out <- file.path(dest, "draws.rds")
    if (file.exists(out)) {
      x <- readRDS(out); stopifnot(identical(x$manifest, seal))
      if (length(x$csv)) check(x$csv)
      next
    }
    dir.create(dest, showWarnings = FALSE)
    s <- m$cases[[job$Case]]$bundle$stan_data
    for (k in c("location_sd", "step_sd", "log_slope_sd")) s[[k]] <- s[[k]] * job$Multiplier
    saveRDS(s, file.path(dest, "data.rds"))
    cat("Starting", job$Case, job$Prior, "\n"); flush.console()
    value <- NULL; error <- NULL; warnings <- character()
    elapsed <- system.time(withCallingHandlers(tryCatch({
      fit <- do.call(model$sample, c(list(data = s, seed = job$Seed, refresh = 0,
        output_dir = normalizePath(dest), sig_figs = 18), m$controls))
      variables <- unique(c("theta", "location_free", "step_free", "log_slope_free",
        m$cases[[job$Case]]$native_variables))
      value <- list(draws = fit$draws(variables, format = "draws_array"),
        diagnostics = fit$diagnostic_summary(), output = fit$output(),
        csv = tools::md5sum(fit$output_files()), data = tools::md5sum(file.path(dest, "data.rds")))
      stopifnot(identical(as.integer(dim(value$draws)[1:2]), c(1000L, 4L)))
    }, error = function(e) error <<- conditionMessage(e)), warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w)); invokeRestart("muffleWarning")
    }))[["elapsed"]]
    if (!is.null(error)) value <- list(csv = tools::md5sum(list.files(dest,
      pattern = "[.]csv$", full.names = TRUE)), data = tools::md5sum(file.path(dest, "data.rds")))
    x <- c(list(manifest = seal, job = job, error = error, warnings = warnings, seconds = elapsed), value)
    saveRDS(x, paste0(out, ".tmp")); stopifnot(file.rename(paste0(out, ".tmp"), out))
    cat("Completed", job$Case, job$Prior, elapsed, "seconds; error:", error, "\n"); flush.console()
  }
  quit(save = "no")
}
for (n in c("rnorm", "runif", "rbinom", "optim", "optimHess", "nlminb", "integrate"))
  assignInNamespace(n, blocked, "stats")
monitor <- function(x) c(mean = mean(x), sd = sd(as.vector(x)),
  median = median(x), lower = unname(quantile(x, .025)), upper = unname(quantile(x, .975)),
  rhat = posterior::rhat(x), bulk = posterior::ess_bulk(x), tail = posterior::ess_tail(x),
  mcse_lower = unname(posterior::mcse_quantile(x, .025)),
  mcse_upper = unname(posterior::mcse_quantile(x, .975)))
summarize_array <- function(a) do.call(rbind, lapply(seq_len(dim(a)[3L]), function(j) monitor(a[, , j])))
rows <- list(); arms <- list(); draw_paths <- character()
for (i in seq_len(nrow(m$plan))) {
  job <- m$plan[i, ]; file <- file.path(path(job), "draws.rds")
  stopifnot(file.exists(file)); draw_paths <- c(draw_paths, file)
  x <- readRDS(file); stopifnot(identical(x$manifest, seal), identical(x$job, job))
  if (length(x$csv)) check(x$csv)
  check(x$data)
  if (!is.null(x$error)) {
    arms[[i]] <- data.frame(Case = job$Case, Prior = job$Prior, Available = FALSE,
      Rhat = NA_real_, BulkESS = NA_real_, TailESS = NA_real_, EndpointMCSEFraction = NA_real_,
      Divergences = NA_real_, DepthHits = NA_real_, MinBFMI = NA_real_, Seconds = x$seconds, Error = x$error)
    next
  }
  native <- as.array(x$draws[, , m$cases[[job$Case]]$native_variables, drop = FALSE])
  d <- dim(native)
  target <- array(matrix(native, nrow = d[1L] * d[2L]) %*% t(m$contrasts),
    dim = c(d[1:2], nrow(m$contrasts)))
  target[, , m$exponentiate] <- exp(target[, , m$exponentiate])
  z <- summarize_array(target)
  free <- grep("^(theta|location_free|step_free|log_slope_free)\\[", dimnames(x$draws)[[3L]])
  f <- summarize_array(as.array(x$draws[, , free, drop = FALSE]))
  all <- rbind(z, f)
  diagnostic <- x$diagnostics
  a <- data.frame(Case = job$Case, Prior = job$Prior, Available = FALSE,
    Rhat = max(all[, "rhat"]), BulkESS = min(all[, "bulk"]), TailESS = min(all[, "tail"]),
    EndpointMCSEFraction = max(all[, c("mcse_lower", "mcse_upper")] / (all[, "upper"] - all[, "lower"])),
    Divergences = sum(diagnostic$num_divergent), DepthHits = sum(diagnostic$num_max_treedepth),
    MinBFMI = min(diagnostic$ebfmi), Seconds = x$seconds, Error = "")
  a$Available <- all(is.finite(all)) && all(is.finite(unlist(a[4:10]))) &&
    a$Rhat < 1.01 && a$BulkESS >= 400 && a$TailESS >= 400 &&
    a$EndpointMCSEFraction <= .025 && a$Divergences == 0 && a$DepthHits == 0 && a$MinBFMI >= .3
  arms[[i]] <- a
  rows[[i]] <- cbind(data.frame(Case = job$Case, Prior = job$Prior,
    Target = rownames(m$contrasts), Scale = ifelse(m$exponentiate, "positive", "native"),
    NumericallyQualified = a$Available, CoverageQualified = FALSE), as.data.frame(z))
}
targets <- do.call(rbind, rows); delivery <- do.call(rbind, arms)
main <- targets[targets$Prior == "main", ]
at <- match(paste(targets$Case, targets$Target), paste(main$Case, main$Target))
targets$MedianShiftOverMainWidth <- (targets$median - main$median[at]) / (main$upper[at] - main$lower[at])
targets$WidthOverMainWidth <- (targets$upper - targets$lower) / (main$upper[at] - main$lower[at])
answer <- list(delivery = delivery, targets = targets, manifest = seal, draws = tools::md5sum(draw_paths))
result <- file.path(directory, "summary.rds")
if (action == "replay") {
  stopifnot(identical(readRDS(result), answer))
  cat("Fresh saved-draw replay reproduces every arm and target without sampling.\n")
} else {
  saveRDS(answer, result)
  write.csv(delivery, file.path(directory, "delivery.csv"), row.names = FALSE)
  write.csv(targets, file.path(directory, "targets.csv"), row.names = FALSE)
  print(delivery)
}
