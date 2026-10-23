# Complete D's existing N240 response/point comparison, without new responses.
# Reuse the two-family outputs; run only the three missing calibration arms.
# Usage: Rscript --vanilla THIS_FILE prepare|run|summarize|replay [JOB ...]
pkgload::load_all('.', quiet = TRUE, compile = FALSE, helpers = FALSE)
source('inst/validation/mfrm-wide-map-mml-stages-20261001.R')
source('inst/validation/mfrm-wide-map-d-response-20261005.R')
script <- 'inst/validation/mfrm-wide-map-d-counterparts-20261011.R'
out <- 'validation-results/mfrm-wide-map-d-counterparts-20261011'
prior <- 'validation-results/mfrm-wide-map-d-retained-output-20261005'
registry <- 'validation-results/mfrm-wide-map-r50-20261001/d-inputs/inputs.csv'
contracts_path <- 'validation-results/mfrm-wide-map-r50-20261001/d-inputs/target-contracts.rds'
template_path <- 'validation-results/mfrm-wide-map-recovery-20261002/witness-manifest.rds'
arms <- c('PCM-MML-free-population', 'GPCM-first-owner-MML-free-population',
          'GPCM-second-owner-MML-free-population')
reference_arm <- 'two-family-MML-fixed-normal'
check_hashes <- function(h) stopifnot(length(h) > 0L, !anyNA(h),
                                     identical(tools::md5sum(names(h)), h))
