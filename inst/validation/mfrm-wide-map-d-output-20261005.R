# D's retained two-family stages. Source the unchanged MML/JML, multi-output
# and accounting helpers first. This is research execution, not a public API.
wide_d_bridge <- function(path = 'validation-results/mfrm-wide-map-d-fit-bridge-20261005/verified.rds') {
  record <- readRDS(path)
  stopifnot(identical(R.version.string, record$session[1L]),
    identical(tools::md5sum(names(record$sources)), record$sources),
    identical(tools::md5sum(names(record$inputs)), record$inputs),
    unname(tools::md5sum(getLoadedDLLs()[['mfrmr']][['path']])) == unname(record$loaded_binary))
  list(path = path, md5 = unname(tools::md5sum(path)), record = record)
}

wide_d_retained_job <- function(condition, replicate, bridge) {
  stopifnot(unname(tools::md5sum(bridge$path)) == bridge$md5,
    identical(readRDS(bridge$path), bridge$record))
  registry <- 'validation-results/mfrm-wide-map-r50-20261001/d-inputs/inputs.csv'
  stopifnot(unname(tools::md5sum(registry)) == unname(bridge$record$inputs[registry]))
  rows <- read.csv(registry, stringsAsFactors = FALSE)
  row <- rows[rows$ConditionId == condition & rows$Replicate == replicate, ]
  approved <- bridge$record$records
  approved <- approved[approved$ConditionId == condition & approved$Replicate == replicate, ]
  stopifnot(nrow(row) == 1L, nrow(approved) == 1L, isTRUE(approved$FitStageCompatible),
    identical(row$CandidateFit, approved$CandidateFit),
    identical(row$CandidateMD5, approved$CandidateMD5),
    unname(tools::md5sum(row$CandidateFit)) == row$CandidateMD5)
  input <- sub('^/Users/tohokusla/Dropbox/MFRM_Application/mfrmr/development/', '', row$Bundle)
  stopifnot(unname(tools::md5sum(input)) == row$BundleMD5)
  data <- readRDS(input)$case$data
  stage <- readRDS(row$CandidateFit)$stages[['31']]
  stopifnot(identical(wide_mml_hash(stage$fitting), approved$FittingFingerprint),
    identical(stage$fitting$value$config$replay_inputs[names(bridge$record$procedure)],
      bridge$record$procedure))
  args <- bridge$record$procedure; args$quad_points <- NULL; args$data <- data
  outputs <- list()
  for (j in seq_along(args$facets)) {
    owner <- args$facets[j]; levels <- sort(unique(as.character(data[[owner]])))
    C <- matrix(0, 1L, length(levels), dimnames = list('first_minus_second', levels))
    C[1L, 1:2] <- c(1, -1)
    outputs[[paste0('location', j)]] <- list(kind = 'location', facet = owner)
    outputs[[paste0('contrast', j)]] <- list(kind = 'contrast', facet = owner, contrasts = C)
  }
  outputs$slopes <- list(kind = 'slopes')
  binding <- list(path = bridge$path, md5 = bridge$md5, approved = approved,
    input = setNames(row$BundleMD5, input))
  spec <- list(ConditionId = condition, Arm = 'GPCM-two-family-MML', Replicate = replicate,
    InputId = paste(row$UnitId, row$View, row$BundleMD5, sep = ':'), args = args,
    outputs = outputs, level = .95, purpose = 'D_retained_comparison', fit_bridge = binding)
  retained <- list('31' = list(args = c(args, list(quad_points = 31L)),
    fitting = stage$fitting, provenance = binding))
  wide_multi_validate(spec)
  list(spec = spec, retained = retained)
}

wide_d_validate_retained <- function(spec, retained) {
  b <- spec$fit_bridge
  stopifnot(identical(spec$purpose, 'D_retained_comparison'),
    identical(names(retained), '31'), identical(spec$args$method, 'MML'),
    identical(spec$args$slope_facet, c('Task', 'Rater')),
    unname(tools::md5sum(b$path)) == b$md5,
    identical(tools::md5sum(names(b$input)), b$input))
  record <- readRDS(b$path)
  row <- record$records[record$records$ConditionId == spec$ConditionId &
    record$records$Replicate == spec$Replicate, ]
  stopifnot(identical(row, b$approved), nrow(row) == 1L,
    identical(retained[['31']]$provenance, b),
    unname(tools::md5sum(row$CandidateFit)) == row$CandidateMD5,
    identical(wide_mml_hash(retained[['31']]$fitting), row$FittingFingerprint))
  args <- spec$args; args$data <- NULL; args$quad_points <- 31L
  stopifnot(identical(args[names(record$procedure)], record$procedure))
  original <- readRDS(names(b$input))$case$data
  stopifnot(identical(spec$args$data, original))
  invisible(TRUE)
}

wide_d_runtime <- function() {
  x <- wide_multi_runtime()
  x$source <- c(x$source, tools::md5sum('inst/validation/mfrm-wide-map-d-output-20261005.R'))
  x
}

wide_d_consumers <- function(source_fit, joint) {
  # Execute the unmodified public consumer bodies in a private environment.
  # Only the costly inference call is replaced by its exact saved result for
  # this identical fit; neither the package namespace nor the fit is changed.
  context <- new.env(parent = asNamespace('mfrmr'))
  context$mfrm_gpcm_product_inference <- function(fit) {
    stopifnot(identical(fit, source_fit))
    if (nzchar(joint$error)) stop(joint$error, call. = FALSE)
    joint$value
  }
  facet <- mfrmr::mfrm_facet_intervals
  slopes <- getS3method('confint', 'mfrm_fit', envir = asNamespace('mfrmr'))
  environment(facet) <- environment(slopes) <- context
  function(fit, consumer, level) {
    stopifnot(identical(fit, source_fit))
    if (consumer$kind == 'slopes') slopes(fit, parm = 'slopes', method = 'model',
      level = level, scale = 'standardized') else facet(fit, consumer$facet,
        contrasts = consumer$contrasts, level = level)
  }
}

