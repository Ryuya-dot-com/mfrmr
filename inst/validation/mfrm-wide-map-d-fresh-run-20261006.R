# One existing R50 historical two-family condition; no new response generation.
# Run prepare/run from the qualified source-v2 directory. Completed numerical
# phases and completed jobs are reused; failures keep their original denominator.
pkgload::load_all('.', quiet = TRUE, compile = FALSE, helpers = FALSE)
for (n in c('mml-stages', 'jml-stages', 'output-summary', 'multi-output'))
  source(paste0('inst/validation/mfrm-wide-map-', n, '-20261001.R'))
for (n in c('output', 'response'))
  source(paste0('inst/validation/mfrm-wide-map-d-', n, '-20261005.R'))
source('inst/validation/mfrm-wide-map-d-fresh-two-family-20261006.R')
script <- 'inst/validation/mfrm-wide-map-d-fresh-run-20261006.R'
root <- 'validation-results/mfrm-wide-map-d-historical-two-family-r50-20261006'
out <- file.path(root, 'n30-sd1-common')
condition <- 'D:historical-full-common:N30:SD1:H-both'
registry_path <- 'validation-results/mfrm-wide-map-r50-20261001/d-inputs/inputs.csv'
contracts_path <- 'validation-results/mfrm-wide-map-r50-20261001/d-inputs/target-contracts.rds'
generator <- 'inst/validation/mfrm-wide-map-d-inputs-20261001.R'
prototype_path <- 'validation-results/mfrm-wide-map-d-retained-output-20261005/job-003/manifest.rds'
arguments <- commandArgs(trailingOnly = TRUE)
stopifnot(length(arguments) == 1L, arguments %in% c('prepare', 'run'),
  identical(normalizePath('.'), normalizePath(file.path(root, 'source-v2'))))
check_hashes <- function(h) stopifnot(length(h) > 0L, identical(tools::md5sum(names(h)), h))
qualification <- readRDS(file.path(root, 'qualification.rds'))
replay <- readRDS(file.path(root, 'qualification-fresh-replay.rds'))
stopifnot(isTRUE(replay$ChecksPassed), isTRUE(replay$NoFittingOrInformation),
          identical(wide_d_runtime(), qualification$runtime))
for (h in list(qualification$source, qualification$original, qualification$inputs,
               replay$qualification, replay$source)) check_hashes(h)
sources <- tools::md5sum(c(script, wide_d_fresh_script, generator,
                           'inst/validation/mfrm-wide-map-d-response-20261005.R'))
stopifnot(!anyNA(sources))
if (arguments == 'prepare') {
  stopifnot(!dir.exists(out))
  registry <- read.csv(registry_path, stringsAsFactors = FALSE)
  rows <- registry[registry$ConditionId == condition, ]
  rows <- rows[order(rows$Replicate), ]
  stopifnot(nrow(rows) == 50L, identical(rows$Replicate, 1:50),
    all(rows$N == 30L), all(rows$SD == 1), all(rows$ObservedRows == 180L),
    all(!nzchar(rows$CandidateFit)), all(rows$Selector == 'views[[View]]$data'))
  rows$Job <- sprintf('job-%03d', rows$Replicate)
  specs <- lapply(seq_len(nrow(rows)), function(i) wide_d_fresh_spec(rows[i, ], prototype_path))
  plans <- lapply(specs, wide_multi_plan)
  stopifnot(all(vapply(plans, function(p) sum(p$Output == 'interval' & p$Eligibility == 'eligible'), 1L) == 20L))
  inputs <- tools::md5sum(unique(c(registry_path, contracts_path, prototype_path, rows$Bundle, rows$MetadataBundle)))
  stopifnot(!anyNA(inputs))
  dir.create(out)
  wide_mml_save(list(condition = condition, rows = rows, specs = specs, runtime = wide_d_runtime(),
    sources = sources, inputs = inputs,
    qualification = tools::md5sum(file.path(root, c('qualification.rds', 'qualification-fresh-replay.rds'))),
    scope = 'One complete planned R50 historical two-family calibration/native-output cell. Other D conditions and model arms, training/future scoring and independent confirmation remain separate.',
    stage_policy = 'Unchanged q31/61/121 integration-only retry and output-specific first admission.',
    new_responses = 0L, session = capture.output(sessionInfo())), file.path(out, 'dispatch.rds'))
  cat('Prepared all 50 N30/SD1/common two-family attempts from existing inputs. No fitting.\n')
} else {
  manifest <- readRDS(file.path(out, 'dispatch.rds'))
  stopifnot(identical(manifest$runtime, wide_d_runtime()), identical(manifest$sources, sources),
            identical(manifest$condition, condition))
  for (h in list(manifest$sources, manifest$inputs, manifest$qualification)) check_hashes(h)
  lock <- file.path(out, 'RUNNING')
  stopifnot(dir.create(lock, showWarnings = FALSE))
  writeLines(as.character(Sys.getpid()), file.path(lock, 'pid'))
  run_jobs <- function() {
    on.exit(unlink(lock, recursive = TRUE))
    for (i in seq_len(nrow(manifest$rows))) {
      row <- manifest$rows[i, ]; spec <- manifest$specs[[i]]; path <- file.path(out, row$Job)
      wide_d_fresh_validate(spec, list())
      complete <- file.path(path, 'complete.rds')
      if (file.exists(complete)) {
        saved <- readRDS(complete)
        stopifnot(identical(saved$spec_hash, wide_mml_hash(spec)))
        check_hashes(saved$immutable_phases)
        next
      }
      cat('Starting', row$Job, condition, 'rep', row$Replicate, '\n'); flush.console()
      selected <- wide_d_fresh_run(spec, path)
      result <- wide_d_fresh_collect(spec, selected, path, contracts_path, generator)
      phases <- list.files(path, '^(q[0-9]+-.*|manifest|selected|d-outputs)[.]rds$', full.names = TRUE)
      wide_mml_save(list(spec_hash = wide_mml_hash(spec), immutable_phases = tools::md5sum(phases),
        complete = TRUE, selected_stages = selected$stages), complete)
      cat('Completed', row$Job, 'point source', result$response$source_ready,
          'intervals', sum(result$records$Output == 'interval' & result$records$Available),
          'of 20\n'); flush.console()
    }
    check_hashes(manifest$inputs); check_hashes(manifest$sources)
    stopifnot(identical(wide_d_runtime(), manifest$runtime))
    paths <- file.path(out, manifest$rows$Job, 'd-outputs.rds')
    outputs <- lapply(paths, function(p) {
      z <- readRDS(p); stopifnot(identical(z$checksum, wide_mml_hash(z$payload))); z$payload
    })
    plan <- do.call(rbind, lapply(outputs, `[[`, 'plan'))
    records <- do.call(rbind, lapply(outputs, `[[`, 'records'))
    summary <- wide_output_summary(plan, records)
    stopifnot(all(summary$Complete), all(summary$Planned == 50L))
    invisible(wide_mml_phase(file.path(out, 'native-summary.rds'),
      list(dispatch = tools::md5sum(file.path(out, 'dispatch.rds')), outputs = tools::md5sum(paths)),
      function() list(summary = summary, scope = manifest$scope, new_responses = 0L)))
    cat('All 50 native calibration/output attempts complete; fresh replay and other D outputs follow.\n')
  }
  run_jobs()
}
