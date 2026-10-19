# Retained-data feasibility, not a coverage study or a public estimator.
# Run prepare, check, fit, replay from the package root, with four thread limits = 1.
args <- commandArgs(TRUE)
stopifnot(length(args) == 1L, args %in% c("prepare", "check", "fit", "replay"))
action <- args[[1L]]
directory <- "validation-results/gmfrm-regularized-feasibility-20261012"
script <- "inst/validation/gmfrm-regularized-feasibility-20261012.R"
manifest <- file.path(directory, "manifest.rds")
old_path <- "validation-results/gmfrm-complete-procedure-20261011/manifest.rds"
prior_path <- "validation-results/gmfrm-posterior-feasibility-20261012/manifest.rds"
threads <- c("OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS", "VECLIB_MAXIMUM_THREADS")
check_hash <- function(h) stopifnot(length(h) > 0L, !anyNA(h), identical(h, tools::md5sum(names(h))))
capture <- function(f) {
  value <- NULL; error <- NULL; warnings <- character()
  seconds <- system.time(withCallingHandlers(tryCatch(value <- f(),
    error = function(e) error <<- conditionMessage(e)), warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w)); invokeRestart("muffleWarning")
    }))[["elapsed"]]
  list(value = value, error = error, warnings = warnings, seconds = seconds)
}
if (action == "prepare") {
  stopifnot(!file.exists(manifest), all(Sys.getenv(threads) == "1"))
  old <- readRDS(old_path); prior <- readRDS(prior_path)
  check_hash(old$inputs); check_hash(prior$inputs)
  installed <- "tmp/owner-category-20261012/install-check"
  live <- list.files("R", full.names = TRUE, pattern = "[.]R$")
  built <- file.path(installed, "source/mfrmr/R", basename(live))
  stopifnot(identical(unname(tools::md5sum(live)), unname(tools::md5sum(built))))
  lib <- file.path(directory, "library")
  dir.create(lib, recursive = TRUE)
  stopifnot(file.copy(file.path(installed, "library/mfrmr"), lib, recursive = TRUE),
    file.copy(script, file.path(directory, "source.R")))
  package_files <- list.files(lib, full.names = TRUE, recursive = TRUE, all.files = TRUE)
  m <- list(cases = old$cases, prior = prior$cases, contrasts = prior$contrasts,
    inputs = tools::md5sum(unique(c(old_path, prior_path, names(old$inputs), names(prior$inputs)))),
    source = tools::md5sum(c(file.path(directory, "source.R"), package_files)),
    source_R = tools::md5sum(live), R = R.version, threads = Sys.getenv(threads),
    packages = vapply(c("Matrix", "statmod", "cpp11"), function(p) as.character(packageVersion(p)), ""),
    controls = list(lambda = 1, fixed_order = 61L, adaptive_orders = c(61L, 121L),
      starts = c("zero", "cosine"), null = "location:Task:t1 - location:Task:t2 = 0",
      gradient_tolerance = 1e-4, value_tolerance = 1e-6, integration_gradient_tolerance = 1e-4,
      start_value_tolerance = 1e-5, start_coordinate_tolerance = 1e-3,
      maxit = 500L, reltol = 1e-12, polish_maxit = 200L, polish_reltol = 1e-14))
  saveRDS(m, manifest)
  cat("Prepared five retained datasets; isolated installed source; no new responses.\n")
  quit(save = "no")
}
m <- readRDS(manifest); check_hash(m$inputs); check_hash(m$source)
stopifnot(identical(m$R, R.version), identical(m$threads, Sys.getenv(threads)),
  identical(m$packages, vapply(names(m$packages), function(p) as.character(packageVersion(p)), "")))
seal <- tools::md5sum(manifest)
library(mfrmr, lib.loc = file.path(directory, "library"))
stopifnot(identical(normalizePath(find.package("mfrmr")),
  normalizePath(file.path(directory, "library/mfrmr"))))
