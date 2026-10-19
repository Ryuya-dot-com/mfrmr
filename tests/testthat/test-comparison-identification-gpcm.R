# Source-tree qualification only; no partial-fit or comparison-review API.
cgid <- new.env(parent = asNamespace("mfrmr"))
for (file in c("comparison-identification-rsm-pcm.R", "comparison-identification-gpcm.R")) {
  sys.source(test_path("..", "..", "inst", "validation", file), cgid)
}

test_that("additive rank does not certify GPCM slope identification", {
  x <- cgid$cgid_map()
  p <- .25 * sin(seq_len(sum(unlist(x$sizes))))
  native <- mfrmr_gpcm_response_kernel_design(x$prep, x$idx, x$config, x$sizes, p)
  independent <- cgid$cgid_jacobian(function(par) as.vector(cgid$cgid_logits(x, par)), p)
  expect_lt(max(abs(as.matrix(native$jacobian) - independent)), 1e-8)
  expect_equal(cgid$cgid_rank(independent)$rank, length(p))
  p[] <- 0
  singular <- mfrmr_gpcm_response_kernel_design(x$prep, x$idx, x$config, x$sizes, p)
  additive <- mfrmr_estimability_adjacent_design(x$prep, x$idx, x$config, x$sizes)
  expect_equal(qr(as.matrix(additive$design))$rank, ncol(additive$design))
  expect_equal(cgid$cgid_rank(as.matrix(singular$jacobian))$rank, length(p) - 1L)
  plus <- minus <- p
  plus[cgid$cgid_index(x, "log_slopes")] <- .6
  minus[cgid$cgid_index(x, "log_slopes")] <- -.6
  expect_equal(cgid$cid_probabilities(cgid$cgid_logits(x, plus)),
               cgid$cid_probabilities(cgid$cgid_logits(x, minus)), tolerance = 0)
  expect_equal(mfrm_loglik_jml(plus, x$idx, x$config, x$sizes),
               mfrm_loglik_jml(minus, x$idx, x$config, x$sizes), tolerance = 0)
})

test_that("the free scale symmetry lies outside the declared GM1 constraint", {
  for (method in c("JML", "MML")) {
    x <- cgid$cgid_map(method = method)
    p <- .25 * sin(seq_len(sum(unlist(x$sizes))))
    q <- p
    scaled <- setdiff(names(x$sizes), c("log_slopes", "log_sigma2"))
    for (block in scaled) q[cgid$cgid_index(x, block)] <- 2 * p[cgid$cgid_index(x, block)]
    if (method == "MML") q[cgid$cgid_index(x, "log_sigma2")] <-
      p[cgid$cgid_index(x, "log_sigma2")] + 2 * log(2)
    slopes <- cgid$cgid_slopes(x, p)
    expect_equal(exp(mean(log(slopes))), 1, tolerance = 1e-14)
    expect_equal(exp(mean(log(slopes / 2))), .5, tolerance = 1e-14)
    for (z in c(-2, 0, 2)) {
      expect_equal(cgid$cgid_logits(x, p, z),
        cgid$cid_logits(x, q, z) * (slopes / 2), tolerance = 1e-13)
      expect_gt(max(abs(cgid$cgid_logits(x, p, z) - cgid$cgid_logits(x, q, z))), .01)
    }
  }
})

test_that("a positive location contrast need not fix the response-curve direction", {
  x <- cgid$cgid_map()
  p <- numeric(sum(unlist(x$sizes)))
  p[cgid$cgid_index(x, "Rater")] <- .2
  p[cgid$cgid_index(x, "log_slopes")] <- log(sqrt(2))
  rows <- which(x$prep$data$Person == "P1" & x$prep$data$Criterion == "C1")
  rows <- rows[match(c("R1", "R2"), as.character(x$prep$data$Rater[rows]))]
  # a1(theta-.2) - a2(theta+.2) changes sign exactly at theta=.6.
  differences <- vapply(c(-2, .6, 2), function(theta) {
    p[cgid$cgid_index(x, "theta")] <- theta
    prob <- cgid$cid_probabilities(cgid$cgid_logits(x, p))
    drop((prob[rows[1], ] - prob[rows[2], ]) %*% 0:2)
  }, numeric(1))
  expect_lt(differences[1], 0)
  expect_equal(differences[2], 0, tolerance = 1e-14)
  expect_gt(differences[3], 0)
  expect_equal(expand_params(p, x$sizes, x$config)$facets$Rater[[1]] -
                 expand_params(p, x$sizes, x$config)$facets$Rater[[2]], .4)
})

