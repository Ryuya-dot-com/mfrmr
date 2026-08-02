# mfrmr development roadmap

Status: authoritative project roadmap, reviewed 2026-08-03.

This file is the single source of truth for release sequencing. `NEWS.md`
records completed user-visible changes. Files under `inst/validation/` provide
technical evidence or historical context and are subordinate to this roadmap.
The roadmap is repository-only and is excluded from source-package tarballs.

## Current position

- CRAN currently distributes 0.2.2, published on 2026-07-27. That published
  package is the immutable public baseline for all 0.2.3 development.
- The exact 0.2.2 source asset is `mfrmr_0.2.2.tar.gz`, SHA-256
  `dddeaaba8d2d0684784fa774b349e8fa1d13570143341daad4aa31e2990e5d00`,
  built from tagged source commit `03915badf336eeaeb7ef7fbb5119c2880c541e63`.
- That asset passed a local full-manual `R CMD check --as-cran
  --run-donttest`, official Win-builder R-devel, the five-platform package
  matrix, the full non-CRAN suite, and pkgdown. The repository-only CRAN
  preparation change was squash-merged as `10cf3e8`; its tree also passed the
  post-merge package matrix and pkgdown.
- Version 0.2.2 was accepted and published by CRAN on 2026-07-27. The submitted
  tarball, tag, and release asset remain frozen. CRAN adds repository metadata
  and an `MD5` manifest to its distributed source, so the submitted compressed
  digest and CRAN-distributed compressed digest are distinct identities even
  though the audited package payload agrees.
- The isolated integration branch now carries package identity 0.2.3. This is
  an unreleased development target, not a release candidate: candidate freeze,
  confirmation, and submission remain prohibited until the M3-M5 evidence and
  identity gates pass.
- If CRAN later asks for a 0.2.2 correction, that work branches from the
  published/tagged source and must not absorb unfinished 0.2.3 implementation.

The central sequencing decision is deliberate: numerical trust and external
overlap evidence come before new model families. Operational calibration and
multiple observed scales come before native multidimensional latent-trait
estimation. An external multidimensional challenge to the current
unidimensional claim belongs to 0.2.3 validation; a native multidimensional
engine and dimension-specific score production remain 0.3-or-later work.

For this roadmap, three similarly named concepts are kept separate:

- an **element anchor** fixes a Person or facet level and is already supported
  in 0.2.2, including group anchors and pre-fit review;
- a **threshold/step anchor** fixes all or part of an RSM/PCM threshold ladder
  and belongs to the single-scale calibration work in 0.2.4; and
- a **scale-specific anchor** is indexed by an explicit observed `ScaleId` and
  cannot be completed until the multi-scale architecture in 0.2.5.

`Umean`/`Uscale`-style score-display transformations are not estimation
anchors. Likewise, PCM thresholds that vary by the current `step_facet` are
item- or facet-specific step ladders on one observed score scale; they are not
multiple independent scales.

The dependency order is therefore: validate the current single-scale contract
in 0.2.3, make that contract reusable through typed calibration and step
anchors in 0.2.4, and only then add explicit multi-scale parameter indexing in
0.2.5. Existing fitted-object EAP/posterior scoring in 0.2.2 is not the same as
loading a versioned frozen calibration for operational scoring of new data.

## 0.2.2: stabilization and contract release

0.2.2 is a substantial stabilization release, not a broad API-expansion
release. Its accepted scope is:

- unidimensional `RSM`, `PCM`, and explicitly bounded `GPCM` fitting;
- direct and group anchors for Person/facet elements within a one-scale fit,
  together with anchor review and linking/drift helpers;
- a coherent data-review, fit, diagnostic, report, export, and replay path;
- numerical-readiness states shared across direct, hybrid, and EM MML routes;
- fitted-scale summaries, native and FACETS-style visualizations, and reusable
  draw-free plot data;
- conservative bias, DFF/DIF, Q3-style, and residual-screening language;
- current `eRm` import compatibility and bounded ConQuest overlap tooling;
- package-native bounded-GPCM score-side uncertainty with the corrected
  expected-score delta factor;
- explicit FACETS positioning, including duplicate-observation, agreement,
  score-side, and unsupported-feature boundaries; and
- reproducibility manifests, validation artifacts, documentation, and the hex
  sticker used in the README and pkgdown site.

The following are not 0.2.2 release blockers and must not be described as
current 0.2.2 features:

- same-candidate external numerical comparison against ConQuest or FACETS;
- a calibrated MML joint-stationarity and parameter-recovery gate;
- freely estimated latent population SD;
- model-family or estimation-scope registry helpers beyond the exported 0.2.2
  capability surfaces;
- configurable-prior EAP sensitivity helpers;
- moderation-specific DFF/DIF helpers;
- mixed response families, multiple observed score scales, general threshold
  anchoring, or fixed-calibration operational scoring;
- unrestricted GPCM, multidimensional latent traits, posterior-predictive
  checks, MCMC, or multivariate G-theory.

### 0.2.2 source-alignment exit record

The submitted candidate completed the following checks:

- [x] Keep `DESCRIPTION`, `CITATION.cff`, `NEWS.md`, `cran-comments.md`, tag,
  tarball, and check log on the same version and release date.
- [x] Build one exact candidate tarball and record its SHA-256 digest
  (`dddeaaba8d2d0684784fa774b349e8fa1d13570143341daad4aa31e2990e5d00`).
- [x] Run a full-manual `R CMD check --as-cran --run-donttest` on that exact
  tarball and retain the full log (`Status: OK`; 282.60 seconds wall time).
- [x] Restrict `\dontrun{}` to the two examples requiring separately generated
  ConQuest files, restrict interactive-only examples to the local Shiny viewer,
  and keep the CRAN-side package workload below ten minutes (153 seconds for
  this candidate: examples including `donttest`, tests, and vignette
  rebuilding). The 261-second sum of all timed top-level components is retained
  as diagnostic context rather than used as the package-controlled gate.
- [x] Audit README, NEWS, vignettes, generated help, and first-screen runtime
  guidance for maintainer-oriented wording while retaining documented API and
  status vocabulary.
- [x] Document `maxit` as a prespecified computational ceiling, make
  iteration-limited fits explicitly review-only, and require numerically ready
  JML and MML fits before estimator-agreement checks.
