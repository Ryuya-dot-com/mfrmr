# Existing D scoring procedures for the new N30 historical calibration cell.
# qualify/run from scoring-source-v2; run snapshots completed jobs only.
pkgload::load_all('.', quiet = TRUE, compile = FALSE, helpers = FALSE)
for (n in c('mml-stages', 'jml-stages', 'output-summary', 'multi-output'))
  source(paste0('inst/validation/mfrm-wide-map-', n, '-20261001.R'))
extra <- c('inst/validation/mfrm-wide-map-f-scoring-20261002.R',
  paste0('inst/validation/mfrm-wide-map-d-',
    c('output-20261005', 'response-20261005', 'scoring-20261005',
      'training-20261005', 'fresh-two-family-20261006'), '.R'))
for (path in extra) source(path)
script <- 'inst/validation/mfrm-wide-map-d-fresh-scoring-run-20261006.R'
root <- 'validation-results/mfrm-wide-map-d-historical-two-family-r50-20261006'
calibrations <- file.path(root, 'n30-sd1-common')
out <- file.path(root, 'n30-sd1-common-scoring-v2')
arguments <- commandArgs(trailingOnly = TRUE)
stopifnot(length(arguments) == 1L, arguments %in% c('qualify', 'run'),
  identical(normalizePath('.'), normalizePath(file.path(root, 'scoring-source-v2'))))
check_hashes <- function(h) stopifnot(length(h) > 0L, identical(tools::md5sum(names(h)), h))
dispatch_path <- file.path(calibrations, 'dispatch.rds')
dispatch <- readRDS(dispatch_path)
stopifnot(identical(dispatch$runtime, wide_d_runtime()), nrow(dispatch$rows) == 50L)
for (h in list(dispatch$inputs, dispatch$qualification)) check_hashes(h)
runtime <- wide_multi_runtime()
runtime$source <- c(runtime$source, tools::md5sum(c(extra, script,
  'inst/validation/mfrm-wide-map-d-inputs-20261001.R')))
stopifnot(!anyNA(runtime$source))
trace('fit_mfrm', tracer = quote(stop('Fresh D scoring must reuse completed calibration.')),
  where = asNamespace('mfrmr'), print = FALSE)
