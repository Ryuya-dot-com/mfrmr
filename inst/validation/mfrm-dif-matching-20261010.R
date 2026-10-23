# Deterministic checks for the MH/ordinal-logistic DFF comparison contract.
# Run from the package root. No mfrmr fit, Monte Carlo sample, or public API
# is evaluated here: these witnesses distinguish the nulls and assumptions.
root <- "validation-results/dif-literature-20261010"
dir.create(root, recursive = TRUE, showWarnings = FALSE)

# Enumerate all binary Rasch response patterns and integrate a declared
# two-point ability distribution exactly, without simulation/quadrature.
pattern_law <- function(b, theta, weights) {
  patterns <- as.matrix(expand.grid(rep(list(0:1), length(b))))
  mass <- vapply(seq_len(nrow(patterns)), function(i) {
    p <- plogis(outer(theta, b, "-"))
    sum(weights * apply(sweep(p, 2L, patterns[i, ], function(p, y)
      ifelse(y == 1L, p, 1 - p)), 1L, prod))
  }, 0)
  stopifnot(abs(sum(mass) - 1) < 1e-14)
  data.frame(y = patterns[, 1L], total = rowSums(patterns),
             rest = rowSums(patterns[, -1L, drop = FALSE]), mass = mass)
}

conditional_prob <- function(law, match) {
  vapply(sort(unique(law[[match]])), function(s) {
    use <- law[[match]] == s
    sum(law$mass[use] * law$y[use]) / sum(law$mass[use])
  }, 0)
}

compare_laws <- function(reference, focal, match, label) {
  r <- conditional_prob(reference, match)
  f <- conditional_prob(focal, match)
  use <- r > 0 & r < 1 & f > 0 & f < 1
  data.frame(Case = label, Matching = match,
    Score = sort(unique(reference[[match]]))[use],
    ReferenceProbability = r[use], FocalProbability = f[use],
    ReferenceFocalOddsRatio = (r[use] / (1 - r[use])) / (f[use] / (1 - f[use])))
}

b <- c(-.6, -1, 0, .5, 1)
theta <- c(-1.5, 1.5)
r <- pattern_law(b, theta, c(.8, .2))
f <- pattern_law(b, theta, c(.2, .8))
total <- compare_laws(r, f, "total", "No DIF; unequal ability distributions")
rest <- compare_laws(r, f, "rest", "No DIF; unequal ability distributions")
shift <- .7
f_shift <- pattern_law(b + c(shift, 0, 0, 0, 0), theta, c(.2, .8))
uniform <- compare_laws(r, f_shift, "total", "Focal item difficulty shifted by 0.7")
stopifnot(max(abs(total$ReferenceFocalOddsRatio - 1)) < 1e-13,
          max(abs(rest$ReferenceFocalOddsRatio - 1)) > .1,
          max(abs(uniform$ReferenceFocalOddsRatio - exp(shift))) < 1e-13)

# The studied cell is identical; only the other rating cells differ by plan.
# Both groups have the same ability distribution and both plans occur in
# both groups. Unequal plan mixtures alone defeat matching on total score.
easy <- pattern_law(c(0, -1, -1, -1), theta, c(.5, .5))
hard <- pattern_law(c(0, 1, 1, 1), theta, c(.5, .5))
mix_laws <- function(easy_weight) {
  law <- easy
  law$mass <- easy_weight * easy$mass + (1 - easy_weight) * hard$mass
  law
}
pooled <- compare_laws(mix_laws(.8), mix_laws(.2), "total", "No DIF; unequal plan mixtures")
within <- rbind(compare_laws(easy, easy, "total", "Within easy plan"),
                compare_laws(hard, hard, "total", "Within hard plan"))
stopifnot(max(abs(pooled$ReferenceFocalOddsRatio - 1)) > .1,
          max(abs(within$ReferenceFocalOddsRatio - 1)) < 1e-13)
matching <- rbind(total, rest, uniform, pooled, within)
write.csv(matching, file.path(root, "matching-contract.csv"), row.names = FALSE)

