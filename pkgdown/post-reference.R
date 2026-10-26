# pkgdown runs this documented hook in the generated reference directory.
# Example plots have no native alt-text option; see
# https://pkgdown.r-lib.org/articles/accessibility.html
# Keep descriptions in example order and review them when examples change.
local({
  wright <- paste(
    "Wright map with a Person histogram beside rater and criterion locations",
    "and shared category steps on the logit scale. Facet whiskers show",
    "approximate normal intervals; higher facet locations mean stricter scoring.")
  curves <- paste(
    "Four category-probability curves across the ability scale, distinguished",
    "by color and line pattern. Low categories dominate at lower abilities",
    "and high categories at higher abilities for the reference facet profile.")
  qc <- paste(
    "Nine diagnostic panels: category counts, Infit versus Outfit, ZSTD,",
    "unexpected responses, observed minus fair averages, displacement,",
    "pairwise agreement, facet chi-square and separation. These are review",
    "aids; high rater separation does not mean agreement between raters.")
  marginal <- paste(
    "Standardized observed-minus-expected category-frequency residuals by",
    "facet level, using marginal model probabilities. Bars above zero mean",
    "more observations than expected; bars below zero mean fewer.")
  silhouette <- paste(
    "Silhouette widths for six raters in two descriptive feature groups.",
    "All widths are positive and near one; the dashed line is their mean.",
    "The groups describe features, not rater quality.")
  experience <- paste(
    "Mean and median experience in years by descriptive group, with three",
    "raters per group. Both summaries are 2 years for group 1 and 13 for",
    "group 2. No uncertainty intervals are shown.")
  components <- paste(
    "Variance components for the equally weighted V and W composite:",
    "Person, Task, and Person by Task plus residual. The combined interaction",
    "and residual component is largest. Segments start at zero and are not",
    "confidence intervals.")
  component_intervals <- paste(
    "Variance components for the equally weighted V and W composite:",
    "Person, Task, and Person by Task plus residual, with pointwise 95 percent",
    "normal-model intervals. Bars use approximate Ting MLS for Person and Task",
    "and chi-square for the combined residual. These are uncertainty in source",
    "variances, not measurement SEM or simultaneous intervals.")
  difference_sem <- paste(
    "Relative and absolute SEM for the difference W minus V decrease as",
    "the number of tasks increases. Values are in difference-score units",
    "and condition on the estimated variance components.")
  difference_reliability <- paste(
    "G for relative ordering and Phi for absolute score levels of W minus V",
    "increase with the number of tasks. These projections condition on the",
    "estimated variance components; no uncertainty intervals are shown.")
  v_reliability <- paste(
    "G and Phi for the original score V increase with the number of tasks.",
    "These projections concern V, not the difference W minus V, and condition",
    "on the estimated variance components.")
  equal_reliability <- paste(
    "G and Phi for the equally weighted V and W composite increase with",
    "the number of tasks. The composite weights are 0.5 and 0.5; projections",
    "condition on the estimated variance components.")
  d_study <- c(difference_reliability, difference_sem, v_reliability,
    paste("Phi for V and W across 3, 6 and 12 tasks. Both curves rise but",
      "remain below the displayed 0.8 reference, an illustrative user",
      "criterion rather than a recommended cutoff. Shaded ribbons show",
      "nominal 95% generalized confidence intervals under independent normal",
      "effects; these do not guarantee exact coverage or simultaneous coverage across scores."))

  descriptions <- list(
    plot.mfrm_facets_results = c(paste(
      "Reported FACETS measures for six synthetic Persons. Downward and upward",
      "triangles mark extreme-score adjustments, a square marks a direct/group",
      "anchor flag whose subtype is not determined by the import,",
      "and circles mark estimated measures. No confidence intervals are shown."),
      paste("Four reported FACETS category-probability curves for Scale 1 of a",
        "synthetic PCM analysis. The horizontal axis retains Graphfile measure",
        "coordinates; the legend preserves categories 0, 1, 2 and 3.",
        "Lines join exported points. No confidence intervals are shown.")),
    plot.mfrm_bias_collection = c(
      paste("Signed conditional bias shifts for all retained Rater by Criterion",
        "cells. The pair label reports screening availability and the range of",
        "observed row counts per cell. Filled circles have usable screening",
        "statistics; the zero line means no conditional shift, not a significance threshold."),
      paste("Ranked conditional bias estimates for Rater by Criterion cells.",
        "The display helps select patterns for closer review; calibration and",
        "Person uncertainty are held fixed and no collection-wide multiplicity",
        "control or confirmatory unfairness decision is supplied.")),
    confint.mfrm_multivariate_d_study = paste(
      "A single forest plot compares default approximate MLS null inversion,",
      "experimental approximate F and conservative mean-square-region intervals",
      "for Phi under two future rating plans.",
      "Plans are grouped vertically, with adjacent method intervals on one shared axis.",
      "All three methods share the same point estimate. Intervals assume independent",
      "normal effects; the comparison does not establish robust coverage."),
    plot.mfrm_dstudy_intervals = paste(
      "A single forest plot shows normal-model exact F intervals for G with six",
      "and twelve future common tasks on separate rows. Both use uncertainty from the",
      "same source study; adding future tasks does not add source information."),
    plot_marginal_pairwise = c(
      paste("Standardized residuals for exact agreement between pairs of",
        "raters or criteria. R04 versus R05 exceeds the displayed upper",
        "review threshold; this is a diagnostic flag, not proof of dependence."),
      paste("Standardized residuals for agreement within one category between",
        "pairs of raters or criteria. Positive bars mean more agreement than",
        "the marginal model expects; no displayed pair crosses the review rule.")),
    rating_scale_table = paste(
      "Observed counts for four score categories with model-expected counts",
      "overlaid as connected open circles. Category 2 is most frequent and",
      "category 4 least frequent; observed and expected counts are close."),
    plot.mfrm_clusters = c(silhouette, experience,
      paste("Specialty proportions within two groups of three raters:",
        "group 1 is entirely Language and group 2 entirely Science.",
        "These are descriptive feature groups, not quality classifications.")),
    plot.mfrm_fit = c(wright,
      paste("Signed severity estimates for six raters. R06 has the highest",
        "and R01 the lowest estimate. Positive values mean stricter scoring",
        "relative to the fitted reference; no intervals are drawn."), curves),
    score_mfrm_random_rater = paste(
      "Conditional EAP estimates and equal-tail intervals for Persons P001",
      "and P002 under the shared-rater model. The full source roster informs",
      "both estimates; calibration is held fixed. These are not intervals",
      "for the difference between Persons."),
    plot_qc_dashboard = qc,
    mfrm_multivariate_d_compare = c(
      paste("G and Phi for three plans with 12 ratings each: 2 raters by",
        "6 tasks, 3 by 4, and 4 by 3. A diamond marks the first plan as",
        "reference; the comparison plans have slightly higher coefficients."),
      paste("Relative and absolute SEM for the same three 12-rating plans.",
        "The 2-rater, 6-task reference has slightly larger errors than the",
        "other plans. These are point estimates in score units."),
      paste("Paired differences in G and Phi from the 2-rater, 6-task",
        "reference, with approximate pointwise normal-theory intervals.",
        "G intervals lie above zero; Phi intervals cross zero.")),
    mfrm_results = wright,
    predict_mfrm_units = paste(
      "Posterior EAPs and 95 percent conditional intervals for NEW01 and",
      "NEW02, each shown under alternative and retained priors. The",
      "intervals condition on calibration and the chosen prior, illustrating",
      "prior sensitivity rather than calibration uncertainty."),
    plot_person_fit = paste(
      "Person Infit against Outfit mean squares. Reference lines mark one",
      "and the displayed review band; several Persons have unusually high",
      "or low values. Flags prompt contextual review, not automatic exclusion."),
    fit_mfrm_random_rater = paste(
      "Conditional-mode severity estimates for four observed raters under",
      "the shared random-rater model. R02 is lowest and R04 highest; positive",
      "values indicate stricter ratings. No intervals or quality flags are shown."),
    plot_marginal_fit = c(marginal,
      paste("Observed-minus-expected category proportions by facet level,",
        "using marginal model probabilities. Small bars on either side of",
        "zero show discrepancies on the proportion scale, not standardized",
        "residuals or significance tests.")),
    mfrm_screening_sensitivity = paste(
      "Overfit family false-flag rates for Broad and Narrow threshold",
      "profiles under a null condition. Both show 33.3 percent among three",
      "known outcomes out of four planned trials; the unresolved trial is",
      "not counted as a non-flag."),
    mfrm_cluster_hierarchical = c(
      paste("Average-linkage dendrogram from Gower dissimilarities for six",
        "raters. Boxes identify two groups, R1 to R3 and R4 to R6. Heights",
        "are dissimilarities, not significance or branch support."),
      silhouette, experience),
    mfrm_pca = c(
      paste("Scores on the first two external-feature principal components",
        "for eight raters, with two k-means groups distinguished by color",
        "and shape. The axes summarize transformed features, not latent",
        "ability or rater quality."),
      paste("Mean and median experience in years for two k-means groups of",
        "four raters. Group 1 is near 12.5 years and group 2 near 2.5 years.",
        "No uncertainty intervals or causal effects are shown.")),
    `mfrmr-package` = wright,
    plot_data = wright,
    data_quality_report = paste(
      "Four data-review panels: row review is unavailable, all four score",
      "categories are used, facet category-use issues are displayed, and",
      "missing or invalid row-count fields are unavailable. Missing summaries",
      "do not establish that no data-quality problems exist."),
    fit_mfrm = wright,
    mfrm_screening_performance = paste(
      "Null-condition family false-flag rate of one third among three known",
      "outcomes out of four planned trials. The wide line is a pointwise",
      "Monte Carlo interval; the shaded unresolved-outcome range is distinct",
      "from that interval."),
    plot.mfrm_multivariate_gstudy = list(
      `3` = c(component_intervals,
        paste("Variance components displayed separately for scores V and W",
          "on a common squared-score scale. Person by Task plus residual is",
          "largest for both scores. Segments from zero are not intervals."),
        paste("Variance-covariance matrices for V and W, one panel per",
          "component: Person, Task, and Person by Task plus residual. Cells",
          "are numerically labeled; these are covariances, not correlations.")),
      `4` = NULL),
    plot_rater_severity_profile = paste(
      "Six rater locations with approximate 95 percent normal intervals and",
      "no magnitude bands. With this example's coding, positive values mean",
      "stricter ratings; zero is the fitted reference, not a quality standard.",
      "These are individual intervals, not pairwise equivalence tests."),
    mfrm_population_intervals = c(
      paste("Conditional population intercept and coefficient for the example's",
        "fictional predictor X, on the native ability scale. Lines show available",
        "experimental pointwise intervals; crosses and row labels identify",
        "unavailable intervals. These are not standardized or causal effects."),
      paste("The conditional population mean at X = 1 minus the mean at X = -1,",
        "using saved weights zero for the intercept and two for X. The",
        "experimental pointwise interval is shown if available; an unavailable",
        "interval retains its point and label. This is not an individual ability difference.")),
    confint.mfrm_fit = paste(
      "Four rater discriminations with pointwise 95 percent model-information",
      "intervals on the relative slope scale, whose geometric mean is one.",
      "Larger slopes mean steeper response curves, not stricter or better raters."),
    mfrm_curve_intervals = paste(
      "Fitted probabilities for score categories 1 to 4 across ability values",
      "from minus two to two for the selected example rater and criterion.",
      "Shaded ribbons show pointwise 95 percent calibration intervals at fixed",
      "ability and context, not intervals for a Person's ability or simultaneous bands."),
    mfrm_facet_intervals = paste(
      "Four rater severity estimates with Person-sandwich and observed-information",
      "pointwise normal intervals. Filled and open circles",
      "distinguish methods; the two methods share the same point estimates.",
      "Zero is the scale reference, not a rater-quality cutoff."),
    plot_interrater_agreement = c(
      paste("Observed exact-agreement bars and model-expected connected",
        "circles for rater pairs with shared ratings. R04 with R05 has the",
        "highest displayed agreement. Pairs without shared evidence have",
        "no estimates, not zero agreement."),
      paste("Pairwise mean signed score differences on the horizontal axis",
        "and mean absolute differences on the vertical axis. Positive",
        "horizontal values mean Rater1 scored higher than Rater2; a zero",
        "mean signed difference can coexist with individual disagreements.")),
    mfrm_d_study = c(difference_reliability, difference_sem,
      v_reliability,
      paste("G for score V at six and twelve common tasks. Points use GENOVA",
        "EMS-adjusted components; the 95 percent interval ribbon targets the",
        "population coefficient under the original-source normal-effects model.",
        "The different bases are retained: these are not intervals for the",
        "adjusted point-estimation procedure."),
      equal_reliability, difference_sem),
    predict.mfrm_testlet = paste(
      "Conditional Person EAPs and equal-tail intervals for P001 to P004",
      "under the testlet model. Fitted calibration and variance parameters",
      "are held fixed; these are not intervals for Person differences."),
    mfrmr_workflow_methods = wright,
    plot_compare_mfrm = c(
      paste("RSM and PCM fitted locations for Persons, raters, criteria and",
        "category transitions, aligned by their labels. The RSM has shared",
        "steps and PCM has criterion-specific steps. Differences alone do",
        "not establish which model is adequate."),
      paste("Four category-probability curves for Content under RSM and PCM.",
        "Solid and dashed lines distinguish models; colors distinguish",
        "categories. The horizontal axis is relative response propensity",
        "in logits, not raw scores.")),
    plot_bubble = c(
      paste("Rater and criterion estimates against Infit mean squares.",
        "Larger circles indicate smaller approximate standard errors.",
        "The shaded 0.5 to 1.5 band is a heuristic review range."),
      paste("Infit against Outfit mean squares for raters and criteria.",
        "Circle area represents observation count. Reference lines mark",
        "one, and shaded bands mark heuristic review ranges, not formal tests.")),
    mfrmr_model_maps = list(
      `1` = paste("Testlet-model Wright map of selected Person EAPs, fixed",
        "facet reference locations and adjacent-category boundaries. Only",
        "Persons have conditional interval whiskers; all locations are in logits."),
      `2` = NULL),
    mfrmr_visual_diagnostics = c(wright, qc, marginal),
    unexpected_response_table = paste(
      "Selected unexpected ratings plotted by standardized residual and",
      "negative log probability of the observed category. Positive and",
      "negative residuals distinguish higher and lower ratings than expected.",
      "The screen supports review, not automatic deletion."),
    mfrm_response_diagnostics = paste(
      "Paired descriptive posterior-predictive Infit and Outfit for four",
      "raters under the testlet model. Circles and triangles distinguish",
      "indices. There are no expectation-one lines or acceptable-fit bands."),
    plot.mfrm_multivariate_d_study = list(
      `7` = c(d_study, equal_reliability, difference_sem,
        "Signed error-variance contributions for the W minus V composite at 3, 6 and 12 tasks. Relative error uses the residual component; absolute error also includes task shifts. Contributions include cross-score covariance and are not SEM or confidence intervals."),
      `9` = c(d_study, difference_sem, equal_reliability, difference_sem,
        equal_reliability,
        "Signed error-variance contributions for the W minus V composite at 3, 6 and 12 tasks. Relative error uses the residual component; absolute error also includes task shifts. Contributions include cross-score covariance and are not SEM or confidence intervals.")),
    plot_fair_average = c(
      paste("Observed Person averages against reference-adjusted FairM",
        "averages on the internal score scale. The diagonal marks equality;",
        "points on either side show how adjustment changes the averages."),
      paste("Person-specific observed-minus-FairM average gaps around zero.",
        "Positive gaps mean the observed average exceeds the reference-adjusted",
        "value. The display is descriptive, without intervals.")),
    analyze_hierarchical_structure = paste(
      "Shares of raw-score variance attributed to Person, Rater, Criterion",
      "and residual by an additive random-effects analysis. Residual is",
      "largest, followed by Person. These variance shares are not MFRM",
      "rater separation reliability or a chosen pairwise agreement ICC."),
    mfrm_g_study = c(
      paste("G and Phi for Content with 1, 2 or 4 raters in a Person by",
        "Rater design. Both increase with rater count, conditional on the",
        "estimated variance components."),
      paste("G and Phi against raters per task for a design with raters",
        "nested within tasks. Separate curves represent 4 or 6 tasks.",
        "The horizontal count is per task, not the total number of raters."),
      paste("Relative and absolute SEM against task count in the nested",
        "rater design, with curves for 2 or 3 raters per task. Error falls",
        "as tasks increase, conditional on the estimated components.")),
    fit_mfrm_testlet = paste(
      "Fixed-rater severity point estimates under the testlet model.",
      "R02 is lowest and R04 highest; positive values mean stricter ratings.",
      "No intervals or rater-quality classifications are shown."),
    plot.mfrm_pca = c(
      paste("Scree plot of transformed external features. The first principal",
        "component accounts for about 91 percent and the second about",
        "9 percent of variance; this is not reliability of ratings."),
      paste("Six entities on the first two external-feature principal",
        "components. The axes describe transformed experience and workshop",
        "hours, not ability; labels identify entities without assigning groups."),
      paste("First-component coefficients for workshop hours and experience",
        "years. The two positive coefficients are equal in this example.",
        "These are transformed-feature loadings, not original-unit correlations.")),
    as_ggplot = c(wright,
      paste("Person and facet locations against Infit mean squares with",
        "location interval whiskers. Symbols distinguish Persons from facet",
        "levels; the shaded band is a review aid, not a formal model-fit test."),
      curves)
  )
  descriptions$plot.mfrm_multivariate_gstudy[['4']] <- c(
    descriptions$plot.mfrm_multivariate_gstudy[['3']], component_intervals)
  descriptions$mfrmr_model_maps[['2']] <- c(
    descriptions$mfrmr_model_maps[['1']],
    paste("Testlet-model rater reference locations against descriptive",
      "posterior Infit. Labels identify raters. No acceptable-fit bands,",
      "expectation-one line or quality classifications are supplied."))

  # Only example plots are targeted; logos and existing authored alt text stay.
  for (page in list.files(pattern = "[.]html$")) {
    html <- xml2::read_html(page)
    images <- xml2::xml_find_all(html,
      "//span[contains(concat(' ', normalize-space(@class), ' '), ' r-plt ')]//img")
    alt <- xml2::xml_attr(images, "alt")
    missing <- is.na(alt) | !nzchar(trimws(alt))
    if (!any(missing)) next
    topic <- tools::file_path_sans_ext(page)
    text <- descriptions[[topic]]
    if (is.list(text)) text <- text[[as.character(length(images))]]
    stems <- tools::file_path_sans_ext(xml2::xml_attr(images, "src"))
    if (length(text) != length(images) || anyNA(text) ||
        any(!nzchar(trimws(text))) ||
        !identical(stems, paste0(topic, "-", seq_along(images)))) {
      stop("Review reference figure descriptions in pkgdown/post-reference.R: ",
        page, " (", length(images), " plots).", call. = FALSE)
    }
    xml2::xml_attr(images[missing], "alt") <- text[missing]
    xml2::write_html(html, page)
  }
})
