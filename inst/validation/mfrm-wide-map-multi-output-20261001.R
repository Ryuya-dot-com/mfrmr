# Source the mml/jml stage and output-summary helpers first. One immutable job
# declares all consumers before fitting; one worker owns its directory. Public
# interval objects are retained intact. No truth-dependent selection or new API.
wide_multi_view <- function(spec) {
  spec$facet <- spec$args$facets[1L]
  spec
}

wide_multi_contrast <- function(spec, consumer) {
  levels <- sort(unique(as.character(spec$args$data[[consumer$facet]])))
  C <- consumer$contrasts
  stopifnot(is.matrix(C), is.numeric(C), !is.complex(C), nrow(C) > 0L,
    ncol(C) == length(levels), !anyNA(C), all(is.finite(C)),
    !is.null(rownames(C)), !anyNA(rownames(C)), all(nzchar(rownames(C))), !anyDuplicated(rownames(C)),
    !is.null(colnames(C)), !anyNA(colnames(C)), !anyDuplicated(colnames(C)), setequal(colnames(C), levels),
    all(rowSums(abs(C)) > 0), all(abs(rowSums(C)) < 1e-10))
  C[, levels, drop = FALSE]
}

wide_multi_targets <- function(spec, consumer) {
  a <- spec$args
  location <- consumer$kind %in% c("location", "contrast")
  owners <- if (location) consumer$facet else a$slope_facet
  do.call(rbind, lapply(owners, function(owner) {
    levels <- sort(unique(as.character(a$data[[owner]])))
    definition <- rep("", length(levels))
    if (consumer$kind == "contrast") {
      C <- wide_multi_contrast(spec, consumer); levels <- rownames(C)
      definition <- vapply(seq_len(nrow(C)), function(i) wide_mml_hash(C[i, , drop = FALSE]), "")
    }
    product <- length(a$slope_facet) == 2L
    scale <- if (location) {
      if (product && owner == a$slope_facet[2L]) "uncentered_on_fixed_N01" else "centered_native_location"
    } else if (product && owner == a$slope_facet[2L]) "fixed_standard_normal" else "geometric_mean_one"
    data.frame(Target = paste(consumer$kind, encodeString(owner, quote = '"'),
        encodeString(levels, quote = '"'), sep = ":"),
      Owner = owner, Level = levels, Coordinate = switch(consumer$kind,
        location = "location", contrast = "location_contrast", slopes = "log_slope"),
      ScaleReference = scale, TargetDefinition = definition, stringsAsFactors = FALSE)
  }))
}

wide_multi_validate <- function(spec) {
  if (spec$args$method == "MML") wide_mml_validate(wide_multi_view(spec)) else wide_jml_validate(wide_multi_view(spec))
  consumers <- spec$outputs; ids <- names(consumers)
  stopifnot(is.list(consumers), length(consumers) > 0L, length(ids) == length(consumers),
    !anyDuplicated(ids), all(grepl("^[a-z][a-z0-9_]*$", ids)),
    length(spec$level) == 1L, is.finite(spec$level), spec$level > 0, spec$level < 1)
  for (x in consumers) {
    stopifnot(length(x$kind) == 1L, x$kind %in% c("location", "contrast", "slopes"))
    if (x$kind %in% c("location", "contrast")) stopifnot(length(x$facet) == 1L, x$facet %in% spec$args$facets) else
      stopifnot(spec$args$model == "GPCM")
    if (x$kind == "contrast") wide_multi_contrast(spec, x) else stopifnot(is.null(x$contrasts))
  }
  keys <- unlist(lapply(consumers, function(x) wide_multi_targets(spec, x)$Target), use.names = FALSE)
  if (anyDuplicated(keys)) stop("Duplicate target consumers would double-count a replication.")
  invisible(TRUE)
}

wide_multi_runtime <- function() {
  x <- wide_jml_runtime()
  x$source <- c(x$source, tools::md5sum(c("inst/validation/mfrm-wide-map-multi-output-20261001.R",
    "inst/validation/mfrm-wide-map-output-summary-20261001.R")))
  x
}

