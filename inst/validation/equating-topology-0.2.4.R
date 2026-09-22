# Run from the package root. These are graph scenarios, not simulated scores.
pkgload::load_all('.', quiet = TRUE)
args <- commandArgs(trailingOnly = TRUE)
out <- if (length(args)) args[1] else file.path(tempdir(), 'mfrmr-equating-topology')
dir.create(out, recursive = TRUE, showWarnings = FALSE)
waves <- paste('Form', LETTERS[1:4])
mixed <- structure(list(config = list(waves = waves),
  links = data.frame(Link = 1:3, FromID = 1:3, ToID = 2:4,
    From = waves[1:3], To = waves[2:4], N_Common = c(2L, 3L, 0L),
    N_Retained = c(2L, 1L, 0L), LinkSupportAdequate = FALSE),
  element_detail = data.frame(LinkID = c(1L, 1L, 2L, 2L, 2L), Facet = 'Item',
    Level = c('I1', 'I2', 'I1', 'I3', 'I4'),
    Retained = c(TRUE, TRUE, TRUE, FALSE, NA), Flag = c(FALSE, TRUE, FALSE, TRUE, NA))
), class = c('mfrm_equating_chain', 'list'))
empty <- mixed
empty$element_detail <- empty$links <- data.frame()
long <- mixed
long$config$waves <- c('Shared -> form name', 'Shared -> form name', 'C | D', 'A long isolated form name')
long$links$From <- long$config$waves[1:3]
long$links$To <- long$config$waves[2:4]
long$element_detail$Level <- paste0('Common prefix with a long item name ', long$element_detail$Level)
fit <- readRDS('inst/validation/plot-models-0.2.4/fits.rds')[['PCM-interaction-MML']]
actual <- suppressWarnings(build_equating_chain(list(A = fit, B = fit), anchor_facets = 'Criterion'))
cases <- list(mixed = mixed, empty = empty, long = long, public_builder = actual)
results <- list()
for (case in names(cases)) for (type in c('links', 'anchor_removal'))
  for (preset in c('publication', 'monochrome')) for (notes in c(TRUE, FALSE)) {
    key <- paste(case, type, preset, if (notes) 'annotated' else 'clean', sep = '-')
    p <- plot(cases[[case]], type = type, draw = FALSE, preset = preset,
      show_title = notes, show_notes = notes)
    for (device in c('png', 'pdf')) {
      path <- file.path(out, paste0(key, '.', device))
      if (device == 'png') png(path, width = 5, height = 4, units = 'in', res = 150)
      else pdf(path, width = 5, height = 4)
      warnings <- character()
      error <- tryCatch(withCallingHandlers({
        drawn <- plot(cases[[case]], type = type, preset = preset,
          show_title = notes, show_notes = notes)
        stopifnot(identical(drawn, p))
        ''
      }, warning = function(w) {
        warnings <<- c(warnings, conditionMessage(w)); invokeRestart('muffleWarning')
      }), error = function(e) conditionMessage(e))
      dev.off()
      results[[length(results) + 1L]] <- data.frame(Case = case, Type = type, Preset = preset,
        Notes = notes, Device = device, Error = error, Warnings = paste(unique(warnings), collapse = ' | '))
    }
    if (preset == 'publication' && notes) {
      for (table in names(p$data$data)) write.csv(p$data$data[[table]],
        file.path(out, paste(case, type, paste0(table, '.csv'), sep = '-')), row.names = FALSE)
      write.csv(p$data$notes, file.path(out, paste0(case, '-', type, '-notes.csv')), row.names = FALSE)
    }
  }
results <- do.call(rbind, results)
write.csv(results, file.path(out, 'drawings.csv'), row.names = FALSE)
stopifnot(all(results$Error == ''))
files <- c('R/api-advanced.R', 'R/api-plotting-anchor-qc.R', 'R/api-plotting.R',
  'R/api-plotting-fit-family.R', 'R/mfrm_core.R', 'tests/testthat/test-equating-graph.R',
  'inst/validation/equating-topology-0.2.4.R', 'inst/validation/plot-models-0.2.4/fits.rds')
write.csv(data.frame(File = files, MD5 = unname(tools::md5sum(files))),
  file.path(out, 'source-md5.csv'), row.names = FALSE)
writeLines(capture.output(sessionInfo()), file.path(out, 'session-info.txt'))
print(results)
