# mfrmr development roadmap

Status: authoritative project roadmap, reviewed 2026-07-27.

This file is the single source of truth for release sequencing.
`NEWS.md` records completed user-visible changes. Files under
`inst/validation/` provide technical evidence or historical context and
are subordinate to this roadmap. The roadmap is repository-only and is
excluded from source-package tarballs.

## Current position

- CRAN currently distributes 0.2.1.
- A 0.2.2 GitHub release exists, but its asset predates the current
  source-alignment candidate and must not be treated as the CRAN
  candidate. No third-party use has been reported; that lowers migration
  risk but does not remove the need to replace artifacts deliberately
  and with explicit approval.
- The estimator and public-API scope for 0.2.2 is frozen. Release-source
  alignment may still correct help execution guards, release evidence,
  and planning documents without expanding that scope.
- The preceding source-alignment commit passed the five required
  cross-platform package-check jobs plus pkgdown. The revised candidate
  has now passed an exact local full-manual `--as-cran --run-donttest`
  check with remote incoming probes enabled; CI must be rerun after the
  example-policy commit.

The central sequencing decision is deliberate: numerical trust and
external overlap evidence come before new model families. Operational
calibration and multiple observed scales come before multidimensional
latent traits.

For this roadmap, three similarly named concepts are kept separate:

- an **element anchor** fixes a Person or facet level and is already
  supported in 0.2.2, including group anchors and pre-fit review;
- a **threshold/step anchor** fixes all or part of an RSM/PCM threshold
  ladder and belongs to the single-scale calibration work in 0.2.4; and
- a **scale-specific anchor** is indexed by an explicit observed
  `ScaleId` and cannot be completed until the multi-scale architecture
  in 0.2.5.

`Umean`/`Uscale`-style score-display transformations are not estimation
anchors. Likewise, PCM thresholds that vary by the current `step_facet`
are item- or facet-specific step ladders on one observed score scale;
they are not multiple independent scales.

The dependency order is therefore: validate the current single-scale
contract in 0.2.3, make that contract reusable through typed calibration
and step anchors in 0.2.4, and only then add explicit multi-scale
parameter indexing in 0.2.5. Existing fitted-object EAP/posterior
scoring in 0.2.2 is not the same as loading a versioned frozen
calibration for operational scoring of new data.

## 0.2.2: stabilization and contract release

0.2.2 is a substantial stabilization release, not a broad API-expansion
release. Its accepted scope is:

- unidimensional `RSM`, `PCM`, and explicitly bounded `GPCM` fitting;
- direct and group anchors for Person/facet elements within a one-scale
  fit, together with anchor review and linking/drift helpers;
- a coherent data-review, fit, diagnostic, report, export, and replay
  path;
- numerical-readiness states shared across direct, hybrid, and EM MML
  routes;
- fitted-scale summaries, native and FACETS-style visualizations, and
  reusable draw-free plot data;
- conservative bias, DFF/DIF, Q3-style, and residual-screening language;
- current `eRm` import compatibility and bounded ConQuest overlap
  tooling;
- package-native bounded-GPCM score-side uncertainty with the corrected
  expected-score delta factor;
- explicit FACETS positioning, including duplicate-observation,
  agreement, score-side, and unsupported-feature boundaries; and
- reproducibility manifests, validation artifacts, documentation, and
  the hex sticker used in the README and pkgdown site.

The following are not 0.2.2 release blockers and must not be described
as current 0.2.2 features:

- same-candidate external numerical comparison against ConQuest or
  FACETS;
- a calibrated MML joint-stationarity and parameter-recovery gate;
- freely estimated latent population SD;
- model-family or estimation-scope registry helpers beyond the exported
  0.2.2 capability surfaces;
- configurable-prior EAP sensitivity helpers;
- moderation-specific DFF/DIF helpers;
- mixed response families, multiple observed score scales, general
  threshold anchoring, or fixed-calibration operational scoring;