dir.create(out, showWarnings = FALSE)
qualification_path <- file.path(out, 'qualification.rds')
if (arguments == 'qualify') {
  stopifnot(!file.exists(qualification_path))
  old_root <- 'validation-results/mfrm-wide-map-d-training-20261005'
  old_path <- file.path(old_root, 'qualification.rds')
  previous <- wide_f_read(old_path)
  common <- intersect(names(runtime$source), names(previous$binding$runtime$source))
  common <- setdiff(common, 'inst/validation/mfrm-wide-map-d-training-20261005.R')
  stopifnot(identical(runtime$source[common], previous$binding$runtime$source[common]),
    identical(runtime$R, previous$binding$runtime$R),
    identical(runtime$threads, previous$binding$runtime$threads),
    identical(runtime$dependencies, previous$binding$runtime$dependencies))
  checks <- list()
  for (job in c('job-203', 'job-102')) {
    prior <- previous$payload$cases[[job]]$native
    row <- prior$records[1L, ]
    input <- wide_d_f_input(row$ConditionId, row$Replicate)
    path <- file.path('validation-results/mfrm-wide-map-d-retained-output-20261005', job)
    check_hashes(prior$sources); check_hashes(prior$input)
    stopifnot(identical(wide_d_training_native(input, path), prior))
    checks[[job]] <- prior$sources
  }
  path <- file.path(calibrations, 'job-001')
  done <- readRDS(file.path(path, 'complete.rds')); check_hashes(done$immutable_phases)
  input <- wide_d_f_input(dispatch$rows$ConditionId[1L], 1L)
  native <- wide_d_training_native(input, path)
  initial <- wide_f_read(file.path(path, 'q31-fit.rds'))$payload$value$facets$person
  ix <- match(native$records$Person, initial$Person)
  stopifnot(nrow(native$records) == 30L, all(native$records$Returned),
    identical(native$records$Estimate, initial$Estimate[ix]),
    identical(native$records$ConditionalSD, initial$PosteriorSD[ix]),
    identical(native$records$EstimateUse, as.character(initial$EstimateUse[ix])),
    identical(native$records$SourceFitReadiness, as.character(initial$SourceFitReadiness[ix])))
  check_hashes(done$immutable_phases)
  saveRDS(list(ChecksPassed = TRUE, runtime = runtime,
    dispatch = tools::md5sum(dispatch_path), retained_checks = checks,
    previous = tools::md5sum(old_path), new_case = done$immutable_phases,
    fresh_training_native = native,
    scope = 'Only source admission changed. Two retained native outputs match exactly; the first fresh output matches its original q31 Person table and readiness labels. Existing scoring and panel procedures are unchanged.'),
    qualification_path)
  cat('Training admission qualified: two retained outputs unchanged and 30 fresh native Persons matched.\n')
} else {
  qualification <- readRDS(qualification_path)
  stopifnot(isTRUE(qualification$ChecksPassed), identical(qualification$runtime, runtime))
  for (h in c(list(qualification$dispatch, qualification$previous, qualification$new_case),
              qualification$retained_checks)) check_hashes(h)
  binding <- list(runtime = runtime, dispatch = tools::md5sum(dispatch_path),
    qualification = tools::md5sum(qualification_path))
  stopifnot(identical(wide_mml_phase(file.path(out, 'manifest.rds'),
    'd-fresh-historical-scoring-v1', function() binding), binding))
  lock <- file.path(out, 'RUNNING'); stopifnot(dir.create(lock, showWarnings = FALSE))
  writeLines(as.character(Sys.getpid()), file.path(lock, 'pid'))
  run_ready <- function() {
    on.exit(unlink(lock, recursive = TRUE))
    ids <- which(file.exists(file.path(calibrations, dispatch$rows$Job, 'complete.rds')))
    for (i in ids) {
      row <- dispatch$rows[i, ]; calibration <- file.path(calibrations, row$Job)
      done <- readRDS(file.path(calibration, 'complete.rds'))
      stopifnot(isTRUE(done$complete), identical(done$spec_hash, wide_mml_hash(dispatch$specs[[i]])))
      check_hashes(done$immutable_phases)
      path <- file.path(out, row$Job); dir.create(path, showWarnings = FALSE)
      input <- wide_d_f_input(row$ConditionId, row$Replicate)
      source <- wide_d_f_source(calibration, input)
      common <- intersect(names(source$model_source), names(runtime$source))
      stopifnot(identical(source$model_source[common], runtime$source[common]))
      dependencies <- list(run = wide_mml_hash(binding), calibration = done$immutable_phases,
                           input = input$provenance)
      native <- wide_mml_phase(file.path(path, 'native.rds'), dependencies,
        function() wide_d_training_native(input, calibration))
      panels <- wide_mml_phase(file.path(path, 'panels.rds'), dependencies, function() {
        future <- wide_d_f_panels(input)
        list(training = wide_d_training_panel(input), future = future)
      })
      # N30 has the declared 60-Person F-pop panel; F-grid is not allocated here.
      stopifnot(identical(names(panels$future$panels), 'population'),
        nrow(panels$training$planned) == 30L,
        nrow(panels$future$panels$population$planned) == 60L)
      records <- phases <- list()
      for (panel in c(list(panels$training), panels$future$panels)) {
        scoring <- file.path(path, 'scoring', panel$Panel)
        selected <- wide_d_f_run(source, panel, scoring, runtime)
        records[[panel$Panel]] <- wide_d_f_records(source, panel, selected)
        phases[[panel$Panel]] <- tools::md5sum(list.files(scoring,
          '^(score-q[0-9]+|selected|manifest)[.]rds$', full.names = TRUE))
      }
      value <- list(job = row, native = native, records = records,
        source_ready = isTRUE(source$review$ready), phases = phases, complete = TRUE)
      record_binding <- list(dependencies = dependencies, phases = phases,
        outputs = tools::md5sum(file.path(path, c('native.rds', 'panels.rds'))))
      stopifnot(identical(wide_mml_phase(file.path(path, 'outputs.rds'),
        record_binding, function() value), value))
      check_hashes(done$immutable_phases)
      z <- lapply(value$records, function(r) r[r$Rule == 'refinement', ])
      cat('Completed', row$Job, 'native', sum(native$records$Finite),
        'training/future scores', sum(vapply(z, function(r) sum(r$ScoreAvailable), 0)),
        'of', sum(vapply(z, nrow, 1L)), '\n'); flush.console()
    }
    check_hashes(dispatch$inputs)
    cat('Scoring pass complete:', length(ids), 'ready jobs; original denominator 50.\n')
  }
  run_ready()
}
