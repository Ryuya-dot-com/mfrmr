# Bounded numerical feasibility, not coverage or a public bootstrap API.
# Run from package root: Rscript --vanilla this-file
# prepare | run [N20|N60|N240] | summarize
script <- "inst/validation/gmfrm-null-bootstrap-20261010.R"
out <- "validation-results/gmfrm-null-bootstrap-20261010"
check_hash <- function(h) stopifnot(length(h) > 0L, !anyNA(h),
  identical(unname(tools::md5sum(names(h))), unname(h)))
fn <- function(n) get(n, asNamespace("mfrmr"))
read_parent <- function(path) {
  x <- readRDS(path)
  if (inherits(x, "mfrm_fit")) x else x$payload$value
}
indices <- function(fit) with(fit$config, fn("build_indices")(fit$prep,
  step_facet, slope_facet, interaction_specs, gpcm_spec = gpcm_spec))
context <- function(fit, order) {
  cfg <- fit$config; cfg$estimation_control$quad_points <- order
  sizes <- fn("build_param_sizes")(cfg); idx <- indices(fit)
  e <- fn("make_mfrm_direct_evaluator")("MML",
    fn("make_param_cache")(sizes, cfg, idx, is_mml = TRUE), idx, cfg, sizes,
    fn("gauss_hermite_normal")(order))
  e$optimization_scale <- cfg$n_person
  e
}

# Independent literal product-slope law; no native expansion or response code.
literal_probability <- function(fit, par, theta) {
  s <- fit$gmfrm$specification; d <- s$data; owners <- s$slope_facets; K <- s$max_score
  lev <- lapply(d[c(s$person, owners)], function(x) sort(unique(as.character(x))))
  id <- Map(function(x, l) match(as.character(x), l), d[names(lev)], lev)
  ni <- length(lev[[2]]); nr <- length(lev[[3]])
  Z <- cbind(rbind(diag(ni - 1L), rep(-1, ni - 1L))[id[[2]], , drop = FALSE],
    diag(nr)[id[[3]], , drop = FALSE])
  ng <- ncol(Z); nb <- ng + nr * (K - 1L)
  steps <- matrix(0, nr, K)
  if (K > 1L) {
    steps[, seq_len(K - 1L)] <- matrix(par[ng + seq_len(nr*(K-1L))], nr, byrow = TRUE)
    steps[, K] <- -rowSums(steps)
  }
  location <- drop(Z %*% par[seq_len(ng)])
  a <- exp(drop(Z %*% par[nb + seq_len(ng)]))
  cumulative <- t(apply(cbind(0, steps), 1L, cumsum))
  logits <- (outer(theta[id[[1]]] - location, 0:K) - cumulative[id[[3]], , drop = FALSE]) * a
  w <- exp(logits - apply(logits, 1L, max))
  w / rowSums(w)
}
generate <- function(fit, par, seed) fn("with_preserved_rng_seed")(seed, {
  cfg <- fit$config; idx <- indices(fit)
  stopifnot(!isTRUE(cfg$population_spec$active), all(idx$weight == 1),
    identical(cfg$gpcm_spec$identification, "first_family_sum_zero_log_slopes"))
  expanded <- fn("expand_params")(par, fn("build_param_sizes")(cfg), cfg)
  theta <- rnorm(cfg$n_person)
  eta <- theta[idx$person] + fn("compute_base_eta")(idx, expanded, cfg)
  cumulative <- t(apply(expanded$steps_mat, 1L, function(x) c(0, cumsum(x))))
  prob <- fn("category_prob_gpcm")(eta, cumulative, idx$step_idx,
    expanded$slopes, idx$slope_idx)
  literal <- literal_probability(fit, par, theta)
  error <- max(abs(prob - literal))
  stopifnot(error <= 1e-12, max(abs(rowSums(prob) - 1)) <= 1e-12,
    all(is.finite(prob)), all(prob >= 0))
  u <- runif(nrow(prob)); cdf <- t(apply(prob, 1L, cumsum))
  cdf[, ncol(cdf)] <- 1
  score <- as.integer(rowSums(u > cdf))
  stopifnot(all(score >= 0L & score <= fit$gmfrm$specification$max_score))
  list(theta = theta, person_index = idx$person, uniforms = u, score = score,
    probabilities = prob, response_error = error, seed = seed)
})
with_scores <- function(parent, score) {
  # Use only likelihood inputs; no retained fit, posterior, or information cache.
  fit <- parent[c("config", "prep", "gmfrm")]
  s <- fit$gmfrm$specification
  stopifnot(length(score) == nrow(fit$prep$data), fit$prep$rating_min == 0,
    identical(as.numeric(fit$prep$score_map$OriginalScore), as.numeric(0:s$max_score)),
    all(vapply(c(s$person, s$slope_facets), function(k)
      identical(as.character(s$data[[k]]), as.character(fit$prep$data[[k]])), TRUE)))
  fit$prep$data$Score <- fit$prep$data$score_k <- score
  fit$prep$unused_score_categories <- setdiff(0:s$max_score, unique(score))
  fit$gmfrm$specification$data[[s$score]] <- score
  stopifnot(identical(indices(fit)$score_k, score),
    identical(fit$config, parent$config), identical(fit$prep$levels, parent$prep$levels),
    identical(fit$prep$data[c("Person", s$slope_facets)],
      parent$prep$data[c("Person", s$slope_facets)]))
  fit
}

