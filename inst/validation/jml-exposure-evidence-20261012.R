# Saved-only paired exposure review. No package loading, fitting or simulation.
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) == 1L, args %in% c("review", "replay"))
root <- "validation-results/mfrm-wide-map-pcm-r50-portable-20261003"
out <- "validation-results/jml-exposure-evidence-20261012"
script <- "inst/validation/jml-exposure-evidence-20261012.R"
inputs <- character()
remember <- function(h) {
  stopifnot(length(h) > 0L, !anyNA(h))
  old <- intersect(names(inputs), names(h))
  stopifnot(identical(unname(inputs[old]), unname(h[old])))
  inputs <<- c(inputs, h[!names(h) %in% names(inputs)])
}
verify <- function(h) {
  fresh <- h[!names(h) %in% names(inputs)]
  if (length(fresh)) stopifnot(identical(tools::md5sum(names(fresh)), fresh))
  remember(h)
}
read_bound <- function(path) {
  remember(tools::md5sum(path))
  x <- readRDS(path)
  # The existing phase checksum is MD5 of version-3 serialization.
  tmp <- tempfile(); on.exit(unlink(tmp))
  writeBin(serialize(x$payload, NULL, version = 3), tmp)
  stopifnot(identical(unname(tools::md5sum(tmp)), x$checksum))
  x
}
mcse <- function(x) if (length(x) > 1L) sd(x) / sqrt(length(x)) else NA_real_
exact_ci <- function(k, n) if (n) unname(binom.test(k, n)$conf.int) else c(NA_real_, NA_real_)
close <- function(x, y) stopifnot(isTRUE(all.equal(unname(x), unname(y), tolerance = 1e-11)))
manifest <- read_bound(file.path(root, "manifest.rds"))$payload
verify(manifest$input)
registry <- read.csv(names(manifest$input))
rows <- list(); reconciled <- list(); pairing <- list()
for (n in c(20L, 60L)) {
  ids <- sprintf("AB:paired-L%d:N%d:SD1:S-PCM", 1:2, n)
  a <- registry[registry$ConditionId == ids[1], ]; b <- registry[registry$ConditionId == ids[2], ]
  a <- a[order(a$Replicate), ]; b <- b[order(b$Replicate), ]
  stopifnot(identical(a$Replicate, 1:50), identical(b$Replicate, 1:50),
    identical(a$ParentId, b$ParentId), identical(a$Bundle, b$Bundle),
    identical(a$BundleMD5, b$BundleMD5), all(a$ObservedRows == 6L * n),
    all(b$ObservedRows == 12L * n))
  verify(setNames(a$BundleMD5, file.path(manifest$root, a$Bundle)))
  for (f in file.path(manifest$root, a$Bundle)) {
    z <- readRDS(f); x <- z$views[["paired-L1"]]; y <- z$views[["paired-L2"]]
    stopifnot(all(z$truth$log_slopes == 0), !anyDuplicated(y[c("Person", "Rater", "Criterion", "Event")]))
    first <- y[y$Event == 1L, ]; rownames(first) <- rownames(x) <- NULL
    stopifnot(identical(x, first))
  }
  pairing[[as.character(n)]] <- a[c("Replicate", "ParentId", "Bundle", "BundleMD5")]
  for (l in 1:2) {
    d <- if (l == 1L) file.path(root, paste0("summary-n", n)) else
      file.path(root, "transition-reuse-l2-20261007", paste0("summary-n", n))
    base <- read_bound(file.path(d, "summary.rds"))
    verify(base$binding$outputs); verify(base$binding$numerical_manifest)
    stopifnot(nrow(base$payload$jobs) == 400L, all(table(base$payload$jobs$Arm) == 50L))
    saved <- read_bound(file.path(d, "jml-inference/summary.rds"))
    verify(saved$binding$jobs)
    stopifnot(length(saved$binding$jobs) == 200L, saved$payload$independent_datasets == 50L)
    all <- lapply(names(saved$binding$jobs), function(path) {
      z <- read_bound(path)
      verify(z$binding$inputs); verify(z$binding$numerical_manifest)
      do.call(rbind, lapply(z$payload$candidates, `[[`, "rows"))
    })
    z <- do.call(rbind, all)
    stopifnot(all(z$ConditionId == ids[l]), !any(z$FormalStructuralInference))
    # Reconstruct every target/normalization summary from per-dataset records.
    tab <- saved$payload$tables$summary
    for (i in seq_len(nrow(tab))) {
      t <- tab[i, ]; v <- z[z$Arm == t$Arm & z$Target == t$Target &
        z$Output == t$Output & z$CovarianceNormalization == t$CovarianceNormalization, ]
      stopifnot(nrow(v) == 50L, setequal(v$Replicate, 1:50), !anyDuplicated(v$Replicate),
        t$Planned == 50L, sum(v$Available) == t$Available)
      ok <- v$Available; error <- v$Estimate[ok] - v$ReferenceValue[ok]
      close(mean(error), t$MeanError); close(sqrt(mean(error^2)), t$RMSE)
      close(mcse(error), t$ErrorMCSE)
      if (t$Output == "interval") {
        covered <- ok & v$Lower <= v$ReferenceValue & v$Upper >= v$ReferenceValue
        stopifnot(sum(covered) == t$Covered)
        close(mean(v$Upper[ok] - v$Lower[ok]), t$MeanWidth)
        ci <- exact_ci(sum(covered), sum(ok))
        delivery <- exact_ci(sum(covered), 50L)
        t$ConditionalLow <- ci[1]; t$ConditionalHigh <- ci[2]
        t$DeliveryLow <- delivery[1]; t$DeliveryHigh <- delivery[2]
        t$EmpiricalSD <- sd(v$Estimate[ok])
        t$RootMeanVariance <- sqrt(mean(v$SE[ok]^2))
        t$SEToSD <- t$RootMeanVariance / t$EmpiricalSD
        reconciled[[length(reconciled) + 1L]] <- t
      }
    }
    z$N <- n; z$L <- l
    rows[[length(rows) + 1L]] <- z
  }
}
rows <- do.call(rbind, rows); intervals <- do.call(rbind, reconciled)
# All fifty parents contribute to availability and returned-and-covered
# differences. Error differences explicitly condition on joint point returns.
paired <- list()
keys <- unique(rows[c("N", "Arm", "Target", "Output", "CovarianceNormalization")])
for (i in seq_len(nrow(keys))) {
  k <- keys[i, ]; z <- rows[rows$N == k$N & rows$Arm == k$Arm & rows$Target == k$Target &
    rows$Output == k$Output & rows$CovarianceNormalization == k$CovarianceNormalization, ]
  a <- z[z$L == 1, ]; b <- z[z$L == 2, ]; a <- a[order(a$Replicate), ]; b <- b[order(b$Replicate), ]
  stopifnot(identical(a$Replicate, 1:50), identical(a$Replicate, b$Replicate),
    identical(a$ReferenceValue, b$ReferenceValue))
  joint <- a$Available & b$Available
  ea <- a$Estimate[joint] - a$ReferenceValue[joint]; eb <- b$Estimate[joint] - b$ReferenceValue[joint]
  da <- as.integer(b$Available) - as.integer(a$Available)
  ca <- a$Available & a$Lower <= a$ReferenceValue & a$Upper >= a$ReferenceValue
  cb <- b$Available & b$Lower <= b$ReferenceValue & b$Upper >= b$ReferenceValue
  dc <- as.integer(cb) - as.integer(ca)
  paired[[i]] <- cbind(k, data.frame(Planned = 50L, Joint = sum(joint),
    AvailabilityDifference = mean(da), AvailabilityMCSE = mcse(da),
    ErrorDifference = mean(eb - ea), ErrorDifferenceMCSE = mcse(eb - ea),
    SquaredErrorDifference = mean(eb^2 - ea^2), SquaredErrorDifferenceMCSE = mcse(eb^2 - ea^2),
    DeliveredCoverageDifference = if (k$Output == "interval") mean(dc) else NA_real_,
    DeliveredCoverageMCSE = if (k$Output == "interval") mcse(dc) else NA_real_))
}
paired <- do.call(rbind, paired)
remember(tools::md5sum(script))
stopifnot(identical(tools::md5sum(names(inputs)), inputs), !exists(".Random.seed", .GlobalEnv),
  !"mfrmr" %in% loadedNamespaces())
result <- list(inputs = inputs, pairing = pairing, intervals = intervals, paired = paired,
  note = "Saved development evidence; joint-return errors, all-parent delivery. No new fits or responses, no formal interval qualification.")
path <- file.path(out, "review.rds")
if (args == "review") {
  stopifnot(!file.exists(path)); dir.create(out, recursive = TRUE, showWarnings = FALSE)
  saveRDS(result, path)
} else stopifnot(identical(result, readRDS(path)))
print(intervals[intervals$CovarianceNormalization == "asymptotic" &
  intervals$Target == "contrast:Criterion:1-2", c("ConditionId", "Arm", "Available", "Covered",
  "MeanError", "RMSE", "SEToSD", "ConditionalLow", "ConditionalHigh")], row.names = FALSE)
print(paired[paired$CovarianceNormalization == "asymptotic" &
  paired$Target == "contrast:Criterion:1-2", ], row.names = FALSE)
cat("Verified input files:", length(inputs), "; saved-only", args, "passed.\n")
