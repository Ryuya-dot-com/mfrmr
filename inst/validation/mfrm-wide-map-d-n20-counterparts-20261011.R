# N20 continuation: reuse the frozen N240 fitting/admission procedure and saved GMFRM.
# Usage: Rscript --vanilla THIS_FILE prepare|run|summarize|replay [JOB ...]
base_script <- 'inst/validation/mfrm-wide-map-d-counterparts-20261011.R'
expressions <- as.list(parse(base_script))
entry <- which(vapply(expressions, function(x) is.call(x) &&
  identical(x[[1L]], as.name('<-')) && identical(x[[2L]], as.name('arguments')), TRUE))
stopifnot(length(entry) == 1L)
for (x in expressions[seq_len(entry-1L)]) eval(x, environment())
script <- 'inst/validation/mfrm-wide-map-d-n20-counterparts-20261011.R'
out <- 'validation-results/mfrm-wide-map-d-n20-counterparts-20261011'
prior <- 'validation-results/mfrm-wide-map-d-historical-two-family-r50-20261006/n20-sd1-common'
condition <- 'D:historical-full-common:N20:SD1:H-both'
previous_dispatch <- 'validation-results/mfrm-wide-map-d-counterparts-20261011/dispatch.rds'

make_spec <- function(row, templates) {
  stopifnot(row$Selector == 'views[[View]]$data', row$N == 20L, row$Truth == 'H-both')
  check_hashes(setNames(row$BundleMD5, row$Bundle))
  data <- readRDS(row$Bundle)$views[[row$View]]$data
  a <- templates[[if (row$Arm == arms[1L]) 'PCM-MML-free' else 'GPCM-MML-free']]$args
  a$data <- data; a$facets <- c('Task', 'Rater'); a$step_facet <- 'Rater'
  a$rating_max <- 2; a$person_data <- data.frame(Person = sort(unique(data$Person)))
  if (row$Arm != arms[1L]) a$slope_facet <- if (row$Arm == arms[2L]) 'Task' else 'Rater'
  stopifnot(nrow(data) == row$ObservedRows, length(unique(data$Person)) == row$N,
            !anyDuplicated(data[c('Person', 'Task', 'Rater')]))
  spec <- list(ConditionId = row$ConditionId, Replicate = row$Replicate, Arm = row$Arm,
    InputId = paste(row$UnitId, row$View, row$BundleMD5, sep = ':'), args = a,
    facet = 'Task', level = .95, purpose = 'D_R50_response_point_comparison')
  wide_mml_validate(spec)
  spec
}

