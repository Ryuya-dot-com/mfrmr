# Saved-point diagnosis only. No package evaluator, fitting or RNG calls.
# From package root: Rscript --vanilla this-file prepare | run | summarize
seg_script <- "inst/validation/gmfrm-segmented-reference-20261011.R"
seg_out <- "validation-results/gmfrm-segmented-reference-20261011"
seg_old <- "validation-results/gmfrm-null-bootstrap-20261010"
seg_hash_check <- function(x) stopifnot(length(x) > 0L, !anyNA(x),
  identical(x, tools::md5sum(names(x))))

# Golub--Welsch Legendre rule, normalized for integration on [0,1].
seg_rule <- function(n) {
  b <- seq_len(n - 1L) / sqrt(4 * seq_len(n - 1L)^2 - 1)
  J <- matrix(0, n, n); J[cbind(1:(n-1L), 2:n)] <- b
  e <- eigen(J + t(J), symmetric = TRUE)
  o <- order(e$values)
  list(nodes = (e$values[o] + 1)/2, weights = e$vectors[1, o]^2)
}

seg_design <- function(fit, par, score = NULL) {
  s <- fit$gmfrm$specification; d <- s$data; owners <- s$slope_facets
  if (!is.null(score)) d[[s$score]] <- score
  stopifnot(identical(owners, c("Task", "Rater")), s$max_score == 2,
    all(fit$config$facet_signs == -1), all(fit$prep$data$Weight == 1),
    !isTRUE(fit$config$population_spec$active))
  lev <- lapply(d[c(s$person, owners)], function(x) sort(unique(as.character(x))))
  id <- Map(function(x, l) match(as.character(x), l), d[names(lev)], lev)
  ni <- length(lev[[2]]); nr <- length(lev[[3]])
  stopifnot(identical(lev[[2]], as.character(fit$config$facet_levels[[owners[1]]])),
    identical(lev[[3]], as.character(fit$config$facet_levels[[owners[2]]])))
  Z <- cbind(rbind(diag(ni-1L), rep(-1, ni-1L))[id[[2]], , drop = FALSE],
    diag(nr)[id[[3]], , drop = FALSE])
  ng <- ncol(Z); nb <- ng + nr
  D <- lapply(0:2, function(k) cbind(k*Z,
    if (k == 1L) diag(nr)[id[[3]], , drop = FALSE] else matrix(0, nrow(d), nr)))
  stopifnot(length(par) == nb+ng, all(is.finite(par)))
  offset <- vapply(D, function(x) drop(x %*% par[seq_len(nb)]), numeric(nrow(d)))
  a <- exp(drop(Z %*% par[nb + seq_len(ng)]))
  stopifnot(all(is.finite(a)), all(a > 0))
  list(Z = Z, D = D, offset = offset, a = a, ng = ng, nb = nb,
    score = d[[s$score]], groups = split(seq_len(nrow(d)), id[[1]]), par = par)
}

