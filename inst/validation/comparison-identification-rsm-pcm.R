# Bounded school-comparison qualification, not an installed comparison API.
# Source into an environment whose parent is asNamespace("mfrmr"). No fits,
# random data, or files are created by sourcing this file.

cid_data <- function(design = "full") {
  d <- expand.grid(Person = paste0("P", 1:8), Rater = paste0("R", 1:4),
                   Criterion = c("C1", "C2"), stringsAsFactors = FALSE)
  d$School <- ifelse(as.integer(sub("P", "", d$Person)) <= 4, "A", "B")
  if (design %in% c("missing", "repaired")) {
    d <- d[!(d$Rater == "R4" & d$School == "B") |
             (design == "repaired" & d$Person == "P5" & d$Criterion == "C1"), ]
  }
  if (design %in% c("separate", "bridge_A", "bridge_both", "neutral")) {
    shared <- switch(design, bridge_A = "P1", bridge_both = c("P1", "P5"),
                     character())
    d <- d[(d$Rater %in% c("R1", "R2")) == (d$School == "A") |
             d$Person %in% shared, ]
    if (design == "neutral") {
      extra <- expand.grid(Person = "P9", Rater = paste0("R", 1:4),
                           Criterion = c("C1", "C2"), stringsAsFactors = FALSE)
      extra$School <- "N"
      d <- rbind(d, extra)
    }
  }
  d$Score <- (match(d$Person, paste0("P", 1:9)) +
               match(d$Rater, paste0("R", 1:4)) +
               match(d$Criterion, c("C1", "C2"))) %% 3L
  rownames(d) <- NULL
  d
}

cid_map <- function(data, model = "RSM", method = "JML", interactions = TRUE,
                    population_formula = NULL, step_facet = "Criterion",
                    positive_facets = character(), anchors = NULL) {
  stopifnot(model %in% c("RSM", "PCM"), method %in% c("JML", "MML"))
  prep <- prepare_mfrm_data(data, "Person", c("Rater", "Criterion", "School"),
                            "Score", rating_min = 0, rating_max = 2, keep_original = TRUE)
  inter <- build_facet_interaction_specs(prep,
    if (interactions) "Rater:School" else NULL, interaction_policy = "silent")
  population <- prepare_mfrm_population_scaffold(data, "Person",
    population_formula = population_formula,
    person_data = unique(data[c("Person", "School")]))
  stopifnot(method == "MML" || !population$active)
  if (model == "RSM") step_facet <- NULL
  idx <- build_indices(prep, step_facet = step_facet, interaction_specs = inter)
  signs <- build_facet_signs(prep$facet_names, positive_facets)
  cfg <- build_estimation_config(prep, model, method,
    step_facet = step_facet, slope_facet = NULL, interaction_specs = inter,
    weight_col = NULL, facet_signs = signs$signs, positive_facets = positive_facets,
    noncenter_facet = "Person", dummy_facets = "School", anchor_df = anchors,
    group_anchor_df = NULL, population = population, centering_scope = "facet")
  adjacent <- mfrmr_estimability_adjacent_design(prep, idx, cfg$config, cfg$sizes)
  list(data = data, prep = prep, idx = idx, config = cfg$config,
       sizes = cfg$sizes, design = adjacent$design, map = adjacent$map)
}