collect <- function(manifest) {
  contracts <- readRDS(contracts_path)$contracts
  generator <- 'inst/validation/mfrm-wide-map-d-inputs-20261001.R'
  definition <- Filter(function(x) is.call(x) && identical(x[[1L]], as.name('<-')) &&
    identical(x[[2L]], as.name('d_probability')), as.list(parse(generator)))
  stopifnot(length(definition) == 1L)
  reference <- new.env(parent = baseenv()); eval(definition[[1L]], reference)
  rows <- list(); files <- character()
  add <- function(job, initial, admitted, ready, reason, order, epoch, elapsed, mapping_errors) {
    truth <- contracts[[job$ConditionId]]$two_family_fixed_normal
    grid <- expand.grid(z = c(-2,-1,0,1,2), first = 1:3, second = 1:6, KEEP.OUT.ATTRS = FALSE)
    prob <- reference$d_probability(grid$z, grid$first, grid$second, truth)
    truth_contrast <- vapply(truth$locations, function(x) x[1]-x[2], 0)
    for (selection in c('initial', 'admitted')) {
      result <- if (selection == 'initial') initial else admitted
      available <- !is.null(result)
      if (selection == 'admitted' && available) stopifnot(isTRUE(ready))
      errors <- c(ProbabilityMSE = NA_real_, NormalizedScoreMSE = NA_real_,
                  TaskDiscrepancy = NA_real_, RaterDiscrepancy = NA_real_)
      if (available) {
        stopifnot(identical(result$grid[c('z','first','second')], grid),
          identical(dim(result$probabilities), dim(prob)))
        contrast <- vapply(result$parameters$locations, function(x) x[1]-x[2], 0)
        errors[] <- c(mean((result$probabilities-prob)^2),
          mean((result$normalized_expected_score-drop(prob %*% (0:2))/2)^2),
          contrast-truth_contrast)
        stopifnot(all(is.finite(errors)))
      }
      rows[[length(rows)+1L]] <<- cbind(job[1,c('ConditionId','Replicate','N','SD','Arm','BundleMD5')],
        data.frame(Selection = selection, Available = available, SourceReady = ready,
          Order = if (selection == 'initial') 31L else order, Reason = reason,
          MappingError = unname(mapping_errors[selection]), SourceEpoch = epoch, CalibrationSeconds = elapsed, t(errors), row.names = NULL))
    }
  }
  for (i in seq_len(nrow(manifest$jobs))) {
    job <- manifest$jobs[i, ]; file <- file.path(out, job$Job, 'outputs.rds')
    x <- read_phase(file)$payload; files <- c(files, file)
    stopifnot(identical(x$job, job), isTRUE(x$completed))
    reason <- paste(c(x$selected$error, x$selected$review$reason_codes,
      x$selected$review$local_calibration_review$review), collapse = ' ')
    elapsed <- sum(vapply(x$attempts, function(a) sum(a$fitting$elapsed, a$review$elapsed), 0))
    add(job, x$initial$value, x$admitted$value, isTRUE(x$selected$review$ready), reason,
      x$selected$order, wide_mml_hash(manifest$runtime$source), elapsed,
      c(initial = if (is.null(x$initial)) '' else x$initial$error,
        admitted = if (is.null(x$admitted)) '' else x$admitted$error))
  }
  for (i in seq_len(nrow(manifest$references))) {
    job <- manifest$references[i, ]; file <- file.path(prior, job$ReferenceJob, 'd-outputs.rds')
    x <- read_phase(file); files <- c(files, file)
    selected_path <- file.path(prior, job$ReferenceJob, 'selected.rds')
    selected <- read_phase(selected_path); files <- c(files, selected_path)
    stopifnot(identical(x$binding$selected, wide_mml_hash(selected$payload)))
    response <- x$payload$response
    stopifnot(max(abs(response$truth-reference$d_probability(rep(c(-2,-1,0,1,2), 18),
      rep(rep(1:3, each=5), 6), rep(1:6, each=15),
      contracts[[job$ConditionId]]$two_family_fixed_normal))) <= 1e-12)
    add(job, response$initial, response$admitted, response$source_ready,
      paste(c(selected$payload$point$error, selected$payload$point$value$reason_codes,
        selected$payload$point$value$local_calibration_review$review), collapse=' '),
      as.integer(sub('^q([0-9]+):.*', '\\1', response$source$stage)),
      wide_mml_hash(manifest$reference_runtime$source), NA_real_, response$errors)
  }
  rows <- do.call(rbind, rows); rownames(rows) <- NULL
  stopifnot(nrow(rows) == 2L*(nrow(manifest$jobs)+nrow(manifest$references)),
    !anyDuplicated(rows[c('ConditionId','Replicate','Arm','Selection')]))
  average <- function(x) if (length(x)) mean(x) else NA_real_
  group <- function(x, columns) split(x, do.call(paste, c(x[columns], sep='\r')))
  summary <- do.call(rbind, lapply(group(rows, c('ConditionId','Arm','Selection')), function(z) {
    stopifnot(setequal(z$Replicate, 1:50), nrow(z) == 50L)
    a <- z[z$Available, ]; delivery <- binom.test(nrow(a), 50L)$conf.int
    cbind(z[1,c('ConditionId','SD','Arm','Selection')], data.frame(Planned = 50L,
      Returned = nrow(a), DeliveryLower = delivery[1], DeliveryUpper = delivery[2],
      ProbabilityMSE = average(a$ProbabilityMSE), NormalizedScoreMSE = average(a$NormalizedScoreMSE),
      TaskBias = average(a$TaskDiscrepancy), TaskRMSE = sqrt(average(a$TaskDiscrepancy^2)),
      RaterBias = average(a$RaterDiscrepancy), RaterRMSE = sqrt(average(a$RaterDiscrepancy^2))))
  }))
  paired <- list()
  for (cell in unique(rows$ConditionId)) for (selection in c('initial','admitted')) {
    z <- rows[rows$ConditionId == cell & rows$Selection == selection, ]
    common <- Reduce(intersect, lapply(split(z, z$Arm), function(a) a$Replicate[a$Available]))
    ref <- z[z$Arm == reference_arm, ]
    for (arm in arms) for (subset in c('pair_returned','four_returned')) {
      other <- z[z$Arm == arm, ]; ix <- match(ref$Replicate, other$Replicate)
      stopifnot(!anyNA(ix)); other <- other[ix, ]
      keep <- if (subset == 'pair_returned') ref$Available & other$Available else ref$Replicate %in% common
      for (metric in c('ProbabilityMSE','NormalizedScoreMSE','TaskDiscrepancy','RaterDiscrepancy')) {
        d <- if (grepl('Discrepancy', metric)) other[[metric]]^2-ref[[metric]]^2 else other[[metric]]-ref[[metric]]
        d <- d[keep]; n <- length(d); se <- if (n > 1L) sd(d)/sqrt(n) else NA_real_
        paired[[length(paired)+1L]] <- data.frame(ConditionId = cell, Selection = selection,
          Arm = arm, Subset = subset, Metric = if (grepl('Discrepancy', metric)) paste0(metric,'Squared') else metric,
          Planned = 50L, CommonReturned = n, FourReturned = length(common),
          OtherOnly = sum(other$Available & !ref$Available), ReferenceOnly = sum(ref$Available & !other$Available),
          Neither = sum(!ref$Available & !other$Available), MeanDifference = average(d), MCSE = se,
          MCLower = if (n>1L) mean(d)-qt(.975,n-1)*se else NA_real_,
          MCUpper = if (n>1L) mean(d)+qt(.975,n-1)*se else NA_real_)
      }
    }
  }
  list(rows = rows, summary = summary, paired = do.call(rbind, paired),
    consumed = tools::md5sum(unique(files)), new_responses = 0L,
    scope = 'Descriptive original R50 H-both N20 SD1/common comparison. Initial finite values are diagnostic; admitted comparisons retain each source procedure and historical epoch. Positive paired loss differences favor two-family. Pair/four-return subsets are conditional, not all-attempt risk estimates; t-based Monte Carlo intervals are exploratory. No native misspecified-parameter coverage or general model-choice claim.')
}