seg_person <- function(model, rows) {
  a <- model$a[rows]; z <- model$Z[rows, , drop = FALSE]
  off <- model$offset[rows, , drop = FALSE]; y <- model$score[rows]
  design <- lapply(model$D, function(x) x[rows, , drop = FALSE])
  nb <- model$nb; ng <- model$ng; p <- nb+ng
  delta <- lapply(seq_along(rows), function(j)
    t(vapply(design, function(x) design[[y[j]+1L]][j, ] - x[j, ], numeric(nb))))
  # |complete score_j(theta)| <= c0_j + c1_j |theta|.
  c0 <- c1 <- numeric(p)
  for (j in seq_along(rows)) {
    c0[seq_len(nb)] <- c0[seq_len(nb)] + a[j]*apply(abs(delta[[j]]), 2, max)
    c0[nb+seq_len(ng)] <- c0[nb+seq_len(ng)] +
      a[j]*max(abs(off[j, y[j]+1L] - off[j, ]))*abs(z[j, ])
    c1[nb+seq_len(ng)] <- c1[nb+seq_len(ng)] +
      a[j]*max(abs(y[j] - 0:2))*abs(z[j, ])
  }
  kernel <- function(theta, scores = FALSE) {
    n <- length(theta); lj <- dnorm(theta, log = TRUE); ts <- -theta
    U <- if (scores) matrix(0, n, p) else NULL
    for (j in seq_along(rows)) {
      logits <- a[j]*(outer(theta, 0:2) - matrix(off[j, ], n, 3, byrow = TRUE))
      high <- pmax(logits[, 1], logits[, 2], logits[, 3])
      lp <- logits - high; lp <- lp - log(rowSums(exp(lp)))
      pr <- exp(lp); lj <- lj + lp[, y[j]+1L]
      # Sum p_k (y-k), rather than y-E(k), retains tiny tail residuals.
      residual <- drop(pr %*% (y[j] - 0:2))
      ts <- ts + a[j]*residual
      if (scores) {
        U[, seq_len(nb)] <- U[, seq_len(nb), drop = FALSE] - a[j]*(pr %*% delta[[j]])
        log_residual <- a[j]*(theta*residual -
          drop(pr %*% (off[j, y[j]+1L] - off[j, ])))
        U[, nb+seq_len(ng)] <- U[, nb+seq_len(ng), drop = FALSE] + outer(log_residual, z[j, ])
      }
    }
    list(logjoint = lj, theta_score = ts, score = U)
  }
  left <- -1; right <- 1
  while (kernel(left)$theta_score < 0) left <- left*2
  while (kernel(right)$theta_score > 0) right <- right*2
  mode <- uniroot(function(x) kernel(x)$theta_score, c(left, right), tol = 1e-14)$root
  peak <- kernel(mode)$logjoint
  drops <- c(.5, 2, 8, 32, 64)
  # Strong log concavity guarantees that sqrt(2*drop) brackets each crossing.
  bounds <- vapply(c(-1, 1), function(sign) vapply(drops, function(drop) {
    interval <- sort(c(mode, mode + sign*(sqrt(2*drop) + 1)))
    uniroot(function(x) kernel(x)$logjoint - peak + drop, interval, tol = 1e-14)$root
  }, 0), numeric(length(drops)))
  lower <- bounds[length(drops), 1]; upper <- bounds[length(drops), 2]
  cuts <- c(mode, bounds)
  for (j in seq_along(rows)) for (k in 1:2) for (l in 0:(k-1L)) {
    crossing <- (off[j, k+1L] - off[j, l+1L])/(k-l)
    width <- 1/(a[j]*(k-l))
    cuts <- c(cuts, crossing + c(-40, -16, -4, -1, 0, 1, 4, 16, 40)*width)
  }
  cuts <- sort(unique(c(lower, cuts[cuts > lower & cuts < upper], upper)))
  # Concavity gives f(b +/- t) <= f(b)-s*t. Integrate this envelope,
  # including |theta| <= |b|+t, to bound both normalizer and score tails.
  tail_mass <- 0; tail_score <- numeric(p)
  for (side in c(-1, 1)) {
    b <- if (side < 0) lower else upper; at <- kernel(b)
    s <- -side*at$theta_score; h <- exp(at$logjoint - peak)
    stopifnot(is.finite(s), s > 0)
    tail_mass <- tail_mass + h/s
    tail_score <- tail_score + h*((c0 + c1*abs(b))/s + c1/s^2)
  }
  list(kernel = kernel, cuts = cuts, peak = peak, mode = mode,
    tail_mass = tail_mass, tail_score = tail_score)
}

seg_integral <- function(person, rule, scores) {
  lo <- head(person$cuts, -1); width <- diff(person$cuts)
  theta <- as.vector(outer(rule$nodes, width) + rep(lo, each = length(rule$nodes)))
  w <- as.vector(outer(rule$weights, width))
  value <- person$kernel(theta, scores)
  w <- w*exp(value$logjoint - person$peak)
  mass <- sum(w); stopifnot(is.finite(mass), mass > 0)
  list(mass = mass, log_marginal = person$peak + log(mass),
    score = if (scores) colSums(w*value$score)/mass else NULL)
}

seg_reference <- function(model, full = TRUE) {
  rules <- lapply(c(32L, 64L), seg_rule)
  people <- lapply(model$groups, function(rows) {
    p <- seg_person(model, rows); high <- seg_integral(p, rules[[2]], full)
    if (!full) return(list(log_marginal = high$log_marginal))
    low <- seg_integral(p, rules[[1]], TRUE)
    lo <- head(p$cuts, -1); width <- diff(p$cuts)
    gk <- lapply(seq_along(lo), function(j) integrate(function(t)
      width[j]*exp(p$kernel(lo[j]+width[j]*t)$logjoint - p$peak), 0, 1,
      rel.tol = 1e-10, abs.tol = 1e-12/length(lo), subdivisions = 1000L))
    stopifnot(all(vapply(gk, function(x) x$message == "OK", TRUE)))
    mass <- sum(vapply(gk, `[[`, 0, "value"))
    list(log_marginal = high$log_marginal, score = high$score,
      low_score = low$score, low_log_marginal = low$log_marginal,
      gk_log_marginal = p$peak + log(mass),
      gk_relative_error = sum(vapply(gk, `[[`, 0, "abs.error"))/mass,
      tail_log_bound = log1p(p$tail_mass/high$mass),
      tail_score_bound = (p$tail_score + abs(high$score)*p$tail_mass)/high$mass,
      mode = p$mode, segments = length(lo))
  })
  nll <- -sum(vapply(people, `[[`, 0, "log_marginal"))
  if (!full) return(nll)
  score <- Reduce(`+`, lapply(people, `[[`, "score"))
  low_score <- Reduce(`+`, lapply(people, `[[`, "low_score"))
  checks <- c(NLLRuleDifference = abs(nll + sum(vapply(people, `[[`, 0, "low_log_marginal"))),
    NLLGKDifference = abs(nll + sum(vapply(people, `[[`, 0, "gk_log_marginal"))),
    ScoreRuleDifference = max(abs(score - low_score)),
    GKEstimatedRelativeError = sum(vapply(people, `[[`, 0, "gk_relative_error")),
    TailNLLBound = sum(vapply(people, `[[`, 0, "tail_log_bound")),
    TailScoreBound = max(Reduce(`+`, lapply(people, `[[`, "tail_score_bound"))))
  qualified <- all(is.finite(checks)) &&
    all(checks[1:2] <= 1e-7) && checks[3] <= 1e-6 &&
    all(checks[4:5] <= 1e-8) && checks[6] <= 1e-7
  list(nll = nll, score = score, checks = checks, qualified = unname(qualified), people = people)
}

