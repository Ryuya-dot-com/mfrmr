# Local qualification under the active roadmap's prespecified robust-interval protocol.
# Rscript inst/validation/facet-sandwich-0.2.4.R targets <directory>
# Rscript inst/validation/facet-sandwich-0.2.4.R run <directory> 1,2
# Rscript inst/validation/facet-sandwich-0.2.4.R summary <directory>

sandwich_case <- function(model, adverse) {
  patterns <- if (adverse) list(cbind(1:3, c(1, 2, 1)), cbind(1:3, c(2, 1, 2))) else
    list(as.matrix(expand.grid(Rater = 1:3, Criterion = 1:2)))
  response <- as.matrix(expand.grid(rep(list(0:2), nrow(patterns[[1]]))))
  truth <- c(.3, -.1, .4, if (model == "RSM") -.6 else c(-.7, -.2))
  list(model = model, adverse = adverse, designs = patterns, responses = response, truth = truth)
}

# Independent adjacent-category probabilities; no package likelihood or derivative helper.
sandwich_pattern_logprob <- function(theta, par, case, design) {
  r <- c(par[1:2], -sum(par[1:2]))
  difficulty <- c(par[3], -par[3])
  steps <- if (case$model == "RSM") rep(par[4], 2) else par[4:5]
  out <- matrix(0, length(theta), nrow(case$responses))
  for (j in seq_len(nrow(design))) {
    eta <- theta - r[design[j, 1]] - difficulty[design[j, 2]]
    middle <- eta - steps[design[j, 2]]
    hi <- pmax(0, middle, 2 * eta)
    norm <- hi + log(exp(-hi) + exp(middle - hi) + exp(2 * eta - hi))
    out <- out + cbind(-norm, middle - norm, 2 * eta - norm)[, case$responses[, j] + 1, drop = FALSE]
  }
  out
}

sandwich_reference_prob <- function(case, design, tolerance) {
  vapply(seq_len(nrow(case$responses)), function(k) {
    one <- case; one$responses <- case$responses[k, , drop = FALSE]
    density <- function(z) {
      theta <- if (case$adverse) (exp(z) - exp(.5)) / sqrt(exp(1) * (exp(1) - 1)) else z
      as.vector(exp(sandwich_pattern_logprob(theta, case$truth, one, design))) * dnorm(z)
    }
    integrate(density, -9, 9, rel.tol = tolerance, abs.tol = tolerance * .001,
      subdivisions = 300L)$value
  }, numeric(1))
}

sandwich_reference_grid <- function(n) {
  j <- matrix(0, n, n)
  j[cbind(1:(n-1), 2:n)] <- j[cbind(2:n, 1:(n-1))] <- sqrt(1:(n-1))
  e <- eigen(j, symmetric = TRUE)
  weights <- e$vectors[1, ]^2
  keep <- weights > 0
  list(nodes = e$values[keep], weights = weights[keep])
}

sandwich_targets <- function(directory) {
  targets <- list()
  for (model in c("RSM", "PCM")) for (adverse in c(FALSE, TRUE)) {
    case <- sandwich_case(model, adverse)
    probs <- lapply(case$designs, function(d) sandwich_reference_prob(case, d, 1e-10))
    coarse <- lapply(case$designs, function(d) sandwich_reference_prob(case, d, 1e-8))
    stopifnot(max(abs(vapply(probs, sum, numeric(1)) - 1)) < 1e-8,
      max(abs(unlist(probs) - unlist(coarse))) < 1e-8)
    objective <- function(par, n) {
      grid <- sandwich_reference_grid(n)
      mean(vapply(seq_along(case$designs), function(k) {
        lp <- sandwich_pattern_logprob(grid$nodes, par, case, case$designs[[k]])
        hi <- apply(lp, 2, max)
        lm <- hi + log(colSums(exp(sweep(lp, 2, hi, "-")) * grid$weights))
        -sum(probs[[k]] * lm)
      }, numeric(1)))
    }
    q61 <- optim(case$truth, objective, n = 61, method = "BFGS", control = list(reltol = 1e-13, maxit = 500))
    q121 <- optim(q61$par, objective, n = 121, method = "BFGS", control = list(reltol = 1e-13, maxit = 500))
    stopifnot(q61$convergence == 0, q121$convergence == 0,
      max(abs(q61$par - q121$par)) < 1e-5)
    if (!adverse) stopifnot(max(abs(q121$par - case$truth)) < 1e-5)
    targets[[paste(model, adverse, sep = "_")]] <- list(case = case,
      probabilities = probs, pseudo = q121$par, q61 = q61$par,
      integration_difference = max(abs(unlist(probs) - unlist(coarse))))
  }
  saveRDS(targets, file.path(directory, "targets.rds"))
  table <- do.call(rbind, lapply(targets, function(z) data.frame(Model = z$case$model,
    Adverse = z$case$adverse, Parameter = seq_along(z$pseudo), Truth = z$case$truth,
    Pseudo = z$pseudo, Q61 = z$q61)))
  write.csv(table, file.path(directory, "targets.csv"), row.names = FALSE)
  print(table)
}

