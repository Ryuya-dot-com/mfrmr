# Alternate fixed-point research calculator. No fitting or public caller.
# The frozen literal model supplies designs; all relative category logits
# retain the low part of theta = segment origin + local displacement.
source("inst/validation/gmfrm-segmented-reference-20261011.R")
local_add <- function(a, b) {
  s <- a + b; z <- s - a
  list(hi = s, lo = (a - (s - z)) + (b - z))
}
local_dd_add <- function(a, b) {
  x <- local_add(a$hi, b$hi)
  local_add(x$hi, x$lo + a$lo + b$lo)
}
local_logits <- function(origin, displacement, offset, slope) {
  theta <- local_add(origin, displacement)
  categories <- vector("list", length(offset)); current <- list(hi = origin * 0, lo = origin * 0)
  for (k in seq_along(offset)) {
    categories[[k]] <- local_dd_add(current, list(hi = offset[k], lo = 0))
    current <- local_dd_add(current, theta)
  }
  high <- max.col(do.call(cbind, lapply(categories, `[[`, "hi")), ties.method = "first")
  top_hi <- top_lo <- numeric(length(origin))
  for (k in seq_along(offset)) {
    take <- high == k; top_hi[take] <- categories[[k]]$hi[take]; top_lo[take] <- categories[[k]]$lo[take]
  }
  vapply(categories, function(x) {
    d <- local_dd_add(x, list(hi = -top_hi, lo = -top_lo))
    slope * (d$hi + d$lo)
  }, numeric(length(origin)))
}
local_integral <- function(model, rows, person, rule) {
  lower <- head(person$cuts, -1); width <- diff(person$cuts)
  origin <- rep(lower, each = length(rule$nodes))
  displacement <- as.vector(outer(rule$nodes, width))
  theta <- origin + displacement
  joint <- dnorm(theta, log = TRUE); p <- model$nb + model$ng
  U <- matrix(0, length(theta), p)
  for (j in rows) {
    logits <- local_logits(origin, displacement, -model$offset[j, ], model$a[j])
    lp <- logits - log(rowSums(exp(logits))); probability <- exp(lp)
    y <- model$score[j]; joint <- joint + lp[, y + 1L]
    delta <- t(vapply(model$D, function(d) model$D[[y + 1L]][j, ] - d[j, ], numeric(model$nb)))
    U[, seq_len(model$nb)] <- U[, seq_len(model$nb)] - model$a[j] * (probability %*% delta)
    log_residual <- rowSums(probability * (logits[, y + 1L] - logits))
    U[, model$nb + seq_len(model$ng)] <- U[, model$nb + seq_len(model$ng)] +
      outer(log_residual, model$Z[j, ])
  }
  w <- as.vector(outer(rule$weights, width)) * exp(joint - person$peak)
  mass <- sum(w)
  stopifnot(is.finite(mass), mass > 0, all(is.finite(U)))
  list(log_marginal = person$peak + log(mass), score = colSums(w * U) / mass)
}
local_main <- function() {
  directory <- "validation-results/gmfrm-segmented-followup-20261011"
  input <- readRDS(file.path(directory, "roundoff-input.rds")); model <- input$model
  output <- lapply(c(16L, 32L, 64L), function(order) {
    rule <- seg_rule(order)
    people <- lapply(model$groups, function(rows) local_integral(model, rows, seg_person(model, rows), rule))
    list(order = order, nll = -sum(vapply(people, `[[`, 0, "log_marginal")),
      score = Reduce(`+`, lapply(people, `[[`, "score")), people = people)
  })
  saveRDS(list(results = output, input = tools::md5sum(file.path(directory, "roundoff-input.rds")),
    sources = tools::md5sum(c("inst/validation/gmfrm-local-coordinates-20261011.R", seg_script))),
    file.path(directory, "local-coordinate-check.rds"))
  for (i in 1:2) print(c(Order = output[[i]]$order, NLLDifference = abs(output[[i]]$nll - output[[3]]$nll),
    ScoreDifference = max(abs(output[[i]]$score - output[[3]]$score))))
}
if (sys.nframe() == 0L) local_main()