- unrestricted GPCM, multidimensional latent traits,
  posterior-predictive checks, MCMC, or multivariate G-theory.

### 0.2.2 source-alignment exit checks

Before CRAN submission or replacement of the GitHub release asset:

Keep `DESCRIPTION`, `CITATION.cff`, `NEWS.md`, `cran-comments.md`, tag,
tarball, and check log on the same version and release date.

Build one exact candidate tarball and record its SHA-256 digest
(`dddeaaba8d2d0684784fa774b349e8fa1d13570143341daad4aa31e2990e5d00`).

Run a full-manual `R CMD check --as-cran --run-donttest` on that exact
tarball and retain the full log (`Status: OK`; 282.60 seconds wall
time).

Restrict `\dontrun{}` to the two examples requiring separately generated
ConQuest files, restrict interactive-only examples to the local Shiny
viewer, and keep the CRAN-side package workload below ten minutes (153
seconds for this candidate: examples including `donttest`, tests, and
vignette rebuilding). The 261-second sum of all timed top-level
components is retained as diagnostic context rather than used as the
package-controlled gate.

Audit README, NEWS, vignettes, generated help, and first-screen runtime
guidance for maintainer-oriented wording while retaining documented API
and status vocabulary.

Document `maxit` as a prespecified computational ceiling, make
iteration-limited fits explicitly review-only, and require numerically
ready JML and MML fits before estimator-agreement checks.

Confirm the full non-CRAN suite and all required CI matrix jobs complete
for the example-policy source before merge.

Run the updated repository release-readiness review against the exact
tarball and check log for the final example-policy source (all nine
gates `ok`).

Confirm source-package contents exclude repository-only roadmaps and
validation helpers.

Regenerate pkgdown from the final source and inspect key pages and logo.

Obtain explicit manual approval before retagging, replacing an asset, or
submitting to CRAN.

## 0.2.3: numerical trust and external evidence

0.2.3 is the external-comparison and release-gate release. It should
strengthen claims about the existing model scope before introducing a
new family. It may establish fixtures and design decisions needed by
later work, but it must not advertise a new multi-scale,
threshold-anchor, or calibration-bundle API as part of this release.

### MML joint-stationarity and recovery

Define a common terminal-gradient criterion for all MML engines and make
engine-specific stopping conditions secondary evidence.

Test objective, score, and parameter agreement at the selected solution,
including EM solutions polished by direct optimization when required.

Calibrate practical thresholds by seeded recovery studies rather than by
one optimizer trace.

Separate convergence, identification, data/design readiness, and
inferential readiness in every release decision.

Store a tested envelope covering sample size, category support, sparse
links, anchors, and bounded-GPCM slope regimes.

### External comparison gate

Compare the same data, model, constraints, quadrature, starting values,
and reported parameter transformation wherever matching is possible.

Use ConQuest for matched MML overlap cases and FACETS for supported
Rasch-family reporting or calibration overlap cases.

Classify differences as parameterization, identification, numerical,
reporting, or genuinely unsupported rather than treating one correlation
as equivalence evidence.

Keep proprietary binaries and identifier-bearing case files outside the
package while retaining aggregate, reproducible evidence.

Make external comparison a 0.2.3 gate, not a retroactive 0.2.2 blocker.

### FACETS coverage and release tooling

