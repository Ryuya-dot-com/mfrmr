# Targeted PCM-null validation for the G2 release requirement.
# Question: does the regular MML equal-slope LRT have a plausible 5% rejection
# rate, and how often is it available, in a crossed design and a smaller,
# incomplete but linked design? The two designs do not isolate sample size
# from sparsity. This is not a universal type-I error guarantee.
# Run from the package root after pkgload::load_all(..., compile = FALSE).
run_gpcm_lrt_null <- function(output_dir, repetitions = 100L, cores = 2L) {
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  plan <- expand.grid(Owner = c("Criterion", "Rater"),
                      Design = c("crossed_100", "rotating_40"),
                      Rep = seq_len(repetitions), stringsAsFactors = FALSE)
  plan$Seed <- 202609240L + seq_len(nrow(plan))
  plan$N <- ifelse(plan$Design == "crossed_100", 100L, 40L)
  plan$RatersPerPerson <- ifelse(plan$Design == "crossed_100", 3L, 2L)
  plan$Q <- 61L
  write.csv(plan, file.path(output_dir, "plan.csv"), row.names = FALSE)
  run <- function(i) {
    spec <- plan[i, ]
    filename <- file.path(output_dir, sprintf("pair-%03d.rds", i))
    if (file.exists(filename)) return(readRDS(filename)$row)
    warnings <- character()
    pcm <- gpcm <- comparison <- data <- NULL
    row <- cbind(spec, Returned = FALSE, Available = FALSE, ChiSq = NA_real_,
                 Df = NA_real_, P = NA_real_, Reason = "", Elapsed = NA_real_)
    started <- proc.time()[["elapsed"]]
    tryCatch(withCallingHandlers({
      data <- simulate_mfrm_data(n_person = spec$N, n_rater = 3, n_criterion = 3,
        raters_per_person = spec$RatersPerPerson, score_levels = 3, model = "PCM",
        step_facet = spec$Owner, thresholds = matrix(c(-.7, -1.1, -1.5, .7, 1.1, 1.5), 3,
          dimnames = list(sprintf("%s%02d", substr(spec$Owner, 1, 1), 1:3), NULL)),
        seed = spec$Seed)
      args <- list(data = data, person = "Person", facets = c("Rater", "Criterion"),
        score = "Score", model = "PCM", method = "MML", step_facet = spec$Owner,
        population_formula = ~1, person_data = data.frame(Person = unique(data$Person)),
        person_id = "Person", rating_min = 1, rating_max = 3, category_policy = "preserve",
        quad_points = spec$Q, mml_integration = "fixed", maxit = 400, reltol = 1e-10)
      pcm <- do.call(fit_mfrm, args)
      args$model <- "GPCM"; args$slope_facet <- spec$Owner
      gpcm <- do.call(fit_mfrm, args)
      row$Returned <- TRUE
      comparison <- compare_mfrm(pcm, gpcm, labels = c("PCM", "GPCM"), nested = TRUE)
      row$Available <- identical(comparison$comparison_basis$lrt_status, "computed")
      row$Reason <- comparison$comparison_basis$lrt_reason
      if (row$Available) {
        row$ChiSq <- comparison$lrt$ChiSq; row$Df <- comparison$lrt$df
        row$P <- comparison$lrt$p_value
        stopifnot(row$Df == 2, is.finite(row$P), row$P >= 0, row$P <= 1)
      }
    }, warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w)); invokeRestart("muffleWarning")
    }), error = function(e) row$Reason <<- paste("Error:", conditionMessage(e)))
    row$Elapsed <- proc.time()[["elapsed"]] - started
    saveRDS(list(row = row, warnings = warnings, data = data, pcm = pcm,
                 gpcm = gpcm, comparison = comparison), filename)
    row
  }
  rows <- parallel::mclapply(seq_len(nrow(plan)), run, mc.cores = cores, mc.preschedule = FALSE)
  stopifnot(all(vapply(rows, is.data.frame, logical(1))))
  results <- do.call(rbind, rows)
  write.csv(results, file.path(output_dir, "results.csv"), row.names = FALSE)
  groups <- split(results, interaction(results$Owner, results$Design, drop = TRUE))
  summary <- do.call(rbind, lapply(groups, function(x) {
    n <- sum(x$Available); rejected <- sum(x$P < .05, na.rm = TRUE)
    interval <- if (n > 0) binom.test(rejected, n)$conf.int else c(NA_real_, NA_real_)
    data.frame(Owner = x$Owner[1], Design = x$Design[1], Planned = nrow(x),
      Returned = sum(x$Returned), Available = n, Rejected = rejected,
      Availability = n / nrow(x), RejectionAmongAvailable = if (n) rejected / n else NA_real_,
      RejectionPerPlanned = rejected / nrow(x), Lower95 = interval[1], Upper95 = interval[2],
      MonteCarloSE = if (n) sqrt((rejected/n)*(1-rejected/n)/n) else NA_real_)
  }))
  write.csv(summary, file.path(output_dir, "summary.csv"), row.names = FALSE)
  print(summary)
  invisible(summary)
}