- [x] Confirm the full non-CRAN suite and all required CI matrix jobs complete
  for the example-policy source before merge.
- [x] Run the updated repository release-readiness review against the exact
  tarball and check log for the final example-policy source (all nine gates
  `ok`).
- [x] Confirm source-package contents exclude repository-only roadmaps and
  validation helpers.
- [x] Regenerate pkgdown from the final source and inspect key pages and logo.
- [x] Obtain explicit manual approval before retagging, replacing an asset, or
  submitting to CRAN.
- [x] Archive the official Win-builder R-devel result (`Status: OK`; 55-second
  installation and 335-second check) before the temporary result expired.
- [x] Submit the immutable tarball to CRAN without rebuilding it after the
  repository-only preparation merge.

Published 0.2.2 follow-up is operational, not permission to broaden the
package:

- [x] Record CRAN acceptance and publication on 2026-07-27. No CRAN-requested
  source correction is present in the repository record reviewed on
  2026-08-03.
- [x] Verify the CRAN package page and automatically built Windows/macOS
  binaries for 0.2.2.
- [ ] Resolve or attribute the current r-devel Debian GCC CRAN NOTE reporting
  residual `~/tmp/scratch/Rtmp*` directories. Until then, describe the public
  matrix as 12 `OK` and one `NOTE`, not as all-OK.
- [x] Keep any future CRAN-requested 0.2.2 correction isolated from 0.2.3 and
  require an explicit version policy before editing the published line.

## 0.2.3: numerical trust and external evidence

0.2.3 is a numerical-trust release for the existing single-scale contract. Its
purpose is to make release claims harder to earn, not to maximize the number of
new functions. Small API changes are allowed only when they expose evidence or
prevent an unsupported interpretation. A new response family or scoring
architecture requires a later release.

### Release contract

The release owns these outcomes:

- a candidate-linked MML stationarity and recovery gate shared by direct,
  hybrid, and EM routes;
- a prespecified stress envelope for connected, weakly linked, sparse, and
  deliberately disconnected designs;
- a candidate-linked dimensionality challenge that separates exploratory
  residual evidence, confirmatory external model comparison, and the practical
  value of any proposed dimension-specific score;
- an explicit MML information-criterion contract that records the likelihood
  basis, free-parameter count, independent sampling unit, exact formula, and
  integration evaluation used for every reported criterion;
- a same-candidate ConQuest MML overlap gate for the supported overlap region;
- row-specific FACETS evidence for any coverage claim promoted in 0.2.3;
- versioned, machine-readable gate criteria and evidence manifests; and
- release tooling that cannot silently reuse a log, tarball, external result,
  threshold set, or prose pass count from another candidate.

The public estimator vocabulary remains `MML` and `JML`. `JMLE` remains only a
backward-compatible input alias that resolves to `JML`; `MMLE` may describe a
statistical estimator in prose but is not a third `fit_mfrm()` method label.
JML and MML estimate persons differently, so agreement between their person
measures is not a release gate. Comparisons must name a common estimand and
transformation before a tolerance is applied.

The following remain outside 0.2.3:

- threshold/step anchors and frozen-calibration operational scoring (0.2.4);
- multiple observed `ScaleId` values, scale-specific anchors, scale-specific
  PCM, and mixed response structures (0.2.5);
- freely estimated latent population SD, configurable-prior EAP sensitivity,
  and moderation-specific DFF/DIF as new public contracts;
- new exported model-family or estimation-scope registries beyond structured
  evidence needed for the existing 0.2.3 support boundary;
- unrestricted GPCM, native multidimensional latent-trait estimation,
  dimension-specific score production, posterior-predictive checks, MCMC, and
  multivariate G-theory; and
- an automated dependency on proprietary ConQuest or FACETS software.

### Work sequence and evidence invalidation

| Milestone | Work | Required exit artifact |
| --- | --- | --- |
| M0: freeze the published 0.2.2 baseline | Keep the accepted asset and tag immutable. Conduct 0.2.3 gate-specification, pilot, and package work only under the explicit 0.2.3 identity; any later 0.2.2 correction branches from the published tag. | CRAN acceptance is recorded, and correction and development paths remain separate before M3. |
| M1: draft the gate specification | Define scenario IDs, estimands, parameter transformations, readiness states, evidence roles, blocking rows, information-criterion formulas/sample-size bases, dimensionality discovery/confirmation partitions, candidate Q matrices, consequence criteria, and explicit pilot-required numeric criteria. | Versioned draft `inst/validation/release-gate-spec-0.2.3.md` and `inst/validation/release-evidence-checklist-0.2.3.csv` committed with review; confirmation remains unauthorized. |
| M2: instrument, pilot, and freeze | Add independent gradient/objective checks, scenario generators, corrected MML information-criterion instrumentation, external normalization, a TAM dimensionality runner, integration-stability checks, fail-closed import guards, and candidate manifests. Use pilot-only data to calibrate every unresolved criterion, then freeze the specification before confirmation. | Reproducible pilot report with criterion changes recorded plus a reviewed `0.2.3-frozen.*` specification/checklist containing no unresolved blocker criterion and no release decision. |
| M3: freeze one candidate | Freeze source commit, dependency lock information, external-tool versions, input/partition/Q-matrix fingerprints, integration controls, seeds, and tarball digest. | Candidate manifest that uniquely identifies every internal and external input. |
| M4: run confirmation | Run the locked core recovery/stress matrix, dimensionality challenge, and matched external comparisons without changing criteria or reusing discovery data as independent confirmation. | Candidate-linked internal and external evidence with every blocker classified. |
| M5: release handoff | Run full regression, cross-platform CI, manuals, URL checks, CRAN-time examples, Win-builder, package-content audit, and public-claim audit. | All blocker rows `ok`, all caveats visible, and an exact checked tarball. |

The repository now contains `0.2.3-draft.16` planning artifacts at
`inst/validation/release-gate-spec-0.2.3.md` and
`inst/validation/release-evidence-checklist-0.2.3.csv`. They deliberately
record unresolved pilot-calibrated criteria and therefore do not authorize
confirmation or constitute release evidence. The source-grounded M1 review is
recorded in `inst/validation/release-gate-m1-review-0.2.3.md`; the exact IC
arithmetic/policy fixtures begin M2 instrumentation. M1 is content-complete
but remains an open repository milestone until these artifacts receive the
normal commit/review handoff. M2 completes only after package instrumentation
and pilot work have resolved every blocking criterion and the specification
is promoted to a reviewed `0.2.3-frozen.*` identity.

