# D's fresh historical two-family cells, using the qualified shared-output runner.
# No response generation or change to fitting, retry, information or refusal rules.
# Source after the existing D output, response and multi-output helpers.
wide_d_fresh_script <- 'inst/validation/mfrm-wide-map-d-fresh-two-family-20261006.R'

wide_d_fresh_data <- function(path, selector, view) {
  bundle <- readRDS(path)
  switch(selector, 'case$data' = bundle$case$data,
         'views[[View]]$data' = bundle$views[[view]]$data,
         stop('Historical input selector is not qualified.'))
}

wide_d_fresh_spec <- function(row, prototype_path) {
  stopifnot(nrow(row) == 1L, grepl('^D:historical-full-', row$ConditionId),
            row$Truth == 'H-both')
  input <- sub('^/Users/tohokusla/Dropbox/MFRM_Application/mfrmr/development/', '', row$Bundle)
  stopifnot(unname(tools::md5sum(input)) == row$BundleMD5)
  data <- wide_d_fresh_data(input, row$Selector, row$View)
  stopifnot(is.data.frame(data), nrow(data) == row$ObservedRows,
            length(unique(data$Person)) == row$N)
  prototype <- readRDS(prototype_path)
  stopifnot(identical(prototype$checksum, wide_mml_hash(prototype$payload)),
            identical(prototype$payload$runtime, wide_d_runtime()))
  original <- prototype$payload$spec
  args <- original$args; args$data <- data
  spec <- list(ConditionId = row$ConditionId, Arm = original$Arm,
    Replicate = row$Replicate, InputId = paste(row$UnitId, row$View, row$BundleMD5, sep = ':'),
    args = args, outputs = original$outputs, level = original$level,
    purpose = 'D_fresh_historical_two_family',
    input_source = setNames(row$BundleMD5, input),
    input_selector = row$Selector, input_view = row$View,
    procedure_source = tools::md5sum(prototype_path),
    execution_source = tools::md5sum(wide_d_fresh_script))
  wide_multi_validate(spec)
  spec
}

wide_d_fresh_validate <- function(spec, retained) {
  stopifnot(length(retained) == 0L,
            identical(spec$purpose, 'D_fresh_historical_two_family'))
  for (h in list(spec$input_source, spec$procedure_source, spec$execution_source))
    stopifnot(length(h) > 0L, identical(tools::md5sum(names(h)), h))
  stopifnot(length(spec$input_source) == 1L,
    identical(spec$args$data, wide_d_fresh_data(names(spec$input_source),
      spec$input_selector, spec$input_view)))
  prototype <- readRDS(names(spec$procedure_source))
  stopifnot(identical(prototype$checksum, wide_mml_hash(prototype$payload)),
            identical(prototype$payload$runtime, wide_d_runtime()))
  original <- prototype$payload$spec; args <- original$args
  args$data <- spec$args$data
  stopifnot(identical(args, spec$args), identical(original$outputs, spec$outputs),
            identical(original$level, spec$level))
  wide_multi_validate(spec)
  invisible(TRUE)
}

wide_d_fresh_run <- function(spec, out) {
  # Only admission of a new input replaces the retained-fit bridge. The entire
  # fit/selection/retry/shared-information body remains the qualified function.
  run <- wide_d_output_run
  environment(run) <- list2env(list(wide_d_validate_retained = wide_d_fresh_validate),
                              parent = environment(wide_d_output_run))
  stopifnot(identical(body(run), body(wide_d_output_run)),
            identical(formals(run), formals(wide_d_output_run)))
  run(spec, out, retained = list())
}

