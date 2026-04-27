# M3 GPCM Consistency Audit

Date: 2026-04-04  
Package baseline: `mfrmr` 0.1.5

## 1. Purpose

This note records the post-fit consistency sweep for the first-release `GPCM`
branch. The immediate goal is not to widen support aggressively. The goal is
to make the current support boundary flow cleanly through the package:

- fit paths that are mathematically supported should stay open;
- helper layers that still depend on Rasch-only semantics should reject
  `GPCM` explicitly;
- help pages should say the same thing as the code.

## 2. Source base

Primary sources:

- Muraki (1992), generalized partial credit model:
  <https://www.ets.org/research/policy_research_reports/publications/report/1992/ihkr.html>
- Muraki (1993), information functions of the generalized partial credit model:
  <https://www.ets.org/research/policy_research_reports/publications/report/1993/ihfu.html>
- TAM `tam.mml` manual:
  <https://search.r-project.org/CRAN/refmans/TAM/html/tam.mml.html>
- mirt `fscores` manual:
  <https://search.r-project.org/CRAN/refmans/mirt/html/fscores.html>
- psychotools `gpcmodel` manual:
  <https://search.r-project.org/CRAN/refmans/psychotools/html/gpcmodel.html>
- FACETS fair-average help page:
  <https://www.winsteps.com/facetman/fairaverage.htm>

## 3. Source-backed interpretation

### 3.1 What is already justified

The current first-release `GPCM` branch is mathematically defensible for:

- ordered-category fitting under a generalized partial credit probability
  kernel with positive discrimination parameters;
- exact reduction to `PCM` when all discriminations equal 1;
- fixed-calibration posterior scoring once the fitted probability kernel is
  available for quadrature-based EAP summaries;
- design-weighted information summaries once the generalized category
  probabilities and squared-discrimination scaling are used explicitly.

This is consistent with Muraki's `GPCM` formulation and with the way open
software such as `mirt` / `psychotools` documents `GPCM` scoring under
quadrature-based posterior summaries.

### 3.2 What is not yet justified

The current package still lacks a validated generalized contract for:

- fair-average adjusted-score tables and their reporting semantics;
- bias-adjusted diagnostics that still depend on Rasch-only probability paths;
- planning / forecasting helpers that assume threshold-only design summaries;
- scorefile-style exports and APA / QC writer pipelines that have not yet been
  re-derived for free-discrimination fits.

The dedicated fair-average audit is recorded separately in
`inst/references/M3_GPCM_FAIR_AVERAGE_AUDIT_2026-04-04.md`. The short version
is that FACETS documents fair averages as Rasch-family measure-to-score
transformations in a standardized mean/zero-facet environment. The current
first-release `GPCM` branch has generalized category probabilities, but it
does not yet have a validated slope-aware fair-average score contract.

This boundary follows from the literature and from the local codebase.
Muraki (1993) ties information to the generalized category probabilities and
scoring functions, so `PCM` information formulas should not be silently reused
as if they were already generalized. Likewise, a threshold-only simulation
specification is not enough for `GPCM`, because the data-generating contract
must include the discrimination structure as well.

For the same reason, residual-based fit screens can be generalized once the
expected score, category probabilities, and score information are computed
under the `GPCM` kernel, but fair-average and bias-adjusted summaries should
not be treated as automatically portable from a Rasch-only workflow merely
because residual tables exist.

## 4. Current support map

### 4.1 Supported now

- `fit_mfrm(model = "GPCM")`
- `summary.mfrm_fit()`
- `predict_mfrm_units()`
- `sample_mfrm_plausible_values()`
- `compute_information()` / `plot_information()`
- `diagnose_mfrm()`
- `analyze_residual_pca()`
- `unexpected_response_table()`
- `interrater_agreement_table()`
- `displacement_table()`
- `measurable_summary_table()`
- `rating_scale_table()`
- `facet_quality_dashboard()`
- `plot_qc_dashboard()` with the fair-average panel retained as an explicit
  unavailable placeholder
- `reporting_checklist()`
- `plot.mfrm_fit()` for Wright / pathway / CCC views
- `category_structure_report()` / `category_curves_report()`
- graph-only `facets_output_file_bundle(include = "graph")`
- `reference_case_benchmark(cases = "synthetic_gpcm", model = "GPCM")`

