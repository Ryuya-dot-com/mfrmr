# Synthetic accounting check only; never used as simulation evidence.
directory <- tempfile("mi-summary-accounting-fixture-"); dir.create(directory)
saveRDS(list(replications = 2L, truth = .5), file.path(directory, "plan.rds"))
d <- data.frame(Score = rep(0L, 480L), Assigned = c(rep(FALSE, 20L), rep(TRUE, 460L)))
d$Score[!d$Assigned] <- NA_integer_
valid <- data.frame(Estimate = .5, SE = .1, Lower = .3, Upper = .7)
wrong <- data.frame(Estimate = 1.5, SE = .1, Lower = 1.3, Upper = 1.7)
for (id in 1:2) for (mask in c("MAR", "MNAR")) {
  methods <- if (id == 1L) list(MML = valid, Bayes = valid, MI = valid) else
    list(MML = wrong, Bayes = wrong) # MI deliberately unavailable, not dropped.
  x <- list(id = id, mask = mask, preflight = FALSE, seed = 92231000L + id,
    data = d, generating_scores = rep(0L, 480L), missing = integer(), methods = methods,
    errors = if (id == 2L) list(pool = "Synthetic unavailable MI") else list(),
    warnings = list(), seconds = 1, sampling_ready = TRUE,
    diagnostics = data.frame(rhat = 1, ess_bulk = 1000, ess_tail = 1000), grid = c(0, 0),
    analyses = list(analysis_summary = data.frame(Imputation = 1L, Status = "eligible",
      InferenceReady = TRUE, Error = "", Warnings = "")))
  saveRDS(x, file.path(directory, sprintf("trial-%04d-%s.rds", id, mask)))
}
script <- normalizePath("inst/validation/response-mi-coverage-summary-0.2.4.R")
output <- system2(file.path(R.home("bin"), "Rscript"), c(shQuote(script), shQuote(directory)), stdout = TRUE, stderr = TRUE)
stopifnot(is.null(attr(output, "status")))
z <- readRDS(file.path(directory, "summary.rds"))
s <- z$summary
stopifnot(nrow(z$rows) == 12L, all(s$Planned == 2L),
  all(s$Available[s$Method == "MI"] == 1L),
  all(s$Coverage[s$Method == "MI"] == 1),
  all(s$JointAvailableCovered == .5),
  all(s$Availability[s$Method == "MI"] == .5),
  all(s$Coverage[s$Method != "MI"] == .5),
  all(s$Bias[s$Method == "MI"] == 0),
  all(s$Bias[s$Method != "MI"] == .5),
  all(z$paired$N == 1L), all(z$paired$Difference == 0),
  all(is.na(z$paired$MCSE)),
  all(abs(s$CoverageLower[s$Method == "MI"] - .025) < 1e-12),
  all(s$Decision[s$Method == "MI"] == "inconclusive"))
cat("Synthetic accounting check passed: unavailable MI stays in planned/joint denominators; pairing uses common datasets.\n")
unlink(directory, recursive = TRUE)
