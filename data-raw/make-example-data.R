#!/usr/bin/env Rscript

# Build compact packaged datasets used in help examples.

args <- commandArgs(trailingOnly = FALSE)
file_arg <- grep("^--file=", args, value = TRUE)
script_path <- sub("^--file=", "", file_arg[1])
pkg_root <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)
data_dir <- file.path(pkg_root, "data")

dir.create(data_dir, recursive = TRUE, showWarnings = FALSE)

rsm_probs <- function(eta, steps = c(-1.4, 0, 1.4)) {
  step_cum <- c(0, cumsum(steps))
  cats <- 0:length(steps)
  log_num <- eta * cats - step_cum
  probs <- exp(log_num - max(log_num))
  probs / sum(probs)
}

make_example_core <- function() {
  set.seed(20260318)
  persons <- sprintf("P%03d", 1:48)
  raters <- sprintf("R%02d", 1:4)
  criteria <- c("Content", "Organization", "Language", "Accuracy")
  groups <- rep(c("A", "B"), each = 24)

  theta <- stats::rnorm(length(persons), mean = 0, sd = 1)
  alpha <- c(R01 = -0.4, R02 = -0.1, R03 = 0.1, R04 = 0.4)
  beta <- c(Content = -0.4, Organization = -0.1, Language = 0.1, Accuracy = 0.4)

  dat <- expand.grid(
    Person = persons,
    Rater = raters,
    Criterion = criteria,
    stringsAsFactors = FALSE
  )
  dat$Group <- groups[match(dat$Person, persons)]

  eta <- theta[match(dat$Person, persons)] - alpha[dat$Rater] - beta[dat$Criterion]
  probs <- t(vapply(eta, rsm_probs, numeric(4)))
  dat$Score <- apply(probs, 1, function(p) sample.int(4, size = 1, prob = p))
  dat$Study <- "ExampleCore"

  dat[, c("Study", "Person", "Rater", "Criterion", "Score", "Group")]
}

make_example_bias <- function() {
  set.seed(20260319)
  persons <- sprintf("P%03d", 1:48)
  raters <- sprintf("R%02d", 1:4)
  criteria <- c("Content", "Organization", "Language", "Accuracy")
  groups <- rep(c("A", "B"), each = 24)
  pair_cycle <- list(
    c("R01", "R02"),
    c("R01", "R03"),
    c("R01", "R04"),
    c("R02", "R03"),
    c("R02", "R04"),
    c("R03", "R04")
  )

  theta <- stats::rnorm(length(persons), mean = rep(c(-0.1, 0.1), each = 24), sd = 0.9)
  alpha <- c(R01 = -0.35, R02 = -0.1, R03 = 0.12, R04 = 0.33)
  beta <- c(Content = -0.35, Organization = -0.05, Language = 0.15, Accuracy = 0.3)

  rows <- vector("list", length(persons))
  for (i in seq_along(persons)) {
    pair <- pair_cycle[[((i - 1) %% length(pair_cycle)) + 1]]
    rows[[i]] <- expand.grid(
      Person = persons[i],
      Rater = pair,
      Criterion = criteria,
      stringsAsFactors = FALSE
    )
  }
  dat <- do.call(rbind, rows)
  dat$Group <- groups[match(dat$Person, persons)]

  eta <- theta[match(dat$Person, persons)] - alpha[dat$Rater] - beta[dat$Criterion]
  eta <- eta + ifelse(dat$Group == "B" & dat$Criterion == "Language", 1.2, 0)
  eta <- eta + ifelse(dat$Rater == "R04" & dat$Criterion == "Accuracy", -1.2, 0)

  probs <- t(vapply(eta, rsm_probs, numeric(4)))
  dat$Score <- apply(probs, 1, function(p) sample.int(4, size = 1, prob = p))
  dat$Study <- "ExampleBias"

  dat[, c("Study", "Person", "Rater", "Criterion", "Score", "Group")]
}

mfrmr_example_core <- make_example_core()
mfrmr_example_bias <- make_example_bias()

save(
  mfrmr_example_core,
  file = file.path(data_dir, "mfrmr_example_core.rda"),
  compress = "bzip2"
)
save(
  mfrmr_example_bias,
  file = file.path(data_dir, "mfrmr_example_bias.rda"),
  compress = "bzip2"
)

message("Saved example data objects to: ", data_dir)
