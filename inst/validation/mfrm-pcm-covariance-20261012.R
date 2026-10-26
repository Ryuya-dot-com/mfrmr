# One matched PCM covariance comparison; no response generation or native refit.
# Usage: Rscript --vanilla THIS_FILE prepare|conquest [61|121]
source('inst/validation/mfrm-wide-map-d-pcm-external-review-20261012.R')
covariance_script <- 'inst/validation/mfrm-pcm-covariance-20261012.R'
covariance_dir <- file.path(bridge_dir, 'covariance-review')

covariance_main <- function(mode, q = NULL) {
  m <- readRDS(file.path(bridge_dir, 'manifest.rds'))
  correction <- readRDS(review_manifest)
  for (h in list(m$source, m$inputs, correction$source, correction$inputs)) check_hashes(h)
  stopifnot(identical(wide_mml_runtime(), m$runtime),
    identical(digest::digest(file = bridge_executable, algo = 'sha256'), m$ConQuest))
  for (name in c('fit_mfrm', 'simulate_mfrm_data'))
    trace(name, quote(stop('Covariance review cannot refit or generate native data.')),
      where = asNamespace('mfrmr'), print = FALSE)
  record_path <- file.path(covariance_dir, 'manifest.rds')
  if (mode == 'prepare') {
    stopifnot(!dir.exists(covariance_dir))
    dir.create(covariance_dir)
    inputs <- c(file.path(bridge_dir, 'manifest.rds'), review_manifest)
    for (order in c(61L, 121L)) {
      old <- file.path(bridge_dir, paste0('conquest-task-first-q', order))
      read_cq(old, m)
      target <- file.path(covariance_dir, paste0('q', order)); dir.create(target)
      stopifnot(file.copy(file.path(old, 'responses.csv'), target))
      command <- sub('stderr=quick', 'stderr=empirical',
        readLines(file.path(old, 'commands.cqc')), fixed = TRUE)
      command <- append(command, c(
        'write bridge_estimatecovariances ! filetype=csv >> estimatecovariances.csv;',
        'print bridge_estimatecovariances ! decimals=12, labels=yes;',
        'show parameters ! tables=10 >> covariance-review.txt;',
        'put ! compress=no >> fitted-state.sys;'), after = length(command)-1L)
      writeLines(command, file.path(target, 'commands.cqc'))
      inputs <- c(inputs, file.path(old, 'execution.rds'),
        file.path(target, c('responses.csv', 'commands.cqc')))
    }
    record <- list(source = tools::md5sum(c(covariance_script, names(m$source),
        names(correction$source))), inputs = tools::md5sum(inputs),
      runtime = wide_mml_runtime(), executable = m$ConQuest,
      tolerance = c(covariance_scaled = 1e-3, relative_se = 1e-3,
        grid_covariance_scaled = 1e-4, map = 1e-10),
      protocol = c('Same N60 PCM response/model/constraints and original neutral starts.',
        'Only stderr changes to empirical; export full estimate covariance and preserve state.',
        'q61/q121 check covariance integration sensitivity; no native or TAM refit.',
        'Compare 15 identified parameters, including mean/variance cross-covariance.',
        'Scale matrix differences by sqrt(V_ii V_jj); tolerances fixed before output.',
        'Reuse point evidence; downstream indices are sensitivity calculations, not coverage.',
        'No change to public formulas or N480 frozen source.'))
    saveRDS(record, record_path)
    cat('Prepared two covariance exports for the one retained PCM dataset.\n')
    return(invisible(record))
  }
  stopifnot(mode == 'conquest', q %in% c(61L, 121L))
  record <- readRDS(record_path)
  check_hashes(record$source); check_hashes(record$inputs)
  stopifnot(identical(wide_mml_runtime(), record$runtime))
  directory <- file.path(covariance_dir, paste0('q', q))
  stopifnot(!file.exists(file.path(directory, 'console.txt')))
  old <- getwd(); on.exit(setwd(old), add = TRUE); setwd(directory)
  started <- proc.time()
  status <- system2('/usr/bin/arch', c('-x86_64', shQuote(bridge_executable)),
    input = readLines('commands.cqc'), stdout = 'console.txt', stderr = 'stderr.txt')
  saveRDS(list(status = status, timing = proc.time()-started,
    files = tools::md5sum(list.files(pattern = '[.](csv|txt|cqc|sys)$'))), 'execution.rds')
  stopifnot(status == 0L, any(grepl('End of Program', readLines('console.txt'), fixed = TRUE)))
  cat('ConQuest empirical covariance completed q', q, '\n')
}
if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE)
  stopifnot(length(args) >= 1L, args[1] %in% c('prepare', 'conquest'))
  covariance_main(args[1], if (length(args) > 1L) as.integer(args[2]) else NULL)
}
