# Repository-only GPCM comparison qualification. Source after
# comparison-identification-rsm-pcm.R in an mfrmr namespace child environment.
# No fits or files are created on sourcing; numerical ranks are local evidence.

cgid_data <- function(crossing = "full") {
  d <- expand.grid(Person = paste0("P", 1:4), Rater = c("R1", "R2"),
                   Criterion = c("C1", "C2"), stringsAsFactors = FALSE)
  if (crossing == "diagonal") d <- d[substr(d$Rater, 2, 2) == substr(d$Criterion, 2, 2), ]
  if (crossing == "three") d <- d[!(d$Rater == "R2" & d$Criterion == "C2"), ]
  d$School <- ifelse(d$Person %in% c("P1", "P2"), "A", "B")
  d$Score <- (match(d$Person, paste0("P", 1:4)) +
               match(d$Rater, c("R1", "R2")) + match(d$Criterion, c("C1", "C2"))) %% 3L
  rownames(d) <- NULL
  d
}

cgid_map <- function(data = cgid_data(), method = "JML", step = "Rater",
                     population_formula = if (method == "MML") ~1 else NULL,
                     product = FALSE) {
  if (product) {
    stopifnot(method == "MML", is.null(population_formula))
    return(mfrm_gmfrm_common_setup(data, 2L, c("Criterion", "Rater")))
  }
  stopifnot(method %in% c("JML", "MML"), method != "JML" || step == "Rater")
  prep <- prepare_mfrm_data(data, "Person", c("Rater", "Criterion"), "Score",
                            rating_min = 0, rating_max = 2, keep_original = TRUE)
  population <- prepare_mfrm_population_scaffold(data, "Person", population_formula,
    person_data = unique(data[c("Person", "School")]))
  built <- build_estimation_config(prep, "GPCM", method, step, "Rater",
    weight_col = NULL, facet_signs = c(Rater = -1, Criterion = -1),
    positive_facets = character(), noncenter_facet = "Person", dummy_facets = character(),
    anchor_df = NULL, group_anchor_df = NULL, population = population, centering_scope = "facet")
  list(prep = prep, idx = build_indices(prep, step, "Rater"),
       config = built$config, sizes = built$sizes)
}

cgid_index <- function(x, block) {
  end <- cumsum(unlist(x$sizes)); n <- x$sizes[[block]]
  if (n == 0L) integer() else seq.int(end[[block]] - n + 1L, end[[block]])
}

# Reconstruct slopes independently of expand_gpcm_log_slopes and its design.
cgid_slopes <- function(x, par) {
  free <- par[cgid_index(x, "log_slopes")]
  owners <- x$config$slope_facet
  levels <- x$config$facet_levels[owners]
  n1 <- length(levels[[1L]])
  log_first <- c(head(free, n1 - 1L), -sum(head(free, n1 - 1L)))
  values <- exp(log_first[as.integer(x$prep$data[[owners[1L]]])])
  if (length(owners) == 2L) {
    values <- values * exp(tail(free, length(levels[[2L]]))[
      as.integer(x$prep$data[[owners[2L]]])])
  }
  values
}

cgid_logits <- function(x, par, z = 0) cid_logits(x, par, z) * cgid_slopes(x, par)

cgid_jacobian <- function(fn, par, h = 1e-5) {
  base <- fn(par)
  vapply(seq_along(par), function(j) {
    hi <- lo <- par; hi[j] <- hi[j] + h; lo[j] <- lo[j] - h
    (fn(hi) - fn(lo)) / (2 * h)
  }, numeric(length(base)))
}

cgid_rank <- function(jacobian) {
  norms <- sqrt(colSums(jacobian^2)); norms[norms == 0] <- 1
  singular <- svd(sweep(jacobian, 2L, norms, "/"), nu = 0L, nv = 0L)$d
  list(rank = sum(singular > max(singular) * 1e-7), dimension = ncol(jacobian),
       singular_values = singular, column_norms = norms)
}

# Complete joint response-pattern law for each observed Person roster, not
# just the realized score vector. Bounded here to at most four 3-category rows.
cgid_patterns <- function(x, par, rule) {
  rosters <- split(seq_len(nrow(x$prep$data)), x$idx$person)
  stopifnot(all(lengths(rosters) <= 4L))
  patterns <- lapply(rosters, function(rows) as.matrix(expand.grid(
    rep(list(seq_len(x$config$n_cat)), length(rows)))))
  Reduce(`+`, lapply(seq_along(rule$nodes), function(q) {
    prob <- cid_probabilities(cgid_logits(x, par, rule$nodes[q]))
    values <- Map(function(rows, patterns) {
      joint <- rep(1, nrow(patterns))
      for (j in seq_along(rows)) joint <- joint * prob[cbind(rows[j], patterns[, j])]
      joint
    }, rosters, patterns)
    unlist(values, use.names = FALSE) * rule$weights[q]
  }))
}

cgid_nll <- function(x, par, rule = NULL) {
  rosters <- split(seq_len(nrow(x$prep$data)), x$idx$person)
  conditional <- function(z) {
    prob <- cid_probabilities(cgid_logits(x, par, z))
    observed <- prob[cbind(seq_len(nrow(prob)), x$idx$score_k + 1L)]
    vapply(rosters, function(rows) prod(observed[rows]), numeric(1))
  }
  if (x$config$method == "JML") return(-sum(log(conditional(0))))
  joint <- vapply(rule$nodes, conditional, numeric(length(rosters)))
  -sum(log(drop(joint %*% rule$weights)))
}

# Both parameter sets respect first-family GM1. Only the diagonal cell products
# are held fixed; this witness is not a supported fit to a disconnected design.
cgid_product_witness <- function(x, t) {
  stopifnot(length(x$config$slope_facet) == 2L,
            all(lengths(x$config$facet_levels[x$config$slope_facet]) == 2L))
  par <- numeric(sum(unlist(x$sizes)))
  par[cgid_index(x, "log_slopes")] <- c(t, .2 - t, -.2 + t)
  par
}

cgid_local <- function(x, nodes = 41L, h = 1e-5) {
  par <- .25 * sin(seq_len(sum(unlist(x$sizes))))
  rule <- cid_normal_rule(nodes)
  fn <- if (x$config$method == "JML") {
    function(p) as.vector(cgid_logits(x, p))
  } else function(p) cgid_patterns(x, p, rule)
  jacobian <- cgid_jacobian(fn, par, h)
  list(rank = cgid_rank(jacobian), par = par, values = fn(par), jacobian = jacobian,
    nodes = nodes, h = h,
    scope = if (x$config$method == "JML") "Local conditional adjacent-logit map" else
      "Local complete response-pattern law under normal quadrature; no global or finite-sample claim")
}