The current M2 development branch now contains the first package-side G3
instrumentation: one internal Person-basis AIC/BIC/SABIC builder, a retained-
vector `Npar` assertion, explicit JML/non-unit-weight/legacy states, stored-
value and integration/constraint fail-closed checks in `compare_mfrm()`, and
independent free-dimension fixtures. Repository-only common-GHQ evaluators now
separate fixed-vector integration drift from independent-refit drift. The
six-scenario fixed-vector and refit matrices are recorded as
`review`; together they support the draft public boundary that q<31 retains
raw ICs but cannot generate automatic comparison conclusions. Draft.5 also
adds the repository-only external-IC v1 arithmetic/identity contract and makes
public TAM imports fail closed for JML and multidimensional objects. Draft.6
adds the separate dimension-aware TAM runner, a 32-fit true-1D/true-2D
product-quadrature/deterministic-QMC matrix, and exact 1024-node QMC replay
checks. Draft.7 adds explicit ConQuest stopping controls and a matrixout-history
handoff that audits deviance, free dimension, the final exported parameter
vector, unit weights, exact bundle-to-export Person IDs, run metadata, and
output fingerprints without parsing the free-form summary report. Draft.8
fixes the generated ConQuest benchmark controls at parameter change `1e-8`,
deviance change `1e-10`, and 2000 iterations. In one 60-Person, 31-node binary
pilot, the ConQuest-minus-mfrmr deviance difference fell from approximately
`5.33e-4` under ConQuest's default stopping rule to `-4.14e-7` under the strict
controls, within the six-decimal ConQuest CSV resolution; the largest audited
transformed-parameter difference was `5.77e-6`. This resolves the apparent
likelihood-constant discrepancy for that pilot only. Draft.9 adds a
repository-only binary node-ladder preparer/reviewer that never launches
ConQuest. Under strict mfrmr and ConQuest controls, q=31, 61, 91, and 121 all
passed the arithmetic handoff with the same six-decimal ConQuest deviance;
the repeated q=31 native CSV set was byte-identical. The q=7 and q=15 rows
were rejected because the terminal history vector did not match the retained
native exports. Draft.10 adds a repository-only four-category RSM/PCM
preparer/reviewer, again without launching ConQuest. On one byte-identical
120-Person, five-item, q=31 input, both model families passed the native
history/export handoff with matched free dimensions (RSM 9; PCM 17), exact
sum-zero reconstruction, maximum absolute deviance difference `1.25e-6`, and
maximum transformed-parameter difference `1.60e-6`; the cross-engine
RSM-minus-PCM deviance-drop difference was `1.11e-6`. Draft.11 extends that
runner to q=7, 15, 31, 61, 91, and 121 plus a fresh q=31 repeat for each model.
Every q=31--121 RSM and PCM core row passed the arithmetic handoff; ConQuest
deviance was constant at its six-decimal export resolution, the maximum
absolute cross-engine deviance difference was `1.25e-6`, and the maximum
transformed-parameter difference was `1.6743e-6`. Within each model, all five
native q=31 CSV files were byte-identical across the two runs. The low-node
rows remained diagnostic only: RSM q=7/q=15 and PCM q=15 were extractable but
showed material objective and parameter drift, while PCM q=7 was rejected for
a `1e-6` final-history/export mismatch. This completes same-platform
likelihood/constraint mapping, the polytomous node ladder, and same-platform
repetition only. Independent platform/version replication, replicated and
confounded dimensionality cells, multi-node/platform stochastic integration,
weak-link/near-boundary cells, numeric freeze, and confirmation remain
pending.

Draft.12 adds the first repository-only G1 canonical-score pilot. Five fixed
binary/RSM/PCM/GPCM runs use q=31 and a three-step independently implemented
central-difference ladder at both the retained solution and a deterministic
nonzero-score probe. Across the ten run/point summaries, the largest absolute
analytic-versus-numeric difference was `6.91e-9`, and the largest numeric
step-ladder range was `6.91e-8`. The existing bounded-GPCM implementation was
also clarified: it has no optimizer box bounds, but maps `n-1` free log slopes
to sum-zero expanded log slopes and then exponentiates them. The independently
checked transformation Jacobian differed by at most `3.00e-10`, and exact
binary RSM=PCM and unit-slope GPCM=PCM probability/objective/common-score
reductions held. These are fixed-fixture pilot and structural-regression
results only. `NUM-SCORE-TOL`, an expanded near-boundary grid,
independent-engine replication, and confirmation remain unresolved.

Draft.13 adds the first repository-only G1 common-vector engine-path pilot.
Four fixed binary/RSM/PCM runs compare direct, hybrid, and converged-EM plus
common-direct-polish solutions; raw EM is retained as a diagnostic path, and
the polish must start from its exact hashed retained vector. Every one of the
four path vectors was re-evaluated through the direct, EM, and hybrid contexts
under identical q=31 likelihood, score, coordinate, and constraint structures.
The objective and score evaluator ranges were exactly zero over all 16
run/path summaries. Across the 12 mandatory path pairs, the largest objective
difference was `1.47e-10`, and the largest free or sum-zero-expanded parameter
difference was `5.73e-6`. These maxima are calibration observations, not
thresholds. The scope registry also makes the current engine boundary
explicit: additive RSM/PCM enter this pilot, while GPCM has only a direct
engine and EM/hybrid requests fall back to direct; interaction and latent-
regression requests with unsupported engines are likewise fallback rows, not
parity evidence. `NUM-OBJECTIVE-TOL`, `NUM-PARAMETER-TOL`, expansion across
fixtures/platforms, independent replication, and confirmation remain
unresolved.

Any source change that can alter the installed package or a validation result
invalidates M3-M5 evidence. A documentation-only change may retain numerical
evidence only when the manifest proves that the package payload and claimed
scope are unchanged. Changing a confirmatory tolerance after seeing a result
creates a new gate-specification version and requires the complete
confirmatory run to be repeated.

