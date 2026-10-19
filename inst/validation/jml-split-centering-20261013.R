# Saved-root decision for a design-preserving split of order-2 corrected JML.
# No responses, fits, derivatives or interval-coverage calculations are run.
args <- commandArgs(TRUE)
stopifnot(length(args) == 1L, args %in% c("prepare", "review", "replay"))
action <- args[1]
out <- "validation-results/jml-split-centering-20261013"
script <- "inst/validation/jml-split-centering-20261013.R"
base <- "validation-results/jml-exposure-roots-20261001"
check_hash <- function(h) stopifnot(length(h) > 0L, !anyNA(h),
  identical(tools::md5sum(names(h)), h))
save_new <- function(x, path) {
  stopifnot(!file.exists(path))
  saveRDS(x, paste0(path, ".tmp"))
  stopifnot(file.rename(paste0(path, ".tmp"), path))
}
if (action == "prepare") {
  stopifnot(!dir.exists(out))
  previous <- readRDS(file.path(base, "stage-reconciliation.rds"))
  check_hash(previous$result_hashes); check_hash(previous$source_hash)
  m <- readRDS(file.path(base, "manifest.rds")); check_hash(m$hashes)
  paths <- names(previous$result_hashes)[grepl("-2-[1248][.]rds$", names(previous$result_hashes))]
  stopifnot(length(paths) == 16L)
  pdf <- list.files("/Users/tohokusla/Zotero/storage/NCPNCNAA", "[.]pdf$", full.names = TRUE)
  stopifnot(length(pdf) == 1L)
  dir.create(out, recursive = TRUE)
  stopifnot(file.copy(script, file.path(out, "source.R")))
  manifest <- list(inputs = tools::md5sum(c(paths, file.path(base,
    c("manifest.rds", "stage-reconciliation.rds")), pdf)),
    source = tools::md5sum(c(script, file.path(out, "source.R"))),
    R = R.version, order = 2L, r = 3L, N_reference = m$N,
    protocol = list(
      question = "Does the order-2 split combination reduce finite-exposure population-root displacement?",
      family = "All four retained two-level owner/design settings and full L=2,4,8; halves L/2",
      target = "Five native free coordinates, including log slopes; structural truth unchanged",
      candidate = "(8*full - (half1+half2)/2)/7; r=3 fixed by the existing growth argument, not selected from results",
      comparator = "Unchanged full root; ordinary 2*full-half is an algebraic misapplication control only",
      uncertainty = "Marginal asymptotic SEs only; Cauchy bounds do not substitute for aligned joint influences",
      exit = "Report every coordinate and split. No coverage claim, new fits, automatic adoption or larger allocation"))
  save_new(manifest, file.path(out, "manifest.rds"))
  cat("Frozen 12 paired exposure/design comparisons; no results calculated.\n")
  quit(save = "no")
}
m <- readRDS(file.path(out, "manifest.rds"))
check_hash(m$inputs); check_hash(m$source)
stopifnot(identical(m$R, R.version), m$order == 2L, m$r == 3L)
old <- readRDS(file.path(base, "stage-reconciliation.rds"))
check_hash(old$result_hashes); check_hash(old$source_hash)
original <- readRDS(file.path(base, "manifest.rds")); check_hash(original$hashes)

# Exact polynomial control: remove L^-3, retain -8/7 times the L^-4 term.
L <- c(2, 4, 8); truth <- .3; c3 <- .7; c4 <- -.2
root <- function(l) truth + c3/l^3 + c4/l^4
control_error <- max(abs((8*root(L)-root(L/2))/7 - (truth-8*c4/(7*L^4))))
stopifnot(control_error < 1e-14)
rows <- list()
for (owner in c("Criterion", "Rater")) for (design in c("sparse", "unequal")) {
  read_root <- function(l) {
    z <- readRDS(file.path(base, sprintf("%s-%s-2-%d.rds", owner, design, l)))
    stopifnot(z$status$Reviewed, z$status$Owner == owner,
      z$status$Design == design, z$status$Order == m$order, z$status$L == l,
      identical(z$hashes, original$hashes),
      isTRUE(all.equal(unname(z$root), z$rows$Root, tolerance = 0)),
      isTRUE(all.equal(z$rows$SE, sqrt(diag(z$vcov)), tolerance = 1e-12)))
    # The original L=1 pilot predates staged execution; its result hash above
    # and original source bindings still apply without a stage.R hash.
    if (!is.null(z$stage_hash)) check_hash(z$stage_hash)
    z
  }
  for (l in L) {
    full <- read_root(l); half <- read_root(l/2)
    stopifnot(identical(full$rows$Parameter, half$rows$Parameter),
      identical(full$rows$Truth, half$rows$Truth))
    reference <- full$rows$Truth
    sp <- (8*full$root-half$root)/7
    bias <- full$root-reference; split_bias <- sp-reference
    sf <- sqrt(diag(full$vcov)); sh <- sqrt(diag(half$vcov))
    rows[[length(rows)+1L]] <- data.frame(Owner = owner, Design = design,
      Order = m$order, L = l, Parameter = full$rows$Parameter, Truth = reference,
      FullRoot = full$root, SplitRoot = sp, FullBias = bias, SplitBias = split_bias,
      AbsoluteBiasChange = abs(split_bias)-abs(bias),
      NaiveSplitBias = 2*full$root-half$root-reference,
      FullReferenceSE = sf, HalfReferenceSE = sh,
      SplitSELowerBound = pmax(0, 8*sf-sh)/7,
      SplitSEUpperBound = (8*sf+sh)/7,
      FullBiasOverFullSE = bias/sf, SplitBiasOverFullSE = split_bias/sf,
      RootSpread = pmax(full$status$Spread, half$status$Spread))
  }
}
rows <- do.call(rbind, rows); rownames(rows) <- NULL
summary <- do.call(rbind, lapply(split(rows, interaction(rows$Owner, rows$Design, rows$L)), function(z)
  data.frame(Owner = z$Owner[1], Design = z$Design[1], L = z$L[1],
    ImprovedCoordinates = sum(z$AbsoluteBiasChange < 0),
    MaxFullAbsoluteBias = max(abs(z$FullBias)),
    MaxSplitAbsoluteBias = max(abs(z$SplitBias)),
    MaxFullBiasOverFullSE = max(abs(z$FullBiasOverFullSE)),
    MaxSplitBiasOverFullSE = max(abs(z$SplitBiasOverFullSE)))))
rownames(summary) <- NULL
result <- list(manifest = tools::md5sum(file.path(out, "manifest.rds")),
  rows = rows, summary = summary, algebra_error = control_error,
  interpretation = "Population-root displacement only; not finite-N estimator bias or interval coverage. Reference SEs use N=400; no joint split covariance has been computed.")
if (action == "review") save_new(result, file.path(out, "review.rds")) else
  stopifnot(identical(result, readRDS(file.path(out, "review.rds"))))
stopifnot(!exists(".Random.seed", .GlobalEnv), !"mfrmr" %in% loadedNamespaces())
print(summary, row.names = FALSE)
cat("Saved-only", action, "complete;", nrow(rows), "coordinate comparisons.\n")
