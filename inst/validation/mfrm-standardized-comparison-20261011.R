# Retained equal-slope control for D. Transform saved intervals, never refit.
# The contract is in gmfrm-mml-em-20260927.md; original source admission stays.
pkgload::load_all('.', quiet = TRUE, compile = FALSE, helpers = FALSE)
root <- 'validation-results/mfrm-wide-map-pcm-r50-portable-20261003'
out <- 'validation-results/mfrm-standardized-comparison-20261011'
dir.create(out, showWarnings = FALSE)
blocked <- c('fit_mfrm', 'compute_mml_parameter_covariance',
  'mfrm_native_location_inference', 'score_mfrm_persons', 'simulate_mfrm')
for (name in blocked) if (exists(name, asNamespace('mfrmr'), inherits = FALSE))
  trace(name, quote(stop('Numerical recomputation is forbidden in this reanalysis.')),
    where = asNamespace('mfrmr'), print = FALSE)
source_hash <- tools::md5sum(c('inst/validation/mfrm-standardized-comparison-20261011.R',
  list.files('R', '[.]R$', full.names = TRUE)))
bound <- character()
read <- function(path, wrapped = TRUE) {
  h <- tools::md5sum(path)
  stopifnot(!is.na(h), !path %in% names(bound) || identical(bound[path], h))
  bound[path] <<- h
  z <- readRDS(path)
  if (wrapped) {
    stopifnot(identical(z$checksum, mfrmr:::mfrm_checkpoint_fingerprint(z$payload)))
  }
  z
}
verify <- function(h) {
  stopifnot(length(h) > 0L, !anyNA(h), identical(tools::md5sum(names(h)), h))
  bound[names(h)] <<- h
}
manifest <- read(file.path(root, 'manifest.rds'))$payload
conditions <- c(paste0('AB:paired-L1:N', c(20,30,60,240,480), ':SD1:S-PCM'),
  paste0('AB:paired-L1:N', c(20,60,240), ':SD0.5:S-PCM'))
summaries <- c('summary-n20', 'summary-n30', 'summary-n60', 'summary-n240',
  'summary-n480', 'summary-n20-sd05', 'summary-n60-sd05', 'summary-n240-sd05')
