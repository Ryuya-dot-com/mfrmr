#!/usr/bin/env Rscript

# Build a compact, neutral, operational-design example from explicit RSM
# category probabilities. This file contains no empirical records.

args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
script_path <- sub("^--file=", "", file_arg[1])
pkg_root <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)
data_dir <- file.path(pkg_root, "data")

dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)
set.seed(20260724)

persons <- sprintf("P%03d", seq_len(48))
raters <- sprintf("R%02d", seq_len(6))
criteria <- c("Content", "Organization", "Language")
pair_counts <- c(10L, 9L, 8L, 8L, 7L, 6L)
pair_group_a <- c(5L, 5L, 4L, 4L, 3L, 3L)
rater_pairs <- lapply(seq_along(raters), function(i) {
  c(raters[i], raters[(i %% length(raters)) + 1L])
})

assignments <- vector("list", length(rater_pairs))
cursor <- 1L
for (i in seq_along(rater_pairs)) {
  n_i <- pair_counts[i]
  person_i <- persons[cursor:(cursor + n_i - 1L)]
  group_i <- c(
    rep("A", pair_group_a[i]),
    rep("B", n_i - pair_group_a[i])
  )
  assignments[[i]] <- data.frame(
    Person = person_i,
    Rater1 = rater_pairs[[i]][1],
    Rater2 = rater_pairs[[i]][2],
    Group = group_i,
    stringsAsFactors = FALSE
  )
  cursor <- cursor + n_i
}
assignments <- do.call(rbind, assignments)

theta <- stats::rnorm(length(persons), mean = 0, sd = 0.75)
names(theta) <- persons
severity <- stats::setNames(seq(-0.55, 0.55, length.out = length(raters)), raters)
difficulty <- c(Content = -0.35, Organization = 0, Language = 0.35)
steps <- c(-1.2, 0, 1.2)

rsm_probabilities <- function(eta) {
  log_numerator <- c(0, cumsum(eta - steps))
  numerator <- exp(log_numerator - max(log_numerator))
  numerator / sum(numerator)
}

rows <- vector("list", nrow(assignments))
for (i in seq_len(nrow(assignments))) {
  rows[[i]] <- expand.grid(
    Person = assignments$Person[i],
    Rater = c(assignments$Rater1[i], assignments$Rater2[i]),
    Criterion = criteria,
    stringsAsFactors = FALSE
  )
  rows[[i]]$Group <- assignments$Group[i]
}
mfrmr_example_operational <- do.call(rbind, rows)

eta <- theta[mfrmr_example_operational$Person] -
  severity[mfrmr_example_operational$Rater] -
  difficulty[mfrmr_example_operational$Criterion]
probabilities <- t(vapply(eta, rsm_probabilities, numeric(4)))
mfrmr_example_operational$Score <- apply(
  probabilities,
  1,
  function(p) sample.int(4, size = 1L, prob = p)
)
mfrmr_example_operational$Study <- "OperationalExample"

# Preserve the complete planned assignment roster before removing unavailable
# ratings. It deliberately has no Score column: it declares which rating cells
# were expected, not fabricated outcomes for cells that were not observed.
mfrmr_example_operational_design <- mfrmr_example_operational[
  order(
    mfrmr_example_operational$Person,
    mfrmr_example_operational$Rater,
    mfrmr_example_operational$Criterion
  ),
  c("Study", "Person", "Rater", "Criterion", "Group")
]
row.names(mfrmr_example_operational_design) <- NULL

# Six planned criterion-level omissions: one for each rater, two for each
# criterion, three in each person group, and six different persons. In long
# form these unobserved ratings are absent rather than represented by
# fabricated scores or sentinel codes.
omission_targets <- data.frame(
  Rater = raters,
  Criterion = rep(criteria, length.out = length(raters)),
  Group = rep(c("A", "B"), length.out = length(raters)),
  stringsAsFactors = FALSE
)
omission_rows <- integer(nrow(omission_targets))
used_persons <- character()
for (i in seq_len(nrow(omission_targets))) {
  candidates <- which(
    mfrmr_example_operational$Rater == omission_targets$Rater[i] &
      mfrmr_example_operational$Criterion == omission_targets$Criterion[i] &
      mfrmr_example_operational$Group == omission_targets$Group[i] &
      !mfrmr_example_operational$Person %in% used_persons
  )
  omission_rows[i] <- candidates[1]
  used_persons <- c(
    used_persons,
    mfrmr_example_operational$Person[omission_rows[i]]
  )
}
mfrmr_example_operational <- mfrmr_example_operational[-omission_rows, ]
mfrmr_example_operational <- mfrmr_example_operational[
  order(
    mfrmr_example_operational$Person,
    mfrmr_example_operational$Rater,
    mfrmr_example_operational$Criterion
  ),
  c("Study", "Person", "Rater", "Criterion", "Score", "Group")
]
row.names(mfrmr_example_operational) <- NULL

# Regeneration invariants keep the teaching design stable.
observed_rater_pairs <- lapply(
  split(mfrmr_example_operational$Rater, mfrmr_example_operational$Person),
  unique
)
pair_key <- function(x) paste(sort(x), collapse = "|")
observed_pair_keys <- vapply(observed_rater_pairs, pair_key, character(1))
planned_pair_keys <- vapply(rater_pairs, pair_key, character(1))
stopifnot(
  nrow(mfrmr_example_operational_design) == 288L,
  !"Score" %in% names(mfrmr_example_operational_design),
  !anyDuplicated(mfrmr_example_operational_design[c("Person", "Rater", "Criterion")]),
  nrow(mfrmr_example_operational) == 282L,
  length(unique(mfrmr_example_operational$Person)) == 48L,
  length(unique(mfrmr_example_operational$Rater)) == 6L,
  length(unique(mfrmr_example_operational$Criterion)) == 3L,
  identical(as.integer(table(mfrmr_example_operational$Rater)),
            c(47L, 56L, 50L, 47L, 44L, 38L)),
  all(table(mfrmr_example_operational$Criterion) == 94L),
  identical(as.integer(table(unique(mfrmr_example_operational[c("Person", "Group")])$Group)),
            c(24L, 24L)),
  identical(as.integer(table(mfrmr_example_operational$Group)),
            c(141L, 141L)),
  all(table(mfrmr_example_operational$Person) %in% c(5L, 6L)),
  sum(table(mfrmr_example_operational$Person) == 5L) == 6L,
  all(lengths(observed_rater_pairs) == 2L),
  all(observed_pair_keys %in% planned_pair_keys),
  setequal(observed_pair_keys, planned_pair_keys),
  identical(sort(unique(mfrmr_example_operational$Score)), 1:4),
  all(table(mfrmr_example_operational$Score) >= 20L)
)

save(
  mfrmr_example_operational,
  file = file.path(data_dir, "mfrmr_example_operational.rda"),
  compress = "xz",
  version = 2
)
save(
  mfrmr_example_operational_design,
  file = file.path(data_dir, "mfrmr_example_operational_design.rda"),
  compress = "xz",
  version = 2
)

message("Saved operational example data and assignment roster to: ", data_dir)
