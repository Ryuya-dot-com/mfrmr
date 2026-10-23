# D's retained-prior scoring on its declared population-relative scale.
# Source the MML, F accounting and D response helpers first. No calibration fits.
wide_d_f_input <- function(condition, replicate) {
  root <- 'validation-results/mfrm-wide-map-r50-20261001/d-inputs'
  registry <- file.path(root, 'inputs.csv')
  verified <- readRDS(file.path(root, 'verified-inputs.rds'))
  stopifnot(identical(tools::md5sum(names(verified$inputs_md5)), verified$inputs_md5))
  rows <- read.csv(registry, stringsAsFactors = FALSE)
  row <- rows[rows$ConditionId == condition & rows$Replicate == replicate, ]
  stopifnot(nrow(row) == 1L, row$Origin != 'AB_alias')
  local <- function(path) sub('^/Users/tohokusla/Dropbox/MFRM_Application/mfrmr/development/', '', path)
  paths <- c(local(row$Bundle), local(row$MetadataBundle))
  stopifnot(identical(unname(tools::md5sum(paths)), c(row$BundleMD5, row$MetadataMD5)))
  bundle <- readRDS(paths[2L]); view <- bundle$views[[row$View]]
  stopifnot(identical(bundle$unit$UnitId, row$UnitId),
    bundle$unit$Replicate == replicate, identical(view$family, row$Truth),
    identical(view$design, row$Design))
  data <- if (row$Selector == 'case$data') readRDS(paths[1L])$case$data else {
    stopifnot(row$Selector == 'views[[View]]$data'); view$data
  }
  contract_path <- file.path(root, 'target-contracts.rds')
  contract <- readRDS(contract_path)$contracts[[condition]]
  stopifnot(identical(view$truth, contract$canonical), nrow(data) == row$ObservedRows)
  list(row = row, data = data, bundle = bundle, truth = view$truth, contract = contract,
    provenance = tools::md5sum(unique(c(registry, paths, contract_path))))
}

wide_d_f_generators <- function() {
  path <- 'inst/validation/mfrm-wide-map-d-inputs-20261001.R'
  wanted <- c('d_probability', 'd_draw', 'd_new_rosters')
  expressions <- Filter(function(x) is.call(x) && identical(x[[1L]], as.name('<-')) &&
    as.character(x[[2L]]) %in% wanted, as.list(parse(path)))
  stopifnot(length(expressions) == length(wanted))
  context <- new.env(parent = baseenv())
  for (x in expressions) eval(x, context)
  context
}

