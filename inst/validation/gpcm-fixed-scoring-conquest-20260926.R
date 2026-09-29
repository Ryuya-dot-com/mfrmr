# Local, repository-only fixed-calibration comparison. No free calibration fit.
prepare_gpcm_fixed_scoring_conquest <- function(output_dir,
    source_path = "validation-results/gpcm-fixed-scoring-tam-20260926/results.rds") {
  source_path <- normalizePath(source_path)
  fixed <- readRDS(source_path)
  stopifnot(all(vapply(fixed, function(x) isTRUE(x$passed), logical(1))))
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  settings <- expand.grid(Nodes = c(20000L, 200000L), Seed = c(2L, 73L, 20260926L))
  for (owner in names(fixed)) {
    x <- fixed[[owner]]; ni <- ncol(x$response); nk <- ncol(x$AXsi)
    directory <- file.path(output_dir, owner)
    dir.create(directory, showWarnings = FALSE)
    stopifnot(nk >= 3L)
    # Some target contexts have unobserved middle categories. ConQuest removes
    # those category parameters before applying anchors. A declared support row
    # supplies each middle category; it is not a target score and cannot change the
    # fully fixed calibration or prior.
    support <- matrix(rep(seq_len(nk - 2L), each = ni), ncol = ni, byrow = TRUE)
    rownames(support) <- if (nk == 3L) "category_support" else
      paste0("support_", seq_len(nk - 2L))
    response <- rbind(x$response, support)
    write.csv(data.frame(Person = rownames(response), response),
      file.path(directory, "responses.csv"), row.names = FALSE, na = ".")
    a <- matrix(0, ni * nk, ni * (nk - 1L)); pos <- 0L
    for (j in seq_len(ni)) for (k in 2:nk) {
      pos <- pos + 1L; a[(j - 1L) * nk + k, pos] <- -1
    }
    write.table(a, file.path(directory, "design.csv"), row.names = FALSE,
      col.names = FALSE, quote = FALSE, sep = ",")
    # Official manual Figure 2.74: parameter count, then matrix rows.
    writeLines(c(as.character(ncol(a)), apply(a, 1L, paste, collapse = " ")),
      file.path(directory, "design.txt"))
    values <- -as.vector(t(x$AXsi[, -1L, drop = FALSE]))
    writeLines(sprintf("%d %.17g", seq_along(values), values),
      file.path(directory, "anchors.txt"))
    writeLines("1 1 0", file.path(directory, "mean.txt"))
    writeLines("1 1 1", file.path(directory, "variance.txt"))
    commands <- c(
      "title Fixed GPCM scoring comparison;",
      sprintf(paste0("datafile responses.csv ! filetype=csv, header=yes, ",
        "columnlabels=no, pid=Person, pidwidth=16, responses=context1 to context%d;"), ni),
      paste0("codes ", paste(0:(nk - 1L), collapse = ","), ";"),
      "set lconstraints=cases;", "model item + item*step;",
      vapply(seq_len(ni), function(j) sprintf("score (%s) (%s) ! item(%d);",
        paste(0:(nk - 1L), collapse = ","),
        paste(sprintf("%.17g", x$B[j, , 1L]), collapse = ","), j), character(1)),
      "import designmatrix << design.txt;",
      "import anchor_parameters << anchors.txt;",
      "import anchor_reg_coefficients << mean.txt;",
      "import anchor_covariance << variance.txt;",
      "estimate ! method=quadrature, nodes=61, fit=no, stderr=none, iterations=5;",
      "export parameters ! filetype=csv >> parameters.csv;",
      "export amatrix ! filetype=csv >> amatrix.csv;",
      "export itemscores ! filetype=csv >> itemscores.csv;",
      "export reg_coefficients ! filetype=csv >> mean.csv;",
      "export covariance ! filetype=csv >> variance.csv;")
    writeLines(c(commands, "put >> fixed.sys;", "quit;"),
      file.path(directory, "calibration.cqc"))
    commands <- "get << fixed.sys;"
    for (i in seq_len(nrow(settings))) commands <- c(commands,
      sprintf("set p_nodes=%d;", settings$Nodes[i]),
      sprintf("set seed=%d;", settings$Seed[i]),
      sprintf("show cases ! estimates=eap, filetype=csv >> scores_n%d_s%d.csv;",
        settings$Nodes[i], settings$Seed[i]))
    commands <- c(commands,
      "export amatrix ! filetype=csv >> amatrix_after.csv;",
      "export parameters ! filetype=csv >> parameters_after.csv;",
      "export itemscores ! filetype=csv >> itemscores_after.csv;",
      "export reg_coefficients ! filetype=csv >> mean_after.csv;",
      "export covariance ! filetype=csv >> variance_after.csv;", "quit;")
    writeLines(commands, file.path(directory, "scoring.cqc"))
  }
  manifest <- list(settings = settings, source_path = source_path, owners = names(fixed),
    fixture_md5 = tools::md5sum(source_path),
    executable = "/Applications/ConQuest/ConQuest",
    executable_sha256 = unname(digest::digest(file = "/Applications/ConQuest/ConQuest", algo = "sha256")),
    comparison = "Fixed-model identity and descriptive stochastic EAP/SD comparison; no deterministic EAP tolerance",
    script_md5 = tools::md5sum("inst/validation/gpcm-fixed-scoring-conquest-20260926.R"))
  saveRDS(manifest, file.path(output_dir, "manifest.rds"))
  invisible(output_dir)
}