wide_multi_points <- function(fit, spec) {
  rows <- lapply(spec$outputs, function(x) {
    t <- wide_multi_targets(spec, x)
    if (x$kind == "contrast") {
      C <- wide_multi_contrast(spec, x); tab <- fit$facets$others
      tab <- tab[tab$Facet == x$facet, ]; stopifnot(!anyDuplicated(tab$Level))
      values <- tab$Estimate[match(colnames(C), tab$Level)]
      t$Estimate <- vapply(seq_len(nrow(C)), function(i) {
        use <- C[i, ] != 0; sum(C[i, use] * values[use])
      }, 0)
      return(t)
    } else if (x$kind == "location") {
      tab <- fit$facets$others; owner <- tab$Facet; level <- tab$Level; value <- tab$Estimate
    } else {
      tab <- fit$slopes
      owner <- if ("SlopeOwner" %in% names(tab)) tab$SlopeOwner else rep(spec$args$slope_facet, nrow(tab))
      level <- tab$SlopeFacet; value <- log(tab$Estimate)
    }
    t$Estimate <- vapply(seq_len(nrow(t)), function(i) {
      ix <- which(owner == t$Owner[i] & level == t$Level[i])
      if (length(ix) > 1L) stop("Duplicate native target identity.")
      if (length(ix)) unname(value[ix]) else NA_real_
    }, 0)
    t
  })
  do.call(rbind, rows)
}

wide_multi_consume <- function(fit, consumer, level) {
  if (consumer$kind == "contrast") mfrmr::mfrm_facet_intervals(fit, consumer$facet,
    contrasts = consumer$contrasts, level = level) else
  if (consumer$kind == "location") wide_mml_interval(fit, consumer$facet, level) else
    stats::confint(fit, parm = "slopes", method = "model", level = level,
      scale = if (length(fit$config$slope_facet) == 2L) "standardized" else "relative")
}

wide_multi_interval_table <- function(value, spec, consumer, fit) {
  targets <- wide_multi_targets(spec, consumer)
  if (consumer$kind %in% c("location", "contrast")) {
    stopifnot(inherits(value, "mfrm_facet_intervals"), identical(value$fit, fit),
      identical(value$settings$facet, consumer$facet), value$settings$level == spec$level)
    if (consumer$kind == "contrast") {
      C <- wide_multi_contrast(spec, consumer)
      stopifnot(identical(value$contrasts, C[, fit$config$facet_levels[[consumer$facet]], drop = FALSE]))
    }
    tab <- wide_mml_interval_table(value)
    owner <- rep(consumer$facet, nrow(tab)); level <- tab$Target
    estimate <- tab$Estimate; se <- tab$SE; low <- tab$Lower; high <- tab$Upper
  } else {
    stopifnot(inherits(value, "mfrm_slope_intervals"), attr(value, "level") == spec$level,
      identical(attr(value, "source"), mfrmr:::mfrm_gpcm_inference_source(fit)))
    tab <- attr(value, "diagnostics")
    owner <- if ("SlopeOwner" %in% names(tab)) tab$SlopeOwner else rep(spec$args$slope_facet, nrow(tab))
    level <- if ("SlopeLevel" %in% names(tab)) tab$SlopeLevel else tab$SlopeFacet
    estimate <- log(tab$Estimate); se <- tab$LogSE
    low <- log(tab$CI_Lower); high <- log(tab$CI_Upper)
  }
  ix <- vapply(seq_len(nrow(targets)), function(i) {
    found <- which(owner == targets$Owner[i] & level == targets$Level[i])
    if (length(found) != 1L) stop("Interval targets do not match their declared owners and levels.")
    found
  }, 1L)
  targets$Estimate <- estimate[ix]; targets$SE <- se[ix]
  targets$Lower <- low[ix]; targets$Upper <- high[ix]
  targets$Available <- tab$CIEligible[ix] & is.finite(targets$Estimate) &
    is.finite(targets$SE) & targets$SE > 0 & is.finite(targets$Lower) & is.finite(targets$Upper)
  targets$Reason <- tab$InferenceReview[ix]
  targets$Reason[!targets$Available & (is.na(targets$Reason) | !nzchar(targets$Reason))] <- "Target interval unavailable"
  targets[!targets$Available, c("SE", "Lower", "Upper")] <- NA_real_
  targets
}

wide_multi_retry <- function(value, consumer) {
  # One-family relative-slope intervals have no documented finer-grid check.
  # Record that public procedure; do not invent an integration-only retry.
  if (consumer$kind == "slopes") value <- list(settings = attr(value, "settings"),
    checks = attr(value, "checks"), numerical_checks = attr(value, "numerical_checks"))
  wide_mml_interval_retry(value)
}

