# mfrmr development roadmap

This roadmap keeps the package-development sequence aligned with the immediate
0.2.2 release goal and the post-release research/software extensions that are
likely to matter most to users. It is a planning artifact, not a public support
promise. Public support boundaries remain the package help pages,
`gpcm_capability_matrix()`, and release notes.

## Guiding priorities

- Keep 0.2.2 focused on a CRAN-ready, bounded-`GPCM`-safe package release that
  can support later software-article or program-exchange materials.
- Do not move complete `GPCM`, multidimensional estimation, posterior
  predictive checks, MCMC, or broad multivariate G-theory into the 0.2.2
  release boundary.
- Prefer workflow clarity, examples, diagnostics, and caveat-preserving report
  surfaces over large new estimators before any external software-article
  submission.
- Treat `Criterion` carefully: it can be a measurement facet, a rubric
  dimension, a profile dimension, or a planned-count design axis depending on
  the workflow. The documentation must state which role is active.
- Use self-contained implementations when the estimand and design assumptions
  are narrow enough to validate directly. Use external packages or external
  validation only as comparison evidence, not as hidden dependencies.

## Source-grounded G-theory correctness policy

G-theory helpers must be conservative because the coefficients are
design-specific consequences of a variance-component model, not generic
reliability summaries. The package should fail closed when a requested
projection is not identifiable from the observed design.

Sources to keep in scope:

- Brennan instructional module:
  <https://ncme.org/wp-content/uploads/2025/10/Module-14-Generalizability-Theory-Brennan-Winter-1.pdf>
- Brennan coefficients and indices report:
  <https://education.uiowa.edu/sites/education.uiowa.edu/files/2026-04/casma-research-report-1-archived.pdf>
- Shavelson, Webb, and Rowley review:
  <https://doi.org/10.1037/0003-066X.44.6.922>
- Huebner, Skar, and Huang mixed-model tutorial:
  <https://files.eric.ed.gov/fulltext/EJ1482037.pdf>
- Jiang et al. multivariate G-theory in R:
  <https://doi.org/10.3758/s13428-020-01399-z>
- Mixed-model boundary/singularity guidance:
  <https://easystats.github.io/performance/reference/check_singularity.html>

Implementation rules:

- [ ] Every G/D-study route must declare the object of measurement, universe of
  admissible observations, universe of generalization, random/fixed facet
  status, crossed/nested/confounded design structure, and intended relative or
  absolute decision before reporting coefficients.
- [ ] Every supported design needs a stated estimand, expected-mean-square or
  likelihood basis, D-study sample-size transformation, and tests against
  published or deterministic fixtures.
- [ ] Unsupported D-study transformations must return a package-native
  identification/design warning or error. Do not approximate a crossed
  D-study coefficient from a nested or confounded G-study design unless the
  needed components are explicitly identified.
- [ ] Current 0.2.2 G/D-study output remains a univariate planned-count helper.
  It must not be described as multivariate/profile G-theory, and a
  mixed-model boundary or singular fit must not be allowed to look like
  high-stakes-ready evidence.
- [ ] Negative variance-component estimates must be reported transparently.
  Keep raw estimates visible, label any nonnegative decision-use adjustment,
  and do not present a floored zero as substantive evidence that a facet has
  no variance.
- [ ] For a later profile-G-theory helper, treat `Criterion` as a fixed
  profile dimension when appropriate, not as an ordinary random facet by
  default. Estimate variance-covariance component matrices across criteria
  and include off-diagonal covariance terms in composite reliability.
- [ ] Weighted composite coefficients must be computed from covariance
  matrices, for example using `w' Sigma_p w` and the matching relative or
  absolute error covariance matrix. Averaging criterion-level univariate
  coefficients is not a valid multivariate D-study.
- [ ] Profile reliability should be exposed only when criterion scales are
  comparable or explicitly standardized and when the estimand is documented.
