# mfrmr Reporting and APA

This vignette shows the package-native route from a fitted many-facet
Rasch model to manuscript-oriented prose, tables, figure notes, and
revision checks.

The reporting stack in `mfrmr` is organized around four objects:

- `fit`: the fitted model from
  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
- `diag`: diagnostics from
  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
- `chk`: the revision guide from
  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
- `apa`: structured manuscript outputs from
  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)

For a broader workflow view, see
[`vignette("mfrmr-workflow", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-workflow.md).
For a plot-first route, see
[`vignette("mfrmr-visual-diagnostics", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/articles/mfrmr-visual-diagnostics.md).

## Minimal setup

``` r

library(mfrmr)

toy <- load_mfrmr_data("example_core")

# The vignette uses compact quadrature so optional local execution stays fast.
# For final manuscript reporting, refit with the package default or a higher
# quadrature setting and record that setting in the analysis log.
fit <- fit_mfrm(
  toy,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  model = "RSM",
  quad_points = 7
)

diag <- diagnose_mfrm(fit, residual_pca = "none")
```

## 1. Start with the revision guide

Use
[`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
first when the question is “what is still missing?” rather than “how do
I phrase the results?”

``` r

chk <- reporting_checklist(fit, diagnostics = diag)

head(
  chk$checklist[, c("Section", "Item", "DraftReady", "Priority", "NextAction")],
  10
)
#>           Section                                                      Item
#> 1  Method Section                                       Model specification
#> 2  Method Section                                          Data description
#> 3  Method Section                                           Precision basis
#> 4  Method Section                                               Convergence
#> 5  Method Section                                     Connectivity assessed
#> 6  Method Section Empirical-Bayes shrinkage when small-N facets are present
#> 7  Method Section                                Facet sample-size adequacy
#> 8  Method Section                             Hierarchical structure review
#> 9      Global Fit                                    Standardized residuals
#> 10     Global Fit                                          PCA of residuals
#>    DraftReady Priority
#> 1        TRUE    ready
#> 2        TRUE    ready
#> 3        TRUE    ready
#> 4        TRUE    ready
#> 5        TRUE    ready
#> 6        TRUE    ready
#> 7        TRUE    ready
#> 8       FALSE   medium
#> 9        TRUE    ready
#> 10      FALSE   medium
#>                                                                                                                                   NextAction
#> 1                                                      Available; adapt this evidence into the manuscript draft after methodological review.
#> 2                                                      Available; adapt this evidence into the manuscript draft after methodological review.
#> 3                                                                             Report the precision tier as model-based in the APA narrative.
#> 4                                                      Available; adapt this evidence into the manuscript draft after methodological review.
#> 5                                                             Document the connectivity result before making common-scale or linking claims.
#> 6                          Report both the fixed-effects and shrunk estimates; cite Efron & Morris (1973) for the empirical-Bayes rationale.
#> 7       Report the per-facet adequacy bands and discuss any sparse/marginal levels; cite Linacre (1994) sample-size guidance where relevant.
#> 8  Run `analyze_hierarchical_structure(fit)` once per design and pass the result to `reporting_checklist(..., hierarchical_structure = hs)`.
#> 9                                            Use standardized residuals as screening diagnostics, not as standalone proof of model adequacy.
#> 10                                                                Run residual PCA if you want to comment on unexplained residual structure.
```

Interpretation:

- `DraftReady` flags whether the current objects already support a
  section for drafting with the package’s documented caveats.
- `Priority` shows what to resolve first.
- `NextAction` is the shortest package-native instruction for closing
  the gap.

## 2. Check the precision layer before strong claims

`mfrmr` intentionally distinguishes `model_based`, `hybrid`, and
`exploratory` precision tiers.

``` r

prec <- precision_review_report(fit, diagnostics = diag)

prec$profile
#>   Method Converged PrecisionTier SupportsFormalInference HasFallbackSE
#> 1    MML      TRUE   model_based                    TRUE         FALSE
#>        PersonSEBasis           NonPersonSEBasis
#> 1 Posterior SD (EAP) Observed information (MML)
#>                               CIBasis
#> 1 Normal interval from model-based SE
#>                                                   ReliabilityBasis
#> 1 Observed variance with model-based and fit-adjusted error bounds
#>   HasFitAdjustedSE HasSamplePopulationCoverage
#> 1             TRUE                        TRUE
#>                                                          RecommendedUse
#> 1 Use for primary reporting of SE, CI, and reliability in this package.
prec$checks
#>                      Check Status
#> 1           Precision tier   pass
#> 2    Optimizer convergence   pass
#> 3     ModelSE availability   pass
#> 4 Fit-adjusted SE ordering   pass
#> 5     Reliability ordering   pass
#> 6 Facet precision coverage   pass
#> 7         SE source labels   pass
#>                                                                                 Detail
#> 1                              This run uses the package's model-based precision path.
#> 2                                                  The optimizer reported convergence.
#> 3                             Finite ModelSE values were available for 100.0% of rows.
#> 4            Fit-adjusted SE values were not smaller than their paired ModelSE values.
#> 5         Conservative reliability values were not larger than the model-based values.
#> 6 Each facet had sample/population summaries for both model and fit-adjusted SE modes.
#> 7                        Person and non-person SE labels match the MML precision path.
prec$fit_separation_basis
#>                               Topic
#> 1                          Fit MnSq
#> 2                          Fit ZSTD
#> 3 Separation reliability and strata
#> 4         Operational QC thresholds
#>                                                             SourceBasis
#> 1                               Wright & Linacre (1994); Linacre (2002)
#> 2                          Linacre (2002); FACETS WHEXACT documentation
#> 3       Wright & Masters (1982); Wright & Masters (2002); FACETS manual
#> 4 Package QC policy layered on the fit and separation conventions above
#>                                                                  PackageSurface
#> 1                                         diagnose_mfrm(); fit_measures_table()
#> 2                    diagnose_mfrm(fit_df_method = "both"); facets_fit_review()
#> 3 diagnostics$reliability; facet_statistics_report(); precision_review_report()
#> 4                                     run_qc_pipeline(); evaluate_mfrm_design()
#>                                                                                                              Interpretation
#> 1                      Mean-square fit is the primary size diagnostic; values are read relative to the expected value of 1.
#> 2                    ZSTD standardizes mean-square fit and is sensitive to df, transformation, and sample-size conventions.
#> 3 Separation/reliability/strata summarize spread relative to average measurement error; they are not inter-rater agreement.
#> 4                  Pass/warn/fail cutoffs are reporting policy overlays and should remain separate from formula validation.
#>                                                                                                                ValidationUse
#> 1                   Use as diagnostic evidence and external comparison input; not a standalone validation success criterion.
#> 2         Compare MnSq first; label df-driven ZSTD changes convention-sensitive when validating against FACETS-style output.
#> 3                 Report with precision tier and model/real basis; do not use separation alone as measurement-quality proof.
#> 4 Use for operational triage after formula/source checks; calibrate thresholds with simulations or external reference cases.
#>                                 Availability
#> 1                   available_in_diagnostics
#> 2                available_without_df_review
#> 3              available_in_precision_tables
#> 4 available_where_qc_pipeline_supports_model
```

Interpretation:

- Use stronger inferential phrasing only when the reported tier is
  `model_based`.
- Treat `hybrid` and `exploratory` outputs more conservatively,
  especially for SE-, CI-, and reliability-heavy prose.
- Read `fit_separation_basis` as a boundary table: MnSq fit, ZSTD
  standardization, Rasch/FACETS-style separation, and package QC
  thresholds have different source bases and should not be collapsed
  into a single validation pass/fail claim.

## 3. Build structured manuscript outputs

[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
is the writing engine. It returns report text plus a section map, note
map, and caption map that all share the same output contract.

``` r

apa <- build_apa_outputs(
  fit,
  diagnostics = diag,
  context = list(
    assessment = "Writing assessment",
    setting = "Local scoring study",
    scale_desc = "0-4 rubric scale",
    rater_facet = "Rater"
  )
)

cat(apa$report_text)
#> Method.
#> 
#> Design and data.
#> The analysis focused on Writing assessment in Local scoring study. A many-facet
#> rating-scale Rasch model was fit to 768 observations from 48 persons scored on a 4-category
#> scale (1-4). The design included facets for Rater (n = 4), Criterion (n = 4). Facet-level
#> sample sizes were strong (smallest level N = 192), though facets were still estimated as
#> fixed effects with sum-to-zero identification; `analyze_hierarchical_structure()` is
#> available for nesting and variance-component follow-up. The rating scale was described as
#> 0-4 rubric scale.
#> 
#> Estimation settings.
#> The RSM specification was estimated using MML with mfrmr. Model-based precision summaries
#> were available for this run. Person measures are expected a posteriori (EAP) estimates
#> under the marginal person distribution, and residual-based fit statistics are evaluated at
#> these EAP measures rather than at joint maximum likelihood (JMLE) estimates. Recommended
#> use for this precision profile: Use for primary reporting of SE, CI, and reliability in
#> this package.. Optimization converged after 74 function evaluations and 12 gradient
#> evaluations (LogLik = -903.081, AIC = 1822.162, BIC = 1859.312). Terminal gradient sup-norm
#> = 0.2906 (review threshold = 0.0001). Optimizer returned convergence code 0. Constraint
#> settings: noncenter facet = Person; anchored levels = 0 (facets: none); group anchors = 0
#> (facets: none); dummy facets = none.
#> 
#> Results.
#> 
#> Scale functioning.
#> Category usage was adequate (unused categories = 0, low-count categories = 0), and
#> thresholds were ordered. Step/threshold summary: 3 step(s); estimate range = -1.30 to 1.35
#> logits; no disordered steps.
#> 
#> Facet measures.
#> Person measures ranged from -2.02 to 2.33 logits (M = 0.03, SD = 1.01). Rater measures
#> ranged from -0.32 to 0.33 logits (M = 0.00, SD = 0.31). Criterion measures ranged from
#> -0.41 to 0.24 logits (M = 0.00, SD = 0.28).
#> 
#> Fit and precision.
#> Overall mean-square fit was within the 0.5-1.5 screening band (infit MnSq = 0.99, outfit
#> MnSq = 1.01). This band is the package's review convention; published mean-square
#> guidelines differ, and band position is screening evidence rather than a model-validity
#> decision. 1 of 56 elements fell outside the 0.5-1.5 mean-square screening band. Largest
#> misfit signals: Person:P023 (|ZSTD| = 2.09); Criterion:Organization (|ZSTD| = 1.69);
#> Person:P018 (|ZSTD| = 1.45). Criterion reliability = 0.91 (separation = 3.20). Person
#> reliability = 0.90 (separation = 3.06). Rater reliability = 0.92 (separation = 3.51). These
#> are Rasch/FACETS-style separation indices (measure spread relative to measurement error),
#> not inter-rater agreement. The Person row uses EAP measures with posterior SDs, which
#> yields a conservative summary that is not numerically comparable to JMLE-based person
#> reliability from FACETS. Observed inter-rater agreement is reported separately from
#> separation reliability: for Rater, exact agreement = 0.36, expected exact agreement = 0.37,
#> adjacent agreement = 0.83. Element-level 95% confidence intervals (Normal approximation)
#> accompany the measures (CI_Lower / CI_Upper); 56 of 56 rows are flagged CIEligible for
#> primary reporting.
#> 
#> Residual structure.
#> Exploratory residual PCA (overall standardized residual matrix) showed PC1 eigenvalue =
#> 2.10 (13.2% variance), with PC2 eigenvalue = 1.79. Facet-specific exploratory residual PCA
#> showed the largest first-component signal in Rater (eigenvalue = 1.55, 38.7% variance).
#> Heuristic reference bands: EV >= 1.4 (critical minimum), >= 1.5 (caution), >= 2.0 (common),
#> >= 3.0 (strong); variance >= 5% (minor), >= 10% (caution), >= 20% (strong). Strict marginal
#> screening was available as a latent-integrated exploratory check (overall RMSD = 0.00,
#> overall max |standardized residual| = 0.48). The largest strict marginal cell involved
#> Criterion: Language | Cat 1 (standardized residual = 2.47, proportion difference = 0.06).
#> Strict pairwise local-dependence follow-up flagged 0 level pair(s) under the
#> latent-integrated agreement screen. The largest strict pairwise signal involved Criterion:
#> Language vs Organization (ExactStdResidual = -1.45, AdjacentStdResidual = 0.39).
#> 
#> Reporting cautions.
#> Fit-basis note: MnSq/ZSTD fit statistics in this run were computed at EAP person measures,
#> which are shrunken toward the population mean; they are therefore not numerically
#> interchangeable with JMLE-based engines such as FACETS. Refit with method = "JML" when a
#> JMLE-style residual basis is required for external comparison.
```

``` r

apa$section_map[, c("SectionId", "Heading", "Available")]
#>                    SectionId                            Heading Available
#> 1              method_design                    Design and data      TRUE
#> 2          method_estimation                Estimation settings      TRUE
#> 3              results_scale                  Scale functioning      TRUE
#> 4           results_measures                     Facet measures      TRUE
#> 5   results_population_model Latent-regression population model     FALSE
#> 6      results_fit_precision                  Fit and precision      TRUE
#> 7 results_residual_structure                 Residual structure      TRUE
#> 8     results_bias_screening                     Bias screening     FALSE
#> 9           results_cautions                 Reporting cautions      TRUE
```

Interpretation:

- `report_text` is the compact narrative output.
- `section_map` is the machine-readable map of what text blocks are
  available.
- The same contract also feeds captions and notes, which reduces wording
  drift.

## Publication-readiness boundary

The APA route is strongest when it is used as a structured drafting and
review surface. It is not a one-click manuscript generator. Before
moving text into a journal article, inspect the following objects
together:

``` r

res <- mfrm_results(fit, include = "publication")
report <- mfrm_report(res, style = "apa")

report$first_screen
#>                Area            Status         Readiness
#> 1           Overall            review            review
#> 2               Fit            review            review
#> 3        Bias / DFF request_if_needed request_if_needed
#> 4 Linking / anchors request_if_needed request_if_needed
#> 5  Misfit / pathway request_if_needed request_if_needed
#> 6         Precision                ok             ready
#>                                                       MainIssue
#> 1 ok=1; review=1; caveat=0; request_if_needed=3; unavailable=0.
#> 2  ReviewSignalCount = 8; underfit=0; overfit=0; df_sensitive=8
#> 3                                   Evidence was not requested.
#> 4                                   Evidence was not requested.
#> 5                                   Evidence was not requested.
#> 6                               No report-index review signals.
#>                                                                 NextAction
#> 1                                                          Start with Fit.
#> 2 Inspect the primary evidence table and template boundary before writing.
#> 3                       Request this evidence only if the claim is needed.
#> 4                       Request this evidence only if the claim is needed.
#> 5                       Request this evidence only if the claim is needed.
#> 6                  Use the listed template route if this area is reported.
#>                                   PrimaryRoute
#> 1   report$report_index; report$template_index
#> 2                  report$fit_evidence_summary
#> 3          mfrm_results(fit, include = "bias")
#> 4       mfrm_results(fit, include = "linking")
#> 5 mfrm_results(fit, include = "misfit_review")
#> 6            report$precision_evidence_summary
#>                          TemplateRoute                   PlotRoute
#> 1                report$template_index                            
#> 2       report$fit_reporting_templates      plot(res, type = 'qc')
#> 3      report$bias_reporting_templates  plot(res, type = 'tables')
#> 4   report$linking_reporting_templates plot(res, type = "anchors")
#> 5    report$misfit_reporting_templates plot(res, type = 'pathway')
#> 6 report$precision_reporting_templates      plot(res, type = 'qc')
#>                   BoundaryType
#> 1         first_screen_summary
#> 2             fit_not_validity
#> 3 screen_not_fairness_decision
#> 4     anchor_not_drift_absence
#> 5    misfit_not_exclusion_rule
#> 6      precision_not_agreement
report$claim_readiness
#>                              Claim                        Section CurrentStatus
#> 7  Anchor, linking, or drift claim            Anchors and linking not_requested
#> 5            Bias or DFF screening                 Bias screening not_requested
#> 8              Design connectivity       Network and connectivity not_requested
#> 6               Misfit case review      Misfit and pathway review not_requested
#> 3       Fit and precision evidence Fit, separation, and precision        review
#> 9        APA-style manuscript text     APA and manuscript wording     available
#> 10 Appendix or reviewer supplement     Tables, plots, and handoff     available
#> 4             Category functioning           Category functioning     available
#> 2      Diagnostic review completed       First-screen diagnostics     available
#> 1              Model specification           Model and data setup     available
#>                  Readiness
#> 7  needs_requested_section
#> 5  needs_requested_section
#> 8  needs_requested_section
#> 6  needs_requested_section
#> 3        write_with_caveat
#> 9                    ready
#> 10                   ready
#> 4                    ready
#> 2                    ready
#> 1                    ready
#>                                                                                                                                                                EvidenceNeeded
#> 7                                                                                     Anchor-readiness output for one fit; multiple fitted waves/forms for drift or equating.
#> 5                                                                                             Facet-level bias table and any explicitly selected interaction or DFF contrast.
#> 8                                                                                                                    Network/connectivity review and design overlap evidence.
#> 6                                                                                                   Unexpected-response rows, displacement evidence, and pathway-map context.
#> 3  Selected MnSq threshold profile, observed fit-status counts, ZSTD convention, fit df, df-sensitivity rows, separation, reliability, strata, and uncertainty/context notes.
#> 9                                                                                                           Supported APA output object or a manually edited report template.
#> 10                                                                               Collected result tables, plot routes, replay code, and a written-files manifest if exported.
#> 4                                                                                                               Rating-scale, category-structure, or category-curve evidence.
#> 2                                                                                                                A diagnostics object, triage rows, and any key warning text.
#> 1                                                                                    Model, method, facets, score coding, categories, sample size, and missing-data handling.
#>                                                                                                                               SuggestedWording
#> 7                                                                            Report anchor readiness separately from drift or equating claims.
#> 5                                                Use screening language unless a targeted contrast and substantive review have been completed.
#> 8                                                          Use connectivity language to describe design support and sparseness, not model fit.
#> 6                                                                     Frame misfit rows as case-review prompts and report the follow-up basis.
#> 3  Report MnSq fit, ZSTD standardization, separation, and reliability as separate evidence streams with the selected threshold profile stated.
#> 9                                                                 Treat generated APA-style text as a draft and edit against the study design.
#> 10                                                               Provide tables and replay routes so readers can inspect the evidence surface.
#> 4                                               Describe whether score categories behaved as intended and identify any category-level caveats.
#> 2                                                     State that diagnostics were inspected, then report only the specific supported findings.
#> 1                                          Report the fitted MFRM specification, estimation method, scoring scale, and facet roles explicitly.
#>                                                                                                                                                       FollowUp
#> 7                                          Use mfrm_results(fit, include = "linking"); for drift/equating use detect_anchor_drift() or build_equating_chain().
#> 5                                                                   Use mfrm_results(fit, include = "bias") and then estimate_bias() for explicit facet pairs.
#> 8                                                                                  Use mfrm_results(fit, include = "network") and build_mfrm_network_review().
#> 6                                                                    Use mfrm_results(fit, include = "misfit_review") and build_misfit_casebook() when needed.
#> 3  Use report$fit_evidence_summary, report$fit_threshold_sensitivity, report$fit_df_sensitivity_summary, precision_review_report(), and facets_fit_df_guide().
#> 9                                                                                       Use mfrm_results(fit, include = "publication") or build_apa_outputs().
#> 10                                                        Use build_summary_table_bundle(res), export_mfrm_results(res), or mfrm_report(res, output = "html").
#> 4                                                                         Use rating_scale_table(), category_structure_report(), and category_curves_report().
#> 2                                                                                       Inspect summary(res)$triage and summary(res$diagnostics)$key_warnings.
#> 1                                                                            Use specifications_report(fit) and the analysis script for final methods wording.
#>                                                                                                                       Boundary
#> 7                                                                  Do not infer drift or equating from a single fitted object.
#> 5                                                               Do not present screen positives as final fairness conclusions.
#> 8                                                  Connectivity evidence does not replace fit, precision, or bias diagnostics.
#> 6                                                          Do not use observation-level misfit as an automatic exclusion rule.
#> 3  Do not reduce these indices to one pass/fail claim, and do not interpret a df-sensitive ZSTD flag without MnSq and context.
#> 9                                                   Generated prose is not a substitute for study-specific reporting judgment.
#> 10                                                             Appendix files preserve evidence; they do not add new analyses.
#> 4                                           Category evidence supports score-scale review but not a standalone validity claim.
#> 2                                                 Diagnostic availability is a starting point, not a global quality guarantee.
#> 1                                                    This documents the analysis setup; it is not validity evidence by itself.
#>    Style
#> 7    apa
#> 5    apa
#> 8    apa
#> 6    apa
#> 3    apa
#> 9    apa
#> 10   apa
#> 4    apa
#> 2    apa
#> 1    apa
report$report_gaps
#>   Priority           GapType                        Section CurrentStatus
#> 4        2     not_requested            Anchors and linking not_requested
#> 2        2     not_requested                 Bias screening not_requested
#> 3        2     not_requested      Misfit and pathway review not_requested
#> 6        2     not_requested       Network and connectivity not_requested
#> 5        2     not_requested               Response-time QC not_requested
#> 1        3 caveated_evidence Fit, separation, and precision        review
#>                                                                                                    RecommendedAction
#> 4               Rebuild the result with mfrm_results(fit, include = "linking") before writing anchor-readiness text.
#> 2           Rebuild the result with mfrm_results(fit, include = "bias") before writing bias or fairness-screen text.
#> 3 Rebuild the result with mfrm_results(fit, include = "misfit_review") before writing observation-level misfit text.
#> 6                   Rebuild the result with mfrm_results(fit, include = "network") before writing connectivity text.
#> 5         Request the relevant mfrm_results() section or call the route-specific helper before reporting this claim.
#> 1                            Write only a caveated claim and inspect the route-specific table before manuscript use.
#>                                                                                                                            Route
#> 4                                                            mfrm_results(fit, include = "linking"); plot(res, type = "anchors")
#> 2                                                mfrm_results(fit, include = "bias"); estimate_bias(); bias_interaction_report()
#> 3                                                      mfrm_results(fit, include = "misfit_review"); plot(res, type = "pathway")
#> 6                                                            mfrm_results(fit, include = "network"); build_mfrm_network_review()
#> 5 mfrm_results(fit, include = "response_time", response_time = ..., response_time_data = ...); plot(res, type = "response_time")
#> 1                                            summary(res$components$precision_review); precision_review_report(fit, diagnostics)
#>                                                                                                           Reason
#> 4                 Drift and equating require multiple fitted forms or waves; they are not inferred from one fit.
#> 2                      Treat positive screens as prompts for substantive review, not final fairness conclusions.
#> 3                                       Observation-level misfit is not an automatic exclusion or bias decision.
#> 6                              Connectivity evidence does not replace model fit, precision, or bias diagnostics.
#> 5 Response-time review does not alter MFRM estimates, fit speed parameters, or define automatic exclusion rules.
#> 1                                Do not collapse fit, separation, reliability, and ZSTD into one pass/fail rule.
head(report$template_index[, c(
  "Area", "Topic", "BoundaryType", "ClaimStrength", "RecommendedUse"
)])
#>                Area                                 Topic
#> 1        Bias / DFF       Bias/DFF evidence not requested
#> 2 Linking / anchors        Linking evidence not requested
#> 3               Fit             Threshold-profile wording
#> 4               Fit               ZSTD-convention wording
#> 5               Fit           DF/ZSTD sensitivity wording
#> 6  Misfit / pathway Misfit/pathway evidence not requested
#>                   BoundaryType                  ClaimStrength
#> 1 screen_not_fairness_decision not_supported_without_followup
#> 2     anchor_not_drift_absence not_supported_without_followup
#> 3             fit_not_validity              write_with_caveat
#> 4             fit_not_validity              write_with_caveat
#> 5             fit_not_validity              write_with_caveat
#> 6    misfit_not_exclusion_rule              write_with_caveat
#>                    RecommendedUse
#> 1  targeted_followup_before_claim
#> 2 request_evidence_before_writing
#> 3      methods_or_appendix_caveat
#> 4      methods_or_appendix_caveat
#> 5      methods_or_appendix_caveat
#> 6 request_evidence_before_writing
```

For a high-stakes manuscript, treat
[`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
and `mfrm_report(style = "apa")` as conservative scaffolding. Stronger
journal claims still require a defensible study design, cited
measurement rationale, adequate precision evidence, linked or balanced
design evidence where relevant, and substantive interpretation written
in the language of the target journal. Do not report `DraftReady`,
`ReadyForAPA`, or `ClaimStrength` as if they were formal acceptance
decisions; use them to decide what wording is currently safe and which
caveats must remain visible.

When the target is a local HTML/CSV/replay bundle rather than an
interactive review object, use
[`export_mfrm_bundle()`](https://ryuya-dot-com.github.io/mfrmr/reference/export_mfrm_bundle.md)
directly from the fitted object:

``` r

bundle <- export_mfrm_bundle(
  fit,
  diagnostics = diag,
  output_dir = "mfrmr-report-bundle",
  prefix = "analysis01",
  include = c(
    "core_tables", "checklist", "dashboard", "apa",
    "summary_tables", "manifest", "script", "html"
  ),
  overwrite = TRUE
)

bundle$written_files[bundle$written_files$Format == "html", ]
```

## 4. Build tables from the same contract

Use
[`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
when you want reproducible handoff tables without rebuilding captions or
notes by hand.

``` r

tbl_summary <- apa_table(fit, which = "summary")
tbl_reliability <- apa_table(fit, which = "reliability", diagnostics = diag)

tbl_summary$caption
#> [1] "Table 1\nFacet Summary (Measures, Precision, Fit, Reliability)"
tbl_reliability$note
#> [1] "Separation and reliability are based on observed variance, measurement error, and adjusted true variance. Overall fit: infit MnSq = 0.99, outfit MnSq = 1.01. Rater facet (Rater) reliability = 0.92, separation = 3.51. Observed inter-rater agreement is reported separately from separation reliability: for Rater, exact agreement = 0.36, expected exact agreement = 0.37, adjacent agreement = 0.83."
```

The actual table data are stored in `tbl_summary$table` and
`tbl_reliability$table`.

## 5. Add figure-ready visual data

For reporting workflows,
[`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md)
is the bridge between statistical results and figure-ready plot data.

``` r

vis <- build_visual_summaries(
  fit,
  diagnostics = diag,
  threshold_profile = "standard"
)

names(vis)
#>  [1] "warning_map"        "summary_map"        "warning_counts"    
#>  [4] "summary_counts"     "plot_payloads"      "public_plot_routes"
#>  [7] "crosswalk"          "gpcm_boundary"      "branch"            
#> [10] "style"              "threshold_profile"
names(vis$warning_map)
#>  [1] "wright_map"                       "pathway_map"                     
#>  [3] "facet_distribution"               "step_thresholds"                 
#>  [5] "category_curves"                  "observed_expected"               
#>  [7] "fit_diagnostics"                  "fit_zstd_distribution"           
#>  [9] "misfit_levels"                    "strict_marginal_fit"             
#> [11] "strict_pairwise_local_dependence" "residual_pca_overall"            
#> [13] "residual_pca_by_facet"
```

## 6. Reporting route when interaction screening matters

When bias or local interaction screens matter, keep the wording
conservative. The package treats these outputs as screening-oriented
unless the current precision and design evidence justify stronger
claims.

``` r

bias_df <- load_mfrmr_data("example_bias")

fit_bias <- fit_mfrm(
  bias_df,
  person = "Person",
  facets = c("Rater", "Criterion"),
  score = "Score",
  method = "MML",
  model = "RSM",
  quad_points = 7
)

diag_bias <- diagnose_mfrm(fit_bias, residual_pca = "none")
bias <- estimate_bias(fit_bias, diag_bias, facet_a = "Rater", facet_b = "Criterion")
apa_bias <- build_apa_outputs(fit_bias, diagnostics = diag_bias, bias_results = bias)

apa_bias$section_map[, c("SectionId", "Available", "Heading")]
#>                    SectionId Available                            Heading
#> 1              method_design      TRUE                    Design and data
#> 2          method_estimation      TRUE                Estimation settings
#> 3              results_scale      TRUE                  Scale functioning
#> 4           results_measures      TRUE                     Facet measures
#> 5   results_population_model     FALSE Latent-regression population model
#> 6      results_fit_precision      TRUE                  Fit and precision
#> 7 results_residual_structure      TRUE                 Residual structure
#> 8     results_bias_screening      TRUE                     Bias screening
#> 9           results_cautions      TRUE                 Reporting cautions
```

## 7. Keep model comparison as a reporting review

When candidate models are fitted, separate same-data comparison from the
scoring interpretation.
[`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
provides the fit-statistic table;
[`build_model_choice_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_model_choice_review.md)
attaches model roles, downstream route boundaries, and cautious wording.
Convert the review to a summary-table bundle when the comparison needs
to appear in an appendix or exported report.

``` r

cmp <- compare_mfrm(RSM = fit_rsm, PCM = fit_pcm, GPCM = fit_gpcm)
review <- build_model_choice_review(
  RSM = fit_rsm,
  PCM = fit_pcm,
  GPCM = fit_gpcm,
  run_weighting_review = TRUE
)
model_choice_tables <- build_summary_table_bundle(
  review,
  appendix_preset = "recommended"
)

cmp[, c("Model", "LogLik", "AIC", "BIC", "ICComparable")]
model_choice_tables$table_index
```

For bounded `GPCM`, report the fit as a slope-aware sensitivity model
unless the score interpretation explicitly justifies
discrimination-based reweighting. Do not use AIC/BIC alone as an
operational-scoring decision.

## 8. Report latent regression as a population-model branch

Latent-regression fits expose their reportable surface through the fit
summary: `population_overview`, `population_coefficients`,
`population_coding`, and `caveats`. Coefficients are conditional-normal
population-model parameters, not post-hoc regressions on EAP or MLE
scores.

``` r

s_pop <- summary(fit_pop)
s_pop$population_overview
s_pop$population_coefficients
s_pop$population_coding
s_pop$caveats
```

In this release, keep latent-regression claims to the documented
one-dimensional `MML` `RSM` / `PCM` route. Report the population
formula, coding/contrast handling, population policy, and any
omitted-person or omitted-row counts; do not imply multidimensional
latent regression, Wald-test inference, or posterior predictive checking
from these tables alone.

## Recommended sequence

For a compact manuscript-oriented route:

1.  [`fit_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/fit_mfrm.md)
2.  [`diagnose_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/diagnose_mfrm.md)
3.  [`precision_review_report()`](https://ryuya-dot-com.github.io/mfrmr/reference/precision_review_report.md)
4.  [`reporting_checklist()`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
5.  [`build_apa_outputs()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
6.  [`apa_table()`](https://ryuya-dot-com.github.io/mfrmr/reference/apa_table.md)
7.  [`build_visual_summaries()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_visual_summaries.md)
8.  [`compare_mfrm()`](https://ryuya-dot-com.github.io/mfrmr/reference/compare_mfrm.md)
    -\>
    [`build_model_choice_review()`](https://ryuya-dot-com.github.io/mfrmr/reference/build_model_choice_review.md)
    when candidate-model comparisons are part of the manuscript

## Related help

- [`help("mfrmr_reporting_and_apa", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reporting_and_apa.md)
- [`help("mfrmr_reports_and_tables", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/reference/mfrmr_reports_and_tables.md)
- [`help("reporting_checklist", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/reference/reporting_checklist.md)
- [`help("build_apa_outputs", package = "mfrmr")`](https://ryuya-dot-com.github.io/mfrmr/reference/build_apa_outputs.md)
