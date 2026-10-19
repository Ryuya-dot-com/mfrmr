# Read complete, saved summaries only. This report never fits or scores a model.
wide_pcm_report_data <- function(base, jml) {
  stopifnot(base$independent_replicates == 50L, jml$independent_datasets == 50L,
    nrow(base$jobs) == 400L, length(unique(base$jobs$ConditionId)) == 1L,
    all(table(base$jobs$Arm) == 50L),
    all(vapply(split(base$jobs$Replicate, base$jobs$Arm), function(x)
      !anyDuplicated(x) && setequal(x, 1:50), TRUE)))
  design <- unique(base$jobs[c('N', 'SD', 'View')])
  stopifnot(nrow(design) == 1L, design$View %in% c('full-L1', 'paired-L1', 'paired-L2'))
  targets <- c('contrast:Rater:1-2', 'contrast:Criterion:1-2')
  p <- base$tables$initial
  p <- p[p$Analysis == 'initial_finite_return' & p$Target %in% targets, ]
  s <- jml$tables$summary
  ci <- s[s$Output == 'interval' & s$Target %in% targets, ]
  stopifnot(nrow(p) == 16L, nrow(ci) == 16L, all(p$Complete), all(ci$Complete),
    all(p$ConditionId == unique(base$jobs$ConditionId)),
    all(ci$ConditionId == unique(base$jobs$ConditionId)),
    setequal(p$Arm, base$jobs$Arm), all(table(p$Arm, p$Target) == 1L),
    setequal(ci$Arm, c('PCM-JML', 'GPCM-JML', 'GPCM-JML2', 'GPCM-JML4')),
    setequal(ci$CovarianceNormalization, c('asymptotic', 'finite_roster')),
    all(table(ci$Arm, ci$Target, ci$CovarianceNormalization) == 1L),
    all(p$Planned == 50L), all(ci$Planned == 50L), all(p$Eligible == 50L),
    all(ci$Eligible == 50L), all(p$Reference == 'generating_parameter'),
    all(ci$Reference == 'generating_parameter'),
    !anyDuplicated(p[c('Arm', 'Target')]),
    !anyDuplicated(ci[c('Arm', 'Target', 'CovarianceNormalization')]),
    all(ci$Covered >= 0 & ci$Covered <= ci$Available & ci$Available <= 50L))
  # Exact binomial Monte Carlo intervals retain uncertainty at 0/50 or 50/50.
  interval <- function(k, n) if (n) unname(binom.test(k, n)$conf.int) else c(NA_real_, NA_real_)
  for (metric in c('ConditionalCoverage', 'ReturnedAndCovered', 'Availability')) {
    numerator <- if (metric == 'Availability') ci$Available else ci$Covered
    denominator <- if (metric == 'ConditionalCoverage') ci$Available else ci$Eligible
    bounds <- t(mapply(interval, numerator, denominator))
    ci[[paste0(metric, 'MCLower')]] <- bounds[, 1]
    ci[[paste0(metric, 'MCUpper')]] <- bounds[, 2]
  }
  v <- jml$tables$variation
  stopifnot(!anyDuplicated(v[c('ConditionId', 'Arm', 'Target', 'CovarianceNormalization')]))
  ci <- merge(ci, v[c('ConditionId', 'Arm', 'Target', 'CovarianceNormalization',
    'EmpiricalSD', 'MeanSE', 'RootMeanEstimatedVariance', 'ReportedToEmpiricalSDRatio')],
    by = c('ConditionId', 'Arm', 'Target', 'CovarianceNormalization'), all.x = TRUE, sort = FALSE)
  stopifnot(nrow(ci) == 16L)
  list(points = p, intervals = ci, targets = targets, arms = unique(base$jobs$Arm),
    condition = unique(base$jobs$ConditionId), design = design)
}

wide_pcm_report_draw <- function(data, kind) {
  old <- par(mfrow = c(1, 2), mar = c(4.5, 10, 3, 1), oma = c(2, 0, 3, 0))
  on.exit(par(old))
  limits <- range(c(0, data$points$MeanError,
    data$points$MeanError - qnorm(.975) * data$points$ErrorMCSE,
    data$points$MeanError + qnorm(.975) * data$points$ErrorMCSE), finite = TRUE)
  if (diff(limits) == 0) limits <- limits + c(-.1, .1)
  for (target in data$targets) {
    title <- sub('contrast:', '', target, fixed = TRUE)
    if (kind == 'points') {
      x <- data$points[data$points$Target == target, ]
      x <- x[match(data$arms, x$Arm), ]; y <- rev(seq_len(nrow(x)))
      lo <- x$MeanError - qnorm(.975) * x$ErrorMCSE
      hi <- x$MeanError + qnorm(.975) * x$ErrorMCSE
      plot(NA, xlim = limits, ylim = c(.5, nrow(x) + .5), yaxt = 'n',
        xlab = 'Mean estimation error', ylab = '', main = title)
      abline(v = 0, col = 'grey60', lty = 2)
      axis(2, at = y, labels = paste0(x$Arm, ' [', x$Available, '/50]'), las = 1, cex.axis = .8)
      segments(lo, y, hi, y, col = '#355F8D'); points(x$MeanError, y, pch = 19, col = '#355F8D')
      if (any(!is.finite(x$MeanError))) text(0, y[!is.finite(x$MeanError)], 'Unavailable', pos = 4, cex = .7)
    } else {
      x <- data$intervals[data$intervals$Target == target, ]
      x <- x[order(match(x$Arm, data$arms), match(x$CovarianceNormalization,
        c('asymptotic', 'finite_roster'))), ]; y <- rev(seq_len(nrow(x)))
      plot(NA, xlim = c(0, 1), ylim = c(.5, nrow(x) + .5), yaxt = 'n',
        xlab = 'Truth inclusion / planned-dataset frequency', ylab = '', main = title)
      abline(v = .95, col = 'grey60', lty = 2)
      label <- paste0(x$Arm, ' / ', ifelse(x$CovarianceNormalization == 'asymptotic', 'current', 'finite'),
        ' [', x$Available, '/50]')
      axis(2, at = y, labels = label, las = 1, cex.axis = .75)
      segments(x$ConditionalCoverageMCLower, y + .10, x$ConditionalCoverageMCUpper, y + .10, col = '#355F8D')
      points(x$ConditionalCoverage, y + .10, pch = 19, col = '#355F8D')
      points(x$ReturnedAndCovered, y - .10, pch = 0, col = '#9B4931')
      if (any(x$Available == 0)) text(.5, y[x$Available == 0] + .12, 'No interval returned', cex = .65)
    }
  }
  mtext(if (kind == 'points') 'Initial point estimates: eight methods, 50 shared datasets' else
    'Research JML intervals: coverage and delivery remain separate', outer = TRUE, side = 3, line = 1, font = 2)
  mtext(if (startsWith(data$condition, 'SYNTHETIC')) 'SYNTHETIC DISPLAY CHECK - NOT SIMULATION RESULTS' else
    data$condition, outer = TRUE, side = 3, cex = .85)
  mtext(if (kind == 'points') 'Bars: approximate 95% Monte Carlo intervals for mean error; labels: returned points / 50.' else
    'Blue: coverage among returns, with exact 95% Monte Carlo bounds. Open squares: returned and covered / 50. Labels: intervals / 50.',
    outer = TRUE, side = 1, cex = .8)
}

