# Repository-only software regression comparison, not additional confirmation.
# From the package root:
# Rscript inst/validation/package-check-repair-fairz-bridge-0.2.4.R
pkgload::load_all('.', quiet = TRUE)
source('inst/validation/fairz-coverage-0.2.4.R')
input <- 'validation-results/fairz-current-20260915/final-current/confirmation'
output <- 'validation-results/checkpoint-20260917/package-fix-fairz-bridge'
dir.create(output, recursive = TRUE, showWarnings = FALSE)

# First replicate in every cell plus all four original non-ready fits.
# These cases check ordinary and warning behavior, not coverage rates.
cases <- rbind(data.frame(Cell = 1:8, Replicate = 1L),
               data.frame(Cell = c(1L, 1L, 7L, 7L),
                          Replicate = c(1459L, 2447L, 2075L, 2418L)))
payload <- fairz_coverage_payload()
backend <- fairz_coverage_backend()
rows <- vector('list', nrow(cases))
for (id in 1:8) {
  path <- file.path(input, sprintf('cell-%02d.rds', id))
  before_md5 <- tools::md5sum(path)
  state <- readRDS(path)
  stopifnot(length(state$Results) == 2500L,
            identical(names(state$Payload), names(payload)),
            identical(state$Backend, backend))
  # Validate the historical state against its own declared source identity.
  fairz_coverage_validate(state, mml_coverage_cells()[id, ],
                         'confirmation', state$Payload)
  changed <- names(payload)[state$Payload != payload]
  stopifnot(setequal(changed, c('R/core-optimizer.R', 'R/mfrm_core.R')))
  # The old confirmation must still refuse the changed current payload.
  rejected <- tryCatch({
    fairz_coverage_validate(state, state$Cell, 'confirmation', payload)
    FALSE
  }, error = function(e) TRUE)
  stopifnot(rejected)

  for (i in which(cases$Cell == id)) {
    replicate <- cases$Replicate[i]
    old <- state$Results[[replicate]]
    new <- fairz_coverage_one(state$Cell, replicate, 'confirmation')
    fields <- setdiff(names(old), grep('Seconds$', names(old), value = TRUE))
    comparable_old <- old
    comparable_new <- new
    if (!is.null(old$Detail)) {
      # The four adverse cases retain whole fits. Their only intended new
      # field is the zero population-boundary count; stage timings vary.
      stopifnot(identical(new$Detail$fit$opt$evaluation_cache$
                            PopulationVarianceNumericBoundaryRejections, 0L),
                !isTRUE(new$Detail$fit$config$population_spec$active))
      comparable_new$Detail$fit$opt$evaluation_cache$
        PopulationVarianceNumericBoundaryRejections <- NULL
      comparable_old$Detail$fit$opt$optimizer_polish$Stages$ElapsedSeconds <- NULL
      comparable_new$Detail$fit$opt$optimizer_polish$Stages$ElapsedSeconds <- NULL
      comparable_old$Detail$fit$config$estimation_control$
        optimizer_polish$Stages$ElapsedSeconds <- NULL
      comparable_new$Detail$fit$config$estimation_control$
        optimizer_polish$Stages$ElapsedSeconds <- NULL
    }
    differences <- fields[!vapply(fields, function(name)
      identical(comparable_old[[name]], comparable_new[[name]]), logical(1))]
    rows[[i]] <- data.frame(
      Cell = id, Replicate = replicate, Seed = old$Seed,
      OriginalFitReady = old$FitReady, CurrentFitReady = new$FitReady,
      WholeFitCompared = !is.null(old$Detail),
      ComparedFields = length(fields), ExactMatch = !length(differences),
      ChangedFields = paste(differences, collapse = ';'),
      HistoricalFileMD5 = unname(before_md5),
      stringsAsFactors = FALSE
    )
    saveRDS(list(Original = old, Current = new, Row = rows[[i]]),
            file.path(output, sprintf('cell-%02d-rep-%04d.rds', id, replicate)))
    print(rows[[i]], row.names = FALSE)
  }
  stopifnot(identical(before_md5, tools::md5sum(path)))
}
result <- do.call(rbind, rows)
write.csv(result, file.path(output, 'comparison.csv'), row.names = FALSE)
saveRDS(list(CurrentPayload = payload, Backend = backend,
             Cases = cases, Results = result, Session = sessionInfo()),
        file.path(output, 'manifest.rds'))
stopifnot(all(result$ExactMatch))
