# mfrmr 0.2.0 release evidence map

This file summarizes the source-grounded evidence that should be reviewed
before treating mfrmr 0.2.0 as release-ready. It is a review guide, not a new
user-facing analysis API. The focus is on mathematical/statistical adequacy,
user workflow clarity, and help-file readability.

Source check date: 2026-05-16.

Companion checklist:
`inst/validation/release-evidence-checklist-0.2.0.csv`. Use the Markdown file
for interpretation and the CSV file for structured release review.

## Reading order

1. Check the release-level validation result first:
   `topline_release_decision`, then `release_decision_table`, then
   `domain_decision_table`.
2. Check the model contract:
   `RSM` and `PCM` remain the equal-weighting reference route; bounded `GPCM`
   is supported only where the capability matrix says it is supported or
   supported with caveat.
3. Check the mathematical kernels:
   step/threshold degrees of freedom, GPCM slope identification, GPCM
   information, fair-average uncertainty, and bias-screening uncertainty.
4. Check fit-standardization evidence:
   engine df and FACETS-style df are both reported when comparison is needed;
   differences are interpreted as convention differences unless the mean-square
   or measure rows also disagree.
5. Check the user workflow:
   the user should be able to start from `summary()`, then status or metric
   plots, and only then inspect row-level tables.
6. Check documentation:
   each caveat should name the supported route and the unavailable route
   without exposing implementation migration decisions.
7. Check the release-readiness protocol:
   source `inst/validation/release-readiness.R`, run
   `mfrmr_release_readiness_review(pkg_dir = ".")`, and read
   `release_decision` before the detailed gate tables.
8. Check the CI contract:
   the workflow should treat warnings as failures, retain check artifacts, and
   run the release-readiness gate after package check.

## Release Review Steps

Use the review steps below when asking a reviewer or maintainer to re-check the
release. Each review question has an expected evidence artifact.

| Step | Prompt | Evidence |
|---:|---|---|
| 1 | Does `DESCRIPTION`, `NEWS`, and generated help describe the same 0.2.0 release rather than a development snapshot? | `DESCRIPTION`, first `NEWS.md` heading, absence of `0.2.0.9000` in current release files |
| 2 | Do mathematical blocker rows have explicit evidence? | checklist blocker rows, targeted mathematical tests, recovery-validation summary |
| 3 | Are bounded-`GPCM` supported, caveated, blocked, and deferred routes visible before unsupported score-side workflows? | `gpcm_capability_matrix()`, README, vignettes, deferred-work notes |
| 4 | Is the FACETS relationship described as comparison/handoff support rather than numerical reproduction? | `facets_positioning_guide()`, `facets_fit_review()`, output guide |
| 5 | Can users start from summaries, status tables, and draw-free plot data before row-level internals? | summary methods, `plot(..., draw = FALSE)`, `plot_data()` |
| 6 | Do public-facing docs use review/check/traceability wording and avoid removed helper names as current API? | README/vignettes/man/cheatsheet terminology scan |
| 7 | Does package build/check complete with zero errors and zero warnings, and does CI preserve cross-platform check evidence? | `R CMD build`; `R CMD check --no-manual --as-cran`; `cran-comments.md`; GitHub Actions warning policy and check artifacts |
| 8 | Do CRAN comments, NEWS, and validation artifacts tell the same release-scope story? | `cran-comments.md`, `NEWS.md`, evidence map/checklist |

## Research anchors and release implications

