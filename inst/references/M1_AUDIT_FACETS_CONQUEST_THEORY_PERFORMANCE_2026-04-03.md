# M1 Audit: FACETS / ConQuest / Theory / Performance

Date: 2026-04-03  
Scope: ordered-category MFRM core, planning/prediction layer, recent helper generalization work

## Goal

This audit fixes the interpretation frame for `mfrmr` before adding larger features. The package should be described as a Stan-free, ordered-category many-facet Rasch package whose current core is `RSM` / `PCM` with `MML` / `JML`, plus simulation/planning/prediction helpers built around the same ordered-response family.

## Primary Sources

- ConQuest manual index: <https://conquestmanual.acer.org/index.html>
- ConQuest command reference: <https://conquestmanual.acer.org/s4-00.html>
- ConQuest technical matters: <https://conquestmanual.acer.org/s3-00.html>
- FACETS overview: <https://www.winsteps.com/facets.htm>
- FACETS model specification: <https://www.winsteps.com/facetman64/models.htm>
- FACETS fair average: <https://www.winsteps.com/facetman/fairaverage.htm>
- FACETS bias analysis: <https://www.winsteps.com/facetman/biasanalysis.htm>
- FACETS manual PDF: <https://www.winsteps.com/a/Facets64-Manual.pdf>
- Andrich (1978): <https://doi.org/10.1007/BF02293814>
- Masters (1982): <https://doi.org/10.1007/BF02296272>
- Bock & Aitkin (1981): <https://doi.org/10.1007/BF02293801>
- Mislevy (1991): <https://doi.org/10.1007/BF02294457>
- Adams, Wilson, & Wang (1997): <https://doi.org/10.1177/0146621697211001>
- Muraki (1992): <https://www.ets.org/research/policy_research_reports/publications/report/1992/ihkr.html>
- Muraki (1993): <https://www.ets.org/research/policy_research_reports/publications/report/1993/ihfu.html>

## Official-Documentation Alignment

- `fit_mfrm()` aligns with the additive ordered-category Rasch family described in FACETS and ConQuest for dichotomous, rating-scale, partial-credit, and many-facet settings.
- Treating binary responses as the ordered two-category special case is mathematically aligned with Andrich (1978), Masters (1982), and ConQuest's general design-and-score-matrix framing for dichotomous and polytomous ordered responses.
- `predict_mfrm_units()` and `sample_mfrm_plausible_values()` align with quadrature-based fixed-calibration scoring. They should not be described as ConQuest-style full population-model plausible values.
- `evaluate_mfrm_design()` and `predict_mfrm_population()` are package-native Monte Carlo planning helpers. They are conceptually aligned with simulation-study guidance, but they are not official FACETS or ConQuest procedures.
- Public facet-name aliases and role-based descriptors are `mfrmr` implementation features. They improve interface clarity but do not correspond to distinct measurement-theory constructs in the official software manuals.

## Boundaries To Keep Explicit

- `mfrmr` is not yet functionally equivalent to ConQuest. ConQuest documents broader support for arbitrary linear design, latent regression, multidimensional models, generalized partial credit, nominal response, imported design matrices, and plausible values workflows.
- `mfrmr` is not yet functionally equivalent to FACETS. FACETS documents broader reporting and operational support around fair averages, bias/interaction analysis, mixed rating structures, and additional model families.
- The current simulation/planning layer still assumes exactly two non-person facet roles. Alias/descriptor support renames those roles, but it does not yet create an arbitrary-facet planning engine.

## Mathematical Audit

- Binary as ordered two-category: defensible.
- `compute_information()` as score-variance-based conditional information for ordered Rasch-family cells: defensible.
- `compute_information()` as a design-weighted precision screen rather than a design-free textbook TIF: necessary caveat.
- JML-based unit scoring as post hoc fixed-calibration EAP with a reference prior: defensible as an approximation layer.
- JML-based unit scoring as a population model or full plausible-values procedure: not defensible.
- Recovery RMSE and bias after facet-wise mean alignment: defensible because Rasch-family locations are indeterminate up to a constant shift.
- Recovery comparability checks currently cover `model` and `step_facet`; orientation/anchoring compatibility still relies on user judgment and should be documented as such.
- Bias-side "power" should be read as screening hit rate, not formal inferential power.

## Performance Audit

### Main hotspots

- Repeated `fit_mfrm()` and `diagnose_mfrm()` calls dominate `evaluate_mfrm_design()`.
- Repeated `fit_mfrm()`, `diagnose_mfrm()`, `analyze_dff()`, and `estimate_bias()` dominate `evaluate_mfrm_signal_detection()`.
- Within `simulate_mfrm_data()`, assignment generation and row-wise score sampling are the largest pure-simulation costs.

### Low-risk improvements

- Move design-specific `sim_spec` overrides and related metadata resolution outside replication loops.
- Avoid repeated facet-table filtering by splitting summary tables once per replicate.
- Reuse single-pass quantities such as `MinCategoryCount` within a replicate.
- Prefer precomputed template groups to repeated `filter()` in resampled/skeleton assignment builders.

### Medium-risk improvements

- Replace row-wise response sampling with a more vectorized sampler.
- Rewrite effect injection as keyed joins or model-matrix style additions.
- Add optional parallel execution for design-by-rep Monte Carlo work.
- Add cached summary objects for plot/recommend workflows.

## Immediate Actions

- [x] Tighten public docs so `JML` is no longer described as simply "faster".
- [x] Keep `predict_mfrm_units()` and `sample_mfrm_plausible_values()` framed as fixed-calibration approximate scoring.
- [x] Keep `compute_information()` framed as a design-weighted precision screen.
- [x] State that helper alias/descriptor work is a naming layer over the current two-non-person-facet planner.
- [x] Apply low-risk loop optimizations in `evaluate_mfrm_design()` and `evaluate_mfrm_signal_detection()`.
- [x] Pre-split empirical assignment templates in resampled/skeleton simulation paths.
- [x] Decide whether bias-side plotting should foreground `screen_rate` more explicitly than `power`.
- [x] Add a dedicated performance-regression benchmark script for planning helpers.

Current local timing snapshot after the low-risk cleanup:

- `simulate_pcm_rotating` repeated 20 times:
  about `0.294s`
- `design_eval_pcm`:
  about `1.997s`
- `signal_detection_pcm`:
  about `1.320s`
- `simulate_resampled_spec` repeated 20 times:
  about `0.081s`
- `simulate_skeleton_spec` repeated 20 times:
  about `0.285s`

These timings are environment-specific, but they confirm that the empirical
assignment paths are no longer the same obvious bottleneck observed before the
template pre-splitting change. The benchmark entrypoint is now fixed in
`analysis/benchmark_planning_helpers.R`, with interpretation guidance in
`inst/references/M1_PLANNING_BENCHMARK_2026-04-03.md`.

## Decision Rule For Next Phases

Phase M1 should continue to prioritize:

1. ordered-category core completeness,
2. truthful documentation of approximations and boundaries,
3. low-risk planning/simulation performance improvements,
4. only then larger feature expansion toward latent regression and `GPCM`.
