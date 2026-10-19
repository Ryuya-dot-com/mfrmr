# D2 delivery check using retained fits; no model fitting or response generation.
# Run from the package root, with record once and replay in a fresh R session.
mode <- match.arg(commandArgs(TRUE)[1], c('record', 'replay'))
out <- 'validation-results/model-comparison-workflow-20261012'
paths <- c('validation-results/gpcm-lrt-20260924/null/pair-001.rds',
  'validation-results/gpcm-lrt-20260924/null/pair-005.rds')
source_files <- c('DESCRIPTION', 'NAMESPACE', list.files('R', '[.]R$', full.names = TRUE),
  'inst/validation/model-comparison-workflow-20261012.R')
hashes <- tools::md5sum(c(source_files, paths))
stopifnot(!anyNA(hashes))
pkgload::load_all('.', quiet = TRUE, compile = FALSE, helpers = FALSE)
for (name in c('fit_mfrm', 'simulate_mfrm_data'))
  trace(name, quote(stop('No new fits or responses in this delivery check.')),
    where = asNamespace('mfrmr'), print = FALSE)
capture <- function(expr) {
  warnings <- character()
  value <- withCallingHandlers(expr, warning = function(w) {
    warnings <<- c(warnings, conditionMessage(w)); invokeRestart('muffleWarning')
  })
  list(value = value, warnings = warnings)
}
first <- readRDS(paths[1]); other <- readRDS(paths[2])
fits <- list(same = list(first$pcm, first$gpcm),
  different_data = list(first$pcm, other$gpcm))
labels <- c('PCM', 'GPCM')
check_comparison <- function(x, allowed) {
  stopifnot(identical(x$comparison_basis$same_data, allowed),
    all(x$table$ICComparable == allowed))
  if (allowed) {
    stopifnot(x$comparison_basis$lrt_status == 'computed',
      x$comparison_basis$nesting_review$relation == 'PCM_in_GPCM',
      x$lrt$df == 2L,
      abs(x$lrt$ChiSq - 2 * diff(x$table$LogLik)) < 1e-10,
      abs(x$lrt$p_value - pchisq(x$lrt$ChiSq, 2, lower.tail = FALSE)) < 1e-12,
      isTRUE(all.equal(x$lrt, first$comparison$lrt, tolerance = 1e-12)))
    stopifnot(max(abs(x$table$AIC - (-2*x$table$LogLik + 2*x$table$Npar))) < 1e-10,
      max(abs(x$table$BIC - (-2*x$table$LogLik + log(100)*x$table$Npar))) < 1e-10)
  } else {
    stopifnot(is.null(x$lrt), length(x$preferred) == 0L,
      all(is.na(as.matrix(x$table[, c('Delta_AIC','Delta_BIC','Delta_SABIC',
        'AkaikeWeight','BICWeight','SABICWeight')]))),
      grepl('common response data', x$comparison_basis$lrt_reason, fixed = TRUE))
  }
}
if (mode == 'record') {
  stopifnot(!dir.exists(out)); dir.create(out)
  records <- lapply(names(fits), function(name) {
    f <- fits[[name]]; allowed <- name == 'same'
    comp <- capture(compare_mfrm(f[[1]], f[[2]], labels = labels, nested = TRUE))
    check_comparison(comp$value, allowed)
    review <- build_model_choice_review(PCM = f[[1]], GPCM = f[[2]],
      run_weighting_review = FALSE)
    stopifnot(identical(review$comparison_table, comp$value$table))
    tables <- build_summary_table_bundle(review)
    stopifnot(all(tables$tables$comparison_table$ICComparable == allowed))
    if (!allowed) stopifnot(any(grepl('same prepared response data',
      review$comparison_warnings, fixed = TRUE)),
      identical(tables$tables$comparison_warnings$Warning, review$comparison_warnings))
    appendix <- export_summary_appendix(tables, output_dir = file.path(out, name),
      prefix = name, include_html = TRUE)
    warning_path <- appendix$written_files$Path[
      grepl('comparison_warnings', appendix$written_files$Component, fixed = TRUE)]
    if (!allowed) stopifnot(length(warning_path) == 1L,
      identical(read.csv(warning_path)$Warning, review$comparison_warnings))
    plots <- lapply(c('ccc','wright'), function(type) {
      p <- capture(plot_compare_mfrm(f[[1]], f[[2]], type = type,
        view = 'difference', labels = labels, draw = FALSE))
      stopifnot(!p$value$data$display$show_title, !p$value$data$display$show_notes,
        any(grepl('does not prove scale equivalence or identical observations',
          p$value$data$notes$Text, fixed = TRUE)))
      g <- as_ggplot(p$value)
      stopifnot(is.null(g$labels$title), is.null(g$labels$subtitle),
        is.null(g$labels$caption))
      if (allowed) ggplot2::ggsave(file.path(out, paste0(type, '.png')), g,
        width = 9, height = 5.5, dpi = 120)
      p
    })
    names(plots) <- c('ccc','wright')
    list(comparison = comp, review = review, tables = tables,
      appendix = appendix, plots = plots)
  })
  names(records) <- names(fits)
  saveRDS(list(hashes = hashes, records = records, session = sessionInfo()),
    file.path(out, 'workflow.rds'))
} else {
  saved <- readRDS(file.path(out, 'workflow.rds'))
  stopifnot(identical(saved$hashes, hashes))
  for (name in names(fits)) {
    f <- fits[[name]]; old <- saved$records[[name]]
    current <- capture(compare_mfrm(f[[1]], f[[2]], labels = labels, nested = TRUE))
    check_comparison(current$value, name == 'same')
    stopifnot(identical(current, old$comparison),
      identical(build_summary_table_bundle(old$review), old$tables))
    for (type in names(old$plots)) {
      current_plot <- capture(plot_compare_mfrm(f[[1]], f[[2]], type = type,
        view = 'difference', labels = labels, draw = FALSE))
      stopifnot(identical(current_plot$value$data, old$plots[[type]]$value$data),
        identical(current_plot$warnings, old$plots[[type]]$warnings))
      # Redraw the reloaded public plot, without constructing a new fitted model.
      ggplot2::ggplot_build(as_ggplot(old$plots[[type]]$value))
    }
  }
}
stopifnot(identical(tools::md5sum(names(hashes)), hashes))
campaign <- readRDS('validation-results/mfrm-wide-map-d-n480-controls-20261012/dispatch.rds')
stopifnot(identical(tools::md5sum(names(campaign$source)), campaign$source),
  identical(tools::md5sum(names(campaign$inputs)), campaign$inputs))
cat(mode, ': eligible and different-data refusal, report tables, plots and source identity passed.\n')