Following 0.2.2 acceptance, the canonical integration source moves directly
to `Version: 0.2.3` so unpublished behavior cannot masquerade as the CRAN
0.2.2 package. This version identity names the development target; it does not
authorize M3 candidate freeze, confirmatory evidence, or release claims. A
candidate becomes valid only when the exact source, tarball, check log, frozen
specification, checklist, and gate results are bound by the candidate manifest.

### Gate model

| Gate | Blocking requirement | Evidence that does not suffice |
| --- | --- | --- |
| Candidate identity | Source commit, tarball digest, package version, dependency/runtime metadata, seeds, and external input fingerprints agree. | A branch name, a newer file modification time, or an unpaired check log. |
| Numerical stationarity | The retained MML solution passes the common canonical free/transformed-coordinate score rule and objective/parameter cross-engine checks. | Optimizer code zero, `maxit` exhaustion, or one engine's native message alone. |
| Recovery envelope | Prespecified core cells meet their bias, RMSE, supported-interval coverage, failure-rate, and Monte Carlo-precision criteria for each claimed parameter class. | One successful seed, aggregate correlation, or pooled results that hide a failed cell. |
| Sparse/design behavior | Connected sparse cells are classified correctly; disconnected and unidentified negative controls fail closed and cannot become inferentially ready. | Convergence without connectivity, category support, or identification evidence. |
| Information criteria | Comparable MML fits expose the same observed-data likelihood basis, free dimension after constraints, Person-based sample size for the current fixed-facet model, exact AIC/BIC/SABIC formula, and locked integration evaluation. | Response-row `N`, summed observation weights, JML incidental-parameter IC ranking, an unlabeled native `aBIC`, or a ranking that changes across the integration ladder. |
| Dimensionality challenge | Prespecified synthetic 1D/2D controls, matched mfrmr/TAM 1D fits, independently confirmed TAM alternatives, integration-stability checks, rater-by-criterion confounding checks, and consequence classifications meet their locked criteria. | A naive LRT p-value, significance driven only by large N, a Q matrix generated and confirmed on the same data, one QMC node count, or better multidimensional fit without score-utility evidence. |
| External overlap | Matched ConQuest core rows pass locked estimand-specific tolerances; any promoted FACETS row has matched external evidence. | Correlation alone, unmatched constraints, or comparison of MML/EAP persons with FACETS-style JML persons. |
| Public contract | Code, help, README, vignettes, capability tables, exports, and runtime guards state the same support boundary. | A roadmap sentence or callable internal helper by itself. |
| Engineering release | Exact-candidate checks, full suite, platform matrix, manuals, package contents, URLs, examples, timing, and Win-builder are acceptable. | A source-tree check that was not run on the upload tarball. |

`blocker`, `caveat`, and `roadmap` remain separate states. A blocker failure is
0.2.3 `No-Go`. A caveat may ship only when it is unavoidable in first-screen
output and documentation. A roadmap row must be guarded from ordinary use and
must not be advertised as implemented.

### MML stationarity and independent numerical checks

- [x] Add and run the draft.12 fixed-fixture pilot that verifies analytic score
  components against an independently implemented central-difference
  reference on small binary, RSM, PCM, and bounded-GPCM fixtures. This checks
  instrumentation and supplies calibration data; it is not confirmation.
- [x] Define the canonical free-parameter score for the current models and
  store the bounded-GPCM coordinate system and transformation Jacobian. The
  current positive-slope GPCM route is transformed, not box-constrained, so no
  projected-gradient rule applies to it.
- [ ] Expand the score pilot by model/parameter class and near-boundary slope
  regime, then freeze absolute/scaled `NUM-SCORE-TOL` before confirmation.
- [x] Add and run the draft.13 fixed-fixture pilot that compares direct,
  hybrid, and converged-EM-plus-common-direct-polish routes at the same
  retained parameter vectors, objective, quadrature, coordinate order, and
  identification constraints. This instruments the contract; it does not
  freeze agreement tolerances or establish confirmation evidence.
- [x] In that pilot, retain raw EM and native optimizer states only as
  diagnostics; neither can override the common-vector or canonical-score
  rules, and EM-plus-polish must start from the exact hashed raw-EM vector.
- [ ] Expand the engine-path pilot by fixture, parameter class, and platform,
  then freeze absolute/scaled `NUM-OBJECTIVE-TOL` and
  `NUM-PARAMETER-TOL` before confirmation.
- [ ] Preserve the 0.2.2 `maxit` contract: use a prespecified ceiling sequence,
  never select a preferred result by rerunning until a desired answer appears,
  and keep iteration-limited fits review-only.
- [x] Add exact reduction checks: two-category polytomous cases reduce to the
  intended binary model, RSM/PCM unit-slope cases agree, and bounded-GPCM
  score-side transformations use the same retained fit.
- [ ] Keep JML regression and FACETS-overlap checks distinct from the MML
  recovery gate; no JML-versus-MML equality criterion is permitted.

### Recovery and sparse-data stress envelope

- [ ] Define core cells across response family, sample size, facet-level count,
  category support, anchor pattern, link density, and bounded-GPCM slope
  regime. Select replication counts from a prespecified Monte Carlo standard-
  error target rather than convenience.
- [ ] Separate ordinary sparse-but-connected, weak-link/bridge, articulation,
  zero-common-person-pair, disconnected, empty-category, and extreme-score
  scenarios. Do not pool these into one generic `sparse` label.
- [ ] Record numerical convergence, identification, data/design readiness,
  inferential readiness, bias, RMSE, interval coverage where defined,
  terminal score, objective, condition indicators, and elapsed time by cell.
- [ ] Require disconnected or unidentified negative controls to fail closed.
  A negative control reported as numerically and inferentially ready is a
  blocker even if its optimizer converged.
- [ ] Use three execution tiers: a deterministic CRAN smoke tier, a release-
  blocking core tier outside CRAN, and an extended sensitivity tier that cannot
  hide a failed core cell.
- [ ] Retain per-replicate results outside the package, compact aggregate
  evidence in the repository, and a manifest linking both to the candidate.

### Information-criterion contract for fitted MML objects

For the current marginal MML models, persons are the independent likelihood
units after the latent person parameter is integrated out, while item, rater,
criterion, step, and interaction effects remain fixed parameters. The 0.2.2
implementation instead uses response-row count, or the sum of observation
weights, in the BIC penalty. That value may remain as descriptive/legacy `N`,
but it must not remain the implicit BIC sample size in 0.2.3.