# Direct expansion of the declared response equation, independently of the
# sparse audit Jacobians, compute_eta(), and package probability helpers.
cid_logits <- function(x, par, z = 0) {
  p <- expand_params(par, x$sizes, x$config)
  d <- x$prep$data
  theta <- if (x$config$method == "JML") p$theta[as.integer(d$Person)] else {
    pop <- x$config$population_spec
    if (pop$active) {
      mu <- drop(pop$design_matrix %*% p$population$coefficients)
      mu[pop$person_lookup[as.integer(d$Person)]] + sqrt(p$population$sigma2) * z
    } else rep(z, nrow(d))
  }
  eta <- theta
  for (f in x$config$facet_names) {
    eta <- eta + x$config$facet_signs[[f]] * p$facets[[f]][as.integer(d[[f]])]
  }
  if (length(p$interactions)) {
    gamma <- p$interactions[["Rater:School"]]
    eta <- eta + gamma[cbind(as.integer(d$Rater), as.integer(d$School))]
  }
  steps <- if (x$config$model == "RSM") {
    matrix(p$steps, nrow(d), length(p$steps), byrow = TRUE)
  } else p$steps_mat[as.integer(d[[x$config$step_facet]]), , drop = FALSE]
  eta - steps
}

cid_probabilities <- function(logits) {
  logp <- cbind(0, t(apply(logits, 1L, cumsum)))
  p <- exp(logp - apply(logp, 1L, max))
  p / rowSums(p)
}

cid_targets <- function(x, par) {
  p <- expand_params(par, x$sizes, x$config)
  out <- c(severity_R1_minus_R2 = unname(p$facets$Rater["R1"] - p$facets$Rater["R2"]))
  if (length(p$interactions)) {
    gamma <- p$interactions[["Rater:School"]]
    ab <- gamma[, "A"] - gamma[, "B"]
    out <- c(out, stats::setNames(unname(ab), paste0("relative_DFF_", names(ab))),
      DFF_R1_minus_R2 = unname(ab["R1"] - ab["R2"]),
      matched_panel_A_R1_minus_R2 = unname(
        x$config$facet_signs[["Rater"]] * (p$facets$Rater["R1"] - p$facets$Rater["R2"]) +
          gamma["R1", "A"] - gamma["R2", "A"]))
    step <- function(rater) {
      if (x$config$model == "RSM") return(p$steps)
      level <- switch(x$config$step_facet, Rater = rater, Criterion = "C1", School = "A")
      p$steps_mat[match(level, x$config$facet_levels[[x$config$step_facet]]), ]
    }
    adjacent <- out[["matched_panel_A_R1_minus_R2"]] - step("R1") + step("R2")
    out <- c(out, stats::setNames(unname(adjacent), paste0("adjacent_A_R1_minus_R2_step", seq_along(adjacent))))
  }
  persons <- unique(x$prep$data[c("Person", "School")])
  if (x$config$method == "JML") {
    theta <- p$theta[as.integer(persons$Person)]
    out <- c(out, finite_cohort_A_minus_B =
      mean(theta[persons$School == "A"]) - mean(theta[persons$School == "B"]))
  } else if (x$config$population_spec$active) {
    pop <- x$config$population_spec
    mu <- drop(pop$design_matrix %*% p$population$coefficients)
    mu <- mu[pop$person_lookup[as.integer(persons$Person)]]
    out <- c(out, population_A_minus_B =
      mean(mu[persons$School == "A"]) - mean(mu[persons$School == "B"]))
  }
  out
}

cid_linear_maps <- function(x) {
  zero <- numeric(sum(unlist(x$sizes)))
  index <- x$map$OptimizerIndex
  base <- as.vector(cid_logits(x, zero))
  offset <- cid_targets(x, zero)
  design <- vapply(index, function(j) {
    p <- zero; p[j] <- 1
    as.vector(cid_logits(x, p)) - base
  }, base)
  targets <- vapply(index, function(j) {
    p <- zero; p[j] <- 1
    cid_targets(x, p) - offset
  }, offset)
  colnames(design) <- colnames(targets) <- x$map$Coordinate
  list(design = design, targets = targets, offset = offset, zero = zero)
}