wide_d_f_panels <- function(input) {
  stopifnot(identical(tools::md5sum(names(input$provenance)), input$provenance))
  old_kind <- RNGkind(); had_seed <- exists('.Random.seed', .GlobalEnv, inherits = FALSE)
  if (had_seed) old_seed <- get('.Random.seed', .GlobalEnv)
  on.exit({do.call(RNGkind, as.list(old_kind)); if (had_seed) assign('.Random.seed', old_seed, .GlobalEnv)
    else if (exists('.Random.seed', .GlobalEnv, inherits = FALSE)) rm('.Random.seed', envir = .GlobalEnv)}, add = TRUE)
  RNGkind("L'Ecuyer-CMRG", normal.kind = 'Inversion', sample.kind = 'Rejection')
  b <- input$bundle; row <- input$row; truth <- input$truth; generator <- wide_d_f_generators()
  stream <- b$stream$F_first_unused; stopifnot(length(stream) == 7L)
  registry <- list()
  for (id in c('population', paste0('grid', 1:5))) {
    registry[[id]] <- list()
    for (component in c('ability', 'assignment', 'response', 'missingness')) {
      registry[[id]][[component]] <- stream; stream <- parallel::nextRNGSubStream(stream)
    }
  }
  selected <- 'population'
  if (row$N %in% c(20L, 60L, 240L, 480L) && row$Truth %in% c('H-both', 'rubric-both'))
    selected <- c(selected, paste0('grid', 1:5))
  panels <- list(); historical <- startsWith(row$Truth, 'H-')
  for (id in selected) {
    M <- if (id == 'population') 60L else 30L
    seeds <- registry[[id]]; assign('.Random.seed', seeds$ability, .GlobalEnv)
    z <- if (id == 'population') stats::rnorm(M) else rep(as.integer(sub('grid', '', id))-3L, M)
    theta <- truth$mu + truth$sd*z
    persons <- paste0('F-', id, '-', sprintf('%03d', seq_len(M)))
    stopifnot(!any(persons %in% input$data$Person))
    g <- expand.grid(PersonIndex = seq_len(M), First = seq_along(truth$levels[[1L]]),
      Second = seq_along(truth$levels[[2L]]))
    if (historical) {
      rosters <- generator$d_new_rosters(M, seeds$assignment)$rosters
      roster <- if (endsWith(row$Design, '-common')) 'common_persons' else {
        stopifnot(endsWith(row$Design, '-rotating-pair')); 'rotating_pairs'
      }
      keep <- rosters[[roster]][cbind(g$PersonIndex, g$Second)]
    } else {
      stopifnot(identical(truth$facets, c('Rater', 'Criterion')),
        row$Design %in% c('full-L1', 'paired-L1'))
      assign('.Random.seed', seeds$assignment, .GlobalEnv)
      pair <- integer(M); pair[sample.int(M)] <- rep(1:3, each = M/3)
      pairs <- rbind(c(1,2), c(2,3), c(3,1))
      keep <- if (row$Design == 'full-L1') rep(TRUE, nrow(g)) else
        g$First == pairs[pair[g$PersonIndex], 1L] | g$First == pairs[pair[g$PersonIndex], 2L]
    }
    assign('.Random.seed', seeds$response, .GlobalEnv)
    score <- generator$d_draw(theta[g$PersonIndex], g$First, g$Second, stats::runif(nrow(g)), truth)
    data <- data.frame(Person = persons[g$PersonIndex], Score = score)
    for (j in 1:2) data[[truth$facets[j]]] <- truth$levels[[j]][g[[c('First','Second')[j]]]]
    data <- data[keep, c('Person', truth$facets, 'Score')]; rownames(data) <- NULL
    stopifnot(!anyDuplicated(data[c('Person', truth$facets)]),
      all(data$Score %in% 0:(truth$K-1L)), setequal(data$Person, persons))
    x <- list(Panel = id, Family = if (id == 'population') 'F-pop' else 'F-grid',
      CohortId = paste(b$unit$UnitId, id, sep = ':'), data = data,
      planned = data.frame(Person = persons, Theta = z, GeneratingTheta = theta),
      categories = 0:(truth$K-1L), facets = truth$facets, seeds = seeds,
      provenance = input$provenance, scale = 'population_relative_z',
      contract = 'D_retained_prior_population_relative_v1')
    x$DataId <- wide_mml_hash(list(data = data, planned = x$planned, CohortId = x$CohortId, scale = x$scale))
    x$PanelId <- wide_mml_hash(x); panels[[id]] <- x
  }
  list(panels = panels, registry = registry, next_unused_substream = stream,
    parent = b$unit, calibration_provenance = input$provenance)
}

