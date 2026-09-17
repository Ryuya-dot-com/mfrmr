# Descriptive native recheck of the existing four-arm microcase. No numerical
# acceptance threshold is inferred from ConQuest's printed precision.
run_conquest_adaptive_recheck <- function(output_dir) {
  source("inst/validation/conquest-additive-mfrm-design-0.2.3.R", local = environment())
  source("inst/validation/conquest-additive-mfrm-reference-preflight-0.2.3.R", local = environment())
  source("inst/validation/adaptive-quadrature-review-0.2.4.R", local = environment())
  executable <- "/Applications/ConQuest/ConQuest"
  stopifnot(mfrmr_cq_additive_hash_file(executable) ==
    "61d0b87f379f1578466b789866366c5cc633d31a6c3501e872861d44ff02da48")
  historical <- normalizePath("validation-results/conquest-additive-native-20260811")
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  output_dir <- normalizePath(output_dir)
  fixture <- mfrmr_cq_additive_fixture()
  original_wd <- getwd()
  on.exit(setwd(original_wd), add = TRUE)
  comparisons <- scores <- reference <- manifests <- list()
  for (model in c("RSM", "PCM")) for (q in c(31L, 61L)) {
    id <- sprintf("%s_q%03d", tolower(model), q)
    message(id)
    directory <- file.path(output_dir, id)
    dir.create(directory, showWarnings = FALSE)
    prefix <- paste0("cq_additive_", id)
    command <- paste0(prefix, ".cqc"); wide <- paste0(prefix, "_wide.csv")
    stopifnot(file.copy(file.path(historical, id, c(command, wide)), directory))
    supplied <- read.csv(file.path(directory, wide)); expected <- fixture$wide
    rownames(supplied) <- rownames(expected) <- NULL
    stopifnot(isTRUE(all.equal(supplied, expected, tolerance = 0)))
    setwd(directory)
    exit <- system2("/usr/bin/arch", c("-x86_64", shQuote(executable)),
      input = readLines(command), stdout = "console.txt", stderr = "stderr.txt", timeout = 600L)
    setwd(original_wd)
    stopifnot(exit == 0L, any(grepl("End of Program", readLines(file.path(directory, "console.txt")))))
    read_native <- function(suffix) read.csv(file.path(directory, paste0(prefix, suffix)))
    native <- read_native("_conquest_parameters.csv")
    beta <- read_native("_conquest_reg_coefficients.csv")$Estimate
    sigma2 <- read_native("_conquest_covariance.csv")$Covariance[1L]
    history <- read_native("_conquest_history.csv")
    deviance <- tail(history$LogLikelihood, 1L)
    cases <- read_native("_conquest_cases_eap.csv")
    index <- match(fixture$persons, trimws(cases$PID))
    stopifnot(!anyNA(index), length(beta) == 2L, is.finite(sigma2), sigma2 > 0)
    amatrix_file <- paste0(prefix, "_conquest_amatrix.csv")
    stopifnot(identical(read.csv(file.path(directory, amatrix_file)),
      read.csv(file.path(historical, id, amatrix_file))))
    manifests[[id]] <- data.frame(Arm = id, ExecutableSHA256 = mfrmr_cq_additive_hash_file(executable),
      CommandSHA256 = mfrmr_cq_additive_hash_file(file.path(directory, command)),
      InputSHA256 = mfrmr_cq_additive_hash_file(file.path(directory, wide)),
      AMatrixMatchesHistorical = TRUE, ExitStatus = exit,
      FinalIteration = tail(history$Iteration, 1L))
    for (integration in c("fixed", "adaptive")) {
      fit <- mfrmr::fit_mfrm(fixture$long, "Person", c("Rater", "Criterion"), "Score",
        rating_min = 0L, rating_max = 3L, model = model,
        step_facet = if (model == "PCM") "Criterion" else NULL,
        population_formula = stats::as.formula("~ X", env = baseenv()),
        person_data = fixture$wide[c("Person", "X")], quad_points = q,
        maxit = 2000L, reltol = 1e-12, mml_integration = integration)
      coordinate <- mfrmr_cq_additive_coordinates(fit, model, fixture)
      free_steps <- if (model == "RSM") coordinate$steps[1L, 1:2] else
        as.numeric(t(coordinate$steps[, 1:2]))
      mfrmr_values <- c(coordinate$rater[1L], coordinate$criterion[1L], free_steps,
        coordinate$beta, coordinate$sigma2, fit$summary$Deviance)
      cq_values <- c(native$Estimate, beta, sigma2, deviance)
      labels <- c(trimws(native$Label), "population intercept", "population X", "population variance", "deviance")
      comparisons[[paste(id, integration)]] <- data.frame(Arm = id, Integration = integration,
        Coordinate = labels, ConQuest = cq_values, mfrmr = as.numeric(mfrmr_values),
        Difference = cq_values - as.numeric(mfrmr_values),
        Gradient = fit$summary$TerminalGradientSupNorm, InferenceReady = fit$summary$InferenceReady,
        FormalEquivalenceEstablished = FALSE)
      person <- fit$facets$person
      matched <- match(fixture$persons, person$Person)
      stopifnot(!anyNA(matched))
      scores[[paste(id, integration)]] <- data.frame(Arm = id, Integration = integration,
        Person = fixture$persons, ConQuestEAP = cases$EAP_1[index], EAP = person$Estimate[matched],
        ConQuestSD = cases$PosteriorSD_1[index], SD = person$SD[matched])
      if (integration == "adaptive") {
        long <- fixture$long
        actual <- t(vapply(fixture$persons, function(person_id) {
          rows <- which(long$Person == person_id)
          x <- long$X[rows[1L]]
          aq_continuous_reference(long$Score[rows],
            -coordinate$rater[long$Rater[rows]] - coordinate$criterion[long$Criterion[rows]],
            coordinate$steps[long$Criterion[rows], , drop = FALSE],
            rep(1, length(rows)), rep(1, length(rows)),
            coordinate$beta["Intercept"] + coordinate$beta["X"] * x, sqrt(coordinate$sigma2))
        }, numeric(5)))
        reference[[id]] <- data.frame(Arm = id, Person = fixture$persons, actual,
          EAPError = actual[, "eap"] - person$Estimate[matched],
          SDError = actual[, "sd"] - person$SD[matched],
          TotalLogLikelihoodError = sum(actual[, "log_marginal"]) - fit$summary$LogLik)
      }
      saveRDS(fit, file.path(directory, paste0(integration, "-mfrmr.rds")))
    }
    for (name in c("comparisons", "scores", "reference", "manifests")) {
      write.csv(do.call(rbind, get(name)), file.path(output_dir, paste0(name, ".csv")), row.names = FALSE)
    }
  }
  stopifnot(length(comparisons) == 8L, length(scores) == 8L, length(reference) == 4L,
    all(vapply(reference, function(x) max(abs(x$TotalLogLikelihoodError)) < 1e-7 &&
      max(abs(x$EAPError)) < 1e-7 && max(abs(x$SDError)) < 1e-7, TRUE)))
  invisible(list(comparisons = comparisons, scores = scores, reference = reference, manifests = manifests))
}