if (sys.nframe() == 0L) {
  arguments <- commandArgs(trailingOnly = TRUE)
  stopifnot(length(arguments) >= 1L, arguments[1L] %in% c('prepare','run','summarize','replay'))
  mode <- arguments[1L]
  if (mode == 'prepare') {
    stopifnot(!dir.exists(out))
    index <- read.csv(registry, stringsAsFactors=FALSE)
    rows <- index[index$ConditionId == condition, ]
    references <- readRDS(file.path(prior, 'dispatch.rds'))
    completion <- read_phase(file.path(prior, 'native-summary.rds'))
    check_hashes(completion$binding$dispatch); check_hashes(completion$binding$outputs)
    stopifnot(nrow(rows) == 50L, setequal(rows$Replicate, 1:50),
      length(completion$binding$outputs) == 50L, references$new_responses == 0L)
    at <- match(rows$Replicate, references$rows$Replicate); stopifnot(!anyNA(at))
    rows$ReferenceJob <- references$rows$Job[at]; rows$Arm <- reference_arm
    stopifnot(setequal(file.path(prior, rows$ReferenceJob, 'd-outputs.rds'),
                       names(completion$binding$outputs)))
    templates <- read_phase(template_path)$payload$specs[c('PCM-MML-free','GPCM-MML-free')]
    jobs <- do.call(rbind, lapply(arms, function(arm) { x <- rows; x$Arm <- arm; x }))
    jobs <- jobs[order(jobs$Replicate, match(jobs$Arm, arms)), ]; rownames(jobs) <- NULL
    jobs$Job <- sprintf('job-%04d', seq_len(nrow(jobs)))
    stopifnot(nrow(jobs) == 150L)
    for (i in seq_len(nrow(jobs))) make_spec(jobs[i, ], templates)
    # The existing N240 runtime bridge already verifies relocated R/BLAS binaries.
    previous <- readRDS(previous_dispatch)
    check_hashes(previous$source); check_hashes(previous$inputs)
    runtime <- wide_mml_runtime(); stopifnot(identical(runtime, previous$runtime))
    for (n in setdiff(names(references$runtime), 'source'))
      stopifnot(identical(references$runtime[[n]], previous$reference_runtime[[n]]))
    for (i in seq_len(nrow(rows))) {
      row <- rows[i, ]; spec <- read_phase(file.path(prior, row$ReferenceJob, 'manifest.rds'))$payload$spec
      stopifnot(identical(spec$ConditionId, row$ConditionId), identical(spec$Replicate, row$Replicate),
        identical(spec$args$data, readRDS(row$Bundle)$views[[row$View]]$data))
      x <- read_phase(file.path(prior, row$ReferenceJob, 'd-outputs.rds'))
      s <- read_phase(file.path(prior, row$ReferenceJob, 'selected.rds'))
      stopifnot(identical(x$binding$selected, wide_mml_hash(s$payload)))
    }
    sources <- unique(c(script, base_script, names(previous$source)))
    inputs <- unique(c(previous_dispatch, names(previous$inputs), registry, contracts_path,
      template_path, rows$Bundle, file.path(prior, c('dispatch.rds','native-summary.rds')),
      file.path(prior, rows$ReferenceJob, 'd-outputs.rds'),
      file.path(prior, rows$ReferenceJob, 'selected.rds'),
      file.path(prior, rows$ReferenceJob, 'manifest.rds')))
    manifest <- list(jobs=jobs, references=rows, templates=templates, orders=c(31L,61L,121L),
      source=tools::md5sum(sources), inputs=tools::md5sum(inputs), runtime=runtime,
      reference_runtime=references$runtime, new_responses=0L,
      protocol=c('Original N20 SD1/common H-both R50 allocation; same inputs for all four models.',
        'Reuse point_job, native mapping and source-admission/retry functions without modification.',
        'Independent free-population PCM/Task-only/Rater-only fits; retain all fifty GMFRM outcomes.',
        'No outcome-based tuning. Initial finite maps are diagnostic, not admitted estimates.',
        'Fifty-attempt delivery and pair/four-return loss with exploratory MC uncertainty.',
        'No general model ranking, misspecified native coverage or interval qualification.'))
    check_hashes(manifest$source); check_hashes(manifest$inputs)
    dir.create(file.path(out, 'source'), recursive=TRUE)
    for (p in sources) {
      dest <- file.path(out, 'source', p); dir.create(dirname(dest), recursive=TRUE, showWarnings=FALSE)
      stopifnot(file.copy(p, dest))
    }
    wide_mml_save(manifest, file.path(out,'dispatch.rds'))
    write.csv(jobs[c('Job','ConditionId','Replicate','N','SD','Arm','ReferenceJob')],
      file.path(out,'jobs.csv'), row.names=FALSE)
    cat('Frozen 150 missing N20 counterpart jobs and 50 retained GMFRM outcomes. No fits.\n')
  } else {
    manifest <- readRDS(file.path(out,'dispatch.rds'))
    check_hashes(manifest$source); check_hashes(manifest$inputs)
    stopifnot(identical(wide_mml_runtime(), manifest$runtime))
    if (mode == 'run') {
      ids <- if (length(arguments)>1L) as.integer(arguments[-1L]) else seq_len(nrow(manifest$jobs))
      stopifnot(!anyNA(ids), !anyDuplicated(ids), all(ids %in% seq_len(nrow(manifest$jobs))))
      lock <- file.path(out,'RUNNING'); stopifnot(dir.create(lock,showWarnings=FALSE))
      execute <- function() {
        on.exit(unlink(lock,recursive=TRUE))
        writeLines(as.character(Sys.getpid()),file.path(lock,'pid'))
        chunks <- split(ids,rep(1:2,length.out=length(ids)))
        status <- parallel::mclapply(chunks,function(at) {
          for (i in at) point_job(manifest$jobs[i, ],manifest)
          TRUE
        },mc.cores=min(2L,length(chunks)),mc.set.seed=FALSE)
        stopifnot(all(vapply(status,isTRUE,TRUE)))
      }
      execute()
      cat('Completed requested jobs; cached phases were reused.\n')
    } else {
      for (name in c('fit_mfrm','compute_mml_parameter_covariance','simulate_mfrm_data'))
        trace(name,quote(stop('No numerical recomputation in summary/replay.')),
          where=asNamespace('mfrmr'),print=FALSE)
      result <- collect(manifest); result$summary_source <- tools::md5sum(script)
      file <- file.path(out,'comparison.rds')
      if (mode == 'replay') {
        stopifnot(identical(readRDS(file),result))
        cat('Fresh replay reproduced N20 comparison without fitting, generation or information.\n')
      } else {
        stopifnot(!file.exists(file)); wide_mml_save(result,file)
        for (n in c('rows','summary','paired'))
          write.csv(result[[n]],file.path(out,paste0(n,'.csv')),row.names=FALSE)
        print(result$summary[,c('Arm','Selection','Returned','ProbabilityMSE')],row.names=FALSE)
      }
    }
    check_hashes(manifest$source); check_hashes(manifest$inputs)
  }
}
