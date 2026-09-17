# Rscript inst/validation/fairz-current-output-0.2.4.R <completed study directory>
# Reuse the saved preflight fits; this is an output audit, not new simulation.
source('inst/validation/fairz-coverage-0.2.4.R')
pkgload::load_all('.', quiet = TRUE)
args <- commandArgs(TRUE)
stopifnot(length(args) == 1L,
          fairz_coverage_preflight_ready(args[1], fairz_coverage_payload()))
destination <- file.path(args[1], 'output-audit')
dir.create(destination, showWarnings = FALSE)
rows <- list()
for (id in 1:8) {
  state <- readRDS(file.path(args[1], 'preflight', sprintf('cell-%02d.rds', id)))
  r <- state$Results[[1]]
  fit <- r$Detail$fit
  dx <- diagnose_mfrm(fit, residual_pca = 'none')
  for (style in c('native', 'legacy', 'both')) {
    b <- fair_average_table(fit, dx, facets = c('Rater', 'Criterion'),
                            reference = 'zero', label_style = style,
                            fair_se = TRUE, udecimals = 12)
    brief <- summary(b, digits = 12)
    p <- plot_fair_average(fit, diagnostics = dx, facet = c('Rater', 'Criterion'),
                           metric = 'FairZ', show_ci = TRUE, ci_level = .9,
                           show_title = FALSE, show_notes = FALSE, draw = FALSE)
    d <- p$data$data
    at <- match(paste(d$Facet, d$Level, sep = ':'), names(r$Estimate))
    stopifnot(!anyNA(at), nrow(d) == 5L,
              identical(brief$summary$FairMetric, 'FairZ'),
              !brief$summary$FairCIEligible, !any(b$stacked$FairCIEligible),
              all(b$stacked$FairCIReportingUse == 'unavailable'),
              !any(d$CI_Eligible), all(d$CI_ReportingUse == 'diagnostic_only'),
              all(d$CI_Level == .9),
              any(grepl('Full-refit coverage unverified', p$data$notes$Text)))
    score_error <- max(abs(d$FairZ - r$Estimate[at]))
    interval_error <- max(abs(c(
      d$CI_Lower - pmax(0, r$Estimate[at] - qnorm(.95) * r$SE[at, 'conditional_measure']),
      d$CI_Upper - pmin(2, r$Estimate[at] + qnorm(.95) * r$SE[at, 'conditional_measure']))))
    label <- if (style == 'legacy') 'Fair(Z) Average' else 'StandardizedAdjustedAverage'
    table_at <- match(paste(b$stacked$Facet, b$stacked$Element, sep = ':'), names(r$Estimate))
    summary_at <- match(paste(brief$preview$Facet, brief$preview$Level, sep = ':'), names(r$Estimate))
    stopifnot(!anyNA(table_at), !anyNA(summary_at))
    table_error <- max(abs(b$stacked[[label]] - r$Estimate[table_at]))
    summary_error <- max(abs(brief$preview$StandardizedAdjustedAverage - r$Estimate[summary_at]))
    prefix <- file.path(destination, sprintf('cell-%02d-%s', id, style))
    saveRDS(list(fit = fit, diagnostics = dx, table = b, plot = p), paste0(prefix, '.rds'))
    saved <- readRDS(paste0(prefix, '.rds'))
    replay <- plot_fair_average(saved$fit, diagnostics = saved$diagnostics,
                                facet = c('Rater', 'Criterion'), metric = 'FairZ',
                                show_ci = TRUE, ci_level = .9,
                                show_title = FALSE, show_notes = FALSE, draw = FALSE)
    stopifnot(identical(saved$table$raw_by_facet, b$raw_by_facet),
              identical(saved$plot$data, p$data), identical(replay$data, p$data))
    # Without a fit, stored RSM/PCM tables cannot reconstruct the derivative.
    stored_plot <- plot_fair_average(saved$table, metric = 'FairZ', show_ci = TRUE, draw = FALSE)
    stopifnot(all(is.na(stored_plot$data$data$CI_Lower)),
              !any(stored_plot$data$data$CI_Eligible))
    write.csv(d, paste0(prefix, '-plot.csv'), row.names = FALSE)
    write.csv(b$stacked, paste0(prefix, '-table.csv'), row.names = FALSE)
    write.csv(p$data$notes, paste0(prefix, '-notes.csv'), row.names = FALSE)
    csv <- read.csv(paste0(prefix, '-plot.csv'), check.names = FALSE)
    table_csv <- read.csv(paste0(prefix, '-table.csv'), check.names = FALSE)
    csv_error <- max(abs(as.matrix(csv[c('FairZ', 'CI_SE', 'CI_Lower', 'CI_Upper')]) -
                          as.matrix(d[c('FairZ', 'CI_SE', 'CI_Lower', 'CI_Upper')])))
    stopifnot(!any(csv$CI_Eligible), all(csv$CI_ReportingUse == 'diagnostic_only'),
              !any(table_csv$FairCIEligible), all(table_csv$FairCIReportingUse == 'unavailable'),
              score_error < 1e-9, table_error < 1e-11, summary_error < 1e-11,
              interval_error < 1e-8, csv_error < 1e-13)
    rows[[length(rows) + 1L]] <- data.frame(Cell = id, Model = state$Cell$Model,
      Style = style, ScoreError = score_error, FormattedScoreError = table_error,
      SummaryScoreError = summary_error,
      ConditionalIntervalError = interval_error, CSVError = csv_error,
      SavedAndReplayExact = TRUE, FairCIEligible = FALSE)
  }
}
result <- do.call(rbind, rows)
write.csv(result, file.path(destination, 'checks.csv'), row.names = FALSE)
print(result, row.names = FALSE)