# Reuse each native optimizer with a frozen policy, identical for observed and
# generated data. Unrestricted: native direct BFGS and its existing polishing;
# constrained: existing profile BFGS stages. Both use maxit 400 and two starts.
optimize_one <- function(fit, start, C, target, constrained) {
  low <- context(fit, 31L); high <- context(fit, 61L)
  if (constrained) return(fn("mfrm_gpcm_profile_nuisance")(
    low, high, start, C, target, 400L))
  cfg <- fit$config
  opt <- fn("run_mfrm_direct_optimization")(start, "MML", indices(fit), cfg,
    fn("build_param_sizes")(cfg), 31L, 400L, 1e-10,
    optimizer = "BFGS", suppress_convergence_warning = TRUE)
  p <- opt$par; g <- low$gradient(p); h <- high$gradient(p)
  row <- data.frame(NLL = low$value(p), MaxGradient = max(abs(g)),
    OptimizerCode = opt$convergence, NLLChange = abs(low$value(p) - high$value(p)),
    GradientChange = max(abs(g - h)), ReferenceGradient = max(abs(h)))
  row$Passed <- all(is.finite(as.matrix(row))) && row$OptimizerCode == 0L &&
    row$MaxGradient <= 1e-4 && row$NLLChange <= 1e-5 &&
    row$GradientChange <= 1e-4 && row$ReferenceGradient <= 1e-4
  list(check = row, parameters = p, optimizer = opt)
}
reference_one <- function(fit, attempt, C, target, constrained) {
  p <- attempt$parameters
  if (is.null(p) || any(!is.finite(p))) stop("No finite returned optimum.")
  r <- gmfrm_profile_reference(fit, p, 121L)
  basis <- if (constrained) qr.Q(qr(matrix(C, ncol = 1)), complete = TRUE)[, -1, drop = FALSE] else diag(length(p))
  info <- crossprod(basis, r$information %*% basis)
  row <- data.frame(NLL = r$continuous_nll,
    NLLDifference = abs(r$continuous_nll - attempt$check$NLL),
    IntegrationDifference = abs(r$continuous_nll + sum(r$log_marginal)),
    Score = max(abs(crossprod(basis, colSums(r$scores)))),
    MinimumInformation = min(eigen(info, symmetric = TRUE, only.values = TRUE)$values),
    ConstraintError = if (constrained) abs(sum(C*p) - target) else 0)
  row$Passed <- all(is.finite(as.matrix(row))) && row$NLLDifference <= 1e-5 &&
    row$IntegrationDifference <= 1e-6 && row$Score <= 1e-4 &&
    row$MinimumInformation > 0 && row$ConstraintError <= 1e-8
  list(check = row, reference = r)
}

preflight <- function(paths) do.call(rbind, lapply(paths, function(path) {
  f <- read_parent(path); idx <- indices(f); p <- f$opt$par
  ex <- fn("expand_params")(p, fn("build_param_sizes")(f$config), f$config)
  theta <- seq(-2, 2, length.out = f$config$n_person)
  eta <- theta[idx$person] + fn("compute_base_eta")(idx, ex, f$config)
  cs <- t(apply(ex$steps_mat, 1L, function(x) c(0, cumsum(x))))
  prob <- fn("category_prob_gpcm")(eta, cs, idx$step_idx, ex$slopes, idx$slope_idx)
  error <- max(abs(prob - literal_probability(f, p, theta)))
  g <- with_scores(f, rep(0L, nrow(f$prep$data)))
  stopifnot(error < 1e-12, all(indices(g)$score_k == 0L),
    identical(g$prep$unused_score_categories, 1:2),
    all(g$gmfrm$specification$data$Score == 0),
    identical(fn("build_param_sizes")(g$config), fn("build_param_sizes")(f$config)))
  data.frame(N = f$config$n_person, ProbabilityError = error,
    EmptyCategoriesPreserved = TRUE)
}))

