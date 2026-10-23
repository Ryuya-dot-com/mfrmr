# Extend the 208 approved historical two-family q31 stages with D's outputs.
# prepare OUTPUT from development; run OUTPUT [ROW ...] from OUTPUT/source.
# No responses are generated. q61/q121 fitting follows only the unchanged
# integration-only retry rules; interrupted phases are never called failures.
pkgload::load_all('.', quiet = TRUE, compile = FALSE, helpers = FALSE)
for (n in c('mml-stages', 'jml-stages', 'output-summary', 'multi-output'))
  source(paste0('inst/validation/mfrm-wide-map-', n, '-20261001.R'))
source('inst/validation/mfrm-wide-map-d-output-20261005.R')
source('inst/validation/mfrm-wide-map-d-response-20261005.R')
arguments <- commandArgs(trailingOnly = TRUE)
stopifnot(length(arguments) >= 2L, arguments[1L] %in% c('prepare', 'run'))
mode <- arguments[1L]; out <- arguments[2L]
script <- 'inst/validation/mfrm-wide-map-d-retained-run-20261005.R'
contracts_path <- 'validation-results/mfrm-wide-map-r50-20261001/d-inputs/target-contracts.rds'
generator <- 'inst/validation/mfrm-wide-map-d-inputs-20261001.R'
qualification_root <- 'validation-results/mfrm-wide-map-d-output-20261005'
bridge <- wide_d_bridge()
extra <- c(script, 'inst/validation/mfrm-wide-map-d-response-20261005.R',
  'inst/validation/mfrm-wide-map-d-fit-bridge-20261005.R', generator)
source_paths <- unique(c(names(wide_d_runtime()$source)[names(wide_d_runtime()$source) != 'loaded:mfrmr'],
  'src/mfrmr.so', extra, 'LICENSE'))
