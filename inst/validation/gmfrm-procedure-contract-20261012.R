# Fixed procedure checks and allocation arithmetic. No stochastic draws.
# Run prepare, witness, replay with the four original thread limits = 1.
args <- commandArgs(TRUE)
stopifnot(length(args) == 1L, args %in% c("prepare", "witness", "replay"))
action <- args[[1L]]
base <- "validation-results/gmfrm-regularized-feasibility-20261012"
pilot <- file.path(base, "small-pilot")
directory <- file.path(base, "procedure-contract")
script <- "inst/validation/gmfrm-procedure-contract-20261012.R"
helper <- "inst/validation/gmfrm-regularized-procedure-20261012.R"
manifest <- file.path(directory, "manifest.rds")
for (e in parse(file.path(pilot, "source.R"))) if (is.call(e) &&
    identical(e[[1L]], as.name("<-")) && identical(e[[2L]], as.name("load_definitions"))) eval(e)
load_definitions(file.path(pilot, "source.R"),
  c("check_hash", "write_result", "context", "contrast", "fit_one", "summarize_fit"))
load_definitions(file.path(base, "source.R"), c("capture", "mapping", "setup", "coordinates", "evaluator", "minimize"))
load_definitions(file.path(pilot, "continuation/source.R"), c("review", "summarize"))
m <- readRDS(file.path(base, "manifest.rds")); plan <- readRDS(file.path(pilot, "manifest.rds"))
original <- readRDS(file.path(pilot, "summary.rds"))
continued <- readRDS(file.path(pilot, "continuation/replay.rds"))
for (h in list(m$source, m$inputs, plan$source, plan$inputs, original$outputs,
    continued$outputs, original$manifest, continued$manifest)) check_hash(h)
stopifnot(identical(m$R, R.version), identical(m$threads, Sys.getenv(names(m$threads))),
  identical(m$packages, vapply(names(m$packages), function(p) as.character(packageVersion(p)), "")))
library(mfrmr, lib.loc = file.path(base, "library"))
stopifnot(identical(normalizePath(find.package("mfrmr")), normalizePath(file.path(base, "library/mfrmr"))))
fn <- function(n) get(n, asNamespace("mfrmr"))
ref <- new.env(parent = asNamespace("mfrmr")); sys.source(file.path(base, "pattern-reference.R"), ref)
sys.source(helper, .GlobalEnv)
blocked <- function(...) stop("New responses are outside this contract check.")
for (n in c("rnorm", "runif", "rbinom")) assignInNamespace(n, blocked, "stats")

saved_pair <- function(job) {
  fits <- lapply(c("free", "null"), function(kind) {
    original_file <- file.path(pilot, job, paste0("primary-", kind, ".rds"))
    old <- readRDS(original_file); route <- regularized_route(old$summary)
    fallback_file <- file.path(pilot, "continuation", paste0(job, "-", kind, ".rds"))
    final <- if (route %in% c("segmented", "adaptive121")) readRDS(fallback_file) else old
    list(primary = old, route = route, fit = final$fit, summary = final$summary)
  })
  names(fits) <- c("free", "null")
  c(list(fits = fits), regularized_statistic(fits$free, fits$null))
}
if (action != "witness") for (n in c("optim", "nlminb", "integrate")) assignInNamespace(n, blocked, "stats")

