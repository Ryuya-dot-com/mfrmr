# Freeze A/B inputs only: no package loading, estimation or outcome-based redraw.
# From package root: Rscript THIS_FILE OUTPUT_DIRECTORY
# An interrupted run resumes from its immutable registry and existing bundles.
ab_script <- 'inst/validation/mfrm-wide-map-ab-inputs-20261001.R'
ab_allocation <- 'validation-results/mfrm-wide-map-r50-20261001/conditions.csv'
ab_protocol <- 'inst/validation/internal-roadmap-0.2.4.md'

ab_atomic_save <- function(x, path) {
  temporary <- paste0(path, '.tmp')
  saveRDS(x, temporary, version = 3)
  stopifnot(file.rename(temporary, path))
}

ab_truth <- function(name) list(
  Rater = c(-.3, 0, .3), Criterion = c(-.4, .1, .3),
  steps = if (name == 'S-RSM') matrix(c(-.6, 0, .6), 3, 3, byrow = TRUE) else
    rbind(c(-.6, .2, .4), c(-.8, -.1, .9), c(-.4, -.1, .5)),
  log_slopes = if (name == 'S-GPCM') c(-.2, .2, 0) else rep(0, 3))

ab_probabilities <- function(theta, rater, criterion, truth) {
  eta <- theta - truth$Rater[rater] - truth$Criterion[criterion]
  cumulative_steps <- t(apply(truth$steps, 1L, function(x) c(0, cumsum(x))))
  z <- exp(truth$log_slopes[criterion]) *
    (outer(eta, 0:3) - cumulative_steps[criterion, , drop = FALSE])
  z <- z - pmax(z[, 1L], z[, 2L], z[, 3L], z[, 4L])
  mass <- exp(z); mass <- mass / rowSums(mass)
  stopifnot(all(is.finite(mass)), max(abs(rowSums(mass) - 1)) < 1e-12)
  mass
}

ab_check_equation <- function() {
  errors <- numeric()
  for (name in c('S-RSM', 'S-PCM', 'S-GPCM')) {
    truth <- ab_truth(name)
    for (theta in c(-10, -3, 0, 3, 10)) for (r in 1:3) for (c in 1:3) {
      p <- drop(ab_probabilities(theta, r, c, truth))
      log_odds <- exp(truth$log_slopes[c]) *
        (theta - truth$Rater[r] - truth$Criterion[c] - truth$steps[c, ])
      # Separate scalar adjacent-category recurrence, without cumulative logits.
      weights <- 1
      for (k in 1:3) weights[k + 1L] <- weights[k] * exp(log_odds[k])
      errors <- c(errors, max(abs(p - weights / sum(weights))),
        max(abs(diff(log(p)) - log_odds)))
    }
  }
  stopifnot(max(errors) < 1e-12)
  max(errors)
}

ab_generate <- function(unit, seeds) {
  N <- unit$N; truth <- ab_truth(unit$Truth)
  assign('.Random.seed', seeds$ability, envir = .GlobalEnv)
  theta <- rnorm(N, sd = unit$SD)
  persons <- sprintf('P%04d', seq_len(N)); names(theta) <- persons
  assign('.Random.seed', seeds$assignment, envir = .GlobalEnv)
  person_order <- sample.int(N)
  counts <- rep(N %/% 3L, 3L) + as.integer(seq_len(3L) <= N %% 3L)
  pair_id <- integer(N); pair_id[person_order] <- rep(seq_len(3L), counts)
  pair_map <- rbind(c(1L, 2L), c(2L, 3L), c(3L, 1L))
  L <- if (N %in% c(20L, 60L, 240L, 480L)) 2L else 1L
  grid <- expand.grid(PersonIndex = seq_len(N), RaterIndex = 1:3,
    CriterionIndex = 1:3, Event = seq_len(L))
  mass <- ab_probabilities(theta[grid$PersonIndex], grid$RaterIndex,
    grid$CriterionIndex, truth)
  assign('.Random.seed', seeds$response, envir = .GlobalEnv)
  u <- runif(nrow(grid))
  cdf <- cbind(mass[, 1L], mass[, 1L] + mass[, 2L],
    mass[, 1L] + mass[, 2L] + mass[, 3L])
  data <- data.frame(RowId = seq_len(nrow(grid)),
    Person = persons[grid$PersonIndex], Rater = as.character(grid$RaterIndex),
    Criterion = as.character(grid$CriterionIndex), Event = grid$Event,
    Score = as.integer(rowSums(u > cdf)), stringsAsFactors = FALSE)
  paired <- grid$RaterIndex == pair_map[pair_id[grid$PersonIndex], 1L] |
    grid$RaterIndex == pair_map[pair_id[grid$PersonIndex], 2L]
  views <- list('full-L1' = data[grid$Event == 1L, ],
    'paired-L1' = data[paired & grid$Event == 1L, ])
  if (L == 2L) views[['paired-L2']] <- data[paired, ]
  views <- lapply(views, function(x) { rownames(x) <- NULL; x })
  list(unit = unit, truth = truth, theta = theta,
    assignment = data.frame(Person = persons, PairId = pair_id),
    person_order = person_order, rng = seeds, views = views)
}