| Area | Source basis | Release implication |
|---|---|---|
| Rating-scale model | Andrich (1978), Psychometrika, doi:10.1007/BF02293814 | Keep `RSM` as an equal-category-threshold reference model. Do not let bounded `GPCM` fit improvement alone replace a scoring argument that requires equal weighting. |
| Partial-credit model | Masters (1982), Psychometrika, doi:10.1007/BF02296272 | Keep `PCM` as the equal-discrimination route with step profiles that may vary by the designated step facet. Step/threshold profiles must be identified with the correct `steps - 1` degrees of freedom. |
| Generalized partial-credit model | Muraki (1992), Applied Psychological Measurement, doi:10.1177/014662169201600206 | Treat `GPCM` slopes as discrimination parameters. The release boundary should allow direct fitting, information, recovery, and screening evidence where slope-aware kernels are implemented, but should not automatically generalize Rasch-family score-side products. |
| GPCM information | Muraki (1993), ETS Research Report, doi:10.1002/j.2333-8504.1993.tb01538.x; Samejima (1974) | Use the slope-aware information identity `a^2 * Var(X | theta)`. Any GPCM bias or information display that omits the slope term is mathematically incomplete. |
| Many-facet Rasch comparison | Linacre's FACETS framework and current FACETS 4.5.0 documentation | FACETS-style comparison should be a clearly scoped comparison. mfrmr should not claim that FACETS was run unless external FACETS output is supplied and imported. |
| Fit mean-squares and ZSTD | Wright and Masters (1982); Winsteps/FACETS fit documentation | Mean-squares describe size of misfit; ZSTD depends strongly on the df convention and sample size. mfrmr should expose engine and FACETS-style df/ZSTD side by side when external comparison is the goal. |
| Simulation study design | Morris, White, and Crowther (2019), Statistics in Medicine, doi:10.1002/sim.8086 | Recovery validation should state its aim, data-generating mechanism, estimand, methods, and performance measures. Release claims should use recovery metrics, convergence, and Monte Carlo precision separately from uncertainty limitations. |
| Visual and table handoff | Same simulation-reporting logic plus fit-diagnostic practice | Plots should help users triage first: status, metric, and attention-order displays should come before raw row-level inspection. `draw = FALSE` payloads should keep reusable `reading_order` and `guidance` fields. |

## Decision rule

Use three levels when reading the checklist.

- `blocker_if_failed`: the item must be correct before 0.2.0 is released.
  These rows protect model identification, GPCM information, recovery evidence,
  GPCM scope boundaries, and package-check viability.
- `caveat_if_incomplete`: the item can ship only when the limitation is
  visible in summaries, help, and release notes. These rows usually affect
  uncertainty interpretation, FACETS comparison, or user workflow clarity.
- `roadmap_if_missing`: the item should not be represented as part of 0.2.0.
  It belongs in a later release unless validation evidence is added first.

Release-ready means: no failed blocker rows, all caveat rows either satisfy the
current evidence requirement or have an explicit user-visible limitation, and
roadmap rows are not advertised as supported behavior.

## Scorecard template

The score is intentionally a review aid, not a statistical estimate.

| Domain | Weight | What earns full credit |
|---|---:|---|
| Mathematical/statistical core | 35 | Identified parameterization, slope-aware GPCM kernels, fair-average uncertainty separation, and FACETS-style fit convention handling are correct. |
| Recovery and validation evidence | 20 | Core validation cases pass release-level recovery criteria, convergence and Monte Carlo precision are visible, and uncertainty limitations are separated. |
| User workflow and visualization | 20 | Users can start from `summary()`, then status/metric plots, then row-level tables; `draw = FALSE` returns reusable review data. |
| Help and terminology | 15 | README, vignettes, and help files use the same model-boundary language and avoid internal migration wording. |
| Release engineering | 10 | Version labels, generated help, namespace, tests, and package checks are consistent. |

Current interpretation for 0.2.0: release engineering is locally clean after
`R CMD check --no-manual --as-cran` completed with `Status: OK` on 2026-05-16
against the v0.2.0 source tarball on local macOS Tahoe 26.4.1
(aarch64-apple-darwin23), R 4.6.0. The largest residual risk is no longer the
point-estimate kernel; it is cross-platform confirmation on win-builder and
GitHub Actions. The CI workflow treats warnings as failures and uploads
per-platform check artifacts so that platform-specific warnings, notes, and log
differences can be reviewed explicitly. The remaining substantive risk is the
clarity of uncertainty and coverage limitations across all user-facing
summaries.

## Release-readiness checklist

### Mathematical and statistical adequacy

- Step and threshold profiles use the identified parameter basis, and AIC/BIC
  parameter counts match that basis.
- Bounded `GPCM` slopes use the positive geometric-mean-one log-slope
  convention in fitting, simulation generation, and recovery comparison.
- GPCM information, bias-screening SEs, category curves, and direct recovery
  checks use the slope-aware probability/information kernel.
- Fair-average SE columns distinguish measure-level SEs from structural
  fair-average SEs. A missing structural SE is reported as an availability
  limitation, not silently replaced by a measure SE.
- FACETS-style fit comparison distinguishes mean-square disagreement from
  df/ZSTD convention disagreement.

### UX and help adequacy

- First-time users can follow README `Start here first` without understanding
  every release boundary.
- Bounded `GPCM` users can find `gpcm_capability_matrix()` before using
  blocked or deferred routes.
- Recovery-validation readers see `ReleaseRecoveryStatus` before detailed
  case or metric tables.
- `summary()` output gives a top-line status before detailed tables.
- `plot(..., draw = FALSE)` output exposes reusable plot tables, not only
  side effects.
