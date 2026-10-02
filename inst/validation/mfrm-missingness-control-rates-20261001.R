# E8 controls: population-defined independent deletion rates, before simulation.
# Two integration coordinates check each rate. No data generation or fitting.
# Rscript THIS_FILE NEW_OUTPUT_DIRECTORY
args <- commandArgs(trailingOnly = TRUE)
stopifnot(length(args) == 1L, !dir.exists(args[1L]))
out <- args[1L]; dir.create(out, recursive = TRUE)
truths <- c('S-RSM', 'S-PCM', 'S-GPCM')
deletion <- c(.05, .10, .20, .35)
raters <- c(-.3, 0, .3); criteria <- c(-.4, .1, .3)
steps <- rbind(c(-.6,.2,.4), c(-.8,-.1,.9), c(-.4,-.1,.5))
tolerance <- list(integration_abs = 1e-10, integration_rel = 1e-10, agreement = 1e-8)
spec <- list(raters = raters, criteria = criteria, steps = steps,
  shared_steps = c(-.6,0,.6), log_slopes = c(-.2,.2,0), deletion = deletion,
  assignment = 'iid uniform choice among rater pairs 12/23/31; all three criteria',
  weighting = 'Each of the nine Rater/Criterion cells has expected rating weight 1/9.',
  shapes = c(normal = 'N(0,1)', right_skew = 'Exp(rate=1)-1'), tolerance = tolerance,
  scope = 'E8 and the normal/right-skew x missingness comparison, independent of N.')
saveRDS(spec, file.path(out, 'specification.rds'))

expected_deletion <- function(theta, truth) {
  tau <- if (truth == 'S-RSM') matrix(c(-.6,0,.6),3,3,byrow=TRUE) else steps
  slope <- if (truth == 'S-GPCM') exp(c(-.2,.2,0)) else rep(1,3)
  value <- numeric(length(theta))
  for (r in 1:3) for (c in 1:3) {
    z <- slope[c] * sweep(outer(theta-raters[r]-criteria[c], 0:3),
      2L, c(0,cumsum(tau[c,])), '-')
    mass <- exp(z-apply(z,1,max)); mass <- mass/rowSums(mass)
    stopifnot(all(is.finite(mass)), max(abs(rowSums(mass)-1)) < 1e-12)
    value <- value + drop(mass %*% deletion)/9
  }
  value
}

rows <- list(); evidence <- list()
for (truth in truths) for (shape in c('normal','right_skew')) {
  density <- if (shape == 'normal') dnorm else function(x) dexp(x+1)
  quantile <- if (shape == 'normal') qnorm else function(u) -log1p(-u)-1
  lower <- if (shape == 'normal') -Inf else -1
  a <- integrate(function(x) expected_deletion(x,truth)*density(x), lower, Inf,
    abs.tol=tolerance$integration_abs, rel.tol=tolerance$integration_rel,
    subdivisions=1000L, stop.on.error=FALSE)
  b <- integrate(function(u) expected_deletion(quantile(u),truth), 0, 1,
    abs.tol=tolerance$integration_abs, rel.tol=tolerance$integration_rel,
    subdivisions=1000L, stop.on.error=FALSE)
  id <- paste(truth,shape,sep='-')
  evidence[[id]] <- list(density_integral=a, uniform_quantile_integral=b)
  saveRDS(evidence, file.path(out,'integrals.rds'))
  stopifnot(a$message == 'OK', b$message == 'OK',
    abs(a$value-b$value) < tolerance$agreement,
    a$value > min(deletion), a$value < max(deletion))
  rows[[id]] <- data.frame(Truth=truth, Shape=shape, IndependentDeletionRate=a$value,
    DensityAbsError=a$abs.error, UniformAbsError=b$abs.error,
    CoordinateDifference=abs(a$value-b$value))
}
rows <- do.call(rbind,rows)
write.csv(rows,file.path(out,'rates.csv'),row.names=FALSE)
saveRDS(list(rows=rows,specification=spec,source_md5=tools::md5sum(
  'inst/validation/mfrm-missingness-control-rates-20261001.R'),
  session=capture.output(sessionInfo())),file.path(out,'verified-rates.rds'))
print(rows,row.names=FALSE,digits=12)
