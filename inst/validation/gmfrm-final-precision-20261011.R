# Saved-arithmetic diagnosis, not a new fit or an acceptance rule.
# Run from the package root with Rscript --vanilla. A second run verifies
# the saved result without optimization, integration or package loading.
precision_main <- function() {
  script <- "inst/validation/gmfrm-final-precision-20261011.R"
  bounded <- "validation-results/gmfrm-bounded-search-20261011"
  followup <- "validation-results/gmfrm-segmented-followup-20261011"
  original <- "validation-results/gmfrm-segmented-estimation-20261011"
  check_hash <- function(x) stopifnot(identical(tools::md5sum(names(x)), x))
  archive_check <- function(directory, sources) {
    files <- file.path(directory, "epoch-source", names(sources))
    hashes <- unname(tools::md5sum(files))
    # The original epoch archived only changed files. Its unchanged files
    # also occur in the full followup archive; require exact recorded hashes.
    missing <- is.na(hashes)
    if (any(missing) && identical(directory, original))
      hashes[missing] <- unname(tools::md5sum(file.path(followup,
        "epoch-source", names(sources)[missing])))
    stopifnot(identical(hashes, unname(sources)))
  }
  paths <- file.path(c(bounded, followup, original), "manifest.rds")
  manifests <- lapply(paths, readRDS)
  names(manifests) <- c("bounded", "followup", "original")
  summaries <- lapply(file.path(c(bounded, followup, original), "summary.rds"), readRDS)
  for (i in seq_along(manifests)) {
    seal <- if (i == 3L) manifests$followup$inputs[paths[i]] else summaries[[i]]$manifest
    stopifnot(identical(seal, tools::md5sum(paths[i])))
    check_hash(summaries[[i]]$results)
    archive_check(dirname(paths[i]), manifests[[i]]$sources)
  }
  check_hash(manifests$followup$inputs[file.path(original, "summary.rds")])
  check_hash(manifests$bounded$inputs)
  check_hash(manifests$bounded$sources)
  consumed <- character()
  read_point <- function(directory, prefix, key, epoch) {
    path <- file.path(directory, paste0(prefix, "-", key, ".rds"))
    x <- readRDS(path)
    stopifnot(identical(x$manifest, tools::md5sum(file.path(directory, "manifest.rds"))),
      identical(tools::md5sum(path), summaries[[epoch]]$results[path]),
      !nzchar(x$error))
    consumed <<- unique(c(consumed, path)); x
  }
  # z = (b, q, log(a), c); p = (b, s, tau, log(a), log(c)).
  # Gradients transform exactly by dz/dp. No Hessian is transported between
  # these nonlinear charts, and the fixed Task-t1 derivative is never freed.
  native <- function(point) {
    z <- point$parameters; gz <- point$evaluation$gradient
    stopifnot(length(z) == 22L, all(is.finite(c(z, gz))), all(z[17:22] > 0))
    c <- z[17:22]; q <- matrix(z[3:14], 6, 2, byrow = TRUE)
    s <- rowMeans(q)/c; tau <- (q[, 1] - q[, 2])/(2*c)
    D <- matrix(0, 22, 22)
    D[cbind(c(1:2, 15:16), c(1:2, 15:16))] <- 1
    for (r in 1:6) {
      rows <- 2 + 2*r - c(1, 0)
      D[rows, 2+r] <- c[r]; D[rows, 8+r] <- c[r]*c(1, -1)
      D[rows, 16+r] <- q[r, ]; D[16+r, 16+r] <- c[r]
    }
    gp <- drop(crossprod(D, gz))
    # Separate component equations check the matrix pullback and inverse.
    gq <- matrix(gz[3:14], 6, 2, byrow = TRUE)
    explicit <- c(gz[1:2], c*rowSums(gq), c*(gq[, 1]-gq[, 2]),
      gz[15:16], rowSums(q*gq)+c*gz[17:22])
    stopifnot(max(abs(gp-explicit)) < 1e-12,
      max(abs(drop(solve(t(D), gp))-gz)) < 1e-12)
    e <- Reduce(`+`, point$evaluation$score_error)
    list(parameters = c(z[1:2], s, tau, z[15:16], log(c)), gradient = gp,
      error = drop(crossprod(abs(D), e)))
  }
  free <- setdiff(1:22, 15L)
  keys <- c("N20-observed-null-neutral", "N240-observed-null-retained",
    "N240-observed-null-neutral")
  rows <- historical <- list()
  for (key in keys) {
    old <- read_point(original, "fit", key, 3L)$value
    record <- read_point(followup, "curvature", key, 2L)
    a <- record$value; H <- a$hessian[[2]]$symmetric
    V <- chol2inv(chol(H)); g0 <- old$terminal$gradient[free]
    step0 <- drop(V %*% g0)
    stopifnot(max(abs(old$parameters[free]-step0-a$parameters[free])) < 1e-12,
      abs(sum(g0*step0)/2-a$curvature["PredictedDecrease"]) < 1e-12,
      abs(old$terminal$value-a$terminal$value-a$curvature["ActualDecrease"]) < 1e-10)
    historical[[key]] <- data.frame(Key=key, Free=length(free),
      ScoreEvaluations=record$evaluations$Evaluations, Seconds=record$seconds,
      StandardizedBefore=sqrt(sum(g0*step0)),
      PredictedDecrease=sum(g0*step0)/2,
      ActualDecrease=unname(a$curvature["ActualDecrease"]),
      FinalRawScore=unname(a$curvature["NewScore"]))
    for (start in c("retained", "neutral")) {
      k <- sub("(retained|neutral)$", start, key)
      fit <- read_point(bounded, "fit", k, 1L)$value
      point <- fit$selected; x <- native(point); g <- x$gradient[free]
      stopifnot(identical(x$parameters[15], old$parameters[15]),
        identical(x$parameters[15], a$parameters[15]))
      step <- drop(V %*% g); decrement <- sum(g*step)
      # An invertible affine basis change leaves this quadratic diagnostic
      # unchanged. This is not invariance under a nonlinear chart change.
      A <- diag(exp(seq(-2, 2, length.out=length(free))))
      A[1:2, 1:2] <- matrix(c(2, .5, 1, 1), 2)
      ga <- drop(crossprod(A, g)); Ha <- crossprod(A, H %*% A)
      stopifnot(abs(drop(crossprod(ga, solve(Ha, ga)))-decrement) < 1e-12,
        max(abs(step)/sqrt(diag(V))) <= sqrt(decrement)*(1+1e-10))
      e <- x$error[free]
      rows[[paste(key, start)]] <- data.frame(Key=k, CurvatureKey=key,
        RawNativeScore=max(abs(g)), RawNaturalScore=unname(fit$checks["ProjectedScore"]),
        Standardized=sqrt(decrement), PredictedDecrease=decrement/2,
        ActualNLLGap=point$evaluation$value-a$terminal$value,
        MaxParameterStep=max(abs(step)), MaxSEStep=max(abs(step)/sqrt(diag(V))),
        DistanceToHessianPoint=max(abs(x$parameters[free]-old$parameters[free])),
        DistanceToRefinedPoint=max(abs(x$parameters[free]-a$parameters[free])),
        PredictedDistanceToRefinedPoint=max(abs(x$parameters[free]-step-a$parameters[free])),
        IntegrationDiagnostic=sqrt(drop(crossprod(e, abs(V) %*% e))),
        HistoricalCandidate=isTRUE(fit$candidate))
    }
  }
  # Preserve all N20/N60/N240 observed-data comparisons even though saved
  # compatible nuisance Hessians exist only for these N20/N240 null points.
  observed <- summaries[[1]]$attempts
  observed <- observed[observed$Case %in% c("N20-observed", "N60-observed", "N240-observed"), ]
  reference <- manifests$bounded$interior
  at <- match(paste(observed$Case, observed$Kind), paste(reference$Case, reference$Kind))
  stopifnot(nrow(observed) == 12L, !anyNA(at), all(is.finite(observed$ReferenceNLL)))
  likelihood <- observed[c("Key", "Case", "Kind", "Start", "NLL", "Code", "ProjectedScore")]
  likelihood$PreviousQualifiedNLL <- reference$InteriorNLL[at]
  likelihood$NLLGap <- likelihood$NLL-likelihood$PreviousQualifiedNLL
  inputs <- unique(c(paths, file.path(c(bounded, followup, original), "summary.rds"), consumed))
  answer <- list(inputs=tools::md5sum(inputs), source=tools::md5sum(script),
    diagnosis=do.call(rbind, rows), historical=do.call(rbind, historical),
    likelihood=likelihood,
    scope="Local predictions using earlier native nuisance Hessians; no current-point curvature, refitting, acceptance change, global or coverage claim.")
  path <- file.path(bounded, "precision-diagnosis.rds")
  if (file.exists(path)) {
    saved <- readRDS(path); check_hash(saved$inputs); check_hash(saved$source)
    stopifnot(identical(saved, answer))
    cat("Saved arithmetic replay and source/input/archive bindings passed.\n")
  } else saveRDS(answer, path)
  print(answer$diagnosis[c("Key", "CurvatureKey", "Standardized", "MaxSEStep",
    "PredictedDecrease", "ActualNLLGap")], row.names=FALSE)
  print(answer$historical, row.names=FALSE)
  invisible(answer)
}
if (sys.nframe() == 0L) {
  for (name in c("optim", "optimHess", "nlminb", "integrate", "uniroot", "rnorm", "runif"))
    invisible(capture.output(trace(name, tracer=quote(stop("Numerical work disabled in saved diagnosis.")),
      print=FALSE, where=asNamespace("stats"))))
  stopifnot(!"mfrmr" %in% loadedNamespaces(), !"pkgload" %in% loadedNamespaces())
  precision_main()
}