- Help pages use review/check/traceability terminology for user-facing actions;
  generated source-path headers are the only tolerated public-doc `audit`
  occurrences.

## Pre-release action plan for 0.2.0

1. Freeze the public surface:
   confirm `DESCRIPTION` is `0.2.0`, `NEWS.md` begins with `mfrmr 0.2.0`,
   and no development-suffix version label remains.
2. Confirm the breaking review-name cleanup:
   removed public `*_audit*` spellings must not appear in README, vignettes,
   generated help pages, or namespace exports.
3. Run targeted mathematical tests:
   identified step parameterization, GPCM slope identification, GPCM
   fair-average SEs, GPCM bias profile checks, person-fit `lz` /
   Snijders-corrected `lz_star` status handling, FACETS-style fit df,
   and recovery simulation.
4. Run release validation:
   use the core tier for the release gate and the extended tier as sensitivity
   evidence when time allows.
5. Run package checks:
   build the source tarball with vignettes, run
   `R CMD check --no-manual --as-cran mfrmr_0.2.0.tar.gz`, and require
   `Status: OK` locally. Then confirm that GitHub Actions matrix jobs pass
   with warnings treated as failures and retain their uploaded check artifacts
   as cross-platform evidence.
6. Review the user entry points:
   README, `mfrmr_workflow_methods`, `gpcm_capability_matrix()`,
   `mfrmr_output_guide()`, and the workflow vignette should tell the same
   story.
7. Run the release-readiness protocol:
   source `inst/validation/release-readiness.R`; confirm `gate_summary` has no
   `concern` or `review` rows locally before cross-platform checks.
8. Preserve CI evidence:
   confirm the GitHub Actions workflow treats warnings as failures, runs the
   release-readiness gate, and uploads check logs/artifacts for each matrix
   environment.

## Post-release roadmap

### 0.2.1: tighten uncertainty evidence

- Make uncertainty limitations more explicit in recovery and validation
  summaries.
- Add more edge-case recovery tests for sparse categories, extreme persons,
  missing boundary categories, unbalanced facets, and near-flat GPCM slopes.
- Add a compact user-facing table that explains when coverage is unavailable,
  not requested, or available but below threshold.
- Extend `lz_star` validation with external or independent conditional-JML
  comparison fixtures when available; keep MML/EAP scores explicitly outside
  the Snijders correction rather than approximating them as ML/MAP/WLE
  estimates.

### 0.3.0: expand bounded GPCM only where validated

- Add posterior-predictive checks for bounded `GPCM`.
- Add GPCM design-operating-characteristic evaluation after the recovery route
  is stable.
- Consider FACETS/TAM/ConQuest comparison helpers only where the estimand and
  external output contract are explicit.
- Keep APA writer, QC pass/fail pipelines, and score-side compatibility outputs
  blocked for bounded `GPCM` until their score semantics and uncertainty
  propagation are validated.

### Longer-term

- Build a reproducible release-validation report from the validation CSV/RDS
  bundle.
- Add a small pkgdown article that reads the evidence map from the perspective
  of an applied user: fit, diagnose, validate, report.
- Revisit arbitrary-facet design planning after the current role-based
  simulation layer has complete operating-characteristic validation.

## References

- Andrich, D. (1978). A rating formulation for ordered response categories.
  Psychometrika, 43, 561-573. https://doi.org/10.1007/BF02293814
- Masters, G. N. (1982). A Rasch model for partial credit scoring.
  Psychometrika, 47, 149-174. https://doi.org/10.1007/BF02296272
- Muraki, E. (1992). A generalized partial credit model: Application of an EM
  algorithm. Applied Psychological Measurement, 16, 159-176.
  https://doi.org/10.1177/014662169201600206
- Muraki, E. (1993). Information functions of the generalized partial credit
  model. ETS Research Report Series.
  https://doi.org/10.1002/j.2333-8504.1993.tb01538.x
- Morris, T. P., White, I. R., & Crowther, M. J. (2019). Using simulation
  studies to evaluate statistical methods. Statistics in Medicine, 38,
  2074-2102. https://doi.org/10.1002/sim.8086
- Winsteps.com. Facets many-facet Rasch measurement software 4.5.0.
  https://www.winsteps.com/facets.htm
- Winsteps.com. Fit diagnosis: infit outfit mean-square standardized.
  https://www.winsteps.com/winman/misfitdiagnosis.htm
- Wright, B. D., & Masters, G. N. (1982). Rating Scale Analysis. MESA Press.