- [x] Add an auditable criterion record to fitted MML objects and
  `compare_mfrm()`: deviance `D = -2 logLik`, free-parameter count `k`,
  `ICSampleSize`, `ICSampleSizeBasis`, formula identifier, and integration
  evaluation identity. Compute the common panel as
  `AIC = D + 2k`, `BIC = D + log(N_person) k`, and
  `SABIC = D + log((N_person + 2) / 24) k`, with an explicit
  `sclove_n_plus_2_over_24` formula identifier.
- [x] Count `k` as the dimension of the free optimization vector after all
  anchors, centering constraints, and fixed parameters. MML posterior person
  estimates are not free model parameters; estimated latent-regression,
  variance/covariance, slope, step, and interaction coordinates are. Assert
  the stored count against the retained optimization vector.
- [x] Keep response rows, weighted response total, and unique Persons in
  separate fields; do not silently repurpose the legacy summary `N`. Regression
  fixtures show that unbalanced and missing response layouts do not convert
  fixed-facet MML BIC back to response-row N.
- [x] At the deliberate development-version transition, add the visible
  0.2.2-to-0.2.3 NEWS migration note and align `DESCRIPTION` and
  `CITATION.cff` on 0.2.3 while preserving the historical 0.2.2 NEWS section.
- [x] Fail closed for non-unit observation weights until their sampling
  semantics are explicit. In particular, `sum(Weight)` is not automatically
  the number of independent Persons. In 0.2.3, explicit all-unit weights are
  equivalent to the unweighted path, while every non-unit observation-weight
  fit—including a weight constant within Person—remains descriptive and
  carries `ICComparable = FALSE`.
- [x] Keep JML outside primary AIC/BIC/SABIC ranking. Its fitted person effects
  are incidental parameters whose number grows with the Person sample, so a
  finite raw value must be labelled descriptive rather than treated as the
  same asymptotic criterion used for marginal MML.
- [ ] Normalize external MML comparisons by recomputing AIC, Person-based BIC,
  and common `SABIC` from each engine's comparable deviance, `k`, and Person
  count. Preserve each engine's native IC fields and exact formula separately.
  TAM's native `aBIC` must not be relabelled as common `SABIC`; the audited TAM
  4.3-25/source snapshot uses `log((n - 2) / 24)`, whereas the prespecified
  common Sclove form uses `log((n + 2) / 24)`. Every later external run must
  re-record its installed TAM version and formula rather than assuming this
  snapshot remains unchanged.
  - [x] Add repository-only contract `mfrmr_external_ic_v1`, backed by the
    package's single common-panel formula builder. It keeps every native
    criterion and formula separate, requires explicit observation,
    likelihood, constraint, integration-evaluation, and integration-comparison
    identities, and suppresses deltas/weights until convergence and integration
    stability both pass.
  - [x] Add seven arithmetic/fail-closed fixtures plus a TAM 4.3-25 adapter
    check showing that native `aBIC = D + log((n - 2) / 24)k` is preserved and
    differs from common Sclove `SABIC = D + log((n + 2) / 24)k`.
  - [x] Extend the generated ConQuest handoff with an estimate `matrixout`
    history CSV, explicit stopping controls, and a repository-only adapter. It
    audits deviance, free dimension by two independent paths, the final
    exported parameter vector, unit weights, exact bundle-to-export Person
    IDs, run metadata, convergence-evidence identity, integration-evaluation
    identity, and output fingerprints without parsing the free-form summary
    report.
  - [x] Run one strict-control, 31-node binary development pilot. Its deviance
    matched mfrmr within the six-decimal ConQuest export resolution and its
    largest audited transformed-parameter difference was `5.77e-6`; this is
    pilot evidence, not a frozen tolerance or release result.
  - [x] Add a repository-only strict binary ladder at
    `q = 7, 15, 31, 61, 91, 121` plus an independent same-platform q=31
    rerun. The q=31--121 arithmetic rows shared the same six-decimal ConQuest
    deviance, and all five native q=31 CSV files were byte-identical across
    runs. The adapter rejected q=7 after ConQuest retained an earlier
    higher-likelihood solution and rejected q=15 because its final history and
    exported vectors differed by up to `8.7e-5`. This is pilot calibration,
    not an integration-stability pass.
  - [x] Add a repository-only four-category q=31 RSM/PCM pilot on one fixed
    120-Person, five-item input. The native free dimensions were 9 and 17,
    reconstructed item and step constraints had zero residual, both objective
    differences were at most `1.25e-6`, and transformed-parameter differences
    were at most `1.60e-6`. The RSM-minus-PCM deviance-drop difference across
    engines was `1.11e-6`. This is same-platform mapping evidence only.
  - [x] Extend the same fixture to matched RSM/PCM ladders at
    `q = 7, 15, 31, 61, 91, 121` plus fresh same-platform q=31 repeats. Every
    q=31--121 core row passed, the largest cross-engine deviance and
    transformed-parameter differences were `1.25e-6` and `1.6743e-6`, and each model's
    five native q=31 CSV files were byte-identical across repeats. RSM q=7/q=15
    and PCM q=15 remained arithmetically extractable but numerically unstable;
    PCM q=7 failed closed on a final-history/export mismatch. This calibrates
    the ladder but freezes no tolerance.
  - [ ] Repeat the binary and polytomous cores on an independent
    platform/version, complete and freeze the integration review, and run
    candidate-linked mfrmr/TAM/ConQuest pilots before treating any normalized
    comparison as release evidence.
