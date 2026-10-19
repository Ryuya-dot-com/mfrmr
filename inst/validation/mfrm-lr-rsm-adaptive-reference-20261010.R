# Refine only the failed independent reference, retaining every producer result.
# Run in the same validation runtime after the 15-point allocation completes.
repair_script <- 'inst/validation/mfrm-lr-rsm-adaptive-reference-20261010.R'
driver <- 'inst/validation/mfrm-lr-rsm-adaptive-points-20261010.R'
out <- 'validation-results/mfrm-lr-rsm-adaptive-points-20261010'
manifest_file <- file.path(out, 'manifest.rds')
stopifnot(unname(tools::md5sum(manifest_file)) == '0247d63daa14f19cc0f496efe06f0aeb')
parent <- readRDS(manifest_file)
parent_files <- c(manifest_file, file.path(out, paste0(names(parent$points),'.rds')),
  file.path(out, 'accuracy.csv'))
stopifnot(all(file.exists(parent_files)), length(parent$points) == 15L)
before <- tools::md5sum(parent_files)
# All points exist: the original driver checks identity and reuses them.
invisible(capture.output(source(driver)))
stopifnot(identical(tools::md5sum(names(before)), before))
source_result <- readRDS(file.path(out, 'case05-source.rds'))
stopifnot(!any(source_result$rows$ReferencePassed), source_result$reference_calls == 36L)
repair_binding <- list(parents = before, source = tools::md5sum(c(repair_script,driver)),
  controls = list(relative_tolerance = 1e-13, absolute_tolerance = 1e-15),
  original_controls = controls, session = sessionInfo())
repair_file <- file.path(out, 'reference-repair.rds')
if (file.exists(repair_file)) {
  repaired <- readRDS(repair_file)
  stopifnot(identical(repaired$binding, repair_binding))
} else {
  # Change only stats::integrate accuracy in a private copy of the same
  # independently coded likelihood; no change to the old helper or its gates.
  strict <- rsm_lr_continuous_value
  scope <- new.env(parent = environment(strict))
  scope$integrate <- function(f, lower, upper, ...) {
    args <- list(...); args$rel.tol <- 1e-13; args$abs.tol <- 1e-15
    do.call(stats::integrate, c(list(f = f, lower = lower, upper = upper), args))
  }
  environment(strict) <- scope
  rsm_lr_continuous_value <- strict
  point <- source_result$point
  ctx <- context(point$case)
  saved <- source_result$evaluations
  fixed_value <- saved$fixed$result
  ctx$fixed <- list(value = function(p) {
    stopifnot(identical(p,point$par)); fixed_value$value
  }, gradient = function(p) {
    stopifnot(identical(p,point$par)); fixed_value$gradient
  })
  ctx$adaptive <- lapply(saved[c('adaptive15','adaptive31')], function(z) function(p) {
    stopifnot(identical(p,point$par)); z$result
  })
  contexts[[point$case]] <- ctx
  started <- proc.time()[['elapsed']]
  repaired <- run_point(point)
  repaired$elapsed <- proc.time()[['elapsed']]-started
  repaired$point <- point; repaired$binding <- repair_binding
  # The new comparison must use byte-identical old producer values/gradients.
  stopifnot(repaired$reference_calls == 36L,
    identical(repaired$reference, source_result$reference),
    all(vapply(names(saved), function(n)
      identical(repaired$evaluations[[n]]$result,saved[[n]]$result), TRUE)),
    identical(tools::md5sum(names(before)), before))
  saveRDS(repaired, repair_file)
}
write.csv(repaired$rows, file.path(out, 'reference-repair.csv'), row.names = FALSE)
print(repaired$rows)
cat(sprintf('Reference-only phase: %s; %.3f seconds; original producer files unchanged.\n',
  repaired$status, repaired$elapsed))