# The shared runner below retains its phase, retry and failure rules.
wide_d_output_run <- function(spec, out, retained) {
  wide_d_validate_retained(spec, retained)
  plan <- wide_multi_plan(spec); mml <- spec$args$method == "MML"
  orders <- if (mml) c(31L, 61L, 121L) else 0L
  for (key in names(retained)) {
    z <- retained[[key]]; args <- spec$args
    if (mml) args$quad_points <- as.integer(key)
    stopifnot(spec$purpose == "D_retained_comparison", key %in% as.character(orders),
      identical(z$args, args), is.list(z$fitting), length(z$provenance) > 0L)
  }
  stopifnot(length(retained) == length(names(retained)), !anyDuplicated(names(retained)))
  runtime <- wide_d_runtime()
  manifest <- list(spec = spec, runtime = runtime, retained = retained, orders = orders)
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  old <- wide_mml_phase(file.path(out, "manifest.rds"), "d-retained-shared-fit-outputs-v1", function() manifest)
  if (!identical(old, manifest)) stop("Shared job data/settings/source/output plan changed.")
  identity <- wide_mml_hash(manifest); finished <- FALSE; phase <- "start"; q <- orders[1]
  state <- function(status) wide_mml_save(list(identity = identity, status = status, phase = phase,
    order = q, time = Sys.time()), file.path(out, "status.rds"))
  on.exit(if (!finished) state("interrupted"), add = TRUE)
  run <- function(name, dependency, compute) {
    phase <<- name; state("running")
    wide_mml_phase(file.path(out, paste0("q", q, "-", name, ".rds")),
      list(job = identity, order = q, phase = name, dependency = dependency), compute)
  }
  need_point <- TRUE
  pending <- unique(plan$Consumer[plan$Output == "interval" & plan$Eligibility == "eligible"])
  point <- NULL; intervals <- list(); stages <- list()
  for (q in orders) {
    args <- spec$args; if (mml) args$quad_points <- q
    fitting <- run("fit", NULL, function() {
      if (!is.null(retained[[as.character(q)]])) return(retained[[as.character(q)]]$fitting)
      wide_mml_capture(function() wide_mml_fit(args))
    })
    fit <- fitting$value; hash <- wide_mml_hash(fitting); stage <- paste0("q", q, ":", hash)
    failed <- list(stage = stage, fit_hash = hash, error = fitting$error, value = NULL, table = NULL)
    if (nzchar(fitting$error)) {
      if (need_point) point <- failed
      for (id in pending) intervals[[id]] <- failed
      stages[[as.character(q)]] <- list(stage = stage, fit_error = fitting$error)
      break
    }
    stopifnot(inherits(fit, "mfrm_fit"), identical(fit$config$method, spec$args$method),
      identical(fit$config$model, spec$args$model))
    if (mml) stopifnot(fit$config$estimation_control$quad_points == q) else {
      order <- spec$args$jml_correction_order
      if (is.null(order)) stopifnot(!mfrmr:::mfrm_has_jml_adjustment(fit)) else stopifnot(
        identical(fit$jml_adjustment$estimator$order, as.integer(order)),
        identical(fit$jml_adjustment$estimator$sampling, spec$args$jml_correction_sampling))
    }
    retry_point <- FALSE
    if (need_point) {
      review <- run("scoring-source", hash, function() wide_mml_capture(function()
        if (mml) wide_mml_score(fit) else wide_jml_source(fit)))
      point <- list(stage = stage, fit_hash = hash, error = review$error, value = review$value,
        table = wide_multi_points(fit, spec))
      retry_point <- mml && !nzchar(review$error) && wide_mml_scoring_retry(review$value)
      need_point <- retry_point && q < 121L
    }
    next_pending <- character()
    consume <- wide_multi_consume
    if (length(pending)) {
      joint <- run("joint-inference", hash, function() wide_mml_capture(function()
        mfrmr:::mfrm_gpcm_product_inference(fit)))
      consume <- wide_d_consumers(fit, joint)
    }
    for (id in pending) {
      consumer <- spec$outputs[[id]]
      result <- run(paste0("interval-", id), hash, function() wide_mml_capture(function() {
        value <- consume(fit, consumer, spec$level)
        list(object = value, table = wide_multi_interval_table(value, spec, consumer, fit),
          retry = wide_multi_retry(value, consumer))
      }))
      intervals[[id]] <- list(stage = stage, fit_hash = hash, error = result$error,
        value = result$value$object, table = result$value$table)
      if (!nzchar(result$error) && isTRUE(result$value$retry) && q < 121L) next_pending <- c(next_pending, id)
    }
    stages[[as.character(q)]] <- list(stage = stage, fit_error = "", retry_point = retry_point,
      interval_consumers = pending, retry_intervals = next_pending)
    pending <- next_pending
    if (!need_point && !length(pending)) break
  }
  stopifnot(identical(wide_d_runtime(), runtime))
  selected <- list(identity = identity, spec_hash = wide_mml_hash(spec), plan = plan,
    point = point, intervals = intervals, stages = stages,
    initial_stage = paste0("q", orders[1], "-fit.rds"))
  result <- wide_mml_phase(file.path(out, "selected.rds"), identity, function() selected)
  stopifnot(identical(result, selected)); phase <- "complete"; state("complete"); finished <- TRUE
  result
}

