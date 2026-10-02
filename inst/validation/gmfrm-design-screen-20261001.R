# Repository-only scenario generator and no-fit preflight, not a study runner.
# Rscript inst/validation/gmfrm-design-screen-20261001.R check OUTPUT
gmfrm_design_template <- "validation-results/gmfrm-practitioner-20260930/sirt-data.ratings1.rds"

gmfrm_design_plan <- function() {
  core <- expand.grid(Persons = c(120L, 240L, 480L), AbilitySD = c(.5, 1),
    Roster = c("common_persons", "rotating_pairs"), stringsAsFactors = FALSE)
  core$Scenario <- sprintf("core-n%d-s%s-%s", core$Persons, core$AbilitySD, core$Roster)
  core$Tasks <- 3L; core$Raters <- 6L; core$Maximum <- 2L
  core$Perturbation <- "none"; core$Block <- "core"
  core$Retained <- core$Persons == 240L
  extra <- data.frame(
    Scenario = c("small-common", "small-rotating", "wide-common", "wide-rotating",
      "six-tasks", "twelve-raters", "unequal-exposure", "weak-bridge",
      "weak-rater-slope", "rare-top-category", "writing-original", "writing-redistributed"),
    Persons = c(60L, 60L, rep(240L, 8), 135L, 135L),
    AbilitySD = c(1, 1, 1.5, 1.5, rep(1, 8)),
    Roster = c("common_persons", "rotating_pairs", "common_persons", "rotating_pairs",
      "rotating_pairs", "rotating_pairs", "unequal", "weak_bridge",
      "rotating_pairs", "rotating_pairs", "writing_original", "writing_redistributed"),
    Tasks = c(rep(3L, 4), 6L, rep(3L, 5), 5L, 5L),
    Raters = c(rep(6L, 5), 12L, rep(6L, 4), 7L, 7L),
    Maximum = c(rep(2L, 10), 3L, 3L),
    Perturbation = c(rep("none", 8), "weak_slope", "rare_top", "none", "none"),
    Block = "targeted", Retained = FALSE, stringsAsFactors = FALSE)
  plan <- rbind(core, extra[names(core)])
  plan$SeedGroup <- seq_len(nrow(plan))
  # Same latent Persons and potential responses for the two writing rosters.
  plan$SeedGroup[24L] <- plan$SeedGroup[23L]
  plan$ScreenRepetitions <- 100L
  plan$NewFits <- ifelse(plan$Retained, 0L, plan$ScreenRepetitions)
  plan
}

gmfrm_design_roster <- function(s) {
  n <- s$Persons; r <- s$Raters
  roster <- matrix(FALSE, n, r)
  if (s$Roster == "common_persons") {
    bridges <- n / 5L; single <- n - bridges
    stopifnot(bridges == as.integer(bridges), single %% r == 0L)
    ix <- sample.int(n)
    roster[ix[seq_len(bridges)], ] <- TRUE
    roster[cbind(ix[seq.int(bridges + 1L, n)], rep(seq_len(r), each = single / r))] <- TRUE
  } else if (s$Roster %in% c("rotating_pairs", "unequal")) {
    sizes <- if (s$Roster == "unequal") c(70L, 50L, 40L, 30L, 20L, 30L) else rep(n / r, r)
    stopifnot(length(sizes) == r, sum(sizes) == n, all(sizes == as.integer(sizes)))
    panel <- rep(seq_len(r), sizes); ix <- sample.int(n)
    roster[cbind(ix, panel)] <- TRUE
    roster[cbind(ix, panel %% r + 1L)] <- TRUE
  } else if (s$Roster == "weak_bridge") {
    stopifnot(n == 240L, r == 6L)
    roster[1:6, ] <- TRUE
    for (g in 0:1) {
      pairs <- rep(1:3, each = 35L); rows <- 7L + 117L * g + 0:104
      roster[cbind(rows, pairs + 3L * g)] <- TRUE
      roster[cbind(rows, pairs %% 3L + 1L + 3L * g)] <- TRUE
      roster[cbind(112L + 117L * g + 0:11, rep(1:3, each = 4L) + 3L * g)] <- TRUE
    }
    roster <- roster[sample.int(n), , drop = FALSE]
  } else if (s$Roster %in% c("writing_original", "writing_redistributed")) {
    stopifnot(unname(tools::md5sum(gmfrm_design_template)) == "45cdfdc65f8ab0c5c86878fa043bdf0b")
    d <- readRDS(gmfrm_design_template)
    stopifnot(!anyDuplicated(d[c("idstud", "rater")]))
    person <- match(d$idstud, sort(unique(d$idstud)))
    rater <- match(as.character(d$rater), sort(unique(as.character(d$rater))))
    stopifnot(max(person) == n, max(rater) == r)
    roster[cbind(person, rater)] <- TRUE
    if (s$Roster == "writing_redistributed") {
      remaining <- colSums(roster); roster[,] <- FALSE
      # Bipartite degree construction: 4 Persons x 3, 131 x 2; exact rater totals.
      degree <- c(rep(3L, 4L), rep(2L, 131L)); ix <- sample.int(n)
      for (i in seq_len(n)) {
        columns <- order(-remaining, seq_len(r))[seq_len(degree[i])]
        stopifnot(all(remaining[columns] > 0L))
        roster[ix[i], columns] <- TRUE
        remaining[columns] <- remaining[columns] - 1L
      }
      stopifnot(all(remaining == 0L))
    }
  } else stop("Unknown roster")
  stopifnot(all(rowSums(roster) > 0L), all(colSums(roster) > 0L))
  roster
}

