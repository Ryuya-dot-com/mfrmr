# Row 2b: matched-budget screening evaluation. Run from the package root.
# Rscript inst/validation/rater-screening-matched-0.2.4.R setup <output>
# Rscript inst/validation/rater-screening-matched-0.2.4.R preflight <output>
# Rscript inst/validation/rater-screening-matched-0.2.4.R run <output> <first> <last>
# Rscript inst/validation/rater-screening-matched-0.2.4.R summary <output>

screening_archive <- function() {
  directory <- "validation-results/roadmap-followthrough-20260922/selection-study"
  original <- readRDS(file.path(directory, "protocol.rds"))
  paths <- names(original$source)[startsWith(names(original$source), "R/")]
  changed <- paths[unname(tools::md5sum(paths)) != unname(original$source[paths])]
  allowed <- c("R/api-as-ggplot.R", "R/api-cluster-comparison.R", "R/api-feature-clustering.R",
    "R/api-plotting-clusters.R", "R/api-simulation.R", "R/help_visual_diagnostics.R")
  stopifnot(all(changed %in% allowed))
  definitions <- function(path, name) Filter(function(x) is.call(x) &&
    identical(x[[1]], as.name("<-")) && identical(x[[2]], as.name(name)),
    as.list(parse(path, keep.source = FALSE)))
  generator <- definitions(file.path(directory, "executed-runner.R"), "generate")
  current <- definitions("inst/validation/rater-feedback-selection-0.2.4.R", "generate")
  stopifnot(length(generator) == 1L, identical(generator, current))
  environment <- new.env(parent = globalenv()); environment$protocol <- original$protocol
  eval(generator[[1]], envir = environment)
  list(directory = directory, identity = original, changed = changed, generate = environment$generate)
}

screening_conditions <- function() {
  expand.grid(Design = c("Rotating", "Weak bridge"),
    Scenario = c("Null", "Inconsistent R6", "Ability-linked null", "MCAR null", "Score-dependent null"),
    stringsAsFactors = FALSE)
}

screening_setup <- function(directory) {
  archive <- screening_archive()
  conditions <- screening_conditions()
  roster <- do.call(rbind, lapply(seq_len(nrow(conditions)), function(i) {
    z <- expand.grid(Replicate = archive$identity$protocol$seeds, Target = paste0("R", 1:6))
    z$Condition <- paste(conditions$Design[i], conditions$Scenario[i], sep = " / ")
    z$Affected <- conditions$Scenario[i] == "Inconsistent R6" & z$Target == "R6"
    z[c("Condition", "Replicate", "Target", "Affected")]
  }))
  rule <- "Infit OR Outfit outside [0.5, 1.5]; all six observed raters; no selection or refitting"
  source <- c("inst/validation/rater-screening-matched-0.2.4.R",
    "inst/validation/internal-roadmap-0.2.3.md", "R/api-screening-performance.R",
    "R/api-estimation.R", "R/api-methods.R", "R/mfrm_core.R")
  protocol <- list(conditions = conditions, roster = roster, rule = rule,
    archive = archive$identity, unchanged_generator = TRUE, changed_unrelated_sources = archive$changed,
    source = tools::md5sum(source), missing_stream = "seed modulo 1e9 + 923000; full-rating exponential draws",
    missing_n = 144L, missing_zero_weight = 4, independent_reps = 100L,
    planned_new_fits = 800L, reused_screens = 200L, session = sessionInfo())
  path <- file.path(directory, "protocol.rds")
  if (file.exists(path)) stop("An execution protocol already exists; do not overwrite it.")
  saveRDS(protocol, path)
  write.csv(roster, file.path(directory, "roster.csv"), row.names = FALSE)
}

screening_data <- function(generated, design, scenario, seed) {
  d <- if (scenario == "Inconsistent R6") generated$inconsistent_R6 else generated$null
  p <- match(d$Person, names(generated$theta))
  position <- if (scenario == "Ability-linked null") rank(generated$theta, ties.method = "first")[p] else p
  if (design == "Rotating") {
    first <- (position - 1L) %% 6L + 1L; second <- first %% 6L + 1L
  } else {
    panel <- ifelse(position <= 60L, 0L, 3L)
    local <- (position - 1L) %% 3L + 1L
    first <- panel + local; second <- panel + local %% 3L + 1L
    second[position == 1L] <- 4L
    first[position == 61L] <- 2L
  }
  r <- match(d$Rater, paste0("R", 1:6))
  assigned <- r == first | r == second
  set.seed(as.integer(seed %% 1e9 + 923000L))
  race <- rexp(nrow(d))[assigned]
  d <- d[assigned, ]
  stopifnot(nrow(d) == 720L, all(table(d$Rater) == 120L), all(table(d$Person) == 6L))
  d$Assigned <- TRUE
  d$GeneratedScore <- d$Score
  if (scenario %in% c("MCAR null", "Score-dependent null")) {
    weight <- if (scenario == "Score-dependent null") ifelse(d$Score == 0, 4, 1) else rep(1, nrow(d))
    missing <- order(race / weight)[seq_len(144L)]
    d$Score[missing] <- NA_integer_
  }
  d
}