read_phase <- function(path) {
  x <- readRDS(path)
  stopifnot(identical(x$checksum, wide_mml_hash(x$payload)))
  x
}
make_spec <- function(row, templates) {
  stopifnot(row$Selector == 'case$data', row$N == 240L, row$Truth == 'H-both')
  check_hashes(setNames(row$BundleMD5, row$Bundle))
  data <- readRDS(row$Bundle)$case$data
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

# Independent literal adjacent-logit evaluation on the native population scale.
check_mapping <- function(fit, mapped) {
  p <- mfrmr:::expand_params(fit$opt$par, mfrmr:::build_param_sizes(fit$config), fit$config)
  g <- mapped$grid; mu <- unname(p$population$coefficients); sd <- sqrt(p$population$sigma2)
  eta <- mu + sd * g$z - p$facets$Task[g$first] - p$facets$Rater[g$second]
  slope <- rep(1, nrow(g))
  if (fit$config$model == 'GPCM') slope <- p$slopes[
    if (fit$config$slope_facet == 'Task') g$first else g$second]
  logmass <- matrix(0, nrow(g), 3L)
  for (k in 1:2) logmass[, k+1L] <- logmass[, k] + slope * (eta-p$steps_mat[g$second,k])
  probability <- exp(logmass-apply(logmass, 1L, max)); probability <- probability/rowSums(probability)
  error <- max(abs(probability-mapped$probabilities))
  stopifnot(is.finite(error), error <= 1e-12,
    max(abs(rowSums(mapped$probabilities)-1)) <= 1e-12)
  error
}

point_job <- function(row, manifest) {
  spec <- make_spec(row, manifest$templates)
  path <- file.path(out, row$Job); dir.create(path, showWarnings = FALSE)
  binding <- list(dispatch = unname(tools::md5sum(file.path(out, 'dispatch.rds'))),
                  job = row$Job, spec = wide_mml_hash(spec))
  result_path <- file.path(path, 'outputs.rds')
  if (file.exists(result_path)) return(wide_mml_phase(result_path, binding, function() stop('Unreachable')))
  cat('Starting', row$Job, row$ConditionId, 'rep', row$Replicate, row$Arm, '\n'); flush.console()
  saved <- wide_mml_phase(file.path(path, 'manifest.rds'), binding, function() spec)
  stopifnot(identical(saved, spec))
  initial <- admitted <- NULL; selected <- list(); attempts <- list(); mapping_error <- numeric()
  map <- function(fit) {
    value <- wide_d_response_points(fit)
    mapping_error <<- c(mapping_error, check_mapping(fit, value))
    value
  }
  for (q in manifest$orders) {
    phase <- function(name, dependency, call) wide_mml_phase(
      file.path(path, paste0('q', q, '-', name, '.rds')),
      list(job = binding, order = q, phase = name, dependency = dependency), call)
    fitting <- phase('fit', NULL, function() wide_mml_capture(function()
      wide_mml_fit(c(spec$args, list(quad_points = q)))))
    fh <- wide_mml_hash(fitting)
    selected <- list(order = q, fit_hash = fh, error = fitting$error, review = NULL)
    attempts[[as.character(q)]] <- list(fitting = fitting[c('elapsed','error','warnings')])
    if (nzchar(fitting$error)) break
    fit <- fitting$value
    stopifnot(inherits(fit, 'mfrm_fit'), fit$config$estimation_control$quad_points == q)
    if (q == 31L) initial <- wide_mml_capture(function() map(fit))
    review <- phase('scoring-source', fh, function() wide_mml_capture(function() wide_mml_score(fit)))
    selected$error <- review$error; selected$review <- review$value
    attempts[[as.character(q)]]$review <- review[c('elapsed','error','warnings')]
    if (!nzchar(review$error) && isTRUE(review$value$ready)) {
      admitted <- wide_mml_capture(function() map(fit)); break
    }
    if (nzchar(review$error) || !wide_mml_scoring_retry(review$value)) break
  }
  value <- list(job = row, initial = initial, admitted = admitted, selected = selected,
    attempts = attempts, mapping_error = mapping_error, completed = TRUE)
  wide_mml_phase(result_path, binding, function() value)
  cat('Completed', row$Job, 'q', selected$order, 'source',
      isTRUE(selected$review$ready), '\n'); flush.console()
  invisible(value)
}

collect <- function(manifest) {
  contracts <- readRDS(contracts_path)$contracts
  generator <- 'inst/validation/mfrm-wide-map-d-inputs-20261001.R'
  definition <- Filter(function(x) is.call(x) && identical(x[[1L]], as.name('<-')) &&
    identical(x[[2L]], as.name('d_probability')), as.list(parse(generator)))
  stopifnot(length(definition) == 1L)
  reference <- new.env(parent = baseenv()); eval(definition[[1L]], reference)
  rows <- list(); files <- character()
  add <- function(job, initial, admitted, ready, reason, order, epoch, elapsed) {
    truth <- contracts[[job$ConditionId]]$two_family_fixed_normal
    grid <- expand.grid(z = c(-2,-1,0,1,2), first = 1:3, second = 1:6)
    prob <- reference$d_probability(grid$z, grid$first, grid$second, truth)
    truth_contrast <- vapply(truth$locations, function(x) x[1]-x[2], 0)
    for (selection in c('initial', 'admitted')) {
      result <- if (selection == 'initial') initial else admitted
      available <- !is.null(result)
      errors <- c(ProbabilityMSE = NA_real_, NormalizedScoreMSE = NA_real_,
                  TaskDiscrepancy = NA_real_, RaterDiscrepancy = NA_real_)
      if (available) {
        stopifnot(identical(result$grid[c('z','first','second')], grid),
          identical(dim(result$probabilities), dim(prob)))
        contrast <- vapply(result$parameters$locations, function(x) x[1]-x[2], 0)
        errors[] <- c(mean((result$probabilities-prob)^2),
          mean((result$normalized_expected_score-drop(prob %*% (0:2))/2)^2),
          contrast-truth_contrast)
      }
      rows[[length(rows)+1L]] <<- cbind(job[1,c('ConditionId','Replicate','N','SD','Arm','BundleMD5')],
        data.frame(Selection = selection, Available = available, SourceReady = ready,
          Order = if (selection == 'initial') 31L else order, Reason = reason,
          SourceEpoch = epoch, CalibrationSeconds = elapsed, t(errors), row.names = NULL))
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
      x$selected$order, wide_mml_hash(manifest$runtime$source), elapsed)
  }
  for (i in seq_len(nrow(manifest$references))) {
    job <- manifest$references[i, ]; file <- file.path(prior, job$ReferenceJob, 'd-outputs.rds')
    x <- read_phase(file); files <- c(files, file)
    selected_path <- file.path(prior, job$ReferenceJob, 'selected.rds')
    selected <- read_phase(selected_path); files <- c(files, selected_path)
    stopifnot(identical(x$binding$selected, wide_mml_hash(selected$payload)))
    response <- x$payload$response
    stopifnot(max(abs(response$truth-reference$d_probability(response$initial$grid$z,
      response$initial$grid$first, response$initial$grid$second,
      contracts[[job$ConditionId]]$two_family_fixed_normal))) <= 1e-12)
    add(job, response$initial, response$admitted, response$source_ready,
      paste(c(selected$payload$point$error, selected$payload$point$value$reason_codes,
        selected$payload$point$value$local_calibration_review$review), collapse=' '),
      as.integer(sub('^q([0-9]+):.*', '\\1', response$source$stage)),
      wide_mml_hash(manifest$reference_runtime$source), NA_real_)
  }
  rows <- do.call(rbind, rows); rownames(rows) <- NULL
  stopifnot(nrow(rows) == 1600L,
    !anyDuplicated(rows[c('ConditionId','Replicate','Arm','Selection')]))
  group <- function(x, columns) split(x, do.call(paste, c(x[columns], sep='\r')))
  summary <- do.call(rbind, lapply(group(rows, c('ConditionId','Arm','Selection')), function(z) {
    stopifnot(setequal(z$Replicate, 1:50), nrow(z) == 50L)
    a <- z[z$Available, ]; delivery <- binom.test(nrow(a), 50L)$conf.int
    cbind(z[1,c('ConditionId','SD','Arm','Selection')], data.frame(Planned = 50L,
      Returned = nrow(a), DeliveryLower = delivery[1], DeliveryUpper = delivery[2],
      ProbabilityMSE = mean(a$ProbabilityMSE), NormalizedScoreMSE = mean(a$NormalizedScoreMSE),
      TaskBias = mean(a$TaskDiscrepancy), TaskRMSE = sqrt(mean(a$TaskDiscrepancy^2)),
      RaterBias = mean(a$RaterDiscrepancy), RaterRMSE = sqrt(mean(a$RaterDiscrepancy^2))))
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
          Neither = sum(!ref$Available & !other$Available), MeanDifference = mean(d), MCSE = se,
          MCLower = if (n>1L) mean(d)-qt(.975,n-1)*se else NA_real_,
          MCUpper = if (n>1L) mean(d)+qt(.975,n-1)*se else NA_real_)
      }
    }
  }
  list(rows = rows, summary = summary, paired = do.call(rbind, paired),
    consumed = tools::md5sum(unique(files)), new_responses = 0L,
    scope = 'Descriptive original R50 H-both N240 comparison. Initial finite values are diagnostic; admitted comparisons retain each source procedure and historical epoch. Positive paired loss differences favor two-family. Pair/four-return subsets are conditional, not all-attempt risk estimates; t-based Monte Carlo intervals are exploratory. No native misspecified-parameter coverage or general model-choice claim.')
}

