# One bounded numerical continuation of saved pilot failures; no new responses.
# Run prepare, run, replay with the pilot's four thread limits set to 1.
args <- commandArgs(TRUE)
stopifnot(length(args) == 1L, args %in% c("prepare", "run", "replay"))
action <- args[[1L]]
base <- "validation-results/gmfrm-regularized-feasibility-20261012"
pilot <- file.path(base, "small-pilot")
directory <- file.path(pilot, "continuation")
script <- "inst/validation/gmfrm-small-pilot-continuation-20261012.R"
manifest <- file.path(directory, "manifest.rds")
# Extract frozen function definitions without executing either original driver.
definitions <- function(file, wanted) {
  loaded <- character()
  for (e in parse(file)) if (is.call(e) && identical(e[[1L]], as.name("<-")) &&
      is.symbol(e[[2L]]) && as.character(e[[2L]]) %in% wanted) {
    stopifnot(is.call(e[[3L]]), identical(e[[3L]][[1L]], as.name("function")))
    eval(e, .GlobalEnv); loaded <- c(loaded, as.character(e[[2L]]))
  }
  stopifnot(identical(sort(loaded), sort(wanted)))
}
definitions(file.path(pilot, "source.R"),
  c("check_hash", "write_result", "context", "contrast", "summarize_fit"))
definitions(file.path(base, "source.R"), c("capture", "mapping", "setup", "coordinates", "evaluator"))
m <- readRDS(file.path(base, "manifest.rds"))
plan <- readRDS(file.path(pilot, "manifest.rds"))
original <- readRDS(file.path(pilot, "summary.rds"))
check_hash(m$source); check_hash(m$inputs); check_hash(plan$source); check_hash(plan$inputs)
check_hash(original$outputs)
stopifnot(identical(original$manifest, tools::md5sum(file.path(pilot, "manifest.rds"))),
  identical(m$R, R.version), identical(plan$R, R.version),
  identical(m$threads, Sys.getenv(names(m$threads))), identical(plan$threads, m$threads),
  identical(m$packages, vapply(names(m$packages), function(p) as.character(packageVersion(p)), "")))
library(mfrmr, lib.loc = file.path(base, "library"))
stopifnot(identical(normalizePath(find.package("mfrmr")), normalizePath(file.path(base, "library/mfrmr"))))
fn <- function(n) get(n, asNamespace("mfrmr"))
ref <- new.env(parent = asNamespace("mfrmr"))
sys.source(file.path(base, "pattern-reference.R"), ref)
blocked <- function(...) stop("No response generation in this saved-data continuation.")
for (n in c("rnorm", "runif", "rbinom")) assignInNamespace(n, blocked, "stats")

review <- function(s, co, candidate, target, constrained) capture(function() {
  stopifnot(is.null(candidate$error)); state <- candidate$value
  independent <- ref$mfrm_gmfrm_reference_integrate(ref$mfrm_gmfrm_reference_design(s$specification, state$par))
  full <- -drop(crossprod(s$T, independent$score)) + m$controls$lambda * state$z
  list(reference = independent, state = state, gradient = drop(crossprod(co$U, full)),
    constraint_error = if (constrained) abs(sum(contrast(s$T) * state$par) - target) else 0,
    objective_error = abs(state$nll - independent$nll),
    gradient_error = max(abs(state$full_gradient - full)))
})
summarize <- function(fit, references) {
  # Both endpoints receive the independent check; retain the original criteria.
  rows <- lapply(references, function(r) { x <- fit; x$reference <- r; summarize_fit(x) })
  rows <- do.call(rbind, rows)
  result <- summarize_fit(fit)
  result$Qualified <- all(rows$Qualified)
  result$Reasons <- paste(unique(unlist(strsplit(rows$Reasons[nzchar(rows$Reasons)], ";", fixed = TRUE))), collapse = ";")
  result$ReferenceSeconds <- sum(vapply(references, `[[`, 0, "seconds"))
  result$MaxGradient <- max(rows$MaxGradient)
  result$NLLCheck <- max(rows$NLLCheck)
  result$GradientCheck <- max(rows$GradientCheck)
  list(summary = result, endpoints = rows)
}

