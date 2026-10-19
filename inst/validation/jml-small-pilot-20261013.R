# Independent engineering/cost pilot, not a coverage study or a new interval rule.
args <- commandArgs(TRUE)
stopifnot(length(args) == 1L, args %in% c("prepare", "fit", "replay"))
action <- args[1]
out <- "validation-results/jml-small-pilot-20261013"
script <- "inst/validation/jml-small-pilot-20261013.R"
threads <- c("OMP_NUM_THREADS", "OPENBLAS_NUM_THREADS", "MKL_NUM_THREADS", "VECLIB_MAXIMUM_THREADS")
check_hash <- function(h) stopifnot(length(h) > 0L, !anyNA(h), identical(tools::md5sum(names(h)), h))
save_new <- function(x, p) {
  stopifnot(!file.exists(p)); saveRDS(x, paste0(p, ".tmp"))
  stopifnot(file.rename(paste0(p, ".tmp"), p))
}
if (action == "prepare") {
  stopifnot(!dir.exists(out), all(Sys.getenv(threads) == "1"))
  installed <- "tmp/owner-category-20261012/install-check"
  live <- list.files("R", "[.]R$", full.names = TRUE)
  built <- file.path(installed, "source/mfrmr/R", basename(live))
  source_live <- tools::md5sum(live); source_installed <- tools::md5sum(built)
  stopifnot(!anyNA(source_installed))
  changed <- live[source_live != source_installed]
  # The sole subsequent change batches identical GMFRM reference integrals;
  # JML source is unchanged. Bind the reviewed exception, and forbid that
  # unrelated routine at runtime rather than rebuilding an identical JML path.
  stopifnot(identical(changed, "R/core-gmfrm-reference.R"),
    source_live[[changed]] == "38457848a36514b15a4a0c96685d683b",
    source_installed[[which(live == changed)]] == "6c9b1acc8861d89bd60ea7f749d91196")
  helper <- paste0("inst/validation/", c("jml-observed-inference-20261001.R",
    "jml-design-adjustment-20260927.R", "jml-total-expectation-20260927.R",
    "jml-profile-bias-sample-20260927.R", "jml-profile-bias-exact-20260927.R"))
  dir.create(file.path(out, "library"), recursive = TRUE)
  stopifnot(file.copy(file.path(installed, "library/mfrmr"), file.path(out, "library"), recursive = TRUE))
  for (f in c(script, helper)) {
    dest <- file.path(out, "source", f); dir.create(dirname(dest), recursive = TRUE, showWarnings = FALSE)
    stopifnot(file.copy(f, dest))
  }
  source(helper[1])
  designs <- jml_observed_designs()[1:2]
  parents <- expand.grid(Design = 1:2, N = c(20L, 60L), Replicate = 1:2)
  parents$Parent <- seq_len(nrow(parents))
  jobs <- merge(parents, data.frame(L = 1:2), by = NULL, sort = FALSE)
  jobs <- jobs[order(jobs$Parent, jobs$L), ]; rownames(jobs) <- NULL
  RNGkind("L'Ecuyer-CMRG"); set.seed(20261013)
  streams <- vector("list", 8L); streams[[1]] <- .Random.seed
  for (i in 2:8) streams[[i]] <- parallel::nextRNGStream(streams[[i - 1L]])
  population <- setNames(lapply(1:2, function(i) setNames(lapply(1:2, function(l)
    sprintf("validation-results/jml-exposure-roots-20261001/%s-%s-2-%d.rds",
      designs[[i]]$owner, c("unequal", "sparse")[i], l)), 1:2)), 1:2)
  for (i in 1:2) for (l in 1:2) {
    ref <- readRDS(population[[i]][[l]])
    stopifnot(isTRUE(ref$status$Reviewed), ref$status$Owner == designs[[i]]$owner,
      ref$status$Order == 2L, ref$status$L == l,
      identical(ref$rows$Parameter, names(designs[[i]]$truth)),
      identical(ref$rows$Truth, unname(designs[[i]]$truth)))
  }
  old_pilot <- "validation-results/jml-observed-inference-20261001/pilot-summary.csv"
  m <- list(designs = designs, parents = parents, jobs = jobs, streams = streams,
    population = population, population_N = 400L,
    inputs = tools::md5sum(c(unlist(population), old_pilot,
      "validation-results/jml-scope-challenge-20260927/contract.rds")),
    source = tools::md5sum(list.files(out, recursive = TRUE, full.names = TRUE)),
    source_R = source_live, installed_R = source_installed,
    source_exception = "Only GMFRM reference-integral batching differs; forbidden in this JML pilot",
    R = R.version, threads = Sys.getenv(threads),
    packages = vapply(c("Matrix", "statmod", "cpp11"), function(p) as.character(packageVersion(p)), ""),
    protocol = list(aim = "Generator/reference alignment, complete procedure and cost; not coverage estimation",
      estimand = "Structural truth and independently computed order-2 population root, separately",
      law = "Independent new Persons within fixed roster counts; known three-point ability mixture per roster",
      procedure = "Public GPCM JML, explicit order 2, maxit 400, default starts; consistent-root research intervals",
      allocation = "Eight independent parents, two nested exposure views each, sixteen attempts; no repairs or extension",
      comparison = "Existing ordinary/order-4/MML and equal-slope evidence retained; no method-superiority claim",
      role = "Development pilot excluded from any subsequent independent confirmation"))
  check_hash(m$inputs); check_hash(m$source)
  save_new(m, file.path(out, "manifest.rds"))
  cat("Frozen eight parents / sixteen fits; no responses or fits yet.\n")
  quit(save = "no")
}
out <- normalizePath(out); manifest <- file.path(out, "manifest.rds")
m <- readRDS(manifest); check_hash(m$inputs); check_hash(m$source)
stopifnot(identical(unname(tools::md5sum(script)),
  unname(tools::md5sum(file.path(out, "source", script)))))