runtime <- wide_d_runtime()
if (mode == 'prepare') {
  stopifnot(!dir.exists(out))
  sources <- tools::md5sum(source_paths); stopifnot(!anyNA(sources))
  dir.create(file.path(out, 'source'), recursive = TRUE)
  for (path in source_paths) {
    target <- file.path(out, 'source', path)
    dir.create(dirname(target), recursive = TRUE, showWarnings = FALSE)
    stopifnot(file.copy(path, target), unname(tools::md5sum(target)) == unname(sources[path]))
  }
  stopifnot(file.symlink(normalizePath('validation-results'), file.path(out, 'source/validation-results')))
  rows <- bridge$record$records[c('ConditionId', 'Replicate', 'CandidateFit', 'CandidateMD5')]
  rows$Job <- sprintf('job-%03d', seq_len(nrow(rows)))
  manifest <- list(rows = rows, sources = sources, runtime = runtime,
    bridge = setNames(bridge$md5, bridge$path), contracts = tools::md5sum(contracts_path),
    qualification = tools::md5sum(file.path(qualification_root,
      c('qualification-manifest.rds', 'qualification-joint.rds', 'qualification.rds'))),
    stage_policy = 'Unchanged q31/61/121 integration-only retry; output-specific first admission.',
    outputs = 'Both native location families, first-minus-second contrasts, component log slopes, initial and admitted common-z responses.',
    exclusions = 'This extension does not run held-out Person scoring or the other D model arms; their agreed work remains.',
    original_denominators_retained = TRUE)
  stopifnot(!anyNA(manifest$qualification))
  wide_mml_save(manifest, file.path(out, 'dispatch.rds'))
  stopifnot(file.copy('inst/validation/internal-roadmap-0.2.4.md', file.path(out, 'protocol-before-execution.md')))
  cat('Frozen 208 retained fitting-stage output jobs; no fitting or new responses.\n')
} else {
  manifest <- readRDS(file.path(out, 'dispatch.rds'))
  stopifnot(identical(normalizePath('.'), normalizePath(file.path(out, 'source'))),
    identical(runtime, manifest$runtime))
  for (h in list(manifest$sources, manifest$bridge, manifest$contracts, manifest$qualification))
    stopifnot(identical(tools::md5sum(names(h)), h))
  lock <- file.path(out, 'RUNNING')
  stopifnot(dir.create(lock, showWarnings = FALSE))
  writeLines(as.character(Sys.getpid()), file.path(lock, 'pid'))
  run_jobs <- function() {
    on.exit(unlink(lock, recursive = TRUE))
    ids <- if (length(arguments) > 2L) as.integer(arguments[-c(1L, 2L)]) else seq_len(nrow(manifest$rows))
    stopifnot(!anyNA(ids), !anyDuplicated(ids), all(ids %in% seq_len(nrow(manifest$rows))))
    contracts <- readRDS(contracts_path)$contracts
    definition <- Filter(function(x) is.call(x) && identical(x[[1L]], as.name('<-')) &&
      identical(x[[2L]], as.name('d_probability')), as.list(parse(generator)))
    stopifnot(length(definition) == 1L)
    reference <- new.env(parent = baseenv()); eval(definition[[1L]], reference)
    for (i in ids) {
      row <- manifest$rows[i, ]; path <- file.path(out, row$Job)
      job <- wide_d_retained_job(row$ConditionId, row$Replicate, bridge)
      # The qualification case already has this exact joint result. Carry it
      # into an explicitly bound phase rather than differentiate the fit again.
      if (row$ConditionId == 'D:historical-full-common:N120:SD1:H-both' && row$Replicate == 1L) {
        saved_path <- file.path(qualification_root, 'qualification-joint.rds')
        saved <- readRDS(saved_path)
        stopifnot(identical(saved$checksum, wide_mml_hash(saved$payload)),
          identical(saved$binding$runtime, runtime),
          identical(saved$binding$fit, wide_mml_hash(job$retained[['31']]$fitting$value)))
        job$spec$retained_joint_source <- tools::md5sum(saved_path)
        m <- list(spec = job$spec, runtime = runtime, retained = job$retained, orders = c(31L, 61L, 121L))
        dir.create(path, recursive = TRUE, showWarnings = FALSE)
        sealed <- wide_mml_phase(file.path(path, 'manifest.rds'), 'd-retained-shared-fit-outputs-v1', function() m)
        stopifnot(identical(sealed, m)); identity <- wide_mml_hash(m)
        invisible(wide_mml_phase(file.path(path, 'q31-fit.rds'),
          list(job = identity, order = 31L, phase = 'fit', dependency = NULL),
          function() job$retained[['31']]$fitting))
        invisible(wide_mml_phase(file.path(path, 'q31-joint-inference.rds'),
          list(job = identity, order = 31L, phase = 'joint-inference',
            dependency = wide_mml_hash(job$retained[['31']]$fitting)), function() saved$payload))
      }
      cat('Starting', row$Job, row$ConditionId, 'rep', row$Replicate, '\n'); flush.console()
      selected <- wide_d_output_run(job$spec, path, job$retained)
      # Truth enters only after selection and cannot change any retry/admission.
      contract <- contracts[[row$ConditionId]]; truth <- contract$two_family_fixed_normal
      stopifnot(isTRUE(contract$correctly_specified[['two_family']]),
        identical(truth$facets, job$spec$args$facets))
      plan <- selected$plan
      for (consumer_id in names(job$spec$outputs)) {
        consumer <- job$spec$outputs[[consumer_id]]
        t <- wide_multi_targets(job$spec, consumer)
        values <- vapply(seq_len(nrow(t)), function(j) {
          owner <- t$Owner[j]; at <- match(t$Level[j], truth$levels[[owner]])
          if (consumer$kind == 'contrast') {
            C <- wide_multi_contrast(job$spec, consumer)
            return(drop(C[t$Level[j], , drop = FALSE] %*%
              truth$locations[[owner]][match(colnames(C), truth$levels[[owner]])]))
          }
          stopifnot(!is.na(at))
          if (consumer$kind == 'slopes') log(truth$slopes[[owner]][at]) else truth$locations[[owner]][at]
        }, 0)
        at <- which(plan$Consumer == consumer_id)
        plan$Reference[at] <- 'generating_parameter'
        plan$ReferenceValue[at] <- values[match(plan$Target[at], t$Target)]
      }
      records <- wide_multi_records(job$spec, selected)
      ledger <- wide_output_records(plan, records)
      response <- list()
      initial <- readRDS(file.path(path, 'q31-fit.rds'))
      stopifnot(identical(initial$checksum, wide_mml_hash(initial$payload)))
      response$initial <- wide_d_response_points(initial$payload$value, contract$z_grid)
      response$admitted <- NULL
      if (!nzchar(selected$point$error) && isTRUE(selected$point$value$ready)) {
        order <- sub(':.*$', '', selected$point$stage)
        fitted <- readRDS(file.path(path, paste0(order, '-fit.rds')))
        stopifnot(identical(fitted$checksum, wide_mml_hash(fitted$payload)),
          identical(wide_mml_hash(fitted$payload), selected$point$fit_hash))
        response$admitted <- wide_d_response_points(fitted$payload$value, contract$z_grid)
      }
      grid <- response$initial$grid
      response$truth <- reference$d_probability(grid$z, grid$first, grid$second, truth)
      response$source <- selected$point[c('stage', 'fit_hash', 'error')]
      response$source_ready <- isTRUE(selected$point$value$ready)
      response$loss <- vapply(c('initial', 'admitted'), function(name)
        if (is.null(response[[name]])) NA_real_ else mean((response[[name]]$probabilities - response$truth)^2), 0)
      binding <- list(selected = wide_mml_hash(selected), contracts = manifest$contracts,
        helper_sources = manifest$sources[extra])
      invisible(wide_mml_phase(file.path(path, 'd-outputs.rds'), binding, function()
        list(plan = plan, records = records, ledger = ledger, response = response)))
      cat('Completed', row$Job, 'source', response$source_ready, 'intervals',
        sum(ledger$Available & ledger$Output == 'interval'), 'of',
        sum(ledger$Eligibility == 'eligible' & ledger$Output == 'interval'), '\n'); flush.console()
    }
    stopifnot(identical(wide_d_runtime(), runtime),
      identical(tools::md5sum(names(manifest$sources)), manifest$sources))
  }
  run_jobs()
}