- [ ] Evaluate compared criteria on a common, locked quadrature/QMC basis and
  require delta-criterion/model-order stability over the integration ladder.
  An IC calculated from a deviance whose numerical drift is large relative to
  the model difference is not release evidence.
  - [x] Add a repository-only fixed-retained-vector common-GHQ evaluator with
    source-objective, data, constraint, weight, method, and readiness guards.
  - [x] Run a deterministic six-scenario matrix over
    `q = 7, 15, 31, 61, 91, 121`, covering RSM/PCM, bounded GPCM, a sparse
    linked assignment, Rater-by-Criterion interaction, latent regression, and
    a wide-latent near-tie stress. q=31--121 retained every criterion ordering;
    the maxima were raw drift `0.039737`, pairwise-gap drift `0.009244`, and
    relative gap drift `0.01601` against q=121.
  - [x] Add an independent-refit/common-q=121 layer for all six scenarios. The
    q=31--121 core retained all orderings; q=7 reversed AIC/SABIC in the
    wide-latent cell, while common-q reevaluation restored the reference
    ordering and isolated the principal coarse-grid effect as integration
    approximation.
  - [x] Fail closed below q=31: q<15 is screening-only, q=15--30 is
    review-only, and raw canonical criteria cannot generate deltas, weights,
    preferred-model labels, evidence ratios, or LRT until q>=31.
  - [x] Add the first TAM 1D/2D product-quadrature and deterministic-QMC
    calibration layer. In the true-1D control, product q=15 reversed all three
    common IC signs while q=21--41 agreed; the 512--4096 QMC ladder retained
    signs but showed maximum gap drift 0.188 across the two controls. Exact
    1024-node refits reproduced every deviance and retained parameter.
  - [x] Add a first 1024-node `QMC = FALSE` four-seed audit. Maximum criterion-
    gap seed drift was 3.966 in the true-1D control and 2.866 in the true-2D
    control; true-1D raw deviance-gain sign changed across seeds.
  - [ ] Add weak-link/near-boundary and cross-platform cells, multi-node
    stochastic TAM repeats, and replicated dimensionality controls; then review
    and freeze the ladder and `IC-INTEGRATION-TOL` before confirmation. Treat
    q>=31 for mfrmr and the observed TAM q>=21 behavior as pilot starting
    points, not automatic proof of numerical stability.
- [x] Present raw and delta criteria as complementary evidence, not an
  automatic dimensionality verdict or literal model probability. SABIC is a
  small-sample sensitivity criterion, not a universal tie-breaker; when
  `N_person <= 22`, its Sclove penalty is non-positive and cannot be a blocker.
  BIC/SABIC also remain sensitive to tiny systematic gains at large N and to
  boundary/singular models, so consequence and calibration gates still apply.
- [x] Test package-native exact formulas, constraint-aware `k`,
  Person-versus-row `N`, missing layouts, weight-policy suppression, JML and
  legacy-object suppression, stored-value tampering, integration identity,
  and agreement across fit summaries, `compare_mfrm()`, and reporting bundles.
- [x] Add imported TAM native-IC provenance, formula verification, estimator
  and dimension guards, plus repository external-normalizer metadata tests.
- [ ] Complete end-to-end agreement through ConQuest exports and
  candidate-linked release evidence.

### Dimensionality challenge: explore, confirm, then test consequences

The 0.2.3 dimensionality work is an external challenge to the supported
unidimensional contract, not a native multidimensional `mfrmr` feature. TAM may
fit prespecified multidimensional MML alternatives in release evidence, while
`mfrmr` continues to fit and report one latent dimension. A better-fitting TAM
model cannot silently create a multidimensional `mfrmr` support claim.

| Stage | Required work | Permitted conclusion |
| --- | --- | --- |
| Explore | Use substantive theory, design review, residual PCAR/parallel-analysis patterns, and Q3-style residual correlations to propose item/criterion clusters, local-dependence pairs, rater effects, and candidate Q matrices. | A versioned hypothesis set for confirmation; no dimensionality decision and no subscore claim. |
| Confirm | Freeze Q matrices, axis labels, variance/covariance constraints, response family, data partition, integration policy, and comparison metrics. First establish matched TAM-versus-mfrmr 1D overlap, then compare TAM 1D with each prespecified TAM multidimensional alternative on untouched persons or an external sample. | Evidence for or against the specified 1D model relative to specified alternatives; not proof that every omitted structure is absent. |
| Test consequences | Evaluate whether the confirmed structure changes score precision, prediction, classification, ranking, invariance, or an external decision enough to justify a different reporting policy. | Total-score-only, multidimensionality-as-nuisance/sensitivity, or a future subscore research case; 0.2.3 does not produce native dimension scores. |

- [ ] Split discovery and confirmation by Person, stratified as needed to retain
  rater/criterion coverage and connectivity. If sparse design prevents an
  honest holdout and no external replication exists, label the result
  same-sample sensitivity evidence rather than independent confirmation.
  Cross-fitting may recover precision, but every fold assignment and
  aggregation rule must be frozen before confirmatory results are viewed.
- [ ] Keep residual exploration broad enough to challenge a mistaken Q matrix.
  Inspect PCAR loadings and scree/parallel evidence together with residual-pair
  clusters and content/design labels; a quiet result for one candidate Q does
  not establish global unidimensionality.
- [ ] Treat fixed PCAR eigenvalue and residual-correlation cutoffs as
  exploratory only. Their null behavior depends on sample size, item/facet
  count, category structure, missingness, targeting, and residual definition;
  use a design-specific simulated or bootstrap reference before a statistic can
  enter a blocking row.
- [ ] Preserve the current `q3_statistic()` naming boundary. It uses
  standardized residuals aggregated to Person-by-facet-level cells, and its
  relative-pair flag is not the published raw-residual
  `Q3* = Q3_max - mean(Q3)`. Do not relabel it as Q3*. A formal Q3* gate needs
  an explicit residual/unit-of-analysis definition, multiplicity policy, and
  design-specific parametric bootstrap; otherwise report `Q3-style` only.
- [ ] Use a four-model attribution grid where the design permits it: 1D
  additive facets, 1D plus rater-by-criterion interaction, multidimensional
  additive facets, and multidimensional plus that interaction. Include fully
  crossed, weakly crossed, and deliberately confounded synthetic cells. If
  rater assignment and criterion structure make the interaction inseparable
  from a latent dimension, classify the design as unidentified rather than
  awarding the fit gain to either explanation.
- [ ] Use TAM 1D versus TAM multidimensional fits for formal within-engine model
  evidence. Use mfrmr 1D versus TAM 1D to establish the external baseline. Do
  not apply a direct mfrmr-1D-versus-TAM-multidimensional LRT or cross-engine
  IC ranking until observation likelihoods, constants, parameter counts,
  constraints, Person-based sample sizes, exact IC formulas, and integration
  bases are demonstrably comparable. Retain native engine criteria for audit,
  but make decisions from the normalized common panel.
  - [x] Implement the pilot-only within-TAM binary 1D/2D grid with common
    Person-basis IC arithmetic, per-Person/per-response gain, Q hashes,
    integration identities, parameter drift, and selection suppression.
  - [ ] Replicate the truth cells and freeze integration, failure, and practical
    criteria before this becomes formal model evidence.