wide_pcm_report <- function(directory) {
  paths <- file.path(directory, c('summary.rds', 'jml-inference/summary.rds'))
  if (!all(file.exists(paths))) stop('Both complete-condition summaries are required; no report produced.')
  base <- wide_f_read(paths[1])$payload; jml <- wide_f_read(paths[2])$payload
  # Confirm the numerical summaries still refer to the same saved job results.
  for (path in paths) {
    b <- wide_f_read(path)$binding
    dependencies <- if (!is.null(b$outputs)) b$outputs else b$jobs
    stopifnot(length(dependencies) > 0L, identical(dependencies, tools::md5sum(names(dependencies))))
  }
  data <- wide_pcm_report_data(base, jml)
  dir.create(directory, recursive = TRUE, showWarnings = FALSE)
  figures <- c(points = 'point-comparison.png', intervals = 'jml-interval-comparison.png')
  for (kind in names(figures)) {
    png(file.path(directory, figures[[kind]]), width = 1800, height = 800, res = 140)
    tryCatch(wide_pcm_report_draw(data, kind), finally = dev.off())
  }
  stopifnot(all(file.info(file.path(directory, figures))$size > 0))
  escape <- function(x) {
    x <- gsub('&', '&amp;', x, fixed = TRUE); x <- gsub('<', '&lt;', x, fixed = TRUE)
    gsub('>', '&gt;', x, fixed = TRUE)
  }
  table_html <- function(x) {
    if (!nrow(x)) return('<p>No rows in this category.</p>')
    x[] <- lapply(x, function(v) if (is.numeric(v)) format(v, digits = 4, trim = TRUE) else as.character(v))
    paste0('<div class="table"><table><thead><tr><th>', paste(escape(names(x)), collapse = '</th><th>'),
      '</th></tr></thead><tbody>', paste(apply(x, 1, function(v) paste0('<tr><td>',
      paste(escape(v), collapse = '</td><td>'), '</td></tr>')), collapse = '\n'), '</tbody></table></div>')
  }
  accuracy <- character(); accuracy_sources <- character()
  audit_path <- file.path(directory,'accuracy-review/audit.rds')
  if(file.exists(audit_path)) {
    stopifnot(data$condition=='AB:paired-L1:N30:SD1:S-PCM')
    a <- wide_f_read(audit_path)
    for(b in a$binding[c('input','source')])stopifnot(identical(b,tools::md5sum(names(b))))
    stopifnot(identical(a$payload$probability_input,tools::md5sum(names(a$payload$probability_input))))
    ar <- file.path(directory,'accuracy-review')
    precision_path <- file.path(ar,'probability-precision.csv')
    metadata_path <- file.path(ar,'probability-precision.json')
    meta <- jsonlite::fromJSON(metadata_path)
    stopifnot(meta$input_md5==unname(a$payload$probability_input),
      meta$source_md5==unname(tools::md5sum('inst/validation/mfrm-wide-map-probability-precision-20261003.py')))
    precision <- read.csv(precision_path)
    qpath <- file.path(ar,'fixed-pcm-quadrature/summary.rds');q <- wide_f_read(qpath)
    for(b in q$binding[c('jobs','source')])stopifnot(identical(b,tools::md5sum(names(b))))
    accuracy_sources <- tools::md5sum(c(audit_path,precision_path,metadata_path,qpath))
    roots <- a$payload$tables$ordinary
    root_summary <- do.call(rbind,lapply(split(roots,roots$Arm),function(z)data.frame(
      Arm=z$Arm[1],Planned=nrow(z),LocalRootAdmitted=sum(z$RootAdmitted),
      MaximumRootDistanceInSD=max(z$RootDistanceSD[z$RootAdmitted]),
      MaximumOneDatasetGeneratorTV=max(z$JointGeneratorTV[z$RootAdmitted]),
      IllustrativeB999GeneratorTV=sqrt(999)*max(z$JointGeneratorTV[z$RootAdmitted]))))
    pr <- aggregate(cbind(MaximumAbsoluteError,MaximumRowTV)~Arm+Kind,precision,max)
    qi <- q$payload$table
    qm <- aggregate(cbind(NLLChange,ComparisonGradient,QuadratureScoreShift,
      QuadratureCovarianceChange)~ComparisonOrder,qi,max)
    selected_jobs <- a$payload$tables$jobs
    counts <- aggregate(cbind(InitialNumericalPass,SourceReady)~Arm,selected_jobs,sum)
    bad <- a$payload$tables$contrasts
    bad <- bad[bad$Arm=='GPCM-JML' & bad$Target=='contrast:Criterion:1-2',]
    worst <- bad[order(abs(bad$Error),decreasing=TRUE)[1:3],]
    share <- sum(worst$Error^2)/sum(bad$Error^2)
    stopifnot(all(!worst$NumericalPass),all(!worst$ResearchIntervalAvailable))
    accuracy <- c('<h2>5. Numerical accuracy and statistical validity: completed-condition review</h2>',
      '<p>Three different questions must remain separate: whether the saved parameters solve the chosen equations, whether probabilities are computed accurately at those parameters, and whether the resulting estimator and interval target the generating truth.</p>',
      '<h3>Numerical solutions and response probabilities</h3>',table_html(counts),
      '<p>Initial numerical pass is the frozen estimator diagnostic. SourceReady is the output-specific scoring source decision. Neither substitutes for a global-root proof or structural-truth inference. Ordinary JML research intervals apply an additional local-root and fixed-roster covariance screen.</p>',
      table_html(root_summary),
      '<p>Root distances use the stored research sandwich standard deviation. Generator TV bounds compare normalized product laws at the saved ordinary-JML profile and its nearby local root. They are sufficient analytic inequalities evaluated in floating point, without outward rounding. GPCM bounds concern only the local branch. Extreme-person endpoint masses stay fixed. The hypothetical paired-design generator is not a completed bootstrap study or an extension of the complete-block bootstrap theorem.</p>',
      '<p>For B independent inner datasets, the KL-based local perturbation bound grows as sqrt(B). The B=999 column is an illustration, not a launch or adequacy recommendation. A small one-dataset bound does not establish a negligible total bootstrap error budget; accepted inner-refit errors and statistical validity still need separate treatment.</p>',
      sprintf('<p>An independent adjacent-odds implementation evaluated %s saved probability vectors at 80 decimal digits. Maximum raw absolute error was %.3g; the worst row agreed between 80 and 120 digits to %.3g. Total variation uses normalized binary64 sampling weights. This checks arithmetic at identical parameters, not recovery of true probabilities, random-number implementation, root selection or quadrature integration.</p>',
        format(meta$rows,big.mark=',',scientific=FALSE),as.numeric(meta$maximum_absolute_error),as.numeric(meta$worst_row_80_vs_120)),
      table_html(pr),
      '<h3>MML integration and output-specific adoption</h3>',
      '<p>Scoring-source stages use orders 31/61/121; interval stages can differ because the recorded accuracy measures differ. One free-population GPCM source (replicate 3) remains refused at order 121: its comparison gradient at order 241 is 1.75e-4, above 1e-4. Its interval can still pass the separately declared standardized score/covariance checks. All refusals and original stage choices remain in the frozen comparison.</p>',
      '<p>The fixed-normal PCM legacy procedure has no stored finer-grid comparison. A separate audit held all 50 saved q31 parameter vectors fixed and evaluated q61/q121 objectives, analytic gradients and observed information (numerical differences of the gradients). The following are maxima across datasets; no model was refitted.</p>',table_html(qm),
      '<p>All 50 fixed-normal PCM cases pass the interval sensitivity limits (standardized score shift and relative covariance change each at most .01). None passes the stricter absolute scoring-source gradient criterion when applied retrospectively. The retained public source status remains unchanged; reporting every arm as passing an identical quadrature check would be incorrect. This is a measured precision difference between output contracts, not evidence that all fixed-normal PCM estimates are unusable.</p>',
      '<h3>What the statistical evidence supports</h3>',
      sprintf('<p>Ordinary PCM passes the local-root screen in all 50 cases, yet the Criterion contrast has mean error -0.149 (Monte Carlo SE .042). Accurate solution of its equations does not remove finite-exposure bias. For ordinary GPCM, replicates 6, 24 and 28 account for %.2f%% of the Criterion squared error; all three fail the initial numerical screen. Those failures must remain visible, but their errors cannot be described as the bias of an accurately computed exact JML estimator. Even the 36 interval-admitted GPCM cases have conditional mean Criterion error -0.188.</p>',100*share),
      '<p>Correction orders 2 and 4 return 49 points each and 45/46 research intervals. Their Criterion mean errors are -0.102/-0.105 on the 49 finite-return cases. On the 49 common returns, the order-2 minus order-4 Criterion MSE difference is -0.00293 (paired Monte Carlo SE .00259); this does not establish an order-4 advantage. Tiny adjusted-equation residuals and agreement of correction orders do not qualify truth-centered inference.</p>',
      '<p>The balanced fixed roster makes the sandwich computationally feasible: three groups of ten Persons, rather than singleton strata. Multiplying the within-roster meat by 10/9 only increases SE by sqrt(10/9); it does not correct the centering target. Return-conditioned coverage must be accompanied by finite interval delivery over all 50 datasets. The research Wald intervals in this report are not results from the new completed bootstrap procedure.</p>',
      '<p>MML primary-contrast interval inclusion ranges from .92 to .96 with all 50 intervals returned. Both the PCM response model and fixed N(0,1) population are correctly specified here; their favorable error cannot be generalized to different generating slopes, population variance/shape, missingness or dependence. R=50 provides a descriptive comparison, not equivalence to nominal coverage.</p>',
      '<p>This condition has six ratings per Person, planned incomplete exposure and normally distributed abilities. <a href="https://jochmans.github.io/publications/panel%20bootstrap/panel_bstrap.pdf">Higgins and Jochmans, assumptions 1–6 and theorem 1</a> require a matching joint-growth and regularity argument; the previously checked bounded, complete-block sufficient case does not establish validity for this design. Few-rating PCM/RSM conditional-likelihood inference, growing-exposure JML/bootstrap, and corrected/GPCM branch qualification remain distinct work items.</p>',
      '<p>Action: retain the frozen procedures and failures for comparison; use ordinary PCM as the numerically resolved bias benchmark; investigate the rejected GPCM branches before interpreting them as estimator bias; keep correction orders 2/4 separately named; qualify the estimator, covariance target, generator and exposure regime together before adding formal JML truth intervals. Medium/large N, other models, assignment, missingness and dependence remain in scope.</p>')
  }
  qualification <- character()
  decision_path <- file.path(directory,'conditional-reference/truth-interval-decision.json')
  if(file.exists(decision_path)) {
    decision <- jsonlite::fromJSON(decision_path)
    check_path <- file.path(directory,'conditional-reference/qualification-checks.json')
    proof_path <- file.path(dirname(dirname(directory)),
      'jml-truth-interval-decision-20261003/wald-noncoverage.json')
    checks <- jsonlite::fromJSON(check_path);proof <- jsonlite::fromJSON(proof_path)
    stopifnot(checks$AllChecksPassed,checks$ConditioningStrata==250L,
      checks$ExactCoverageChecks==1750L,checks$ProjectedSetsChecked==50L,
      decision$NewFits==0L,decision$NewDatasets==0L)
    accuracy_sources <- c(accuracy_sources,tools::md5sum(c(decision_path,check_path,proof_path)))
    tab <- decision$Summary
    tab <- tab[tab$ConditionalProcedureSupported,]
    qualification <- c('<h2>6. Truth-interval qualification: a decision, not a changed flag</h2>',
      sprintf('<p><strong>The general uncorrected JML truth-Wald rule is rejected.</strong> In a two-item binary Rasch submodel with N=480, true abilities zero and item contrast log(4), an exact integer-probability certificate bounds coverage of the wider JML +/- 2 SE interval by <strong>%s</strong>, even after multiplying covariance by N/(N-1). This is a different submodel from the N30 comparison; it disproves a universal claim, not a claim that N30 coverage equals this number.</p>',proof$CoverageUpperBound),
      '<p>The same fixed-two-item submodel also defeats the ideal fitted-fixed-ability basic bootstrap: the exact original JML converges to 2 log(4), bootstrap JML to 4 log(4), and the basic interval to {0}, while truth remains log(4). More inner draws or more accurate probabilities do not repair that fixed-exposure procedure. This does not contradict a theorem requiring growing exposure.</p>',
      '<p><strong>A separately named conditional procedure has finite-sample pointwise coverage at least 95% under its declared model and assignment assumptions.</strong> It retains the original JML point and obtains intervals by exact nuisance conditioning and tail inversion, without estimating a bias correction or JML covariance. For regular exact PCM joint maxima the JML contrast is monotone in the conditional statistic, so the tail ordering also calibrates that conditional JML ordering. Boundary/uninformative samples retain their proper unbounded outcomes.</p>',
      table_html(tab[c('Arm','Facet','Planned','Points','FiniteIntervals','Covered','FiniteCovered','MeanFiniteWidth','MeanWidth')]),
      '<p>PCM intervals were finite on all 50 datasets for both targets, with 48/50 truth inclusion. Their validity follows from the conditional tail theorem, not from R=50. GPCM Rater projection covers every positive Criterion-slope vector with geometric mean one: 48/50 finite sets, 49/50 total truth inclusion, but only 47/50 finite truth delivery. Its overall mean width is infinite. The three GPCM arms share this same interval procedure and data; they are not three independent confirmations. Failed point estimates remain absent.</p>',
      '<p>The implementation check enumerated all outcomes at seven rational parameter values in each of 250 scalar conditioning distributions (1,750 exact checks), verified tail brackets and outward logarithmic endpoints, and independently checked all 50 GPCM projections. These checks support the implementation; the coverage proof holds for all parameters under the stated assumptions.</p>',
      '<p><strong>Scope:</strong> the fixed/exogenous paired 3-Rater x 3-Criterion design, four categories, centered Criterion-owned steps, unit weights, no interactions and conditional response independence. The PCM procedure covers the two named differences. GPCM projection covers only the nonowner Rater difference. It does not supply GPCM Criterion intervals, a general corrected-JML Wald result, a plug-in bootstrap qualification, or a public all-coordinate API. The 95% statements are pointwise, not simultaneous across both targets.</p>',
      '<p><a href="conditional-reference/jml-points-and-conditional-intervals.csv">Retained JML points and conditional intervals</a> | <a href="conditional-reference/truth-interval-decision.json">Qualification decisions and source identities</a> | <a href="conditional-reference/qualification-checks.json">Exact checks</a> | <a href="../../jml-truth-interval-decision-20261003/wald-noncoverage.json">Finite-sample Wald rejection certificate</a></p>')
    owner_path <- file.path(directory,'conditional-reference/owner-identification.json')
    if(file.exists(owner_path)) {
      owner <- jsonlite::fromJSON(owner_path)
      stopifnot(nrow(owner$Designs)==50L,all(owner$Designs$N==30L),
        all(owner$Designs$Rows==180L),length(owner$InputSHA256)==50L,
        owner$NewFits==0L,owner$NewDatasets==0L,
        owner$NumericallySolvedEquivalentPopulations==0L,
        all(owner$ExactSupportChecks$ObservedRoster$DistinctWeightedTotals==343L),
        all(owner$ExactSupportChecks$CompletePanel$DistinctWeightedTotals==1000L))
      review_path <- 'inst/validation/jml-inference-review-20260927.md'
      accuracy_sources <- c(accuracy_sources,tools::md5sum(c(owner_path,review_path,
        'inst/validation/jml-n30-owner-identification-20261003.py')))
      qualification <- c(qualification,
        '<h3>Why more exact conditioning does not finish the GPCM Criterion interval</h3>',
        '<p>The actual three-by-three design also has an owner-location identification obstruction when ability-population shape is unrestricted. For slopes (1,(q+1)/q,q/(q+1)), q &gt; 9, all 1,000 complete-panel Criterion-total vectors have different ability-weighted totals. Eliminating each free ability by exact conditioning then also removes Criterion locations. The same obstruction holds in the 343 owner-total states of each observed six-rating roster, even for slopes arbitrarily close to one.</p>',
        '<p>A separate analytic construction gives different Criterion contrasts with the same complete nine-cell response law under one common ability population. Marginalization preserves the equivalence for all three observed Rater-pair rosters. One population can be N(0,1); the alternative can preserve mean zero, variance one and normal tails while changing density shape within a compact region. Thus specifying moments alone is insufficient. Uniform 95% coverage at both equivalent truths requires the interval to contain both with probability at least 90%, at every N; universally shrinking intervals at fixed exposure cannot meet that requirement.</p>',
        '<p><strong>Limits of this negative result:</strong> it does not rule out informative nonshrinking confidence sets, inference under an exactly specified normal family, or the equal-slope PCM conditional method. It supplies no numerical lower bound on practical interval width and does not explain the three rejected extreme-slope fits. The saved R50 generating law has exactly unit slopes and an exactly normal population, so that condition must not be relabelled as the nonidentified alternative.</p>',
        '<p>All 50 input designs and exact support arithmetic at maximum slope deviations .1, .01 and .0001 were checked. No new datasets, fits or numerical derivatives were used, and no equivalent population was numerically fitted. The common-population equivalence is the documented analytic proof. Further fixed-exposure Criterion inference must retain the ambiguity in the confidence set or explicitly declare and calibrate an identifying restriction, including other structural nuisance parameters and failures.</p>',
        '<p><a href="conditional-reference/owner-identification.json">Design arithmetic and source identities</a> | <a href="../../../inst/validation/jml-inference-review-20260927.md#october-3--gpcm-owner-location-decision-for-the-actual-three-by-three-design">Derivation and scope decision</a></p>')
    }
  }
  p <- data$points; ci <- data$intervals
  mc_path <- file.path(directory,'normal-mc-calibration/projection-gate.json')
  if(file.exists(mc_path)) {
    mc <- jsonlite::fromJSON(mc_path)
    mc_check_path <- file.path(directory,'normal-mc-calibration/importance-checks.json')
    mc_check <- jsonlite::fromJSON(mc_check_path)
    stopifnot(nrow(mc$SelfNormalizedEscapeCertificates)==45L,
      mc$FiniteContrastIntervalsProduced==0L,mc$NewFits==0L,mc$NewDatasets==0L,
      mc_check$AllChecksPassed,mc_check$PValuesCompared==800L)
    accuracy_sources <- c(accuracy_sources,tools::md5sum(c(mc_path,mc_check_path,
      file.path(directory,'normal-mc-calibration/failure-rule.json'),
      file.path(directory,'normal-mc-calibration/importance-audit.json'),
      file.path(directory,'normal-mc-calibration/rank-audit.json'))))
    tab <- mc$Summary[mc$Summary$Arm!='PCM-JML',]
    qualification <- c(qualification,
      '<h2>7. Normal-population calibration: a research candidate with a projection gate</h2>',
      '<p>The candidate retains each ordinary or corrected JML algorithm and calibrates its statistic under an explicitly declared N(0,1) population and response/assignment law. Corrected importance-sampling tests include the observed sample weight. They can reuse stored JML outputs across candidate parameters. A completed algorithm failure has statistic zero and observed p=1; no missing point is imputed and no reference failure is deleted. Unfinished calculations remain unknown.</p>',
      '<p>Four candidate points were evaluated from the same 50 samples, using the other 49 as the reference bank. This is overlapping development reuse, not independent coverage confirmation. Normal likelihood weights have analytic quadrature/tail bounds and interval arithmetic; 800 normalized test values agree with an independent integration calculation within 4.39e-15.</p>',
      '<p><strong>The self-normalized version was rejected for full nuisance projection.</strong> Exact separating category-count directions show that 45/50 samples would have whole-line Criterion sets, even under the stated normal model. The selected absolute-weight correction avoids that particular escape. The four candidate-point calculations alone do not bound other joint parameter escapes.</p>',
      table_html(tab),
      '<p><strong>Read these as candidate-point tests and retention witnesses.</strong> Rejecting a fully specified point does not reject a Criterion contrast when other nuisance values remain possible. A finite grid or local maximum is insufficient to certify the required nuisance supremum. There are no completed finite contrast intervals or public CI changes from this prototype. The 48/50 retention at the proposal itself follows from the rank construction and is not a new empirical coverage result.</p>',
      '<p><a href="normal-mc-calibration/projection-gate.json">Absolute-weight results and exact whole-line certificates</a> | <a href="normal-mc-calibration/importance-checks.json">Independent numerical checks</a> | <a href="normal-mc-calibration/failure-rule.json">Failure rule and weighted-rank checks</a> | <a href="../../../inst/validation/jml-inference-review-20260927.md#october-3--normal-population-monte-carlo-calibration-and-the-projection-gate">Derivations, sources and remaining projection work</a></p>')
    tail_path <- file.path(directory,'normal-mc-calibration/tail-bounds.json')
    if(file.exists(tail_path)) {
      tails <- jsonlite::fromJSON(tail_path)
      stopifnot(tails$Summary$DatasetCount==50L,
        tails$Summary$SlopeCertificates==150L,
        tails$Summary$MissingEndpointCells==13L,
        tails$Summary$PValueUpperOutsideUnionOfBoxes=='1/32',
        !tails$InteriorSupremumCompleted,!tails$UsefulIntervalEndpointsProduced,
        tails$NewFits==0L,tails$NewDatasets==0L)
      tail_source <- 'inst/validation/jml-normal-mc-tail-bounds-20261004.py'
      accuracy_sources <- c(accuracy_sources,tools::md5sum(c(tail_path,tail_source)))
      qualification <- c(qualification,
        '<h3>Joint parameter tails: boundedness proved, useful precision unresolved</h3>',
        '<p>All 150 dataset/Criterion pairs have a roster with opposite rating orientations. Their likelihood bounds control arbitrarily large slopes uniformly in other parameters. The product-one constraint then bounds slopes away from zero. Endpoint-cell connectivity controls locations despite 13 cells lacking an endpoint category; observed interior categories control centered steps. Thus simultaneous slope, location and step escapes are covered under the declared N(0,1) model.</p>',
        '<p>Outside the union of the certified finite boxes, every absolute importance weight is below 1/32, so the p-value is below .05 for a finite observed point. The exact projected sets are bounded for all 50 ordinary GPCM points and 49 points in each corrected arm. The observed failures in replicate 38 retain whole-line sets.</p>',
        paste0('<p><strong>The initial common outer radius was ',
          format(tails$Summary$CriterionContrastOuterRadiusApproximate,scientific=TRUE,digits=5),
          '.</strong> This is not useful interval precision, an estimated endpoint or evidence that the exact set is wide. Interior nuisance suprema and useful endpoints remain unresolved. Bounded sets may also be empty: existing points witness nonemptiness in 48/50 ordinary cases and 47/49 finite-point cases for each correction order. Unknown cases are not labelled empty.</p>'),
        '<p>The proof uses deterministic inequalities and enclosed proposal lower integrals, checked against independent quadrature for all 1,172 response patterns. No new samples or fits were used. This is development evidence, not independent coverage confirmation or a public CI qualification.</p>',
        '<p><a href="normal-mc-calibration/tail-bounds.json">Finite boxes and data witnesses</a> | <a href="../../../inst/validation/jml-inference-review-20260927.md#october-4--uniform-joint-parameter-tails-for-the-normal-mc-projection">Tail proof, numerical checks and remaining interval work</a></p>')
    }
    upper_path <- file.path(directory,'normal-mc-calibration/profile-upper-checks.json')
    if(file.exists(upper_path)) {
      upper <- jsonlite::fromJSON(upper_path)
      quadrature_path <- file.path(directory,'normal-mc-calibration/profiles/adaptive-check.json')
      quadrature <- jsonlite::fromJSON(quadrature_path)
      stopifnot(upper$FixedSlopeGlobalProfileUpperVerified,
        !upper$AllSlopeSupremumCertified,upper$CertifiedCIEndpoints==0L,
        upper$IndependentCoverageDatasets==0L,nrow(quadrature$Results)==20L)
      paths <- c(upper_path,quadrature_path,
        'inst/validation/jml-normal-profile-upper-20261004.py',
        'inst/validation/jml-normal-profile-upper-check-20261004.py',
        'inst/validation/jml-normal-profile-quadrature-check-20261004.py',
        'inst/validation/jml-normal-profile-adaptive-20261004.py',
        'inst/validation/jml-normal-mc-profile-20261004.py')
      adaptive_path <- file.path(directory,'normal-mc-calibration/profiles/adaptive-scaled/summary.json')
      if(file.exists(adaptive_path)) {
        adaptive <- jsonlite::fromJSON(adaptive_path)
        independent_path <- file.path(directory,'normal-mc-calibration/profiles/adaptive-scaled/independent-check.json')
        independent <- jsonlite::fromJSON(independent_path)
        stopifnot(nrow(adaptive$Results)==20L,all(adaptive$Results$OptimizerSuccess),
          independent$AllChecksPassed,independent$IndependentCoverageDatasets==0L,
          independent$MaximumAbsoluteLogLikelihoodDifference<1e-8)
        paths <- c(paths,adaptive_path,independent_path)
      }
      sharp_path <- file.path(directory,'normal-mc-calibration/profiles/proposal-and-sharp-transfer.json')
      if(file.exists(sharp_path)) paths <- c(paths,sharp_path,
        file.path(directory,'normal-mc-calibration/profiles/sharp-transfer.json'))
      accuracy_sources <- c(accuracy_sources,tools::md5sum(paths))
      qualification <- c(qualification,
        '<h3>Interior profile bound and a numerical issue found during slope exploration</h3>',
        '<p>At fixed unit slopes and Criterion contrast 3, a global upper bound over all nine remaining location/step coordinates is certified for replicate 1. Its log-likelihood enclosure has width 6.654e-15. A uniform power-normalization inequality transfers the bound to a slope box: this one sample\'s importance weight is at most 7.697e-12 over [.9,1.1]^3. This is one numerator term, not a p-value or a bound covering every slope and reference sample.</p>',
        '<p>Exploratory free-slope optimization revealed that GH241 may overstate the continuous log likelihood by 39.12 at large slopes. Eight of 20 candidate points differed from independently split adaptive integration by more than .1 log-likelihood units. Scaled adaptive integration around each Person\'s normal mode is used to repair those candidate calculations. Optimizer convergence and additional quadrature nodes alone cannot certify an endpoint.</p>',
        '<p><strong>Requested endpoint and independent-validation work remains incomplete.</strong> The full normalized-slope region, complete inclusive-rank numerator, useful endpoints and empty-set outcomes still require certified evaluation. No new independent coverage datasets have been consumed. Existing N20–480 and facet/assignment/missingness conditions remain in scope; correct population specification and misspecification will need separate interpretation.</p>',
        '<p><a href="normal-mc-calibration/profile-upper-checks.json">Upper-bound and derivative checks</a> | <a href="normal-mc-calibration/profiles/adaptive-check.json">Fixed-grid integration discrepancies</a> | <a href="../../../inst/validation/jml-inference-review-20260927.md#october-4--interior-upper-bounds-and-a-quadrature-failure-in-slope-searches">Proof, numerical repair and outstanding dependency</a></p>')
      if(file.exists(adaptive_path)) qualification <- c(qualification,
        '<p>All 20 mode-scaled adaptive reoptimizations completed and were checked by a separate unshifted adjacent-odds integration. The maximum log-likelihood difference was 5.685e-14. At one large-contrast candidate the third slope moved from 100 to 24.08; GH961 still differed by up to 9.73 at the repaired points. These remain development nuisance witnesses, not global maxima or outer coverage datasets.</p>')
      if(file.exists(sharp_path)) qualification <- c(qualification,
        '<p>A sharper normalization inequality, the product-one constraint and an enclosed proposal probability expand the replicate-1, contrast-3 bound: throughout [.75,1.25]^3 its importance weight is at most .009585, over all location/step values. This still bounds only one numerator term over part of the slope domain.</p>')
    }
    dual_path <- file.path(directory,'normal-mc-calibration/profiles/dual-region-checks.json')
    if(file.exists(dual_path)) {
      dual <- jsonlite::fromJSON(dual_path,simplifyVector=FALSE)
      general_path <- file.path(directory,'normal-mc-calibration/profiles/general-region-checks.json')
      general <- jsonlite::fromJSON(general_path,simplifyVector=FALSE)
      stopifnot(dual$ChecksPassed,dual$DualCertificatesChecked==100L,
        dual$Complete50TermUpperBoundsWithinNamedSlopeRegions,
        !dual$AllSlopeSupremumCertified,dual$CertifiedCIEndpoints==0L,
        dual$IndependentCoverageDatasets==0L,general$ChecksPassed,
        length(dual$Results)==2L,length(general$Results)==2L)
      region_table <- do.call(rbind,lapply(dual$Results,function(z) {
        do.call(rbind,lapply(z$SlopeRegions,function(box) data.frame(
          ReferenceSlopes=paste(unlist(z$ReferenceSlopes),collapse=', '),
          RelativeSlopeRegion=paste(box$RelativeSlopeLower,box$RelativeSlopeUpper,sep=' to '),
          ExcludedContrastRay=paste(if(box$ContrastRay=='right') '>=' else '<=',
            format(box$ExcludedRayBoundaryApproximate,digits=12)),
          CompleteSumUpper=box$CompleteNumeratorPValueUpperApproximate)))
      }))
      stopifnot(nrow(region_table)==6L,all(region_table$CompleteSumUpper<=.05))
      dependencies <- c(dual_path,general_path,
        'inst/validation/jml-normal-profile-regions-20261004.py',
        'inst/validation/jml-normal-profile-regions-check-20261004.py',
        'inst/validation/jml-normal-profile-dual-20261004.py',
        'inst/validation/jml-normal-profile-dual-check-20261004.py',
        file.path(directory,'normal-mc-calibration/profiles/general-replicate-01-psi--10.json'),
        file.path(directory,'normal-mc-calibration/profiles/general-replicate-01-psi--10.moments.json'))
      for(name in c('dual-unit','dual-small-small-large')) {
        folder <- file.path(directory,'normal-mc-calibration/profiles',name)
        dependencies <- c(dependencies,list.files(folder,pattern='[.]json$',full.names=TRUE))
      }
      accuracy_sources <- c(accuracy_sources,tools::md5sum(dependencies))
      qualification <- c(qualification,
        '<h3>All 50 reference terms bounded within explicit slope regions</h3>',
        '<p>The accurate profile certificate now extends to slopes (.2,.2,25). At replicate 1 and contrast -10 its log-profile enclosure has width 3.627e-14. A locally certified integration mesh uses 99 segments instead of the 1,800 needed by the uniform-strip bound; this is a segment count, not a measured total runtime speedup. Independent integration and directional Hessian checks pass.</p>',
        '<p>A separate normal-moment-generating-function and entropy-dual inequality gives an integral-free affine upper envelope over every location/step value and every contrast at fixed slopes. All 100 rational witnesses (50 samples at each of two slope vectors) pass independent simplex, exact-balance and outward primal/dual checks. The maximum enclosed joint-mode primal/dual gap is 7.574e-14; this is not the gap between the joint-mode relaxation and the marginal likelihood.</p>',
        table_html(region_table),
        '<p>Each row applies to product-one slopes in the stated componentwise relative region. Its upper bound includes the observed self term and all 49 reference terms, conservatively replacing inclusive statistic-tail indicators by one. All finite-point GPCM arms are covered within that region; completed observed failures retain whole-line sets.</p>',
        '<p><strong>These are regional exclusions, not full-model CI endpoints.</strong> The remaining positive-slope domain is unresolved. Boundaries from different slope regions cannot be joined into a confidence interval. No independent coverage dataset has been consumed; the original 400 jobs and broad-condition allocation remain unchanged.</p>',
        '<p><a href="normal-mc-calibration/profiles/dual-region-checks.json">Complete-sum regional certificates</a> | <a href="normal-mc-calibration/profiles/general-region-checks.json">Large-slope integration and ray checks</a> | <a href="../../../inst/validation/jml-inference-review-20260927.md#october-4--general-slopes-and-the-complete-reference-sum-within-slope-regions">Derivations, scope and remaining dependency</a></p>')
    }
    global_folder <- file.path(directory,'normal-mc-calibration/profiles/global-tail')
    global_path <- file.path(global_folder,'location-checks.json')
    if(file.exists(global_path)) {
      global <- jsonlite::fromJSON(file.path(global_folder,'checks.json'),simplifyVector=FALSE)
      location <- jsonlite::fromJSON(global_path,simplifyVector=FALSE)
      stopifnot(global$ChecksPassed,global$EntropyWitnessesChecked==150L,
        global$ImprovedSlopeBounds==150L,length(global$SwapWitnesses)==6L,
        location$ChecksPassed,location$Datasets==50L,
        location$ExactEndpointCombinationsChecked==300L,
        location$PValueUpperOutsideContrastRadius=='1/32',
        location$ObservedFailureWholeLineOverride,
        !location$UsefulIntervalEndpointsProduced,location$CertifiedCIEndpoints==0L,
        location$IndependentCoverageDatasets==0L)
      radii <- data.frame(
        Bound=c('Original joint-tail bound','Sharper uniform slope tails','Centered-facet geometry'),
        ConservativeOuterRadius=c(global$PreviousCommonCriterionContrastOuterRadiusApproximate,
          global$CommonCriterionContrastOuterRadiusApproximate,
          location$CommonCriterionContrastOuterRadiusApproximate))
      dependencies <- c(list.files(global_folder,pattern='[.]json$',full.names=TRUE),
        'inst/validation/jml-normal-profile-global-tail-20261004.py',
        'inst/validation/jml-normal-profile-global-tail-check-20261004.py',
        'inst/validation/jml-normal-profile-location-bound-20261004.py')
      accuracy_sources <- c(accuracy_sources,tools::md5sum(dependencies))
      qualification <- c(qualification,
        '<h3>Sharper uniform tails and centered-facet location bounds</h3>',
        '<p>Owner-specific free-ability entropy bounds and a powered discordance inequality sharpen all 150 slope cutoffs uniformly in the remaining parameters. A separate raw-response reconstruction verifies exact simplex and sufficient-statistic balance for every entropy witness. Six auxiliary problems use an exact score-swap witness after an infeasible numerical projection; no response, original estimate or reference failure is deleted.</p>',
        '<p>Slope ordering, the product-one constraint and both facet-centering constraints then tighten the contrast bound further. All 300 required endpoint-cell combinations are checked against the actual saved responses, covering all six possible slope orderings in each sample. The 13 missing endpoint cells do not invalidate these particular combinations.</p>',
        table_html(radii),
        '<p><strong>The resulting radius is still about 7.15 billion, not useful precision or a certified CI endpoint.</strong> Outside it the full absolute MC sum is at most 1/32 for a finite observed point. This is a uniform outer-domain bound, not a restriction imposed on slopes or a claim that the actual confidence set is wide. Observed failures still return the whole line. Interior inversion, empty-set handling and independent validation remain incomplete.</p>',
        '<p>These calculations reuse the N30 development bank; they add 150 auxiliary entropy problems and exact algebraic checks, with no original-estimator refits or new response datasets. The N20 descriptive comparison is separate and does not validate an unfinished CI procedure.</p>',
        '<p><a href="normal-mc-calibration/profiles/global-tail/checks.json">Entropy and powered-tail checks</a> | <a href="normal-mc-calibration/profiles/global-tail/location-checks.json">Exact centered-location checks</a> | <a href="../../../inst/validation/jml-inference-review-20260927.md#october-4--uniform-slope-tails-strengthened-by-entropy-and-centered-locations">Proof and remaining scope</a></p>')
    }
  }
  original_ci <- base$tables$source_reviewed
  original_ci <- original_ci[original_ci$Output == 'interval' & grepl('^contrast:', original_ci$Target), ]
  selected <- base$tables$source_reviewed
  selected <- selected[selected$Output == 'point' & grepl('^contrast:', selected$Target), ]
  paired <- jml$tables$paired_points
  paired <- paired[paired$CovarianceNormalization == 'asymptotic' & paired$Target %in% data$targets, ]
  columns <- c('Arm', 'Target', 'Available', 'MeanError', 'RMSE', 'ErrorMCSE')
  html <- c('<!doctype html><html lang="en"><meta charset="utf-8"><title>PCM basic-condition comparison</title>',
    '<style>body{font:16px/1.5 system-ui;max-width:1200px;margin:32px auto;padding:0 20px;color:#202938}img{width:100%}.table{overflow:auto}table{border-collapse:collapse;font-size:13px}th,td{padding:6px 9px;border-bottom:1px solid #ddd;text-align:right;white-space:nowrap}h1,h2{line-height:1.2}code{font-size:14px}</style>',
    '<h1>PCM basic-condition comparison</h1>', paste0('<p><strong>', escape(unique(base$jobs$ConditionId)),
      '</strong>. 50 independent parent datasets, eight matched methods, 400 completed jobs. Methods, Persons and targets do not add independent replications.</p>'),
    paste0('<p>The A/B design has two observed facets: Rater (3 levels) and Criterion (3 levels), with scores 0, 1, 2, 3. Each dataset has ',
      data$design$N, ' Persons and generating ability SD ', data$design$SD, '. Assignment: ', data$design$View,
      '; ratings per Person: ', switch(data$design$View, 'full-L1' = 9L, 'paired-L1' = 6L, 'paired-L2' = 12L),
      '. Paired assignment is planned incomplete exposure; L2 denotes distinct conditionally independent rating events, not duplicated responses.</p>'),
    '<p>This is a descriptive first-stage simulation report. JML intervals are research candidates; numerical return or coverage in one condition does not qualify structural-truth inference. All original datasets, failures and interval refusals remain in the accounting.</p>',
    '<h2>1. Do the point estimates recover the generating contrasts?</h2>',
    '<p>Compare the prespecified Rater and Criterion first-minus-second contrasts on their native centered scale. Initial finite-return estimates and source-reviewed estimates are shown separately: numerical stage selection can change both the estimate and its availability. Neither is replaced by an oracle-selected correction order.</p>',
    '<img src="point-comparison.png" alt="Bias and Monte Carlo uncertainty for two prespecified contrasts and eight methods">',
    table_html(p[columns]), '<h3>Source-reviewed point outputs</h3>', table_html(selected[columns]),
    '<h2>2. Do reported intervals combine coverage with reliable delivery?</h2>',
    '<p>Blue points condition on interval return; open squares divide returned-and-covered cases by all 50 planned datasets. Return counts must be read alongside coverage. Exact binomial Monte Carlo bounds describe simulation uncertainty, not uncertainty about a structural parameter in one dataset. They are marginal bounds, not a simultaneous model-selection guarantee.</p>',
    '<img src="jml-interval-comparison.png" alt="Research JML conditional coverage and returned-and-covered frequency with interval return counts">',
    table_html(ci[c('Arm', 'Target', 'CovarianceNormalization', 'Available', 'MeanError', 'Covered', 'ConditionalCoverage',
      'ConditionalCoverageMCLower', 'ConditionalCoverageMCUpper', 'ReturnedAndCovered', 'MeanWidth')]),
    '<p>The finite-roster version corrects the within-roster sample covariance denominator. It does not remove structural bias or guarantee correct intervals. The two versions use identical point estimates and datasets; they are sensitivity comparisons, not independent replications.</p>',
    '<h3>Source-reviewed intervals from the original eight-method workflow</h3>',
    '<p>Unsupported JML structural intervals remain unavailable here. The research candidates above are not substituted into the public/source-reviewed output contract.</p>',
    table_html(original_ci[c('Arm', 'Target', 'Eligibility', 'Eligible', 'Available', 'ConditionalCoverage', 'ReturnedAndCovered', 'MeanWidth')]),
    '<h2>3. Does reported SE match empirical variation?</h2>',
    '<p>Empirical SD and reported SE below use exactly the same interval-delivered datasets. Bias in the first table uses all returned points. Accurate SE alone does not correct bias or establish coverage.</p>',
    table_html(ci[c('Arm', 'Target', 'CovarianceNormalization', 'Available', 'EmpiricalSD', 'MeanSE', 'RootMeanEstimatedVariance', 'ReportedToEmpiricalSDRatio')]),
    '<h3>Paired squared-error differences</h3><p>Differences are ArmA minus ArmB on jointly returned points; negative values favor ArmA for that contrast and subset. Read the paired Monte Carlo SE and joint-return count. No automatic winner is selected.</p>',
    table_html(paired[c('Target', 'ArmA', 'ArmB', 'BothAvailable', 'MeanSquaredErrorDifference', 'PairedMCSE')]),
    '<h2>4. Prediction, scoring and extreme responses</h2>',
    '<p>Response-probability errors aggregate the fixed evaluation grid within each dataset. Native training scores use method-specific estimators; they are not interchangeable with common-prior EAP re-scoring. Infinite JML ability estimates retain infinite loss. Conditional ability intervals omit calibration uncertainty; the complete scoring and paired-scoring tables retain their own denominators.</p>',
    table_html(base$tables$probability), table_html(base$tables$native),
    if(length(accuracy)) c('<h3>Common N(0,1) EAP after the prespecified scoring refinement</h3>',
      table_html(base$tables$scoring[base$tables$scoring$Prior=='reference' & base$tables$scoring$Rule=='refinement',
        c('Arm','Panel','Availability','RMSE','RMSEMCSE','ConditionalInclusion')]),
      '<p>Future scoring uses 60 Persons per dataset, but Monte Carlo uncertainty retains the 50 independent calibration datasets. Ordinary PCM delivers 16/50 datasets and ordinary GPCM 11/50; the latter loses three further sources to posterior integration refusal. Corrected orders deliver 49/50. Returned-only errors describe different selected subsets. Native infinite JML scores remain separate from these finite EAP scores.</p>'),
    accuracy,
    qualification,
    '<h2>Limits and complete outputs</h2>',
    '<p>At R=50, coverage and bias estimates can have substantial Monte Carlo uncertainty. Nominal 95% coverage lying inside a Monte Carlo interval is not evidence of equivalence to 95%. Conclusions remain local to this condition. Small, medium and large samples, exposure, facet structure, missingness and dependence remain separate roadmap conditions.</p>',
    '<p>All targets, failure reasons, scoring rules and paired comparisons remain available in the CSV tables below. The two displayed contrasts were prespecified, rather than chosen after seeing favorable results.</p>',
    paste0('<p>', paste(vapply(names(base$tables), function(n) paste0('<a href="', n, '.csv">', n, '</a>'), ''), collapse = ' | '), '</p>'),
    paste0('<p>', paste(vapply(names(jml$tables), function(n) paste0('<a href="jml-inference/', n, '.csv">JML ', n, '</a>'), ''), collapse = ' | '), '</p>'),
    '<p>Generated from saved complete-condition summaries; no fitting, scoring, response generation or dataset replacement occurs in this report.</p></html>')
  writeLines(html, file.path(directory, 'report.html'))
  saveRDS(list(summary_sources = tools::md5sum(paths),
    report_source = tools::md5sum('inst/validation/mfrm-wide-map-pcm-report-20261003.R'),
    accuracy_sources = accuracy_sources,
    data = data, figures = tools::md5sum(file.path(directory, figures))), file.path(directory, 'report.rds'))
  invisible(data)
}