cid_target_audit <- function(design, targets) {
  design <- as.matrix(design)
  stopifnot(ncol(design) == ncol(targets), all(is.finite(design)), all(is.finite(targets)))
  norms <- sqrt(colSums(design^2)); norms[norms == 0] <- 1
  scaled <- sweep(design, 2L, norms, "/")
  scaled_targets <- sweep(targets, 2L, norms, "/")
  # Use the whole null space; the production diagnostic display is truncated.
  sv <- svd(scaled, nu = 0L, nv = ncol(scaled))
  rank <- sum(sv$d > 1e-10 * max(sv$d))
  null <- if (rank < ncol(scaled)) sv$v[, seq.int(rank + 1L, ncol(scaled)), drop = FALSE] else {
    matrix(numeric(), ncol(scaled), 0L)
  }
  null_fraction <- sqrt(rowSums((scaled_targets %*% null)^2)) /
    pmax(sqrt(rowSums(scaled_targets^2)), .Machine$double.eps)
  identified <- null_fraction < 1e-9
  # Independently test row-space membership by augmented QR, including every
  # coordinate. Normalize only the appended row, leaving its span unchanged.
  qr_rank <- function(m) qr(m, tol = 1e-10, LAPACK = FALSE)$rank
  qr_identified <- apply(scaled_targets, 1L, function(c) {
    c <- c / max(sqrt(sum(c^2)), .Machine$double.eps)
    qr_rank(rbind(scaled, c)) == qr_rank(scaled)
  })
  stopifnot(identical(unname(identified), unname(qr_identified)))
  coordinates <- colnames(targets) %||% paste0("coordinate", seq_len(ncol(design)))
  native <- mfrmr_estimability_rank_audit(design,
    data.frame(Coordinate = coordinates, Block = rep("declared", ncol(design))))
  stopifnot(rank == native$Rank, !native$ToleranceSensitive)
  list(table = data.frame(Target = rownames(targets),
    State = ifelse(!identified, "target_unidentified",
      if (rank == ncol(design)) "all_parameters_identified" else "target_identified_only"),
    NullFraction = unname(null_fraction), stringsAsFactors = FALSE),
    rank = rank, dimension = ncol(design),
    null_basis = sweep(null, 1L, norms, "/"),
    scope = "Declared linear adjacent-logit map; not a marginal/global MML certificate")
}

cid_witness <- function(x, maps, audit, target) {
  c <- maps$targets[target, ]
  direction <- drop(audit$null_basis %*% crossprod(audit$null_basis, c))
  direction <- direction / sum(c * direction)
  plus <- minus <- maps$zero
  plus[x$map$OptimizerIndex] <- direction * (0.5 - maps$offset[target])
  minus[x$map$OptimizerIndex] <- direction * (-0.5 - maps$offset[target])
  probability_difference <- max(abs(cid_probabilities(cid_logits(x, plus)) -
                                    cid_probabilities(cid_logits(x, minus))))
  stopifnot(probability_difference < 1e-12,
    abs(cid_targets(x, plus)[target] - .5) < 1e-10,
    abs(cid_targets(x, minus)[target] + .5) < 1e-10)
  list(target = target, plus = plus, minus = minus,
       probability_difference = probability_difference)
}

# Independent standard-normal quadrature (Golub-Welsch), not the package's
# integration backend. Derivatives below certify only a bounded local map.
cid_normal_rule <- function(n) {
  jacobi <- matrix(0, n, n)
  jacobi[cbind(1:(n-1), 2:n)] <- sqrt(1:(n-1))
  jacobi <- jacobi + t(jacobi)
  e <- eigen(jacobi, symmetric = TRUE)
  list(nodes = e$values, weights = e$vectors[1, ]^2)
}

