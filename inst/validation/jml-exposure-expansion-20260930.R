# Exact score-mean expansion check; not a root, covariance or coverage study.
# Rscript <file> OUTPUT pilot|run
source("inst/validation/jml-total-expectation-20260927.R")

jml_block_moments <- function(owner, exposure, beta, theta) {
  cells <- expand.grid(Rater = 1:2, Criterion = 1:2)
  own <- cells[[owner]]; sr <- c(1, -1)[cells$Rater]; sc <- c(1, -1)[cells$Criterion]
  sa <- c(1, -1)[own]; a <- exp(sa * beta[5])
  mu <- information <- third <- 0
  cross <- mixed_third <- cross_total_derivative <- numeric(5L)
  for (j in 1:4) {
    k <- 0:2; t <- a[j] * k
    z <- a[j] * ((theta - sr[j] * beta[1] - sc[j] * beta[2]) * k - c(0, beta[2 + own[j]], 0))
    p <- exp(z - max(z)); p <- p / sum(p)
    D <- matrix(0, 3L, 5L)
    D[, 1:2] <- cbind(-sr[j] * t, -sc[j] * t)
    D[, 2 + own[j]] <- -a[j] * c(0, 1, 0); D[, 5] <- sa[j] * z
    tc <- t - sum(p * t); Dc <- sweep(D, 2, drop(crossprod(p, D)))
    mu <- mu + exposure[j] * sum(p * t)
    information <- information + exposure[j] * sum(p * tc^2)
    third <- third + exposure[j] * sum(p * tc^3)
    cross <- cross + exposure[j] * drop(crossprod(p * tc, Dc))
    mixed_third <- mixed_third + exposure[j] * drop(crossprod(p * tc^2, Dc))
    cross_total_derivative[5] <- cross_total_derivative[5] + exposure[j] * sa[j] * sum(p * tc^2)
  }
  list(mu = mu, I = information, third = third, cross = cross,
    cross_total_derivative = cross_total_derivative,
    b1 = mixed_third / (2 * information) - cross * third / (2 * information^2))
}

jml_expansion_coefficients <- function(owner, exposure, beta, theta) {
  at <- jml_block_moments(owner, exposure, beta, theta)
  # Independent identity: d_beta Var(T) = 2 Cov(T,T_beta) + cum(T,T,D_beta).
  derivative <- vapply(seq_along(beta), function(j) {
    h <- numeric(5); h[j] <- 1e-5
    (jml_block_moments(owner, exposure, beta + h, theta)$I -
      jml_block_moments(owner, exposure, beta - h, theta)$I) / (2e-5)
  }, 0)
  independent <- (derivative - 2 * at$cross_total_derivative) / (2 * at$I) -
    at$cross * at$third / (2 * at$I^2)
  stopifnot(max(abs(independent - at$b1)) < 1e-8)
  # K_L f = f + D1 f/L + O(L^-2); c1 = -D1 b1.
  predict <- function(h) {
    plus <- jml_block_moments(owner, exposure, beta, theta + h)$b1
    minus <- jml_block_moments(owner, exposure, beta, theta - h)$b1
    first <- (plus - minus) / (2 * h)
    second <- (plus - 2 * at$b1 + minus) / h^2
    -second / (2 * at$I) + at$third * first / (2 * at$I^2)
  }
  coarse <- predict(.002); fine <- predict(.001)
  stopifnot(max(abs(coarse - fine)) < 2e-6)
  list(b1 = at$b1, c1 = fine + (fine - coarse) / 3,
    coefficient_identity_error = max(abs(independent - at$b1)),
    c1_refinement_error = max(abs(coarse - fine)))
}