sandwich_generate <- function(case, n, seed) {
  set.seed(seed)
  theta <- rnorm(n)
  if (case$adverse) theta <- (exp(theta) - exp(.5)) / sqrt(exp(1) * (exp(1) - 1))
  designs <- if (case$adverse) sample.int(2, n, replace = TRUE) else rep(1L, n)
  d <- do.call(rbind, lapply(seq_len(n), function(i) data.frame(Person = sprintf("P%04d", i),
    Rater = case$designs[[designs[i]]][, 1], Criterion = case$designs[[designs[i]]][, 2], Theta = theta[i])))
  r <- c(.3, -.1, -.2); difficulty <- c(.4, -.4)
  steps <- if (case$model == "RSM") c(-.6, -.6) else c(-.7, -.2)
  eta <- d$Theta - r[d$Rater] - difficulty[d$Criterion]
  lp <- cbind(0, eta - steps[d$Criterion], 2 * eta)
  prob <- exp(lp - apply(lp, 1, max)); prob <- prob / rowSums(prob)
  draw <- runif(nrow(d))
  d$Score <- as.integer(draw > prob[, 1]) + as.integer(draw > rowSums(prob[, 1:2]))
  d$Rater <- paste0("R", d$Rater); d$Criterion <- paste0("C", d$Criterion)
  d$Theta <- NULL
  d
}

sandwich_cells <- function() {
  d <- expand.grid(Model = c("RSM", "PCM"), Persons = c(80L, 320L), Adverse = c(FALSE, TRUE),
    stringsAsFactors = FALSE)
  d$Cell <- seq_len(nrow(d)); d
}

sandwich_run <- function(directory, cells) {
  pkgload::load_all(".", quiet = TRUE)
  targets <- readRDS(file.path(directory, "targets.rds"))
  cases <- sandwich_cells()
  source_files <- c("R/api-facet-intervals.R", "inst/validation/facet-sandwich-0.2.4.R",
    "inst/validation/internal-roadmap-0.2.3.md", "R/mfrm_core.R")
  source_hashes <- tools::md5sum(source_files)
  for (cell in cells) {
    path <- file.path(directory, paste0("cell-", cell, ".rds"))
    if (file.exists(path)) stop("Refusing to replace an existing cell: ", cell)
    spec <- cases[cell, ]; target <- targets[[paste(spec$Model, spec$Adverse, sep = "_")]]
    map <- matrix(0, 4, length(target$pseudo)); map[1:3, 1:2] <- rbind(c(1,-1),c(2,1),c(1,2)); map[4,3] <- 2
    labels <- c("R1-R2", "R1-R3", "R2-R3", "C1-C2")
    truth <- drop(map %*% target$case$truth); pseudo <- drop(map %*% target$pseudo)
    runs <- vector("list", 200)
    for (i in seq_along(runs)) {
      seed <- 92230000L + 1000L * cell + i
      d <- sandwich_generate(target$case, spec$Persons, seed)
      warning_text <- character(); error_text <- ""
      estimate <- model_se <- robust_se <- rep(NA_real_, 4)
      available <- FALSE; started <- proc.time()[["elapsed"]]
      fit <- NULL
      tryCatch(withCallingHandlers({
        fit <- fit_mfrm(d, "Person", c("Rater", "Criterion"), "Score", model = spec$Model,
          step_facet = if (spec$Model == "PCM") "Criterion" else NULL,
          rating_min = 0, rating_max = 2, keep_original = TRUE, quad_points = 61,
          maxit = 400, reltol = 1e-10)
        estimate <- drop(map %*% fit$opt$par)
        result <- mfrm_facet_intervals(fit, "Rater", method = "sandwich")
        model_se <- sqrt(diag(map %*% result$model_parameter_covariance %*% t(map)))
        robust_se <- sqrt(diag(map %*% result$parameter_covariance %*% t(map)))
        available <- all(result$table$Status == "available") && all(is.finite(robust_se)) && all(robust_se > 0)
      }, warning = function(w) { warning_text <<- c(warning_text, conditionMessage(w)); invokeRestart("muffleWarning") }),
      error = function(e) { error_text <<- conditionMessage(e) })
      runs[[i]] <- data.frame(Cell = cell, Model = spec$Model, Persons = spec$Persons,
        Adverse = spec$Adverse, Replicate = i, Seed = seed, Target = labels,
        Truth = truth, Pseudo = pseudo, Estimate = estimate, ModelSE = model_se,
        SandwichSE = robust_se, Available = available, Error = error_text,
        Warnings = paste(unique(warning_text), collapse = " | "),
        Seconds = proc.time()[["elapsed"]] - started)
      if (nzchar(error_text)) saveRDS(list(data = d, fit = fit, error = error_text),
        file.path(directory, paste0("failure-", cell, "-", i, ".rds")))
      if (i %% 25 == 0) cat("Cell", cell, "completed", i, "of", length(runs), "\n")
    }
    saveRDS(list(spec = spec, rows = do.call(rbind, runs), source = source_hashes,
      session = sessionInfo()), path)
  }
}