wide_d_f_source <- function(out, input) {
  recorded <- readRDS(file.path(out, 'manifest.rds'))$payload$runtime$R
  if (!identical(R.version.string, recorded)) stop('D source replay requires its recorded R runtime: ', recorded)
  m <- wide_f_read(file.path(out, 'manifest.rds'))$payload
  selected <- wide_f_read(file.path(out, 'selected.rds'))
  stopifnot(identical(selected$binding, wide_mml_hash(m)),
    identical(selected$payload$spec_hash, wide_mml_hash(m$spec)),
    identical(m$spec$args$data, input$data), m$spec$ConditionId == input$row$ConditionId,
    m$spec$Replicate == input$row$Replicate)
  s <- selected$payload$point; order <- as.integer(sub('^q([0-9]+):.*', '\\1', s$stage))
  path <- file.path(out, paste0('q', order, '-fit.rds')); f <- wide_f_read(path)
  stopifnot(identical(f$binding, list(job = wide_mml_hash(m), order = order, phase = 'fit', dependency = NULL)),
    identical(s$fit_hash, f$checksum), identical(s$stage, paste0('q', order, ':', f$checksum)))
  x <- list(fit = f$payload$value, review = s$value, error = s$error, stage = s$stage,
    spec = m$spec, model_source = m$runtime$source,
    files = tools::md5sum(c(file.path(out, c('manifest.rds', 'selected.rds')), path)))
  x$SourceId <- wide_mml_hash(x); x
}

wide_d_f_run <- function(source, panel, out, runtime) {
  stopifnot(identical(panel$PanelId, wide_mml_hash(panel[setdiff(names(panel), 'PanelId')])),
    identical(source$SourceId, wide_mml_hash(source[setdiff(names(source), 'SourceId')])),
    identical(source$spec$args$facets, panel$facets), source$spec$args$method == 'MML')
  # Only observations enter scoring; neither theta nor generating moments do.
  rows <- panel$data[c('Person', panel$facets, 'Score')]
  manifest <- list(SourceId = source$SourceId, PanelId = panel$PanelId, prior = 'retained',
    actual_prior = NULL, data = rows, facets = panel$facets, orders = c(31L,61L,121L), runtime = runtime)
  dir.create(out, recursive = TRUE, showWarnings = FALSE)
  old <- wide_mml_phase(file.path(out, 'manifest.rds'), 'd-held-out-scoring-v1', function() manifest)
  stopifnot(identical(old, manifest))
  identity <- wide_mml_hash(manifest); attempts <- list(); finished <- FALSE; q <- 31L
  status <- function(value) wide_mml_save(list(status = value, identity = identity,
    scoring_order = q, time = Sys.time()), file.path(out, 'status.rds'))
  on.exit(if (!finished) status('interrupted'), add = TRUE)
  source_ready <- !nzchar(source$error) && isTRUE(source$review$ready)
  for (q in manifest$orders) {
    status('running')
    a <- wide_mml_phase(file.path(out, paste0('score-q', q, '.rds')),
      list(job = identity, scoring_order = q), function() {
        if (!source_ready) return(list(value = NULL, error = paste('Scoring source refused:',
          source$error, paste(source$review$reason_codes, collapse = '; '),
          source$review$local_calibration_review$review), warnings = character(), elapsed = 0))
        wide_mml_capture(function() mfrmr::predict_mfrm_units(source$fit, new_data = rows,
          person = 'Person', facets = panel$facets, score = 'Score', scoring_prior = NULL,
          interval_level = .95, n_draws = 0L, readiness_policy = 'error', scoring_quad_points = q))
      })
    attempts[[as.character(q)]] <- a
    if (!wide_f_retry(a$error)) break
  }
  selected <- list(identity = identity, source_ready = source_ready, source_stage = source$stage,
    attempts = attempts, selected_order = q, prior = 'retained', SourceId = source$SourceId, PanelId = panel$PanelId)
  saved <- wide_mml_phase(file.path(out, 'selected.rds'), identity, function() selected)
  stopifnot(identical(saved, selected)); status('complete'); finished <- TRUE
  saved
}