jml_total_mass <- function(problem, beta, theta) {
  table <- problem$conditional(beta); ag <- exp(c(1, -1) * beta[5])
  marginals <- lapply(1:2, function(g) {
    logp <- log(table[[g]]$probability) + ag[g] * theta * (seq_along(table[[g]]$probability) - 1L)
    p <- exp(logp - max(logp)); p / sum(p)
  })
  result <- marginals[[1]][problem$totals[, 1] + 1L] * marginals[[2]][problem$totals[, 2] + 1L]
  stopifnot(abs(sum(result) - 1) < 1e-12)
  result
}

jml_expansion_case <- function(job, contract, max_states = 10000L) {
  design <- contract$designs[[job$Design]]
  base <- design$exposure[[job$Roster]]; exposure <- job$L * base
  beta <- c(Rater = .3, Criterion = -.4, Step1 = -.6, Step2 = -.9, LogSlope = .25)
  # Placeholder counts initialize the existing expectation factory. They are
  # not generated observations and their actual-score return is never used.
  placeholder <- lapply(exposure, function(n) matrix(c(n, 0, 0), 1L, 3L))
  problem <- make_jml_total_problem(job$Owner, exposure, placeholder, max_states = max_states)
  ability <- design$ability[[job$Roster]]
  coefficients <- lapply(ability, function(t) jml_expansion_coefficients(job$Owner, base, beta, t))
  rows <- list(); checks <- list()
  for (order in c(0L, 1L, 2L)) {
    z <- problem$scores(beta, order)
    U <- z$conditional_raw - z$adjustment
    stopifnot(z$root_residual < 1e-8, z$max_omitted_mass == 0,
      all(is.finite(U)), all(U[c(1, nrow(U)), ] == 0))
    for (i in seq_along(ability)) {
      theta <- ability[i]; mass <- jml_total_mass(problem, beta, theta)
      mean <- drop(crossprod(mass, U)) / job$L
      moment <- jml_block_moments(job$Owner, base, beta, theta)
      # Canonical MLE identities: mu(theta_hat) is the observed mean total,
      # including extended endpoints. Therefore K_L mu = mu, K_L mu^2 = mu^2+I/L.
      target <- drop(problem$totals %*% exp(c(1, -1) * beta[5])) / job$L
      stopifnot(abs(sum(mass * target) - moment$mu) < 1e-10,
        abs(sum(mass * target^2) - moment$mu^2 - moment$I / job$L) < 1e-10)
      # Check finite profiles at representative interior totals independently.
      selected <- unique(as.integer(seq(2, length(target) - 1, length.out = 7)))
      profile_error <- max(abs(vapply(z$total_theta[selected], function(t)
        jml_block_moments(job$Owner, base, beta, t)$mu, 0) - target[selected]))
      stopifnot(profile_error < 1e-10, is.infinite(z$total_theta[1]),
        is.infinite(tail(z$total_theta, 1)))
      prediction <- if (order == 0) coefficients[[i]]$b1 else if (order == 1)
        coefficients[[i]]$c1 else rep(NA_real_, 5)
      rows[[paste(order, i)]] <- data.frame(job, Ability = theta, Order = order,
        Parameter = names(beta), NormalizedMean = mean, ScaledMean = job$L^(order + 1) * mean,
        PredictedLeading = prediction, LeadingError = job$L^(order + 1) * mean - prediction,
        ExtremeMass = sum(mass[c(1, length(mass))]), row.names = NULL)
      checks[[paste(order, i)]] <- c(profile_error = profile_error,
        coefficient_identity_error = coefficients[[i]]$coefficient_identity_error,
        c1_refinement_error = coefficients[[i]]$c1_refinement_error)
    }
  }
  # Match full response-pattern enumeration at the original exposure only.
  if (job$L == 1L) {
    source("inst/validation/jml-design-adjustment-20260927.R")
    ref <- make_jml_roster_problem(job$Owner, base)
    old <- new.env(parent = globalenv())
    sys.source("validation-results/jml-exposure-expansion-20260930/previous-total-expectation.R", old)
    old_problem <- old$make_jml_total_problem(job$Owner, base, placeholder)
    for (k in 0:2) {
      current <- problem$scores(beta, k); current$total_theta <- NULL
      stopifnot(identical(current, old_problem$scores(beta, k)))
      Uref <- ref$scores(beta, k)$value
      for (i in seq_along(ability)) {
        expected <- drop(crossprod(drop(ref$mass(beta, ability[i])), Uref))
        stopifnot(max(abs(expected - rows[[paste(k, i)]]$NormalizedMean)) < 1e-10)
      }
    }
  }
  list(rows = do.call(rbind, rows), checks = do.call(rbind, checks), states = problem$total_states)
}