sandwich_summary <- function(directory) {
  rows <- do.call(rbind, lapply(1:8, function(i) readRDS(file.path(directory, paste0("cell-", i, ".rds")))$rows))
  stopifnot(nrow(rows) == 8 * 200 * 4, !anyDuplicated(rows[c("Cell", "Replicate", "Target")]))
  summarize <- function(d) {
    available <- d$Available & is.finite(d$ModelSE) & is.finite(d$SandwichSE)
    a <- d[available, ]; n <- nrow(a)
    do.call(rbind, lapply(c("Truth", "Pseudo"), function(target) {
      do.call(rbind, lapply(c("Model", "Sandwich"), function(method) {
        se <- a[[paste0(method, "SE")]]
        covered <- abs(a$Estimate - a[[target]]) <= qnorm(.975) * se
        interval <- if (n) binom.test(sum(covered), n)$conf.int else c(NA, NA)
        data.frame(Cell = d$Cell[1], Model = d$Model[1], Persons = d$Persons[1], Adverse = d$Adverse[1],
          Target = d$Target[1], Reference = target, Method = method, Assigned = nrow(d), Available = n,
          Coverage = if (n) mean(covered) else NA_real_, MCLower = interval[1], MCUpper = interval[2],
          JointAvailableCovered = sum(covered) / nrow(d), Width = mean(2 * qnorm(.975) * se),
          Bias = mean(a$Estimate - a[[target]]), EmpiricalSD = sd(a$Estimate), MeanSE = mean(se))
      }))
    }))
  }
  tables <- do.call(rbind, lapply(split(rows, interaction(rows$Cell, rows$Target, drop = TRUE)), summarize))
  paired <- do.call(rbind, lapply(split(rows, interaction(rows$Cell, rows$Target, drop = TRUE)), function(d) {
    a <- d[d$Available, ]
    do.call(rbind, lapply(c("Truth", "Pseudo"), function(target) {
      diff <- as.integer(abs(a$Estimate - a[[target]]) <= qnorm(.975) * a$SandwichSE) -
        as.integer(abs(a$Estimate - a[[target]]) <= qnorm(.975) * a$ModelSE)
      data.frame(Cell = d$Cell[1], Target = d$Target[1], Reference = target, Paired = nrow(a),
        CoverageDifference = mean(diff), MCSE = sd(diff) / sqrt(length(diff)))
    }))
  }))
  write.csv(rows, file.path(directory, "replications.csv"), row.names = FALSE)
  write.csv(tables, file.path(directory, "coverage.csv"), row.names = FALSE)
  write.csv(paired, file.path(directory, "paired-coverage.csv"), row.names = FALSE)
  print(aggregate(Available ~ Cell, rows[rows$Target == "R1-R2", ], sum))
  print(aggregate(Coverage ~ Adverse + Reference + Method, tables, range))
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE); stopifnot(length(args) >= 2)
  dir.create(args[2], recursive = TRUE, showWarnings = FALSE)
  switch(args[1], targets = sandwich_targets(args[2]),
    run = sandwich_run(args[2], as.integer(strsplit(args[3], ",", fixed = TRUE)[[1]])),
    summary = sandwich_summary(args[2]), stop("Unknown action"))
}
