# Fixed small refitting/cost pilot, not a nested coverage study.
# Run prepare, run, summarize with the four thread limits set to 1.
args <- commandArgs(TRUE)
stopifnot(length(args) == 1L, args %in% c("prepare", "run", "summarize"))
action <- args[[1L]]
base <- "validation-results/gmfrm-regularized-feasibility-20261012"
directory <- file.path(base, "small-pilot")
script <- "inst/validation/gmfrm-small-pilot-20261012.R"
manifest <- file.path(directory, "manifest.rds")
threads <- c("OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS", "VECLIB_MAXIMUM_THREADS")
check_hash <- function(h) stopifnot(length(h) > 0L, !anyNA(h), identical(h, tools::md5sum(names(h))))
write_result <- function(x, file) {
  saveRDS(x, paste0(file, ".tmp")); stopifnot(file.rename(paste0(file, ".tmp"), file))
}
m <- readRDS(file.path(base, "manifest.rds")); check_hash(m$inputs); check_hash(m$source)
stopifnot(identical(m$R, R.version), identical(m$threads, Sys.getenv(threads)),
  identical(m$packages, vapply(names(m$packages), function(p) as.character(packageVersion(p)), "")))
library(mfrmr, lib.loc = file.path(base, "library"))
stopifnot(identical(normalizePath(find.package("mfrmr")), normalizePath(file.path(base, "library/mfrmr"))))
fn <- function(n) get(n, asNamespace("mfrmr"))
load_definitions <- function(file, wanted) {
  loaded <- character()
  for (e in parse(file)) if (is.call(e) && identical(e[[1L]], as.name("<-")) &&
      is.symbol(e[[2L]]) && as.character(e[[2L]]) %in% wanted) {
    stopifnot(is.call(e[[3L]]), identical(e[[3L]][[1L]], as.name("function")))
    eval(e, envir = .GlobalEnv); loaded <- c(loaded, as.character(e[[2L]]))
  }
  stopifnot(identical(sort(loaded), sort(wanted)))
}
load_definitions(file.path(base, "source.R"),
  c("capture", "mapping", "setup", "coordinates", "evaluator", "minimize"))
ref <- new.env(parent = asNamespace("mfrmr"))
sys.source(file.path(base, "pattern-reference.R"), ref)
context <- function(case, data) {
  local <- new.env(parent = environment(setup)); local$m <- m
  local$m$cases[[case]]$specification$data <- data
  f <- setup; environment(f) <- local
  f(case)
}
contrast <- function(T) as.numeric(rownames(T) == "location:Task:t1") -
  as.numeric(rownames(T) == "location:Task:t2")

