# Common-variance-zero nuisance searches, not a fitted LR or coverage study.
# Rscript --vanilla this-file prepare | run | summarize
source("inst/validation/gmfrm-variance-score-20261011.R")
zs_script <- "inst/validation/gmfrm-zero-search-20261011.R"
zs_out <- "validation-results/gmfrm-zero-search-20261011"

# Independent conditional response law; no decoder, likelihood kernel or scores.
zs_literal <- function(z, spec) {
  d <- spec$data; K <- spec$max_score
  ids <- lapply(d[spec$slope_facets], function(x) match(x, sort(unique(x))))
  ni <- max(ids[[1]]); nr <- max(ids[[2]]); nb <- ni - 1L + nr*K
  b <- c(z[seq_len(ni-1L)], -sum(z[seq_len(ni-1L)]))
  a <- exp(c(z[nb + seq_len(ni-1L)], -sum(z[nb + seq_len(ni-1L)])))
  lr <- head(tail(z, nr), -1L); r <- exp(c(lr, -sum(lr)))
  s <- z[ni-1L + seq_len(nr)]
  tau <- matrix(z[ni-1L + nr + seq_len(nr*(K-1L))], nr, K-1L, byrow = TRUE)
  tau <- cbind(tau, -rowSums(tau)); ii <- ids[[1]]; rr <- ids[[2]]
  step <- -a[ii]*r[rr]*(b[ii] + s[rr] + tau[rr, , drop = FALSE])
  logits <- cbind(0, t(apply(step, 1L, cumsum)))
  lp <- logits - apply(logits, 1L, max); lp <- lp - log(rowSums(exp(lp)))
  -sum(lp[cbind(seq_len(nrow(d)), d[[spec$score]] + 1L)])
}

zs_review <- function(fit, ev, spec) {
  z <- fit$selected$parameters; a <- fit$selected$evaluation; free <- fit$free
  reference <- nat_boundary_reference(z, "common_scale", spec, ev$natural)
  derivatives <- lapply(c(1e-4, 5e-5), function(h) vapply(free, function(j) {
    step <- replace(numeric(length(z)), j, h * max(1, abs(z[j])))
    (zs_literal(z + step, spec) - zs_literal(z - step, spec)) / (2*step[j])
  }, 0))
  numerical <- (4*derivatives[[2]] - derivatives[[1]]) / 3
  H <- lapply(c(1e-4, 5e-5), function(h) vapply(free, function(j) {
    step <- replace(numeric(length(z)), j, h * max(1, abs(z[j])))
    (ev$gradient(z + step)[free] - ev$gradient(z - step)[free]) / (2*step[j])
  }, numeric(length(free))))
  symmetric <- lapply(H, function(x) (x + t(x))/2)
  lambda <- eigen(symmetric[[2]], symmetric = TRUE, only.values = TRUE)$values
  spread <- norm(symmetric[[1]] - symmetric[[2]], "2")
  # An empirical resolution diagnostic, not a rigorous error bound on curvature.
  tolerance <- max(1e-7 * max(1, max(abs(lambda))), 10*spread)
  checks <- c(NLL = max(abs(a$value - c(reference[1], zs_literal(z, spec)))),
    Gradient = max(abs(a$gradient[free] - numerical)),
    Outward = abs(a$gradient[ev$natural] - reference[2]))
  list(checks = unname(checks), reference = reference, numerical_gradient = numerical,
    derivative_step_difference = max(abs(derivatives[[1]] - derivatives[[2]])),
    curvature = c(MinEigen = min(lambda), MaxEigen = max(lambda), StepDifference = spread,
      Asymmetry = max(abs(H[[2]] - t(H[[2]]))), NegativeResolution = tolerance),
    negative_curvature = min(lambda) < -tolerance)
}

