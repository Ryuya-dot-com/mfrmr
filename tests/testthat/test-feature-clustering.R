test_that("feature review preserves entity identity, types, and missing reasons", {
  input <- data.frame(
    Rater = c("R|1", "R2", "R3"), Experience = c(NA, 2, 3),
    Specialty = c("Language", NA, "Science"),
    Training = ordered(c("low", "high", NA), levels = c("low", "medium", "high")),
    Certified = c(TRUE, FALSE, NA), Unselected = c(NA, NA, NA)
  )
  reasons <- data.frame(ID = c("R|1", "R2"),
    Feature = c("Experience", "Specialty"), Reason = c("Not collected", "Not applicable"))
  x <- mfrm_features(input, "Rater", c("Experience", "Specialty", "Training", "Certified"), reasons)
  expect_identical(x$data$Rater, input$Rater)
  expect_identical(x$data$Experience, input$Experience)
  expect_identical(levels(x$data$Training), levels(input$Training))
  expect_identical(x$feature_summary$Type, c("Numeric", "Nominal", "Ordinal", "Symmetric binary"))
  expect_equal(x$feature_summary$Missing, rep(1, 4))
  expect_equal(x$row_summary$MissingFeatures, c(1, 1, 2))
  expect_equal(nrow(x$missing), 4L)
  expect_identical(x$missing$Reason, c("Not collected", "Not applicable", "Not supplied", "Not supplied"))
  expect_equal(summary(x), x$feature_summary)
  expect_output(print(x), "no imputation is performed")
  expect_error(mfrm_features(input[c(1, 1), ], "Rater", "Experience"), "unique")
  expect_error(mfrm_features(input, "Rater", "Rater"), "excluding")
  expect_error(mfrm_features(input, "Rater", c("Experience", "Experience")), "distinct")
  reasons$Feature[1] <- "Training"
  expect_error(mfrm_features(input, "Rater", c("Experience", "Training"), reasons), "missing cells")
  reasons <- data.frame(ID = "R|1", Feature = "Experience", Reason = "Not collected")
  expect_error(mfrm_features(input, "Rater", "Experience", rbind(reasons, reasons)), "unique per")
  input$Experience[1] <- Inf
  expect_error(mfrm_features(input, "Rater", "Experience"), "infinite")
  input$Specialty[1] <- " "
  expect_error(mfrm_features(input, "Rater", "Specialty"), "blank")
  input$Date <- as.Date("2026-01-01") + 0:2
  expect_error(mfrm_features(input, "Rater", "Date"), "unsupported type")
  input$Complex <- 1:3 + 1i
  expect_error(mfrm_features(input, "Rater", "Complex"), "unsupported type")
})

test_that("mixed-feature groups retain ID mapping, separation, and profiles", {
  skip_if_not_installed("cluster")
  input <- data.frame(Rater = c("z", "a", "é", "R|4", "R5", "R6"),
    Experience = c(1, 2, 3, 12, 13, 14),
    Specialty = rep(c("Language", "Science"), each = 3),
    Certified = rep(c(FALSE, TRUE), each = 3))
  x <- mfrm_features(input, "Rater", c("Experience", "Specialty", "Certified"))
  groups <- mfrm_cluster(x, 2, weights = c(Certified = 1, Specialty = 2, Experience = 3))
  expect_identical(groups$membership$ID, input$Rater)
  expect_equal(outer(groups$membership$Cluster, groups$membership$Cluster, "=="),
               outer(rep(1:2, each = 3), rep(1:2, each = 3), "=="))
  # Hand-derived distances: within-group difference / 13 * 3/6;
  # across-group differences additionally have nominal/binary contributions 3/6.
  distances <- abs(outer(input$Experience, input$Experience, "-")) / 26 +
    outer(input$Specialty, input$Specialty, "!=") / 2
  expected_silhouette <- cluster::silhouette(groups$membership$Cluster, stats::as.dist(distances))[, "sil_width"]
  expect_equal(groups$membership$Silhouette, unname(expected_silhouette), tolerance = 1e-12)
  expect_setequal(groups$medoids$Rater, c("a", "R5"))
  expect_setequal(groups$membership$ID[groups$membership$Medoid], groups$medoids$Rater)
  expect_equal(groups$cluster_summary$N, c(3L, 3L))
  expect_equal(sort(groups$profiles$numeric$Mean), c(2, 13))
  expect_true(all(tapply(groups$profiles$categorical$Proportion,
    list(groups$profiles$categorical$Cluster, groups$profiles$categorical$Feature), sum) == 1))
  expect_identical(groups$settings$weights, c(Experience = 3, Specialty = 2, Certified = 1))
  expect_equal(groups$settings$numeric_ranges$Minimum, 1)
  expect_equal(groups$settings$numeric_ranges$Maximum, 14)
  expect_equal(summary(groups), groups$cluster_summary)
  expect_output(print(groups), "stability is not assessed")
  scaled <- mfrm_cluster(x, 2, weights = c(Experience = 3e307, Specialty = 2e307, Certified = 1e307))
  expect_equal(scaled$membership, groups$membership)
  expect_identical(x$data$Rater, input$Rater)
})