These should be described as the current first-release `GPCM` path.

### 4.2 Explicitly unsupported or intentionally blocked

- `fair_average_table()` and fair-average-driven report sections
- `estimate_bias()` / `unexpected_after_bias_table()`
- APA / QC writer pipelines such as `build_apa_outputs()`,
  `build_visual_summaries()`, `run_qc_pipeline()`, and `facets_parity_report()`
- planning / forecasting helpers
- scorefile exports and diagnostics-driven compatibility/report bundles

These should reject with direct messages instead of failing deeper in the
workflow or being described as if they were already generalized.

## 5. Code-level conclusions

The local code audit showed three important consistency gaps:

1. `extract_mfrm_sim_spec()` was still trying to build threshold-driven
   simulation specifications from fitted objects without first excluding
   `GPCM`.
2. residual / diagnostic helpers still assumed `PCM`-style probability and
   variance tables even when `GPCM` scoring information depends on both the
   category variance and the squared discrimination parameter.
3. diagnostics-dependent export/report bundle helpers could fall through to
   deeper Rasch-only paths rather than either using the generalized residual
   tables or stopping immediately with a `GPCM`-specific boundary message.

These were boundary-control issues, not invitations to silently coerce `GPCM`
objects back into `PCM`. The first gap is now closed by requiring
slope-aware sim specs for `GPCM`; the second is now closed for the residual
stack by computing generalized category probabilities and score information;
the third remains intentionally blocked where report semantics still depend on
fair-average or bias-adjusted Rasch-only quantities.

## 6. Documentation conclusions

User-facing workflow pages and package-level help must separate:

- the ordinary `RSM` / `PCM` path:
  fit -> diagnostics -> reporting / planning
- the first-release `GPCM` path:
  fit -> summary -> posterior scoring -> design-weighted information ->
  residual diagnostics / residual-PCA -> reporting checklist / dashboard ->
  QC dashboard -> Wright/pathway/CCC views -> category curve/structure reports ->
  direct simulation-spec generation / data generation

Until the generalized downstream layers are implemented, those two routes
should not be described as if they were the same.

## 7. Minimal next step

The smallest source-backed next step is now:

1. keep `GPCM` fitting, summary, scoring, direct curve/report helpers, direct
   simulation, package-native recovery benchmarking, and residual-based
   diagnostics/reporting screens open;
2. keep fair-average, bias-adjusted, planning/forecasting, and writer/export
   paths explicitly blocked;
3. then choose one branch:
   - generalized planning/forecasting, or
   - generalized fair-average / reporting writers

before widening reporting or planning claims.

## 8. Bottom line

The current first-release `GPCM` branch is coherent if and only if the package
is explicit about its boundary:

> fitting, core summaries, and fixed-calibration posterior scoring are active;
> design-weighted information via `compute_information()` /
> `plot_information()` is active; residual-based diagnostics via
> `diagnose_mfrm()`, residual-PCA follow-up, `unexpected_response_table()`,
> `interrater_agreement_table()`, `displacement_table()`,
> `measurable_summary_table()`, `rating_scale_table()`,
> `facet_quality_dashboard()`, `plot_qc_dashboard()`, and
> `reporting_checklist()` are active, with
> fair-average outputs retained only as explicit unavailable placeholders;
> `plot.mfrm_fit()` for Wright/pathway/CCC, `category_structure_report()`,
> `category_curves_report()`, and graph-only
> `facets_output_file_bundle(include = "graph")` are active; direct
> slope-aware simulation via `build_mfrm_sim_spec()`,
> `extract_mfrm_sim_spec()`, and `simulate_mfrm_data()` is active; narrow
> package-native recovery benchmarking is active. The simulation/planning
> layer still remains role-based for exactly two non-person facets, even
> though estimation itself supports arbitrary facet counts; bias-adjusted diagnostics,
> scorefile exports, broader reporting writers, and planning/forecasting
> helpers are not yet validated.

That is the narrow claim most consistent with Muraki's theory, the comparator
packages, and the present local implementation.