fn <- function(n) get(n, asNamespace("mfrmr"))
blocked <- function(...) stop("New random data are outside this feasibility allocation.")
for (n in c("rnorm", "runif", "rbinom")) assignInNamespace(n, blocked, "stats")

# Native drop-last coordinates = T * standardized orthonormal coordinates.
mapping <- function(bundle, labels) {
  b <- bundle; d <- b$stan_data
  sd <- c(d$location_sd, rep(d$step_sd, d$G * d$Q), d$log_slope_sd)
  T <- matrix(0, length(labels), length(sd), dimnames = list(labels, NULL))
  for (j in seq_along(labels)) {
    k <- strsplit(labels[j], ":", fixed = TRUE)[[1L]]
    if (k[1L] == "location") {
      row <- b$levels$Index[b$levels$Facet == k[2L] & b$levels$Level == k[3L]]
      stopifnot(length(row) == 1L)
      T[j, seq_len(d$P)] <- d$location_basis[row, ]
    } else if (k[1L] == "step") {
      owner <- match(k[3L], b$step_owners)
      T[j, d$P + (owner - 1L) * d$Q + seq_len(d$Q)] <- d$step_basis[as.integer(k[4L]), ]
    } else {
      stopifnot(k[1L] == "log_slope")
      row <- b$slope_levels$Index[b$slope_levels$Owner == k[2L] & b$slope_levels$Level == k[3L]]
      stopifnot(length(row) == 1L)
      T[j, d$P + d$G * d$Q + seq_len(d$S)] <- d$slope_basis[row, ]
    }
  }
  T <- sweep(T, 2L, sd, "*")
  stopifnot(nrow(T) == ncol(T), qr(T)$rank == ncol(T), all(is.finite(T)))
  T
}
setup <- function(case) {
  s <- m$cases[[case]]$specification
  p <- do.call(fn("mfrm_gmfrm_problem"), c(s,
    list(quadrature = fn("gauss_hermite_normal")(m$controls$fixed_order))))
  stopifnot(identical(names(p$start), colnames(m$contrasts)))
  T <- mapping(m$prior[[case]]$bundle, names(p$start))
  ad <- lapply(m$controls$adaptive_orders, function(q)
    fn("mfrmr_make_adaptive_mml_evaluator")(p$common$idx, p$common$config, p$common$sizes, q))
  fixed <- function(par) {
    v <- p$marginal(par)
    list(value = p$n_person * v$value, gradient = p$n_person * v$gradient)
  }
  list(specification = s, problem = p, T = T, likelihood = c(list(fixed = fixed),
    setNames(ad, paste0("adaptive", m$controls$adaptive_orders))))
}
coordinates <- function(T, null = FALSE, target = 0) {
  n <- ncol(T)
  if (!null) return(list(U = diag(n), origin = numeric(n)))
  C <- as.numeric(rownames(T) == "location:Task:t1") - as.numeric(rownames(T) == "location:Task:t2")
  c <- drop(C %*% T); stopifnot(sum(c^2) > 0)
  U <- qr.Q(qr(matrix(c, ncol = 1L)), complete = TRUE)[, -1L, drop = FALSE]
  origin <- c * target / sum(c^2)
  stopifnot(max(abs(c %*% U)) < 1e-12, abs(sum(c * origin) - target) < 1e-12,
    max(abs(crossprod(U) - diag(n - 1L))) < 1e-12)
  list(U = U, origin = origin)
}
evaluator <- function(likelihood, T, coordinate) {
  last <- state <- NULL; evaluations <- hits <- 0L
  U <- coordinate$U; origin <- coordinate$origin
  evaluate <- function(u) {
    if (!is.null(last) && identical(u, last)) { hits <<- hits + 1L; return(state) }
    last <<- NULL; evaluations <<- evaluations + 1L
    z <- origin + drop(U %*% u); par <- drop(T %*% z)
    l <- likelihood(par)
    g <- drop(crossprod(T, l$gradient)) + m$controls$lambda * z
    state <<- list(value = l$value + m$controls$lambda * sum(z^2) / 2,
      gradient = drop(crossprod(U, g)), full_gradient = g,
      nll = l$value, z = z, par = par)
    last <<- u + 0
    state
  }
  list(evaluate = evaluate, counts = function() c(evaluations = evaluations, hits = hits))
}
finite_difference <- function(f, x, h) vapply(seq_along(x), function(j) {
  a <- b <- x; a[j] <- a[j] + h; b[j] <- b[j] - h
  (f(a) - f(b)) / (2 * h)
}, 0)
out <- function(name) file.path(directory, paste0(name, ".rds"))
save <- function(x, file) {
  saveRDS(c(list(manifest = seal), x), paste0(file, ".tmp"))
  stopifnot(file.rename(paste0(file, ".tmp"), file))
}
if (action == "check") {
  stopifnot(!file.exists(out("checks")))
  rows <- list(); timings <- list()
  for (case in names(m$cases)) {
    s <- setup(case); T <- s$T; p <- s$problem
    z <- .25 * cos(seq_len(ncol(T))); par <- drop(T %*% z)
    inverse <- solve(T); P <- crossprod(inverse)
    decoded <- p$unpack(par); ni <- length(decoded$locations[[1L]])
    K <- s$specification$max_score
    expanded_penalty <- (sum(decoded$locations[[1L]]^2) / (ni / (ni - 1)) +
      sum(decoded$locations[[2L]]^2) + sum(decoded$steps^2) / (K / (K - 1)) +
      sum(log(decoded$slopes[[1L]])^2) / (.7^2 * ni / (ni - 1)) +
      sum(log(decoded$slopes[[2L]])^2) / .7^2) / 2
    ev <- evaluator(s$likelihood$fixed, T, coordinates(T))
    state <- ev$evaluate(z)
    fd <- lapply(c(1e-5, 5e-6), function(h) finite_difference(function(x) ev$evaluate(x)$value, z, h))
    null <- coordinates(T, TRUE, .4)
    nv <- evaluator(s$likelihood$fixed, T, null); u <- drop(crossprod(null$U, z))
    ng <- finite_difference(function(x) nv$evaluate(x)$value, u, 1e-5)
    e <- c(Penalty = abs(expanded_penalty - sum(z^2) / 2),
      CoordinatePenalty = abs(drop(crossprod(par, P %*% par)) / 2 - sum(z^2) / 2),
      Gradient = max(abs(state$gradient - fd[[1L]])),
      GradientHalfStep = max(abs(state$gradient - fd[[2L]])),
      NullGradient = max(abs(nv$evaluate(u)$gradient - ng)),
      TotalScaling = abs(state$value - state$nll - sum(z^2) / 2))
    stopifnot(all(e[1:2] < 1e-12), all(e[3:5] < 1e-5), e[6L] < 1e-10)
    # Rotation must transform both the response coordinates and the penalty.
    V <- qr.Q(qr(outer(seq_along(z), seq_along(z), function(i, j) sin(i + j^2)) + diag(length(z))))
    rotation <- evaluator(s$likelihood$fixed, T %*% V, coordinates(T))
    rotated <- rotation$evaluate(drop(crossprod(V, z)))
    stopifnot(abs(rotated$value - state$value) < 1e-10,
      max(abs(rotated$gradient - crossprod(V, state$gradient))) < 1e-9)
    a <- ev$evaluate(z); counts <- ev$counts(); b <- ev$evaluate(z)
    stopifnot(identical(a, b), ev$counts()[1L] == counts[1L], ev$counts()[2L] == counts[2L] + 1L)
    rows[[case]] <- e
    if (case %in% c("N20-observed", "N240-observed")) for (method in c("fixed", "adaptive61")) {
      values <- vector("list", 5L)
      profile <- file.path(directory, paste0(case, "-", method, ".Rprof"))
      Rprof(profile, interval = .001)
      seconds <- system.time(for (i in seq_len(5L)) values[[i]] <-
        s$likelihood[[method]](par + i * 1e-4))[["elapsed"]]
      Rprof(NULL)
      timings[[paste(case, method)]] <- list(case = case, method = method,
        seconds = seconds, evaluations = 5L, values = values,
        profile = summaryRprof(profile)$by.total)
    }
    cat(case, "objective, gradient, penalty and affine/rotation checks passed.\n"); flush.console()
  }
  save(list(checks = do.call(rbind, rows), timings = timings, session = sessionInfo()), out("checks"))
  quit(save = "no")
}
stopifnot(file.exists(out("checks")), identical(readRDS(out("checks"))$manifest, seal))
minimize <- function(ev, start, n) {
  f <- function(x) ev$evaluate(x)$value / n
  g <- function(x) ev$evaluate(x)$gradient / n
  a <- optim(start, f, g, method = "BFGS",
    control = list(maxit = m$controls$maxit, reltol = m$controls$reltol))
  polish <- NULL; par <- a$par
  if (max(abs(ev$evaluate(a$par)$gradient)) > m$controls$gradient_tolerance) {
    polish <- nlminb(a$par, f, g, control = list(iter.max = m$controls$polish_maxit,
      eval.max = 1000L, rel.tol = m$controls$polish_reltol))
    if (polish$objective <= a$value + 1e-12) par <- polish$par
  }
  list(state = ev$evaluate(par), u = par, optimizer = a, polish = polish, counts = ev$counts())
}
if (action == "fit") {
  for (case in names(m$cases)) for (kind in c("free", "null")) {
    file <- out(paste(case, kind, sep = "-"))
    if (file.exists(file)) { stopifnot(identical(readRDS(file)$manifest, seal)); next }
    s <- setup(case); co <- coordinates(s$T, kind == "null")
    starts <- list(zero = numeric(ncol(s$T)), cosine = .25 * cos(seq_len(ncol(s$T))))
    attempts <- list()
    for (name in names(starts)) {
      stages <- list(); u <- drop(crossprod(co$U, starts[[name]] - co$origin))
      for (method in c("fixed", "adaptive61", "adaptive121")) {
        ev <- evaluator(s$likelihood[[method]], s$T, co)
        stage <- capture(function() minimize(ev, u, s$problem$n_person))
        stages[[method]] <- stage
        if (!is.null(stage$error)) break
        u <- stage$value$u
        review <- capture(function() {
          other <- evaluator(s$likelihood$adaptive121, s$T, co)$evaluate(u)
          at <- stage$value$state
          list(state = other, value_difference = abs(at$value - other$value),
            gradient_difference = max(abs(at$full_gradient - other$full_gradient)))
        })
        stages[[paste0(method, "_review")]] <- review
        if (!is.null(review$error)) break
        r <- review$value
        if (r$value_difference <= m$controls$value_tolerance &&
            r$gradient_difference <= m$controls$integration_gradient_tolerance &&
            max(abs(r$state$gradient)) <= m$controls$gradient_tolerance) break
      }
      attempts[[name]] <- list(stages = stages, u = u)
      cat(case, kind, name, "finished:", paste(names(stages), collapse = ", "), "\n"); flush.console()
    }
    candidates <- lapply(attempts, function(a) capture(function()
      evaluator(s$likelihood$adaptive121, s$T, co)$evaluate(a$u)))
    values <- vapply(candidates, function(x) if (is.null(x$error)) x$value$value else Inf, 0)
    selected <- if (any(is.finite(values))) names(which.min(values)) else NA_character_
    reference <- if (!is.na(selected)) capture(function() {
      state <- candidates[[selected]]$value
      ref <- fn("mfrm_gmfrm_reference_integrate")(
        fn("mfrm_gmfrm_reference_design")(s$specification, state$par))
      gradient <- -drop(crossprod(s$T, ref$score)) + m$controls$lambda * state$z
      list(reference = ref, state = state,
        gradient = drop(crossprod(co$U, gradient)),
        objective_error = abs(state$nll - ref$nll),
        gradient_error = max(abs(state$full_gradient - gradient)))
    }) else list(value = NULL, error = "No finite candidate", seconds = 0)
    save(list(case = case, kind = kind, T = s$T, coordinate = co, attempts = attempts,
      candidates = candidates, selected = selected, reference = reference), file)
    cat("Saved", case, kind, "reference error:", reference$error, "\n"); flush.console()
  }
  quit(save = "no")
}