run_jml_exposure_expansion <- function(out, mode) {
  stopifnot(mode %in% c("pilot", "run"))
  contract_file <- "validation-results/jml-scope-challenge-20260927/contract.rds"
  contract <- readRDS(contract_file)
  jobs <- expand.grid(Owner = c("Criterion", "Rater"), Design = c("sparse", "unequal"),
    Roster = 1:2, L = c(1L, 2L, 4L, 8L, 16L), stringsAsFactors = FALSE)
  files <- c(contract_file, "inst/validation/jml-exposure-expansion-20260930.R",
    "inst/validation/jml-total-expectation-20260927.R",
    "inst/validation/jml-design-adjustment-20260927.R",
    "inst/validation/jml-profile-bias-sample-20260927.R",
    "inst/validation/jml-profile-bias-exact-20260927.R",
    "validation-results/jml-exposure-expansion-20260930/previous-total-expectation.R")
  manifest <- list(jobs = jobs, orders = 0:2, hashes = tools::md5sum(files),
    max_states = 10000L, cores = 1L, session = capture.output(sessionInfo()))
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  path <- file.path(out, "manifest.rds")
  if (file.exists(path)) stopifnot(identical(readRDS(path)$hashes, manifest$hashes)) else {
    saveRDS(manifest, path)
    for (file in files) {
      dest <- file.path(out, "source", file)
      dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
      stopifnot(file.copy(file, dest))
    }
  }
  selected <- if (mode == "pilot") which(jobs$Owner == "Rater" & jobs$Design == "unequal" &
    jobs$Roster == 2 & jobs$L == 8) else seq_len(nrow(jobs))
  for (i in selected) {
    job <- jobs[i, ]; name <- paste(job, collapse = "-"); path <- file.path(out, paste0(name, ".rds"))
    if (file.exists(path)) {
      stopifnot(identical(readRDS(path)$hashes, manifest$hashes)); next
    }
    time <- system.time(z <- jml_expansion_case(job, contract))[["elapsed"]]
    z$hashes <- manifest$hashes; z$seconds <- unname(time)
    stopifnot(identical(manifest$hashes, tools::md5sum(files)))
    saveRDS(z, paste0(path, ".tmp")); stopifnot(file.rename(paste0(path, ".tmp"), path))
    cat(name, "states", z$states, "seconds", time, "\n"); flush.console()
  }
  if (mode == "run") {
    saved <- lapply(seq_len(nrow(jobs)), function(i)
      readRDS(file.path(out, paste0(paste(jobs[i, ], collapse = "-"), ".rds"))))
    rows <- do.call(rbind, lapply(saved, `[[`, "rows"))
    stopifnot(nrow(rows) == 40L * 3L * 3L * 5L)
    write.csv(rows, file.path(out, "means.csv"), row.names = FALSE)
    print(aggregate(abs(LeadingError) ~ Order + L, rows, max), row.names = FALSE)
    saveRDS(list(complete = length(saved), seconds = sum(vapply(saved, `[[`, 0, "seconds")),
      maximum_errors = apply(do.call(rbind, lapply(saved, `[[`, "checks")), 2, max),
      hashes = manifest$hashes), file.path(out, "completion.rds"))
  }
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  stopifnot(length(args) == 2L)
  run_jml_exposure_expansion(args[1], args[2])
}