# RSM/PCM with three categories and zero steps: p(k) proportional to exp(k*theta).
# Parallel cumulative logits require a constant gap, which this model lacks.
t <- c(-2, 0, 2)
pmf <- t(vapply(t, function(x) { p <- exp((0:2) * x); p / sum(p) }, numeric(3)))
lower <- qlogis(pmf[, 1L])
upper <- qlogis(rowSums(pmf[, 1:2]))
gap <- upper - lower
stopifnot(max(abs(gap - (2 * log1p(exp(t)) - t))) < 1e-13,
          gap[1L] > gap[2L] + 1e-10,
          abs(gap[1L] - gap[3L]) < 1e-13)
ordinal <- data.frame(Theta = t, LowerCumulativeLogit = lower,
                      UpperCumulativeLogit = upper, Gap = gap)
write.csv(ordinal, file.path(root, "cumulative-logit-contract.csv"), row.names = FALSE)

# Opposite odds ratios cancel in the common MH association. This is a
# deterministic count example, not a power study or a fitted MFRM benchmark.
tab <- array(c(10, 40, 40, 10, 40, 10, 10, 40), dim = c(2, 2, 2),
             dimnames = list(Group = c("Reference", "Focal"),
                             Score = c("High", "Low"), Match = c("Low", "High")))
mh <- mantelhaen.test(tab, correct = FALSE)
counts <- expand.grid(Group = 0:1, Match = c(-1, 1))
counts$Yes <- c(10, 40, 40, 10)
counts$No <- 50 - counts$Yes
logistic <- function(multiplier) {
  base <- glm(cbind(Yes * multiplier, No * multiplier) ~ Match,
              family = binomial(), data = counts)
  full <- glm(cbind(Yes * multiplier, No * multiplier) ~ Match * Group,
              family = binomial(), data = counts)
  stopifnot(base$converged, full$converged)
  list(lr = as.numeric(2 * (logLik(full) - logLik(base))), coef = coef(full))
}
original <- logistic(1)
duplicated <- logistic(2)
stopifnot(abs(unname(mh$estimate) - 1) < 1e-14,
          abs(unname(mh$statistic)) < 1e-14,
          original$lr > 70,
          max(abs(original$coef - duplicated$coef)) < 1e-10,
          abs(duplicated$lr - 2 * original$lr) < 1e-10)
contrasts <- data.frame(Case = c("Opposite effects", "Same records counted twice"),
  ReferenceFocalORLow = .0625, ReferenceFocalORHigh = 16,
  MHOddsRatio = unname(mh$estimate), JointLogisticLR = c(original$lr, duplicated$lr),
  UniquePersons = 200, TreatedAsIndependentRows = c(200, 400))
write.csv(contrasts, file.path(root, "crossing-and-dependence.csv"), row.names = FALSE)

# Audit source arithmetic; do not use these printed discrepancies as
# software acceptance targets. The original PDFs remain unmodified.
source_check <- data.frame(
  Source = c("Zumbo 1999 p.30", "Zumbo 1999 p.32 and p.55", "Rogers & Swaminathan 1993 p.111"),
  Quantity = c("Chi-square 1.077, df=2, upper-tail p", "WLS R2 change: .700-.208", "SD of chi-square(1)"),
  Printed = c(.299, .402, 1),
  Recomputed = c(pchisq(1.077, 2, lower.tail = FALSE), .700 - .208, sqrt(2)))
stopifnot(abs(source_check$Recomputed[1] - exp(-1.077 / 2)) < 1e-15)
write.csv(source_check, file.path(root, "source-arithmetic.csv"), row.names = FALSE)
saveRDS(list(parameters = list(b = b, theta = theta, group_weights = list(c(.8, .2), c(.2, .8)),
                              shift = shift, plan_weights = c(.8, .2)),
             matching = matching, ordinal = ordinal, counts = counts, mh = mh,
             original = original, duplicated = duplicated, sources = source_check),
        file.path(root, "contract-results.rds"))
writeLines(capture.output(sessionInfo()), file.path(root, "contract-session.txt"))
write.csv(data.frame(File = "inst/validation/mfrm-dif-matching-20261010.R",
  SHA256 = digest::digest(file = "inst/validation/mfrm-dif-matching-20261010.R", algo = "sha256")),
  file.path(root, "contract-source.csv"), row.names = FALSE)
print(matching, row.names = FALSE)
print(ordinal, row.names = FALSE)
print(contrasts, row.names = FALSE)
print(source_check, row.names = FALSE)
cat("All deterministic contract checks passed; no sampling-performance claim.\n")