cid_marginal_patterns <- function(x, par, rule) {
  # All single-response margins and two-response joint probabilities are
  # marginals of the full observed response law, retaining repeated Persons.
  rosters <- split(seq_len(nrow(x$prep$data)), x$idx$person)
  rosters <- rosters[!duplicated(vapply(rosters, function(rows) {
    paste(x$idx$facets$Rater[rows], x$idx$facets$Criterion[rows],
          x$idx$facets$School[rows], collapse = ":")
  }, character(1)))]
  lapply_result <- lapply(seq_along(rule$nodes), function(q) {
    prob <- cid_probabilities(cid_logits(x, par, rule$nodes[q]))
    values <- lapply(rosters, function(rows) {
      singles <- as.vector(prob[rows, 1:2, drop = FALSE])
      pairs <- combn(rows, 2L)
      joint <- unlist(lapply(seq_len(ncol(pairs)), function(j) {
        as.vector(outer(prob[pairs[1,j], 1:2], prob[pairs[2,j], 1:2]))
      }), use.names = FALSE)
      c(singles, joint)
    })
    unlist(values, use.names = FALSE) * rule$weights[q]
  })
  Reduce(`+`, lapply_result)
}

cid_marginal_local <- function(x, nodes = 41L, h = 1e-5) {
  stopifnot(x$config$method == "MML")
  par <- seq_len(sum(unlist(x$sizes))) / 50 - .15
  rule <- cid_normal_rule(nodes)
  fn <- function(p) cid_marginal_patterns(x, p, rule)
  jacobian <- vapply(seq_along(par), function(j) {
    p <- m <- par; p[j] <- p[j] + h; m[j] <- m[j] - h
    (fn(p) - fn(m)) / (2 * h)
  }, fn(par))
  norms <- sqrt(colSums(jacobian^2)); norms[norms == 0] <- 1
  singular <- svd(sweep(jacobian, 2L, norms, "/"), nu = 0L, nv = 0L)$d
  list(rank = sum(singular > max(singular) * 1e-7), dimension = length(par),
       singular_values = singular, par = par, nodes = nodes, h = h,
       values = fn(par), jacobian = jacobian,
       scope = "Numerical local rank of observed univariate/bivariate marginal probabilities; no global or finite-sample guarantee")
}

cid_observed_marginal_nll <- function(x, par, rule) {
  rosters <- split(seq_len(nrow(x$prep$data)), x$idx$person)
  conditional <- vapply(rule$nodes, function(z) {
    prob <- cid_probabilities(cid_logits(x, par, z))
    observed <- prob[cbind(seq_len(nrow(prob)), x$idx$score_k + 1L)]
    vapply(rosters, function(rows) prod(observed[rows]), numeric(1))
  }, numeric(length(rosters)))
  -sum(log(drop(conditional %*% rule$weights)))
}

cid_run <- function() {
  records <- list()
  for (model in c("RSM", "PCM")) for (method in c("JML", "MML")) {
    for (design in c("full", "missing", "repaired", "separate", "bridge_A", "bridge_both", "neutral")) {
      x <- cid_map(cid_data(design), model, method)
      maps <- cid_linear_maps(x)
      stopifnot(max(abs(as.matrix(x$design) - maps$design)) < 1e-14)
      audit <- cid_target_audit(x$design, maps$targets)
      probe <- seq_along(maps$zero) / 20 - .2
      probabilities <- cid_probabilities(cid_logits(x, probe))
      if (method == "JML") {
        direct_ll <- -sum(log(probabilities[cbind(seq_len(nrow(probabilities)), x$idx$score_k + 1L)]))
        stopifnot(abs(direct_ll - mfrm_loglik_jml(probe, x$idx, x$config, x$sizes)) < 1e-10)
      }
      witness <- if (audit$table$State[audit$table$Target == "relative_DFF_R1"] == "target_unidentified") {
        cid_witness(x, maps, audit, "relative_DFF_R1")
      } else NULL
      key <- paste(model, method, design, sep = "/")
      records[[key]] <- list(map = x, targets = maps, audit = audit, witness = witness)
    }
  }
  table <- do.call(rbind, lapply(names(records), function(name) {
    x <- records[[name]]
    data.frame(Configuration = name, Rank = x$audit$rank,
               Dimension = x$audit$dimension, x$audit$table)
  }))
  rownames(table) <- NULL
  list(records = records, table = table, session = sessionInfo())
}