main <- function(args) {
  stopifnot(length(args) > 0L, args[1] %in% c("prepare", "run", "summarize"))
  manifest_path <- file.path(out, "manifest.rds")
  pkgload::load_all(quiet = TRUE, compile = FALSE)
  source("inst/validation/gmfrm-adaptive-profile-reference-20261010.R")
  if (args[1] == "prepare") {
    stopifnot(!file.exists(manifest_path))
    review_path <- "validation-results/gmfrm-profile-membership-20261010/bootstrap-candidate-review.rds"
    review <- readRDS(review_path); check_hash(review$inputs)
    plan <- review$parents
    stopifnot(identical(plan$Case, c("N20", "N60", "N240")), all(plan$PlannedInner == 19))
    sources <- c(script, "inst/validation/gmfrm-adaptive-profile-reference-20261010.R",
      "tests/testthat/helper-gmfrm-information.R", list.files("R", full.names = TRUE), "src/mfrmr.so")
    stopifnot(unname(tools::md5sum(getLoadedDLLs()[["mfrmr"]][["path"]])) ==
      unname(tools::md5sum("src/mfrmr.so")))
    seeds <- matrix(2026101000L + seq_len(57L), 3L, 19L, byrow = TRUE,
      dimnames = list(plan$Case, as.character(1:19)))
    manifest <- list(plan = plan, seeds = seeds, rng_kind = RNGkind(),
      deterministic_preflight = preflight(plan$Path),
      inputs = tools::md5sum(c(review_path, names(review$inputs))),
      sources = tools::md5sum(sources), session = sessionInfo(),
      threads = Sys.getenv(c("OPENBLAS_NUM_THREADS", "OMP_NUM_THREADS", "MKL_NUM_THREADS", "VECLIB_MAXIMUM_THREADS")),
      policy = c("Target = retained Task t1 log slope + 0.5. Same retained/zero starts for every dataset.",
        "Native unrestricted BFGS reltol 1e-10 plus existing polishing; native constrained profile stages; maxit 400.",
        "q31/61 NLL 1e-5, gradient 1e-4, two-start NLL 1e-5; reference q121 plus continuous integration.",
        "All four returned optima receive independent score/information checks. No ridge information.",
        "Generation only after observed unrestricted and null pass. Fixed assignments/ladder; all 19 draws accounted.",
        "LR comparison bracket +/-4e-5 per statistic from the two 1e-5 NLL tolerances; numerical sensitivity, not certified error bounds.",
        "No curtailment, redraw, case-specific rescue, broad performance launch, or public adoption."))
    dir.create(out, recursive = TRUE, showWarnings = FALSE)
    saveRDS(manifest, manifest_path)
    cat("Bound inputs, source, 57 seeds and policy before numerical execution.\n")
    return(invisible(NULL))
  }
  m <- readRDS(manifest_path); check_hash(m$inputs); check_hash(m$sources)
  seal <- tools::md5sum(manifest_path)
  stopifnot(identical(R.version.string, m$session$R.version$version.string),
    identical(RNGkind(), m$rng_kind), identical(Sys.getenv(names(m$threads)), m$threads),
    unname(tools::md5sum(getLoadedDLLs()[["mfrmr"]][["path"]])) == unname(m$sources["src/mfrmr.so"]))
  # Every phase is independently persisted; refitting is not repeated after a
  # reference/summary interruption. Bind prerequisite result files as well.
  phase <- function(path, inputs, calculate) {
    binding <- tools::md5sum(inputs); check_hash(binding)
    if (file.exists(path)) {
      x <- readRDS(path)
      stopifnot(identical(x$manifest, seal), identical(x$inputs, binding))
      return(x)
    }
    warnings <- character(); error <- ""; value <- NULL
    elapsed <- system.time(withCallingHandlers(tryCatch(value <- calculate(),
      error = function(e) error <<- conditionMessage(e)), warning = function(w) {
        warnings <<- c(warnings, conditionMessage(w)); invokeRestart("muffleWarning") }))
    x <- list(manifest = seal, inputs = binding, value = value, error = error,
      warnings = unique(warnings), seconds = unname(elapsed["elapsed"]))
    tmp <- paste0(path, ".tmp"); saveRDS(x, tmp); stopifnot(file.rename(tmp, path))
    cat(basename(path), if (nzchar(error)) error else "saved", x$seconds, "seconds\n")
    flush.console(); x
  }
  qualify <- function(fit, p, C, target, prefix, input) {
    results <- list(); paths <- character()
    for (kind in c("free", "null")) for (start in c("retained", "neutral")) {
      key <- paste(kind, start, sep = "-"); path <- paste0(prefix, "-", key, ".rds")
      a <- phase(path, input, function() optimize_one(fit,
        if (start == "retained") p else rep(0, length(p)), C, target, kind == "null"))
      rpath <- paste0(prefix, "-", key, "-reference.rds")
      r <- phase(rpath, c(input, path), function() reference_one(fit,
        a$value, C, target, kind == "null"))
      results[[key]] <- list(attempt = a, reference = r); paths <- c(paths, path, rpath)
    }
    phase(paste0(prefix, "-result.rds"), paths, function() {
      passed <- all(vapply(results, function(x) !nzchar(x$attempt$error) &&
        !nzchar(x$reference$error) && isTRUE(x$attempt$value$check$Passed) &&
        isTRUE(x$reference$value$check$Passed), TRUE))
      nll <- vapply(results, function(x) if (is.null(x$attempt$value$check$NLL)) NA_real_ else x$attempt$value$check$NLL, 0)
      spread <- vapply(c("free", "null"), function(k)
        diff(range(nll[startsWith(names(nll), k)])), 0)
      passed <- passed && all(is.finite(nll)) && all(spread <= 1e-5)
      lr <- 2*(min(nll[3:4]) - min(nll[1:2]))
      passed <- passed && is.finite(lr) && lr >= -4e-5
      best <- if (all(is.finite(nll[3:4]))) 2L + which.min(nll[3:4]) else NA_integer_
      list(passed = passed, LR = lr, nll = nll, start_spread = spread,
        null_parameters = if (is.na(best)) NULL else results[[best]]$attempt$value$parameters,
        results = results)
    })
  }
  if (args[1] == "run") {
    selected <- if (length(args) > 1L) match(args[2], m$plan$Case) else seq_len(nrow(m$plan))
    stopifnot(!anyNA(selected))
    for (i in selected) {
      job <- m$plan[i, ]; fit <- read_parent(job$Path); original <- serialize(fit, NULL)
      dir <- file.path(out, job$Case); dir.create(dir, showWarnings = FALSE)
      p <- fit$opt$par; tg <- fn("mfrm_gpcm_product_slope_targets")(p, fit$config)$components
      C <- unname(tg$jacobian[tg$metadata$Owner == job$FirstOwner & tg$metadata$Level == job$Level, ])
      expected <- numeric(length(p)); expected[length(p) - 7L] <- 1
      stopifnot(identical(C, expected), fit$config$n_person == job$N,
        fn("mfrmr_adaptive_integration")(fit$config), fit$config$estimation_control$quad_points == 31)
      target <- sum(C*p) + .5
      observed <- qualify(fit, p, C, target, file.path(dir, "observed"), job$Path)
      if (!isTRUE(observed$value$passed)) {
        cat(job$Case, "observed qualification refused; no generation.\n"); next
      }
      null <- observed$value$null_parameters
      observed_path <- file.path(dir, "observed-result.rds")
      for (b in 1:19) {
        prefix <- file.path(dir, sprintf("b%02d", b)); gp <- paste0(prefix, "-generation.rds")
        generated <- phase(gp, c(job$Path, observed_path), function() {
          had <- exists(".Random.seed", .GlobalEnv, inherits = FALSE)
          old <- if (had) get(".Random.seed", .GlobalEnv) else NULL
          on.exit(if (had) assign(".Random.seed", old, .GlobalEnv) else if
            (exists(".Random.seed", .GlobalEnv, inherits = FALSE)) rm(".Random.seed", envir = .GlobalEnv))
          if (had) rm(".Random.seed", envir = .GlobalEnv)
          first <- generate(fit, null, m$seeds[i, b])
          stopifnot(!exists(".Random.seed", .GlobalEnv, inherits = FALSE))
          set.seed(1701L); before <- get(".Random.seed", .GlobalEnv)
          replay <- generate(fit, null, m$seeds[i, b])
          stopifnot(identical(before, get(".Random.seed", .GlobalEnv)), identical(first, replay),
            abs(sum(C*null) - target) <= 1e-8)
          # Replay is the identical dataset, not an extra allocated replicate.
          first
        })
        if (nzchar(generated$error)) next
        draw <- with_scores(fit, generated$value$score)
        qualify(draw, p, C, target, prefix, c(job$Path, gp))
      }
      stopifnot(identical(original, serialize(fit, NULL)))
    }
  }
  if (args[1] == "summarize") {
    rows <- list()
    for (case in m$plan$Case) {
      dir <- file.path(out, case); op <- file.path(dir, "observed-result.rds")
      stopifnot(file.exists(op)); observed <- readRDS(op)
      stopifnot(identical(observed$manifest, seal)); check_hash(observed$inputs)
      for (b in 0:19) {
        path <- if (b == 0) op else file.path(dir, sprintf("b%02d-result.rds", b))
        gp <- file.path(dir, sprintf("b%02d-generation.rds", b))
        available <- file.exists(path)
        x <- if (available) readRDS(path) else NULL
        if (available) { stopifnot(identical(x$manifest, seal)); check_hash(x$inputs) }
        reason <- if (b > 0 && !isTRUE(observed$value$passed)) "parent_refused" else
          if (!available && file.exists(gp) && nzchar(readRDS(gp)$error)) "generation_error" else
          if (!available) "incomplete" else if (!isTRUE(x$value$passed)) "numerical_refusal" else "qualified"
        lr <- if (available) x$value$LR else NA_real_
        comparison <- if (b == 0 || reason != "qualified") "unresolved" else
          if (lr - observed$value$LR > 8e-5) "exceed" else
          if (lr - observed$value$LR < -8e-5) "lower" else "numerically_ambiguous"
        rows[[length(rows) + 1L]] <- data.frame(Case = case, Draw = b,
          Status = reason, LR = lr, Comparison = comparison)
      }
    }
    rows <- do.call(rbind, rows); stopifnot(!any(rows$Status == "incomplete"))
    accounting <- do.call(rbind, lapply(m$plan$Case, function(case) {
      r <- rows[rows$Case == case & rows$Draw > 0, ]; obs <- rows[rows$Case == case & rows$Draw == 0, ]
      E <- sum(r$Comparison == "exceed"); L <- sum(r$Comparison == "lower")
      lower <- (1+E)/20; upper <- (20-L)/20
      data.frame(Case = case, Parent = obs$Status, Qualified = sum(r$Status == "qualified"),
        Refused = sum(r$Status %in% c("numerical_refusal", "generation_error")),
        NotGenerated = sum(r$Status == "parent_refused"), Exceed = E, Lower = L,
        PLower = if (obs$Status == "qualified") lower else NA_real_,
        PUpper = if (obs$Status == "qualified") upper else NA_real_,
        Decision = if (obs$Status != "qualified") "unavailable" else if (lower > .05)
          "retain" else if (upper <= .05) "reject" else "unresolved")
    }))
    files <- list.files(out, pattern = "[.]rds$", recursive = TRUE, full.names = TRUE)
    files <- setdiff(files, c(manifest_path, file.path(out, "summary.rds")))
    phases <- do.call(rbind, lapply(files, function(path) {
      x <- readRDS(path); stopifnot(identical(x$manifest, seal)); check_hash(x$inputs)
      data.frame(Path = path, Seconds = x$seconds, Error = x$error)
    }))
    summary <- list(manifest = seal, results = tools::md5sum(files), rows = rows,
      accounting = accounting, phases = phases,
      advancement = if (all(rows$Status == "qualified")) "numerical_feasibility_only" else "blocked_pending_disposition")
    saveRDS(summary, file.path(out, "summary.rds"))
    write.csv(rows, file.path(out, "draws.csv"), row.names = FALSE)
    write.csv(accounting, file.path(out, "accounting.csv"), row.names = FALSE)
    write.csv(phases, file.path(out, "phases.csv"), row.names = FALSE)
    print(accounting, row.names = FALSE); cat(summary$advancement, "\n")
  }
  check_hash(m$inputs); check_hash(m$sources)
}
if (sys.nframe() == 0L) main(commandArgs(trailingOnly = TRUE))
