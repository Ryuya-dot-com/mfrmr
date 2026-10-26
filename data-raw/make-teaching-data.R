# Reproduce the existing G-theory and agreement tutorial data as loadable objects.
# Run from the package root. These are fictional examples, not new validation data.
local({
  # Existing two-crossed-facet tutorial / mfrm_multivariate_d_compare example.
  set.seed(24)
  ratings <- expand.grid(Person = 1:40, Rater = 1:8, Task = 1:6)
  ratings$Content <- ratings$Organization <- 0
  sources <- list('Person', 'Rater', 'Task', c('Person', 'Rater'),
    c('Person', 'Task'), c('Rater', 'Task'), c('Person', 'Rater', 'Task'))
  for (source in sources) {
    group <- interaction(ratings[source], drop = TRUE)
    effects <- matrix(rnorm(2 * nlevels(group)), ncol = 2)
    ratings[c('Content', 'Organization')] <-
      ratings[c('Content', 'Organization')] + effects[as.integer(group), ]
  }
  mfrmr_example_gtheory_crossed <- ratings
  save(mfrmr_example_gtheory_crossed, file = 'data/mfrmr_example_gtheory_crossed.rda',
    compress = 'xz', version = 2)

  # Existing nested-facet example from mfrm_multivariate_gstudy.
  set.seed(2027)
  nested <- expand.grid(Person = 1:30, Task = 1:6, Rater = paste0('R', 1:3))
  nested$Content <- nested$Organization <- 0
  sources <- list('Person', 'Task', c('Task', 'Rater'),
    c('Person', 'Task'), c('Person', 'Task', 'Rater'))
  for (source in sources) {
    group <- interaction(nested[source], drop = TRUE)
    effect <- matrix(rnorm(2 * nlevels(group)), ncol = 2)
    effect <- effect %*% matrix(c(1, 0, 0.4, 1), 2)
    nested[c('Content', 'Organization')] <-
      nested[c('Content', 'Organization')] + effect[as.integer(group), ]
  }
  mfrmr_example_gtheory_nested <- nested
  save(mfrmr_example_gtheory_nested, file = 'data/mfrmr_example_gtheory_nested.rda',
    compress = 'xz', version = 2)

  # Existing agreement tutorial: offset, disagreement, missing score and absent row.
  units <- expand.grid(Task = c('T1', 'T2'), Person = sprintf('P%02d', 1:6),
    stringsAsFactors = FALSE)
  units <- units[c('Person', 'Task')]
  r1 <- rep(0:2, 4)
  r3 <- r1
  r3[c(3, 8)] <- c(1, 2)
  ratings <- rbind(data.frame(units, Rater = 'R1', Score = r1),
    data.frame(units, Rater = 'R2', Score = r1 + 1),
    data.frame(units, Rater = 'R3', Score = r3))
  ratings$Score[ratings$Rater == 'R3' & ratings$Person == 'P06' & ratings$Task == 'T2'] <- NA
  ratings <- subset(ratings, !(Rater == 'R3' & Person == 'P02' & Task == 'T2'))
  mfrmr_example_agreement <- ratings
  save(mfrmr_example_agreement, file = 'data/mfrmr_example_agreement.rda',
    compress = 'xz', version = 2)
})
