# Arguments: installed package library, output directory, and optional replay mode.
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) %in% 2:3)
checked_library <- normalizePath(args[[1L]], winslash = "/", mustWork = TRUE)
.libPaths(c(checked_library, .libPaths()))
library(mfrmr)
stopifnot(identical(normalizePath(find.package("mfrmr"), winslash = "/"),
                    file.path(checked_library, "mfrmr")))

read_ratings <- function(path, score) {
  ratings <- read.csv(path, check.names = FALSE, colClasses = "character",
                      na.strings = "", fileEncoding = "UTF-8")
  ratings[[score]] <- as.numeric(ratings[[score]])
  ratings
}

inspect_analysis <- function(wf, ratings, keys, score) {
  retained <- which(!is.na(ratings[[score]]))
  obs <- augment(wf)
  expected <- predict(wf, type = "response")
  stopifnot(glance(wf)$n_obs == length(retained), identical(obs$.row_id, retained),
            identical(obs$Observed, ratings[[score]][retained]),
            isTRUE(all.equal(obs$Expected, as.numeric(expected), tolerance = 1e-12)),
            isTRUE(summary(wf)$readiness$ready))
  for (key in keys) stopifnot(identical(obs[[key]], ratings[[key]][retained]))
  list(observations = obs, raters = tidy(wf, "raters"), coefficients = coef(wf))
}

output <- args[[2L]]
if (length(args) == 3L) {
  stopifnot(identical(args[[3L]], "replay"))
  baseline <- readRDS(file.path(output, "reference.rds"))
  ratings <- read_ratings(file.path(output, "ratings.csv"), baseline$score)
  wf <- readRDS(file.path(output, "analysis.rds"))
  actual <- inspect_analysis(wf, ratings, baseline$keys, baseline$score)
  stopifnot(identical(actual, baseline$result))
  html <- render_mfrm_report(wf, format = "html")
  if (baseline$check_escaping) {
    stopifnot(grepl("&lt;R01&gt; &amp;", html, fixed = TRUE),
              !grepl("<R01> &", html, fixed = TRUE))
  }
  writeLines(html, file.path(output, "report.html"), useBytes = TRUE)
  cat("Moved-folder replay matches ratings and diagnostics.\n")
  quit(save = "no")
}

dir.create(output, recursive = TRUE, showWarnings = FALSE)
output <- normalizePath(output, winslash = "/", mustWork = TRUE)
script_arg <- grep("^--file=", commandArgs(), value = TRUE)
script <- normalizePath(sub("^--file=", "", script_arg), winslash = "/")

ratings <- load_mfrmr_data("example_core")
columns <- c("Person", "Rater", "Criterion", "Score")
translated <- c("\u53d7\u9a13\u8005 ID", "\u8a55\u5b9a\u8005",
                "\u89b3\u70b9", "\u5f97\u70b9")
unicode <- ratings
unicode$Rater <- paste0("\u8a55\u5b9a\u8005 <", unicode$Rater, "> & \u540d\u79f0")
literal <- ratings
ids <- unique(literal$Person)
literal$Person <- c("01", "1", "NA", ids[-(1:3)])[match(literal$Person, ids)]
pcm <- transform(ratings, Score = Score + 10)
limited <- pcm$Criterion == "Content"
pcm$Score[limited] <- pmin(pcm$Score[limited], 13)
support <- data.frame(Level = "Content", Min = 11, Max = 13)
weighted <- transform(ratings, Weight = rep(c(0, .5, 1, 2), length.out = nrow(ratings)))
weighted$Score[2:4] <- NA_real_
people <- unique(literal[c("Person", "Group")])
people[["Group code"]] <- factor(people$Group, levels = rev(sort(unique(people$Group))))
contrasts(people[["Group code"]]) <- contr.sum(2)

run_case <- function(name, data, fields = columns, fit_args = list(),
                     diagnostic_args = list(), check_escaping = FALSE) {
  names(data)[match(columns, names(data))] <- fields
  keys <- fields[1:3]
  score <- fields[[4L]]
  folder <- file.path(output, paste0(name, "-original"))
  dir.create(folder)
  path <- file.path(folder, "ratings.csv")
  write.csv(data, path, row.names = FALSE, na = "", fileEncoding = "UTF-8")
  input <- read_ratings(path, score)
  for (key in keys) stopifnot(identical(input[[key]], data[[key]]))
  stopifnot(isTRUE(all.equal(input[[score]], data[[score]])))
  retained <- !is.na(input[[score]])
  if ("Weight" %in% names(input)) {
    input$Weight <- as.numeric(input$Weight)
    retained <- retained & input$Weight > 0
  }
  fit <- do.call(fit_mfrm, c(list(data = input, person = keys[[1L]],
                                facets = keys[2:3], score = score), fit_args))
  # Attach a calibration to the same retained rating rows and order it used.
  input <- input[retained, , drop = FALSE]
  write.csv(input, path, row.names = FALSE, fileEncoding = "UTF-8")
  wf <- mfrm_workflow(input, keys[[1L]], keys[2:3], score, fit = fit)
  wf <- do.call(step_mfrm_diagnose, c(list(wf), diagnostic_args))
  result <- inspect_analysis(wf, input, keys, score)
  saveRDS(wf, file.path(folder, "analysis.rds"))
  saveRDS(list(keys = keys, score = score, result = result, check_escaping = check_escaping),
          file.path(folder, "reference.rds"))
  moved <- file.path(output, paste0(name, " \u79fb\u52d5 folder"))
  stopifnot(file.rename(folder, moved))
  log <- file.path(moved, "fresh-session.log")
  status <- system2(file.path(R.home("bin"), "Rscript"),
                    c("--vanilla", shQuote(script), shQuote(checked_library),
                      shQuote(moved), "replay"), stdout = log, stderr = log)
  if (status != 0L) {
    writeLines(readLines(log, warn = FALSE))
    stop("Fresh-session replay failed for ", name, call. = FALSE)
  }
  cat(name, "PASS\n")
}

run_case("nonstandard_columns", ratings, translated)
run_case("unicode_mml", unicode, translated, check_escaping = TRUE)
run_case("literal_ids_jml", literal, fit_args = list(method = "JML"))
run_case("pcm_varying_steps", pcm, fit_args = list(model = "PCM", step_facet = "Criterion",
                                                  category_support = support))
run_case("gpcm_varying_slopes", ratings, fit_args = list(model = "GPCM", step_facet = "Criterion",
                                                        slope_facet = "Criterion"))
run_case("weighted_missing", weighted, fit_args = list(weight = "Weight"))
run_case("latent_factor", literal, fit_args = list(population_formula = ~ `Group code`, person_data = people))
run_case("diagnostic_options", ratings, diagnostic_args = list(cut_scores = 2.5))
run_case("fixed_anchor", ratings, fit_args = list(
  anchors = data.frame(Facet = "Rater", Level = "R01", Anchor = 0)))