zs_main <- function(action) {
  stopifnot(action %in% c("prepare", "run", "summarize"))
  path <- file.path(zs_out, "manifest.rds")
  if (action == "prepare") {
    stopifnot(!file.exists(path))
    old <- readRDS(file.path(vs_out, "manifest.rds")); summary <- readRDS(file.path(vs_out, "summary.rds"))
    seg_hash_check(old$inputs); seg_hash_check(summary$results)
    archive <- tools::md5sum(file.path(vs_out, "epoch-source", names(old$sources)))
    names(archive) <- names(old$sources); stopifnot(identical(archive, old$sources))
    seg_hash_check(old$sources[names(old$sources) != "R/core-gmfrm-natural.R"])
    jobs <- old$points; neutral <- subset(jobs, Start == "retained")
    neutral$Start <- "chart_neutral"; neutral$Key <- with(neutral, paste(Case, Kind, Start, sep = "-"))
    jobs <- rbind(jobs, neutral); stopifnot(nrow(jobs) == 30L, !anyDuplicated(jobs$Key))
    pkgload::load_all(quiet = TRUE, compile = FALSE)
    sources <- unique(c(zs_script, names(old$sources), "R/core-gmfrm-natural-search.R", "tests/testthat/test-gmfrm-natural-search.R"))
    m <- list(jobs = jobs, plan = old$plan,
      inputs = tools::md5sum(unique(c(file.path(vs_out, c("manifest.rds", "summary.rds", "verification.rds")),
        names(old$inputs), names(summary$results)))), sources = tools::md5sum(sources),
      session = sessionInfo(), threads = old$threads,
      policy = c("30 common-variance-zero nuisance attempts; five datasets, free/null, two saved projections plus chart-neutral.",
        "L-BFGS-B maxit400 factr1 pgtol1e-8 lmm20 fnscaleN initial parscale max(1,abs(start)); preserve all stops.",
        "Independent NLL<=1e-7, nuisance gradient<=1e-6, outward derivative<=1e-6; target unchanged exactly.",
        "Nuisance score<=1e-4, no resolved negative curvature; outward violation and start agreement remain separate.",
        "Curvature negative-resolution diagnostic max(1e-7*max(1,max(abs(eigen))),10*two-step spectral difference).",
        "No global-optimality, identification, LR or coverage qualification; no new response generation."))
    stopifnot(identical(Sys.getenv(names(m$threads)), m$threads))
    dir.create(zs_out, recursive = TRUE, showWarnings = FALSE); saveRDS(m, path)
    for (s in sources) {
      dest <- file.path(zs_out, "epoch-source", s); dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
      stopifnot(file.copy(s, dest, overwrite = FALSE))
    }
    return(invisible(NULL))
  }
  m <- readRDS(path); seg_hash_check(m$inputs); seal <- tools::md5sum(path)
  files <- file.path(zs_out, paste0("fit-", m$jobs$Key, ".rds"))
  if (action == "summarize") {
    records <- lapply(files, readRDS)
    stopifnot(all(vapply(records, function(r) identical(r$manifest, seal), TRUE)))
    table <- do.call(rbind, lapply(records, function(r) data.frame(Key = r$key, Status = r$status,
      NLL = if (is.null(r$fit)) NA_real_ else r$fit$selected$evaluation$value,
      NuisanceScore = if (is.null(r$fit)) NA_real_ else r$fit$checks[1],
      Outward = if (is.null(r$fit)) NA_real_ else r$fit$boundary_gradient[1],
      Code = if (is.null(r$fit$optimizer)) NA_integer_ else r$fit$optimizer$convergence,
      NLLDifferenceFromInterior = r$interior_difference, Seconds = r$seconds, Error = r$error)))
    rownames(table) <- NULL
    write.csv(table, file.path(zs_out, "attempts.csv"), row.names = FALSE)
    saveRDS(list(manifest = seal, results = tools::md5sum(files), attempts = table), file.path(zs_out, "summary.rds"))
    print(table, row.names = FALSE); return(invisible(NULL))
  }
  seg_hash_check(m$sources); stopifnot(identical(Sys.getenv(names(m$threads)), m$threads))
  pkgload::load_all(quiet = TRUE, compile = FALSE); stopifnot(identical(sessionInfo(), m$session))
  for (j in seq_len(nrow(m$jobs))) {
    if (file.exists(files[j])) { stopifnot(identical(readRDS(files[j])$manifest, seal)); next }
    job <- m$jobs[j, ]; saved <- readRDS(job$Path)$value
    parent <- seg_parent(m$plan$Path[match(job$Parent, m$plan$Case)])
    score <- if (job$Draw != "observed") readRDS(file.path(seg_old, job$Parent,
      paste0(job$Draw, "-generation.rds")))$value$score else NULL
    x <- est_context(parent, score)
    idx <- est_fn("build_indices")(x$fit$prep, x$config$step_facet, x$config$slope_facet,
      x$config$interaction_specs, gpcm_spec = x$config$gpcm_spec)
    ev <- est_fn("mfrm_gmfrm_natural_evaluator")(idx, x$config, x$sizes, "common_scale")
    alpha <- build_param_slices(x$sizes)$log_slopes[1]
    z <- ev$from_native(if (job$Start == "chart_neutral") numeric(length(saved$parameters)) else saved$parameters)
    z[ev$natural] <- 0
    if (job$Kind == "null") z[alpha] <- parent$opt$par[alpha] + .5
    r <- list(manifest = seal, key = job$Key, status = "unresolved", error = "", interior_difference = NA_real_)
    timing <- system.time(tryCatch({
      checkpoint <- paste0(files[j], ".search")
      if (file.exists(checkpoint)) {
        r <- readRDS(checkpoint); stopifnot(identical(r$manifest, seal), identical(r$key, job$Key))
      } else {
        r$fit <- est_fn("mfrm_gmfrm_natural_search")(z, ev,
          fixed = if (job$Kind == "null") alpha else integer(), boundary = ev$natural)
        r$error <- r$fit$error
        # Save the search before independent derivative/curvature checks.
        saveRDS(r, paste0(checkpoint, ".tmp")); stopifnot(file.rename(paste0(checkpoint, ".tmp"), checkpoint))
      }
      r$review <- zs_review(r$fit, ev, x$fit$gmfrm$specification)
      C <- numeric(length(z)); C[alpha] <- 1
      r$target_error <- abs(ev$target(r$fit$selected$parameters, C)$value -
        if (job$Kind == "null") parent$opt$par[alpha] + .5 else r$fit$selected$parameters[alpha])
      prior_key <- if (job$Start == "chart_neutral") sub("chart_neutral$", "retained", job$Key) else job$Key
      previous <- readRDS(file.path(vs_out, paste0("point-", prior_key, ".rds")))
      if (previous$status == "qualified") r$interior_difference <- r$fit$selected$evaluation$value - previous$value$value
      if (!is.null(r$fit$optimizer) && r$fit$optimizer$convergence == 0L && !nzchar(r$error) &&
          r$fit$nuisance_stationary && !r$review$negative_curvature && r$target_error == 0 &&
          all(r$review$checks <= c(1e-7, 1e-6, 1e-6))) r$status <- "stationary_boundary_candidate"
    }, error = function(e) r$error <<- conditionMessage(e)))
    r$seconds <- unname(timing["elapsed"])
    saveRDS(r, paste0(files[j], ".tmp")); stopifnot(file.rename(paste0(files[j], ".tmp"), files[j]))
    cat(job$Key, r$status, r$seconds, r$error, "\n"); flush.console()
  }
}
if (sys.nframe() == 0L) zs_main(commandArgs(trailingOnly = TRUE))