test_that("observed products and components have different identification requirements", {
  x <- cgid$cgid_map(method = "MML", population_formula = NULL, product = TRUE)
  plus <- cgid$cgid_product_witness(x, .6)
  minus <- cgid$cgid_product_witness(x, -.6)
  rows <- as.integer(x$prep$data$Criterion) == as.integer(x$prep$data$Rater)
  difference <- plus - minus
  targets <- mfrm_gpcm_product_slope_targets(plus, x$config)
  other <- mfrm_gpcm_product_slope_targets(minus, x$config)
  diagonal <- targets$effective$metadata$Criterion == "C1" & targets$effective$metadata$Rater == "R1" |
    targets$effective$metadata$Criterion == "C2" & targets$effective$metadata$Rater == "R2"
  expect_equal(drop(targets$effective$jacobian[diagonal, ] %*% difference), c(0, 0), tolerance = 1e-14)
  expect_gt(targets$components$value[1] - targets$components$value[2], 0)
  expect_lt(other$components$value[1] - other$components$value[2], 0)
  expect_gt(max(abs(targets$effective$value[!diagonal] - other$effective$value[!diagonal])), 1)
  for (z in c(-3, -.7, 0, .8, 3)) {
    a <- cgid$cid_probabilities(cgid$cgid_logits(x, plus, z))
    b <- cgid$cid_probabilities(cgid$cgid_logits(x, minus, z))
    expect_equal(a[rows, ], b[rows, ], tolerance = 1e-14)
  }
  expect_equal(qr(as.matrix(x$config$gpcm_spec$log_slope_design)[diagonal, ])$rank, 2)
  expect_equal(qr(as.matrix(x$config$gpcm_spec$log_slope_design))$rank, 3)
  three <- cgid$cgid_map(cgid$cgid_data("three"), method = "MML", population_formula = NULL, product = TRUE)
  expect_equal(qr(as.matrix(three$config$gpcm_spec$log_slope_design))$rank, 3)
  # The missing C2:R2 product is inferred from separability, not observed.
  products <- setNames(targets$effective$estimate,
    paste(targets$effective$metadata$Criterion, targets$effective$metadata$Rater))
  expect_equal(unname(products["C2 R2"]),
    unname(products["C1 R2"] * products["C2 R1"] / products["C1 R1"]), tolerance = 1e-14)
  # Relabeling/reordering preserves owner roles and native target mapping.
  d <- cgid$cgid_data(); d <- d[rev(seq_len(nrow(d))), ]
  names(d)[names(d) == "Criterion"] <- "Task"
  renamed <- mfrm_gmfrm_common_setup(d, 2L, c("Task", "Rater"))
  rt <- mfrm_gpcm_product_slope_targets(plus, renamed$config)
  expect_equal(rt$components$value, targets$components$value, tolerance = 0)
  expect_equal(rt$effective$value, targets$effective$value, tolerance = 0)
  effective_row <- match(paste(x$prep$data$Criterion, x$prep$data$Rater),
    paste(targets$effective$metadata$Criterion, targets$effective$metadata$Rater))
  expect_equal(cgid$cgid_slopes(x, plus), targets$effective$estimate[effective_row], tolerance = 1e-14)
})

test_that("comparison qualification does not bypass unsupported GPCM fit routes", {
  diagonal <- cgid$cgid_data("diagonal")
  extra <- diagonal; extra$Person <- sub("P", "Q", extra$Person)
  args <- list(data = rbind(diagonal, extra), person = "Person",
    facets = c("Criterion", "Rater"), score = "Score", model = "GPCM", method = "MML",
    step_facet = "Rater", slope_facet = c("Criterion", "Rater"), noncenter_facet = "Rater",
    gpcm_mml_identification = "fixed_standard_normal", mml_engine = "em", mml_integration = "fixed",
    rating_min = 0, rating_max = 2)
  expect_error(do.call(fit_mfrm, args), "Facet crossings do not identify both slope families", fixed = TRUE)
  args$method <- "JML"
  expect_error(do.call(fit_mfrm, args), "Two slope families require", fixed = TRUE)
  expect_error(fit_mfrm(cgid$cgid_data(), person = "Person", facets = c("Rater", "Criterion"),
    score = "Score", model = "GPCM", method = "JML", slope_facet = "Rater", step_facet = "Criterion"),
    "Separate GPCM slope and step owners require MML", fixed = TRUE)
})