screening_one <- function(d, seed, design, scenario) {
  labels <- paste0("R", 1:6)
  rows <- data.frame(Condition = paste(design, scenario, sep = " / "),
    Replicate = seed, Target = labels, Flag = rep(NA, 6), Infit = NA_real_, Outfit = NA_real_,
    Source = "New fit")
  run <- data.frame(Condition = rows$Condition[1], Replicate = seed,
    AssignedRatings = nrow(d), ObservedRatings = sum(!is.na(d$Score)),
    ObservedPersons = length(unique(d$Person[!is.na(d$Score)])),
    FitReady = FALSE, ScreenAvailable = FALSE, Seconds = NA_real_, Error = "", Warnings = "")
  started <- proc.time()[["elapsed"]]; warnings <- character(); fit <- NULL
  tryCatch(withCallingHandlers({
    observed <- d[!is.na(d$Score), ]
    fit <- fit_mfrm(observed, "Person", c("Rater", "Criterion"), "Score",
      model = "RSM", method = "MML", rating_min = 0, rating_max = 3, quad_points = 61, maxit = 400)
    run$FitReady <- mfrm_inference_ready(fit)
    dx <- diagnose_mfrm(fit, residual_pca = "none")
    measures <- dx$measures[dx$measures$Facet == "Rater", ]
    at <- match(labels, measures$Level)
    rows$Infit <- measures$Infit[at]; rows$Outfit <- measures$Outfit[at]
    flag <- function(x) ifelse(is.finite(x), x < .5 | x > 1.5, NA)
    rows$Flag <- flag(rows$Infit) | flag(rows$Outfit)
    run$ScreenAvailable <- all(!is.na(rows$Flag))
  }, warning = function(w) { warnings <<- c(warnings, conditionMessage(w)); invokeRestart("muffleWarning") }),
  error = function(e) { run$Error <<- conditionMessage(e) })
  run$Seconds <- proc.time()[["elapsed"]] - started
  run$Warnings <- paste(unique(warnings), collapse = " | ")
  list(rows = rows, run = run, failure = if (!run$FitReady || !run$ScreenAvailable || nzchar(run$Error)) list(data = d, fit = fit) else NULL)
}

screening_reuse <- function(archive, seed, scenario) {
  old_scenario <- if (scenario == "Null") "null" else "inconsistent_R6"
  path <- file.path(archive$directory, paste(seed, "rotating", old_scenario, "rds", sep = "."))
  old <- readRDS(path)$result
  stopifnot(nrow(old) == 1, isTRUE(old$ScreenAvailable), isTRUE(old$FitReady),
    identical(old$AnyFalseFlag, FALSE), !is.na(old$TargetFlag), old$Ratings == 720, !nzchar(old$Error))
  flag <- rep(FALSE, 6)
  if (scenario == "Inconsistent R6") flag[6] <- old$TargetFlag
  if (scenario == "Null") stopifnot(!old$TargetFlag)
  condition <- paste("Rotating", scenario, sep = " / ")
  list(rows = data.frame(Condition = condition, Replicate = seed, Target = paste0("R", 1:6),
    Flag = flag, Infit = NA_real_, Outfit = NA_real_, Source = "Reused pre-selection screen"),
    run = data.frame(Condition = condition, Replicate = seed, AssignedRatings = 720,
      ObservedRatings = 720, ObservedPersons = 120, FitReady = old$FitReady,
      ScreenAvailable = old$ScreenAvailable, Seconds = NA_real_, Error = "", Warnings = ""),
    archive_file = path, archive_md5 = tools::md5sum(path), failure = NULL)
}