wide_d_f_records <- function(source, panel, selected) {
  stopifnot(identical(source$SourceId, selected$SourceId), identical(panel$PanelId, selected$PanelId),
    selected$prior == 'retained', panel$scale == 'population_relative_z')
  # This is the declared plug-in scale conversion, with no added calibration uncertainty.
  result <- lapply(c('default31', 'refinement'), function(rule) {
    q <- if (rule == 'default31') 31L else selected$selected_order
    a <- selected$attempts[[as.character(q)]]; stopifnot(!is.null(a))
    z <- panel$planned
    z$Observed <- vapply(z$Person, function(id) sum(panel$data$Person == id & !is.na(panel$data$Score)), 1L)
    z$Extreme <- vapply(z$Person, function(id) {
      y <- panel$data$Score[panel$data$Person == id & !is.na(panel$data$Score)]
      length(y) > 0L && (all(y == min(panel$categories)) || all(y == max(panel$categories)))
    }, TRUE)
    z$Estimate <- z$SD <- z$Lower <- z$Upper <- z$PriorMean <- z$PriorSD <- NA_real_
    z$ScoreAvailable <- z$IntervalAvailable <- FALSE; z$Reason <- a$error
    z$BatchStatus <- if (!selected$source_ready) 'source_refused' else
      if (wide_f_retry(a$error)) 'integration_refused' else if (nzchar(a$error)) 'error' else 'returned'
    z$BatchCheck <- 'no_return'
    if (!nzchar(a$error)) {
      pop <- wide_d_fixed_normal_parameters(source$fit)$native_population
      v <- a$value; t <- v$estimates; mfrmr:::prediction_validate_population_output(v)
      stopifnot(inherits(v, 'mfrm_unit_prediction'), v$settings$scoring_quad_points == q,
        v$settings$n_draws == 0, identical(v$settings$readiness_policy, 'error'),
        isTRUE(v$settings$source_scoring_ready), v$settings$interval_level == .95,
        is.null(v$settings$scoring_prior), !anyDuplicated(t$Person), all(t$Person %in% z$Person))
      ix <- match(z$Person, t$Person)
      for (field in c('Estimate', 'Lower', 'Upper', 'PriorMean')) z[[field]] <- (t[[field]][ix]-pop['mean'])/pop['sd']
      for (field in c('SD', 'PriorSD')) z[[field]] <- t[[field]][ix]/pop['sd']
      checked <- !is.null(v$settings$score_integration_review)
      if (checked) stopifnot(all(v$settings$score_integration_review$Passed))
      z$BatchCheck <- if (checked) 'public_EAP_SD_pass' else 'not_performed_by_public_procedure'
      z$ScoreAvailable <- !is.na(ix) & z$Observed > 0 & is.finite(z$Estimate) &
        t$EstimateUse[ix] == 'fitted_object_scoring'
      z$IntervalAvailable <- z$ScoreAvailable & is.finite(z$SD) & z$SD > 0 &
        is.finite(z$Lower) & is.finite(z$Upper) & z$Lower < z$Upper
      z$Reason <- ifelse(z$ScoreAvailable, '', ifelse(z$Observed == 0, 'No usable responses', 'Score not returned'))
    }
    z$IntervalReason <- ifelse(z$IntervalAvailable, '', ifelse(nzchar(z$Reason), z$Reason, 'Conditional interval not returned'))
    z$Error <- ifelse(z$ScoreAvailable, z$Estimate-z$Theta, NA_real_)
    z$Covered <- z$IntervalAvailable & z$Lower <= z$Theta & z$Upper >= z$Theta
    z$Covered[!z$IntervalAvailable] <- FALSE
    z$ConditionId <- source$spec$ConditionId; z$Replicate <- source$spec$Replicate; z$Arm <- source$spec$Arm
    z$Prior <- 'retained'; z$Rule <- rule; z$Panel <- panel$Panel; z$Family <- panel$Family
    z$PanelId <- panel$PanelId; z$DataId <- panel$DataId; z$CohortId <- panel$CohortId
    z$SourceId <- source$SourceId; z$SourceStage <- source$stage; z$ScoringOrder <- q
    z$Scale <- panel$scale; z$ScoringRoute <- 'fitted_object'; z$ConditionalUncertainty <- TRUE; z
  })
  do.call(rbind, result)
}