if (action == "prepare") {
  stopifnot(!file.exists(manifest))
  primary <- subset(original$fits, Strategy == "primary")
  routes <- vapply(seq_len(nrow(primary)), function(i) regularized_route(primary[i, ]), "")
  stopifnot(sum(routes == "accept") == 89L, sum(routes == "segmented") == 3L,
    sum(routes == "adaptive121") == 2L)
  saved <- lapply(plan$jobs$Job, saved_pair)
  stopifnot(all(vapply(saved, `[[`, TRUE, "qualified")))
  bad <- readRDS(file.path(pilot, "job-014/primary-free.rds"))
  for (reason in c("IndependentIntegral", "StartObjective", "StartCoordinates", "Constraint", "NoErrors", "Unknown")) {
    x <- bad$summary; x$Reasons <- reason
    stopifnot(regularized_route(x) == "unavailable")
  }
  # Verify failure returns once rather than retrying a selected case indefinitely.
  local <- new.env(parent = .GlobalEnv); local$count <- 0L
  local$fit_one <- function(...) bad$fit
  local$regularized_continue <- function(...) { local$count <- local$count + 1L; bad }
  f <- regularized_fit; environment(f) <- local
  failure <- f(list(), 0, FALSE)
  stopifnot(local$count == 1L, !failure$summary$Qualified, identical(failure$fit, bad$fit))
  local$regularized_continue <- function(...) stop("deliberate continuation exception")
  stopifnot(grepl("^Continuation:", f(list(), 0, FALSE)$summary$Reasons))
  local$fit_one <- function(...) stop("deliberate primary exception")
  stopifnot(grepl("^Primary:", f(list(), 0, FALSE)$summary$Reasons))
  data <- m$cases[["N20-observed"]]$specification$data; data$Score <- 0
  refusal <- regularized_pair("N20-observed", data, 0)
  stopifnot(!refusal$qualified, is.na(refusal$statistic),
    all(vapply(refusal$fits, function(x) grepl("at least two distinct", x$summary$Reasons), TRUE)))
  valid <- saved[[1L]]$fits
  valid$null$summary$Q <- valid$free$summary$Q - 1
  stopifnot(!regularized_statistic(valid$free, valid$null)$qualified)
  # Exhaustive exchangeable four-state example, including a response-related failure.
  states <- c(-2, 0, 4, NA_real_); prob <- c(.2, .3, .4, .1)
  grid <- as.matrix(expand.grid(rep(list(seq_along(states)), 4L)))
  mass <- apply(grid, 1L, function(x) prod(prob[x]))
  decisions <- apply(grid, 1L, function(x) {
    v <- states[x]; answer <- regularized_rank(v[1L], v[-1L], .25)
    completed <- ifelse(is.na(v), 1, 2 * atan(v) / pi)
    exact <- (1 + sum(completed[-1L] >= completed[1L])) / 4
    stopifnot(answer$p_upper >= exact)
    answer$status == "reject"
  })
  stopifnot(sum(mass * decisions) <= .25 + 1e-12,
    regularized_rank(NA_real_, states)$status == "observed_unavailable",
    regularized_rank(1, rep(NA_real_, 19))$status == "unresolved",
    regularized_rank(1, rep(1, 19))$p_upper == 1,
    regularized_rank(1, rep(0, 19))$status == "reject")
  # All missing-comparison completions stay in the declared rank bounds.
  bounds <- regularized_rank(2, c(2, 3, 0, 1, NA, NA, NA))
  ps <- (1 + 2 + rowSums(expand.grid(rep(list(0:1), 3)))) / 8
  stopifnot(all(ps >= bounds$p_lower), all(ps <= bounds$p_upper))
  # Prices reuse original work plus the selected continuation, not rerun fits.
  primary$Seconds <- rowSums(primary[c("FitSeconds", "ReviewSeconds", "ReferenceSeconds")])
  for (i in seq_len(nrow(continued$fits))) {
    row <- continued$fits[i, ]; at <- primary$Job == row$Job & primary$Kind == row$Kind
    primary$Seconds[at] <- primary$Seconds[at] + sum(row[c("FitSeconds", "ReviewSeconds", "ReferenceSeconds")])
  }
  cost <- aggregate(Seconds ~ Cell, primary, sum)
  cost$Draws <- plan$cells$B[match(cost$Cell, plan$cells$Cell)]
  cost$PairSeconds <- cost$Seconds / cost$Draws
  power <- do.call(rbind, lapply(c(.10, .15), function(alternative) {
    n <- 1:1000
    critical <- vapply(n, function(r) {
      k <- 0:r; admissible <- k[pbinom(k - 1, r, .05, lower.tail = FALSE) <= .05]
      if (length(admissible)) min(admissible) else r + 1
    }, 0)
    achieved <- pbinom(critical - 1, n, alternative, lower.tail = FALSE)
    j <- which(achieved >= .8)[1L]
    data.frame(Alternative = alternative, R = n[j], Critical = critical[j],
      Level = pbinom(critical[j] - 1, n[j], .05, lower.tail = FALSE), Power = achieved[j])
  }))
  allocation <- merge(merge(cost, power), data.frame(B = c(19L, 199L, 1999L)))
  allocation$WorkerHours <- allocation$PairSeconds * allocation$R * (allocation$B + 1) / 3600
  dir.create(directory)
  stopifnot(file.copy(helper, file.path(directory, "procedure.R")), file.copy(script, file.path(directory, "source.R")))
  contract <- list(witnesses = c("job-001", "job-014"), routes = routes,
    saved_statistics = vapply(saved, `[[`, 0, "statistic"), rank_check_size = sum(mass * decisions),
    refusal = refusal, cost = cost, power = power, allocation = allocation,
    inputs = c(tools::md5sum(c(file.path(base, "manifest.rds"), file.path(pilot, c("manifest.rds", "summary.rds", "continuation/replay.rds")))),
      original$outputs, continued$outputs),
    source = c(tools::md5sum(c(file.path(directory, c("procedure.R", "source.R")),
      file.path(pilot, "continuation/source.R"))), plan$source),
    R = R.version, threads = m$threads, session = sessionInfo())
  write_result(contract, manifest)
  print(table(routes)); print(cost, row.names = FALSE); print(power, row.names = FALSE)
  cat("Contract fixed; no new draws. Two retained-data end-to-end witnesses only.\n")
  quit(save = "no")
}
contract <- readRDS(manifest); check_hash(contract$inputs); check_hash(contract$source)
stopifnot(identical(contract$R, R.version), identical(contract$threads, m$threads),
  identical(unname(tools::md5sum(c(helper, script))), unname(contract$source[1:2])))