# Fresh replay uses retained values only; fitting/integration cannot fill gaps.
for (n in c("optim", "nlminb", "integrate")) assignInNamespace(n, blocked, "stats")
files <- unlist(lapply(names(m$cases), function(case) out(paste(case, c("free", "null"), sep = "-"))))
stopifnot(all(file.exists(files)))
rows <- lapply(files, function(file) {
  x <- readRDS(file); stopifnot(identical(x$manifest, seal))
  r <- x$reference$value
  if (is.null(r)) return(data.frame(Case = x$case, Kind = x$kind, Qualified = FALSE,
    Q = NA_real_, Penalty = NA_real_, MaxGradient = NA_real_, NLLCheck = NA_real_,
    GradientCheck = NA_real_, StartValueSpread = NA_real_, StartCoordinateSpread = NA_real_,
    FitSeconds = NA_real_, ReviewSeconds = NA_real_, ReferenceSeconds = x$reference$seconds,
    Evaluations = NA_real_, CacheHits = NA_real_))
  values <- vapply(x$candidates, function(a) if (is.null(a$error)) a$value$value else Inf, 0)
  coordinates <- lapply(x$candidates, function(a) if (is.null(a$error)) a$value$z else NA_real_)
  value_spread <- diff(range(values)); parameter_spread <- max(abs(coordinates[[1L]] - coordinates[[2L]]))
  errors <- unlist(lapply(x$attempts, function(a) vapply(a$stages, function(s) !is.null(s$error), TRUE)))
  good <- !any(errors) && isTRUE(r$reference$qualified) &&
    r$objective_error <= m$controls$value_tolerance &&
    r$gradient_error <= m$controls$integration_gradient_tolerance &&
    max(abs(r$gradient)) <= m$controls$gradient_tolerance &&
    value_spread <= m$controls$start_value_tolerance &&
    parameter_spread <= m$controls$start_coordinate_tolerance
  stages <- unlist(lapply(x$attempts, `[[`, "stages"), recursive = FALSE)
  fit_stages <- stages[!grepl("_review$", names(stages))]
  data.frame(Case = x$case, Kind = x$kind, Qualified = isTRUE(good),
    Q = r$reference$nll + sum(r$state$z^2) / 2, Penalty = sum(r$state$z^2) / 2,
    MaxGradient = max(abs(r$gradient)), NLLCheck = r$objective_error,
    GradientCheck = r$gradient_error, StartValueSpread = value_spread,
    StartCoordinateSpread = parameter_spread,
    FitSeconds = sum(vapply(fit_stages, `[[`, 0, "seconds")),
    ReviewSeconds = sum(vapply(stages[grepl("_review$", names(stages))], `[[`, 0, "seconds")),
    ReferenceSeconds = x$reference$seconds,
    Evaluations = sum(vapply(fit_stages, function(s) s$value$counts[1L], 0)),
    CacheHits = sum(vapply(fit_stages, function(s) s$value$counts[2L], 0)))
})
table <- do.call(rbind, rows)
stopifnot(nrow(table) == 10L)
for (case in names(m$cases)) {
  q <- table$Q[table$Case == case]
  stopifnot(length(q) == 2L)
  if (all(is.finite(q))) stopifnot(q[2L] >= q[1L] - m$controls$value_tolerance)
}
save(list(summary = table, outputs = tools::md5sum(files)), out("replay"))
write.csv(table, file.path(directory, "summary.csv"), row.names = FALSE)
print(table, digits = 6, row.names = FALSE)