stopifnot(identical(m$R, R.version), identical(m$threads, Sys.getenv(threads)),
  identical(m$packages, vapply(names(m$packages), function(p) as.character(packageVersion(p)), "")))
manifest_hash <- tools::md5sum(manifest)
if (action == "fit") {
  library(mfrmr, lib.loc = file.path(out, "library"))
  stopifnot(identical(normalizePath(find.package("mfrmr")), file.path(out, "library/mfrmr")))
  trace("mfrm_gmfrm_reference_integrate",
    quote(stop("Unplanned GMFRM reference call in the JML pilot")),
    where = asNamespace("mfrmr"), print = FALSE)
  setwd(file.path(out, "source"))
  source("inst/validation/jml-observed-inference-20261001.R")
  # Generalize only N and the nested event count of the retained generator.
  generate <- function(d, N, stream) {
    assign(".Random.seed", stream, .GlobalEnv)
    sizes <- N * d$proportions; stopifnot(all(sizes == round(sizes)), all(sizes >= 2))
    roster <- rep(seq_along(sizes), sizes)
    theta <- unlist(lapply(seq_along(sizes), function(g)
      sample(d$ability[[g]], sizes[g], replace = TRUE, prob = c(.25, .5, .25))))
    map <- jml_observed_expand(list(Rater = c("1", "2"), Criterion = c("1", "2")), d$owner, 2L)
    expanded <- drop(map$H %*% d$truth)
    steps <- matrix(expanded[5:8], 2, 2, byrow = TRUE)
    slopes <- exp(expanded[9:10]); stopifnot(abs(prod(slopes) - 1) < 1e-12)
    probability <- lapply(seq_len(nrow(d$cells)), function(j) {
      own <- d$cells[[d$owner]][j]
      eta <- theta - expanded[d$cells$Rater[j]] - expanded[2 + d$cells$Criterion[j]]
      logits <- slopes[own] * (outer(eta, 0:2) - matrix(c(0, cumsum(steps[own, ])), N, 3, byrow = TRUE))
      p <- exp(logits - apply(logits, 1, max)); p <- p / rowSums(p)
      # Independent adjacent-category recurrence checks the generating formula.
      odds <- exp(slopes[own] * (eta - matrix(steps[own, ], N, 2, byrow = TRUE)))
      q <- cbind(1, odds[, 1], odds[, 1] * odds[, 2]); q <- q / rowSums(q)
      stopifnot(max(abs(p - q)) < 1e-13, all(p > 0), max(abs(rowSums(p) - 1)) < 1e-13)
      p
    })
    counts <- lapply(probability, function(p) matrix(0L, N, 3)); arms <- list()
    for (l in 1:2) {
      for (j in seq_along(probability)) for (i in seq_len(N)) {
        n <- d$exposure[[roster[i]]][j]
        if (n) counts[[j]][i, ] <- counts[[j]][i, ] + drop(rmultinom(1L, n, probability[[j]][i, ]))
      }
      arms[[as.character(l)]] <- counts
    }
    stopifnot(all(vapply(seq_along(counts), function(j)
      all(arms[["2"]][[j]] >= arms[["1"]][[j]]), TRUE)))
    list(roster = roster, theta = theta, counts = arms, stream = stream, end_stream = .Random.seed)
  }
  for (i in seq_len(nrow(m$jobs))) {
    job <- m$jobs[i, ]; d <- m$designs[[job$Design]]
    ip <- file.path(out, sprintf("input-%02d.rds", job$Parent))
    fp <- file.path(out, sprintf("fit-%02d-L%d.rds", job$Parent, job$L))
    if (!file.exists(ip)) save_new(list(manifest = manifest_hash, parent = m$parents[job$Parent, ],
      input = generate(d, job$N, m$streams[[job$Parent]])), ip)
    input <- readRDS(ip)
    stopifnot(identical(input$manifest, manifest_hash), identical(input$input$stream, m$streams[[job$Parent]]))
    ih <- tools::md5sum(ip)
    if (file.exists(fp)) { old <- readRDS(fp); stopifnot(identical(old$input, ih), identical(old$job, job)); next }
    before <- proc.time()[["elapsed"]]
    data <- jml_observed_long(input$input$counts[[as.character(job$L)]], d$cells)
    fit <- jml_observed_public(data, d$owner, d$rating_max)
    save_new(list(manifest = manifest_hash, input = ih, job = job, fit = fit,
      total_seconds = proc.time()[["elapsed"]] - before), fp)
    cat("Saved parent", job$Parent, "N", job$N, "L", job$L, "seconds", fit$seconds, "\n"); flush.console()
  }
}
# Replay only reads completed results and independent population references.
setwd(dirname(dirname(out)))
status <- list(); rows <- list(); files <- character()
for (i in seq_len(nrow(m$jobs))) {
  job <- m$jobs[i, ]; fp <- file.path(out, sprintf("fit-%02d-L%d.rds", job$Parent, job$L))
  z <- readRDS(fp); check_hash(z$input)
  stopifnot(identical(z$manifest, manifest_hash), identical(z$job, job))
  files <- unique(c(files, fp, names(z$input)))
  ref <- readRDS(m$population[[job$Design]][[as.character(job$L)]])
  stopifnot(ref$status$Reviewed)
  fit <- z$fit; has_point <- is.null(fit$error) && isTRUE(fit$result$point$available)
  eligible <- has_point && identical(fit$result$point$status, "consistent_roots") &&
    isTRUE(fit$result$covariance$available) && all(fit$rows$Available)
  status[[i]] <- cbind(job, data.frame(Point = has_point, Interval = eligible,
    Status = if (!is.null(fit$error)) fit$error else fit$result$point$status,
    FitSeconds = fit$seconds, TotalSeconds = z$total_seconds))
  se <- if (eligible) sqrt(diag(fit$result$covariance$result$vcov)) else rep(NA_real_, 5)
  estimate <- if (has_point) fit$result$point$beta else rep(NA_real_, 5)
  rows[[i]] <- cbind(job[rep(1L, 5L), , drop = FALSE],
    data.frame(Parameter = names(m$designs[[job$Design]]$truth),
      Estimate = estimate, SE = se, Truth = m$designs[[job$Design]]$truth,
      PopulationRoot = ref$root, PopulationSE = sqrt(diag(ref$vcov) * m$population_N / job$N)))
}
result <- list(status = do.call(rbind, status), rows = do.call(rbind, rows),
  results = tools::md5sum(files), manifest = manifest_hash,
  interpretation = "Sixteen development attempts; no coverage estimate or candidate qualification")
path <- file.path(out, "completion.rds")
if (action == "fit") save_new(result, path) else stopifnot(identical(result, readRDS(path)))
if (action == "replay") stopifnot(!exists(".Random.seed", .GlobalEnv), !"mfrmr" %in% loadedNamespaces())
print(result$status, row.names = FALSE)
cat("Complete:", nrow(result$status), "attempts; fit seconds", sum(result$status$FitSeconds), "\n")