if (action == "prepare") {
  stopifnot(!file.exists(manifest))
  failures <- subset(original$fits, Strategy == "primary" & !Qualified)
  allowed <- c("NLLAgreement", "GradientAgreement", "Stationarity")
  failures$Eligible <- vapply(strsplit(failures$Reasons, ";", fixed = TRUE),
    function(r) length(r) > 0L && all(r %in% allowed), TRUE)
  failures$Engine <- ifelse(failures$NLLCheck > m$controls$value_tolerance |
      failures$GradientCheck > m$controls$integration_gradient_tolerance, "segmented", "adaptive121")
  failures$File <- file.path(pilot, failures$Job, paste0("primary-", failures$Kind, ".rds"))
  dir.create(directory)
  stopifnot(file.copy(script, file.path(directory, "source.R")))
  contract <- list(failures = failures,
    controls = list(maxit = m$controls$polish_maxit, factr = 0,
      total_gradient_goal = m$controls$gradient_tolerance / 10),
    inputs = c(tools::md5sum(c(file.path(pilot, c("manifest.rds", "summary.rds")),
      file.path(base, "manifest.rds"))), original$outputs),
    source = c(tools::md5sum(file.path(directory, "source.R")), plan$source),
    R = R.version, threads = m$threads, session = sessionInfo())
  write_result(contract, manifest)
  print(failures[, c("Job", "Cell", "Kind", "Reasons", "Eligible", "Engine")], row.names = FALSE)
  quit(save = "no")
}
contract <- readRDS(manifest); check_hash(contract$inputs); check_hash(contract$source)
stopifnot(identical(contract$R, R.version), identical(contract$threads, m$threads),
  identical(unname(tools::md5sum(script)), unname(contract$source[1L])))
seal <- tools::md5sum(manifest)
eligible <- subset(contract$failures, Eligible)
if (action == "run") {
  for (i in seq_len(nrow(eligible))) {
    row <- eligible[i, ]; file <- file.path(directory, paste0(row$Job, "-", row$Kind, ".rds"))
    if (file.exists(file)) { stopifnot(identical(readRDS(file)$manifest, seal)); next }
    old <- readRDS(row$File); input <- readRDS(file.path(pilot, row$Job, "input.rds"))
    cell <- plan$cells[plan$cells$Cell == row$Cell, ]
    s <- context(cell$Case, input$data); stopifnot(identical(s$T, old$T))
    co <- coordinates(s$T, row$Kind == "null", input$target)
    engine <- if (row$Engine == "segmented")
      fn("mfrm_gmfrm_segmented_evaluator")(s$problem$common$idx, s$problem$common$config, s$problem$common$sizes) else NULL
    likelihood <- if (is.null(engine)) s$likelihood$adaptive121 else engine$evaluate
    attempts <- candidates <- references <- list()
    for (name in names(old$fit$candidates)) {
      u <- drop(crossprod(co$U, old$fit$candidates[[name]]$value$z - co$origin))
      ev <- evaluator(likelihood, s$T, co)
      stage <- capture(function() {
        initial <- ev$evaluate(u)
        fit <- optim(u, function(v) ev$evaluate(v)$value / s$problem$n_person,
          function(v) ev$evaluate(v)$gradient / s$problem$n_person, method = "L-BFGS-B",
          control = list(maxit = contract$controls$maxit, factr = contract$controls$factr,
            pgtol = contract$controls$total_gradient_goal / s$problem$n_person))
        final <- ev$evaluate(fit$par)
        list(u = fit$par, state = final, initial = initial, optimizer = fit, counts = ev$counts())
      })
      if (is.null(stage$error)) u <- stage$value$u
      attempts[[name]] <- list(stages = list(continuation = stage), u = u)
      candidates[[name]] <- capture(function() ev$evaluate(u))
      references[[name]] <- review(s, co, candidates[[name]], input$target, row$Kind == "null")
    }
    values <- vapply(candidates, function(x) if (is.null(x$error)) x$value$value else Inf, 0)
    selected <- names(which.min(values))
    fit <- list(attempts = attempts, candidates = candidates, selected = selected,
      reference = references[[selected]])
    result <- summarize(fit, references)
    write_result(list(manifest = seal, input = tools::md5sum(row$File), T = s$T,
      fit = fit, references = references, summary = result$summary, endpoints = result$endpoints), file)
    cat(row$Job, row$Cell, row$Kind, row$Engine, "qualified", result$summary$Qualified,
      result$summary$Reasons, "seconds", sum(result$summary[c("FitSeconds", "ReviewSeconds", "ReferenceSeconds")]), "\n")
    flush.console()
  }
  quit(save = "no")
}
blocked <- function(...) stop("No fitting or integration during continuation replay.")
for (n in c("optim", "nlminb", "integrate")) assignInNamespace(n, blocked, "stats")
rows <- list(); files <- character()
for (i in seq_len(nrow(eligible))) {
  row <- eligible[i, ]; file <- file.path(directory, paste0(row$Job, "-", row$Kind, ".rds"))
  x <- readRDS(file); result <- summarize(x$fit, x$references)
  stopifnot(identical(x$manifest, seal), identical(x$input, tools::md5sum(row$File)),
    identical(x$summary, result$summary), identical(x$endpoints, result$endpoints))
  rows[[i]] <- cbind(row[, c("Job", "Cell", "Kind", "Engine")], x$summary)
  files <- c(files, file)
}
check_hash(contract$inputs); check_hash(contract$source)
write_result(list(manifest = seal, outputs = tools::md5sum(files), fits = do.call(rbind, rows),
  session = sessionInfo()), file.path(directory, "replay.rds"))
print(do.call(rbind, rows), digits = 6, row.names = FALSE)
cat("Original pilot retained. Selected-failure development evidence, not independent confirmation.\n")