wide_multi_plan <- function(spec) {
  wide_multi_validate(spec)
  exclusion <- if (spec$args$method == "JML") list(eligibility = "unsupported",
    reason = "Formal JML structural interval procedure remains unresolved.") else wide_mml_interval_plan(wide_multi_view(spec))
  rows <- lapply(names(spec$outputs), function(id) {
    targets <- wide_multi_targets(spec, spec$outputs[[id]])
    z <- targets[rep(seq_len(nrow(targets)), 2L), ]; z$Consumer <- id
    z$Output <- rep(c("point", "interval"), each = nrow(targets))
    z$Eligibility <- ifelse(z$Output == "point", "eligible", exclusion$eligibility)
    z$ExclusionReason <- ifelse(z$Output == "point", "", exclusion$reason)
    z
  })
  z <- do.call(rbind, rows); rownames(z) <- NULL
  z$ConditionId <- spec$ConditionId; z$Arm <- spec$Arm; z$Replicate <- spec$Replicate
  z$InputId <- spec$InputId; z$Reference <- "none"; z$ReferenceValue <- NA_real_; z
}

wide_multi_run <- function(spec, out, retained = list()) {
  plan <- wide_multi_plan(spec); mml <- spec$args$method == "MML"
  orders <- if (mml) c(31L, 61L, 121L) else 0L
  for (key in names(retained)) {
    z <- retained[[key]]; args <- spec$args
    if (mml) args$quad_points <- as.integer(key)
    stopifnot(spec$purpose == "workflow_witness_only", key %in% as.character(orders),
      identical(z$args, args), is.list(z$fitting), length(z$provenance) > 0L)
  }
  stopifnot(length(retained) == length(names(retained)), !anyDuplicated(names(retained)))
  runtime <- wide_multi_runtime()
  manifest <- list(spec = spec, runtime = runtime, retained = retained, orders = orders)
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  old <- wide_mml_phase(file.path(out, "manifest.rds"), "shared-fit-outputs-v1", function() manifest)
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
    for (id in pending) {
      consumer <- spec$outputs[[id]]
      result <- run(paste0("interval-", id), hash, function() wide_mml_capture(function() {
        value <- wide_multi_consume(fit, consumer, spec$level)
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
  stopifnot(identical(wide_multi_runtime(), runtime))
  selected <- list(identity = identity, spec_hash = wide_mml_hash(spec), plan = plan,
    point = point, intervals = intervals, stages = stages,
    initial_stage = paste0("q", orders[1], "-fit.rds"))
  result <- wide_mml_phase(file.path(out, "selected.rds"), identity, function() selected)
  stopifnot(identical(result, selected)); phase <- "complete"; state("complete"); finished <- TRUE
  result
}

wide_multi_records <- function(spec, selected) {
  if (!identical(selected$spec_hash, wide_mml_hash(spec))) stop("Selected outputs need the exact shared job specification.")
  plan <- selected$plan; rows <- list()
  for (i in which(plan$Eligibility == "eligible")) {
    p <- plan[i, ]; x <- if (p$Output == "point") selected$point else selected$intervals[[p$Consumer]]
    z <- p[c("ConditionId", "Arm", "Replicate", "Target", "Output")]
    z$Status <- if (nzchar(x$error)) "error" else "returned"
    z$Available <- FALSE; z$Estimate <- z$SE <- z$Lower <- z$Upper <- NA_real_
    z$SourceStage <- x$stage; z$Reason <- if (nzchar(x$error)) x$error else "Source/output review failed"
    if (!is.null(x$table)) {
      t <- x$table[x$table$Target == p$Target, ]; stopifnot(nrow(t) == 1L)
      z$Estimate <- t$Estimate
      if (p$Output == "point") {
        z$Available <- !nzchar(x$error) && isTRUE(x$value$ready) && is.finite(z$Estimate)
        if (!nzchar(x$error) && !isTRUE(x$value$ready)) z$Reason <- paste(c("Source review failed",
          x$value$reason_codes, x$value$local_calibration_review$review), collapse = "; ")
      } else {
        z$Available <- t$Available
        if (z$Available) z[c("SE", "Lower", "Upper")] <- t[c("SE", "Lower", "Upper")]
        z$Reason <- t$Reason
      }
    }
    if (z$Available) z$Reason <- ""
    rows[[length(rows) + 1L]] <- z
  }
  result <- do.call(rbind, rows); rownames(result) <- NULL
  wide_output_records(plan, result) # Validate accounting before returning rows.
  result
}
