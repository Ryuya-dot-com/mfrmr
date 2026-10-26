# Bounded numerical validation on two retained datasets, not a coverage study.
# Rscript inst/validation/gmfrm-adaptive-profile-20261010.R JOB
# JOB: small-task, small-rater, large-task, or large-rater.
out <- "validation-results/gmfrm-adaptive-profile-20261010"
job <- commandArgs(trailingOnly = TRUE)
stopifnot(length(job) == 1L, job %in% c("small-task", "small-rater", "large-task", "large-rater"))
pkgload::load_all(quiet = TRUE, compile = FALSE)
size <- strsplit(job, "-", fixed = TRUE)[[1]][1]
path <- file.path(out, paste0(size, "-fit.rds"))
target <- if (grepl("task$", job)) c(Task = "t3") else c(Rater = "r3")
destination <- file.path(out, paste0(job, ".rds"))
stopifnot(!file.exists(destination))
fit <- readRDS(path)
before <- serialize(fit, NULL)
inputs <- tools::md5sum(c(path, "R/core-gpcm-profile.R", "R/core-optimizer.R",
  "R/core-adaptive-quadrature.R", "R/mfrm_core.R"))
warnings <- character(); error <- ""; ci <- NULL
time <- system.time(withCallingHandlers(tryCatch(
  ci <- confint(fit, parm = "slopes", method = "profile", slope = target),
  error = function(e) error <<- conditionMessage(e)),
  warning = function(w) { warnings <<- c(warnings, conditionMessage(w)); invokeRestart("muffleWarning") }))
stopifnot(identical(before, serialize(fit, NULL)),
  identical(inputs, tools::md5sum(names(inputs))))
saveRDS(list(job = job, fit = path, target = target, ci = ci, error = error,
  warnings = unique(warnings), seconds = unname(time["elapsed"]),
  inputs = inputs, session = sessionInfo(),
  purpose = "Existing-source adaptive profile calculation; not independent sampling or a coverage comparison."), destination)
cat(job, "elapsed", time["elapsed"], "error", error, "\n")
if (!is.null(ci)) {
  print(attr(ci, "profile")$endpoints)
  print(attr(ci, "settings"))
  cat("points", nrow(attr(ci, "profile")$profile), "\n")
}
