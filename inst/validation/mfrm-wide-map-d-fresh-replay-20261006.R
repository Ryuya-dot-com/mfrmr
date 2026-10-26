# Incremental fresh-session replay of completed N30 native/scoring outputs.
# Run from the frozen scoring-source-v2. Never create a missing numerical phase.
pkgload::load_all('.', quiet = TRUE, compile = FALSE, helpers = FALSE)
for (n in c('mml-stages', 'jml-stages', 'output-summary', 'multi-output'))
  source(paste0('inst/validation/mfrm-wide-map-', n, '-20261001.R'))
extra <- c('inst/validation/mfrm-wide-map-f-scoring-20261002.R',
  paste0('inst/validation/mfrm-wide-map-d-', c('output-20261005', 'response-20261005',
    'scoring-20261005', 'training-20261005', 'fresh-two-family-20261006'), '.R'))
for (path in extra) source(path)
root <- 'validation-results/mfrm-wide-map-d-historical-two-family-r50-20261006'
calibrations <- file.path(root, 'n30-sd1-common')
scoring <- file.path(root, 'n30-sd1-common-scoring-v2')
out <- file.path(root, 'incremental-replays')
stopifnot(identical(normalizePath('.'), normalizePath(file.path(root, 'scoring-source-v2'))),
          !dir.exists(file.path(scoring, 'RUNNING')))
check_hashes <- function(h, prefix = NULL) {
  paths <- if (is.null(prefix)) names(h) else file.path(prefix, names(h))
  stopifnot(length(h) > 0L, !anyNA(h),
    identical(unname(tools::md5sum(paths)), unname(h)))
}
dispatch_path <- file.path(calibrations, 'dispatch.rds')
dispatch <- readRDS(dispatch_path)
stopifnot(identical(dispatch$runtime, wide_d_runtime()))
check_hashes(dispatch$sources, file.path(root, 'source-v2'))
for (h in list(dispatch$inputs, dispatch$qualification)) check_hashes(h)
runtime <- wide_multi_runtime()
runtime$source <- c(runtime$source, tools::md5sum(c(extra,
  'inst/validation/mfrm-wide-map-d-fresh-scoring-run-20261006.R',
  'inst/validation/mfrm-wide-map-d-inputs-20261001.R')))
qualification <- readRDS(file.path(scoring, 'qualification.rds'))
stopifnot(qualification$ChecksPassed, identical(runtime, qualification$runtime))
for (h in c(list(qualification$dispatch, qualification$previous, qualification$new_case),
            qualification$retained_checks)) check_hashes(h)

first_native_path <- file.path(calibrations, 'first-unit-replay.rds')
first_scoring_path <- file.path(scoring, 'first-pass-fresh-replay.rds')
first_native <- readRDS(first_native_path); first_scoring <- readRDS(first_scoring_path)
stopifnot(first_native$ChecksPassed, first_scoring$ChecksPassed)
check_hashes(first_native$ImmutablePhases)
for (p in first_scoring$Jobs)
  for (h in c(list(p$Output, p$Calibration), p$Phases)) check_hashes(h)
known_native <- first_native$Job; known_scoring <- names(first_scoring$Jobs)
dir.create(out, showWarnings = FALSE)
previous <- list.files(out, '^batch-[0-9]+[.]rds$', full.names = TRUE)
for (path in previous) {
  proof <- readRDS(path)
  stopifnot(proof$ChecksPassed, identical(proof$Runtime, runtime))
  check_hashes(proof$Sources)
  for (p in c(proof$Native, proof$Scoring)) check_hashes(p$Files)
  known_native <- c(known_native, names(proof$Native))
  known_scoring <- c(known_scoring, names(proof$Scoring))
}
stopifnot(!anyDuplicated(known_native), !anyDuplicated(known_scoring))
ids <- which(file.exists(file.path(calibrations, dispatch$rows$Job, 'complete.rds')))
native_ids <- ids[!dispatch$rows$Job[ids] %in% known_native]
score_ids <- ids[file.exists(file.path(scoring, dispatch$rows$Job[ids], 'outputs.rds')) &
                  !dispatch$rows$Job[ids] %in% known_scoring]
stopifnot(length(native_ids) + length(score_ids) > 0L)
for (n in c('fit_mfrm', 'predict_mfrm_units', 'mfrm_gpcm_product_inference',
            'compute_mml_parameter_covariance'))
  trace(n, tracer = quote(stop('Incremental replay must reuse numerical phases.')),
        where = asNamespace('mfrmr'), print = FALSE)
