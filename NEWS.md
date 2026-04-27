# mfrmr 0.1.6

This release adds empirical-Bayes shrinkage for small-N facets, a
hierarchical-structure and sample-adequacy audit layer, integrated
missing-code pre-processing, APA output adapters for Word / HTML,
model-estimated two-way non-person facet interactions, confidence-interval
propagation through the plot surface and the ICC
reporting family, and expanded reproducibility manifests. Six bug
fixes close issues that affected bias statistics, ZSTD sign, input
validation, and graphical state hygiene.

## Default changes (three breaking flips)

Three default values change in this release. Scripts that explicitly
pass the old value are unaffected; scripts that rely on the default
should be reviewed.

- `diagnose_mfrm(diagnostic_mode = ...)` default flips from `"legacy"`
  to `"both"`. Strict marginal screens are produced automatically for
  `RSM` / `PCM` fits without the caller having to request them.
  Pass `diagnostic_mode = "legacy"` to restore the earlier behaviour.
- `plot(fit)` default output is now the Wright map alone, returned as
  an `mfrm_plot_data` object. The previous three-plot overview
  (Wright + pathway + CCC) remains available via
  `plot(fit, type = "bundle")`, which returns an `mfrm_plot_bundle`
  with the same three slots.
- `fit_mfrm(quad_points = ...)` default increases from `15` to `31`
  so a default MML fit is stable enough for direct manuscript
  reporting. Pass `quad_points = 15` (or `7`) to restore the earlier
  iteration speed for exploratory scans.

## New features

### Model-estimated facet interactions

`fit_mfrm()` gains `facet_interactions` for confirmatory two-way interactions
between non-person facets in `RSM` and `PCM` fits, for example
`facet_interactions = "Rater:Criterion"`. These terms are estimated
simultaneously with the main MFRM parameters as fixed effects under zero
marginal-sum constraints, contributing `(A - 1) * (B - 1)` free parameters for
an `A x B` interaction block.

New supporting pieces:

- `interaction_effect_table(fit)` returns one row per interaction cell, with
  estimates, weighted counts, sparse-cell flags, and the identification note.
- `summary(fit)` reports a compact interaction overview when interaction terms
  are present.
- `compare_mfrm(..., nested = TRUE)` now recognizes same-family additive-vs-
  interaction comparisons as nested when all other structural settings match
  and the smaller model's interaction set is a subset of the larger model's
  set.

The feature is intentionally narrow for the initial CRAN-facing release:
person-involving interactions, higher-order interactions, GPCM interactions,
and random-effect facet interactions are deferred. Residual bias screening via
`estimate_bias()` and `estimate_all_bias()` remains separate from these
model-estimated fixed effects.

### Empirical-Bayes facet shrinkage

`fit_mfrm(..., facet_shrinkage = "empirical_bayes")` applies
James-Stein / empirical-Bayes shrinkage to each non-person facet's
fixed-effect estimates. `fit$facets$others` gains `ShrunkEstimate`,
`ShrunkSE`, and `ShrinkageFactor` columns, and `fit$shrinkage_report`
summarises the per-facet prior variance, mean shrinkage, and
effective degrees of freedom.

The estimator is the classical method-of-moments form (Efron & Morris,
1973):

- \eqn{\hat{\tau}^2 = \max(0, K^{-1}\sum_j \hat{\delta}_j^2 -
  \overline{\mathrm{SE}^2})}, using the raw second moment under
  mfrmr's sum-to-zero identification (the facet mean is exactly 0 by
  construction, so no degree of freedom is consumed).
- \eqn{B_j = \mathrm{SE}_j^2 / (\hat{\tau}^2 + \mathrm{SE}_j^2)}
  (shrinkage factor).
- \eqn{\hat{\delta}_j^{EB} = (1 - B_j)\hat{\delta}_j} and
  \eqn{\mathrm{SE}_j^{EB} = \sqrt{(1 - B_j) \mathrm{SE}_j^2}}
  (posterior mean / SE; the posterior SE treats \eqn{\hat{\tau}^2} as
  known, omitting the Morris (1983) correction for \eqn{\hat{\tau}^2}
  uncertainty).

Two post-hoc helpers make shrinkage available to existing fits:

- `apply_empirical_bayes_shrinkage(fit, facet_prior_sd = NULL,
  shrink_person = FALSE)` augments an existing `mfrm_fit`.
- `shrinkage_report(fit)` returns the per-facet summary table.

The `"laplace"` alias currently routes to the empirical-Bayes path
and is reserved for a future penalised-MML implementation.

Integration: `summary(fit)` exposes `FacetShrinkage` and
`FacetShrinkageTau2Mean`; `build_apa_outputs()` adds a Method-section
sentence naming the mode, mean \eqn{\hat{\tau}^2}, and mean shrinkage
with a Efron & Morris (1973) citation; `build_mfrm_manifest()` gains
a `shrinkage_audit` table; `reporting_checklist()` gains an
"Empirical-Bayes shrinkage" item.

### Hierarchical structure and sample-adequacy audit

Five new exported functions describe the observed design, flag
small-N facet levels, and quantify ICC / design effect. Estimation
remains fixed-effects MFRM; these helpers are purely descriptive and
do not alter the fit.

- `detect_facet_nesting(data, facets, person)` classifies every
  ordered pair of facets (plus Person, optionally) as *Fully nested*,
  *Near-perfectly nested*, *Partially nested*, or *Crossed* using the
  conditional-entropy index `1 - H(B|A)/H(B)`.
- `facet_small_sample_audit(fit)` returns per-level
  `N / Estimate / SE / Infit / Outfit / SampleCategory` for every
  facet. `SampleCategory` is one of `"sparse"` (< 10), `"marginal"`
  (< 30), `"standard"` (< 50), `"strong"` (>= 50). Thresholds follow
  Linacre (1994) and are configurable.
- `compute_facet_icc(data, facets, score, person)` fits
  `lme4::lmer(Score ~ 1 + (1|Person) + (1|Facet1) + ...)` and reports
  the variance-component share per facet. Person uses the Koo & Li
  (2016) reliability bands; other facets use a "variance share" label
  (Trivial / Small / Moderate / Large).
- `compute_facet_design_effect(data, facets, icc_table)` computes the
  Kish (1965) `Deff = 1 + (m - 1) * rho` and effective N per facet.
- `analyze_hierarchical_structure(data, facets, ...)` bundles the
  four helpers above and (when `igraph` is available) a bipartite
  connectivity summary over Person * facet-level edges.

Fit- and reporting-stack integration:

- `fit$summary` carries `FacetSampleSizeFlag`, `FacetMinLevelN`, and
  `FacetSparseCount`.