gmfrm_design_parameters <- function(s) {
  # Six-task/twelve-rater contrasts duplicate the original parameter values,
  # adding levels without changing the distribution of generating parameters.
  task_location <- if (s$Tasks %in% c(3L, 6L)) rep(c(-.4, .1, .3), s$Tasks / 3L) else
    seq(-.4, .4, length.out = s$Tasks)
  task_slope <- if (s$Tasks %in% c(3L, 6L)) rep(exp(c(-.2, 0, .2)), s$Tasks / 3L) else
    exp(seq(-.2, .2, length.out = s$Tasks))
  repeat_raters <- function(low, high) if (s$Raters == 12L) rep(seq(low, high, length.out = 6L), 2L) else
    seq(low, high, length.out = s$Raters)
  rater_location <- repeat_raters(-.3, .3)
  rater_slope <- repeat_raters(.75, 1.25)
  if (s$Perturbation == "weak_slope") rater_slope[4L] <- .2
  if (s$Perturbation == "rare_top") rater_location <- rater_location + 2.5
  steps <- outer(repeat_raters(.45, .7), seq(-1, 1, length.out = s$Maximum))
  list(task_location = task_location, rater_location = rater_location,
    task_slope = task_slope, rater_slope = rater_slope, steps = steps)
}

gmfrm_design_probability <- function(theta, task, rater, p) {
  # Literal adjacent-category recursion; does not call the fitted probability kernel.
  a <- p$task_slope[task] * p$rater_slope[rater]
  eta <- theta - p$task_location[task] - p$rater_location[rater]
  logits <- matrix(0, length(theta), ncol(p$steps) + 1L)
  for (k in seq_len(ncol(p$steps))) logits[, k + 1L] <- logits[, k] + a * (eta - p$steps[rater, k])
  probability <- exp(logits - apply(logits, 1L, max))
  probability / rowSums(probability)
}

gmfrm_design_data <- function(s, id) {
  stopifnot(nrow(s) == 1L, id %in% seq_len(s$ScreenRepetitions))
  seed <- 93100000L + 1000L * s$SeedGroup + id
  set.seed(seed, kind = "Mersenne-Twister", normal.kind = "Inversion", sample.kind = "Rejection")
  theta <- s$AbilitySD * rnorm(s$Persons)
  grid <- expand.grid(Person = seq_len(s$Persons), Task = seq_len(s$Tasks), Rater = seq_len(s$Raters))
  u <- runif(nrow(grid))
  roster <- gmfrm_design_roster(s)
  p <- gmfrm_design_parameters(s)
  probability <- gmfrm_design_probability(theta[grid$Person], grid$Task, grid$Rater, p)
  score <- integer(nrow(grid)); cumulative <- numeric(nrow(grid))
  for (k in seq_len(s$Maximum)) {
    cumulative <- cumulative + probability[, k]
    score <- score + as.integer(u > cumulative)
  }
  keep <- roster[cbind(grid$Person, grid$Rater)]
  data <- data.frame(Person = sprintf("p%03d", grid$Person[keep]),
    Task = paste0("t", grid$Task[keep]), Rater = paste0("r", grid$Rater[keep]), Score = score[keep])
  # Identification: z = theta / SD, a_r* = SD a_r, locations/steps divided by SD.
  truth <- data.frame(SlopeOwner = c(rep("Task", s$Tasks), rep("Rater", s$Raters)),
    SlopeLevel = c(paste0("t", seq_len(s$Tasks)), paste0("r", seq_len(s$Raters))),
    Truth = c(p$task_slope, s$AbilitySD * p$rater_slope))
  list(data = data, truth = truth, roster = roster, theta = theta, parameters = p,
    seed = seed, scenario = s, expected_category = colMeans(probability[keep, , drop = FALSE]))
}