run_gpcm_fixed_scoring_conquest <- function(output_dir) {
  output_dir <- normalizePath(output_dir)
  manifest <- readRDS(file.path(output_dir, "manifest.rds"))
  stopifnot(identical(manifest$executable_sha256,
    unname(digest::digest(file = manifest$executable, algo = "sha256"))))
  original <- getwd(); on.exit(setwd(original), add = TRUE)
  for (owner in if (is.null(manifest$owners)) c("shared", "separate") else manifest$owners) {
    setwd(file.path(output_dir, owner))
    stopifnot(!file.exists("calibration-console.txt"), !file.exists("console.txt"))
    exit <- system2("/usr/bin/arch", c("-x86_64", shQuote(manifest$executable)),
      input = readLines("calibration.cqc"), stdout = "calibration-console.txt",
      stderr = "calibration-stderr.txt", timeout = 60L)
    stopifnot(exit == 0L)
    # Stop before stochastic scoring if ConQuest silently retained another A.
    expected_a <- as.matrix(read.csv("design.csv", header = FALSE))
    returned_a <- as.matrix(read.csv("amatrix.csv", check.names = FALSE)[, -(1:2)])
    anchors <- read.table("anchors.txt")
    parameters <- read.csv("parameters.csv")
    stopifnot(identical(dim(expected_a), dim(returned_a)),
      max(abs(expected_a - returned_a)) == 0,
      identical(as.integer(parameters$P), as.integer(anchors[[1L]])),
      max(abs(parameters$Estimate - anchors[[2L]])) < 1e-6,
      read.csv("mean.csv")$Estimate == 0,
      read.csv("variance.csv")$Covariance == 1)
    command <- readLines("calibration.cqc")
    score <- command[startsWith(command, "score (")]
    expected_b <- do.call(rbind, lapply(strsplit(
      sub("^score \\([^)]*\\) \\(([^)]*)\\).*", "\\1", score), ",", fixed = TRUE), as.numeric))
    returned_b <- read.csv("itemscores.csv")
    stopifnot(identical(returned_b$GIN, rep(seq_len(nrow(expected_b)), each = ncol(expected_b) - 1L)),
      identical(returned_b$Category, rep(seq_len(ncol(expected_b) - 1L), nrow(expected_b))),
      all(returned_b$Dimension == 1),
      max(abs(returned_b$Score - as.vector(t(expected_b[, -1L, drop = FALSE])))) < 1e-6)
    exit <- system2("/usr/bin/arch", c("-x86_64", shQuote(manifest$executable)),
      input = readLines("scoring.cqc"), stdout = "console.txt", stderr = "stderr.txt",
      timeout = 180L)
    console <- readLines("console.txt", warn = FALSE)
    saveRDS(list(exit = exit, end_of_program = any(grepl("End of Program", console)),
      stderr = readLines("stderr.txt", warn = FALSE)), "execution-status.rds")
    stopifnot(exit == 0L, any(grepl("End of Program", console)))
    expected <- c("parameters.csv", "amatrix.csv", "itemscores.csv", "mean.csv", "variance.csv",
      sprintf("scores_n%d_s%d.csv", manifest$settings$Nodes, manifest$settings$Seed))
    stopifnot(all(file.exists(expected)))
    message(owner, ": native process completed; inspect exports before accepting results")
  }
  invisible(output_dir)
}