arms <- c('PCM-MML-free', 'GPCM-MML-free')
rows <- epochs <- list()
for (cell in seq_along(conditions)) {
  condition <- conditions[cell]
  summary_path <- file.path(root, summaries[cell], 'summary.rds')
  if (file.exists(summary_path)) {
    summary <- read(summary_path)
    stopifnot(identical(summary$binding$condition, condition))
    verify(summary$binding$outputs)
  }
  jobs <- manifest$jobs[manifest$jobs$ConditionId == condition & manifest$jobs$Arm %in% arms, ]
  stopifnot(nrow(jobs) == 100L, all(table(jobs$Arm) == 50L))
  for (i in seq_len(nrow(jobs))) {
    job <- jobs[i, ]; path <- file.path(root, job$JobId)
    original <- read(file.path(path, 'outputs.rds'))
    stopifnot(identical(original$payload$job, job), isTRUE(original$payload$completed))
    epoch <- mfrmr:::mfrm_checkpoint_fingerprint(original$binding$source)
    epochs[[epoch]] <- original$binding$source
    selection <- read(file.path(path, 'calibration/selected.rds'))$payload
    calibration <- read(file.path(path, 'calibration/manifest.rds'))$payload
    stopifnot(identical(selection$identity, mfrmr:::mfrm_checkpoint_fingerprint(calibration)),
      identical(selection$spec_hash, mfrmr:::mfrm_checkpoint_fingerprint(calibration$spec)))
    input_path <- file.path(manifest$root, job$Bundle)
    verify(setNames(job$BundleMD5, input_path))
    input <- read(input_path, FALSE)
    stopifnot(input$unit$N == job$N, input$unit$SD == job$SD,
      input$unit$Replicate == job$Replicate, input$unit$Truth == 'S-PCM',
      all(input$truth$log_slopes == 0))
    for (owner in c('Rater', 'Criterion')) {
      id <- tolower(owner); selected <- selection$intervals[[id]]
      stopifnot(identical(selected$error, ''), inherits(selected$value, 'mfrm_facet_intervals'))
      ci <- selected$value; fit <- ci$fit
      q <- sub(':.*', '', selected$stage)
      phase <- read(file.path(path, 'calibration', paste0(q, '-fit.rds')))
      stopifnot(identical(phase$checksum, selected$fit_hash),
        identical(phase$payload$value, fit),
        identical(calibration$spec$args$data, input$views[[job$View]]),
        identical(ci$settings$procedure, 'mml_native_location_model_v1'),
        identical(ci$settings$population, 'estimated_intercept_normal'),
        identical(ci$settings$scale, 'native_ability'), nrow(ci$table) == 1L,
        identical(as.numeric(ci$contrasts), c(1, -1, 0)))
      saved_row <- original$payload$intervals$records
      saved_row <- saved_row[saved_row$Output == 'interval' &
        saved_row$Target == paste0('contrast:"', owner, '":"1-2"'), ]
      stopifnot(nrow(saved_row) == 1L, identical(saved_row$SourceStage, selected$stage),
        identical(saved_row$Available, ci$table$CIEligible),
        isTRUE(all.equal(unname(unlist(saved_row[c('Estimate','SE','Lower','Upper')])),
          unname(unlist(ci$table[c('Estimate','SE','Lower','Upper')])))))
      sizes <- mfrmr:::build_param_sizes(fit$config)
      slices <- mfrmr:::build_param_slices(sizes)
      params <- mfrmr:::expand_params(fit$opt$par, sizes, fit$config)
      lambda <- slices$log_sigma2
      sigma <- sqrt(params$population$sigma2)
      stopifnot(length(lambda) == 1L, is.finite(sigma), sigma > 0,
        identical(names(params$population$coefficients), '(Intercept)'),
        abs(exp(fit$opt$par[lambda]/2) - sigma) < 1e-12 * sigma)
      d <- as.numeric(ci$contrasts %*% params$facets[[owner]])
      stopifnot(abs(d - ci$table$Estimate) < 1e-10 * max(1, abs(d)))
      estimate <- d / sigma
      truth <- (input$truth[[owner]][1] - input$truth[[owner]][2]) / job$SD
      eligible <- isTRUE(ci$table$CIEligible)
      se <- width <- lower <- upper <- fixed_sd_se <- NA_real_
      if (eligible) {
        V <- ci$parameter_covariance; Jd <- ci$target_jacobian
        stopifnot(all(ci$checks$Passed), identical(dim(V), rep(length(fit$opt$par), 2L)),
          all(is.finite(V)), all(is.finite(Jd)), Jd[1, lambda] == 0)
        J <- Jd / sigma; J[1, lambda] <- -estimate / 2
        variance <- as.numeric(J %*% V %*% t(J))
        native_variance <- as.numeric(Jd %*% V %*% t(Jd))
        scalar <- (native_variance + d^2 * V[lambda, lambda]/4 -
          d * as.numeric(Jd %*% V[, lambda])) / sigma^2
        stopifnot(is.finite(variance), variance > 0,
          abs(variance - scalar) < 1e-10 * max(1, abs(variance)),
          abs(sqrt(native_variance) - ci$table$SE) < 1e-10 * max(1, ci$table$SE))
        se <- sqrt(variance); fixed_sd_se <- sqrt(native_variance)/sigma
        lower <- estimate - qnorm(.975) * se; upper <- estimate + qnorm(.975) * se
        width <- upper - lower
      }
      rows[[length(rows) + 1L]] <- data.frame(ConditionId = condition, N = job$N,
        SD = job$SD, Replicate = job$Replicate, Arm = job$Arm, Owner = owner,
        BundleMD5 = job$BundleMD5, Stage = selected$stage, HistoricalSourceEpoch = epoch,
        Truth = truth, Estimate = estimate, NativeEstimate = d, PopulationSD = sigma,
        Eligible = eligible, SE = se, FixedSDSE = fixed_sd_se, Lower = lower, Upper = upper,
        Width = width, Covered = eligible && lower <= truth && truth <= upper,
        Reason = ci$table$InferenceReview, CoverageQualified = FALSE,
        stringsAsFactors = FALSE)
    }
  }
  cat('Completed saved transformation:', condition, '\n'); flush.console()
}
rows <- do.call(rbind, rows); rownames(rows) <- NULL
stopifnot(nrow(rows) == 1600L, !anyDuplicated(rows[c('ConditionId','Replicate','Arm','Owner')]))
group <- function(x, columns) split(x, do.call(paste, c(x[columns], sep = '\r')))
summary <- do.call(rbind, lapply(group(rows, c('ConditionId','Arm','Owner')), function(z) {
  stopifnot(setequal(z$Replicate, 1:50))
  a <- z[z$Eligible, ]; err <- a$Estimate - a$Truth
  coverage <- if (nrow(a)) binom.test(sum(a$Covered), nrow(a))$conf.int else c(NA,NA)
  delivery <- binom.test(nrow(a), nrow(z))$conf.int
  cbind(z[1, c('ConditionId','N','SD','Arm','Owner')], data.frame(Planned = nrow(z),
    FinitePoints = sum(is.finite(z$Estimate)), Returned = nrow(a),
    DeliveryLower = delivery[1], DeliveryUpper = delivery[2], Covered = sum(a$Covered),
    ConditionalCoverage = mean(a$Covered), CoverageLower = coverage[1], CoverageUpper = coverage[2],
    AllAttemptInclusion = sum(a$Covered)/nrow(z),
    AllFiniteBias = mean(z$Estimate-z$Truth), AllFiniteRMSE = sqrt(mean((z$Estimate-z$Truth)^2)),
    Bias = mean(err), BiasMCSE = sd(err)/sqrt(length(err)), RMSE = sqrt(mean(err^2)),
    EmpiricalSD = sd(a$Estimate), RMSSE = sqrt(mean(a$SE^2)), MeanWidth = mean(a$Width),
    SEtoFixedSDMin = min(a$SE/a$FixedSDSE), SEtoFixedSDMax = max(a$SE/a$FixedSDSE)))
}))
paired <- do.call(rbind, lapply(group(rows, c('ConditionId','Owner')), function(z) {
  a <- z[z$Arm == arms[1], ]; b <- z[z$Arm == arms[2], ]; b <- b[match(a$Replicate,b$Replicate), ]
  stopifnot(identical(a$BundleMD5,b$BundleMD5), identical(a$Truth,b$Truth), nrow(a) == 50L)
  joint <- a$Eligible & b$Eligible
  loss <- (b$Estimate-b$Truth)^2 - (a$Estimate-a$Truth)^2
  cbind(z[1, c('ConditionId','N','SD','Owner')], data.frame(Planned = 50L,
    PCMReturned = sum(a$Eligible), GPCMReturned = sum(b$Eligible), Joint = sum(joint),
    PCMJointRMSE = sqrt(mean((a$Estimate[joint]-a$Truth[joint])^2)),
    GPCMJointRMSE = sqrt(mean((b$Estimate[joint]-b$Truth[joint])^2)),
    JointMSEDifference = mean(loss[joint]), JointMSEDifferenceMCSE = sd(loss[joint])/sqrt(sum(joint)),
    AllFiniteMSEDifference = mean(loss), AllFiniteMSEDifferenceMCSE = sd(loss)/sqrt(length(loss))))
}))
rownames(summary) <- rownames(paired) <- NULL
verify(bound); stopifnot(identical(source_hash, tools::md5sum(names(source_hash))))
result <- list(rows = rows, summary = summary, paired = paired, historical_source_epochs = epochs,
  input_hashes = bound, source_hashes = source_hash,
  scope = paste('Historical native interval selection and numerical admission; full joint d/sigma transformation.',
    'Eight PCM-truth cells, 50 datasets each; paired models and targets are not independent replications.',
    'No current-source readmission, independent coverage qualification or universal model ranking.'),
  new_fits = 0L, new_information = 0L, new_responses = 0L, new_scores = 0L)
target <- file.path(out, 'comparison.rds')
if (file.exists(target)) stopifnot(identical(readRDS(target), result)) else saveRDS(result, target)
for (name in c('rows','summary','paired'))
  write.csv(result[[name]], file.path(out, paste0(name, '.csv')), row.names = FALSE)
print(paired, row.names = FALSE)
cat('All 1,600 target/model/dataset rows reconciled; no estimation or information calls.\n')