read_phase <- wide_mml_phase
wide_mml_phase <- function(path, binding, compute) {
  stopifnot(file.exists(path))
  read_phase(path, binding, function() stop('A missing phase cannot be created during replay.'))
}
native_proofs <- scoring_proofs <- list()
for (i in native_ids) {
  row <- dispatch$rows[i, ]; path <- file.path(calibrations, row$Job)
  done <- readRDS(file.path(path, 'complete.rds')); spec <- dispatch$specs[[i]]
  stopifnot(done$complete, identical(done$spec_hash, wide_mml_hash(spec)))
  check_hashes(done$immutable_phases)
  selected <- wide_d_fresh_run(spec, path)
  result <- wide_d_fresh_collect(spec, selected, path,
    'validation-results/mfrm-wide-map-r50-20261001/d-inputs/target-contracts.rds',
    'inst/validation/mfrm-wide-map-d-inputs-20261001.R')
  stopifnot(nrow(result$plan) == 40L, nrow(result$records) == 40L,
    identical(wide_multi_records(spec, selected), result$records))
  initial <- wide_f_read(file.path(path, 'q31-fit.rds'))$payload
  contract <- readRDS('validation-results/mfrm-wide-map-r50-20261001/d-inputs/target-contracts.rds')$contracts[[spec$ConditionId]]
  if (!nzchar(initial$error)) {
    mapped <- wide_mml_capture(function() wide_d_response_points(initial$value, contract$z_grid))
    stopifnot(identical(mapped$value, result$response$initial), identical(mapped$error, result$response$errors[['initial']]))
  }
  if (isTRUE(result$response$source_ready)) {
    order <- sub(':.*$', '', selected$point$stage)
    admitted <- wide_f_read(file.path(path, paste0(order, '-fit.rds')))$payload
    mapped <- wide_mml_capture(function() wide_d_response_points(admitted$value, contract$z_grid))
    stopifnot(identical(mapped$value, result$response$admitted), identical(mapped$error, result$response$errors[['admitted']]))
  }
  check_hashes(done$immutable_phases)
  native_proofs[[row$Job]] <- list(Files = c(done$immutable_phases,
    tools::md5sum(file.path(path, 'complete.rds'))),
    SourceReady = result$response$source_ready,
    IntervalReturns = sum(result$records$Output == 'interval' & result$records$Available),
    Stages = selected$stages, Reasons = unique(result$records[c('Output', 'Status', 'Available', 'Reason')]))
  cat('Native replay', row$Job, 'intervals', native_proofs[[row$Job]]$IntervalReturns, 'of 20\n'); flush.console()
}
for (i in score_ids) {
  row <- dispatch$rows[i, ]; path <- file.path(scoring, row$Job)
  output_path <- file.path(path, 'outputs.rds'); saved <- wide_f_read(output_path); z <- saved$payload
  hashes <- c(list(saved$binding$dependencies$calibration, saved$binding$dependencies$input,
                   saved$binding$outputs), saved$binding$phases)
  for (h in hashes) check_hashes(h)
  input <- wide_d_f_input(row$ConditionId, row$Replicate)
  calibration <- file.path(calibrations, row$Job)
  source <- wide_d_f_source(calibration, input)
  native <- wide_d_training_native(input, calibration)
  stopifnot(identical(native, z$native))
  panels <- wide_f_read(file.path(path, 'panels.rds'))$payload
  stopifnot(identical(panels$training, wide_d_training_panel(input)),
            identical(panels$future, wide_d_f_panels(input)))
  for (panel in c(list(panels$training), panels$future$panels)) {
    selected <- wide_d_f_run(source, panel, file.path(path, 'scoring', panel$Panel), runtime)
    stopifnot(identical(wide_d_f_records(source, panel, selected), z$records[[panel$Panel]]))
  }
  for (h in hashes) check_hashes(h)
  scoring_proofs[[row$Job]] <- list(Files = c(tools::md5sum(output_path), unlist(unname(hashes))),
    NativePersons = nrow(native$records), SourceReady = z$source_ready,
    ScoreReturns = vapply(z$records, function(r) sum(r$ScoreAvailable & r$Rule == 'refinement'), 1L),
    IntervalReturns = vapply(z$records, function(r) sum(r$IntervalAvailable & r$Rule == 'refinement'), 1L))
  cat('Scoring replay', row$Job, 'returns', scoring_proofs[[row$Job]]$ScoreReturns, '\n'); flush.console()
}
script <- sub('^--file=', '', grep('^--file=', commandArgs(), value = TRUE))
for (p in c(native_proofs, scoring_proofs)) check_hashes(p$Files)
proof <- list(ChecksPassed = TRUE, Runtime = runtime, Native = native_proofs, Scoring = scoring_proofs,
  Sources = tools::md5sum(c(script, dispatch_path, file.path(scoring, 'qualification.rds'),
    first_native_path, first_scoring_path, previous)),
  NewFits = 0L, NewNumericalScores = 0L, NewInformation = 0L, MissingPhasesForbidden = TRUE,
  session = capture.output(sessionInfo()),
  Scope = 'Only newly completed jobs replayed; previous proofs and immutable phases retained. Native response maps and output records reconstructed, deterministic scoring panels and records matched. Original denominator50; no incomplete-cell performance claim.')
target <- file.path(out, sprintf('batch-%03d.rds', length(previous) + 1L))
stopifnot(!file.exists(target)); saveRDS(proof, target)
cat('Incremental replay completed:', length(native_proofs), 'native and', length(scoring_proofs), 'scoring jobs.\n')