# Validate written numeric inputs without claiming that ConQuest read them.
check_gpcm_conquest_input_map <- function(output_dir) {
  manifest <- readRDS(file.path(output_dir, "manifest.rds"))
  fixed <- readRDS(if (is.null(manifest$source_path))
    "validation-results/gpcm-fixed-scoring-tam-20260926/results.rds" else manifest$source_path)
  summary <- lapply(names(fixed), function(owner) {
    x <- fixed[[owner]]; directory <- file.path(output_dir, owner)
    a <- as.matrix(read.csv(file.path(directory, "design.csv"), header = FALSE))
    anchors <- read.table(file.path(directory, "anchors.txt"))
    ni <- nrow(x$AXsi); nk <- ncol(x$AXsi)
    stopifnot(identical(as.integer(anchors[[1L]]), seq_len(ncol(a))),
      nrow(a) == ni * nk, qr(a)$rank == ncol(a))
    command <- readLines(file.path(directory, "calibration.cqc"))
    stopifnot(as.integer(readLines(file.path(directory, "design.txt"), n = 1L)) == ncol(a),
      identical(as.matrix(read.table(file.path(directory, "design.txt"), skip = 1L)), a),
      "import designmatrix << design.txt;" %in% command)
    score <- command[startsWith(command, "score (")]
    score_values <- sub("^score \\([^)]*\\) \\(([^)]*)\\).*", "\\1", score)
    b <- do.call(rbind, lapply(strsplit(score_values, ",", fixed = TRUE), as.numeric))
    stopifnot(identical(dim(b), c(ni, nk)),
      identical(sub(".*item\\(([0-9]+)\\);$", "\\1", score), as.character(seq_len(ni))),
      identical(as.numeric(read.table(file.path(directory, "mean.txt"))), c(1, 1, 0)),
      identical(as.numeric(read.table(file.path(directory, "variance.txt"))), c(1, 1, 1)))
    # Reconstruct only from serialized A, anchors and category scores.
    intercept <- matrix(drop(a %*% anchors[[2L]]), ni, nk, byrow = TRUE)
    z <- as.vector(x$tam[[2L]]$theta)
    probabilities <- array(NA_real_, dim(x$tam[[2L]]$rprobs))
    for (j in seq_len(ni)) for (h in seq_along(z)) {
      eta <- intercept[j, ] + b[j, ] * z[h]
      p <- exp(eta - max(eta)); probabilities[j, , h] <- p / sum(p)
    }
    difference <- max(abs(probabilities - x$tam[[2L]]$rprobs))
    stopifnot(difference < 1e-11)
    data.frame(Owner = owner, InputProbabilityDifference = difference,
      InputMapVerified = TRUE, NativeResultVerified = FALSE)
  })
  summary <- do.call(rbind, summary)
  write.csv(summary, file.path(output_dir, "input-map-check.csv"), row.names = FALSE)
  print(summary)
  invisible(summary)
}