seal <- tools::md5sum(manifest)
rows <- list(); outputs <- character()
for (job in contract$witnesses) {
  file <- file.path(directory, paste0(job, ".rds"))
  input <- readRDS(file.path(pilot, job, "input.rds"))
  cell <- plan$cells[plan$cells$Cell == input$job$Cell, ]
  if (action == "witness" && !file.exists(file)) {
    execution <- capture(function() regularized_pair(cell$Case, input$data, input$target))
    write_result(list(manifest = seal, execution = execution), file)
  }
  x <- readRDS(file); stopifnot(identical(x$manifest, seal), is.null(x$execution$error))
  expected <- saved_pair(job); actual <- x$execution$value
  stopifnot(actual$qualified, identical(lapply(actual$fits, `[[`, "route"), lapply(expected$fits, `[[`, "route")),
    abs(actual$statistic - expected$statistic) < 1e-6)
  for (kind in c("free", "null")) {
    a <- actual$fits[[kind]]; b <- expected$fits[[kind]]
    stopifnot(max(abs(a$fit$reference$value$state$z - b$fit$reference$value$state$z)) < 1e-5)
    independently_summarized <- if (a$route == "accept") summarize_fit(a$fit) else
      summarize(a$fit, a$continuation$references)$summary
    stopifnot(identical(a$summary, independently_summarized))
  }
  rows[[job]] <- data.frame(Job = job, Qualified = actual$qualified, Statistic = actual$statistic,
    ReferenceDifference = actual$statistic - expected$statistic, Seconds = x$execution$seconds)
  outputs <- c(outputs, file)
  print(rows[[job]], row.names = FALSE); flush.console()
}
check_hash(contract$inputs); check_hash(contract$source)
if (action == "replay") write_result(list(manifest = seal, outputs = tools::md5sum(outputs),
  witnesses = do.call(rbind, rows), session = sessionInfo()), file.path(directory, "replay.rds"))
