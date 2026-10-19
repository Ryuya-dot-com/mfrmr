# Analytic observed-ability reference for the two unresolved N20 questions.
# Base R only. This is not a new MFRM procedure or a simulation confirmation.
script <- 'inst/validation/mfrm-lr-normal-reference-20261012.R'
root <- 'validation-results/mfrm-lr-rsm-inconclusive-20261010'
input <- file.path(root, 'diagnosis.rds')
saved <- readRDS(input)
stopifnot(identical(tools::md5sum(names(saved$inputs)), saved$inputs),
  identical(tools::md5sum(names(saved$script)), saved$script),
  !'mfrmr' %in% loadedNamespaces())

# Conditional on full-rank X with two columns, S/sigma^2 ~ chi-square(N-2).
# Independently verify normal-contrast coverage by integrating its normal
# conditional inclusion probability over the residual chi-square density.
mixture_coverage <- function(n, critical, variance_divisor) {
  df <- n - 2L
  # Scale to mean one so adaptive quadrature samples the mass even at N240.
  f <- function(u) {
    v <- df*u
    density <- exp((df/2-1)*log(v) - v/2 - df/2*log(2) - lgamma(df/2))
    (2*pnorm(critical*sqrt(v/variance_divisor))-1)*density*df
  }
  integrate(f, 0, Inf, rel.tol = 1e-11, abs.tol = 1e-11,
    subdivisions = 1000L, stop.on.error = TRUE)$value
}
# The even-df survival law is a finite Erlang sum, independent of pchisq.
erlang_survival <- function(v, df) {
  stopifnot(df %% 2 == 0, v > 0)
  k <- 0:(df/2 - 1L)
  terms <- -v/2 + k*log(v/2) - lgamma(k+1)
  exp(max(terms))*sum(exp(terms-max(terms)))
}

rows <- list(); discrepancies <- numeric()
for (n in c(20L, 240L)) {
  df <- n - 2L; z <- qnorm(.975); t <- qt(.975, df)
  mean_specs <- data.frame(Method = c('z_with_ML_variance',
    't_only_with_ML_variance', 'exact_t_with_unbiased_variance'),
    Critical = c(z, t, t), Divisor = c(n, n, df))
  for (i in seq_len(nrow(mean_specs))) {
    a <- mean_specs[i, ]
    coverage <- 2*pt(a$Critical*sqrt(df/a$Divisor), df)-1
    check <- mixture_coverage(n, a$Critical, a$Divisor)
    discrepancies <- c(discrepancies, abs(coverage-check))
    rows[[length(rows)+1L]] <- data.frame(N = n, DF = df,
      Target = 'any_prespecified_mean_contrast', Method = a$Method,
      Coverage = coverage, IntervalBelowTruth = (1-coverage)/2,
      IntervalAboveTruth = (1-coverage)/2)
  }
  bounds <- list(log_variance_Wald = n*exp(c(-1,1)*z*sqrt(2/n)),
    log_variance_t_only = n*exp(c(-1,1)*t*sqrt(2/n)),
    exact_chisq_variance = qchisq(c(.025,.975), df))
  for (method in names(bounds)) {
    b <- bounds[[method]]
    below <- pchisq(b[1], df)
    above <- pchisq(b[2], df, lower.tail = FALSE)
    independent <- c(1-erlang_survival(b[1], df), erlang_survival(b[2], df))
    discrepancies <- c(discrepancies, abs(c(below,above)-independent))
    rows[[length(rows)+1L]] <- data.frame(N = n, DF = df,
      Target = 'log_residual_variance', Method = method,
      Coverage = 1-below-above, IntervalBelowTruth = below,
      IntervalAboveTruth = above)
  }
}
reference <- do.call(rbind, rows)
stopifnot(max(discrepancies) < 1e-10,
  max(abs(reference$Coverage+reference$IntervalBelowTruth+reference$IntervalAboveTruth-1)) < 1e-14,
  all(abs(reference$Coverage[grepl('^exact_',reference$Method)]-.95) < 1e-12))
historical <- subset(saved$diagnostics,
  Target %in% c('contrast:mean_at_plus1','log_residual_variance'))
historical$Coverage <- historical$Covered/historical$Returned
historical$IntervalBelowTruth <- historical$BelowTruth/historical$Returned
historical$IntervalAboveTruth <- historical$AboveTruth/historical$Returned
stopifnot(all(historical$Returned[historical$N==20]==765L),
  identical(historical$Covered[historical$N==20], c(713L,744L)))
write.csv(reference, file.path(root,'normal-reference-20261012.csv'), row.names=FALSE)
scope <- paste('Exact-law observed-ability normal regression with p=2, full-rank fixed X and independent homoscedastic normal errors.',
  'No ratings, facet estimation, latent integration or output selection in this reference.',
  'Historical MFRM values describe selected returned intervals; this is not a causal decomposition or a calibration formula for MFRM.',
  'The original supported/inconclusive decisions, public SEs and critical values are unchanged.')
record <- list(reference=reference,historical=historical,
  input=c(tools::md5sum(input),saved$inputs),script=tools::md5sum(script),
  maximum_independent_discrepancy=max(discrepancies),scope=scope,
  new_mfrmr_fits=0L,new_draws=0L,new_mfrmr_information=0L,
  runtime=capture.output(sessionInfo()))
saveRDS(record,file.path(root,'normal-reference-20261012.rds'))
print(reference, digits=8, row.names=FALSE)
cat('Maximum independent probability discrepancy:',max(discrepancies),'\n')
cat(scope,'\n')
cat('No MFRM package loaded; no new fits, random draws or information calculations.\n')
