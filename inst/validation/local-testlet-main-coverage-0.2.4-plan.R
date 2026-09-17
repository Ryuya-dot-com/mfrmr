# Freeze allocation and seeds only; this script never generates data or fits.
freeze_testlet_main_coverage_plan <- function() {
  prefix <- 'inst/validation/local-testlet-main-coverage-0.2.4'
  input <- 'inst/validation/local-testlet-pair-allocation-0.2.4-evidence.rds'
  allocation <- readRDS(input)
  stopifnot(all(allocation$audit$Pass),
    identical(allocation$plan$sources, tools::md5sum(names(allocation$plan$sources))),
    identical(allocation$plan$inputs, tools::md5sum(names(allocation$plan$inputs))))
  selected <- allocation$allocations[which.min(allocation$allocations$BenchmarkAdjustedSerialHours), ]
  b <- as.integer(selected$BenchmarkAdjustedDatasetsPerCell)
  manifest <- data.frame(Cell = rep(1:4, each = b), N = rep(c(24L, 120L, 24L, 120L), each = b),
    Variance = rep(c(0, 0, .49, .49), each = b), Replicate = rep(seq_len(b), 4))
  manifest$Pairs <- ifelse(manifest$N == 24L, selected$N24Pairs, selected$N120Pairs)
  manifest$Seed <- 262017000L + 10000L * manifest$Cell + manifest$Replicate
  manifest$ID <- sprintf('cell-%02d-rep-%04d', manifest$Cell, manifest$Replicate)
  previous_seeds <- c(allocation$input$plan$manifest$Seed, allocation$input$plan$prior_seeds)
  stopifnot(!anyDuplicated(manifest$Seed), !any(manifest$Seed %in% previous_seeds),
    b < 10000L, all(manifest$Pairs <= manifest$N / 2))
  sources <- tools::md5sum(c(paste0(prefix, '-plan.R'), names(allocation$plan$sources)))
  inputs <- tools::md5sum(input)
  design <- readLines(paste0(prefix, '-protocol.md'))
  path <- paste0(prefix, '-plan.rds')
  if (file.exists(path)) {
    old <- readRDS(path)
    stopifnot(identical(old$manifest, manifest), identical(old$sources, sources),
      identical(old$inputs, inputs), identical(old$design, design))
    cat('REUSE frozen main design:', nrow(manifest), 'assigned datasets; no data generated\n')
    return(invisible(old))
  }
  plan <- list(manifest = manifest, selected_allocation = selected,
    selection_rule = 'lowest estimated serial hours after ideal-oracle adjustment; pilot planning, not proven optimum',
    previous_seeds = previous_seeds, start = allocation$input$plan$start,
    controls = lapply(manifest$N, function(n) list(maxit = 250L, fnscale = n, factr = 0, pgtol = 5e-6 / n)),
    sources = sources, inputs = inputs, design = design, created = Sys.time(),
    parent = system2('git', 'rev-parse HEAD', stdout = TRUE), session = sessionInfo(),
    status = 'design_frozen_not_generated')
  saveRDS(plan, path)
  write.csv(manifest, paste0(prefix, '-manifest.csv'), row.names = FALSE)
  cat('FROZEN main design:', nrow(manifest), 'datasets;', b, 'per cell; pairs',
    selected$N24Pairs, '/', selected$N120Pairs, '; no data generated or fitted\n')
  invisible(plan)
}

if (sys.nframe() == 0L) freeze_testlet_main_coverage_plan()