screening_run <- function(directory, first, last) {
  pkgload::load_all(".", quiet = TRUE)
  protocol <- readRDS(file.path(directory, "protocol.rds"))
  stopifnot(identical(tools::md5sum(names(protocol$source)), protocol$source))
  archive <- screening_archive()
  for (i in seq.int(first, last)) {
    seed <- archive$identity$protocol$seeds[i]
    path <- file.path(directory, paste0("replicate-", i, ".rds"))
    if (file.exists(path)) stop("Refusing to replace a completed replication: ", i)
    generated <- archive$generate(seed)
    runs <- lapply(seq_len(nrow(protocol$conditions)), function(j) {
      spec <- protocol$conditions[j, ]
      if (spec$Design == "Rotating" && spec$Scenario %in% c("Null", "Inconsistent R6")) {
        screening_reuse(archive, seed, spec$Scenario)
      } else screening_one(screening_data(generated, spec$Design, spec$Scenario, seed), seed, spec$Design, spec$Scenario)
    })
    saveRDS(list(runs = runs, source = protocol$source), path)
    cat("Replication", i, "complete; eight new fits, two reused screens\n"); flush.console()
  }
}

screening_summary <- function(directory) {
  pkgload::load_all(".", quiet = TRUE)
  protocol <- readRDS(file.path(directory, "protocol.rds"))
  records <- lapply(1:100, function(i) readRDS(file.path(directory, paste0("replicate-", i, ".rds"))))
  stopifnot(all(vapply(records, function(x) identical(x$source, protocol$source), logical(1))))
  runs <- unlist(lapply(records, `[[`, "runs"), recursive = FALSE)
  rows <- do.call(rbind, lapply(runs, `[[`, "rows"))
  status <- do.call(rbind, lapply(runs, `[[`, "run"))
  stopifnot(nrow(rows) == 6000L, nrow(status) == 1000L)
  result <- mfrm_screening_performance(protocol$roster, rows, protocol$rule)
  events <- result$family_outcomes
  paired <- do.call(rbind, lapply(unique(protocol$conditions$Scenario), function(scenario) {
    a <- events[events$Condition == paste("Rotating", scenario, sep = " / "), ]
    b <- events[events$Condition == paste("Weak bridge", scenario, sep = " / "), ]
    z <- merge(a, b, by = c("Replicate", "Metric"))
    do.call(rbind, lapply(split(z, z$Metric), function(d) {
      known <- !is.na(d$Flag.x) & !is.na(d$Flag.y)
      differences <- as.integer(d$Flag.y[known]) - as.integer(d$Flag.x[known])
      data.frame(Scenario = scenario, Metric = d$Metric[1], PlannedPairs = nrow(d),
        AvailablePairs = sum(known), WeakMinusRotating = if (length(differences)) mean(differences) else NA_real_,
        MCSE = if (length(differences) > 1) sd(differences) / sqrt(length(differences)) else NA_real_)
    }))
  }))
  saveRDS(result, file.path(directory, "performance.rds"))
  write.csv(result$by_target, file.path(directory, "by-target.csv"), row.names = FALSE)
  write.csv(result$by_family, file.path(directory, "by-family.csv"), row.names = FALSE)
  write.csv(rows, file.path(directory, "target-outcomes.csv"), row.names = FALSE)
  write.csv(status, file.path(directory, "run-status.csv"), row.names = FALSE)
  write.csv(paired, file.path(directory, "paired-family.csv"), row.names = FALSE)
  print(result); print(paired)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE); stopifnot(length(args) >= 2)
  dir.create(args[2], recursive = TRUE, showWarnings = FALSE)
  switch(args[1], setup = screening_setup(args[2]),
    preflight = {
      pkgload::load_all(".", quiet = TRUE)
      archive <- screening_archive(); seed <- 2026092200L
      generated <- archive$generate(seed)
      for (scenario in c("Null", "Inconsistent R6", "Ability-linked null", "MCAR null", "Score-dependent null")) {
        d <- screening_data(generated, "Weak bridge", scenario, seed)
        expected <- if (grepl("MCAR|Score-dependent", scenario)) 576 else 720
        stopifnot(sum(!is.na(d$Score)) == expected)
        x <- screening_one(d, seed, "Weak bridge", scenario)
        print(x$run)
        stopifnot(x$run$ScreenAvailable, !nzchar(x$run$Error))
      }
    }, run = screening_run(args[2], as.integer(args[3]), as.integer(args[4])),
    summary = screening_summary(args[2]), stop("Unknown action"))
}