- [ ] Do not use the ordinary chi-square LRT p-value as a blocker. One dimension
  can correspond to a zero variance or perfect-correlation boundary of the
  multidimensional model, invalidating the regular chi-square reference. First
  prove the nesting relation; when a boundary remains, use a prespecified
  parametric-bootstrap deviance-difference reference and report boundary,
  singular-fit, and failed-replicate frequencies.
- [ ] Do not turn large-N significance into practical multidimensionality.
  Alongside any calibrated p-value, report deviance/log-likelihood gain per
  Person and per response, AIC, Person-based BIC, and Sclove SABIC where their
  bases are valid, held-out predictive gain where feasible, residual reduction,
  dimension correlations, parameter stability, and numerical uncertainty.
  Freeze a smallest practically relevant gain during M2 pilot work; do not
  invent it after observing the confirmatory data. Agreement among ICs does not
  replace the practical-consequence test.
- [ ] Treat TAM QMC variation precisely. With `QMC = TRUE`, finite-node
  integration is nonstochastic, but its approximate deviance can drift with
  `snodes`; `QMC = FALSE` adds stochastic variation. For the 2D core, compare
  product-quadrature node ladders with locked QMC node ladders, repeat any
  stochastic integration, and require the model ordering, retained parameters,
  and deviance difference to be stable relative to the prespecified numerical
  uncertainty. Record TAM version, Q hash, node sequence/count, QMC setting,
  seed where operative, convergence controls, and starts.
  - [x] Record the first deterministic 512--4096-node QMC ladder and verify at
    1024 nodes that two fresh refits return exactly identical deviances and
    retained parameters for both models in both synthetic controls.
  - [x] Record the first four-seed `QMC = FALSE`, 1024-node audit with operative
    seeds in every integration-evaluation identity; its seed drift remains
    review-only and cannot choose a favored run.
  - [ ] Expand stochastic integration over node counts and required platforms,
    freeze its seed aggregation and failure policy, then freeze the numerical
    uncertainty rule.
- [ ] Separate structural fit from score-reporting value. A statistically
  multidimensional model may represent local dependence, testlets, or nuisance
  rater behavior and still provide no useful individual subscore. Before any
  future subscore claim, compare each direct dimension score with prediction
  from the total score using prespecified mean-squared-error/PRMSE-style value,
  conditional precision and information, replication stability,
  classification/rank changes, and external-criterion increment where one is
  defensible. If the added value is absent, retain a total score and describe
  multidimensionality only as model/sensitivity evidence.
- [ ] Make synthetic decisions release-blocking but keep empirical-case claims
  conditional. A true-1D core must control false multidimensional selections;
  a prespecified true-2D core must show useful detection power, including weak
  and highly correlated dimensions. A real-data improvement is a scoped
  sensitivity result, not ground truth and not permission to expose native
  multidimensional scores.
- [x] Make `import_tam_fit()` fail closed for `tam.jml` and `ndim > 1` rather
  than relabelling or flattening them. Supported 1D imports preserve the TAM
  MML class, dimension count, version, native IC fields/formulas, and a
  conservative stop-before-iteration-ceiling status.
- [x] Extract multidimensional validation evidence through a separate
  dimension-aware repository runner that cannot be imported as a native
  multidimensional mfrmr fit.
- [ ] Calibrate the fuller TAM convergence review, including final-history
  reevaluation differences, singular/boundary cases, warnings, and failed
  replicates, until a native multidimensional object contract is designed for
  0.3 or later.

### External comparison gate

- [ ] Make ConQuest the mandatory 0.2.3 external core for matched
  unidimensional MML binary, RSM, and PCM cases. Add a latent-regression case
  only when both design matrices and coefficient transformations are explicit.
  - [x] Instrument same-platform pilot coverage for binary and four-category
    RSM/PCM cases; keep every row non-comparison-ready until independent
    replication, integration review, tolerance freeze, and candidate-linked
    confirmation are complete.
- [ ] Compare the same observations, missingness, category maps, model,
  constraints, quadrature, starting-value interpretation, convergence target,
  facet orientation, and reported parameter transformation wherever the two
  programs permit matching.
- [ ] Report absolute and signed differences by parameter class, objective or
  deviance differences where comparable, and readiness/provenance metadata.
  Correlation may be descriptive but cannot be the acceptance statistic.
- [ ] Classify every non-passing row as parameterization, identification,
  numerical, reporting, unsupported, or unresolved. An unresolved core row is
  `No-Go`; an unsupported row must remain outside the public claim.
- [ ] Use FACETS as a row-promotion gate: supported JML Rasch-family element,
  estimated-threshold (not threshold-anchor), fit, and reporting rows may be
  promoted only with matched supplied output. FACETS availability is not
  required to retain an already caveated or blocked row, but that row cannot be
  advertised as externally validated.
- [ ] Do not use FACETS JML person measures as an external target for MML EAP
  person scores. Compare model parameters or JML outputs only where estimands,
  constraints, and extreme-score handling match.
- [ ] Keep proprietary binaries and identifier-bearing case files outside the
  package while retaining commands, synthetic/public inputs, normalized
  aggregate outputs, hashes, versions, and run dates needed for audit.
- [ ] Treat bounded-GPCM external rows as extended evidence until a genuinely
  matched external likelihood and identification contract is documented; they
  cannot silently expand the mandatory overlap scope.

### FACETS coverage and release tooling

- [x] Extend `facets_feature_coverage()` with separate axes for surface
  coverage, statistical contract, validation evidence, and operational status,
  while retaining the current `Status` column for compatibility.
- [x] Distinguish familiar visual grammar, matched numerical evidence, and
  operational interchangeability as three different claims.
- [x] Require `--as-cran` provenance, metadata agreement, candidate identity,
  gate-specification identity, and current-versus-future API truth in release-
  readiness output.
- [x] Replace brittle prose-only pass counts with candidate-linked evidence or
  regenerate exact counts at each release.
- [x] Add negative tests ensuring future calibration, threshold-anchor,
  multi-scale, and unrestricted-GPCM terms cannot be reported as current 0.2.3
  support.

### 0.2.3 Definition of Done