- `reporting_checklist()` gains two items: "Facet sample-size
  adequacy" (auto-ready when the flag is `"standard"` / `"strong"`)
  and "Hierarchical structure audit" (ready when the user passes
  `hierarchical_structure = analyze_hierarchical_structure(...)`).
- `build_apa_outputs()` adds a Method sentence naming the
  sample-adequacy band and linking to `facet_small_sample_audit()`.
- `build_mfrm_manifest()` gains a `hierarchical_audit` table.
- `recommend_mfrm_design()$caveats` now points users at the three
  post-fit audit functions.

Optional dependencies `igraph` and `lme4` move to `Suggests`; when
either is absent the relevant report is omitted with a clear
`message()`.

### Missing-code pre-processing in the fit call

`fit_mfrm()` now accepts `missing_codes = NULL | TRUE | "default" |
<character vector>`, forwarded to `prepare_mfrm_data()`,
`audit_mfrm_anchors()`, and `describe_mfrm_data()`. When active, the
standard FACETS / SPSS / SAS sentinels (`"99"`, `"999"`, `"-1"`,
`"N"`, `"NA"`, `"n/a"`, `"."`, `""` by default, or any caller-
supplied set) are converted to `NA` on the `person`, `facets`, and
`score` columns before any downstream processing. Replacement counts
are recorded in `fit$prep$missing_recoding` and surfaced through
`build_mfrm_manifest()$missing_recoding`. The default
(`missing_codes = NULL`) is strictly backward-compatible.

A standalone `recode_missing_codes()` helper is also exported for
users who prefer to recode before calling `fit_mfrm()`.

### APA output adapters

- `as_kable.apa_table()` converts an `apa_table` into a
  `knitr::kable()` object with the caption above and the note below.
  When `kableExtra` is installed the note becomes a proper table
  footnote; otherwise it is appended as Markdown.
- `as_flextable.apa_table()` produces a `flextable::flextable()`
  with caption and note pre-wired, suitable for `officer` / Word /
  PowerPoint exports.
- Two generics, `as_kable()` and `as_flextable()`, are exported so
  other mfrmr classes (or third-party wrappers) can register
  compatible methods.
- `build_apa_outputs(..., context = list(output_mode = "reflow"))`
  now returns the Method / Results paragraphs as single long lines
  per sentence-joined paragraph, which is the format Word / Quarto /
  RMarkdown prefer. The default `"wrapped"` keeps the 92-column
  layout for console readability.

`kableExtra` and `flextable` join `Suggests`.

### Shrinkage and audit visualisations

- `plot(fit, type = "shrinkage")` renders a horizontal forest-style
  dotplot of original and shrunk facet-level estimates, with arrows
  indicating shrinkage direction, optional 95 % CI error bars
  (`show_ci = TRUE`), and a reference line at zero. When shrinkage
  is not applied the plot becomes a placeholder inviting the user to
  re-fit with `facet_shrinkage = "empirical_bayes"`.
- `plot.mfrm_facet_sample_audit()` draws a horizontal bar chart of
  per-level observation counts coloured by Linacre band, with dashed
  vertical lines at the thresholds.
- `plot.mfrm_facet_nesting()` renders the pairwise nesting index as
  a heatmap with numeric cell labels.

All three methods follow the existing
`preset = c("standard", "publication", "compact")` convention and
use base-R graphics.

### Confidence intervals across the plot surface

- `plot_bias_interaction(show_ci = TRUE, ci_level = 0.95)` draws
  `BiasSize +/- z * SE` whiskers on the scatter and ranked views.
- `plot_displacement(show_ci = TRUE)` draws
  `Displacement +/- z * DisplacementSE` whiskers in the lollipop
  view.
- `plot_fair_average(show_ci = TRUE)` draws fair-average CI whiskers
  on the observed-score scale using a delta-method propagation
  `SE_fair = Var(X | Measure) * ModelSE` from the logit `Measure`
  error. Rows near a rating boundary (where the implied score
  variance is effectively zero) are excluded from the whiskers,
  drawn as open circles, and counted in the subtitle.
- `compute_facet_icc(ci_method = "profile" | "boot")` returns ICC
  confidence intervals in new `ICC_CI_Lower` / `ICC_CI_Upper` /
  `ICC_CI_Level` / `ICC_CI_Method` columns, propagated through
  `analyze_hierarchical_structure()` and drawn as whiskers on
  `plot.mfrm_hierarchical_structure(type = "icc")`. The default
  `ci_method = "none"` keeps the point-estimate-only behaviour.

### Additional visualisations

Fourteen additions across the plot surface, all base-R / additive
(default behaviours unchanged):

- **`plot_threshold_ladder()`** (new) — vertical ladder of
  Rasch-Andrich thresholds for RSM and PCM, with disordered-step
  crossings highlighted in the preset's `fail` colour. The returned
  payload exposes per-step `Group / Step / Threshold / Disordered`
  rows.
- **`plot(fit, type = "ccc_overlay")`** (new branch on
  `plot.mfrm_fit`) — observed category proportions binned by person
  measure overlaid on the model CCC curves, for an at-a-glance
  model-data fit visual.
- **`plot_person_fit()`** (new) — FACETS Table 6 style per-person
  Infit / Outfit bubble with the standard 0.5-1.5 acceptance band
  (Linacre, 2002).
- **`plot_bias_interaction(plot = "heatmap")`** (new mode) — diverging
  Rater x Criterion grid coloured by bias size, with flagged cells
  outlined for emphasis.
- **`plot(fit, type = "wright", group = ..., group_data = ...)`**
  (new option) — overlays per-group person-density curves on the
  Wright map's left density column, useful for DIF / DFF screening.
- **`plot_rater_severity_profile()`** (new) — per-rater severity
  ranking with CI whiskers and optional `+/-0.5` (gentle) and
  `+/-1.0` (strict) guidance bands for rater-training feedback.
- **`plot_anchor_drift(type = "forest")`** (new mode) — per-wave
  anchor-element CI forest with point estimate + `z * SE` whiskers.
- **`plot.mfrm_equating_chain()`** (new S3 method) — `type =
  "common_anchors"` (default bar chart of pairwise common-anchor
  counts) and `type = "graph"` (bipartite Wave x anchor element
  graph via `igraph`).
- **`plot_apa_figure_one()`** (new) — 2x2 publication composite
  bundling Wright map, rater severity profile, threshold ladder, and
  a one-panel summary block.
- **`plot_dif_summary()`** (new) — compact effect-size summary for
  [analyze_dff()] / [analyze_dif()] with ETS A / B / C colour coding.