wide_d_fresh_collect <- function(spec, selected, path, contracts_path, generator) {
  stopifnot(identical(selected$spec_hash, wide_mml_hash(spec)))
  contract <- readRDS(contracts_path)$contracts[[spec$ConditionId]]
  truth <- contract$two_family_fixed_normal
  stopifnot(isTRUE(contract$correctly_specified[['two_family']]),
            identical(truth$facets, spec$args$facets))
  # Truth is read after the frozen procedure has selected each output.
  plan <- selected$plan
  for (id in names(spec$outputs)) {
    consumer <- spec$outputs[[id]]; targets <- wide_multi_targets(spec, consumer)
    values <- vapply(seq_len(nrow(targets)), function(j) {
      owner <- targets$Owner[j]; at <- match(targets$Level[j], truth$levels[[owner]])
      if (consumer$kind == 'contrast') {
        C <- wide_multi_contrast(spec, consumer)
        return(drop(C[targets$Level[j], , drop = FALSE] %*%
          truth$locations[[owner]][match(colnames(C), truth$levels[[owner]])]))
      }
      stopifnot(!is.na(at))
      if (consumer$kind == 'slopes') log(truth$slopes[[owner]][at]) else truth$locations[[owner]][at]
    }, 0)
    at <- which(plan$Consumer == id)
    plan$Reference[at] <- 'generating_parameter'
    plan$ReferenceValue[at] <- values[match(plan$Target[at], targets$Target)]
  }
  records <- wide_multi_records(spec, selected)
  ledger <- wide_output_records(plan, records)
  initial <- readRDS(file.path(path, 'q31-fit.rds'))
  stopifnot(identical(initial$checksum, wide_mml_hash(initial$payload)))
  point_map <- function(fitting) {
    if (nzchar(fitting$error)) return(list(value = NULL, error = fitting$error))
    wide_mml_capture(function() wide_d_response_points(fitting$value, contract$z_grid))
  }
  raw <- point_map(initial$payload)
  response <- list(initial = raw$value, admitted = NULL, errors = c(initial = raw$error, admitted = ''))
  if (!nzchar(selected$point$error) && isTRUE(selected$point$value$ready)) {
    order <- sub(':.*$', '', selected$point$stage)
    fitted <- readRDS(file.path(path, paste0(order, '-fit.rds')))
    stopifnot(identical(fitted$checksum, wide_mml_hash(fitted$payload)),
              identical(wide_mml_hash(fitted$payload), selected$point$fit_hash))
    mapped <- point_map(fitted$payload)
    response$admitted <- mapped$value; response$errors['admitted'] <- mapped$error
  }
  grid <- expand.grid(z = contract$z_grid, first = seq_along(truth$levels[[1L]]),
                      second = seq_along(truth$levels[[2L]]))
  for (name in c('initial', 'admitted')) if (!is.null(response[[name]]))
    stopifnot(identical(response[[name]]$grid[c('z', 'first', 'second')],
                        grid[c('z', 'first', 'second')]))
  definition <- Filter(function(x) is.call(x) && identical(x[[1L]], as.name('<-')) &&
    identical(x[[2L]], as.name('d_probability')), as.list(parse(generator)))
  stopifnot(length(definition) == 1L)
  reference <- new.env(parent = baseenv()); eval(definition[[1L]], reference)
  response$truth <- reference$d_probability(grid$z, grid$first, grid$second, truth)
  response$source <- selected$point[c('stage', 'fit_hash', 'error')]
  response$source_ready <- isTRUE(selected$point$value$ready)
  response$loss <- vapply(c('initial', 'admitted'), function(name)
    if (is.null(response[[name]])) NA_real_ else
      mean((response[[name]]$probabilities - response$truth)^2), 0)
  binding <- list(selected = wide_mml_hash(selected), contracts = tools::md5sum(contracts_path),
    helper_sources = tools::md5sum(c(wide_d_fresh_script, generator,
      'inst/validation/mfrm-wide-map-d-output-20261005.R',
      'inst/validation/mfrm-wide-map-d-response-20261005.R')))
  wide_mml_phase(file.path(path, 'd-outputs.rds'), binding,
                 function() list(plan = plan, records = records, ledger = ledger, response = response))
}