seg_parent <- function(path) {
  x <- readRDS(path); if (inherits(x, "mfrm_fit")) x else x$payload$value
}
seg_load <- function(row, plan) {
  fit <- seg_parent(plan$Path[match(row$Case, plan$Case)])
  attempt <- readRDS(row$Path)$value
  score <- if (row$Draw != "observed") readRDS(file.path(seg_old, row$Case,
    paste0(row$Draw, "-generation.rds")))$value$score else NULL
  list(fit = fit, score = score, attempt = attempt,
    model = seg_design(fit, attempt$parameters, score))
}

seg_main <- function(args) {
  stopifnot(length(args) == 1, args %in% c("prepare", "run", "summarize"))
  path <- file.path(seg_out, "manifest.rds")
  if (args == "prepare") {
    stopifnot(!file.exists(path))
    old <- readRDS(file.path(seg_old, "manifest.rds"))
    seg_hash_check(old$inputs); seg_hash_check(old$sources)
    jobs <- do.call(rbind, lapply(old$plan$Case, function(case)
      expand.grid(Case = case, Draw = if (case == "N20") c("observed", sprintf("b%02d", 1:19)) else "observed",
        Kind = c("free", "null"), Start = c("retained", "neutral"), stringsAsFactors = FALSE)))
    jobs$Key <- with(jobs, paste(Case, Draw, Kind, Start, sep = "-"))
    jobs$Path <- with(jobs, file.path(seg_old, Case, paste0(Draw, "-", Kind, "-", Start, ".rds")))
    jobs$MaxSlope <- vapply(seq_len(nrow(jobs)), function(i) max(seg_load(jobs[i, ], old$plan)$model$a), 0)
    candidates <- which(jobs$Case == "N20" & jobs$Draw != "observed" & jobs$Kind == "free")
    fd <- candidates[c(which.min(jobs$MaxSlope[candidates]), which.max(jobs$MaxSlope[candidates]))]
    inputs <- tools::md5sum(c(old$plan$Path, list.files(seg_old, recursive = TRUE,
      full.names = TRUE, pattern = "[.]rds$")))
    dir.create(seg_out, recursive = TRUE, showWarnings = FALSE)
    saveRDS(list(plan = old$plan, jobs = jobs, finite_difference_jobs = jobs$Key[fd],
      inputs = inputs, sources = tools::md5sum(seg_script), session = sessionInfo(),
      contract = "gmfrm-mml-em-20260927.md: October 11 saved-point integration diagnosis"), path)
    cat("Bound", nrow(jobs), "saved vectors; derivative checks:", jobs$Key[fd], "\n")
    return(invisible(NULL))
  }
  m <- readRDS(path); seg_hash_check(m$inputs); seg_hash_check(m$sources)
  stopifnot(identical(R.version.string, m$session$R.version$version.string))
  seal <- tools::md5sum(path)
  phase <- function(key, calculate) {
    dest <- file.path(seg_out, paste0(key, ".rds"))
    if (file.exists(dest)) {
      x <- readRDS(dest); stopifnot(identical(x$manifest, seal)); return(x)
    }
    error <- ""; warnings <- character(); value <- NULL
    elapsed <- system.time(withCallingHandlers(tryCatch(value <- calculate(),
      error = function(e) error <<- conditionMessage(e)), warning = function(w) {
        warnings <<- c(warnings, conditionMessage(w)); invokeRestart("muffleWarning") }))
    x <- list(manifest = seal, value = value, error = error, warnings = unique(warnings),
      seconds = unname(elapsed["elapsed"]))
    temp <- paste0(dest, ".tmp"); saveRDS(x, temp); stopifnot(file.rename(temp, dest))
    cat(key, if (nzchar(error)) error else "saved", x$seconds, "seconds\n"); flush.console()
    x
  }
  if (args == "run") {
    for (i in seq_len(nrow(m$jobs))) {
      row <- m$jobs[i, ]; x <- seg_load(row, m$plan)
      phase(row$Key, function() seg_reference(x$model))
    }
    for (key in m$finite_difference_jobs) {
      row <- m$jobs[m$jobs$Key == key, ]; x <- seg_load(row, m$plan)
      p <- x$attempt$parameters; nb <- x$model$nb; ng <- x$model$ng
      blocks <- list(location = seq_len(ng), step = (ng+1L):nb, slope = nb+seq_len(ng), dense = seq_along(p))
      for (block in names(blocks)) for (h in c(1e-4, 2.5e-5, 6.25e-6)) {
        direction <- numeric(length(p)); ids <- blocks[[block]]
        direction[ids] <- rep(c(1, -1), length.out = length(ids))/sqrt(length(ids))
        phase(paste("fd", key, block, format(h, scientific = TRUE), sep = "-"), function() {
          plus <- seg_reference(seg_design(x$fit, p+h*direction, x$score), FALSE)
          minus <- seg_reference(seg_design(x$fit, p-h*direction, x$score), FALSE)
          base <- readRDS(file.path(seg_out, paste0(key, ".rds")))$value
          data.frame(Key = key, Block = block, Step = h, Derivative = (plus-minus)/(2*h),
            Analytic = -sum(base$score*direction), Error = abs((plus-minus)/(2*h)+sum(base$score*direction)))
        })
      }
    }
    seg_hash_check(m$inputs)
    return(invisible(NULL))
  }
  rows <- lapply(seq_len(nrow(m$jobs)), function(i) {
    row <- m$jobs[i, ]; file <- file.path(seg_out, paste0(row$Key, ".rds"))
    x <- readRDS(file); stopifnot(identical(x$manifest, seal))
    base <- seg_load(row, m$plan)
    old <- readRDS(sub("[.]rds$", "-reference.rds", row$Path))$value
    r <- x$value; score <- if (is.null(r)) NA_real_ else r$score
    oldscore <- colSums(old$reference$scores)
    if (row$Kind == "null") {
      # Frozen target Task t1 is the first free log-slope coordinate.
      score <- score[-(base$model$nb+1L)]; oldscore <- oldscore[-(base$model$nb+1L)]
    }
    data.frame(row[c("Case", "Draw", "Kind", "Start", "Key", "MaxSlope")],
      Qualified = isTRUE(r$qualified), Error = x$error, Seconds = x$seconds,
      NLL = if (is.null(r)) NA_real_ else r$nll,
      NativeDifference = if (is.null(r)) NA_real_ else abs(r$nll-base$attempt$check$NLL),
      OldContinuousDifference = if (is.null(r)) NA_real_ else abs(r$nll-old$reference$continuous_nll),
      GH121Difference = if (is.null(r)) NA_real_ else abs(r$nll+sum(old$reference$log_marginal)),
      Score = if (!length(score)) NA_real_ else max(abs(score)),
      GHScoreDifference = if (is.null(r)) NA_real_ else max(abs(score-oldscore)),
      if (!is.null(r)) as.data.frame(as.list(r$checks)) else
        as.data.frame(as.list(setNames(rep(NA_real_, 6), c("NLLRuleDifference", "NLLGKDifference",
          "ScoreRuleDifference", "GKEstimatedRelativeError", "TailNLLBound", "TailScoreBound")))))
  })
  table <- do.call(rbind, rows)
  fd_files <- list.files(seg_out, pattern = "^fd-.*[.]rds$", full.names = TRUE)
  fd_results <- lapply(fd_files, readRDS)
  fd <- do.call(rbind, lapply(fd_results, `[[`, "value"))
  write.csv(table, file.path(seg_out, "points.csv"), row.names = FALSE)
  write.csv(fd, file.path(seg_out, "derivatives.csv"), row.names = FALSE)
  saveRDS(list(points = table, derivatives = fd, derivative_errors =
    vapply(fd_results, `[[`, "", "error"), inputs = m$inputs,
    result_hashes = tools::md5sum(c(file.path(seg_out, paste0(m$jobs$Key, ".rds")), fd_files))),
    file.path(seg_out, "summary.rds"))
  print(aggregate(cbind(Qualified, Seconds) ~ Case, table, sum))
  print(aggregate(cbind(NativeDifference, OldContinuousDifference, GH121Difference, Score,
    NLLRuleDifference, NLLGKDifference, ScoreRuleDifference) ~ Case, table, max))
  print(fd, row.names = FALSE)
}
if (sys.nframe() == 0L) seg_main(commandArgs(trailingOnly = TRUE))