fit_one <- function(s, target, constrained, adaptive_only = FALSE) {
  co <- coordinates(s$T, constrained, target)
  starts <- list(zero = numeric(ncol(s$T)), cosine = .25 * cos(seq_len(ncol(s$T))))
  methods <- if (adaptive_only) c("adaptive61", "adaptive121") else c("fixed", "adaptive61", "adaptive121")
  attempts <- list()
  for (name in names(starts)) {
    stages <- list(); u <- drop(crossprod(co$U, starts[[name]] - co$origin))
    for (method in methods) {
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
  }
  candidates <- lapply(attempts, function(a) capture(function()
    evaluator(s$likelihood$adaptive121, s$T, co)$evaluate(a$u)))
  values <- vapply(candidates, function(x) if (is.null(x$error)) x$value$value else Inf, 0)
  selected <- if (any(is.finite(values))) names(which.min(values)) else NA_character_
  reference <- if (!is.na(selected)) capture(function() {
    state <- candidates[[selected]]$value
    independent <- ref$mfrm_gmfrm_reference_integrate(ref$mfrm_gmfrm_reference_design(s$specification, state$par))
    full <- -drop(crossprod(s$T, independent$score)) + m$controls$lambda * state$z
    list(reference = independent, state = state, gradient = drop(crossprod(co$U, full)),
      constraint_error = if (constrained) abs(sum(contrast(s$T) * state$par) - target) else 0,
      objective_error = abs(state$nll - independent$nll),
      gradient_error = max(abs(state$full_gradient - full)))
  }) else list(value = NULL, error = "No finite candidate", warnings = character(), seconds = 0)
  list(attempts = attempts, candidates = candidates, selected = selected, reference = reference)
}
summarize_fit <- function(x, setup_error = NULL) {
  if (!is.null(setup_error)) return(data.frame(Qualified = FALSE,
    Reasons = paste("Setup:", setup_error), Q = NA_real_, MaxGradient = NA_real_,
    NLLCheck = NA_real_, GradientCheck = NA_real_, StartValueSpread = NA_real_,
    StartCoordinateSpread = NA_real_, Errors = 1L, Warnings = 0L,
    FitSeconds = 0, ReviewSeconds = 0, ReferenceSeconds = 0, Evaluations = 0))
  r <- x$reference$value
  values <- vapply(x$candidates, function(a) if (is.null(a$error)) a$value$value else Inf, 0)
  zs <- lapply(x$candidates, function(a) if (is.null(a$error)) a$value$z else NA_real_)
  spread <- diff(range(values)); coordinate_spread <- max(abs(zs[[1L]] - zs[[2L]]))
  stages <- unlist(lapply(x$attempts, `[[`, "stages"), recursive = FALSE)
  fit <- stages[!grepl("_review$", names(stages))]
  reviews <- c(stages[grepl("_review$", names(stages))], x$candidates)
  records <- c(stages, x$candidates, list(x$reference))
  errors <- sum(vapply(records, function(v) !is.null(v$error), TRUE))
  warnings <- sum(vapply(records, function(v) length(v$warnings), 0L))
  checks <- c(NoErrors = errors == 0L, IndependentIntegral = !is.null(r) && isTRUE(r$reference$qualified),
    Constraint = !is.null(r) && r$constraint_error < 1e-10,
    NLLAgreement = !is.null(r) && r$objective_error <= m$controls$value_tolerance,
    GradientAgreement = !is.null(r) && r$gradient_error <= m$controls$integration_gradient_tolerance,
    Stationarity = !is.null(r) && max(abs(r$gradient)) <= m$controls$gradient_tolerance,
    StartObjective = isTRUE(spread <= m$controls$start_value_tolerance),
    StartCoordinates = isTRUE(coordinate_spread <= m$controls$start_coordinate_tolerance))
  data.frame(Qualified = all(checks), Reasons = paste(names(checks)[!checks], collapse = ";"),
    Q = if (is.null(r)) NA_real_ else r$reference$nll + m$controls$lambda * sum(r$state$z^2) / 2,
    MaxGradient = if (is.null(r)) NA_real_ else max(abs(r$gradient)),
    NLLCheck = if (is.null(r)) NA_real_ else r$objective_error,
    GradientCheck = if (is.null(r)) NA_real_ else r$gradient_error,
    StartValueSpread = spread, StartCoordinateSpread = coordinate_spread,
    Errors = errors, Warnings = warnings,
    FitSeconds = sum(vapply(fit, `[[`, 0, "seconds")),
    ReviewSeconds = sum(vapply(reviews, `[[`, 0, "seconds")), ReferenceSeconds = x$reference$seconds,
    Evaluations = sum(vapply(fit, function(v) if (is.null(v$value)) 0 else v$value$counts[1L], 0)))
}

if (action == "prepare") {
  stopifnot(!file.exists(manifest))
  retained <- readRDS(file.path(base, "replay.rds")); check_hash(retained$outputs)
  nonzero <- readRDS(file.path(base, "nonzero-nulls/replay.rds")); check_hash(nonzero$outputs)
  pattern <- readRDS(file.path(base, "pattern-check.rds")); check_hash(pattern$source)
  cells <- data.frame(Cell = c("N20-zero", "N20-plus", "N20-b19", "N60-zero", "N240-zero"),
    Case = c("N20-observed", "N20-observed", "N20-b19", "N60-observed", "N240-observed"),
    Target = c(0, 1, 0, 0, 0), B = c(11L, 11L, 11L, 11L, 3L), stringsAsFactors = FALSE)
  cells$NullFile <- file.path(base, paste0(cells$Case, "-null.rds"))
  cells$NullFile[2L] <- file.path(base, "nonzero-nulls/N20-observed-plus.rds")
  dir.create(directory, recursive = TRUE)
  frozen <- file.path(directory, c("source.R", "generator-source.R"))
  stopifnot(file.copy(script, frozen[1L]),
    file.copy("inst/validation/gmfrm-null-bootstrap-20261010.R", frozen[2L]))
  load_definitions(frozen[2L], c("indices", "literal_probability", "generate"))
  checks <- list()
  for (j in seq_len(nrow(cells))) {
    cell <- cells[j, ]; s <- setup(cell$Case)
    parent <- list(config = s$problem$common$config, prep = s$problem$common$prep,
      gmfrm = list(specification = s$specification))
    par <- readRDS(cell$NullFile)$reference$value$state$par
    theta <- seq(-3, 3, length.out = s$problem$n_person)
    literal <- literal_probability(parent, par, theta)
    p <- fn("expand_params")(par, s$problem$common$sizes, parent$config)
    idx <- indices(parent)
    eta <- theta[idx$person] + fn("compute_base_eta")(idx, p, parent$config)
    cumulative <- t(apply(p$steps_mat, 1L, function(x) c(0, cumsum(x))))
    working <- fn("category_prob_gpcm")(eta, cumulative, idx$step_idx, p$slopes, idx$slope_idx)
    error <- max(abs(literal - working))
    stopifnot(error < 1e-12, abs(sum(contrast(s$T) * par) - cell$Target) < 1e-10,
      all(is.finite(literal)), all(literal >= 0), max(abs(rowSums(literal) - 1)) < 1e-12)
    # Single-category input is refused by the existing common validator;
    # do not silently change that procedure or replace such generated draws.
    for (k in c(0L, s$specification$max_score)) {
      data <- s$specification$data; data[[s$specification$score]] <- k
      refusal <- capture(function() context(cell$Case, data))
      stopifnot(!is.null(refusal$error), grepl("at least two distinct", refusal$error),
        !summarize_fit(NULL, refusal$error)$Qualified,
        summarize_fit(NULL, refusal$error)$Errors == 1L)
    }
    # A missing interior category with two observed endpoints keeps the ladder.
    data <- s$specification$data
    data[[s$specification$score]] <- rep(c(0L, s$specification$max_score), length.out = nrow(data))
    probe <- context(cell$Case, data)
    stopifnot(identical(names(probe$problem$start), names(s$problem$start)),
      identical(probe$T, s$T), identical(probe$problem$common$idx$person, idx$person),
      all(probe$problem$common$idx$score_k == data[[s$specification$score]]),
      is.finite(probe$likelihood$fixed(par)$value))
    checks[[cell$Cell]] <- error
  }
  jobs <- do.call(rbind, lapply(seq_len(nrow(cells)), function(j)
    data.frame(Cell = cells$Cell[j], Replicate = seq_len(cells$B[j]), stringsAsFactors = FALSE)))
  jobs$Seed <- 2026101300L + seq_len(nrow(jobs))
  jobs$Job <- sprintf("job-%03d", seq_len(nrow(jobs)))
  jobs$Comparator <- jobs$Replicate == 1L & jobs$Cell %in% c("N20-zero", "N60-zero", "N240-zero")
  stopifnot(nrow(jobs) == 47L, sum(jobs$Comparator) == 3L, 1 - .8^11 > .9, 1 - .8^10 < .9)
  plan <- list(cells = cells, jobs = jobs, generation_checks = checks, controls = m$controls,
    inputs = tools::md5sum(unique(c(file.path(base, c("manifest.rds", "replay.rds", "nonzero-nulls/replay.rds", "pattern-check.rds")),
      names(m$inputs), names(retained$outputs), names(nonzero$outputs)))),
    source = c(tools::md5sum(c(frozen, file.path(base, "pattern-reference.R"))), m$source),
    R = R.version, threads = Sys.getenv(threads), rng_kind = RNGkind(), session = sessionInfo())
  write_result(plan, manifest)
  print(cells[, 1:4]); print(unlist(checks))
  cat("Frozen 47 draws, 94 primary fits and six same-data adaptive-only comparator fits.\n")
  quit(save = "no")
}
plan <- readRDS(manifest); check_hash(plan$inputs); check_hash(plan$source)
stopifnot(identical(plan$controls, m$controls), identical(plan$R, R.version),
  identical(plan$threads, Sys.getenv(threads)), identical(plan$rng_kind, RNGkind()),
  identical(unname(tools::md5sum(script)), unname(plan$source[1L])))
seal <- tools::md5sum(manifest)
load_definitions(file.path(directory, "generator-source.R"), c("indices", "literal_probability", "generate"))
if (action == "run") {
  for (i in seq_len(nrow(plan$jobs))) {
    job <- plan$jobs[i, ]; cell <- plan$cells[plan$cells$Cell == job$Cell, ]
    path <- file.path(directory, job$Job); dir.create(path, showWarnings = FALSE)
    input <- file.path(path, "input.rds")
    if (!file.exists(input)) {
      s <- setup(cell$Case); generating <- readRDS(cell$NullFile)$reference$value$state$par
      parent <- list(config = s$problem$common$config, prep = s$problem$common$prep,
        gmfrm = list(specification = s$specification))
      before <- if (exists(".Random.seed", .GlobalEnv)) get(".Random.seed", .GlobalEnv) else NULL
      draw <- generate(parent, generating, job$Seed)
      after <- if (exists(".Random.seed", .GlobalEnv)) get(".Random.seed", .GlobalEnv) else NULL
      stopifnot(identical(before, after))
      data <- s$specification$data; data[[s$specification$score]] <- draw$score
      write_result(list(manifest = seal, job = job, data = data, draw = draw,
        generating = generating, target = cell$Target), input)
    }
    x <- readRDS(input); stopifnot(identical(x$manifest, seal), identical(x$job, job))
    source <- tools::md5sum(input)
    strategies <- if (job$Comparator) c("primary", "adaptive-only") else "primary"
    needed <- unlist(lapply(strategies, function(a) paste(a, c("free", "null"), sep = "-")))
    if (all(file.exists(file.path(path, paste0(needed, ".rds"))))) next
    setup_result <- capture(function() context(cell$Case, x$data)); s <- setup_result$value
    if (is.null(setup_result$error)) stopifnot(identical(s$problem$common$idx$score_k, x$draw$score))
    for (strategy in strategies) for (kind in c("free", "null")) {
      file <- file.path(path, paste0(strategy, "-", kind, ".rds"))
      if (file.exists(file)) { stopifnot(identical(readRDS(file)$input, source)); next }
      fit <- if (is.null(setup_result$error))
        fit_one(s, cell$Target, kind == "null", strategy == "adaptive-only") else NULL
      answer <- list(manifest = seal, input = source, T = s$T, fit = fit,
        setup = setup_result[c("error", "warnings", "seconds")],
        summary = summarize_fit(fit, setup_result$error))
      write_result(answer, file)
      cat(job$Job, job$Cell, job$Replicate, strategy, kind, "qualified", answer$summary$Qualified,
        answer$summary$Reasons, "seconds", sum(answer$summary[c("FitSeconds", "ReviewSeconds", "ReferenceSeconds")]), "\n")
      flush.console()
    }
  }
  quit(save = "no")
}

# Fresh analysis cannot fill missing outcomes by generating or fitting.
blocked <- function(...) stop("No random generation, fitting or integration during pilot replay.")
for (n in c("rnorm", "runif", "rbinom", "optim", "nlminb", "integrate")) assignInNamespace(n, blocked, "stats")
rows <- list(); pairs <- list(); files <- character()
for (i in seq_len(nrow(plan$jobs))) {
  job <- plan$jobs[i, ]; path <- file.path(directory, job$Job)
  input <- file.path(path, "input.rds"); x <- readRDS(input); source <- tools::md5sum(input)
  stopifnot(identical(x$manifest, seal), identical(x$job, job)); files <- c(files, input)
  for (strategy in if (job$Comparator) c("primary", "adaptive-only") else "primary") {
    pair <- list()
    for (kind in c("free", "null")) {
      file <- file.path(path, paste0(strategy, "-", kind, ".rds")); y <- readRDS(file)
      stopifnot(identical(y$manifest, seal), identical(y$input, source),
        identical(y$summary, summarize_fit(y$fit, y$setup$error)))
      rows[[paste(job$Job, strategy, kind)]] <- cbind(job[c("Job", "Cell", "Replicate")], Strategy = strategy, Kind = kind, y$summary)
      files <- c(files, file); pair[[kind]] <- y
    }
    free <- pair$free; null <- pair$null
    statistic <- 2 * (null$summary$Q - free$summary$Q)
    qualified <- free$summary$Qualified && null$summary$Qualified && isTRUE(statistic >= -2*m$controls$value_tolerance)
    par <- free$fit$reference$value$state$par
    delta <- if (is.null(par)) NA_real_ else sum(contrast(free$T) * par) - x$target
    slopes <- grepl("^log_slope:", rownames(free$T))
    pairs[[paste(job$Job, strategy)]] <- data.frame(Job = job$Job, Cell = job$Cell,
      Replicate = job$Replicate, Strategy = strategy, Qualified = qualified, Statistic = statistic,
      TargetError = delta, LogSlopeRMSE = if (is.null(par)) NA_real_ else sqrt(mean((par[slopes]-x$generating[slopes])^2)))
  }
}
fits <- do.call(rbind, rows); pairs <- do.call(rbind, pairs)
primary <- subset(pairs, Strategy == "primary")
cell_summary <- do.call(rbind, lapply(seq_len(nrow(plan$cells)), function(j) {
  cell <- plan$cells[j, ]; p <- subset(primary, Cell == cell$Cell)
  f <- readRDS(file.path(base, paste0(cell$Case, "-free.rds")))$reference$value
  n <- readRDS(cell$NullFile)$reference$value
  observed <- 2*(n$reference$nll+sum(n$state$z^2)/2-f$reference$nll-sum(f$state$z^2)/2)
  a <- sum(p$Qualified & p$Statistic >= observed, na.rm = TRUE); u <- sum(!p$Qualified)
  B <- nrow(p); good <- p$TargetError[p$Qualified]
  cp <- c(if (a == 0L) 0 else qbeta(.025, a, B-a+1),
    if (a+u == B) 1 else qbeta(.975, a+u+1, B-a-u))
  timing <- subset(fits, Cell == cell$Cell & Strategy == "primary")
  data.frame(Cell = cell$Cell, B = B, PairsQualified = sum(p$Qualified), Exceed = a, Unresolved = u,
    TailLower = cp[1L], TailUpper = cp[2L], Bias = mean(good),
    BiasMCSE = sd(good)/sqrt(length(good)), RMSE = sqrt(mean(good^2)),
    FitSeconds = sum(timing$FitSeconds), ReviewSeconds = sum(timing$ReviewSeconds),
    ReferenceSeconds = sum(timing$ReferenceSeconds))
}))
stopifnot(nrow(fits) == 100L, nrow(primary) == 47L, all(cell_summary$B == plan$cells$B))
check_hash(plan$inputs); check_hash(plan$source)
write_result(list(manifest = seal, outputs = tools::md5sum(files), fits = fits, pairs = pairs,
  cells = cell_summary, session = sessionInfo()), file.path(directory, "summary.rds"))
print(cell_summary, digits = 5, row.names = FALSE)
print(subset(fits, !Qualified), row.names = FALSE)
cat("All planned draws and fits accounted; conditional pilot only, no outer coverage claim.\n")