0.2.3 may become a release candidate only when:

- [ ] the M1 draft was reviewed and the M2 gate specification was frozen after
  pilot calibration but before confirmatory evidence;
- [ ] every numerical, recovery, sparse-design, dimensionality-challenge,
  information-criterion, ConQuest-core, public-contract, and engineering
  blocker is `ok` for one exact candidate;
- [ ] no failed cell is hidden by aggregation and no unresolved external core
  discrepancy remains;
- [ ] every retained caveat appears in first-screen guidance, help, and the
  capability surface that exposes the affected result;
- [ ] package-controlled CRAN workload remains below ten minutes while the
  complete release-blocking evidence runs outside CRAN and is reproducible;
- [ ] a clean-room reviewer can reproduce the gate decision from the candidate
  manifest without access to private case-level data; and
- [ ] the release notes explicitly state that threshold anchors, frozen
  calibration, multiple scales, scale-specific PCM, native multidimensional
  estimation, and dimension-specific score production remain later work.

## 0.2.4: operational calibration

0.2.4 should make stable calibrations reusable without implying that every
model is suitable for high-stakes scoring. The first implementation target is
one observed score scale; multi-scale indexing remains deferred to 0.2.5.
Public implementation starts only after the 0.2.3 Definition of Done is met;
schema sketches may be prepared earlier, but they are not current API.

- [ ] Define a versioned calibration bundle containing model specification,
  typed parameters, identification constraints, element/group anchors,
  category map, provenance, and software version.
- [ ] Add single-scale threshold/step anchor support, distinguishing partially
  anchored ladders, fully fixed ladders, and starting values, with explicit
  sum-to-zero/origin, degree-of-freedom, and conflict checks.
- [ ] Add documented starting-value import and transformation contracts.
- [ ] Add scoring from a versioned frozen calibration, with explicit handling
  of unknown levels, missing categories, disconnected cases, and out-of-range
  scores; keep it distinct from 0.2.2 fitted-object posterior scoring.
- [ ] Propagate calibration identity into reports, exports, and replay
  manifests.
- [ ] Reserve an unambiguous scale namespace in the calibration schema without
  claiming that a 0.2.4 fit can contain multiple observed `ScaleId` values.
- [ ] Validate round trips, reduction cases, and external overlap before using
  operational-scoring language.

## 0.2.5: multiple observed scales and mixed response structures

This release addresses observed-score complexity while retaining a
one-dimensional latent trait unless a separately validated design says
otherwise. Its entry condition is a stable 0.2.4 calibration-bundle identity,
round-trip scoring, threshold-anchor conflict handling, and reduction-test
contract. Multi-scale work must not be used to repair an unresolved 0.2.3
numerical or 0.2.4 calibration problem.

- [ ] Represent multiple independent rating scales through an explicit
  per-observation `ScaleId`; do not infer scale identity from category values.
- [ ] First establish the reduction case of multiple RSM/binary scales with
  scale-specific category maps and score supports.
- [ ] Then add scale-specific PCM with ragged threshold blocks, so scales and
  `step_facet` levels may have different category counts without padding them
  into the current global rectangular step matrix.
- [ ] Extend the 0.2.4 calibration bundle and threshold-anchor contract so
  every scale-specific parameter is namespaced by `ScaleId` and cannot be
  applied to the wrong scale.
- [ ] Define mixed binary, RSM, and PCM likelihood contributions only after the
  single-scale and homogeneous multi-scale reduction tests pass.
- [ ] Define active facets by observation only after scale assignment and
  likelihood dispatch are explicit and auditable.
- [ ] Extend plotting, information, diagnostics, exports, and calibration
  bundles so scale-specific quantities cannot be silently pooled.
- [ ] Add design audits for partial crossing, structurally inactive facets,
  sparse scale links, and scale-specific identification. Scales without a
  defensible common-person, common-element, or anchor link must fail closed
  rather than be silently reported on one metric.
- [ ] Demonstrate that multiple observed scales retain one latent dimension;
  treat multidimensionality as a separate 0.3-or-later model claim.

## 0.3 and later: research extensions

These are separate research programs, not promises attached to 0.2.x.

- restricted multidimensional `RSM`/`PCM`, followed only later by any
  multidimensional GPCM route;
- unrestricted unidimensional GPCM with general slope design, covariance, and
  downstream-helper closure;
- freely estimated latent population variance and configurable-prior EAP
  sensitivity after their identification and recovery contracts are defined;
- moderation-specific DFF/DIF methods with calibrated null/non-null behavior,
  rather than extending the current direct screening labels by name alone;
- posterior-predictive diagnostics and optional Bayesian/heavy backends;
- profile or multivariate G-theory with covariance-based composite
  reliability;
- alternative polytomous, rater-process, mixture, unfolding, and general
  design-matrix families; and
- larger-scale performance work after the statistical and reporting contracts
  are fixed.

Each extension needs its own estimand, identification argument, negative
tests, recovery evidence, external overlap where possible, and public support
boundary. Experimental implementation alone is not a release claim.

## Permanent development principles

1. The public support boundary is defined by exported code, help pages, tests,
   and release evidence together—not by an aspirational planning note.
2. A helper being callable does not make its output inferentially or
   operationally ready.
3. External comparisons are evidence within a matched overlap region, never a
   blanket equivalence claim.
4. Screening results remain screening results; they do not become fairness,
   validity, or high-stakes decisions through formatting.
5. Unsupported designs fail closed or carry an unavoidable caveat.
6. CRAN-time tests stay lightweight; slower evidence is reproducible and
   retained outside the installed package.
7. Release artifacts are tied to an exact source commit and tarball digest.
8. Changes to this sequence belong in this file first; subordinate validation
   notes may add technical detail but may not redefine the release order.
9. Pilot evidence may define a criterion; confirmatory evidence may only apply
   the frozen criterion. Changing it invalidates the confirmatory decision.
10. The published CRAN 0.2.2 baseline and next-version development remain
    isolated; any later correction starts from the published tag.
11. Residual exploration may generate a model, but cannot independently confirm
    that model on the same observations without an explicit sensitivity label.
12. Better multidimensional fit and useful dimension-specific scores are
    separate claims with separate evidence requirements.
13. An information-criterion label never hides its likelihood basis, free-
    parameter count, independent sampling unit, exact formula, or integration
    evaluation.