- [ ] Sparse, nested, heavily missing, or weakly connected rating designs are
  blocked until the design audit, estimator, simulations, and examples cover
  the same pattern.

## Release sequence

### 0.2.2: bounded GPCM safe-use release

Purpose:

- Publish a CRAN maintenance release that makes bounded `GPCM` usable with
  explicit scope boundaries.
- Prepare the package surface for possible software-article or program-exchange
  materials after CRAN publication.
- Keep examples, vignettes, checks, pkgdown, and validation evidence
  consistent with the 0.2.2 contract.

Required work:

- [ ] Keep `CITATION.cff`, `DESCRIPTION`, NEWS, README, validation artifacts,
  and generated Rd/pkgdown output aligned with 0.2.2.
- [ ] Keep the public route visible:
  `fit_mfrm()` -> `mfrm_results()` -> `mfrm_report()` ->
  `export_mfrm_results()`.
- [ ] Keep bounded `GPCM` wording conservative: bounded, sensitivity,
  screening, caveated, and not FACETS-equivalent score-side output.
- [ ] Preserve `gpcm_capability_matrix()` as the public contract and
  `gpcm_runtime_guard_coverage()` as the blocked/deferred guard audit.
- [ ] Keep model-comparison reporting routed through
  `compare_mfrm()` -> `build_model_choice_review()` ->
  `build_summary_table_bundle()`.
- [ ] Clarify the current G/D-study boundary: `mfrm_generalizability()` and
  `mfrm_d_study()` support univariate planned-count projections with
  `Criterion` as a random measurement facet, but they do not implement
  multivariate/profile G-theory.
- [x] Add a G/D-study release gate that checks source-grounded design wording
  and verifies that singular or boundary mixed-model fits cannot be surfaced
  as high-stakes-ready `G`/`Phi` evidence without an identification warning.
- [ ] Keep `mfrm_d_study()` plots, including `preset = "monochrome"`,
  compatible with the broader visual-reporting contract.
- [ ] Keep latent-regression wording first-version and one-dimensional:
  population-model coefficients, coding, omission policy, and prediction
  support; no multidimensional, Wald-test, or posterior-predictive claims.
- [ ] Keep all long-running recovery, diagnostic-screening, and article checks
  outside CRAN examples and inside explicit validation/intermediate artifacts.

Release gates:

- [ ] `R CMD build .`
- [ ] `R CMD check --as-cran mfrmr_0.2.2.tar.gz`
- [ ] `devtools::test()` or the full non-CRAN test surface when release
  evidence is refreshed.
- [ ] `Rscript inst/validation/release-readiness.R`
- [ ] `pkgdown::build_site(preview = FALSE)`
- [ ] Local pkgdown-link preflight from any external manuscript or review
  workspace.
- [ ] No submission, push, release, or pkgdown publication without explicit
  manual approval.

### Post-0.2.2: software article or program-exchange materials

Purpose:

- Submit a package/software article that demonstrates a stable, documented,
  reproducible, user-facing analysis workflow.
- Emphasize usability, examples, reporting paths, caveats, and comparison to
  related packages rather than claiming a complete new estimator family.

Required work after 0.2.2 CRAN publication:

- [ ] Regenerate CRAN snapshot evidence and package-surface evidence from the
  published 0.2.2 package.
- [ ] Rebuild pkgdown links after public site availability is confirmed.
- [ ] Re-render the article using lightweight examples and keep the body knit
  under 10 minutes.
- [ ] Keep heavy recovery/simulation evidence in intermediate files, not in
  the manuscript render path.
- [ ] Refresh model-comparison, bounded-`GPCM`, G/D-study, and latent-regression
  wording so the manuscript does not overclaim beyond the package help.
- [ ] Compare the user-facing scope against `TAM`, `mirt`, `sirt`, FACETS, and
  related G-theory workflows at the feature/workflow level, not as numerical
  equivalence unless direct comparison evidence exists.

### 0.3.0: special-case multivariate G-theory branch

Purpose:

- Add a narrow, self-contained profile-G-theory route for the common rating
  design where `Person` is the object of measurement, `Criterion` is the
  profile dimension, and `Rater` is the random measurement facet.
- Keep this separate from the existing univariate `mfrm_generalizability()` /
  `mfrm_d_study()` path.

Recommended public surface:

- [ ] `mfrm_profile_g_study()` or
  `mfrm_multivariate_generalizability()` as an experimental helper.
- [ ] `mfrm_profile_d_study()` only after the G-study estimands and
  covariance matrices are stable.
- [ ] `plot()` / `plot_data()` methods for profile reliability and composite
  reliability surfaces after the tabular contract is stable.
- [ ] Summary-table bundle support only after the object contract is stable.

Initial support boundary:

- [ ] Object facet: `Person`.
- [ ] Profile facet: `Criterion`.
- [ ] Random measurement facet: one rater-like facet, default `Rater`.
- [ ] Estimation method: self-contained method-of-moments / ANOVA-style
  estimator for strict balanced or near-balanced complete designs.
- [ ] Optional non-CRAN validation comparison against external mixed-model or
  G-theory tools, but no mandatory `lme4` dependency for the special-case
  helper.
- [ ] Return criterion-specific variance components, criterion covariance
  matrices, composite reliability, profile reliability, and caveat tables.
- [ ] Treat sparse, heavily unbalanced, nested, or missing-by-design layouts as
  `blocked` or `supported_with_caveat` until explicit validation exists.

Singular-fit and estimator policy:

- [ ] Do not base the first profile-G-theory helper on a mandatory
  `lme4::lmer()` random-interaction model such as
  `(1 | Person:Rater) + (1 | Person:Criterion) + (1 | Rater:Criterion)` as
  the primary estimator. Such models are useful validation comparisons, but
  sparse or unbalanced rating designs can produce singular fits when variance
  components are not identifiable from the observed design.
- [ ] Treat singular mixed-model fits as design/identification evidence, not
  as routine success. A zero or near-zero variance component can be
  theoretically admissible in G-theory, but a singular fit with multiple
  interaction terms usually means the current design does not support
  separating those components for D-study use.
- [ ] Prefer a self-contained method-of-moments / expected-mean-squares route
  for the first special case because it can state the balance assumptions,
  estimands, covariance terms, truncation policy, and blocked designs
  directly.
- [ ] Return both raw and decision-use variance-component estimates when
  negative components occur. If nonnegative truncation is used for a
  reliability or D-study denominator, label that column explicitly and keep
  the raw estimate available for review.
- [ ] Add a design audit before estimation. Strictly balanced designs can be
  `supported`; near-balanced designs can be `supported_with_caveat` only if
  the estimator and simulations cover that imbalance pattern; sparse linked,
  nested, and heavily missing layouts must be `blocked` until separately
  validated.

Evidence required before CRAN release:

- [ ] Derive and document the estimands, expected mean squares, covariance
  estimators, and reliability formulas in package help.
- [ ] Add deterministic balanced-design fixtures with known variance/covariance
  components.
- [ ] Add simulation recovery checks for variance, covariance, composite
  reliability, and profile reliability.
- [ ] Add design-audit tests that block unsupported sparse/unbalanced cases
  with package-native errors.
- [ ] Add fixtures where an external mixed-model comparison is singular and
  verify that the package interprets this as an identification/design warning
  rather than silently treating the D-study projection as fully supported.
- [ ] Add examples that are small enough for CRAN and vignettes that explain
  how this differs from ordinary univariate D-study projection.
- [ ] Add terminology tests preventing the current univariate
  `mfrm_d_study()` from being described as multivariate/profile G-theory.

Stop conditions:

- [ ] Do not expose broad arbitrary-facet multivariate G-theory in 0.3.0.
- [ ] Do not claim REML-equivalent mixed-model estimation from the
  self-contained method-of-moments route.
