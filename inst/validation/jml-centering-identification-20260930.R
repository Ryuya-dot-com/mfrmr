# Bounded method decision using the existing finite response spaces.
# No simulated responses, population-root refits, public CI or order selection.
source("inst/validation/jml-design-adjustment-20260927.R")

jml_owner_conditional <- function(problem, beta) {
  cells <- expand.grid(Rater = 1:2, Criterion = 1:2)
  sr <- c(1, -1)[cells$Rater]; sc <- c(1, -1)[cells$Criterion]
  sa <- c(1, -1)[problem$own]; a <- exp(sa * beta[5])
  total <- vapply(problem$counts, function(z) z[, 2] + 2 * z[, 3], numeric(problem$n))
  middle <- vapply(problem$counts, function(z) z[, 2], numeric(problem$n))
  location <- sr * beta[1] + sc * beta[2]
  # h_beta(y) is the ability-free numerator, including count multiplicity.
  logh <- problem$log_multiplicity - drop(total %*% (a * location) +
    middle %*% (a * beta[2 + problem$own]))
  V <- cbind(drop(total %*% (a * sr)), drop(total %*% (a * sc)),
    drop(middle[, problem$own == 1, drop = FALSE] %*% a[problem$own == 1]),
    drop(middle[, problem$own == 2, drop = FALSE] %*% a[problem$own == 2]),
    drop(total %*% (sa * a * location) + middle %*% (sa * a * beta[2 + problem$own])))
  colnames(V) <- names(beta)
  probability <- log_probability <- numeric(problem$n)
  score <- V
  groups <- split(seq_len(problem$n), problem$keys)
  for (ix in groups) {
    shifted <- logh[ix] - max(logh[ix]); logp <- shifted - log(sum(exp(shifted)))
    probability[ix] <- exp(logp); log_probability[ix] <- logp
    score[ix, ] <- sweep(V[ix, , drop = FALSE], 2,
      drop(crossprod(probability[ix], V[ix, , drop = FALSE])))
  }
  list(probability = probability, log_probability = log_probability, score = score, groups = groups)
}

jml_centering_jacobian <- function(fn, beta, h) {
  vapply(seq_along(beta), function(j) {
    step <- numeric(length(beta)); step[j] <- h
    (fn(beta + step) - fn(beta - step)) / (2 * h)
  }, numeric(length(fn(beta))))
}

jml_growth_information <- function(problem, beta, theta) {
  cells <- expand.grid(Rater = 1:2, Criterion = 1:2)
  joint <- matrix(0, 6L, 6L)
  for (j in 1:4) {
    owner <- problem$own[j]; sa <- c(1, -1)[owner]
    sr <- c(1, -1)[cells$Rater[j]]; sc <- c(1, -1)[cells$Criterion[j]]
    a <- exp(sa * beta[5]); k <- 0:2
    z <- a * ((theta - sr * beta[1] - sc * beta[2]) * k - c(0, beta[2 + owner], 0))
    probability <- exp(z - max(z)); probability <- probability / sum(probability)
    D <- matrix(0, 3L, 6L)
    D[, 1:3] <- cbind(a * k, -sr * a * k, -sc * a * k)
    D[, 3 + owner] <- -a * c(0, 1, 0); D[, 6] <- sa * z
    centered <- sweep(D, 2, drop(crossprod(probability, D)))
    joint <- joint + problem$exposure[j] * crossprod(centered, probability * centered)
  }
  # Independently differentiate complete-pattern probabilities, including theta.
  numeric_score <- jml_centering_jacobian(function(x)
    -log(drop(problem$mass(x[-1], x[1]))), c(Theta = theta, beta), 1e-5)
  mass <- drop(problem$mass(beta, theta))
  independent <- crossprod(numeric_score, mass * numeric_score)
  stopifnot(max(abs(joint - independent)) < 1e-8, joint[1, 1] > 0)
  efficient <- joint[-1, -1] - tcrossprod(joint[-1, 1]) / joint[1, 1]
  list(efficient = efficient, derivative_error = max(abs(joint - independent)))
}

