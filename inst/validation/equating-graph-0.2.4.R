# Run from the package root. Synthetic graph checks are not inferential evidence.
pkgload::load_all('.', quiet = TRUE)
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else file.path(tempdir(), 'mfrmr-equating-graph')
dir.create(out, recursive = TRUE, showWarnings = FALSE)
waves <- c('Form A', 'Form B', 'Form C', 'Form D')
mixed <- structure(list(
  config = list(waves = waves),
  links = data.frame(Link = 1:3, FromID = 1:3, ToID = 2:4,
    From = waves[1:3], To = waves[2:4], N_Common = c(3L, 2L, 0L),
    N_Retained = c(2L, 0L, 0L), LinkSupportAdequate = FALSE),
  cumulative = data.frame(Wave = waves, Cumulative_Offset = c(0, 0.1, 0.2, NA)),
  element_detail = data.frame(LinkID = c(1L, 1L, 1L, 2L, 2L), Facet = 'Item',
    Level = c('I1', 'I2', 'I3', 'I1', 'I4'),
    Retained = c(TRUE, TRUE, FALSE, FALSE, NA), Flag = c(FALSE, TRUE, TRUE, TRUE, NA))
), class = c('mfrm_equating_chain', 'list'))
empty <- mixed
empty$element_detail <- data.frame()
empty$links$N_Common <- empty$links$N_Retained <- 0L
duplicate <- mixed
duplicate$config$waves <- c('Shared -> name', 'Shared -> name', 'C | D', 'Long form name with a shared prefix and final suffix')
duplicate$links$From <- duplicate$config$waves[1:3]
duplicate$links$To <- duplicate$config$waves[2:4]
duplicate$cumulative$Wave <- duplicate$config$waves
duplicate$element_detail$Level[1:3] <- paste0('A very long shared item prefix ending in ', 1:3)
fit <- readRDS('inst/validation/plot-models-0.2.4/fits.rds')[['PCM-interaction-MML']]
# The archived fit remains review-only; repeated fits exercise the public builder.
actual <- suppressWarnings(build_equating_chain(list(A = fit, B = fit), anchor_facets = 'Criterion'))
same_names <- suppressWarnings(build_equating_chain(
  stats::setNames(list(fit, fit, fit), rep('Same -> name', 3)), anchor_facets = 'Criterion'))
same_graph <- plot(same_names, type = 'graph', draw = FALSE)$data$data
stopifnot(same_graph$n_waves == 3L,
  identical(same_graph$links$from, c('wave_1', 'wave_2')),
  identical(same_graph$links$to, c('wave_2', 'wave_3')))
cases <- list(mixed = mixed, empty = empty, duplicate = duplicate, public_builder = actual)
results <- list()
for (case in names(cases)) for (preset in c('publication', 'monochrome')) for (notes in c(TRUE, FALSE)) {
  key <- paste(case, preset, if (notes) 'annotated' else 'clean', sep = '-')
  p <- plot(cases[[case]], type = 'graph', draw = FALSE, preset = preset,
    show_title = notes, show_notes = notes)
  for (device in c('png', 'pdf')) {
    path <- file.path(out, paste0(key, '.', device))
    if (device == 'png') png(path, width = 5, height = 4, units = 'in', res = 150)
    else pdf(path, width = 5, height = 4)
    warnings <- character()
    error <- tryCatch(withCallingHandlers({
      drawn <- plot(cases[[case]], type = 'graph', preset = preset,
        show_title = notes, show_notes = notes)
      stopifnot(identical(drawn, p))
      ''
    }, warning = function(w) {
      warnings <<- c(warnings, conditionMessage(w)); invokeRestart('muffleWarning')
    }), error = function(e) conditionMessage(e))
    dev.off()
    results[[length(results) + 1L]] <- data.frame(Case = case, Preset = preset,
      Notes = notes, Device = device, Error = error, Warnings = paste(unique(warnings), collapse = ' | '))
  }
  if (preset == 'publication' && notes) {
    write.csv(p$data$data$nodes, file.path(out, paste0(case, '-nodes.csv')), row.names = FALSE)
    write.csv(p$data$data$edges, file.path(out, paste0(case, '-edges.csv')), row.names = FALSE)
    write.csv(p$data$notes, file.path(out, paste0(case, '-notes.csv')), row.names = FALSE)
  }
}
results <- do.call(rbind, results)
write.csv(results, file.path(out, 'drawings.csv'), row.names = FALSE)
stopifnot(all(results$Error == ''))
files <- c('R/api-advanced.R', 'R/api-plotting-anchor-qc.R', 'R/api-plotting.R',
  'R/api-plotting-fit-family.R', 'tests/testthat/test-equating-graph.R',
  'tests/testthat/test-anchor-equating.R', 'inst/validation/equating-graph-0.2.4.R',
  'inst/validation/plot-models-0.2.4/fits.rds')
write.csv(data.frame(File = files, MD5 = unname(tools::md5sum(files))),
  file.path(out, 'source-md5.csv'), row.names = FALSE)
writeLines(capture.output(sessionInfo()), file.path(out, 'session-info.txt'))
print(results)