- [ ] Do not treat singular `lme4` comparison fits as validation success for
  profile-G-theory D-study projections.
- [ ] Do not support sparse linked designs by silent approximation.
- [ ] Do not merge profile-G-theory output into the ordinary `G`/`Phi` route
  without explicit labels for scalar, composite, and profile decisions.

### 0.3.x: bounded-GPCM evidence strengthening

Purpose:

- Strengthen the existing caveated bounded-`GPCM` workflows without turning the
  release into a complete-`GPCM` or JSS-style estimator paper.

Work packages:

- [ ] Expand parameter-recovery and score-support stress fixtures across slope
  regimes, sample sizes, sparse designs, and local dependence conditions.
- [ ] Keep RSM/PCM versus bounded-`GPCM` model-choice output tied to
  equal-weighting reference and slope-aware sensitivity roles.
- [ ] Improve fair-average and weighting-review reporting surfaces.
- [ ] Keep score-side export caveats separate from FACETS equivalence claims.
- [ ] Add optional comparison tables against `TAM`, `mirt`, and `sirt` only
  where estimands are clearly matched.

### 0.4.0: broader profile/design reporting

Purpose:

- Turn the special-case profile-G-theory branch into a mature reporting
  workflow if 0.3.0 evidence is stable.
- Improve decision-support surfaces for score profiles, composite scores,
  criterion-level reporting, and design planning.

Candidate work:

- [ ] Add profile D-study projections for rater count, criterion inclusion,
  and composite weighting.
- [ ] Add profile-specific appendix tables and APA/report templates.
- [ ] Add user-controlled composite weights with clear default equal-weighting
  behavior.
- [ ] Add criterion-level and composite reliability visualizations with
  monochrome presets.
- [ ] Add stronger links between profile-G-theory output and
  `build_model_choice_review()` / reporting workflows when bounded `GPCM` is
  also present.
- [ ] Consider broader unbalanced-design support only after the special-case
  estimators, tests, and examples are stable.

### Later research branches

These are intentionally post-0.4.0 unless separately prioritized.

- [ ] Complete `GPCM` score-side equivalence review.
- [ ] Multidimensional IRT estimation.
- [ ] Posterior predictive checks.
- [ ] MCMC or heavy backend support.
- [ ] Arbitrary-facet multivariate G-theory.
- [ ] Full external-engine numerical equivalence studies.
- [ ] JSS-style simulation article route, if the package grows into a
  methods/estimation contribution rather than primarily a software workflow
  contribution.

## Cross-cutting engineering rules

- Every new statistical helper needs a stated estimand, supported design
  class, blocked design class, source-grounded references, examples, and
  failure-mode tests.
- Every report/export helper must preserve caveats rather than hiding them in
  prose.
- Every public route needs at least one beginner-readable example and one
  reviewer-facing limitation statement.
- New plots must support `draw = FALSE` and should support
  `preset = "monochrome"` when they are manuscript-facing.
- CRAN examples stay lightweight; long-running validation belongs in explicit
  scripts and intermediate artifacts.
- Do not add a dependency just to avoid writing a narrow validated estimator,
  but also do not replace mature external estimation machinery with an
  under-validated approximation.
- Singular mixed-model comparisons are allowed as diagnostic evidence, but a
  singular fit is not a green light for D-study projection. Treat it as a
  design-identification warning unless the special-case estimator has direct
  validation for the same design pattern.

## Current decision log

- 0.2.2 does not include complete `GPCM`.
- 0.2.2 does not include multivariate/profile G-theory.
- The current `mfrm_d_study()` supports `Criterion` as a planned-count
  measurement facet in a univariate projection.
- Special-case multivariate G-theory is valuable and should be considered for
  0.3.0, but only with a self-contained, narrow, validated method-of-moments
  implementation and explicit blocked routes for unsupported designs.
- `lme4` random-interaction fits may be retained as optional validation
  comparisons, but not as the mandatory estimator for the special-case
  profile-G-theory branch.