arguments <- commandArgs(trailingOnly = TRUE)
stopifnot(length(arguments) >= 1L, arguments[1L] %in% c('prepare','run','summarize','replay'))
mode <- arguments[1L]
if (mode == 'prepare') {
  stopifnot(!dir.exists(out))
  index <- read.csv(registry, stringsAsFactors = FALSE)
  references <- readRDS(file.path(prior, 'dispatch.rds'))
  rows <- index[index$N == 240L & index$Truth == 'H-both' & grepl('^D:historical-full-', index$ConditionId), ]
  stopifnot(nrow(rows) == 200L, all(table(rows$ConditionId) == 50L))
  keys <- function(x) paste(x$ConditionId, x$Replicate, sep='\r')
  at <- match(keys(rows), keys(references$rows)); stopifnot(!anyNA(at))
  rows$ReferenceJob <- references$rows$Job[at]; rows$Arm <- reference_arm
  templates <- read_phase(template_path)$payload$specs[c('PCM-MML-free','GPCM-MML-free')]
  jobs <- do.call(rbind, lapply(arms, function(arm) { x <- rows; x$Arm <- arm; x }))
  jobs <- jobs[order(jobs$ConditionId, jobs$Replicate, match(jobs$Arm, arms)), ]
  rownames(jobs) <- NULL; jobs$Job <- sprintf('job-%04d', seq_len(nrow(jobs)))
  stopifnot(nrow(jobs) == 600L)
  for (i in seq_len(nrow(jobs))) make_spec(jobs[i, ], templates)
  runtime <- wide_mml_runtime()
  for (n in setdiff(intersect(names(runtime), names(references$runtime)), c('source','libraries')))
    stopifnot(identical(runtime[[n]], references$runtime[[n]]))
  # The original extracted R home is gone. Verify its recorded binaries, then
  # normalize only the two absolute library paths in extSoftVersion().
  lock_path <- 'inst/validation/runtime-lock-20261009.json'
  binary_hashes <- jsonlite::fromJSON(lock_path)$R$HistoricalBinarySHA256
  runtime_binaries <- c('bin/exec/R','lib/libR.dylib','lib/libRblas.0.dylib',
    'lib/libRlapack.dylib','modules/lapack.so','library/stats/libs/stats.so')
  for (p in runtime_binaries) stopifnot(identical(
    digest::digest(file=file.path(R.home(),p), algo='sha256', serialize=FALSE), binary_hashes[[p]]))
  lib <- runtime$libraries; oldlib <- references$runtime$libraries
  stopifnot(identical(lib[!names(lib) %in% c('iconv','BLAS')], oldlib[!names(oldlib) %in% c('iconv','BLAS')]),
    identical(sub(' /.*','',lib['iconv']), sub(' /.*','',oldlib['iconv'])),
    identical(basename(lib['BLAS']), basename(oldlib['BLAS'])))
  sources <- unique(c(script, names(runtime$source)[names(runtime$source) != 'loaded:mfrmr'],
    'src/mfrmr.so', 'inst/validation/mfrm-wide-map-d-response-20261005.R',
    'inst/validation/mfrm-wide-map-d-inputs-20261001.R'))
  inputs <- unique(c(registry, contracts_path, template_path, rows$Bundle,
    lock_path, file.path(R.home(), runtime_binaries),
    file.path(prior, 'dispatch.rds'), file.path(prior, 'complete-n240-summary.rds'),
    file.path(prior, rows$ReferenceJob, 'd-outputs.rds'), file.path(prior, rows$ReferenceJob, 'selected.rds'),
    file.path(prior, rows$ReferenceJob, 'manifest.rds')))
  for (i in seq_len(nrow(rows))) {
    row <- rows[i, ]; spec <- read_phase(file.path(prior,row$ReferenceJob,'manifest.rds'))$payload$spec
    stopifnot(identical(spec$ConditionId, row$ConditionId), identical(spec$Replicate, row$Replicate),
      identical(spec$args$data, readRDS(row$Bundle)$case$data))
  }
  manifest <- list(jobs = jobs, references = rows, templates = templates, orders = c(31L,61L,121L),
    source = tools::md5sum(sources), inputs = tools::md5sum(inputs), runtime = runtime,
    reference_runtime = references$runtime,
    protocol = c('Original N240 R50 allocation: both SDs and rosters; no response generation.',
      'Reuse existing MML fit settings and integration-only source retries; no outcome-based tuning.',
      'First/second standardized location contrast and equal-context/z/category probability MSE.',
      'Initial diagnostics, admitted output, all-attempt delivery and paired common-return loss stay separate.',
      'Point-stage completion only; structural intervals and held-out scoring remain separate.',
      'Smaller/larger N, reduced truths and new magnitude/alignment sensitivities remain open.'))
  check_hashes(manifest$source); check_hashes(manifest$inputs)
  dir.create(file.path(out, 'source'), recursive = TRUE)
  for (p in sources) {
    dest <- file.path(out, 'source', p); dir.create(dirname(dest), recursive=TRUE, showWarnings=FALSE)
    stopifnot(file.copy(p, dest))
  }
  wide_mml_save(manifest, file.path(out, 'dispatch.rds'))
  write.csv(jobs[c('Job','ConditionId','Replicate','N','SD','Arm','ReferenceJob')],
    file.path(out, 'jobs.csv'), row.names = FALSE)
  cat('Frozen 600 missing point-calibration jobs and 200 retained two-family results. No fits.\n')
} else {
  manifest <- readRDS(file.path(out, 'dispatch.rds'))
  check_hashes(manifest$source); check_hashes(manifest$inputs)
  stopifnot(identical(wide_mml_runtime(), manifest$runtime))
  if (mode == 'run') {
    ids <- if (length(arguments)>1L) as.integer(arguments[-1L]) else seq_len(nrow(manifest$jobs))
    stopifnot(!anyNA(ids), !anyDuplicated(ids), all(ids %in% seq_len(nrow(manifest$jobs))))
    lock <- file.path(out, 'RUNNING'); stopifnot(dir.create(lock, showWarnings=FALSE))
    run <- function() {
      on.exit(unlink(lock, recursive=TRUE))
      writeLines(as.character(Sys.getpid()), file.path(lock, 'pid'))
      for (i in ids) point_job(manifest$jobs[i, ], manifest)
    }
    run()
  } else {
    for (name in c('fit_mfrm','compute_mml_parameter_covariance','simulate_mfrm'))
      trace(name, quote(stop('No numerical recomputation in summary/replay.')),
        where=asNamespace('mfrmr'), print=FALSE)
    result <- collect(manifest)
    file <- file.path(out, 'comparison.rds')
    if (mode == 'replay') {
      stopifnot(identical(readRDS(file), result))
      cat('Fresh replay reproduced all rows and paired summaries without fitting.\n')
    } else {
      stopifnot(!file.exists(file)); wide_mml_save(result, file)
      for (n in c('rows','summary','paired')) write.csv(result[[n]], file.path(out,paste0(n,'.csv')), row.names=FALSE)
      print(result$summary[,c('ConditionId','Arm','Selection','Returned','ProbabilityMSE')], row.names=FALSE)
    }
  }
  check_hashes(manifest$source); check_hashes(manifest$inputs)
}