# Post-hoc scoring sensitivity: all declared node budgets and seeds are retained.
followup_conquest_posterior <- function(native_root, output_dir) {
  source("inst/validation/conquest-additive-mfrm-design-0.2.3.R", local = environment())
  source("inst/validation/adaptive-quadrature-review-0.2.4.R", local = environment())
  executable <- "/Applications/ConQuest/ConQuest"
  stopifnot(mfrmr_cq_additive_hash_file(executable) ==
    "61d0b87f379f1578466b789866366c5cc633d31a6c3501e872861d44ff02da48")
  native_root <- normalizePath(native_root)
  dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)
  output_dir <- normalizePath(output_dir)
  fixture <- mfrmr_cq_additive_fixture()
  original_wd <- getwd(); on.exit(setwd(original_wd), add = TRUE)
  results <- scores <- list()
  settings <- expand.grid(Nodes = c(2000L, 20000L, 200000L), Seed = c(2L, 73L, 20260914L))
  for (model in c("RSM", "PCM")) {
    arm <- paste0(tolower(model), "_q061"); prefix <- paste0("cq_additive_", arm)
    directory <- file.path(output_dir, arm); dir.create(directory, showWarnings = FALSE)
    old <- file.path(native_root, arm)
    stopifnot(file.copy(file.path(old, paste0(prefix, "_wide.csv")), directory))
    original <- readLines(file.path(old, paste0(prefix, ".cqc")))
    commands <- original[seq_len(which(grepl("^show cases", original))[1L] - 1L)]
    files <- sprintf("posterior_n%d_seed%d.csv", settings$Nodes, settings$Seed)
    for (i in seq_len(nrow(settings))) commands <- c(commands,
      sprintf("set p_nodes=%d;", settings$Nodes[i]), sprintf("set seed=%d;", settings$Seed[i]),
      sprintf("show cases ! estimates=eap, filetype=csv, regressors=yes >> %s;", files[i]))
    commands <- c(commands, original[grepl("^write mfrmrCQ_history", original)], "quit;")
    writeLines(commands, file.path(directory, "posterior-settings.cqc"))
    setwd(directory)
    exit <- system2("/usr/bin/arch", c("-x86_64", shQuote(executable)), input = commands,
      stdout = "console.txt", stderr = "stderr.txt", timeout = 600L)
    setwd(original_wd)
    stopifnot(exit == 0L, any(grepl("End of Program", readLines(file.path(directory, "console.txt")))))
    for (suffix in c("parameters", "reg_coefficients", "covariance", "history")) {
      file <- paste0(prefix, "_conquest_", suffix, ".csv")
      stopifnot(identical(readLines(file.path(old, file)), readLines(file.path(directory, file))))
    }
    v <- read.csv(file.path(directory, paste0(prefix, "_conquest_parameters.csv")))$Estimate
    beta <- read.csv(file.path(directory, paste0(prefix, "_conquest_reg_coefficients.csv")))$Estimate
    sigma2 <- read.csv(file.path(directory, paste0(prefix, "_conquest_covariance.csv")))$Covariance[1L]
    rater <- c(R1 = v[1L], R2 = -v[1L]); criterion <- c(C1 = v[2L], C2 = -v[2L])
    free_steps <- if (model == "RSM") matrix(rep(v[3:4], 2L), 2L, byrow = TRUE) else
      matrix(v[3:6], 2L, byrow = TRUE)
    steps <- cbind(free_steps, -rowSums(free_steps)); rownames(steps) <- c("C1", "C2")
    long <- fixture$long
    ref <- t(vapply(fixture$persons, function(person) {
      rows <- which(long$Person == person)
      aq_continuous_reference(long$Score[rows],
        -rater[long$Rater[rows]] - criterion[long$Criterion[rows]],
        steps[long$Criterion[rows], , drop = FALSE], rep(1, length(rows)), rep(1, length(rows)),
        beta[1L] + beta[2L] * long$X[rows[1L]], sqrt(sigma2))
    }, numeric(5)))
    write.csv(data.frame(Person = fixture$persons, ref), file.path(directory, "continuous-native.csv"), row.names = FALSE)
    for (i in seq_len(nrow(settings))) {
      native <- read.csv(file.path(directory, files[i]))
      index <- match(fixture$persons, trimws(native$PID)); stopifnot(!anyNA(index))
      eap <- native$EAP_1[index] - ref[, "eap"]; sd <- native$PosteriorSD_1[index] - ref[, "sd"]
      stopifnot(all(is.finite(c(eap, sd))))
      results[[length(results) + 1L]] <- data.frame(Model = model, settings[i, ],
        CalibrationUnchanged = TRUE, MaxEAPError = max(abs(eap)), EAPRMSE = sqrt(mean(eap^2)),
        MaxSDError = max(abs(sd)), SDRMSE = sqrt(mean(sd^2)))
      scores[[length(scores) + 1L]] <- data.frame(Model = model, settings[i, ], Person = fixture$persons,
        NativeEAP = native$EAP_1[index], ContinuousEAP = ref[, "eap"],
        NativeSD = native$PosteriorSD_1[index], ContinuousSD = ref[, "sd"], row.names = NULL)
    }
  }
  result <- do.call(rbind, results)
  stopifnot(nrow(result) == 18L)
  write.csv(result, file.path(output_dir, "results.csv"), row.names = FALSE)
  write.csv(do.call(rbind, scores), file.path(output_dir, "scores.csv"), row.names = FALSE)
  invisible(result)
}