Extend
[`facets_feature_coverage()`](https://ryuya-dot-com.github.io/mfrmr/reference/facets_feature_coverage.md)
with separate axes for surface coverage, statistical contract,
validation evidence, and operational status, while retaining the current
`Status` column for compatibility.

Distinguish a familiar visual grammar from numerical equivalence and
operational interchangeability.

Require `--as-cran` provenance, metadata agreement, candidate identity,
and current-versus-future API truth in release-readiness output.

Replace brittle prose-only pass counts with candidate-linked evidence or
regenerate exact counts at each release.

## 0.2.4: operational calibration

0.2.4 should make stable calibrations reusable without implying that
every model is suitable for high-stakes scoring. The first
implementation target is one observed score scale; multi-scale indexing
remains deferred to 0.2.5.

Define a versioned calibration bundle containing model specification,
typed parameters, identification constraints, element/group anchors,
category map, provenance, and software version.

Add single-scale threshold/step anchor support, distinguishing partially
anchored ladders, fully fixed ladders, and starting values, with
explicit sum-to-zero/origin, degree-of-freedom, and conflict checks.

Add documented starting-value import and transformation contracts.

Add scoring from a versioned frozen calibration, with explicit handling
of unknown levels, missing categories, disconnected cases, and
out-of-range scores; keep it distinct from 0.2.2 fitted-object posterior
scoring.

Propagate calibration identity into reports, exports, and replay
manifests.

Reserve an unambiguous scale namespace in the calibration schema without
claiming that a 0.2.4 fit can contain multiple observed `ScaleId`
values.

Validate round trips, reduction cases, and external overlap before using
operational-scoring language.

## 0.2.5: multiple observed scales and mixed response structures

This release addresses observed-score complexity while retaining a
one-dimensional latent trait unless a separately validated design says
otherwise.

Represent multiple independent rating scales through an explicit
per-observation `ScaleId`; do not infer scale identity from category
values.

First establish the reduction case of multiple RSM/binary scales with
scale-specific category maps and score supports.

Then add scale-specific PCM with ragged threshold blocks, so scales and
`step_facet` levels may have different category counts without padding
them into the current global rectangular step matrix.

Extend the 0.2.4 calibration bundle and threshold-anchor contract so
every scale-specific parameter is namespaced by `ScaleId` and cannot be
applied to the wrong scale.

Define mixed binary, RSM, and PCM likelihood contributions only after
the single-scale and homogeneous multi-scale reduction tests pass.

Define active facets by observation only after scale assignment and
likelihood dispatch are explicit and auditable.

Extend plotting, information, diagnostics, exports, and calibration
bundles so scale-specific quantities cannot be silently pooled.

Add design audits for partial crossing, structurally inactive facets,
sparse scale links, and scale-specific identification. Scales without a
defensible common-person, common-element, or anchor link must fail
closed rather than be silently reported on one metric.

Demonstrate that multiple observed scales retain one latent dimension;
treat multidimensionality as a separate 0.3-or-later model claim.

## 0.3 and later: research extensions

These are separate research programs, not promises attached to 0.2.x.

- restricted multidimensional `RSM`/`PCM`, followed only later by any
  multidimensional GPCM route;
- unrestricted unidimensional GPCM with general slope design,
  covariance, and downstream-helper closure;
- posterior-predictive diagnostics and optional Bayesian/heavy backends;
- profile or multivariate G-theory with covariance-based composite
  reliability;
- alternative polytomous, rater-process, mixture, unfolding, and general
  design-matrix families; and
- larger-scale performance work after the statistical and reporting
  contracts are fixed.

Each extension needs its own estimand, identification argument, negative
tests, recovery evidence, external overlap where possible, and public
support boundary. Experimental implementation alone is not a release
claim.

## Permanent development principles

1.  The public support boundary is defined by exported code, help pages,
    tests, and release evidence together—not by an aspirational planning
    note.
2.  A helper being callable does not make its output inferentially or
    operationally ready.
3.  External comparisons are evidence within a matched overlap region,
    never a blanket equivalence claim.
4.  Screening results remain screening results; they do not become
    fairness, validity, or high-stakes decisions through formatting.
5.  Unsupported designs fail closed or carry an unavoidable caveat.
6.  CRAN-time tests stay lightweight; slower evidence is reproducible
    and retained outside the installed package.
7.  Release artifacts are tied to an exact source commit and tarball
    digest.
8.  Changes to this sequence belong in this file first; subordinate
    validation notes may add technical detail but may not redefine the
    release order.
