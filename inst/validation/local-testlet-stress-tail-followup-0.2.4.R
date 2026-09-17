# Targeted post-screen diagnosis; run after local-testlet-stress-0.2.4.R.
source('inst/validation/local-testlet-stress-0.2.4.R')

run_stress_tail_followup <- function() {
  output <- 'validation-results/local-testlet-stress-20260917'
  previous <- readRDS('validation-results/local-testlet-tam-reference-20260917/evidence.rds')
  rows <- list()
  for (id in c('alpha_-40', 'alpha_40')) {
    saved <- readRDS(file.path(output, paste0(id, '.rds')))
    reference <- saved$references[[length(saved$references)]]$value
    fit <- stress_capture(stress_tam(saved$case, seq(-20, 20, length.out = 121),
      previous$fits[['variance_0.49']]))
    old <- stress_capture(local_testlet_reference(saved$case$fixture,
      saved$case$parameters, saved$case$variance, 121L))
    sign <- if (id == 'alpha_-40') 1 else -1
    person <- if (sign == 1) 5 else 4
    expected <- c(12 * sign, 1, 2.94 * sign, .7, 2.94 * sign, .7)
    likelihood_error <- if (is.null(fit$value)) NA_real_ else abs(fit$value$loglik - reference$loglik)
    moment_error <- if (is.null(fit$value)) NA_real_ else max(abs(fit$value$moments - reference$moments))
    limiting_error <- max(abs(reference$moments[person, ] - expected))
    rows[[id]] <- data.frame(Case = id, Grid = 'n121_r20', LogLikError = likelihood_error,
      MomentError = moment_error, LimitingNormalError = limiting_error,
      ProbabilityError = if (is.null(fit$value)) NA_real_ else fit$value$probability_error,
      OriginalReferenceLogLikError = if (is.null(old$value)) NA_real_ else abs(old$value$loglik - reference$loglik),
      OriginalReferenceMomentError = if (is.null(old$value)) NA_real_ else max(abs(old$value$moments - reference$moments)),
      Error = fit$error, Warnings = paste(fit$warnings, collapse = ' | '), Seconds = fit$elapsed)
    saveRDS(list(case = saved$case, reference = reference, tam = fit, original_reference = old,
      expected = expected, executed = Sys.time(),
      sources = tools::md5sum(c('inst/validation/local-testlet-stress-tail-followup-0.2.4.R',
        'inst/validation/local-testlet-stress-0.2.4.R'))), file.path(output, paste0(id, '-tail-followup.rds')))
    cat('FOLLOWUP', id, 'loglik', likelihood_error, 'moments', moment_error, '\n')
  }
  result <- do.call(rbind, rows)
  result$Pass <- is.finite(result$LogLikError) & is.finite(result$MomentError) &
    result$LogLikError <= 1e-6 & result$MomentError <= 1e-6 &
    result$LimitingNormalError <= 1e-6 & result$ProbabilityError <= 1e-12
  write.csv(result, 'inst/validation/local-testlet-stress-0.2.4-tail-followup.csv', row.names = FALSE)
  print(result)
}

if (sys.nframe() == 0L) run_stress_tail_followup()