ab_check_bundle <- function(x, unit, seeds) {
  stopifnot(identical(x$unit, unit), identical(x$rng, seeds),
    identical(x$truth, ab_truth(unit$Truth)), length(x$theta) == unit$N,
    all(is.finite(x$theta)), identical(sort(x$person_order), seq_len(unit$N)))
  expected <- rep(unit$N %/% 3L, 3L) + as.integer(seq_len(3L) <= unit$N %% 3L)
  stopifnot(identical(as.integer(table(x$assignment$PairId)), expected))
  full <- x$views[['full-L1']]; paired <- x$views[['paired-L1']]
  subset_rows <- function(a, ids) { z <- a[match(ids, a$RowId), ]; rownames(z) <- NULL; z }
  stopifnot(identical(paired, subset_rows(full, paired$RowId)))
  if ('paired-L2' %in% names(x$views)) {
    both <- x$views[['paired-L2']]
    stopifnot(identical(paired, subset_rows(both, paired$RowId)),
      all(table(both$Person, both$Event) == 6L))
    event2 <- both[both$Event == 2L, ]
    rownames(event2) <- NULL
    stopifnot(identical(event2[c('Person', 'Rater', 'Criterion')],
      paired[c('Person', 'Rater', 'Criterion')]))
  }
  for (name in names(x$views)) {
    data <- x$views[[name]]
    per_person <- switch(name, 'full-L1' = 9L, 'paired-L1' = 6L, 'paired-L2' = 12L)
    stopifnot(nrow(data) == unit$N * per_person, !anyDuplicated(data$RowId),
      all(data$Score %in% 0:3), all(table(data$Person) == per_person),
      all(table(data$Criterion) == nrow(data) / 3L))
  }
  invisible(TRUE)
}