- **`plot_guttman_scalogram()`** (new) — Person x facet-level
  observed-category matrix, ordered by person measure and location
  measure, with unexpected cells highlighted.
- **`plot_residual_qq()`** (new) — normal Q-Q plot of person-level
  standardized residuals for distributional misfit diagnostics.
- **`plot_rater_trajectory()`** (new) — per-rater severity
  trajectory across an ordered wave / session variable with CI
  whiskers. Accepts a named list of fits.
- **`plot_rater_agreement_heatmap()`** (new) — symmetric rater x
  rater agreement matrix colored by exact agreement (default) or the
  Pearson-style `Corr` column from `interrater_agreement_table()`.
  Quadratic-weighted kappa is not currently computed by that helper
  and is therefore not exposed as a `metric` option.

`igraph` is already in `Suggests`; the equating-graph view falls
back to the bar chart when `igraph` is not installed.

### Expanded test coverage

Direct regression tests for the 0.1.6 additions:

- `test-attach-diagnostics.R` — 18 assertions covering the
  `attach_diagnostics = TRUE` merge, type validation, idempotence,
  and MML / JML parity.
- `test-icc-ci-method.R` — 25 assertions covering
  `compute_facet_icc(ci_method = "profile" / "boot")`, bootstrap
  seed reproducibility, range validation, deprecated
  `icc_ci_method` alias, and `plot.mfrm_hierarchical_structure(type
  = "icc")` integration.
- `test-ci-api-consistency.R` — 21 assertions covering the
  `lifecycle::deprecate_warn()` path for `conf_level`, `show_ci` /
  `ci_level` on `plot_fair_average` / `plot_displacement` /
  `plot_bias_interaction`, and CI column schema.
- `test-messaging-and-guards.R` — 8 assertions covering the single
  "Rating range inferred" message, `analyze_dff(method = "refit")`
  `missing(diagnostics)` guard, and `missing_codes` integration.
- `test-lme4-confint-helper.R` — 17 assertions covering
  `.lme4_confint_components()` across terse and verbose lme4
  row-name conventions.
- `test-plotting-extras.R` + `test-plotting-screening.R` — 78
  assertions covering all 14 new plot helpers.

### Internal architecture

`row_max_fast()` and the three `category_prob_*` polytomous-response
kernels are now in `R/core-category-probabilities.R` instead of
inline in `R/mfrm_core.R`. Pure file-level reorganization; no
behaviour change. The remaining structural split of `mfrm_core.R`
(likelihood / optimizer / EM / gradients / prep / report tables) is
scheduled for a future release.

### Package-level MnSq misfit threshold

`mfrm_misfit_thresholds()` returns the lower / upper Linacre acceptance
band that mfrmr screens use when flagging element-level Infit / Outfit
MnSq misfit. Defaults are `c(lower = 0.5, upper = 1.5)` and can be
overridden globally via R options:

- `options(mfrmr.misfit_lower = 0.7)`
- `options(mfrmr.misfit_upper = 1.3)`

Helpers that consume the band include `summary(diagnose_mfrm(...))`
(`misfit_flagged` block + `key_warnings` auto-flag),
`build_misfit_casebook()` (the new `element_fit` source family),
the bias / misfit narrative inside `build_apa_outputs()`, and
`facet_quality_dashboard()` when `misfit_warn = NULL`. Setting the
options once at the top of an analysis script therefore changes
every downstream screen at once.

### Additional secondary plots

Four new public helpers extend the diagnostic plot family:

- `plot_local_dependence_heatmap(fit)` -- N x N Q3-style
  pairwise residual correlation heatmap between facet levels.
  Complements `plot_marginal_pairwise()` by showing every pair on a
  shared color scale rather than a top-N bar list.
- `plot_reliability_snapshot(fit)` -- compact facet x reliability /
  separation / strata bar overview built from
  `diagnostics$reliability`. Useful as a single small figure for "are
  persons / raters / criteria distinguishable?".
- `plot_residual_matrix(fit)` -- person x facet-level standardized
  residual heatmap. Complements `plot_guttman_scalogram()` by showing
  residual sign and magnitude rather than the raw response code.
- `plot_shrinkage_funnel(fit)` -- empirical-Bayes shrinkage
  caterpillar / funnel for fits augmented via
  `apply_empirical_bayes_shrinkage()`.

`plot_bubble()` gains a `view = c("measure", "infit_outfit")`
argument. The default `"measure"` keeps the historical Measure
(logit) x MnSq bubble layout; `view = "infit_outfit"` switches to the
Winsteps Table 30 layout (Infit MnSq on x, Outfit MnSq on y, bubble
size defaults to `N`). Both views return the same `mfrm_plot_data`
contract.

`plot_dif_heatmap(draw = FALSE)` now returns an `mfrm_plot_data` payload
whose `data$matrix` is the metric matrix (was previously the bare
matrix only).

`plot_information(..., draw = FALSE)` payloads now include a
`series` field listing which curves the legend describes
(`"Information"`, `"SE"`, or both for `type = "both"`), so downstream
ggplot2 re-renderers can map the right column without inspecting
`type` manually.

### Reporting surface enrichments

- `summary(diagnose_mfrm(...))` now prints the **fixed-effect chi-square
  block** ("are all elements equal?") directly from
  `diag$facets_chisq` (`Facet`, `Levels`, `MeanMeasure`, `SD`,
  `FixedChiSq`, `FixedDF`, `FixedProb`, plus the random-effect
  counterparts when present) and the **inter-rater agreement summary**
  (Exact / Expected / Adjacent agreement, MeanAbsDiff, MeanCorr,
  RaterSeparation, RaterReliability) instead of leaving them in the
  diagnostics object only. The new `summary(diag)$facets_chisq` and
  `summary(diag)$interrater` slots also expose the same tables for
  programmatic use.
- `summary(diagnose_mfrm(...))$key_warnings` now names the worst
  MnSq-misfit elements (e.g. `MnSq misfit: Person:P023 (Infit=1.70,
  Outfit=2.40; outside 0.5-1.5).`) and prints a dedicated
  `MnSq misfit` block showing every flagged element. Threshold pair
  is exposed at `summary(diag)$misfit_thresholds` and is steered by
  `mfrm_misfit_thresholds()` (see above).
- `summary(diagnose_mfrm(...))` now prints a **category usage block**
  (one row per observed score with `Count`, `AvgMeasure`, and a
  `Disordering` flag when the average measure decreases across
  adjacent categories). Exposed programmatically at
  `summary(diag)$category_usage`.