summarize_gpcm_fixed_scoring_conquest <- function(output_dir) {
  manifest <- readRDS(file.path(output_dir, "manifest.rds"))
  fixed <- readRDS(if (is.null(manifest$source_path))
    "validation-results/gpcm-fixed-scoring-tam-20260926/results.rds" else manifest$source_path)
  rows <- identity_rows <- list()
  for (owner in names(fixed)) {
    x <- fixed[[owner]]; d <- file.path(output_dir, owner)
    before_parameters <- read.csv(file.path(d, "parameters.csv"))
    after_parameters <- read.csv(file.path(d, "parameters_after.csv"))
    stopifnot(identical(before_parameters[c("P", "Estimate")], after_parameters[c("P", "Estimate")]))
    for (stem in c("itemscores", "mean", "variance")) {
      stopifnot(identical(readLines(file.path(d, paste0(stem, ".csv"))),
        readLines(file.path(d, paste0(stem, "_after.csv")))))
    }
    a <- as.matrix(read.csv(file.path(d, "amatrix.csv"))[, -(1:2)])
    after_a <- as.matrix(read.csv(file.path(d, "amatrix_after.csv"))[, -(1:2)])
    expected_a <- as.matrix(read.csv(file.path(d, "design.csv"), header = FALSE))
    anchors <- read.table(file.path(d, "anchors.txt"))
    parameters <- read.csv(file.path(d, "parameters.csv"))
    scores <- read.csv(file.path(d, "itemscores.csv"))
    ni <- nrow(x$AXsi); nk <- ncol(x$AXsi)
    stopifnot(identical(dim(a), dim(expected_a)), max(abs(a - expected_a)) == 0,
      identical(dim(a), dim(after_a)), max(abs(a - after_a)) == 0,
      identical(as.integer(parameters$P), as.integer(anchors[[1L]])),
      max(abs(parameters$Estimate - anchors[[2L]])) < 1e-6,
      identical(scores$GIN, rep(seq_len(ni), each = nk - 1L)),
      identical(scores$Category, rep(seq_len(nk - 1L), ni)), all(scores$Dimension == 1),
      max(abs(scores$Score - as.vector(t(x$B[, -1L, 1L])))) < 1e-6,
      read.csv(file.path(d, "mean.csv"))$Estimate == 0,
      read.csv(file.path(d, "variance.csv"))$Covariance == 1)
    intercept <- matrix(drop(a %*% parameters$Estimate), ni, nk, byrow = TRUE)
    b <- cbind(0, matrix(scores$Score, ni, nk - 1L, byrow = TRUE))
    z <- as.vector(x$tam[[2L]]$theta)
    pr <- array(NA_real_, dim(x$tam[[2L]]$rprobs))
    for (j in seq_len(ni)) for (h in seq_along(z)) {
      eta <- intercept[j, ] + b[j, ] * z[h]
      p <- exp(eta - max(eta)); pr[j, , h] <- p / sum(p)
    }
    loglik_difference <- max(vapply(seq_len(nrow(x$response)), function(p) {
      observed <- which(!is.na(x$response[p, ]))
      loglik <- function(prob) Reduce(`+`, lapply(observed, function(j)
        log(prob[j, x$response[p, j] + 1L, ])))
      max(abs(loglik(pr) - loglik(x$tam[[2L]]$rprobs)))
    }, numeric(1)))
    # Separate printed-calibration precision from stochastic score differences.
    printed <- t(vapply(seq_len(nrow(x$response)), function(p) {
      observed <- which(!is.na(x$response[p, ]))
      logw <- rowSums(vapply(observed, function(j)
        log(pr[j, x$response[p, j] + 1L, ]), numeric(length(z)))) + dnorm(z, log = TRUE)
      w <- exp(logw - max(logw)); w <- w / sum(w); mean <- sum(w * z)
      c(EAP = x$mean + x$sd * mean, SD = x$sd * sqrt(sum(w * (z - mean)^2)))
    }, numeric(2)))
    identity_rows[[owner]] <- data.frame(Owner = owner, FixedModelVerified = TRUE,
      NativeLabelsChangedOnReload = !identical(before_parameters$Label, after_parameters$Label),
      ProbabilityDifferenceFromPrintedParameters = max(abs(pr - x$tam[[2L]]$rprobs)),
      LogLikelihoodDifferenceFromPrintedParameters = loglik_difference,
      PrintedCalibrationScoreDifference = max(abs(printed - x$native_scores[[2L]])))
    for (i in seq_len(nrow(manifest$settings))) {
      setting <- manifest$settings[i, ]
      file <- sprintf("scores_n%d_s%d.csv", setting$Nodes, setting$Seed)
      s <- read.csv(file.path(d, file)); ids <- trimws(s$PID)
      support_ids <- if (nk == 3L) "category_support" else paste0("support_", seq_len(nk - 2L))
      stopifnot(nrow(s) == nrow(x$response) + length(support_ids),
        !anyDuplicated(ids), all(support_ids %in% ids))
      at <- match(rownames(x$response), ids); stopifnot(!anyNA(at))
      eap <- x$mean + x$sd * s$EAP_1[at]; sd <- x$sd * s$PosteriorSD_1[at]
      stopifnot(all(is.finite(c(eap, sd))), all(sd > 0))
      rows[[paste(owner, i)]] <- data.frame(Owner = owner, Nodes = setting$Nodes,
        Seed = setting$Seed, Person = rownames(x$response), EAP = eap, SD = sd,
        EAPDifference = eap - x$native_scores[[2L]][, 1L],
        SDDifference = sd - x$native_scores[[2L]][, 2L],
        EAPDifferenceFromPrintedCalibration = eap - printed[, 1L],
        SDDifferenceFromPrintedCalibration = sd - printed[, 2L])
    }
  }
  rows <- do.call(rbind, rows); identity <- do.call(rbind, identity_rows)
  summary <- aggregate(abs(rows[c("EAPDifference", "SDDifference")]),
    rows[c("Owner", "Nodes")], max)
  write.csv(rows, file.path(output_dir, "score-comparison.csv"), row.names = FALSE)
  write.csv(identity, file.path(output_dir, "fixed-model-check.csv"), row.names = FALSE)
  write.csv(summary, file.path(output_dir, "summary.csv"), row.names = FALSE)
  print(identity); print(summary)
  invisible(list(identity = identity, scores = rows, summary = summary))
}
