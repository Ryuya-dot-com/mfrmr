# Run from package root: Rscript inst/validation/random-rater-pilot-0.2.4.R
.libPaths(c(normalizePath(".r-library"), .libPaths()))
pkgload::load_all(".", quiet = TRUE)
out <- "validation-results/random-rater-20260923/pilot-final"
dir.create(out, recursive = TRUE, showWarnings = FALSE)
files <- c("R/api-random-rater.R", "R/api-random-rater-profile.R",
  "R/api-random-rater-prediction.R", "R/core-optimizer.R", "R/mfrm_core.R",
  "inst/validation/random-rater-pilot-0.2.4.R", "inst/validation/random-rater-record-0.2.4.md")
conditions <- expand.grid(Raters = c(6L, 24L), SD = c(0, .7))
roster <- do.call(rbind, lapply(1:4, function(i) data.frame(Condition = i,
  Raters = conditions$Raters[i], SD = conditions$SD[i], Replicate = 1:40,
  Seed = 9236100L + 100L * i + 1:40)))
path <- file.path(out, "protocol.rds")
if (!file.exists(path)) {
  saveRDS(list(roster = roster, source = tools::md5sum(files), session = sessionInfo(),
    frozen = Sys.time()), path)
  file.copy("inst/validation/random-rater-record-0.2.4.md", file.path(out, "frozen-protocol.md"))
  for (f in files) {
    destination <- file.path(out, "executed-source", f)
    dir.create(dirname(destination), recursive = TRUE, showWarnings = FALSE)
    file.copy(f, destination)
  }
} else stopifnot(identical(readRDS(path)$source, tools::md5sum(files)))
for (j in seq_len(nrow(roster))) {
  row <- roster[j, ]; path <- file.path(out, sprintf("trial-%03d.rds", j))
  if (file.exists(path)) next
  set.seed(row$Seed)
  person <- rep(1:240, each = 6)
  rater <- (person - 1 + rep(rep(0:1, each = 3), 240)) %% row$Raters + 1
  criterion <- rep(1:3, 480)
  theta <- rnorm(240); u <- rnorm(row$Raters, sd = row$SD)
  eta <- theta[person] - u[rater] - c(-.3, 0, .3)[criterion]
  w <- cbind(0, eta + .6, 2 * eta); w <- exp(w - apply(w, 1, max)); w <- w / rowSums(w)
  d <- data.frame(Person = person, Rater = rater, Criterion = criterion,
    Score = rowSums(runif(length(person)) > t(apply(w, 1, cumsum))))
  fit <- profile <- NULL; errors <- warnings <- character()
  elapsed <- system.time(withCallingHandlers({
    fit <- tryCatch(fit_mfrm_random_rater(person_sd = 1, d, "Person", "Rater", "Score", "Criterion", 0:2,
      quad_points = 61L), error = function(e) { errors <<- c(errors, conditionMessage(e)); NULL })
    if (!is.null(fit) && isTRUE(fit$checks$NumericalReady)) profile <- tryCatch(confint(fit),
      error = function(e) { errors <<- c(errors, conditionMessage(e));
        list(error = conditionMessage(e), evaluations = e$profile) })
  }, warning = function(w) { warnings <<- c(warnings, conditionMessage(w)); invokeRestart("muffleWarning") }))
  saveRDS(list(roster = row, data = d, truth = list(theta = theta, rater = setNames(u, 1:row$Raters),
    criterion = c(-.3, 0, .3), steps = c(-.6, .6)), fit = fit, profile = profile,
    errors = errors, warnings = warnings, elapsed = elapsed), path)
  cat(j, "/", nrow(roster), " condition", row$Condition,
    " ready", !is.null(fit) && isTRUE(fit$checks$NumericalReady),
    " profile", is.matrix(profile), " seconds", elapsed[["elapsed"]], "\n")
  flush.console()
}