- `summary(fit_mfrm(...))` now prints a **targeting block**
  (`Person mean - Facet mean`, plus `PersonSD` / `FacetSD` /
  `SpreadRatio`) for every non-person facet. Under the package's
  sum-to-zero identification this collapses to the person mean by
  construction; the row labels make that explicit and the spread
  ratio surfaces whether persons or facets dominate the test scale.
- `summary(estimate_bias(...))` now reports **Bonferroni** and
  **Holm** significant-cell counts alongside the raw screen-positive
  count. Both are exposed in `summary(bias)$overview` as
  `BonferroniSignificant` and `HolmSignificant`.
- `print(fit)` and `print(summary(fit))` now show an **"Attached
  diagnostics"** line when `fit_mfrm(..., attach_diagnostics = TRUE)`
  has merged per-element fit columns onto `fit$facets`. The
  attach-diagnostics path now extends to the person-facet table,
  so per-person `Infit`, `Outfit`, `InfitZSTD`, `OutfitZSTD`, and
  `PtMeaCorr` columns are visible in `summary(fit)$person_high`
  and `summary(fit)$person_low`.

### Internal architecture: file split

To improve navigability of the core estimation engine, four
self-contained sections moved out of `R/mfrm_core.R` into focused
files. All functions remain internal and the public API is
unchanged.

- `R/core-likelihood.R` -- polytomous Rasch likelihoods and
  cumulative response-probability helpers.
- `R/core-data-prep.R` -- data validation, indexing, and small
  formatting utilities.
- `R/core-anchor-audit.R` -- anchor-table reading, normalization,
  and connectivity / overlap audit.
- `R/core-optimizer.R` -- optim() / EM dispatch and MML-EM
  scaffolding.

`R/api-simulation.R` similarly grew an
`R/api-simulation-future-branch.R` companion file holding the
future-branch design-schema layer. Public simulation entry points
(`simulate_mfrm_data`, `evaluate_mfrm_design`,
`evaluate_mfrm_diagnostic_screening`,
`evaluate_mfrm_signal_detection`) remain in `R/api-simulation.R`.

`R/api-plotting-extras2.R` was renamed to
`R/api-plotting-screening.R` to drop the numerical suffix in favour
of a functional name; tests follow the same rename.

A new `tests/testthat/helper-fixtures.R` exposes
`make_toy_fit()` / `make_toy_diagnostics()` / `local_toy_fit()`
helpers so future tests can reuse the standard `example_core` fit
without retyping the `load_mfrmr_data()` + `fit_mfrm()` +
`diagnose_mfrm()` chain.

### Replay-script overhaul

`export_mfrm_bundle()` and `build_mfrm_replay_script()` now write a
self-contained replay package:

- The generated `replay.R` includes every argument that affected the
  original `fit_mfrm()` call. Earlier 0.1.x scripts silently dropped
  `missing_codes`, `mml_engine`, `slope_facet`, `anchor_policy`,
  `min_common_anchors`, `min_obs_per_*`, `facet_shrinkage`,
  `facet_prior_sd`, `shrink_person`, and `attach_diagnostics`, so
  fits that depended on those arguments did not actually replay.
- `fit_mfrm()` now records its inputs in
  `fit$config$replay_inputs` (post `match.arg`) so the bundle
  generator has a single source of truth.
- The replay script begins with a `utils::packageVersion("mfrmr")`
  guard that warns when the installed version differs from the
  recorded one.
- `export_mfrm_bundle(..., data = ...)` accepts the original analysis
  data; when supplied, the data is written into the bundle as
  `<prefix>_replay_data.csv` and the replay script reads from that
  co-located file. The recorded input hash is now computed against
  the user's original data (not the package's internal `prep$data`,
  which carries synthesised columns), so users can verify their CSV
  matches the recorded fingerprint.
- A new `tests/testthat/test-replay-roundtrip.R` actually sources the
  generated replay script in a fresh environment and compares the
  reproduced log-likelihood and person estimates to the original.

### Performance: `diagnose_mfrm()` on large designs

`calc_interrater_agreement()` (the inter-rater agreement helper that
`diagnose_mfrm()` calls when `Person` is part of `facet_cols`)
previously used a `list()` for the per-context probability lookup
and `c(exp_vals, ...)` accumulation inside a per-row loop. This
gave near-quadratic scaling: 6,400 observations took ~2 s, but
72,000 observations took ~141 s. The lookup is now an
`environment` (hash-backed for character keys) and `exp_vals` is
preallocated and filled by index, so the helper now scales linearly
in the number of observations. On the 72,000-observation benchmark
in the audit, `diagnose_mfrm()` drops from ~141 s to ~15 s.

The `make_union_find()` helper used by the connectivity audit was
also rewritten with an iterative `find_root` (with path
compression) instead of the previous recursive form. Designs whose
union chain depth exceeded `options(expressions)` (default 5,000)
no longer error out with "evaluation is too deeply nested".

### Input validation: degenerate inputs surface earlier

`prepare_mfrm_data()` now:

- emits a `message()` summarising how many rows it dropped due to
  missing values or non-positive weights, instead of dropping them
  silently;
- trims leading/trailing whitespace from `Person` and facet IDs
  (with a `message()` reporting the row count) so " P01 " and
  "P01" do not silently become two persons;