ab_prepare <- function(out) {
  equation_error <- ab_check_equation()
  registry_path <- file.path(out, 'rng-registry.rds')
  if (!dir.exists(out)) {
    dir.create(file.path(out, 'bundles'), recursive = TRUE)
    dir.create(file.path(out, 'source'))
    sources <- c(generator = ab_script, allocation = ab_allocation, protocol = ab_protocol)
    for (name in names(sources)) stopifnot(file.copy(sources[[name]],
      file.path(out, 'source', basename(sources[[name]]))))
    units <- expand.grid(Replicate = 1:50, Truth = c('S-RSM', 'S-PCM', 'S-GPCM'),
      SD = c(.5, 1), N = c(20L, 30L, 40L, 60L, 120L, 240L, 480L),
      stringsAsFactors = FALSE)
    units$PairingGroup <- paste0('AB:N', units$N, ':SD', units$SD, ':', units$Truth)
    units$ParentId <- paste0(units$PairingGroup, ':rep', sprintf('%03d', units$Replicate))
    units$Bundle <- sprintf('bundles/parent-%04d.rds', seq_len(nrow(units)))
    RNGkind("L'Ecuyer-CMRG", normal.kind = 'Inversion', sample.kind = 'Rejection')
    set.seed(2026100101L); next_stream <- .Random.seed
    streams <- vector('list', nrow(units))
    for (i in seq_len(nrow(units))) {
      component <- next_stream; seeds <- list()
      for (name in c('ability', 'assignment', 'response', 'missingness', 'F_first_unused')) {
        seeds[[name]] <- component; component <- parallel::nextRNGSubStream(component)
      }
      streams[[i]] <- seeds; next_stream <- parallel::nextRNGStream(next_stream)
    }
    names(streams) <- units$ParentId
    registry <- list(epoch = 'development-AB-20261001-v1', phase = 'development',
      master_seed = 2026100101L, RNG = RNGkind(), units = units, streams = streams,
      next_unused_unit_stream = next_stream, source_paths = sources,
      source_md5 = unname(tools::md5sum(sources)),
      row_order = 'Person varies fastest, then Rater, Criterion, Event.',
      outside_assignment = 'Potential second-event full-panel scores are discarded outside paired rosters.',
      scope = 'Input freeze only; fitting/aggregation procedure is not frozen here.',
      session = capture.output(sessionInfo()))
    ab_atomic_save(registry, registry_path)
  }
  registry <- readRDS(registry_path)
  stopifnot(identical(unname(tools::md5sum(c(ab_script, ab_allocation))),
    registry$source_md5[1:2]), nrow(registry$units) == 2100L)
  frozen_sources <- file.path(out, 'source', basename(registry$source_paths))
  stopifnot(identical(unname(tools::md5sum(frozen_sources)), registry$source_md5))
  rows <- list(); index <- 0L
  for (i in seq_len(nrow(registry$units))) {
    unit <- registry$units[i, ]; seeds <- registry$streams[[i]]
    path <- file.path(out, unit$Bundle)
    if (!file.exists(path)) {
      x <- ab_generate(unit, seeds); ab_check_bundle(x, unit, seeds)
      ab_atomic_save(x, path)
    }
    x <- readRDS(path); ab_check_bundle(x, unit, seeds)
    md5 <- unname(tools::md5sum(path))
    for (view in names(x$views)) {
      index <- index + 1L; data <- x$views[[view]]
      totals <- tapply(data$Score, data$Person, sum)
      rows[[index]] <- data.frame(ConditionId = paste('AB', view, paste0('N', unit$N),
        paste0('SD', unit$SD), unit$Truth, sep = ':'), Replicate = unit$Replicate,
        ParentId = unit$ParentId, Bundle = unit$Bundle, View = view, BundleMD5 = md5,
        N = unit$N, SD = unit$SD, Truth = unit$Truth, ObservedRows = nrow(data),
        ExtremePersons = sum(totals == 0 | totals == 3 * nrow(data) / unit$N))
    }
    if (i %% 300L == 0L) cat('Prepared', i, 'of', nrow(registry$units), 'parent bundles\n')
  }
  inputs <- do.call(rbind, rows)
  allocation <- read.csv(ab_allocation, stringsAsFactors = FALSE)
  expected <- allocation$ConditionId[allocation$Block == 'AB']
  stopifnot(nrow(inputs) == 5400L, length(expected) == 108L,
    setequal(unique(inputs$ConditionId), expected), all(table(inputs$ConditionId) == 50L),
    !anyDuplicated(inputs[c('ConditionId', 'Replicate')]), sum(inputs$ObservedRows) == 7335000L)
  # Reordered and forked regeneration on two edge cases must reproduce saved inputs.
  selected <- which((registry$units$N == 20L & registry$units$SD == 1 &
    registry$units$Truth == 'S-GPCM' | registry$units$N == 480L &
    registry$units$SD == .5 & registry$units$Truth == 'S-RSM') & registry$units$Replicate == 1L)
  stopifnot(length(selected) == 2L)
  regenerate <- function(i) ab_generate(registry$units[i, ], registry$streams[[i]])
  serial <- lapply(rev(selected), regenerate)
  parallel <- parallel::mclapply(selected, regenerate, mc.cores = 2L, mc.set.seed = FALSE)
  for (j in seq_along(selected)) {
    saved <- readRDS(file.path(out, registry$units$Bundle[selected[j]]))
    stopifnot(identical(saved, serial[[3L - j]]), identical(saved, parallel[[j]]))
  }
  write.csv(inputs, file.path(out, 'inputs.csv'), row.names = FALSE)
  ab_atomic_save(list(epoch = registry$epoch, parent_bundles = 2100L,
    condition_records = nrow(inputs), condition_templates = length(expected),
    response_rows_in_views = sum(inputs$ObservedRows), fits = 0L,
    equation_max_error = equation_error, rng_replay_parents = registry$units$ParentId[selected],
    reordered_and_two_worker_replay_identical = TRUE,
    checks = c('pair counts', 'exposures', 'shared responses', 'category support',
      'all allocation IDs and 50 fixed replicate IDs', 'read-back of every bundle'),
    registry_md5 = tools::md5sum(registry_path), inputs_md5 = tools::md5sum(file.path(out, 'inputs.csv')),
    completed = Sys.time(), session = capture.output(sessionInfo())), file.path(out, 'verified-inputs.rds'))
  print(c(ParentBundles = 2100L, ConditionRecords = nrow(inputs),
    ResponseRows = sum(inputs$ObservedRows), Fits = 0L))
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE); stopifnot(length(args) == 1L)
  ab_prepare(args[1L])
}