test_that("missing features require an explicit policy and excluded IDs remain visible", {
  skip_if_not_installed("cluster")
  input <- data.frame(Person = 1:6, A = c(NA, 2, 3, 12, 13, 14), B = c(NA, 1, 1, 2, 2, 2))
  x <- mfrm_features(input, "Person", c("A", "B"),
    data.frame(ID = 1, Feature = "A", Reason = "Not measured"))
  expect_error(mfrm_cluster(x, 2), "missing values")
  out <- mfrm_cluster(x, 2, missing = "omit")
  expect_identical(out$membership$ID, as.character(input$Person))
  expect_true(all(is.na(out$membership[1, c("Cluster", "Medoid", "Silhouette")])))
  expect_equal(out$settings$included, 5)
  expect_equal(out$settings$excluded, 1)
  expect_identical(out$feature_data$missing, x$missing)
  expect_equal(out$settings$numeric_ranges$Minimum, c(2, 1))
  expect_equal(sum(out$cluster_summary$N), 5)
  expect_equal(names(out$profiles$categorical), c("Cluster", "Feature", "Level", "N", "Proportion"))
  expect_equal(nrow(out$profiles$categorical), 0L)
  # A stale cached review must not override an edited missing cell.
  x$data$A[2] <- NA_real_
  expect_error(mfrm_cluster(x, 2), "missing values")
})

test_that("unusable features and clustering requests are refused before fitting", {
  skip_if_not_installed("cluster")
  x <- mfrm_features(data.frame(ID = letters[1:4], A = c(0, 0, 1, 1)), "ID", "A")
  expect_error(mfrm_cluster(x, 1), "integer from 2")
  expect_error(mfrm_cluster(x, 2.5), "integer from 2")
  expect_error(mfrm_cluster(x, 2 + 1i), "integer from 2")
  expect_error(mfrm_cluster(x, 4), "integer from 2")
  expect_error(mfrm_cluster(x, 3), "distinct included")
  expect_error(mfrm_cluster(x, 2, weights = 1), "named")
  expect_error(mfrm_cluster(x, 2, weights = c(A = 0)), "positive finite")
  expect_error(mfrm_cluster(x, 2, weights = c(B = 1)), "covering")
  expect_error(mfrm_cluster(x, 2, weights = c(A = 1 + 1i)), "positive finite")
  constant <- mfrm_features(data.frame(ID = 1:4, A = rep(1, 4)), "ID", "A")
  expect_error(mfrm_cluster(constant, 2), "must vary")
  empty <- mfrm_features(data.frame(ID = 1:4, A = rep(NA_real_, 4)), "ID", "A")
  expect_equal(empty$feature_summary$Distinct, 0)
  expect_error(mfrm_cluster(empty, 2, missing = "omit"), "included entities")
  large <- mfrm_features(data.frame(ID = 1:5001, A = 1:5001), "ID", "A")
  expect_error(mfrm_cluster(large, 2), "5,000")
  nominal <- mfrm_features(data.frame(ID = letters[1:4], A = c("a", "a", "b", "b")), "ID", "A")
  out <- mfrm_cluster(nominal, 2)
  expect_equal(nrow(out$profiles$numeric), 0)
  expect_equal(names(out$profiles$numeric), c("Cluster", "Feature", "N", "Mean", "Median", "SD"))
})