- `warning()`s when the input contains duplicate Person x facet
  rows (which violate MFRM's conditional-independence assumption)
  but lets the fit continue rather than refusing it outright.

`fit_mfrm()` now treats `NaN` / `Inf` for `maxit`, `reltol`, and
`quad_points` as invalid input with a localised English error,
instead of falling through to R's locale-dependent
"missing value where TRUE/FALSE needed" message.

### Pre-rendered cheatsheet PDF

The two-page landscape cheatsheet now ships in pre-rendered form at
`system.file("cheatsheet", "mfrmr-cheatsheet.pdf", package = "mfrmr")`
alongside the existing `.Rmd` source. Users without a working LaTeX
toolchain can open the PDF directly; users who want to customize it
can still knit the `.Rmd` with `rmarkdown::render()`. The README and
`?mfrmr` package help now point at both files.

### Help-page examples: "what to look for" annotations

The most-visited help pages now embed concrete interpretation
comments inside their `@examples` blocks. Each shipped example
shows what value ranges or patterns indicate "good", what threshold
or rule of thumb applies, and what follow-up to run if the value
is off. Coverage in 0.1.6 includes:

- `?fit_mfrm` (convergence, person SD, targeting bands).
- `?diagnose_mfrm` (key_warnings, MnSq misfit lines, facets_chisq,
  inter-rater agreement minus expected).
- `?summary.mfrm_fit` and `?summary.mfrm_diagnostics` (overview,
  person distribution, top_fit ZSTD bands, facets_chisq, targeting).
- `?estimate_bias`, `?analyze_dff`, `?compute_facet_icc`,
  `?apply_empirical_bayes_shrinkage` (effect-size bands, Penfield
  classification, Koo & Li 2016 reliability bands, shrinkage factor
  interpretation).
- `?build_apa_outputs`, `?reporting_checklist`, `?plot_qc_dashboard`,
  `?plot.mfrm_fit` (manuscript-readiness signals, dashboard panel
  status, Wright / pathway / CCC interpretation).
- `?plot_bubble`, `?plot_dif_heatmap`, `?plot_local_dependence_heatmap`,
  `?plot_reliability_snapshot`, `?plot_residual_matrix`,
  `?plot_shrinkage_funnel`, `?plot_guttman_scalogram`,
  `?plot_residual_qq`, `?plot_rater_trajectory`,
  `?plot_rater_agreement_heatmap` (cell / band thresholds,
  reference-line interpretation).

### Help-page examples: lighter-weight `\donttest{}`

Several main entry points now expose a small fast-path block (a
`JML` fit on `example_core` plus a single diagnostic / plot call)
before the heavier `\donttest{}` block. The fast path is below
R CMD check's example-time budget and provides a regression net
that runs every check, while the full `\donttest{}` block
continues to showcase the larger MML / publication-route examples.
Affected pages: `?fit_mfrm`, `?diagnose_mfrm`, `?plot_qc_dashboard`,
`?reporting_checklist`, `?build_apa_outputs`.

### Documentation

- `?mfrmr_visual_diagnostics` adds a "Cross-reference to FACETS /
  Winsteps tables" section that lists the closest mfrmr helper for
  each canonical Rasch / MFRM table or figure family (Wright map,
  pathway / probability curves, test information, misfit, bias /
  interaction, DIF / DRF, inter-rater agreement, anchoring /
  linking).
- `?mfrmr_visual_diagnostics` and the visual reporting template now
  enumerate the 4 secondary plot helpers and the 4 screening
  helpers added in 0.1.6.
- `?diagnose_mfrm` cites Wright & Masters (1982) at the
  separation / strata / reliability section and reproduces the
  formulae (G = TrueSD / RMSE, R = G^2 / (1 + G^2),
  H = (4G + 1) / 3) so the reliability outputs are traceable to
  source.
- `?fit_mfrm` example block now flags the `quad_points = 7` opening
  fit as an exploratory speed setting.
- The README and `?mfrmr` package help now point at the public
  cheatsheet (`system.file("cheatsheet", "mfrmr-cheatsheet.Rmd",
  package = "mfrmr")`).
- The bias / misfit APA narrative now spells out `|ZSTD|` (or
  `|MnSq - 1|` when ZSTD is unavailable) instead of the generic
  `|metric|` placeholder.
- `build_misfit_casebook()` now also draws element-level Infit /
  Outfit MnSq misfit cases from `diagnostics$fit` (in addition to
  marginal cells, pairwise screens, unexpected responses, and
  displacement). The casebook therefore matches what its name
  implies.

### Yen Q3 local-dependence statistic

`q3_statistic(fit, diagnostics)` returns the Yen (1984) Q3 index
between every facet-level pair, with three published reporting
thresholds (Yen 0.20, Marais 0.30, Christensen et al. relative
0.20) and a textual `Interpretation` column that names which
flag(s) each pair triggered. The helper reuses the standardized-
residual pivot that `plot_local_dependence_heatmap()` already
draws, so the table and the heatmap stay numerically consistent.

### Extended person-fit indices

`compute_person_fit_indices(diagnostics, fit)` adds three new
person-level fit indices on top of the Infit / Outfit / ZSTD
columns that `diagnose_mfrm()` already exposes:

- **lz** (Drasgow, Levine & Williams, 1985): standardized
  log-likelihood under the fitted model.
- **lz\\*** (Snijders, 2001): bias-corrected version that
  accounts for using the JML / EAP estimate in place of the true
  ability.
- **ECI4** (Tatsuoka & Tatsuoka, 1983): standardized squared-
  residual index.

All three are asymptotically standard normal under the
conditional-independence assumption; |index| > 1.96 / 2.58 are
the 5% / 1% reporting flags.

### Generalizability-theory adapter

`mfrm_generalizability(fit)` re-fits the rating data as a crossed
random-effects model `Score ~ 1 + (1 | Person) + (1 | Facet1) + ...`
via `lme4::lmer` and returns the canonical G / Phi coefficients
plus per-source variance components. Useful when a reviewer asks
for a generalizability-theory complement to the Rasch-style
separation / reliability statistics that `diagnose_mfrm()`
already emits.

### Import adapters: mirt / TAM / eRm

Three thin importers expose external fit objects via the same
`mfrm_fit` interface that the mfrmr plot and table helpers
consume:

- `import_mirt_fit(fit, model)` accepts a `mirt::mirt()` result.
- `import_tam_fit(fit, model)` accepts `TAM::tam.mml()` /
  `TAM::tam.jml()`.
- `import_erm_fit(fit, model)` accepts `eRm::PCM()` /
  `eRm::RM()` / `eRm::RSM()`.

The imported objects carry the `mfrm_imported_fit` class and
populate measurement-side slots (`facets$person`,
`facets$others`, `steps`, `summary`) only. Bias / DIF / anchor /
replay slots are explicitly not populated; full bundle import is
on the 0.2.0 roadmap.

### Parallel parametric-bootstrap ICC

`compute_facet_icc(boot = "boot")` gains `ci_boot_parallel`
(`"no"` / `"multicore"` / `"snow"`) and `ci_boot_ncpus` arguments
that are forwarded to `lme4::bootMer()`. The per-replicate `cli`
progress bar is suppressed under parallel execution because
worker processes hold their own copy of the progress state.

### Parallel evaluate_mfrm_design (scaffold)

`evaluate_mfrm_design()` accepts a `parallel = c("no", "future")`
argument. When `"future"` is requested and the `future.apply`
Suggests package is installed, the rep loop within each design
row honours whatever `future::plan()` is currently active;
cross-design-row parallelism is on the 0.2.0 roadmap. Without
`future.apply` the call falls back to serial execution with an
explicit message.

### Resumable MML EM fits

`fit_mfrm()` accepts a `checkpoint = list(file = ..., every_iter = ...)`
argument. When supplied to a `mml_engine = "em"` (or hybrid)
fit, the EM scaffolding writes its state to `file` every
`every_iter` outer iterations using `saveRDS()`. If the file
exists when a subsequent call starts, the engine resumes from the
recorded iteration. The direct `optim()` engine ignores the
checkpoint; non-EM fits run unaffected.

### GPCM verification tests

A new `tests/testthat/test-gpcm-verification.R` exercises every
`"supported"` and `"supported_with_caveat"` row of
`gpcm_capability_matrix()` on a toy dataset and asserts the
documented helper returns the expected shape. `"blocked"` and
`"deferred"` rows have negative tests that confirm the helper
either refuses to run or returns an explicit caveat. These tests
make the GPCM scope a contract that future commits cannot
silently shrink.

### Optional FACETS Table 7 style fit output on fit$facets$others

`fit_mfrm(attach_diagnostics = TRUE)` runs `diagnose_mfrm()` once
after the fit and merges the per-level `SE`, `Infit`, `Outfit`, and
`PtMeaCorr` columns onto `fit$facets$others`. This makes the facet
table look like a FACETS Table 7 summary without a separate call.
The default `FALSE` preserves the minimal `Facet` / `Level` /
`Estimate` layout from 0.1.5.

## Reproducibility

`build_mfrm_manifest()` gains several new tables so replay bundles
carry everything a deterministic re-run needs:

- `environment` now records `RNGKind`, `RNGSeedDigest`, `Locale`, and
  a UTC ISO-8601 timestamp in addition to the existing package and
  platform fields.
- `dependencies` (new) records the installed version of every
  `Imports` and `Suggests` dependency, with a `Role` column.
- `input_hash` (new) hashes the input data, anchors, group anchors,
  and `score_map` with SHA-256 (via `digest`, now in `Suggests`) or
  an MD5-of-RDS fallback. The hash is deterministic across sessions.
- `session_info` (new) unrolls `utils::sessionInfo()` into a long
  data frame (`Scope` / `Package` / `Version`).
- `hierarchical_audit`, `missing_recoding`, and `shrinkage_audit`
  (new) surface the three new audit layers in one place.

`digest` is added to `Suggests`.

## Bug fixes

- **Bias / interaction NA.** `estimate_bias()` and
  `estimate_all_bias()` previously returned `NA` for every cell's
  `S.E.`, `t`, `Prob.`, `Obs-Exp Average`, `Infit`, and `Outfit`,
  and `Significant` counts collapsed to zero. Root cause was an
  `nzchar(NA_character_)` call (which returns `TRUE`) in an internal
  predicate. Downstream helpers such as `bias_interaction_report()`
  and `plot_bias_interaction()` are now populated again.
- **`estimate_bias()` silent failure on typo'd facet names.** A
  mis-spelled `facet_a` / `facet_b` (e.g. `"Raters"` with trailing
  `s`) previously returned an empty `list()` with no warning. It now
  raises an informative error naming the available facets. Missing
  `diagnostics` argument likewise raises an explicit mfrmr error
  rather than falling through to R's locale-dependent missing-
  argument message.
- **ZSTD sign.** `zstd_from_mnsq()` was numerically unstable for very
  small degrees of freedom and could return large positive ZSTD when
  `MnSq` was close to zero, flipping the sign relative to the
  companion Outfit ZSTD for the same element. A `df >= 1` guard
  returns `NA` in degenerate cells.
- **Score out of range.** `prepare_mfrm_data()` now stops when any
  observed `Score` falls outside the declared
  `[rating_min, rating_max]` range. Previously negative `score_k`
  values passed through `m[cbind(i, 0)]`, silently dropping those
  rows from the likelihood while `n_obs` kept its original value.
- **Silent facet-name mismatches.** `sanitize_noncenter_facet()`,
  `sanitize_dummy_facets()`, and `build_facet_signs()` now emit a
  warning when supplied facet names are not part of the fitted
  model. Previously typos such as `positive_facets = "rater"`
  (lowercase) or `noncenter_facet = "Raters"` could silently flip
  the sign convention of facet measures.
- **Graphical state hygiene.** `apply_plot_preset()` and
  `.draw_shrinkage_plot()` now restore the user's `par()` on exit,
  per "Writing R Extensions" 2.1. All plot methods that relied on
  `apply_plot_preset()` inherit this automatically.
- **DFF contrast sign flip.** `analyze_dff()` adds a
  `ContrastDirection` column to the residual and refit branches.
  The two methods use opposite sign conventions by design, so the
  new column spells out which interpretation applies.
- **`compute_facet_icc()` singular fit.** Total variance below
  `sqrt(.Machine$double.eps)` is now reported as `ICC = NA` with
  `Interpretation = "Non-identifiable"` instead of a falsely
  meaningful value. The first `lme4` convergence diagnostic surfaces
  as a `message()` rather than being silently suppressed.
- **Extreme-person flag persistence.** `as.data.frame.mfrm_fit()`
  now carries the new `Extreme` column through to ggplot2 / CSV
  pipelines instead of dropping it.
- **`as_kable(format = "pipe")` output.** Previously silently
  returned HTML when `kableExtra` was installed and the `apa_table`
  carried a non-empty `note`. `"pipe"` now consistently returns the
  Markdown table with an appended `Note.` line.
- **`audit_mfrm_anchors()` false positives.** Overlap-adequacy risk
  flags are skipped when no anchors or group anchors were supplied,
  so single-wave analyses no longer emit "high severity" warnings
  because `OverlapLevels == 0` everywhere.
- **Fractional-score tolerance.** Tightened from
  `sqrt(.Machine$double.eps)` (~`1.5e-8`) to `1e-6`, so integer
  codes like `1.0000001` that round-trip through CSV floats are now
  accepted. Genuinely fractional scores (`1.5`, `2.75`) are still
  caught.
- **Duplicate "Rating range inferred" message.** When
  `rating_min` / `rating_max` were inferred from the observed scores,
  the informational message was emitted twice per `fit_mfrm()` call
  (once from `audit_mfrm_anchors()` and once from `mfrm_estimate()`).
  `fit_mfrm()` now uses a session-scoped option to suppress the
  duplicate; standalone calls to `prepare_mfrm_data()` continue to
  announce normally.
- **Locale-independent error for `plot(fit, type = ...)`.** Passing an
  unknown `type` previously raised R's locale-dependent
  `match.arg()` error. It now raises an English mfrmr-style error
  listing the valid choices.
- **`plot_dif_heatmap(draw = FALSE)` payload contract.** The helper
  documented an `mfrm_plot_data` payload but invisibly returned the
  bare `matrix`, breaking the documented contract used by sibling
  `plot_*` helpers. It now returns an `mfrm_plot_data` whose `data`
  slot bundles `matrix`, `pairs`, `metric`, and `value_column`. Code
  that relied on the old shape should switch from `dim(heat)` to
  `dim(heat$data$matrix)`.
- **Approximate 95% CI whiskers on bias and displacement plots.**
  `plot_bias_interaction(show_ci = TRUE, ci_level = 0.95)` (scatter
  and ranked modes) now draws `BiasSize \u00b1 z \u00b7 SE` whiskers
  using the per-cell SE from [estimate_bias()]. `plot_displacement(
  show_ci = TRUE)` (lollipop mode) draws
  `Displacement \u00b1 z \u00b7 DisplacementSE` whiskers from the
  audit-table standard error. Both functions now populate
  `CI_Lower` / `CI_Upper` / `CI_Level` columns on the returned
  plot-data element so downstream pipelines can reuse the bounds.
  `plot_fair_average()` CI support (now implemented later in this
  release) uses a delta-method propagation because the
  fair-average SE lives on the logit scale while the plot uses the
  observed-score scale, which requires a delta-method transformation.

## Messaging improvements

- `fit_mfrm()` emits a one-time `message()` when called with
  `anchor_policy = "silent"` while the anchor audit flags issues.
- `prepare_mfrm_data()` announces when `rating_min` / `rating_max`
  have been inferred from the observed scores rather than supplied
  explicitly, and flags facets with only one observed level
  (structurally fixed at 0 by the sum-to-zero constraint).
- Non-numeric score labels (`"low"`, `"medium"`, `"high"`) now raise
  a targeted error up front instead of surfacing as the opaque
  "No valid observations remain" message.
- `detect_anchor_drift()` and `build_equating_chain()` thin-linking
  warnings now list per-facet retained-vs-threshold counts
  (e.g. `"Rater (3/5)"`).
- `bias_interaction_report()$summary` carries a `FlagStatus` column
  so empty `ranked_table` rows are no longer ambiguous between
  "nothing flagged" and "nothing computed".
- Latent-regression fits warn when the design matrix is
  near-singular (`rcond(mm) < 1e-8`), catching numerically collinear
  covariates rather than only exact rank deficiency.

## Documentation and citations

- `apply_empirical_bayes_shrinkage()` docstring and R comments now
  document the shrinkage-variance formula as
  `max(0, K^{-1} * sum(delta^2) - mean(SE^2))`, matching the
  implementation under sum-to-zero identification.
- `?fit_mfrm` "Input requirements" now states the MFRM conditional
  independence assumption (Linacre, 1989) and points at
  `diagnose_mfrm(..., diagnostic_mode = "both")` /
  `strict_pairwise_local_dependence` as the exploratory follow-up.
- `?fit_mfrm` example block now flags the `quad_points = 7` opening
  fit as an exploratory speed setting and reminds readers that the
  package default `quad_points = 31` is the publication tier, so the
  example no longer reads as a recommendation against the new default.
- `?fit_mfrm` now presents the recommended `quad_points` tiers as a
  `\tabular{}` block (`7` fast scan, `15` default, `31+` publication)
  so readers do not have to re-extract the recommendation from prose.
  The "adapted from Linacre (1994)" wording for the sample-size bands
  and the wall-clock cost of `diagnostic_mode = "both"` are also
  spelled out.
- `?fit_mfrm` `missing_codes` docstring is now an itemised list of
  the three branches (`NULL` / `TRUE` / custom vector) instead of
  dense prose.
- `?run_mfrm_facets` now notes that `method = "JML"` is the default
  for legacy FACETS-style output continuity and points users at
  `fit_mfrm(..., method = "MML")` for new analysis scripts.
- `?apply_empirical_bayes_shrinkage` now states that
  `EffectiveDF = Σ(1 − B_j)` matches the "effective number of
  parameters" from Efron & Morris (1973).
- `?compute_facet_icc` notes that Koo & Li (2016) recommend applying
  the reliability bands to the 95% confidence interval of the ICC,
  while the current implementation bands the point estimate only.
- `?analyze_facet_equivalence` adds Kass & Raftery (1995) as the
  reference for the BIC-based Bayes-factor approximation
  `BF_{01} ≈ exp((BIC_{H1} − BIC_{H0}) / 2)`.
- ZSTD docstring in `?mfrmr-package` now cites Wilson & Hilferty
  (1931) explicitly alongside Wright & Linacre (1994).
- `calc_displacement_table()` now cites the Winsteps user guide for
  the combined `|Displacement| > 0.5 logit` and `|t| > 2` flagging
  rule.
- `analyze_facet_equivalence()` docstring frames the
  `equivalence_bound = 0.5` default as a starting point.
- Added `print()` S3 methods for 13 classes that previously fell
  back to the default list printer (`mfrm_apa_outputs`, `mfrm_bias`,
  `mfrm_bundle`, `mfrm_design_evaluation`, `mfrm_diagnostics`,
  `mfrm_facet_dashboard`, `mfrm_future_branch_active_branch`,
  `mfrm_plausible_values`, `mfrm_population_prediction`,
  `mfrm_reporting_checklist`, `mfrm_signal_detection`,
  `mfrm_threshold_profiles`, `mfrm_unit_prediction`). Each delegates
  to the existing `summary()` method.

Reference citations corrected:

- Efron & Morris (1973) page range `379-402` (was `379-421`).
- McEwen (2018) BYU dissertation year (was 2017).
- Wright (1998) RMT 12(2) on extreme scores (was Wright 1988,
  which does not exist).
- Jones & Wind (2018) JAM 19(2), 148-161 (was "Wind & Jones, 2018,
  JAM 19(1), 1-19", which does not exist).
- Linacre (2023) *A User's Guide to Facets, Version 4.5* applied
  uniformly where comments had used 2024.

## Plot polish

- `plot_qc_dashboard()` plots a signed ZSTD distribution combining
  Infit and Outfit ZSTD, with reference lines at
  `-3 / -2 / 0 / 2 / 3`. The previous absolute-value histogram
  collapsed over-fit and under-fit tails.
- `plot_residual_pca(..., plot_type = "scree")` draws Rasch
  secondary-dimension reference lines at `1.0 / 1.4 / 2.0 / 3.0`,
  consistent with the Winsteps user guide. The legend and returned
  `reference_lines` record the new entries.
- The Residual-PCA `content_checks` entry uses a case-insensitive
  regex so the check passes whether the APA contract uses
  `"Residual PCA"` or the longer `"Exploratory residual PCA"`.

## Other additions

- `fit$facets$person` exposes `PosteriorSD` and `SE` aliases
  alongside the legacy `SD`. MML fits populate all three with the
  posterior SD under the Gauss-Hermite prior; JML fits set
  `SE = NA_real_` and note that per-person SEs should be pulled
  from `diagnose_mfrm()$measures`.
- `analyze_dff(method = "refit")` subgroup fits return a
  `LinkingAudit` column that captures the anchor-audit messages
  emitted during the refit, replacing the previous
  hard-coded `anchor_policy = "silent"` silence.
- `detect_anchor_drift()` returns `common_vs_reference` and
  `n_common_all_waves` alongside the existing pairwise
  `common_elements` table, for 3+ wave linking reviews.
- `analyze_residual_pca(..., pca_max_factors = "auto")` caps the
  factor count at `min(10, ncol - 1, nrow - 1)` per matrix; this
  value was previously silently coerced to `NA`.
- `describe_mfrm_data()` returns two new components:
  `missing_rate_summary` (per-column missing / non-missing counts)
  and `facet_crosstabs` (long-format pairwise observation-count
  tables, suitable for heatmap plotting).
- DESCRIPTION removes the duplicated `Author` / `Maintainer` fields
  auto-generated by CRAN; `Authors@R` remains the single source of
  truth. The `Description:` field is now three sentences (was 10
  lines of prose), improving CRAN web readability while retaining
  the two rating-scale / partial-credit DOI references.
- `inst/CITATION` now tracks `meta$Version` and `meta$Title`
  dynamically, so `citation("mfrmr")` prints the current installed
  version rather than a hard-coded string.

## Test suite

6,380+ tests pass (up from 6,343 in 0.1.5), with 0 failures and
0 errors. New test files:

- `test-shrinkage.R` (40 tests) covers the closed-form math, edge
  cases (`K < 3`, `tau^2 <= 0`, user-supplied prior), `fit_mfrm`
  integration, reporting and manifest trails, and the three new
  plot methods.
- `test-missing-codes-integration.R` (17 tests) covers `fit_mfrm`,
  `describe_mfrm_data`, `audit_mfrm_anchors`, and manifest paths.
- `test-hierarchical-audit.R` (10 tests) covers the five new
  hierarchical-audit helpers and their integration points.

Pre-existing test-harness errors unrelated to 0.1.5 behaviour have
also been cleaned up (S3 dispatch, GPCM scope wording, internal-helper
prefixing with `mfrmr:::`).

# mfrmr 0.1.5

## Maintenance release

### First-use workflow

- Reworked `print(fit)`, `summary(fit)`, and
  `summary(diagnose_mfrm(...))` so results start with `Status`,
  `Key warnings`, and `Next actions`.
- Added a clearer recommended workflow in the README and help pages: fit with
  `MML`, review diagnostics with `diagnostic_mode = "both"`, then move to
  reporting helpers.
- Improved ordered-score handling and guidance, including binary
  two-category use, rejection of fractional score values, non-consecutive
  score-code mapping through `score_map`, and clearer warnings for retained
  zero-count categories.

### Estimation and scoring

- Added the first public latent-regression `MML` branch for ordered `RSM` /
  `PCM` fits with person covariates, including simulation and scoring support
  for the fitted population model.
- Added bounded `GPCM` support for the documented direct route, including core
  summaries, diagnostics, plots, posterior scoring, and information checks,
  while keeping unsupported downstream routes explicit.
- Extended ordered-response support and documentation for binary `RSM` / `PCM`
  use, fixed-calibration scoring after `JML`, and `PCM` information curves.

### Diagnostics, reporting, and visualization

- Added strict marginal follow-up plots through `plot_marginal_fit()` and
  `plot_marginal_pairwise()`.
- Strengthened the reporting surface with `reporting_checklist()`,
  `build_summary_table_bundle()`, `export_summary_appendix()`, and
  `visual_reporting_template()` for manuscript-oriented tables, appendix
  artifacts, and figure-placement guidance.
- Added structured caveats in summaries and appendix tables for retained
  zero-count score categories and latent-regression population-model
  omission/design issues.
- Added exploratory `plot(fit, type = "ccc_surface", draw = FALSE)` output
  for advanced visualization while keeping 2D Wright/pathway/category plots as
  the default reporting route.

### External-software scope

- Added scoped ConQuest overlap helpers and concise software-scope summaries
  for FACETS, ConQuest, and SPSS handoffs.
- Clarified latent-regression reporting outputs so coefficient reporting is
  kept separate from post hoc score regression.

# mfrmr 0.1.4

## CRAN resubmission

- Replaced a misencoded author name in documentation references so the PDF
  manual builds cleanly under CRAN's LaTeX checks.
- Revised DESCRIPTION references again to avoid incoming spell-check notes
  while preserving the requested author-year-doi citation format.

# mfrmr 0.1.3

## CRAN resubmission

- Revised `DESCRIPTION` references to use the requested `authors (year) <doi:...>`
  format.
- Added a documented return-value section for `facet_quality_dashboard()`,
  including the output class, structure, and interpretation.
- Replaced `\dontrun{}` with `\donttest{}` for executable examples so CRAN can
  exercise those examples during checks.

# mfrmr 0.1.2

## CRAN resubmission

- Further reduced CRAN check time by trimming the CRAN-only test subset to
  lightweight smoke tests after the incoming pretest still reported a Windows
  overall-checktime NOTE for version 0.1.1.

# mfrmr 0.1.1

## CRAN resubmission

- Revised `DESCRIPTION` metadata to avoid CRAN incoming spell-check notes on
  cited proper names.
- Reduced CRAN check time by skipping long integration and coverage-expansion
  test files during CRAN checks while keeping the full local test suite.

# mfrmr 0.1.0

## Initial release

- Native R implementation of many-facet Rasch model (MFRM) estimation without TAM/sirt backends.
- Supports arbitrary facet counts with `fit_mfrm()` and method selection (`MML` default, `JML`).
- Includes FACETS-style bias/interaction iterative estimation via `estimate_bias()`.
- Provides fixed-width report helpers (`build_fixed_reports()`).
- Adds APA-style narrative output (`build_apa_outputs()`).
- Adds visual warning summaries (`build_visual_summaries()`) with configurable threshold profiles.
- Implements residual PCA diagnostics and visualization (`analyze_residual_pca()`, `plot_residual_pca()`).
- Bundles Eckes & Jin (2021)-inspired synthetic Study 1/2 datasets in both `data/` and `inst/extdata/`.

## Package operations and publication readiness

- Added GitHub Actions CI for cross-platform `R CMD check`.
- Added `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, and `SECURITY.md`.
- Added citation metadata (`inst/CITATION`, `CITATION.cff`).
- Expanded README with explicit installation and citation instructions.