wide_pcm_report_check <- function(directory) {
  dir.create(file.path(directory, 'jml-inference'), recursive = TRUE, showWarnings = FALSE)
  condition <- 'SYNTHETIC REPORT CHECK - NOT SIMULATION EVIDENCE'
  arms <- c('PCM-MML-free', 'PCM-MML-fixed', 'PCM-JML', 'GPCM-MML-free',
    'GPCM-MML-fixed', 'GPCM-JML', 'GPCM-JML2', 'GPCM-JML4')
  targets <- c('contrast:Rater:1-2', 'contrast:Criterion:1-2')
  p <- expand.grid(Arm = arms, Target = targets, stringsAsFactors = FALSE)
  p$ConditionId <- condition; p$Analysis <- 'initial_finite_return'; p$Output <- 'point'
  p$Complete <- TRUE; p$Planned <- p$Eligible <- p$Available <- 50L
  p$Reference <- 'generating_parameter'; p$Eligibility <- 'eligible'
  p$MeanError <- seq(-.15, .15, length.out = nrow(p)); p$RMSE <- .4; p$ErrorMCSE <- .04
  p$Available[1] <- 0L; p[1, c('MeanError', 'RMSE', 'ErrorMCSE')] <- NA_real_
  ci <- p[rep(which(grepl('JML', p$Arm)), 2), ]; ci$Output <- 'interval'
  ci$CovarianceNormalization <- rep(c('asymptotic', 'finite_roster'), each = 8L)
  ci$Available <- rep(c(0L, 50L, 45L, 50L), 4)
  ci$Covered <- rep(c(0L, 50L, 35L, 0L), 4)
  ci$ConditionalCoverage <- ifelse(ci$Available > 0, ci$Covered / ci$Available, NA_real_)
  ci$ReturnedAndCovered <- ci$Covered / 50; ci$Availability <- ci$Available / 50
  ci$MeanWidth <- ifelse(ci$Available > 0, 1.2, NA_real_)
  v <- ci[c('ConditionId', 'Arm', 'Target', 'CovarianceNormalization')]
  v$EmpiricalSD <- .3; v$MeanSE <- .35; v$RootMeanEstimatedVariance <- .36
  v$ReportedToEmpiricalSDRatio <- 1.2
  pp <- data.frame(CovarianceNormalization = 'asymptotic', Target = targets,
    ArmA = 'GPCM-JML', ArmB = 'GPCM-JML2', BothAvailable = 50L,
    MeanSquaredErrorDifference = .1, PairedMCSE = .05)
  jobs <- expand.grid(Arm = arms, Replicate = 1:50, stringsAsFactors = FALSE)
  jobs$ConditionId <- condition; jobs$N <- 30L; jobs$SD <- 1; jobs$View <- 'paired-L1'
  base <- list(independent_replicates = 50L, jobs = jobs,
    tables = list(initial = p, source_reviewed = rbind(
      transform(ci[ci$CovarianceNormalization == 'asymptotic', names(p)],
        ConditionalCoverage = ci$ConditionalCoverage[1:8], ReturnedAndCovered = ci$ReturnedAndCovered[1:8], MeanWidth = ci$MeanWidth[1:8]),
      transform(p, ConditionalCoverage = NA_real_, ReturnedAndCovered = NA_real_, MeanWidth = NA_real_)),
      probability = data.frame(), native = data.frame()))
  jml <- list(independent_datasets = 50L, tables = list(summary = ci, variation = v, paired_points = pp, refusals = data.frame()))
  fail <- function(expr) {
    error <- tryCatch({force(expr); NULL}, error = identity)
    stopifnot(inherits(error, 'error'))
  }
  bad <- base; bad$independent_replicates <- 49L; fail(wide_pcm_report_data(bad, jml))
  bad <- jml; bad$tables$summary$ConditionId <- 'different condition'; fail(wide_pcm_report_data(base, bad))
  bad <- jml; bad$tables$summary <- bad$tables$summary[-1, ]; fail(wide_pcm_report_data(base, bad))
  missing <- tempfile('missing-pcm-report-'); fail(wide_pcm_report(missing)); stopifnot(!dir.exists(missing))
  source_path <- file.path(directory, 'synthetic-input.rds'); saveRDS(list(synthetic = TRUE), source_path)
  for (name in c('base', 'jml')) {
    value <- get(name); path <- file.path(directory, if (name == 'base') 'summary.rds' else 'jml-inference/summary.rds')
    saveRDS(list(payload = value, checksum = wide_mml_hash(value),
      binding = list(outputs = tools::md5sum(source_path))), path)
    for (n in names(value$tables)) write.csv(value$tables[[n]], file.path(dirname(path), paste0(n, '.csv')), row.names = FALSE)
  }
  result <- wide_pcm_report(directory); x <- result$intervals
  stopifnot(all(is.na(x$ConditionalCoverageMCLower[x$Available == 0])),
    all(x$ReturnedAndCovered[x$Available == 0] == 0),
    all(abs(x$ConditionalCoverageMCLower[x$Covered == 50] - .025^(1/50)) < 1e-12),
    all(abs(x$ConditionalCoverageMCUpper[x$Available == 50 & x$Covered == 0] - (1 - .025^(1/50))) < 1e-12),
    all(x$AvailabilityMCLower[x$Available == 50] < 1),
    sum(result$points$Available == 0) == 1L,
    all(file.info(file.path(directory, c('report.html', 'point-comparison.png', 'jml-interval-comparison.png')))$size > 0))
  saveRDS(list(synthetic_only = TRUE, source = tools::md5sum('inst/validation/mfrm-wide-map-pcm-report-20261003.R'),
    checks = c('Complete-condition and matching-condition guards', 'Missing target and missing summary refusal',
      'Zero-return and 0/50 and 50/50 Monte Carlo intervals', 'HTML and both graphics rendered')),
    file.path(directory, 'verified.rds'))
  cat('Report checks passed using synthetic summaries only.\n')
  invisible(result)
}

if (sys.nframe() == 0L) {
  args <- commandArgs(trailingOnly = TRUE); stopifnot(length(args) %in% 1:2)
  pkgload::load_all('.', quiet = TRUE, compile = FALSE)
  source('inst/validation/mfrm-wide-map-mml-stages-20261001.R')
  source('inst/validation/mfrm-wide-map-f-scoring-20261002.R')
  if (length(args) == 1L) wide_pcm_report(args[1]) else {
    stopifnot(args[1] == 'check'); wide_pcm_report_check(args[2])
  }
}