run_jml_centering_identification <- function(out) {
  stopifnot(!dir.exists(out))
  dir.create(out, recursive = TRUE)
  scope <- "validation-results/jml-scope-challenge-20260927"
  cases <- expand.grid(Owner = c("Criterion", "Rater"), Design = c("sparse", "unequal"),
    stringsAsFactors = FALSE)
  inputs <- c(file.path(scope, "contract.rds"), file.path(scope,
    paste0(apply(cases, 1, paste, collapse = "-"), "-2.rds")))
  sources <- paste0("inst/validation/", c("jml-centering-identification-20260930.R",
    "jml-design-adjustment-20260927.R", "jml-profile-bias-sample-20260927.R",
    "jml-profile-bias-exact-20260927.R"))
  hashes <- tools::md5sum(c(inputs, sources))
  contract <- readRDS(inputs[1]); results <- growth <- list()
  started <- proc.time()[["elapsed"]]
  for (i in seq_len(nrow(cases))) {
    id <- cases[i, ]; saved <- readRDS(inputs[i + 1L])
    design <- contract$designs[[id$Design]]
    problems <- lapply(design$exposure, function(e) make_jml_roster_problem(id$Owner, e))
    own_column <- match(id$Owner, names(saved$truth))
    other_column <- setdiff(1:2, own_column)
    pieces <- lapply(seq_along(problems), function(g)
      lapply(design$ability[[g]], function(theta) jml_growth_information(problems[[g]], saved$truth, theta)))
    efficient <- Reduce(`+`, lapply(seq_along(pieces), function(g)
      design$proportions[g] * Reduce(`+`, Map(function(z, w) w * z$efficient,
        pieces[[g]], c(.25, .5, .25)))))
    eig <- eigen(efficient, symmetric = TRUE)$values
    stopifnot(min(eig) > 1e-6)
    growth[[paste(id, collapse = "-")]] <- list(information = efficient,
      summary = data.frame(id, Rank = sum(eig > 1e-8 * max(eig)),
        MinimumEigenvalue = min(eig), MaximumEigenvalue = max(eig),
        DerivativeError = max(unlist(lapply(pieces, function(x)
          vapply(x, `[[`, 0, "derivative_error"))))))
    for (scenario in c("retained_truth", "zero_other_location")) {
      beta <- saved$truth
      if (scenario == "zero_other_location") beta[other_column] <- 0
      probabilities <- lapply(seq_along(problems), function(g)
        drop(problems[[g]]$mass(beta, design$ability[[g]]) %*% c(.25, .5, .25)))
      if (scenario == "retained_truth") stopifnot(max(abs(
        unlist(probabilities) - unlist(saved$weights))) < 1e-12)
      at <- lapply(problems, jml_owner_conditional, beta = beta)
      checks <- c()
      for (g in seq_along(problems)) {
        p <- problems[[g]]; z <- at[[g]]
        # Conditional masses must agree with the independent literal response model
        # at every checked ability, including abilities outside the saved mixture.
        mass <- p$mass(beta, c(-4, -2, 0, 2, 4))
        stopifnot(max(abs(colSums(mass) - 1)) < 1e-12)
        for (ix in z$groups) checks <- c(checks,
          max(abs(sweep(mass[ix, , drop = FALSE], 2,
            colSums(mass[ix, , drop = FALSE]), "/") - z$probability[ix])))
        checks <- c(checks, max(abs(crossprod(mass, z$score))))
        # Centering the profile score within owner totals gives the same score.
        raw <- p$evaluate(beta)$gradient
        for (ix in z$groups) raw[ix, ] <- sweep(raw[ix, , drop = FALSE], 2,
          drop(crossprod(z$probability[ix], raw[ix, , drop = FALSE])))
        checks <- c(checks, max(abs(raw - z$score)))
        h <- 1e-5
        numeric_score <- vapply(seq_along(beta), function(j) {
          step <- numeric(length(beta)); step[j] <- h
          -(jml_owner_conditional(p, beta + step)$log_probability -
            jml_owner_conditional(p, beta - step)$log_probability) / (2 * h)
        }, numeric(p$n))
        stopifnot(max(abs(numeric_score - z$score)) < 1e-8)
        shifted <- beta; shifted[own_column] <- shifted[own_column] + .2
        checks <- c(checks, max(abs(z$probability -
          jml_owner_conditional(p, shifted)$probability)), max(abs(z$score[, own_column])))
      }
      stopifnot(max(checks) < 1e-12)
      mean_score <- function(b) Reduce(`+`, lapply(seq_along(problems), function(g)
        design$proportions[g] * drop(crossprod(probabilities[[g]],
          jml_owner_conditional(problems[[g]], b)$score))))
      A <- jml_centering_jacobian(mean_score, beta, 1e-4)
      refined <- jml_centering_jacobian(mean_score, beta, 5e-5)
      B <- Reduce(`+`, lapply(seq_along(problems), function(g)
        design$proportions[g] * crossprod(at[[g]]$score, probabilities[[g]] * at[[g]]$score)))
      singular <- svd(B)$d
      rank <- sum(singular > 1e-8 * max(singular))
      # In these saved rosters Rater 1 never crosses Criteria within a Person.
      # Hence only Rater 2 identifies a Criterion-location times slope product.
      expected_rank <- if (scenario == "retained_truth" && id$Owner == "Criterion") 4L else 3L
      stopifnot(max(abs(mean_score(beta))) < 1e-12, rank == expected_rank,
        max(abs(refined - A)) < 1e-8, max(abs(refined - B)) < 1e-8)
      if (scenario == "zero_other_location" || id$Owner == "Rater") {
        # Changing alpha while inversely rescaling owner steps leaves the
        # conditional distribution unchanged when the other location is zero.
        shifted <- beta; shifted[5] <- shifted[5] + .2
        shifted[3:4] <- beta[3:4] * exp(c(-.2, .2))
        if (id$Owner == "Rater") shifted[other_column] <- beta[other_column] * exp(.2)
        stopifnot(max(abs(unlist(lapply(problems, function(p)
          jml_owner_conditional(p, shifted)$probability)) -
          unlist(lapply(at, `[[`, "probability")))) < 1e-12)
      }
      key <- paste(id$Owner, id$Design, scenario, sep = "-")
      results[[key]] <- list(beta = beta, jacobian = refined, information = B,
        singular_values = singular,
        summary = data.frame(id, Scenario = scenario, Rank = rank,
          MaximumCenteringError = max(checks), JacobianInformationError = max(abs(refined - B)),
          OwnerLocationScore = max(vapply(at, function(z) max(abs(z$score[, own_column])), 0)),
          SmallestPositiveSingular = singular[rank], LargestSingular = singular[1]))
    }
  }
  # A design-preserving half-panel split requires two equal integer cell rosters.
  # Evaluate this prerequisite on all existing rosters, before choosing a bias power.
  splitting <- do.call(rbind, lapply(names(contract$designs), function(d) {
    z <- contract$designs[[d]]
    do.call(rbind, lapply(seq_along(z$exposure), function(g) data.frame(
      Design = d, Roster = g, Ratings = sum(z$exposure[[g]]),
      Exposure = paste(z$exposure[[g]], collapse = ":"),
      ExactHalfSplit = all(z$exposure[[g]] %% 2 == 0))))
  }))
  stopifnot(all(vapply(split(splitting$ExactHalfSplit, splitting$Design),
    function(x) !all(x), TRUE)), identical(hashes, tools::md5sum(names(hashes))))
  summary <- do.call(rbind, lapply(results, `[[`, "summary"))
  saveRDS(list(results = results, growth = growth, splitting = splitting, hashes = hashes,
    elapsed = proc.time()[["elapsed"]] - started, session = capture.output(sessionInfo())),
    file.path(out, "results.rds"))
  write.csv(summary, file.path(out, "conditional-identification.csv"), row.names = FALSE)
  growth_summary <- do.call(rbind, lapply(growth, `[[`, "summary"))
  write.csv(growth_summary, file.path(out, "exposure-growth-information.csv"), row.names = FALSE)
  write.csv(splitting, file.path(out, "split-eligibility.csv"), row.names = FALSE)
  for (file in sources) {
    destination <- file.path(out, "source", file)
    dir.create(dirname(destination), recursive = TRUE, showWarnings = FALSE)
    stopifnot(file.copy(file, destination),
      unname(tools::md5sum(destination)) == unname(hashes[file]))
  }
  print(summary, row.names = FALSE); print(splitting, row.names = FALSE)
  print(growth_summary, row.names = FALSE)
  cat("Conditional centering, rank losses, independent derivatives, exposure information and split eligibility verified.\n")
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  stopifnot(length(args) == 1L)
  run_jml_centering_identification(args[1])
}