gmfrm_design_check <- function(out) {
  stopifnot(!dir.exists(out))
  pkgload::load_all(".", quiet = TRUE, compile = FALSE, helpers = FALSE)
  plan <- gmfrm_design_plan()
  stopifnot(nrow(plan) == 24L, sum(plan$Retained) == 4L, sum(plan$NewFits) == 2000L)
  # A direct old-formula identity, independently of either package kernel or RNG.
  old <- gmfrm_design_parameters(plan[2L, ])
  eta <- c(-1.7, 0, 2.3); task <- 1:3; rater <- c(1L, 4L, 6L)
  a <- old$task_slope[task] * old$rater_slope[rater]
  literal <- cbind(0, a * (eta - old$steps[rater, 1L]), 2 * a * eta)
  literal <- exp(literal - apply(literal, 1L, max)); literal <- literal / rowSums(literal)
  stopifnot(max(abs(literal - gmfrm_design_probability(
    eta + old$task_location[task] + old$rater_location[rater], task, rater, old))) < 1e-14)
  rows <- lapply(seq_len(nrow(plan)), function(i) {
    s <- plan[i, ]; x <- gmfrm_design_data(s, 1L); y <- gmfrm_design_data(s, 2L)
    stopifnot(identical(x, gmfrm_design_data(s, 1L)), !identical(x$data, y$data),
      identical(colSums(x$roster), colSums(y$roster)), nrow(x$data) == sum(x$roster) * s$Tasks,
      nrow(x$truth) == s$Tasks + s$Raters, all(x$data$Score %in% 0:s$Maximum),
      abs(sum(log(x$parameters$task_slope))) < 1e-12,
      abs(sum(x$parameters$task_location)) < 1e-12,
      max(abs(rowSums(x$parameters$steps))) < 1e-12)
    if (s$Roster == "common_persons") stopifnot(sum(rowSums(x$roster) == s$Raters) == s$Persons / 5L)
    if (s$Roster %in% c("rotating_pairs", "unequal")) stopifnot(all(rowSums(x$roster) == 2L))
    if (s$Roster %in% c("common_persons", "rotating_pairs", "weak_bridge") && s$Raters == 6L)
      stopifnot(all(colSums(x$roster) == s$Persons / 3L))
    if (s$Roster == "unequal") stopifnot(identical(colSums(x$roster), c(100, 120, 90, 70, 50, 50)))
    if (s$Roster == "weak_bridge") stopifnot(sum(rowSums(x$roster[, 1:3]) > 0 &
      rowSums(x$roster[, 4:6]) > 0) == 6L, identical(sort(rowSums(x$roster)), c(rep(1, 24), rep(2, 210), rep(6, 6))))
    task <- as.integer(sub("t", "", x$data$Task)); rater <- as.integer(sub("r", "", x$data$Rater))
    theta <- x$theta[as.integer(sub("p", "", x$data$Person))]; p <- x$parameters
    literal <- gmfrm_design_probability(theta, task, rater, p)
    fixed <- p
    fixed$rater_slope <- fixed$rater_slope * s$AbilitySD
    for (name in c("task_location", "rater_location", "steps")) fixed[[name]] <- fixed[[name]] / s$AbilitySD
    transformed <- gmfrm_design_probability(theta / s$AbilitySD, task, rater, fixed)
    cumulative_steps <- cbind(0, t(apply(p$steps, 1L, cumsum)))
    kernel <- mfrmr:::category_prob_gpcm(theta - p$task_location[task] - p$rater_location[rater],
      cumulative_steps, rater, p$task_slope[task] * p$rater_slope[rater], seq_along(theta))
    scale_error <- max(abs(literal - transformed)); kernel_error <- max(abs(literal - kernel))
    stopifnot(scale_error < 1e-12, kernel_error < 1e-12)
    data.frame(Scenario = s$Scenario, Ratings = nrow(x$data), PersonRaterPairs = sum(x$roster),
      MinRaterPersons = min(colSums(x$roster)), MaxRaterPersons = max(colSums(x$roster)),
      MinPersonRaters = min(rowSums(x$roster)), MaxPersonRaters = max(rowSums(x$roster)),
      ExpectedTopFraction = tail(x$expected_category, 1L),
      ObservedTopCount = sum(x$data$Score == s$Maximum),
      ScaleError = scale_error, KernelError = kernel_error)
  })
  original <- gmfrm_design_data(plan[23L, ], 1L); control <- gmfrm_design_data(plan[24L, ], 1L)
  stopifnot(identical(original$theta, control$theta), identical(original$truth, control$truth),
    identical(colSums(original$roster), colSums(control$roster)), sum(original$roster) == 274L,
    identical(sort(rowSums(control$roster)), c(rep(2, 131), rep(3, 4))))
  shared <- merge(original$data, control$data, by = c("Person", "Task", "Rater"))
  stopifnot(nrow(shared) > 0L, identical(shared$Score.x, shared$Score.y))
  rows <- do.call(rbind, rows)
  stopifnot(rows$ExpectedTopFraction[plan$Scenario == "rare-top-category"] < .05)
  dir.create(out, recursive = TRUE)
  write.csv(plan, file.path(out, "scenarios.csv"), row.names = FALSE)
  write.csv(rows, file.path(out, "preflight.csv"), row.names = FALSE)
  files <- c("inst/validation/gmfrm-design-screen-20261001.R", gmfrm_design_template,
    "R/core-category-probabilities.R", "inst/validation/internal-roadmap-0.2.4.md")
  saveRDS(list(plan = plan, preflight = rows, source_hashes = tools::md5sum(files),
    session = capture.output(sessionInfo()), checked = Sys.time(), fits_started = 0L),
    file.path(out, "preflight.rds"))
  print(rows, row.names = FALSE)
  cat("24 scenarios checked with two seeds each; no estimation, no coverage results.\n")
  invisible(rows)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  if (length(args) == 2L && identical(args[1L], "check")) gmfrm_design_check(args[2L]) else
    stop("Use check OUTPUT. This script deliberately has no fitting command.")
}
