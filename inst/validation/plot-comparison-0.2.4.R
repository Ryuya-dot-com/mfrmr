# Paired-plot replay: fitted example plus explicitly edited rendering fixtures.
pkgload::load_all('.', quiet = TRUE)
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else file.path(tempdir(), 'mfrmr-plot-comparison')
dir.create(out, recursive = TRUE, showWarnings = FALSE)
toy <- load_mfrmr_data('example_core')
toy <- toy[toy$Person %in% unique(toy$Person)[1:12], ]
fit_warnings <- character()
fits <- lapply(c('RSM', 'PCM'), function(model) withCallingHandlers(
  fit_mfrm(toy, person = 'Person', facets = c('Rater', 'Criterion'), score = 'Score',
    model = model, method = 'JML', maxit = 60),
  warning = function(w) {fit_warnings <<- c(fit_warnings, conditionMessage(w)); invokeRestart('muffleWarning')}))
saveRDS(fits, file.path(out, 'fits.rds'))
writeLines(fit_warnings, file.path(out, 'fit-warnings.log'))
group <- as.character(fits[[2]]$steps$StepFacet[1])
eleven <- fits[[1]]
eleven$config$n_cat <- 11L
eleven$config$rating_min <- eleven$prep$rating_min <- 0
eleven$config$rating_max <- eleven$prep$rating_max <- 10
eleven$config$score_map <- eleven$prep$score_map <- data.frame(InternalScore = 0:10, OriginalScore = 5:15)
eleven$steps <- data.frame(Step = paste0('Step_', 1:10), Estimate = seq(-2, 2, length.out = 10))
shifted <- eleven; shifted$steps$Estimate <- shifted$steps$Estimate + 0.15
singleton <- fits[[1]]; singleton$facets$person <- singleton$facets$person[1, ]
unmatched <- singleton; unmatched$facets$person$Person <- 'Unmatched person'
long <- fits[[2]]
long_group <- 'Criterion with a deliberately long descriptive name'
long$steps$StepFacet[long$steps$StepFacet == group] <- long_group
long$prep$levels[[long$config$step_facet]][long$prep$levels[[long$config$step_facet]] == group] <- long_group
cases <- list(paired = fits, eleven = list(eleven, shifted), singleton = list(fits[[1]], singleton),
  unmatched = list(singleton, unmatched), long = list(fits[[1]], long))
rows <- list()
for (case in names(cases)) {
  types <- if (case %in% c('paired', 'eleven')) c('wright', 'ccc') else if (case == 'long') 'ccc' else 'wright'
  presets <- if (case %in% c('paired', 'eleven')) c('publication', 'monochrome') else 'monochrome'
  annotations <- if (case == 'paired') c(TRUE, FALSE) else FALSE
  for (type in types) for (view in c('comparison', 'difference')) for (preset in presets) for (notes in annotations) {
    key <- paste(case, type, view, preset, if (notes) 'annotated' else 'clean', sep = '-')
    call_args <- list(reference = cases[[case]][[1]], comparison = cases[[case]][[2]],
      type = type, view = view, preset = preset, show_title = notes, show_notes = notes,
      labels = if (case %in% c('paired', 'long')) c('RSM', 'PCM') else c('Reference', 'Comparison'),
      curve_groups = if (case == 'paired') group else if (case == 'long') long_group else NULL)
    source_warnings <- character()
    p <- withCallingHandlers(do.call(plot_compare_mfrm, c(call_args, list(draw = FALSE))),
      warning = function(w) {source_warnings <<- c(source_warnings, conditionMessage(w)); invokeRestart('muffleWarning')})
    for (device in c('png', 'pdf')) {
      filename <- paste0(key, '.', device)
      width <- if (case == 'eleven') 10 else 9
      height <- if (case == 'eleven') 9 else 5.5
      if (device == 'png') png(file.path(out, filename), width = width, height = height, units = 'in', res = 130)
      else pdf(file.path(out, filename), width = width, height = height)
      warnings <- character()
      error <- tryCatch(withCallingHandlers({
        q <- do.call(plot_compare_mfrm, call_args)
        stopifnot(identical(p, q)); ''
      }, warning = function(w) {warnings <<- c(warnings, conditionMessage(w)); invokeRestart('muffleWarning')}),
        error = function(e) conditionMessage(e))
      dev.off()
      expected <- grepl('^Review-only display:|^Many comparison panels;', warnings)
      rows[[length(rows) + 1L]] <- data.frame(Case = case, Type = type, View = view,
        Preset = preset, Notes = notes, Device = device, File = filename, Error = error,
        Warnings = paste(unique(warnings), collapse = ' | '), UnexpectedWarnings = sum(!expected))
    }
    if (preset == presets[1] && identical(notes, annotations[1])) {
      saveRDS(p, file.path(out, paste0(case, '-', type, '-', view, '-payload.rds')))
      for (nm in names(p$data)) if (is.data.frame(p$data[[nm]])) write.csv(p$data[[nm]],
        file.path(out, paste0(case, '-', type, '-', view, '-', nm, '.csv')), row.names = FALSE)
    }
  }
}
drawings <- do.call(rbind, rows)
write.csv(drawings, file.path(out, 'drawings.csv'), row.names = FALSE)
stopifnot(nrow(drawings) == 60L, all(drawings$Error == ''), all(drawings$UnexpectedWarnings == 0L))
files <- c('R/api-plotting-comparison.R', 'R/api-plotting-fit-family.R', 'R/api-as-ggplot.R',
  'R/api-plotting-wright-facets.R', 'R/api-estimation.R', 'R/api-methods.R',
  'tests/testthat/test-plot-comparison.R', 'inst/validation/plot-comparison-0.2.4.R')
write.csv(data.frame(File = files, MD5 = unname(tools::md5sum(files))), file.path(out, 'source-md5.csv'), row.names = FALSE)
writeLines(capture.output(sessionInfo()), file.path(out, 'session-info.txt'))
print(drawings[, c('Case', 'Type', 'View', 'Preset', 'Notes', 'Device', 'Error', 'UnexpectedWarnings')])
