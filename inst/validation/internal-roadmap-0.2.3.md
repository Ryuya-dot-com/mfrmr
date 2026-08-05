# mfrmr internal development and validation roadmap

Status: repository-only maintainer plan, refined 2026-08-05.

The repository-root `ROADMAP.md` is the single source of truth for public
release direction. This file owns internal sequencing, candidate gates, local
tool identities, and validation operations. `NEWS.md` records completed
user-visible changes. Other files under `inst/validation/` provide
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
- The `development/0.2.3` branch now carries package identity 0.2.3. This is
  an unreleased development target, not a release candidate: candidate freeze,
  confirmation, and submission remain prohibited until the M3-M5 evidence and
  identity gates pass.
- `DESCRIPTION` records lifecycle `development` and public baseline 0.2.2;
  `DESCRIPTION` and `CITATION.cff` intentionally carry no release date until
  an explicit candidate freeze.
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

### Release horizon

| Version | Position | Primary exit decision |
| --- | --- | --- |
| 0.2.2 | Published stabilization and contract baseline | Frozen historical evidence; maintenance only unless CRAN requests a correction. |
| 0.2.3 | Numerical trust and external validation | State exactly where current RSM, PCM, bounded GPCM, JML, and MML are validated, caveated, exploratory, or unsupported. |
| 0.2.4 | Fixed calibration and operational scoring | A typed, versioned calibration can be saved, reloaded, and applied to new data with unknown or incompatible inputs failing closed. |
| 0.2.5 | Multiple observed scales and mixed response structures | Explicit `ScaleId` routing reduces exactly to the one-scale contract and cannot pool or link incompatible scales silently. |
| 0.3.0 | API, evidence, and ecosystem consolidation | Stable object schemas, compatibility/deprecation policy, reproducible case studies, performance envelope, and contributor review are in place. |
| 1.0.0 | Validated core stability contract | The declared core—not FACETS feature parity—has replicated recovery/external evidence, stable schemas, failure-mode coverage, and public support boundaries. |

Research tracks such as native multidimensional MFRM, unrestricted GPCM,
Bayesian backends, and multivariate G-theory do not inherit a release number
merely because code exists. Each enters only after its own estimand,
identification, recovery, reduction, and public-contract gates are defined.

## 0.2.2: published stabilization and contract baseline

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

The central claim is deliberately narrower than feature development:

> mfrmr 0.2.3 adds no new model family. It systematically establishes
> parameter recovery, supported standard-error coverage, matched external
> comparisons, and the applicable design envelope for the RSM, PCM, bounded
> GPCM, JML, and MML surfaces published in 0.2.2.

Terminal-gradient checks, limited ConQuest overlap, FACETS positioning, and
the fit/diagnose/report workflow already existed in 0.2.2. Their 0.2.3 task is
not reimplementation; it is promotion from fixed or narrow demonstrations to
prespecified, replicated, candidate-linked evidence. Any surface that cannot
earn that promotion remains caveated, exploratory, blocked, or deferred.

### Release contract

The release owns these outcomes:

- a candidate-linked MML stationarity and recovery gate shared by direct,
  hybrid, and EM routes;
- parameter-recovery and supported-interval coverage evidence separated by
  estimator, model, parameter class, and design cell rather than pooled into a
  single success rate;
- a prespecified stress envelope for connected, weakly linked, sparse, and
  deliberately disconnected designs, including minimum-rater panels and
  severely imbalanced category support;
- separate operating-characteristic gates for fixed interaction recovery,
  additive-model bias screening, and exploratory residual-PCA signals;
- a candidate-linked dimensionality challenge that separates exploratory
  residual evidence, confirmatory external model comparison, and the practical
  value of any proposed dimension-specific score;
- an explicit MML information-criterion contract that records the likelihood
  basis, free-parameter count, independent sampling unit, exact formula, and
  integration evaluation used for every reported criterion;
- a same-candidate ConQuest MML overlap gate for the supported overlap region;
- a mandatory, candidate-linked FACETS JML RSM/PCM stress core covering
  connected recovery, element/group anchors, sparse topology, and edge cases,
  with additional fit/DFF rows promoted only when their definitions match;
- a machine-readable support envelope that ties maturity and operational
  status to exact recovery, external-tool, and candidate evidence identities;
- versioned, machine-readable gate criteria and evidence manifests; and
- release tooling that cannot silently reuse a log, tarball, external result,
  threshold set, or prose pass count from another candidate.

The public estimator vocabulary remains `MML` and `JML`. `JMLE` remains only a
backward-compatible input alias that resolves to `JML`; `MMLE` may describe a
statistical estimator in prose but is not a third `fit_mfrm()` method label.
JML and MML estimate persons differently, so agreement between their person
measures is not a release gate. Comparisons must name a common estimand and
transformation before a tolerance is applied.

### Estimator ecosystem and maturity boundary

One fitting interface is a workflow property, not evidence that its estimators
have equal inferential maturity. The 0.2.3 gate therefore treats each estimator
and correction convention as a separate method, even when the model formula
and output labels look similar.

| Surface | Audited reference state | 0.2.3 validation role | Boundary that must remain visible |
| --- | --- | --- | --- |
| mfrmr MML | Native RSM, PCM, and bounded-GPCM route with direct/hybrid/EM engine paths. | Primary recovery, stationarity, supported-interval, and ConQuest/TAM MML lane. | Population distribution and integration are part of the estimand; evidence cannot be borrowed from JML. |
| mfrmr JML | Native RSM/PCM/bounded-GPCM route without a classical finite-item bias correction; structural-parameter SEs are observation-information approximations rather than a full profile-likelihood Hessian. | FACETS/TAM/immer comparison, education, and exploratory analysis; any stronger claim is earned separately by recovery and coverage. | Incidental-parameter bias, extreme scores, approximate uncertainty, and person-specific information remain explicit. |
| TAM | CRAN 4.3-25 supplies MML and `tam.jml()`; the latter documents extreme-score adjustment, a default finite-item bias reduction, and fixed item/person parameters. | Independent MML overlap and JML sensitivity/reference lanes. | `tam.mml.mfr()` design-matrix handoff to `tam.jml()` does not make TAM's JML correction automatically valid for mfrmr's arbitrary-facet exposure patterns. |
| immer | CRAN 1.5-13 supplies design-matrix CML/CCML, unadjusted/adjusted/bias-corrected JML modes, and a hierarchical rater model; development 1.6-1 is retained only as a separate sensitivity identity. | Rasch-family conditional-estimator references, JML convention grid, and a local-dependence/model-misspecification challenge. | CML/CCML do not estimate the same person quantities as JML/MML, and HRM is a different latent-data model fitted by MCMC rather than another additive-MFRM estimator switch. |

The primary external identities are the CRAN releases current at the source
audit: TAM 4.3-25 and immer 1.5-13. TAM 4.4-2 and immer 1.6-1 development
snapshots may be run as separately labelled sensitivity strata. Development
and CRAN results are never pooled, and a later installed version requires a new
identity record, source audit, and comparison stratum.

The executable comparison matrix, eligibility rules, stress axes, output
schema, and architecture decision gates are maintained in
`tam-immer-estimator-stress-plan-0.2.3.md`. That file is subordinate to this
roadmap and the release-gate specification; it contains no completed evidence.

The JML convention grid is deliberately adversarial. On the same generated
observations and common parameter coordinates it includes mfrmr's uncorrected
JML, FACETS' selected convention, TAM's unadjusted and documented
adjusted/bias-reduced modes, and immer's unadjusted, extreme-score-adjusted,
and bias-corrected modes. Extreme and nonextreme persons are summarized
separately. Truth recovery, supported-interval coverage, failure behavior, and
between-program differences are four different outputs; agreement cannot
substitute for recovery.

A classical multiplicative JML correction is not copied merely to reproduce an
external value. Under arbitrary facets, sparse assignments, missingness,
unequal rater workloads, and design-matrix pseudoitems, the effective item or
occasion count in a factor such as `(I - 1) / I` is not automatically unique.
Any native correction proposal must first define that exposure quantity,
reduce to the established balanced case, preserve identification and anchors,
and improve prespecified bias/RMSE without unacceptable coverage, boundary, or
failure-rate cost. Otherwise JML remains uncorrected and explicitly caveated.

Native CML/CCML is not promised by this comparison. The first decision point is
an adapter and matched external study limited to identifiable Rasch-family
structural parameters; person measures and bounded-GPCM claims are excluded.
Only after accuracy, missingness/category limits, computation, maintenance, and
user demand are quantified may an architecture decision record choose native
implementation, an adapter, or continued external-reference status.

HRM remains an alternative data-generating and local-dependence model. It must
not appear as `method = "HRM"`. Any future implementation needs a distinct model
family/API or companion package, a latent true-rating estimand, identification
and MCMC diagnostics, posterior checks, and its own recovery gate. Likewise,
the label `GMFRM` is prohibited unless a proposal disambiguates generalized
response discrimination, rater-consistency parameters, and local-dependence
structure; these are not interchangeable generalizations.

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
- native CML/CCML, a new JML bias-correction option, and hierarchical rater or
  other latent local-dependence model families; and
- a package/runtime dependency on ConQuest, FACETS, TAM, or immer. Their locally
  executed synthetic validation is release evidence, not code required to
  install or use mfrmr.

### Work sequence and evidence invalidation

| Milestone | Work | Required exit artifact |
| --- | --- | --- |
| M0: freeze the published 0.2.2 baseline | Keep the accepted asset and tag immutable. Conduct 0.2.3 gate-specification, pilot, and package work only under the explicit 0.2.3 identity; any later 0.2.2 correction branches from the published tag. | CRAN acceptance is recorded, and correction and development paths remain separate before M3. |
| M1: draft the gate specification | Define scenario IDs, estimands, parameter transformations, readiness states, evidence roles, blocking rows, information-criterion formulas/sample-size bases, dimensionality discovery/confirmation partitions, candidate Q matrices, consequence criteria, and explicit pilot-required numeric criteria. | Versioned draft `inst/validation/release-gate-spec-0.2.3.md` and `inst/validation/release-evidence-checklist-0.2.3.csv` committed with review; confirmation remains unauthorized. |
| M2: instrument, pilot, and freeze | Add independent gradient/objective checks, scenario generators, corrected MML information-criterion instrumentation, external normalization, a TAM dimensionality runner, integration-stability checks, fail-closed import guards, and candidate manifests. Pin the local FACETS 4.5.0 binary/report/parser identity without making upstream-version difference a stop rule, build the paired JML RSM/PCM stress runner, and pilot its core/anchor/sparse/edge families. Add TAM/immer runners that preserve every JML adjustment mode, isolate CML/CCML structural estimands, and treat HRM as an alternative-model stress lane. Use pilot-only data to calibrate every unresolved criterion, then freeze the specification before confirmation. | Reproducible internal, ConQuest/TAM, FACETS, and immer pilot reports with criterion changes recorded plus a reviewed `0.2.3-frozen.*` specification/checklist containing no unresolved blocker criterion and no release decision. |
| M3: freeze one candidate | Freeze source commit, dependency lock information, external-tool executable/report identities, parser/generator versions, input/partition/Q-matrix/topology fingerprints, integration controls, seeds, failed-run policy, and tarball digest. | Candidate manifest that uniquely identifies every internal and external input and stratifies rather than silently pools external-program versions. |
| M4: run confirmation | Run the locked recovery/stress matrix, FACETS JML core, ConQuest/TAM MML comparisons, TAM/immer JML convention grid, eligible immer CML/CCML rows, dimensionality challenge, and matched external rows without changing criteria or reusing discovery/pilot data as independent confirmation. | Candidate-linked internal and external evidence with every blocker classified and every expected scenario/replicate accounted for. |
| M5: release handoff | Run full regression, cross-platform CI, manuals, URL checks, CRAN-time examples, Win-builder, package-content audit, and public-claim audit. | All blocker rows `ok`, all caveats visible, and an exact checked tarball. |

The repository now contains `0.2.3-draft.51` planning and pilot artifacts at
`inst/validation/release-gate-spec-0.2.3.md` and
`inst/validation/release-evidence-checklist-0.2.3.csv`, with the TAM/immer
execution contract in `inst/validation/tam-immer-estimator-stress-plan-0.2.3.md`.
They deliberately record unresolved pilot-calibrated criteria and therefore do
not authorize confirmation or constitute release evidence. The source-grounded M1 review is
recorded in `inst/validation/release-gate-m1-review-0.2.3.md`; the exact IC
arithmetic/policy fixtures begin M2 instrumentation. M1 is content-complete
but remains an open repository milestone until these artifacts receive the
normal commit/review handoff. M2 completes only after package instrumentation
and pilot work have resolved every blocking criterion and the specification
is promoted to a reviewed `0.2.3-frozen.*` identity.

Draft.19 retains the FACETS lane introduced in draft.17 and the first
paired one-seed RSM/PCM stress pilot: 22 scenarios per model, 44 successful
FACETS 4.5.0 reports, truth-first normalization, and mfrmr readiness capture.
The deliberately disconnected RSM/PCM cells reached `hold_disconnected`, but
the single-bridge cells remained `pass_linked` despite degraded parameter
agreement. This is a diagnosed gap: binary connectivity cannot serve as a
weak-identification gate. M2 must add bridge-strength, articulation,
component-balance, and local-information diagnostics before any freeze.

Draft.19 also adds nine extension scenarios per model and a separate
interaction/bias/PCAR runner. The extension showed that the current audit can
label a two-rater one-rater-per-Person design `pass_linked` even when no
Persons are shared, and can label a PCM dataset `pass` when one category
contains 94.2% of responses and another is unused. The severe category
threshold vector was centered to sum zero and both batches were rerun, so this
finding is not attributed to an avoidable location-constraint mismatch. It
also showed that a weak
planted interaction can be missed by the residual bias screen, that severe
category imbalance can create large spurious fitted interactions, and that
weak-overlap residual PCA eigenvalues can diverge despite nearly identical
row residuals. These are pilot diagnoses, not support claims. M2 must add a
Person-sharing graph and minimum-rater-panel state, model-specific category-
information states, multi-seed interaction/bias operating characteristics,
and null/non-null PCAR calibration before the gate is frozen. FACETS Table 14
bias evidence remains separate until a definition-matched `?B` control and
parser exist.

Draft.20 adds an adversarial divergence audit before any FACETS difference is
allowed to calibrate a tolerance. It reclassifies three draft.19 observations:

- the zero-common-Person two-rater main-effect design has one exact free
  null direction after the declared centering constraints; common Criteria do
  not identify a rater contrast confounded with nested Person-group location;
- the severe PCM row is not a common parameter comparison because FACETS
  dropped unsupported categories separately by Criterion while mfrmr retained
  the declared four-category, three-step rectangular structure; the important
  current defect is false readiness and a normalizer that did not reject the
  dimension mismatch, not a demonstrated likelihood-kernel error; and
- the largest weak-overlap Person differences are FACETS finite adjusted
  extreme displays versus optimizer-dependent finite proxies to theoretically
  unbounded mfrmr JML measures. Nonextreme Person MAE was far smaller and must
  be reported separately.

The repository audit and full interpretation are in
`facets-mfrmr-divergence-audit-0.2.3.R` and
`facets-mfrmr-divergence-audit-record-0.2.3.md`. M2 now requires a constrained
estimability check, a category-map/retained-step comparison contract, typed
extreme-score output, and definition-specific interaction/bias/PCAR contracts
before the next paired pilot. These are prerequisites to tolerance
calibration, not completed release gates.

### Draft.37 near-term corrective program

Draft.21 converted the draft.20 diagnosis into an implementation sequence.
Draft.22 completes the structural WP0 contract and makes that contract the
fixed input to WP1--WP5. Draft.23 begins WP1 with the estimator-specific sparse
linear-block preflight described below. Draft.24 adds the estimator-ecosystem
boundary and makes correction mode part of external comparison identity.
Draft.25 adds the first bounded post-fit information instrument for nonlinear
coordinates without promoting that instrument to a weak-information rule.
Draft.26 makes the nonlinear free-to-model coordinate transformations explicit
and numerically checked while keeping them separate from response-likelihood
identification. Draft.27 combines the additive and log-slope coordinates in
the retained JML GPCM conditional response kernel, while refusing to reuse
that conditional object as an MML person-integrated identification result.
Draft.28 adds a separate MML observed-Person-pattern score decomposition, while
refusing to reinterpret observed-pattern rank as the structural map over all
possible response patterns.
Draft.29 adds the next bounded MML layer: exhaustive finite response-pattern
enumeration and score-outer-product expected information on each retained
Person observation design, while retaining the result as local geometry rather
than a global structural-identification decision.
Draft.30 removes exact duplicate Person-design computation from that bounded
layer by canonicalizing the observation layout and reusing the all-pattern
result only when facet, step, slope, interaction, and applicable latent-
regression design rows are identical.
Draft.31 begins WP2 by separating declared category semantics from
data-supported free-step estimation. It adds a model-scoped preflight, typed
category blocker, parameter-scoped step statuses, and the first exact and weak
support fixtures without adding threshold anchors or a multi-scale API.
Draft.32 begins WP3 with the Person sufficient-score boundary slice. It
separates the unbounded JML primary value from the finite optimizer trace,
distinguishes direct or implicit fixed constraints and constraint-coupled
review cases, preserves finite MML/EAP estimates, suppresses ordinary SE/CI
for typed boundaries, and gives FACETS-style endpoint placement an explicit
display-only meaning. Generalized non-Person and interaction separation, a
named finite adjustment formula, and complete WP4 propagation remain pending.
Draft.33 adds the next WP3 instrument: a bounded linear-program certificate
over the exact retained adjacent-category contrast design. It holds Person
coordinates fixed and reuses the optimizer's facet signs, anchor/group
Jacobians, two-way interaction basis, and step constraints to test each
expanded non-Person facet, interaction, and step target in both directions.
The certificate is stored internally and is not yet promoted over the finite
optimizer iterate in public tables; that promotion requires WP4 propagation.
GPCM log-slope directions, joint Person-structural recession directions,
target-size execution evidence, and general independent solver parity remain
pending. Draft.34 replaces the certificate's dense constraint allocation with
the solver's sparse triplet interface, retains a small dense-reference route,
and adds an independent finite-grid oracle for prespecified low-dimensional
microcases without claiming general solver independence or FACETS-scale parity.
Draft.35 adds the companion joint Person-structural additive cone. It targets
the constraint-coupled extreme Persons left unresolved by draft.32 and all
structural expanded parameters while allowing every retained free Person and
structural coordinate to move together. A prespecified group-constrained
two-Person/two-Item fixture proves the necessary gap: neither coordinate block
contains a recession direction alone, but their joint cone does. Public-table
propagation remains deferred to WP4.
Draft.36 adds a separate nonlinear GPCM slice without pretending that the
linear cone has become nonlinear. With retained Person, facet, interaction,
and step coordinates fixed, it enumerates every ordered positive/negative
pair allowed by the sum-zero expanded log-slope constraint. A pair is
certified only when every positive-group observed category maximizes its
unscaled cumulative adjacent utility, every negative-group observed category
minimizes it, at least one contributing row has a strict utility span, and the
independently reconstructed retained likelihood agrees with the optimizer
objective. The audit records the limiting likelihood and expanded/free
direction loadings. A checkerboard fixture with fixed Persons exposes one
slope tending to infinity and the other to zero despite finite optimizer
output. Its unanchored counterpart is a required adversarial negative: it has
no strict slope-only ray at the retained symmetric point, yet has an improving
path when Person coordinates move jointly. Consequently `scope_complete` is
separate from `structural_identification_complete`, and a none-certified
result can never become a finite-GPCM claim.
Draft.37 begins WP4 with one runtime fit-readiness builder. It stores the
Input, Estimability, Category, Boundary, and Numerical component rows and
derives `FitReadiness`, the conservative compatibility `InferenceReady`
scalar, all reason codes, and audit provenance once. Native fit summaries,
`summary(fit)`, results bundles, convergence consumers, and plot-readiness
screening now consume the stored fit record. MML is not downgraded merely by
an inapplicable JML audit. Applicable incomplete audits and genuinely
unpropagated structural or slope targets fail closed, while a joint cone made
only of already typed free extreme-Person directions does not create a second
false candidate. The explicit legacy adapter returns `legacy_unknown` and
never promotes an old Boolean. Convergence, summary, results, and fit-plot
entry points all pass saved pre-contract objects through that adapter; a
synthetic old object with successful optimizer fields remains review-only.
The contract identifier is user-safe and does not expose internal work-package
labels.

Draft.38 adds the first non-Person parameter slice and makes the GPCM
asymmetry explicit. The readiness contract moves to v2 because a slope can
have certified low and high paths simultaneously (`unbounded_both`) and an
applicable estimator-specific audit can remain `not_evaluated`; neither state
was representable in v1. Certified fixed-additive JML slope paths receive
typed primary boundaries. A scoped negative retains only a finite numerical
trace because Person, facet, step, or slope coordinates may still move jointly.
MML receives no conclusion from the conditional JML certificate and remains
review-only until a marginal boundary argument is implemented. Local Hessian
SE/CI values are retained under `Optimizer*` names but ordinary inferential
fields are withheld. The one-level unit-slope reduction is fixed rather than
estimated. This remains a partial WP4 implementation:
full facet/interaction/step parameter records, remaining reports/exports/replay consumers,
serialized 0.2.2 migration evidence, and WP5 metric eligibility remain open.

Draft.39 closes a misleading summary path and decomposes the GPCM comparison
problem before more external runs are attempted. `summary.mfrm_fit()` no longer
places a finite optimizer slope into the primary minimum, maximum, or geometric
mean when parameter readiness is absent. Primary summaries remain missing;
the numerical stopping values are labelled `Optimizer*`, accompanied by the
parameter-status mixture and counts eligible for SE and external comparison.
The public scope guide now also states that FACETS' reported element
discrimination is a post-fit Rasch diagnostic, TAM's free GPCM slope route is
not its many-facet route, and immer has no matched free-GPCM MFRM estimator.
Those facts change the validation design: FACETS and immer cannot be treated as
free-slope numeric gold standards, and a TAM row is eligible only after an
exact re-expression and identification audit.

Draft.40 adds the first bounded joint nonlinear GPCM path family. For each
ordered positive/negative slope pair, the expanded log-slope rates are fixed
at `+1` and `-1`, while all constrained additive coordinates may move along a
sparse linear-program direction. A certificate requires a strictly favorable
observed-category direction in the high-slope group, weak support in every
unchanged-slope group, a strictly favorable aggregate leading term as the
low slope tends to zero, exact reconstruction of the retained likelihood, and
an analytic boundary likelihood no worse than the retained fit. The
unanchored two-Person checkerboard now supplies a positive case missed by the
fixed-additive slope check; a repeated balanced-outcome design is the negative
control. Direct likelihood paths, row reversal, workload ceilings, solver
failure, and MML non-reuse are tested. This is deliberately recorded as a
competitive boundary candidate, not a global GPCM result: the primary value
and ordinary uncertainty remain unavailable, a negative result is scoped to
this path family, and more general rate vectors, curved paths, and the marginal
MML problem remain open.

Draft.41 makes the prespecified GPCM stress envelope executable without
pretending that a pilot manifest is confirmation. The repository-only
`gpcm-stress-covering-grid-0.2.3.R` runner constructs a deterministic mixed-
level pairwise covering array over 12 axes. The pilot manifest contains 70
cells, including 12 mandatory adversarial corners, and covers all 1,330
required two-axis level combinations. Separate `PCM_JML` and `PCM_MML` cells
prevent the lower-model reference from being hidden inside a free-slope GPCM
label. The smoke, pilot, and confirmation seed ranges are disjoint; only the
confirmation profile is labelled as confirmation, and confirmation remains
unauthorized. The current public simulator cannot generate a genuine
one-slope-level case because it requires at least two criterion levels while
GPCM requires the slope and step facet to coincide. Those cells remain an
explicit non-executable gap rather than being silently replaced by equal true
slopes across two estimated slope levels.

The runner applies connected sparse, one-bridge, zero-shared-Person, routed,
and disconnected assignments; MCAR, Person-, rater-, and outcome-dependent
deletion; rare, dominant, floor, ceiling, internal-zero, and boundary-zero
category support; repeated cells, explicit Occasion, unequal and zero weights;
Person-by-rater and slope-related interactions; and local-dependence, bias,
and drift signals. Every retained dataset receives a digest and support record,
including category counts, common-Person counts, duplicate counts before and
after Occasion, and positive-weight rows. Fit results keep primary slope
availability, optimizer-only log-slope RMSE, readiness, boundary state,
false-ready status, and optional exploratory residual PCA separate. All
external numeric comparison flags remain false, all numeric thresholds remain
`pilot_required_not_frozen`, and every output is `calibration_only` until the
matched estimator/normalizer and candidate contracts are complete.
The hashed one-seed smoke outcome is retained in
`gpcm-stress-covering-grid-smoke-record-0.2.3.md`; it records six executed
cells, one known generator gap, zero runner failures, zero false-ready rows,
and zero external numeric-eligible rows without promoting those counts to
recovery, coverage, diagnostic-sensitivity, or release evidence.

Draft.42 adds the isolated-attribution layer required by the draft.41 smoke
diagnosis. `gpcm-isolated-attribution-pilot-0.2.3.R` fixes one reference data-
generating cell and changes exactly one of 11 axes per challenge. Every
retained data cell is regenerated under the same seed for four explicitly
different analysis routes: GPCM-JML, GPCM-MML, PCM-JML, and PCM-MML. A route
set is usable only when all four retained-data hashes agree. Person estimates
retain joint-fixed versus marginal-EAP labels; PCM is an exact truth-recovery
route only for the unit-slope reduction; step, slope-level, rater, and Person
dimension changes carry parameter-class coordinate exclusions. Finite GPCM
optimizer slope error remains a diagnostic trace and cannot enter primary
recovery while slope comparison eligibility is absent.

The structural pilot manifest has 40 arms and five common-seed replicates,
giving 800 route rows. It includes an explicit one-slope-level generator gap
and reserves a disjoint confirmation seed range. Full execution is resource-
significant and requires an explicit authorization after dry-run inspection;
confirmation cannot be authorized through this runner. The hashed draft.42
smoke runs 24 rows spanning the reference, two raters, internal category zero,
zero shared Persons, Person-by-rater interaction, and local dependence. It
records 22 fitted objects, two expected JML fail-closed results, zero retained-
data identity violations, zero false-ready rows, zero primary-slope recovery-
eligible rows, and zero external-numeric-eligible rows. Ready PCM rows under
planted interaction/local dependence demonstrate that numerical readiness is
not model adequacy. Residual PCA differences remain descriptive until a
replicated null/non-null calibration freezes no earlier than WP7.

Draft.43 adds a guarded replicated-feasibility layer and, more importantly,
records an internal-invariance failure discovered before external comparison.
`gpcm-attribution-replicated-pilot-0.2.3.R` prespecifies 10-arm feasibility,
30-arm core, and 40-arm expanded tiers, retains the four-route/data-cell
contract, reports Wilson intervals and Monte Carlo standard errors, and adds a
complete route/hash ledger. Core and expanded execution remain explicitly
guarded; the runner cannot authorize confirmation or freeze a threshold.

The first 80-route feasibility analysis exposed implausible MML-only Person
recovery and residual-PCA values after category- or outcome-dependent row
filtering. The cause was not a GPCM kernel or marginal-likelihood difference:
Person-pattern posterior rows retained first-observed order, but the fitted
Person table attached internal Person-level order. This paired EAP and
posterior SD values with the wrong Person labels. Commit `655f6bf` aligns the
posterior summaries by their returned Person indices and adds a row-reversal
regression. On the exact same manifest and retained-data hashes, only eight
MML Person/EAP-derived diagnostic rows changed; every structural recovery,
objective, support, readiness, boundary, and reason field remained unchanged.
The corrected internal-zero/outcome-deletion Person correlations returned to
about 0.93--0.95 and the spurious PC1 values near 13--16 returned to about
2.1--2.6. Pre-fix MML Person and EAP-derived diagnostic rows are invalidated.

The same audit also showed that optional validation capability is evidence
identity. Without `lpSolve`, PCM-JML additive recession auditing correctly
became `not_evaluated` and readiness fell to review; this was a fail-closed
capability omission, not a statistical failure. The authoritative v4 rerun
used `lpSolve` 5.6.23 and reproduced all pre-fix readiness strings while
retaining only the intended EAP corrections. It completed 80/80 routes, 20/20
paired cells, zero identity violations, zero fit failures, and zero false-
ready rows. Two replicates cannot calibrate a rate or diagnostic rule: even
0/2 has a Wilson 95% upper bound near 0.658. The run remains feasibility-only.
Its 1,072-second wall time versus 405.4 seconds of recorded fit time also makes
atomic checkpoint/resume, capability hashing, and staged PCA prerequisites to
the 600-row core tier, not optional conveniences. Full identity, hashes,
invalidation rules, and next gates are in
`gpcm-attribution-replicated-feasibility-record-0.2.3.md`.

Draft.44 removes the all-or-nothing writer as a prerequisite to the guarded
core tier without changing its statistical authorization. The replicated
runner now checkpoints a complete four-route `DataCellId` rather than an
individual route. This is the smallest reusable unit on which common retained-
data identity is auditable. A same-directory temporary RDS must round-trip and
match its payload hash before an atomic rename publishes the checkpoint;
existing targets are never overwritten.

Checkpoint-v1 identity binds the selected and declared manifests, tier,
replicates, optimizer/quadrature/PCA controls, the content of the actually
loaded mfrmr runtime, the three validation runners, R/platform/RNG, numerical
runtime reporting, and the versions, runtime content, or absence of `digest`, `Matrix`,
`lpSolve`, and `psych`. Absolute paths are provenance fields but not hash
inputs. Resume is explicit and rejects schema, execution, cell-manifest,
payload, ScenarioId, route-set, DataCellId, or declared-manifest disagreement.
Unexpected RDS files fail closed; orphan unpublished partial files are ignored.

Aggregate outputs receive an atomic completion marker only after every listed
CSV/RDS and default checkpoint hash is known. Synthetic interruption,
configuration mismatch, orphan-partial, artifact modification, and clean-run
equivalence tests pass. A real reference cell also agrees with the old
four-route execution on every result field except elapsed runtime and is
identical after checkpoint reload. The historical draft.43 v4 artifacts
predate checkpoint-v1 and cannot be resumed or relabelled. Full identity,
hashes, and scope are recorded in
`gpcm-attribution-checkpoint-resume-record-0.2.3.md`.

Draft.45 closes the small-design cross-model MML metamorphic slice without
freezing a numerical tolerance. The repository-only runner prespecifies ten
semantic-equivalence transformations across RSM, PCM, and bounded GPCM:
row reversal/permutation, unused and reordered factor levels, nonlexical
Person/facet labels, missing outcomes versus explicit filtering, zero weights
versus filtering, appended zero-weight levels, positive non-unit weights, and
a combined filter/label/factor transformation. It compares Person posterior
summaries, facets, steps, GPCM slopes, retained-observation expectations and
residual quantities, objective values, semantic keys, and result states.

The first execution deliberately exposed an orchestration defect: runner
controls `maxit = 100`, `reltol = 1e-7` permitted optimizer code zero while
both relabelled fits remained at `NumericalState = review`, producing five
screen failures. The response was not to widen tolerances. The authoritative
v3 uses the public production controls (`maxit = 400`, `reltol = 1e-9`), which
activate bounded gradient polishing, and requires both fits to be numerically
ready. All 30/30 comparisons then passed; maximum objective, parameter, and
retained-observation differences were `3.112007e-09`, `1.862395e-05`, and
`6.113984e-06`. Missing/zero-weight encodings retained their intentionally
different input provenance while preserving every downstream result. The
runner also rejects an existing output directory so a prior bundle cannot be
overwritten; intermediate v2 had identical metric maxima before this storage
guard was added. The thresholds remain `pilot_required_not_frozen`; this is a
software-property pilot on one design, not recovery, coverage, or external
agreement. Full
identity and hashes are recorded in
`mml-metamorphic-grid-record-0.2.3.md`.

Draft.47 begins target-scale execution without relabelling it as a statistical
pilot. A guarded runner executes all six previously declared executable
`target_sparse` cells at 400 generated Persons, one replicate per cell. The
cells span GPCM/PCM, JML/MML, 2--12 Raters, sparse/disconnected assignment,
multiple missingness and category-support challenges, weights, Occasion,
interactions, bias/drift, local dependence, and residual PCA. All six ran in
about 110 seconds on the recorded R 4.5.1 runtime, with zero unexpected runner
failures and zero false-ready rows. Two exactly rank-deficient disconnected
controls failed before optimization; two returned blocked/review states; one
PCM JML fit retained extreme-Person exclusions; and one imbalanced/missing
PCM MML fit was inference-ready. That ready cell is a replicated recovery and
diagnostic target, not proof of adequacy. The mixed-adversity free-slope GPCM
MML cell reached its iteration limit and remained blocked.

The target PCA route also exposed a computability-contract gap: a returned
exploratory object can coexist with `psych` messages that the smoothed-
correlation determinant or objective is undefined. Condition-message capture,
matrix-rank/smoothing state, and a stricter PCA availability vocabulary are
required before diagnostic promotion. The authoritative v3 bundle embeds an
artifact inventory and validates hashes, sizes, safe paths, execution identity,
and confirmation prohibition in a fresh session. Earlier v1/v2 bundles are
retained as superseded evidence-integrity diagnostics. Full results and hashes
are in `target-scale-sparse-stress-pilot-record-0.2.3.md`.

Draft.47 closed the atomic-resume slice of WP7, the current small-design MML
metamorphic slice of WP6, and the first target-scale construction/runtime
feasibility slice. It did not close target-scale support bounds. Its immediate
open items were balanced RSM/PCM/GPCM baselines, weak-bridge gradients, OS
peak-resident-memory measurement, the declared five-replicate pilot,
recovery/coverage, malformed-input and replay properties, active population/
anchor/interaction variants, external normalization, statistical criterion
freeze, and confirmation. Draft.48 addresses only the first three at a one-
replicate calibration level; the wider gates remain open and core confirmation
execution is still unauthorized.

Draft.48 separates scale from adversity in the mixed draft.47 cells. It executes
complete balanced and clean matched-sparse 400-Person RSM/PCM/GPCM baselines,
plus a two-Rater PCM common-Person gradient at 0, 1, 2, 5, 10, 20, and 40.
Each of the 13 data cells is passed unchanged to JML and MML; all 13 pairs have
one data hash. All bridge levels use the same truth seed and one truth hash,
removing the seed confounding discovered in the superseded v1 bridge output.
The authoritative v2 completed all 26 routes with zero unexpected failures,
one expected zero-overlap JML fail-closed route, zero false-ready routes, and
nine inference-ready routes. This remains one-replicate calibration evidence.

The clean baselines materially change the causal diagnosis. At 400 Persons,
complete MML RSM/PCM fits were ready in about one second, whereas every clean
12-Rater/12-Criterion MML baseline completed in 2.5--17 seconds but retained a
terminal-gradient review; GPCM additionally retained an incomplete marginal-
boundary audit. Clean sparse JML RSM, PCM, and GPCM took about 204, 480, and
232 seconds and all reached the fixed iteration limit. Therefore sample size
alone and GPCM nonlinearity alone cannot explain target-scale behavior. JML
free-Person/extreme handling and design dimension, and MML numerical/boundary
contracts, require distinct profiling lanes.

The common-truth bridge traces are nonmonotone. Zero-overlap JML fails exact
estimability, while zero-overlap MML remains review-only under
`population_assumption_linked`. Positive-overlap MML routes are numerically
ready, but one seed cannot define adequate overlap. Positive-overlap JML moves
between `ready_with_exclusions` and iteration-limited blocked states. Binary
connectivity, numerical readiness, or the best observed RMSE must not become a
support threshold. Replicated estimator-specific recovery, local information,
extreme-score, anchor, interaction, imbalance, and failure strata remain
required. Process-lifetime peak working set is now recorded, but isolated-
process memory attribution and capacity limits remain open. Full results and
hashes are in `target-scale-baseline-bridge-pilot-record-0.2.3.md`.

Draft.49 decomposes the JML computation hypothesis before increasing the full
stress grid. Its 14 PCM data cells and 34 routes vary nested Person/row counts,
fixed-row Rater-panel topology, fixed-row Criterion/step panels, fixed-
parameter row exposure, and forced extreme Persons. Each cell has identical
JML/MML input, and selected JML cells add explicit BFGS/L-BFGS-B controls. All
routes executed with zero unexpected failures and zero false-ready states.
This remains one-replicate 60-iteration calibration, not a runtime envelope,
optimizer rule, recovery result, or estimator ranking.

The complete P050/P100 auto routes used BFGS and were ready. At 217 and 417
free parameters, P200/P400 auto switched to L-BFGS-B and blocked, whereas
explicit BFGS on the same data was ready in similar elapsed time. P200 explicit
L-BFGS-B reproduced auto. The current 200-parameter auto threshold is therefore
an actionable hypothesis for the complete nonextreme Person-size path. It is
not a global fix: R12, C12, and forced-extreme BFGS controls remained blocked.
No threshold changes before a replicated 180--260-parameter cross-model grid
and memory audit.

At 2,400 fixed rows, JML time rose from about 6.6 to 19.0 seconds across the
3--12 Rater panel and from about 6.6 to 15.3 seconds across 4--12 Criteria.
The Rater contrast also introduced 0, 3, and 42 zero-common-Person pairs, so it
is a panel/topology contrast rather than a pure parameter-dimension effect. At
fixed JML dimension 249, 1,200 rows were slower and less well conditioned than
2,400, while the 7,200-row cell was slowest but ready. Forced extremes doubled
P200 total fit time and blocked both optimizers. These nonmonotone results rule
out row count, free dimension, optimizer, or connectivity as a single capacity
rule. These findings made internal phase timing the next prerequisite:
preparation, sparse design/rank, boundary/recession audits, optimizer, and
readiness assembly had to be measured separately before a corrective
implementation. Draft.50 supplies that attribution below. Full Draft.49
results and identities are in
`jml-bottleneck-decomposition-pilot-record-0.2.3.md`.

Draft.50 instruments the exact execution phases before changing optimizer or
capacity policy. The timer is internal, opt-in, attached only after readiness,
and decision-nonintervening. A fixed seven-cell/19-route Draft.49 subset passes
the 18-phase contract with zero false-ready rows. All semantic-result hashes,
readiness states, numerical states, and optimizer methods are unchanged across
the coarse v1, refined v2, and workload-complete v3 bundles.

The profile overturns the leading performance interpretation without
invalidating the separate numerical-readiness finding. Across 12 JML routes,
structural and joint recession audits consume 201.94 of 211.25 instrumented
seconds, while optimization consumes 3.70 seconds. Every Person-fixed
structural audit returns `none_certified` only after enumerating 46--126 target
directions. The joint audit already uses a global-cone screen and enumerates
targets only when that screen certifies a ray. The current optimizer dispatch
can still change terminal-gradient readiness at P200/P400, but it is not the
primary elapsed-time bottleneck.

The immediate Draft.51 change-local hypothesis is therefore an exact
structural global-cone prescreen, not an audit bypass. A negative cone screen
must imply that no target-specific recession direction exists under the same
contrast cone and tolerances. Existing sparse/dense, row-order, finite-grid,
anchor, interaction, dependency, size-limit, solver, and MML guards must match;
positive-cone controls must retain target enumeration. The 19 v3 routes must
retain semantic hashes, boundary/readiness states, and fail-closed behavior
while recording solver-work counters and materially reducing no-cone phase
time. Shared design/contrast construction, reusable LP models or warm starts,
and alternative solvers are later hypotheses. The replicated cross-model
optimizer-dispatch grid remains separate and cannot substitute for this
certificate-preserving performance correction. Full results and identities
are in `jml-phase-profile-pilot-record-0.2.3.md`.

Draft.50 verification covers all 127 package-aware `testthat` files and an
exact 491-entry local source tarball. The exact tarball completes install,
static checks, ordinary examples, tests, and vignette rebuilding under
`R CMD check --no-manual`; the sole NOTE is caused by Rd cross-references to
four unavailable suggested packages. This is not a complete `--as-cran`
result: the current environment lacks ten suggested packages, network access,
and `pdflatex`, and the force-suggests-false `--run-donttest` attempt exceeded
the ten-minute tool bound. These gaps remain release-engineering work and are
not converted into a candidate or `Status: OK` claim.

Draft.51 implements the certificate-equivalent structural global-cone
prescreen. The prescreen uses the same nonnegative observed-category contrast
cone and tolerances as target enumeration: if the maximum summed contrast
margin is not positive, no strictly improving row and therefore no
target-specific certificate can exist. A positive cone retains the full legacy
target enumeration. The audit exposes a versioned state and actual cone/target
LP-call counts; dependency, design, mapping, solver, coordinate, nonzero,
constraint, target-direction, and MML guards remain fail closed.

Adversarial tolerance review rejected direct reuse of the ordinary target LP's
`10 * objective_tolerance` early-negative rule: a `5e-7` contrast can satisfy
the target certificate while an unsafe `1e-7` cone objective tolerance reports
negative. The authoritative prescreen therefore records objective tolerance
`1e-10` and certificate tolerance `1e-7`; the counterexample is a regression.
The pre-guard v4 output is superseded by guarded v5 evidence.

The fixed seven-cell/19-route v5 rerun preserves every v3 and v4 semantic hash,
readiness, numerical, boundary, optimizer, structural, and joint state. On the
same 12 JML fitted objects, screened and unscreened structural target-status
hashes match 12/12. All selected structural cones were negative: 908 legacy
target LP calls became 12 cone LP calls and zero target LP calls. Structural
phase time fell from 139.63 to 13.80 seconds and JML outer-fit time from 212.68
to 86.57 seconds; all 12 JML routes were faster. These one-run PCM values
freeze no performance rule. Positive-cone behavior remains protected by
separated-Rater and interaction fixtures, including sparse/dense, row-order,
anchor, retained-row, size-limit, MML, and injected solver-failure controls.
Full results and identities are in
`jml-structural-cone-prescreen-pilot-record-0.2.3.md`.

Draft.52 attributes the remaining joint recession work without changing the
production audit. Phase schema v6 preserves every v5 semantic, readiness,
numerical, boundary, optimizer, structural, and joint state across the fixed
19 routes. Seven negative joint cones consume 13.53 seconds and no target LPs;
five positive cones consume 48.99 seconds and trigger 346 target LP calls, but
none certifies a selected target direction.

A separate fixed-runtime refit of the three distinct positive-cone cells
projects each stored cone through the full target map. All 43 nonzero cone
coordinates and expanded-target projections are exactly ordinary free extreme
Persons already typed `unbounded_low/high`; structural coordinates and all 118
selected target projections are zero. The existing readiness aggregator
correctly treats such a cone as confirmation of a propagated Person boundary,
so this is computation and responsibility duplication rather than a detected
false-readiness path. A diagnostic row-and-coordinate quotient that profiles
those Persons out is negative in all three cells and takes 0.56 seconds versus
30.16 seconds for the three original joint phases. These unequal one-run
workloads freeze no performance rule.

Draft.53 implements the quotient screen only in conjunction with a guarded
selected-target nullspace test. Each proposed ordinary free extreme Person is
verified as a strict one-sided contrast ray confined to that Person's rows and
absent from selected targets. The row-and-coordinate quotient then receives a
guarded strict-cone LP. A negative quotient may skip enumeration only when
common-column-scaled sparse QR gives stable equal base and target-augmented
ranks at `1e-12`, `1e-10`, and `1e-8`. Rank increase, tolerance sensitivity,
mapping/ray failure, solver failure, or size limits retain the old enumeration
or its old target-limit state.

The target-changing flat-direction counterexample forces fallback despite a
negative quotient strict cone. Real RSM safe, row-order, target-limit,
structural-positive, constraint-coupled, interaction, and bounded-GPCM
conditional-additive controls match complete legacy target states; MML and
readiness remain unchanged. The fixed v8 profile preserves all 19 v6 semantic,
readiness, numerical, boundary, optimizer, structural, joint, and target-status
comparisons. Five routes profile 84 Person coordinates across duplicated
optimizer routes; their three-tolerance rank increments are all zero. Joint
target LP calls fall from 346 to zero, joint phase time from 62.52 to 18.82
seconds, JML outer time from 87.10 to 43.53 seconds, and all-route outer time
from 94.67 to 50.91 seconds. These one-run PCM timings freeze no rule. The
completed v7 bundle is superseded because it hashed but did not print the rank
ladder; v8 is authoritative. Full findings and identities are in
`jml-joint-quotient-nullspace-prescreen-pilot-record-0.2.3.md`.

Draft.53 verification also builds a clean exact 491-entry local source tarball
and passes `R CMD check --no-manual` with `Status: OK`. Tarball and check-log
hashes are kept in the package-external
`.check-draft53-standard-no-manual-v3/verification-receipt.txt` to avoid
self-referential mutation of a packaged roadmap. The first 497-entry artifact
is superseded because it incorrectly included six hidden change-local scripts
and received the corresponding hidden-file NOTE. This is neither an
`--as-cran` result nor a candidate gate pass; full-manual, `--run-donttest`,
dependency-present, external, candidate-linked, and confirmation checks remain
open.

Draft.54 attributes the remaining recession work and implements one optional
shared-geometry path. A single full Person-plus-structural adjacent design,
expanded-target system, and observed contrast is projected onto the exact non-
Person columns/rows for the structural audit and reused by the joint audit.
The path is accepted only after version, state, sparse-object, row, column, and
optimizer-index validation; failed or malformed shared construction is
discarded and both audits rerun their legacy construction. MML does not enter
the path, and no shared object is stored in a fit.

Whole-audit identity, exact sparse-column projection, and core-level fallback
tests pass for RSM, criterion-step PCM, direct/group anchors, interaction,
nonuniform/zero weights, missing-score removal, bounded GPCM's supported common
step/slope facet, and malformed/injected-failure controls. The fixed 19-route
component bundle passes all fits, ordinary phase contracts, component
contracts, canonical Draft.53 comparisons, and false-ready checks. Every JML
route constructs the three shared objects once and neither audit reconstructs
them. Against the same-day Draft.53 canonical replay, combined structural and
joint time falls from 33.00 to 21.07 seconds, JML outer time from 44.12 to 31.71
seconds, and all 12 JML routes are faster. These one-run PCM results freeze no
rule. Full findings and identities are in
`jml-shared-recession-geometry-pilot-record-0.2.3.md`.

Draft.54 verification also builds a clean exact 492-entry local source tarball
and passes `R CMD check --no-manual` with `Status: OK`. Artifact and check-log
hashes remain in the package-external
`.check-draft54-standard-no-manual-v4/verification-receipt.txt` to avoid a
self-referential packaged hash. This is neither an `--as-cran` result nor a
candidate gate pass; full-manual, `--run-donttest`, dependency-present,
external, candidate-linked, and confirmation checks remain open.

The comparison also corrected an evidence-identity defect: the former
serialized target-status hash could differ for `identical()` tables whose R
internal representation differed after projection. The versioned canonical-v1
hash now uses type-explicit values and explicit missing encodings. An unchanged
Draft.53 runtime replay matches the original v8 bundle on all 16 selected
semantic/state fields for all 19 routes; its target hashes change only because
the identity representation changed.

Draft.55 replaces repeated triplet-vector growth in the observed-contrast
builder with exact stored-entry counting, score-specific transition templates,
and one preallocated observation-block fill. The former implementation remains
an internal reference path. A 977-expectation change-local test passes exact
`dgCMatrix` identity for 1--10 steps, zero/dense/sparse designs, category
extremes and imbalance, malformed inputs, observation permutation, zero
columns, two-Rater weighted/missing anchored PCM, interaction RSM, and bounded
GPCM. Five guarded cases with seven alternating-order replicates preserve exact
output identity; median constructor time falls 85.7--99.7% and cumulative R
allocation falls 93.3--99.96%. The allocation metric is not peak RSS and no
performance rule is frozen.

The fixed 19-route component bundle passes every fit, phase, component,
canonical-baseline, and false-ready contract. Against Draft.54, contrast time
falls from 10.28 to 0.11 seconds, combined structural/joint time from 21.07 to
10.64 seconds, and JML outer time from 31.71 to 21.34 seconds; all 12 JML routes
are faster. MML is unaffected. LP solver calls now consume 8.01 of 10.60 JML
component seconds. The constructor v1 evidence is superseded because staging
paths leaked into inventory row names; v2 fixed promotion verification and v3
also unifies installed-package identity with the Draft.49--54 convention. Full
findings and identities are in
`jml-contrast-constructor-pilot-record-0.2.3.md`.

Draft.55 verification also builds a clean exact 493-entry local source tarball
and passes `R CMD check --no-manual` with `Status: OK`. Its CRAN-light test path
has 397 passing expectations, three skips, and zero failures or warnings. A
separate 10-shard regression against the same fixed tarball's installed package
and check-expanded tests covers all 126 test files exactly once: 1,726 tests,
11,945 passing expectations, 83 skips, 38 allowlisted warnings, and zero
failures, errors, or unexpected warnings. The aggregate validates a common
runner/tar identity and every source-test hash. A monolithic `NOT_CRAN=true`
attempt reached the 30-minute ceiling while still in tests and is not a pass or
failure; the sharded result is not represented as a second `R CMD check`.
Artifact, standard-check, and sharded-regression hashes remain in the package-
external `.check-draft55-standard-no-manual-v1/verification-receipt.txt`. This
is not an `--as-cran`, full-manual, dependency-present, external, candidate, or
confirmation pass.

Draft.56 attributes LP-base construction, R-side assembly/dispatch, and
`lpSolve::lp()` execution separately without changing production dispatch. The
authoritative v3 bundle preserves all 19 Draft.55 fixed-route semantic,
readiness, boundary, and target-status comparisons with zero false-ready rows;
the seven MML routes produce no LP events. Across the fixed portfolio plus four
RSM/GPCM controls, 40 bases trigger 40 capacity and eight strictness solves.
Base construction takes 0.06 seconds, run-LP work 8.64 seconds, the underlying
solver 8.58 seconds, and R assembly/dispatch 0.06 seconds. The 99.31% solver
share is one diagnostic run, not a frozen performance rule. v2 records a
99.77% share with identical classification/capacity results, demonstrating both
the stable attribution and the instability of sub-percentage timing claims.

An independent sparse GLPK route matches `lpSolve` on all 40 target results:
32 negative cones, eight certified additive recession directions, and maximum
capacity difference `1.421085e-14`. Thirteen sparse/dense, near-boundary, flat-
direction, and forced-failure controls pass. Additional baseline/instrumented
controls cover a two-Rater missing/weighted RSM, an interaction RSM, a two-
Rater strongly imbalanced bounded GPCM with protected category support, and an
eight-Rater sparse-panel bounded GPCM. All four preserve semantic hashes and
readiness and pass 11 independent comparisons. GPCM coverage remains the
conditional-additive LP; nonlinear slope recession is not closed.

The v1 bundle is superseded for interpretation because it covered only the
fixed PCM routes. v2 adds cross-model controls but lacks the runtime-content
hashes that v3 records for all solver capabilities. The promoted v3 record is
`jml-lp-attribution-pilot-record-0.2.3.md`. `Rglpk` and `slam` remain validation-
only and do not enter `DESCRIPTION`. Because independent timing is single-run
and always follows `lpSolve`, its apparent difference cannot select a solver.

Draft.57 reacquires all 40 Draft.56 targets exactly, representing 28 unique
problem identities, and evaluates `lpSolve` and GLPK with one excluded warm-up
and seven included alternating-order replicates per target. All 560 timed calls
are safe and match the captured production result; all 280 paired comparisons
agree, with 140 first-position and 140 second-position calls per solver. GLPK
totals 13.32 seconds versus 60.05 for `lpSolve`, but this is a calibration
hypothesis rather than a speed or dispatch rule.

The broader qualification rejects immediate GLPK candidacy. Cross-model
generated properties pass 94 of 96 solver rows. Both failures are the same
positive joint RSM cone after deterministic positive row scaling from `1e-3`
through `1e3`: `lpSolve` retains the expected certified capacity 147, whereas
GLPK returns nonoptimal status 1 at the capacity stage. Failure-status controls
also show that `lpSolve` reports the unbounded fixture as status 0 with value
`1e30`, while Rglpk collapses infeasible and unbounded cases to status 1 and
returns status 0 with an `NA` objective for a nonfinite input. External box-
bound and post-solve validation reject all unsafe results, but zero of two
solver routes preserves every requested failure class. Six fresh-process
PCM/RSM/GPCM memory cells complete, yet their process-lifetime peaks do not
freeze an allocation envelope. `CandidateQualified`, `SolverDispatchEligible`,
and confirmation authorization remain false; `Rglpk`, `slam`, and `ps` remain
validation-only.

Draft.58 should test a solver-neutral constraint-row normalization that binds
original and transformed identities, retains the original strict objective and
post-solve margins, and repeats a fixed finer scale ladder in fresh processes.
It should replace mapper-only timeout rows with OS-deadlined child processes
and separate raw status, exit reason, objective/primal validity, theoretical
box bound, and original-scale certificate. If this cannot establish scale and
status provenance, retain `lpSolve` and return priority to nonlinear GPCM slope
recession, target-scale RSM/GPCM positive cones, PCA computability, and ADEMP
recovery/coverage rather than continuing solver-local optimization.

Draft.51 verification exercises all 127 package-aware test files. The exact
491-entry source tarball, SHA-256
`bd72d5256d4f721ed735d08306bf6b8cba029108c913707b942095070d56a1df`,
passes `R CMD check --no-manual` with `Status: OK`; its check-log SHA-256 is
`d267352a743fed66d215e42bc57d88bc7f0ad7e948e6d74591a451f13b78e061`.
The repository-only runtime-identity test passes separately against the fixed
installed Draft.51 package. This is not `--as-cran`, a candidate, or a release
gate pass: manual, `--run-donttest`, dependency-present, external, and later
candidate-linked checks remain open.

### GPCM discrepancy decomposition and stress envelope

No scalar "FACETS minus mfrmr" or "TAM minus mfrmr" result is interpretable
until the following layers have been separated. A difference discovered in an
earlier layer blocks numeric aggregation in every later layer; it is recorded
as a specification difference, not repaired by choosing a favorable output
column or rescaling after results are seen.

| Layer | Adversarial question | Required evidence before comparison | Failure classification |
| --- | --- | --- | --- |
| Response kernel | Do cumulative adjacent-category utilities, signs, category origins, and observation weights define the same probabilities? | Probability and log-likelihood equality at prespecified parameter points, including K=2 and unit-slope reductions. | `different_model_kernel` |
| Active structure | Does every row activate the same Person, facet, interaction, step, and slope term? | Row-level design digest and retained-row identity; structural absence is distinct from missing data. | `different_active_design` |
| Step structure | Are thresholds common, scale-specific, or element-specific, and are empty internal categories retained, collapsed, or rejected? | Declared/observed/category maps, free dimensions, anchors, and transformed threshold equality. | `different_category_or_step_estimand` |
| Slope structure | Is discrimination fixed, jointly estimated, post-fit diagnostic, grouped, or designed; which facet indexes it? | Parameter-role map and proof that the slope enters the fitted likelihood. | `different_slope_estimand` |
| Identification | Which location, slope, and latent-variance constraints define the numerical scale? | Analytic transformation plus likelihood and Jacobian checks; transformations are frozen before output is viewed. | `identification_not_matched` |
| Estimator | Are Persons optimized, integrated, conditioned out, adjusted, or hierarchically modeled? | Method, adjustment, quadrature/conditioning, prior/population, and extreme-score convention identity. | `different_estimator` |
| Global geometry | Can Person, facet, step, and slope coordinates escape jointly even when a conditional slice is bounded? | JML joint nonlinear and MML marginal boundary audits with positive and negative controls. | `boundary_not_evaluated` |
| Information | Is uncertainty based on local observed, expected, sandwich, profile, bootstrap, or posterior information? | Parameter-ready estimand plus estimator-specific coverage; local optimizer Hessians remain diagnostic traces. | `uncertainty_not_comparable` |
| Data support | Do missingness, sparse bridges, two-rater overlap, weights, duplicate cells, and category imbalance leave the same effective information? | Retained contribution digest, topology and local-support strata, and zero false-ready exact controls. | `support_not_matched` |
| Diagnostics | Are bias, interaction, residual PCA, fit, and discrimination outputs fitted parameters, conditional screens, or post-fit summaries? | Named estimand, conditioning set, null/non-null operating characteristics, and multiplicity policy. | `diagnostic_not_parameter_agreement` |
| Output transform | Are logits, orientations, user scales, endpoints, finite adjustments, and labels identical? | Reversible transform record; extended-real boundaries never enter finite MAE/RMSE. | `output_transform_not_matched` |

The GPCM simulation program uses a prespecified covering design rather than an
uninterpretable full Cartesian product. Every core seed is crossed with the
mandatory corner cases below, while additional pairwise combinations fill the
covering array. Draft.41 instantiates this as 70 pilot cells covering all 1,330
two-axis level combinations. Discovery, calibration, and confirmation seeds
remain disjoint.

| Axis | Required levels | Why it can expose a false agreement or false difference |
| --- | --- | --- |
| Estimator | JML; MML-direct; applicable lower-model reference | Conditional and marginal boundary or uncertainty evidence is not transportable. |
| Slope levels | 1, 2, 4, and at least 12; balanced and highly unequal exposure | One level is fixed PCM; two levels maximizes constraint coupling; many levels tests sparse coordinate scaling. |
| True slope spread | zero; mild; strong; near-zero/high pair; monotone and non-monotone association with severity | Separates exact reduction, useful discrimination, confounding, and boundary behavior. |
| Categories | K=2, 3, 5, 7; different K only as a deliberate unsupported/multiple-scale control | Checks binary reduction, threshold dimension, and the present single-scale boundary. |
| Category prevalence | balanced; rare interior; dominant middle; floor; ceiling; internal zero; boundary zero | Distinguishes weak information, exact step recession, Person extremes, and arbitrary category collapsing. |
| Rater panel | 2, 3, 6, and many; complete overlap, one shared Person, and zero shared Persons | Separates algebraic identification from fragile or absent empirical linkage. |
| Assignment | complete; sparse connected; weak bridge; disconnected; rater-by-proficiency routing | Tests topology, informative assignment, and latent-distribution sensitivity. |
| Missingness | none; MCAR; Person-dependent; rater-dependent; category/proficiency-dependent | A common missing rate can conceal different effective likelihoods and biased slope recovery. |
| Cell structure | unique cells; repeated cells treated as independent; explicit Occasion; unequal weights; zero weights | Distinguishes input multiplicity from modeled dependence and retained-row identity. |
| Interactions | none; Person-by-rater; rater-by-criterion; slope-correlated and slope-orthogonal | Detects whether free slopes absorb local bias or whether omitted interaction is misread as discrimination. |
| Diagnostics | residual PCA null/local-dependence signal; bias null/non-null; rater severity drift | Tests Type-I proxy and sensitivity separately; no diagnostic threshold is selected from the confirmation data. |
| Sample size | small, standard, and target-scale sparse | Exposes incidental-parameter trends, quadrature limits, dense allocation, and execution ceilings. |

Each eligible cell reports parameter bias/RMSE, supported SE availability and
coverage, primary-versus-optimizer classification, false-ready rate, fit and
parameter failure rates, category-support decisions, transformation residuals,
runtime/memory, and Monte Carlo uncertainty. Diagnostic cells additionally
report null flag rate, signal sensitivity, target localization, and the rate at
which a slope absorbs a generated interaction. Results are stratified by
estimator, support condition, parameter class, and external program/mode;
pooled averages cannot satisfy a blocker.

External roles are fixed as follows:

- local FACETS 4.5.0 supplies the RSM/PCM and fixed/equal-discrimination
  many-facet reference plus deliberately different post-fit discrimination,
  bias, interaction, and residual outputs. Table 7 discrimination is never a
  free-slope recovery target. The published 4.5.1 changes concern the R
  G-theory menu, display/report fixes, missing-label reporting, and Table 7
  subgroup t-test precision/variance; none authorizes transporting 4.5.1
  estimation claims into the local 4.5.0 run. The version difference is kept
  as provenance and sensitivity context, not a stop rule.
- TAM 4.3-25 `tam.mml.2pl(..., irtmodel = "GPCM")`, grouped GPCM, or
  `GPCM.design` is the candidate free-slope MML reference only for a design
  that can be re-expressed exactly. `tam.mml.mfr()` cannot supply estimated
  slopes, so combining its facet design with a separate slope output is
  prohibited.
- immer 1.5-13 supplies PCM-design JML/CML/CCML reductions and HRM
  alternative-model challenges. It supplies no free-GPCM numeric gold
  standard.
- an independent package-native probability/objective/gradient oracle remains
  mandatory even where an external result is eligible; software agreement
  alone cannot validate a shared convention error.

Source identities for this decomposition are the FACETS 4.5.1 manual and
official change log retrieved 2026-08-04, the CRAN TAM 4.3-25 reference manual,
and the CRAN immer 1.5-13 reference manual. Their URLs and retrieval dates
belong in the external candidate manifest; a version change creates a new
stratum rather than silently replacing these inputs.

Draft.46 rechecks those official sources on 2026-08-05 and changes roadmap
governance after the draft.45 metamorphic pass. CRAN still distributes mfrmr
0.2.2, TAM 4.3-25, and immer 1.5-13; FACETS 4.5.1 remains the current upstream
release while the licensed local 4.5.0 executable remains the required primary
execution stratum. No comparator-version rebase is needed. The substantive
change is portfolio control: 87 checklist rows cannot be interpreted as 87
undifferentiated serial release blockers.

The 0.2.3 exit decision now has three portfolios:

| Portfolio | Meaning | Release treatment |
| --- | --- | --- |
| `release_spine` | Candidate identity; core numerical/readiness guards; ADEMP recovery and failure-mode envelope; sparse target envelope; minimal metric-matched external overlap; public support envelope; exact-candidate engineering. | Must pass for the frozen candidate. |
| `claim_conditional` | GPCM primary slope/uncertainty, JML uncertainty or adjustment, automatic IC ranking, inferential diagnostics, dimensionality consequences, and external aggregation beyond a matched metric-mode slice. | Blocks that claim, not automatically the entire release. Unfinished claims must be disabled, remain unavoidably caveated/exploratory, or be deferred on every public surface. |
| `deferred` | Native multidimensional, CML/CCML, HRM, posterior-predictive/MCMC/heavy backends, unrestricted GPCM/ecosystem parity, FACETS-scale capacity parity, 0.2.4 calibration, and 0.2.5 multiple-scale work. | Does not block a bounded 0.2.3 unless public scope is deliberately expanded. |

No existing checklist row is deleted or promoted by this reclassification.
The next governance artifact must map each `(Gate, Item)` to one portfolio and,
for every conditional claim, name the fail-closed fallback. Until that
machine-readable profile is reviewed, the current checklist remains an
inventory rather than a release-minimum count. Full reasoning and official
source URLs are recorded in `roadmap-reassessment-record-0.2.3.md`.

The program's objective is not to maximize new diagnostics. It
is to establish one source of truth for whether a fit, a parameter, and an
external comparison are usable, and to make every downstream surface consume
that source rather than reconstructing readiness independently.

The dependency order is:

```text
WP0 contract/fixtures
  -> WP1 constrained estimability ----+
  -> WP2 category/step support -------+-> WP4 readiness propagation
  -> WP3 JML boundary/extreme states -+       -> WP5 eligible comparison slices
                |                              -> WP6 internal scale/performance
                +-> WP7 design/precision prespecification

Frozen release-spine profile + affected WP1--WP6 slices + candidate identity
  -> WP7 confirmation
```

WP1--WP3 may use separate fixtures, but a claim is not complete until WP4
proves that its state reaches every affected summary, diagnostic, report,
plot, export, and replay surface. WP5 accepted/rejected fixtures may proceed
for stable RSM/PCM metric slices while unrelated GPCM or diagnostic propagation
remains open. WP6 construction/runtime work may proceed in parallel when it
makes no inferential promotion. WP7 may prespecify replication, MCSE, seeds,
and manifests, and may run calibration pilots for explicitly stable slices.
Any later code/contract change invalidates its affected rows by dependency
identity. Confirmation remains prohibited until the release-spine profile,
affected WP1--WP6 slices, criteria, and candidate identity are frozen.

| Work package | Depends on | Current state | Implementation boundary | Required exit artifact |
| --- | --- | --- | --- | --- |
| `WP0-READINESS-CONTRACT` | draft.20 diagnosis | `complete_structural_v3` | Freeze internal state names, scopes, severity/precedence, condition classes, object fields, legacy-object behavior, and exact adversarial fixtures before changing fit logic. | `readiness-contract-0.2.3.md`, its repository validator, 36-row fixture registry including nine GPCM slope states, and privacy/semantic tests; no external tolerance. |
| `WP1-ESTIMABILITY` | WP0 | `in_progress_mml_all_pattern_design_reuse` | Build the estimator-specific free-parameter map and constrained design; detect structural aliases before optimization; distinguish exact alias from weak fitted information. | Unit/property tests, alias diagnostics, sparse-design benchmark, and zero false-ready exact controls. |
| `WP2-CATEGORY-STEP` | WP0 | `in_progress_support_preflight` | Audit declared, observed, retained, free, fixed, and unsupported category/step coordinates globally and by current `step_facet`; do not add threshold anchors. | RSM/PCM/GPCM reduction and missing-category fixtures plus parameter-scoped status tables. |
| `WP3-JML-BOUNDARY` | WP0 | `in_progress_bounded_joint_nonlinear_gpcm_paths` | Detect JML element separation/extreme sufficient scores on the actual contributing row pattern; replace optimizer-dependent finite primary values with typed boundary states. The Person primary-state slice, sparse-triplet Person-fixed structural certificate, companion joint Person-structural additive cone, retained-additive GPCM slope-only monotone paths, and ordered-pair linear-additive/constant-log-slope joint path family are implemented. Positive joint paths remain candidates because the GPCM likelihood is globally non-concave; negative results are scoped. More general rate vectors, curved paths, global arguments, independent general solver parity, broader model/basis properties, and target-scale evidence remain pending. | JML extreme/nonextreme fixtures, MML non-reduction guard, constrained facet/interaction/joint/slope-path certificates, sparse/dense and independent microcase parity, nonlinear joint-path positive and negative controls, and explicit optional-display contract. |
| `WP4-READINESS-PROPAGATION` | WP1--WP3 | `in_progress_gpcm_joint_candidate_slice` | Derive fit-, parameter-, and output-level readiness once and propagate it without surface-specific reinterpretation. The fit record, deterministic precedence, conservative scalar, fail-closed synthetic legacy-object path, summary/results/convergence/plot front doors, target-aware unpropagated-candidate rule, typed slope-only GPCM boundaries, and candidate-specific joint GPCM reasons under contract v3 are implemented. Competitive joint candidates remain `not_evaluated` with no primary value or ordinary uncertainty; complete facet/interaction/step and remaining output propagation depend on unfinished WP1--WP3 states. | Cross-surface snapshot/semantic tests and a real serialized 0.2.2-object migration fixture. |
| `WP5-COMPARISON-CONTRACT` | affected WP4 slice | `in_progress_core_slice_unblocked` | Make FACETS, TAM, immer, and other external normalization metric-specific and fail closed before numeric aggregation; identify estimator, adjustment, person treatment, and software stratum explicitly. Begin deterministic accepted/rejected fixtures and stable RSM/PCM metric slices now; unrelated GPCM, diagnostic, CML/CCML, and HRM rows remain ineligible until their own dependencies pass. | Eligibility/rejection ledger with denominator accounting, method-mode identity, and no silent row loss. |
| `WP6-SCALE-AND-ADVERSARIAL` | affected WP1--WP4 slice | `in_progress_solver_candidate_rejected_normalization_provenance_next` | Verify sparse computation, basis invariance, row-order and label invariance, malformed-input behavior, optional-capability fail-closed behavior, and target-size runtime/memory without claiming FACETS capacity parity. Drafts.43--50 establish MML row-order correction, execution identity, metamorphic checks, capacity/baseline cells, JML bottleneck axes, and phase attribution. Drafts.51--55 implement exact guarded reductions and preallocated contrasts; Draft.56 locates more than 99% of run-LP cost inside the solver with bounded independent parity. Draft.57 balances 560 replicated calls and passes all 280 ordinary pairs, but rejects GLPK candidacy after 94/96 generated property rows and zero-of-two complete failure-status-specific routes. The failed positive-RSM row-scaling control, `lpSolve` unbounded status-zero sentinel, Rglpk undifferentiated failure status, and six isolated-process memory cells are retained. Identity-bound solver-row normalization, actual child-process timeout provenance, finer scale ladders, larger positive cones, nonlinear GPCM slope coverage, PCA computability, serialization/replay, and broader active-structure grids remain open. | Benchmark envelope and metamorphic/negative-test report; capability manifest; no dense design allocation at target sizes. |
| `WP7-REPILOT-AND-FREEZE` | frozen release-spine profile plus affected WP0--WP6 slices | `in_progress_negative_solver_qualification_recorded` | Prespecify replication counts, MCSE targets, failure denominators, seeds, and manifests in parallel. Calibration pilots may run only for explicitly stable slices and are invalidated by later affected code/contract changes. Drafts.43--56 supply feasibility, atomic resume, metamorphic prerequisites, computation attribution, guarded exact reductions, and bounded independent parity. Draft.57 adds seven alternating repetitions per target and isolated-process memory, while explicitly separating a completed negative qualification from candidate promotion. The observed timing difference is not eligible for a rule because scale and status properties fail, the 40 targets contain 28 unique identities, fit-level replication remains open, and memory values are process-lifetime peaks rather than solver-only allocation. General target-scale RSM/GPCM coverage, normalized-property replication, actual timeout provenance, replicated fit timing, and a complete statistical precision plan remain prerequisites to any runtime/capacity or solver-dispatch freeze. Neither the global optimizer threshold nor a runtime/capacity rule may be frozen from these profiles. Confirmation remains globally unauthorized until the profile, criteria, and candidate are frozen. | Claim-disposition profile, complete pilot registry, atomic resumable execution, method-mode-specific exclusions, prespecified precision plan, resolved release-spine blockers, and still no confirmation result. |

#### Corrective-program execution lanes

The work packages use three non-interchangeable execution lanes:

1. The **change-local contract lane** runs the smallest deterministic unit,
   adversarial, privacy, and terminology set that can reject the current edit.
   It is a development feedback gate, not statistical or release evidence.
2. The **branch regression lane** runs every repository test, including the
   non-CRAN suite, before a work-package handoff. If infrastructure time limits
   require a split run, the sorted test-file manifest must be partitioned
   exhaustively with no omitted file, every partition must retain its exit
   status, and warnings/skips must be reconciled across partitions. Passing
   only the change-local lane cannot substitute for this lane.
3. The **candidate evidence lane** runs the frozen scenario registry,
   cross-platform package matrix, heavy recovery/resampling, and external-tool
   comparisons against one manifest-bound candidate. Branch-regression output
   cannot be relabelled as candidate evidence, and candidate thresholds cannot
   be changed after this lane begins.

Runtime budgets for the first two lanes must be piloted separately. Slow
simulation, resampling, and external comparisons may be scheduled outside the
change-local lane, but no blocker may disappear from the exhaustive branch or
candidate manifests. WP6 owns the target-size estimability runtime/memory
envelope; G7 separately owns CRAN-controlled time.

#### WP0 frozen boundary

The normative structural record is
`readiness-contract-0.2.3.md`. Its machine-readable vocabulary, derivation,
legacy mapping, condition-class registry, and validator are in
`readiness-contract-0.2.3.R`; exact expected cases are in
`readiness-contract-fixtures-0.2.3.csv`. The contract identity is
`mfrmr-readiness-0.2.3-v3`.

WP0 is structurally complete, not statistically confirmed. In particular, it
freezes that `InferenceReady` is `TRUE` only for `FitReadiness = ready`, while
parameter-scoped output preserves estimable coordinates from a
`ready_with_exclusions` fit. It freezes fail-closed legacy mapping and
metric-specific comparison eligibility. It does not claim that current fit,
summary, plot, export, or normalizer code implements those states; that claim
is prohibited until WP1--WP5 pass their runtime and propagation tests.

WP0 also resolves pre-fit blocker behavior: invalid input, exact structural
nonidentification, and unsupported free category/step coordinates will use
typed errors carrying structured preflight records. Boundary exclusions and
numerical review remain inspectable on returned fits. No 0.2.3 public bypass
for an exactly unidentified fit is planned.

#### Three readiness scopes

The current scalar readiness vocabulary is insufficient. Draft.21 requires
three linked scopes while retaining one conservative first-screen summary:

| Scope | Required internal record | Examples of non-ready states |
| --- | --- | --- |
| Fit | `FitReadiness` plus component states | invalid input, unsupported model, structurally unidentified, numerical failure, review required |
| Parameter | one row per displayed or fixed coordinate | aliased, unsupported step, weak information, JML unbounded low/high, fixed/anchored, estimable |
| Comparison | one row per external metric and parameter class | model-contract mismatch, category/step mismatch, constraint mismatch, unidentified, unmatched boundary convention, eligible |

`InferenceReady` remains a compatibility summary during 0.2.3, not the data
model for new logic. WP0 must decide and test its conservative mapping before
WP1 changes runtime behavior. In particular:

- exact fit-level nonidentification can never map to `TRUE`;
- an optimizer success code cannot improve a worse design/category state;
- an excluded unbounded JML Person must not appear as a finite primary
  estimate, but other demonstrably estimable parameter classes need not be
  silently discarded; and
- reports must show whether readiness applies to the whole fit, a restricted
  set of parameters, or a comparison only.

The machine-readable component fields frozen by WP0 are:

`InputState`, `EstimabilityState`, `CategoryState`, `BoundaryState`,
`NumericalState`, `FitReadiness`, `ParameterStatus`, `ComparisonEligibility`,
`ReasonCodes`, `ReadinessScope`, and `ReadinessContractVersion`.

They remain internal schema rather than public API promises. The first-screen
precedence is fail closed: blocked, legacy unknown, review,
ready-with-exclusions, then ready. Multiple reason codes are retained; a
single most-severe label must not erase the causal audit trail. Exact state
vocabulary and derivation are owned by the WP0 contract rather than duplicated
here.

#### WP1: constrained estimability contract

The pre-fit audit is estimator- and parameterization-specific:

- JML includes free Person/facet coordinates and the linearly indexed
  step/interaction coordinates, then applies centering, direct/group anchors,
  fixed values, and structural absences before structural location rank is
  judged. Nonlinear bounded-GPCM slope coordinates require their model
  Jacobian/information audit and are not certified by an additive design rank.
- MML integrates Person effects and therefore must not reuse the JML Person-
  column rank rule. Panels linked only through a common latent distribution are
  labelled `population_assumption_linked`; their interpretation requires
  assignment and population-invariance evidence even when the marginal model
  is algebraically identified.
- Anchored coordinates are removed from the free vector and enter as known
  offsets. Linear/group constraints are represented explicitly; they are not
  approximated by dropping an arbitrary display column.
- Interaction columns and step coordinates enter the audit only under the
  model that actually fits them. A main-effect audit cannot certify an
  interaction model.

The implementation uses a staged computation. A graph/structural screen and a
sparse free-coordinate location or derivative design come first as applicable.
Sparse symbolic/numerical QR checks structural rank; a tolerance ladder and
selected singular-value, Jacobian, or fitted-information diagnostics
distinguish exact alias from near-alias. Dense SVD is limited to small
explanation fixtures. Rank, tolerance, evaluation point, scale, contrast
basis, free dimension, and any null-space explanation are recorded. A single
universal condition-number cutoff is prohibited.

Required invariance tests cover row permutation, level relabelling, alternative
full-rank contrast bases, equivalent anchor parameterizations, and harmless
zero-column removal. Required negative controls cover disconnected components,
zero-common-Person JML panels, nested rater/Person groups, single bridges,
unused interaction cells, and anchors that do or do not restore a common
frame. A basis-dependent pass/fail result is a blocker.

##### Draft.23 implementation slice

The package now builds a sparse adjacent-category-logit design in the actual
free coordinates for RSM/PCM. It includes free JML Person coordinates, omits
them for MML, and applies the optimizer's facet/group-anchor Jacobians, facet
signs, two-way sum-zero-marginal interaction basis, and RSM/PCM within-ladder
step constraints. Columns are normalized before a recorded sparse-QR tolerance
ladder; small negative controls receive bounded dense-SVD null explanations,
while large designs do not cross the bounded dense-allocation threshold.
Tolerance-ladder disagreement is retained as a diagnostic field only. It does
not produce the `weak_information` readiness state until a fitted-information
layer and a pilot-calibrated rule have been reviewed and frozen.

Exact rank deficiency now raises a structured `mfrmr_estimability_error`
before optimization. The condition carries the contract identity, rank,
nullity, parameter-block counts, coordinate map, reason codes, tolerance
results, and bounded null directions without printing Person identifiers in
the error message. A full-rank MML fixed-effect block is also compared with a
counterfactual free-Person JML design. If only MML is full rank, the fit is
labelled `population_assumption_linked` and remains review-only; shared
Criterion levels alone do not become shared-Person evidence.

Current exact controls cover balanced JML, row permutation, level relabelling,
RSM/PCM step coordinates, zero-common-Person JML versus MML, two alternative
Rater anchors that restore rank, a missing interaction cell, and the equality
of sparse constraint Jacobians with the optimizer expansion. Existing
disconnected cases were reclassified by rank rather than by graph appearance:
some remain full rank under their declared constraints but still retain a
linking hold, whereas a balanced two-component Rater/criterion split stops as
an exact alias.

##### Draft.25 fitted-information instrumentation slice

For a retained nonlinear fit that passes the existing terminal stationarity
gate and has at most 80 free coordinates, the package now evaluates a dense
numerical Hessian of the same negative log-likelihood and analytical gradient
used by the direct optimizer. The stored record identifies the evaluation
point, model and estimator, free dimension, execution limit, nonlinear blocks,
explicit free-coordinate difference step, retained and reevaluated objective,
objective difference, terminal gradient, Hessian asymmetry, full-vector
symmetric-eigenvalue tolerance ladder, and nonlinear-block diagonal summary.
Deterministic integration controls cover bounded-GPCM `log_slopes`
and latent-regression `log_sigma2`; nonstationary, malformed-vector, oversized,
and unavailable cases retain explicit not-evaluated states.

This is instrumentation, not a decision rule. The 80-coordinate limit is a
dense-Hessian execution cap, not an estimability threshold. No eigenvalue,
rank, diagonal, or condition result produces `weak_information`, changes
readiness, completes the nonlinear preflight, or licenses external agreement.
Those semantics remain prohibited until the pilot grid establishes a
parameterization-aware rule and WP4 propagates the frozen result consistently.

##### Draft.26 nonlinear transformation instrumentation slice

Every retained fit with free bounded-GPCM `log_slopes` or latent-regression
`log_sigma2` now receives a separate free-to-expanded transformation audit.
For GPCM it records the sum-zero log-slope and positive geometric-mean-one
slope Jacobians; for latent regression it records the log-variance and positive
residual-variance Jacobians. Analytic derivatives are checked against
coordinate-scaled central differences. The record includes dimensions,
expected and tolerance-ladder ranks, natural-coordinate ranges, constraint
residuals, absolute and scaled derivative differences, conditioning, malformed-
vector/configuration states, and exact coordinate-system labels.

This audit is deliberately marked `parameterization_only`. Full-column rank
means only that the declared free-to-expanded map is locally nondegenerate at
the retained finite vector. It does not show that the response likelihood
contains information about the coordinate, does not combine the nonlinear
coordinate with the additive design, and cannot produce structural
identification, weak-information, readiness, or external-comparison decisions.
The fitted-information record remains a separate local likelihood diagnostic.

##### Draft.27 JML GPCM conditional response-kernel slice

For retained JML GPCM fits, the package now evaluates the Jacobian of every
adjacent-category logit, `a_s * (eta - step)`, with respect to the full
optimizer free vector. The additive Person/facet/interaction/step block is
scaled by the observed slope; the log-slope block applies the sum-zero
log-slope expansion and the exact `a_s * (eta - step)` chain rule. The record
contains the optimizer-coordinate map, local rank ladder, bounded null
directions, execution size, and an independent coordinate-scaled central-
difference comparison. Deterministic controls establish derivative agreement,
row-order invariance, and exact reduction of the additive block to the existing
PCM design at unit slopes. A numerical-differentiation size cap does not stop
the sparse analytic calculation or create an inferential state.

The estimator boundary is intentionally asymmetric. MML integrates Person
coordinates, so it records
`not_evaluated_marginal_person_pattern_required` instead of treating the JML
conditional-observation Jacobian as a marginal identification result. The
bounded observed-information Hessian remains separately available for eligible
MML fits, but it is a local fitted-likelihood diagnostic and is not a substitute
for a person-pattern response map or a calibrated rule.

##### Draft.28 MML observed Person-pattern score slice

For bounded nonlinear MML fits, the runtime now decomposes the retained
marginal log likelihood into one observed response-pattern contribution per
Person and evaluates its conventional score over the exact optimizer free
coordinate order. Each Person row is obtained from the same analytic MML
derivative kernels at the same quadrature rule as the retained fit. The stored
record verifies that the pattern log marginals reconstruct the full negative
log likelihood and that their score rows sum to the negative of the full
objective gradient. Each row is also checked independently against coordinate-
scaled central differences of that Person's log marginal contribution.

The bounded record contains Person-row and free-coordinate counts, quadrature
points, optimizer severity, execution limits, score-Jacobian rank ladder,
parameter-block map, bounded parameter-only null directions, row-norm summary,
objective/gradient reconstruction error, and derivative error. Observation-row
permutation is tested at a fixed retained vector. Person identifiers and the
score matrix itself are not copied into the fitted audit object.

This is an observed-pattern local diagnostic. It does not enumerate all
possible response patterns, does not reuse the JML conditional kernel, and does
not classify structural identification, weak information, or readiness. In a
deterministic eight-Person GPCM control the derivative and gradient identities
hold while the observed-pattern matrix is rank deficient; this is retained as
a direct negative control against converting observed-pattern rank into a
structural decision. Execution caps are computational states only.

##### Draft.29 MML all-pattern expected-information slice

For each bounded nonlinear MML fit that remains within the recorded execution
envelope, the runtime now fixes each Person's retained observation design and
enumerates every finite category-response vector on that design. Rows omitted
as missing are not recreated or imputed: a Person with fewer retained rows has
a correspondingly smaller response-pattern space. This first exhaustive
implementation requires unit row weights because an arbitrary powered
likelihood is not the same normalized finite response-pattern distribution.
Nonunit weights receive an explicit non-evaluated state.

For every pattern, the package evaluates the marginal probability and analytic
score in the exact optimizer coordinate order. The stored audit verifies that
each Person's pattern probabilities sum to one, that probability-weighted
scores have expectation zero, and that score outer products form a symmetric
positive-semidefinite expected-information matrix. Selected patterns from the
first and last retained Person designs are checked against coordinate-scaled
central differences. The fitted object stores workload, normalization,
identity, eigenvalue, rank-ladder, derivative, and execution summaries, but not
Person identifiers, pattern rows, score rows, or the expected-information
matrix itself.

The default envelope is at most 100 Person designs, 4,096 patterns for any one
design, 5,000 actually evaluated patterns after exact design reuse, 80 free
coordinates, and 400,000 evaluated pattern-by-coordinate score elements. The
conceptual Person-by-pattern total is recorded separately. These values are
implementation caps, not supported capacity claims. Exact controls cover
complete and one-row-missing GPCM
designs, row permutation, latent-regression beta and residual variance,
nonunit-weight rejection, and execution-limit rejection. In the balanced
eight-Person GPCM control, all 2,048 patterns give probability-mass error below
`6e-16`, expected-score error below `5e-15`, central-difference error below
`7e-10`, and local rank 7 of 7, whereas the realized observed-pattern score
matrix in draft.28 has rank 5 of 7. A one-node, zero-vector control makes the
GPCM slope direction locally zero, demonstrating that even exhaustive-pattern
rank remains evaluation-point and integration-rule dependent.

##### Draft.30 exact Person-design reuse slice

The exhaustive evaluator now canonicalizes the retained observation rows
within each Person and creates an internal exact design signature from the
ordered facet, step, slope, and interaction indices. When a latent-regression
population model is active, the aligned numeric population-design row is part
of the signature. Person identifiers and observed scores are excluded. Thus,
Persons with the same measurement design can share one all-pattern evaluation,
while a different missingness layout, facet assignment, interaction cell, or
population covariate row prevents reuse.

Each unique design is evaluated once. Its probability-weighted score matrix is
scaled by the square root of the exact group multiplicity, so its crossproduct
equals the sum of the corresponding Person-level expected-information
matrices. Probability-mass and expected-score identities are still expanded
per conceptual Person. The audit stores only Person-design count, unique-design
count, reused-design count, largest group, conceptual/evaluated pattern counts,
and their ratio; signatures, covariates, Person identifiers, pattern rows, and
score matrices are not retained.

Deterministic controls compare the reused path with a forced non-reuse path. In
the balanced eight-Person GPCM fixture, 2,048 conceptual patterns reduce to 256
evaluated patterns; the two expected-information matrices differ by less than
`6e-14`, expected scores by less than `2e-16`, and probability masses are
identical. One missing row creates exactly two design groups and 320 evaluated
patterns rather than 1,856. Row reversal preserves the one-group result. In
the continuous-covariate latent-regression fixture, all 50 design rows remain
distinct; forcing two covariate rows to equality reduces the group count by
exactly one. An exploratory local timing changed from approximately 1.67 to
0.22 seconds for the balanced fixture, but this machine-specific observation
is not a frozen benchmark or capacity claim.

WP1 is not complete. The JML conditional, MML observed-pattern, and MML
all-pattern expected-information results are retained-point diagnostics. A
global or parameter-grid structural argument, active latent-variance and GPCM
property grids, alternative contrast/anchor/slope-facet grids, exact local-rank
controls away from degenerate integration rules, sparse target-size memory and
runtime evidence, a scalable alternative when unique designs themselves still
have exponentially large response spaces, an alternative to the
bounded dense Hessian, and calibrated weak-information classification remain
pending. No FACETS tolerance or supported-capacity claim follows from this
implementation slice.

#### WP2: category and step contract

Every fit records a category-support table with at least:

`ScaleScope`, `StepScope`, `DeclaredCategories`, `ObservedGlobal`,
`ObservedWithinScope`, `RetainedForFit`, `FreeStepCount`, `FixedStepCount`,
`UnsupportedCategory`, `UnsupportedStep`, `ZeroType`, `InformationState`, and
`ReasonCode`.

The rules are model-specific:

- RSM estimates one common ladder in the current fit. Global absence of an
  internal category creates a common-step recession direction; absence only
  within one facet level is primarily a local-information issue when the
  category is supported elsewhere.
- PCM uses the current `step_facet` ladders, so support must be checked within
  every ladder. A global category count cannot establish a local PCM step.
- bounded GPCM inherits the applicable category/step checks and additionally
  keeps slope information separate; a stable slope cannot rescue an
  unsupported internal-category step contrast.
- a declared but unobserved boundary category is preserved as data semantics,
  and is routed to weak/element-boundary review rather than misclassified as
  an unsupported step-shape coordinate. Threshold anchors and reusable
  assertions remain 0.2.4 work.

Structural zero, sampling zero, rare-but-observed, and severe concentration
remain distinct. Count, proportion, and entropy may trigger review but cannot
by themselves prove identification. Exact unsupported coordinates are decided
from the parameter/support map; weak information is calibrated later from
fitted information and recovery. FACETS `K`, category dropping, dummy-weight,
and threshold-anchor cases are external policy controls, not new 0.2.3 mfrmr
features.

##### Draft.31 category/step preflight slice

Every new fit now builds `category_support_audit` before optimization and
stores it in both `config` and `data_review` when a fit is returned. The
required scope table distinguishes declared, globally observed, observed
within the fitted ladder, retained, free, fixed, derived, unsupported, zero-
type, and information-state fields. Separate category-count, expanded-step
status, and local facet-support tables preserve the evidence behind the scalar
category state. `ScaleScope = single_observed_scale` is an explicit internal
one-scale reduction key, not a public `ScaleId` feature or a claim that the
future multiple-scale schema has been designed.
Raw row counts and positive-weight support are stored separately; all exact
support decisions use positive-weight observations, so frequency-weight
semantics cannot be inferred from row presence alone.

The exact preflight follows the actual within-ladder sum-zero free-coordinate
map. If internal category `c` has zero positive-weight observations, the
direction that increases the step below `c` and decreases the step above `c`
drives only that category probability toward zero while leaving every other
category exponent unchanged. This is an exact likelihood recession direction,
even though observations can occur on both sides of both cumulative
transitions. Conversely, absence of a boundary category does not by itself
create this step-shape direction and is retained as weak/element-boundary
evidence. A small fixed-eta numerical control confirms finite step estimates
for lower- and upper-boundary gaps but diverging adjacent steps for an internal
gap. RSM applies the internal-gap decision to its one shared ladder; a category
absent only within a Rater, Criterion, or other local facet level is review
evidence when it is supported globally. PCM and bounded GPCM apply the decision
independently to every current `step_facet` ladder; a stable GPCM slope cannot
override a missing internal category.
The current within-ladder sum-zero parameterization has `K - 2` free step
coordinates and one derived expanded step for `K` categories. Therefore a
binary ladder has no free step coordinate and is not falsely blocked merely
because one local scope is response-constant; that pattern remains weak or
boundary evidence for later contracts.

An unsupported free step raises `mfrmr_category_readiness_error`, carrying the
fit-scope category state, reason codes, scope table, category counts, and
parameter-scoped step statuses, before the optimizer runs. The condition
message does not print Person identifiers. Declared categories remain in the
audit and descriptive data review. Empty internal categories are exact
unsupported contrasts; empty boundary categories, singleton category cells,
and singleton cumulative-side cells remain `weak_information`. Entropy and
concentration are recorded but do not yet trigger a numerical threshold.

Deterministic controls now cover balanced PCM, a globally supported internal
category absent from one PCM ladder, RSM reduction of a boundary category
absent only locally, a globally empty internal category, bounded-GPCM
inheritance, a boundary-gap negative control, the binary no-free-step negative
control, row reversal, facet relabeling, reason-code/class behavior, and
condition-message privacy. The existing public boundary-gap regression remains
valid and is now explicitly protected against false blocking. Repeated design
evaluation also preserves the category condition class, state, and reason
codes, and returns a typed zero-row result schema when every replicate stops at
preflight instead of collapsing to an unusable zero-column table.

WP2 remains in progress. The singleton weak rule is a conservative structural
review trigger, not a calibrated operating threshold. Severe concentration,
local information eigenstructure, recovery-based weak classification,
structural-zero declarations, threshold anchors, reusable frozen calibration,
multiple observed scales, and metric-specific FACETS category/drop/`K`
eligibility remain pending. WP4 must still combine category, estimability,
boundary, input, and numerical components into the one stored readiness record
and propagate it to all summaries, reports, plots, exports, and replay paths;
until then a returned weak-category fit can still carry the legacy numerical
`InferenceReady` scalar and must not be described as end-to-end readiness
complete.

#### WP3: boundary and extreme contract

Boundary detection applies to every estimated JML element for which an
extreme sufficient-score argument is valid, not only Persons. It uses the
model-implied attainable minimum/maximum on the exact contributing observations
after missingness, signs, and supported positive weights. Fixed/anchored
elements, separated interaction cells, and ordinary large finite estimates
receive different statuses.

For an unanchored JML extreme, the primary measure is typed as unbounded; its
direction and response count remain available, while standard error and
ordinary finite-fit statistics are unavailable unless separately justified.
An optional adjusted display must name its formula and adjustment and cannot
overwrite the primary field. FACETS-compatible adjustment is a comparison
convention, not the mfrmr estimator target. MML/EAP Persons remain finite by
the population/prior model and must not be relabelled as JML-unbounded merely
because their observed response pattern is extreme.

##### Draft.32 Person sufficient-score boundary slice

Every new fit now builds a Person-scoped boundary audit after optimization and
stores it in `config$boundary_audit` and `data_review$boundary`. The audit uses
the retained preparation data, so missing or non-contributing rows cannot make
an otherwise nonextreme pattern appear extreme. Under the standard free-Person
JML parameterization, an all-minimum or all-maximum retained response pattern
has `ParameterStatus = unbounded_low` or `unbounded_high`; the primary
`Estimate` is negative or positive infinity. The optimizer's finite stopping
iterate is retained only in `OptimizerEstimate` with
`OptimizerEstimateUse = numerical_trace_only`, while `DisplayEstimate` is
missing and `DisplayAdjustment = none`. `ResponseRows` and
`WeightedResponseTotal` retain the contributing row count and positive-weight
total used by the classification.

The constraint Jacobian separates three cases before applying that rule. A
directly anchored or implicitly constraint-fixed Person is `fixed`, including
an extreme response pattern; an individually free Person is eligible for the
sufficient-score boundary result; and a centered or group-coupled extreme is
retained as `weak_information` with `weak_design_information` until a
constraint-aware recession-direction proof is implemented. This fail-closed
case prevents both automatic infinity and automatic finite-MLE claims under a
substantive coupled constraint. MML Persons remain finite EAP values with
`mml_extreme_response_prior_regularized` and are never assigned an optimizer
Person coordinate that the marginal model does not estimate.

The Person table, fit summary, and diagnostic measure table now preserve the
typed status. A fit with a proven Person exclusion records
`BoundaryState = has_exclusions`; the legacy `InferenceReady` scalar becomes
`FALSE`, while the estimable coordinates remain inspectable. Diagnostic SE,
CI, and formal-inference eligibility are unavailable for the unbounded Person.
The FACETS-style Wright renderer may place such Persons at the ruler endpoints
when `extreme_placement = "ends"`; this is recorded as a plot placement, not a
finite adjusted estimate. With `extreme_placement = "estimate"`, the row is
omitted from the finite ruler rather than replaced by the optimizer trace.
Native finite-density summaries exclude the unbounded rows.

Deterministic controls cover low/high free JML boundaries, direct anchoring,
constraint-coupled fail-closed behavior, finite MML/EAP non-reduction, missing
rows, fit-summary scalar behavior, diagnostic SE/CI exclusion, and both Wright
placement modes. Existing cross-constraint correlation tests now compare only
common `estimable` Persons; typed boundaries cannot enter those numeric
aggregates accidentally.

WP3 remains in progress. Response-constant non-Person levels are never treated
as sufficient evidence by themselves: additive facet, interaction, and step
claims now require the constrained likelihood recession certificates below.
The resulting candidates are still internal and do not yet replace finite
optimizer iterates in public non-Person tables. The stored fit-level record now
fails closed when an applicable candidate has not been propagated, but it does
not manufacture a primary parameter value. Slopes remain outside the linear cone;
draft.36 audits a separate fixed-additive nonlinear path without changing that
linear claim. No FACETS-compatible finite adjustment formula has been added. Reports,
exports, replay, serialized legacy-object evidence, and external normalizers
remain WP4--WP5 work and may not reconstruct or upgrade the stored state
independently.

##### Draft.33 Person-fixed structural recession certificate

Every retained JML RSM/PCM fit now attempts a bounded linear-program audit of
the additive structural coordinates when `lpSolve` is available. For each
observation, the audit converts the adjacent-category design into the exact
observed-versus-alternative category contrasts. A candidate direction is a
certificate only when every contrast margin is nonnegative after an independent
post-solve check and at least one margin is strictly positive. A structural
null direction therefore cannot masquerade as separation.

Person free coordinates are set to zero in this slice. The remaining design
uses the same free-coordinate map as optimization, including raw facet signs,
direct and group anchors, centering, two-way sum-zero-marginal interactions,
and RSM/PCM within-ladder step constraints. Each expanded facet level,
interaction cell, and step is tested separately for positive and negative
recession. The result distinguishes `unbounded_high`, `unbounded_low`,
bidirectional ambiguity, fixed coordinates, no recession certified in the
audited subspace, solver failure, dependency absence, and execution-limit
non-evaluation. Direction loadings and contrast-margin certificates retain the
optimizer coordinate identity without exposing response or Person identifiers.

Deterministic controls include a two-Rater sum-zero separation, a
response-constant Rater that is not separable once the other Rater's mixed
responses are respected, facet-sign reversal, direct-plus-implicit anchoring,
a checkerboard Rater-by-Criterion interaction, MML non-reduction, and bounded
execution-limit failure. The instrument is intentionally not a completed
boundary contract: its candidate statuses do not yet overwrite public facet,
interaction, step, or slope tables and do not change the Person-scoped
fit-level `BoundaryState`.

Draft.34 supersedes the dense construction in this paragraph, and draft.35
adds the joint additive companion described below. WP3 still requires an
independent general solver/parity fixture, equivalent-basis and broader
model-grid invariance properties, a joint nonlinear GPCM argument beyond the
retained-additive slope-only path, and measured runtime/memory evidence at the
prespecified sparse target sizes. Only after
those checks may WP4 promote a certified structural direction to the primary
parameter state and propagate its SE/CI, plot, report, export, replay, legacy,
and external-comparison effects.

##### Draft.34 sparse LP and independent microcase oracle

The default certificate now sends the constraint system to `lpSolve` as
row-column-value triplets. It no longer constructs the dense matrix containing
the positive and negative split variables. The box constraints and the
target-floor augmentation use the same triplet representation. A deliberately
bounded `dense_reference` route remains available only for parity tests and
small diagnostic reproduction.

The audit records variables, constraints, structural coordinates, target
directions, sparse nonzero count, dense-reference equivalent elements, and the
actual representation. Execution stops before solver entry when any frozen
engineering ceiling is exceeded. These are computational guardrails, not
evidence that the statistical model is weak or that FACETS-scale capacity has
been achieved. The legacy dense-element argument remains a compatibility
guard for internal callers but is no longer the default allocation rule.

Three layers now reject implementation drift. First, every solver result still
passes the observed-category contrast-margin certificate. Second, the sparse
triplet and dense-reference formulations produce the same direction status and
target capacity on both the two-Rater and checkerboard-interaction fixtures,
and the two-Rater result is invariant to retained row order. Third, a test-only
finite-grid oracle enumerates all `{-1, 0, 1}` directions in low-dimensional
microcases and agrees with the LP classifications for the checkerboard
interaction. The finite grid is an independent microcase oracle, not a complete
cone solver for arbitrary dimension or fractional rays.

A 20,000-row by 100-coordinate synthetic constraint-construction control
verifies that the default object stores only sparse triplets and avoids the
dense-reference allocation. It is an engineering allocation test, not a full
fit benchmark, recovery result, or FACETS comparison. WP6 must still measure
end-to-end runtime and peak memory across representative balanced, two-Rater,
sparse-linked, missing, interaction, and category-imbalanced fits before any
capacity claim or release ceiling is frozen.

##### Draft.35 joint Person-structural additive certificate

Every retained JML RSM/PCM fit now stores a second bounded audit beside the
Person-fixed structural result. Its contrast matrix contains all retained free
Person and additive structural optimizer coordinates simultaneously. The
global cone is screened first by maximizing the sum of nonnegative observed-
category margins. A positive result is accepted only after the same independent
post-solve minimum-margin and strict-row checks used for target certificates.
When no global ray exists, selected targets are classified without launching a
separate pair of linear programs for every target.

The joint audit does not duplicate draft.32 indiscriminately. Ordinary free
extreme Persons retain their exact sufficient-score status. Person-level joint
targets are restricted to constraint-coupled low/high cases that draft.32 left
as `weak_information`; all expanded facet, interaction, and step targets remain
eligible. The cone itself nevertheless includes every free Person coordinate,
so a structural direction that is possible only while Persons move cannot be
missed by holding non-targeted Persons fixed. Separate Person, structural, and
total additive-coordinate ceilings fail closed before solver entry. The
target-direction ceiling is applied only after a global ray is certified; a
no-ray result therefore does not launch or budget target-specific LPs merely
because the fitted object contains many expanded targets.

The primary adversarial fixture has two Persons and two Items with a fixed
Person-group mean. Its retained contrast inequalities have no nonzero feasible
strict direction in either the Person-only or structural-only subspace. The
full two-coordinate cone has the ray in which the Person contrast and Item
contrast move together. The LP consequently certifies the unresolved extreme
Person and both Item directions, and every stored direction contains loadings
from both blocks. A test-only exhaustive `{-1, 0, 1}` oracle independently
reproduces the global and target classifications. Sparse/dense formulations,
retained-row reversal, a nonseparated negative control, execution ceilings,
and MML non-reduction are also deterministic controls.

This closes the linear joint-movement gap only. It is not an independent
general-purpose cone-solver comparison, an end-to-end sparse capacity result,
the separate draft.36 nonlinear GPCM slope-path certificate, or a public
readiness propagation change.
The finite public `weak_information` Person and structural optimizer values are
deliberately retained until WP4 defines precedence, primary values, SE/CI
suppression, plotting, reports, exports, replay, legacy objects, and external
comparison eligibility from one stored readiness record.

##### Draft.36 retained-additive GPCM log-slope boundary paths

For a retained JML GPCM observation, draft.36 reconstructs the unscaled
cumulative category utilities from the exact adjacent `eta - step` values.
Along a constant expanded log-slope direction `q`, the derivative of the
observed log probability has the sign of
`q * alpha * (u_observed - E[u])`. It is therefore nonnegative for every
finite path point when a positive-loading group always observes a maximum-
utility category and a negative-loading group always observes a minimum-
utility category. At least one positive utility span is required so a null
direction cannot pass as a boundary path.

The geometric-mean-one identification is sum-zero on expanded log slopes.
Every nonzero constant direction has at least one positive and one negative
loading; any compatible pair alone is a valid direction. Enumerating all
ordered distinct level pairs is therefore complete for this fixed-additive,
constant-ray scope. The audit independently rebuilds the current weighted log
likelihood, rejects an objective mismatch, computes the high-slope and zero-
slope limiting likelihoods, records expanded and optimizer-coordinate
loadings, and fails closed before allocation when observation, utility,
slope-level, or pair limits are exceeded. MML is explicitly not applicable
because its Person-integrated pattern likelihood is a different object.

The fixed-Person checkerboard control has exact high compatibility for one
Criterion and exact low compatibility for the other. The optimizer stops at
finite log slopes near `+14.31` and `-14.31`, while the independent objective
oracle is monotone along the certified direction and approaches the stored
boundary likelihood. Row reversal gives the same certificate; public slope
tables retain the finite trace until WP4.

The more important negative control removes the Person anchors. At the
retained symmetric stationary point every base utility is tied, so no strict
slope-only ray is certified. Moving the two Person coordinates apart while
the two log slopes diverge nevertheless gives a monotonically improving joint
nonlinear path. This is not a defect in the scoped certificate; it is the
counterexample that prevents `scope_complete = TRUE` from being read as
`structural_identification_complete = TRUE`. A none-certified result means
only that no audited constant slope-only ray exists at the retained additive
point. WP3 remains open until broader joint nonlinear path logic, model/basis
properties, and target-scale evidence are addressed. Draft.37 now makes an
unpropagated positive candidate a fit-level review cause, but WP4 must still
determine its primary parameter value, SE/CI suppression, and complete
report/export/replay/external-eligibility propagation.

#### WP4--WP5: propagation and comparison eligibility

One readiness builder owns state derivation. Print, summary, diagnostics,
reports, plots, exports, support-envelope rows, and replay manifests consume
the stored record. They may format it but may not infer a different state from
warnings, parameter magnitude, or optimizer text. A saved 0.2.2 object without
the contract is `legacy_unknown`; it is never silently upgraded by current
display code. A deliberate re-audit/refit route may create a new-version
record with provenance.

External eligibility is metric-specific rather than one Boolean per run. The
normalizer checks response family, estimator, included observations/weights,
active facets, signs, category map, retained/free step dimension, anchors,
constraints, coordinate transformation, parameter status, and extreme-score
convention. A scenario may therefore permit a nonextreme Person comparison
while rejecting extreme display values, or retain prediction sensitivity while
rejecting PCM parameter MAE. Every rejection is counted by reason; aggregate
denominators report expected, eligible, rejected, missing, and failed rows.

#### WP6--WP7: scale discipline and repilot

The implementation must not construct a dense response-by-parameter matrix for
large sparse designs. WP6 benchmarks the graph screen, sparse design build,
rank audit, fitted-information audit, storage overhead, and downstream report
cost separately. Pilot target sizes are chosen from current mfrmr use and
resource measurements; they are not inferred from FACETS' advertised maximum.
If exact null-space explanation is too expensive, fail-closed classification
remains mandatory and the detailed explanation may be a bounded diagnostic.

WP7 first reruns deterministic fixtures, then the affected two-rater,
single-bridge, disconnected, category-absence, severe-concentration, and
extreme-score pilots on new pilot seeds. FACETS remains 4.5.0 for the primary
local stratum. The rerun must show:

- zero false-ready exact unidentified controls;
- zero unsupported-step parameters labelled estimable;
- no optimizer-dependent finite primary estimate for typed JML extremes;
- unchanged supported balanced reductions within frozen regression tolerance;
- no ineligible external row entering a numeric aggregate; and
- complete reason-coded accounting before any weak-information threshold or
  external tolerance is frozen.

Only after those structural outcomes pass may multi-seed recovery calibrate
weak-information and operating-envelope thresholds. Failure narrows 0.2.3
claims or keeps the affected surface blocked; it does not accelerate 0.2.4 or
0.2.5 features as a workaround.

#### Change containment, risk register, and decision log

Implementation is divided into reviewable commits in WP order. A contract/test
commit precedes each behavior change; rank, category, boundary, propagation,
normalization, and pilot changes are not combined into one unreviewable
refactor. Until WP7 completes, no commit may add a response family, public
`ScaleId`, threshold anchor, frozen-calibration API, or general active-facet
dispatcher.

| Risk | Adversarial failure | Required control |
| --- | --- | --- |
| Numerical rank masquerades as exact algebra | A tolerance or contrast choice changes pass/fail. | Structural screen, sparse-QR tolerance ladder, basis-invariance fixtures, recorded diagnostics, and `review` when exactness cannot be established. |
| Safety audit destroys sparse scalability | A dense matrix exhausts memory before the model can be assessed. | Sparse construction, dimension forecast before allocation, bounded explanations, target-size memory/runtime gates, and an explicit unsupported-size state rather than bypass. |
| Correct certificate is recomputed target by target without a global exclusion screen | A fail-closed audit dominates runtime even when the feasible recession cone is empty, or a later optimization weakens the Draft.51 equivalence. | Retain the versioned Draft.51 structural prescreen, positive-cone enumeration, solver/size fail-closed guards, frozen-route semantic comparisons, and target-status equivalence tests. Extend the same evidence discipline to joint attribution; never skip an audit merely because it is slow. |
| Fail-closed becomes indiscriminate | One extreme Person suppresses otherwise estimable facet results, or a local category rarity blocks a common RSM ladder. | Fit/parameter/comparison scopes, model-specific rules, reduction fixtures, and reason-coded exclusions. |
| Legacy behavior changes silently | A saved 0.2.2 object acquires 0.2.3 readiness semantics when printed. | Contract version, `legacy_unknown`, explicit re-audit/refit provenance, and serialized-object tests. |
| External software defines mfrmr | FACETS category dropping or adjusted extremes are copied merely to reduce numerical differences. | Truth-first evaluation, explicit estimand choice, separate display convention, and architecture decisions independent of agreement magnitude. |
| Valid rows disappear from aggregates | A normalizer silently drops hard cases and improves MAE. | Expected/eligible/rejected/missing/failed denominators and immutable reason ledger. |
| Pilot becomes confirmation by repetition | Seeds or thresholds are changed until results look acceptable. | Registered pilot seeds, one declared escalation rule, spec revision for every criterion change, and disjoint confirmation seeds after freeze. |
| Near-term fixes hard-code the future API | One-scale assumptions are embedded in fields later meant for `ScaleId`. | Use explicit scope keys internally, reserve versioned schema fields, and require one-scale reduction without exposing premature multi-scale behavior. |

Each WP decision record contains: decision ID/date, affected estimand and
surface, alternatives considered, selected rule, rejected shortcuts,
fixture/evidence IDs, compatibility impact, performance impact, open risks,
and which later evidence it invalidates. A rule promoted from pilot to frozen
also records the pilot registry and why the chosen threshold is scientifically
meaningful rather than merely observed to pass.

WP completion does not mean that every initially proposed behavior survives.
If a safe and scalable rule cannot be supported, the permitted outcomes are a
narrower support envelope, a visible review/blocked state, or deferral. The
impermissible outcomes are silently skipping the audit, loosening a criterion
after viewing confirmation, or expanding later features to route around an
unresolved core defect.

Draft.17 promoted FACETS from a conditional supplied-output row to a mandatory
JML RSM/PCM validation lane and adds
`inst/validation/facets-jml-stress-plan-0.2.3.md`. The 2026-08-03 environment
audit found that the official site advertises FACETS 4.5.1, while the selected
local `Facets.exe` has file metadata 4.5.0 and SHA-256
`dfb0afb0faa18f026d1b3b4175f22e42cc3764430eb83cbd368c7a572b3593a1`,
and retained 2026-05-07 reports identify FACETS 4.4.5. These are three distinct
identities. FACETS 4.5.0 is used for current pilot execution. Identity is
recorded for reproducibility, but the upstream-version difference does not stop
the batch. Existing 4.4.5 reports remain historical, and different versions
are summarized as separate sensitivity strata rather than pooled.

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
| External overlap | Matched ConQuest/TAM MML rows, the pinned FACETS 4.5.0 JML RSM/PCM stress core, the TAM/immer JML convention grid, and eligible immer CML/CCML structural rows pass locked, estimand-specific rules; optional FACETS fit/DFF and immer HRM challenge rows retain their distinct roles. | Correlation alone, any external program as truth, pooled adjustment/version modes, unmatched constraints, CML person comparisons, HRM-as-estimator reasoning, or comparison of MML/EAP persons with JML persons. |
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

- [x] Execute all six previously declared executable 400-Person
  `target_sparse` covering-grid cells as a guarded one-replicate capacity-
  feasibility run. Record zero unexpected runner failures and zero false-ready
  rows, but keep the one ready PCM-MML cell, blocked free-slope GPCM-MML cell,
  and all runtime/memory values out of recovery or capacity-limit claims.
- [ ] Define core cells across response family, sample size, facet-level count,
  category support, anchor pattern, link density, and bounded-GPCM slope
  regime. Select replication counts from a prespecified Monte Carlo standard-
  error target rather than convenience.
- [ ] Separate ordinary sparse-but-connected, weak-link/bridge, articulation,
  zero-common-person-pair, disconnected, empty-category, and extreme-score
  scenarios. Do not pool these into one generic `sparse` label.
- [x] Add pilot cells for complete two-rater assignment, one rater per Person
  with zero common Persons, and a three-Person bridge. The one-seed result
  diagnoses false-readiness risk but does not freeze a minimum design.
- [ ] Add a Person-sharing graph and report rater-panel size, common-Person
  counts, bridge strength, articulation, component balance, and local
  information. A binary response-graph connection must not override a weak or
  unidentified rater comparison.
- [ ] Construct the constrained free-coordinate design implied by active
  facets, centering, anchors, and structural absences; reject exact rank
  deficiency before fitting and expose aliased directions. Only after full
  rank is established may fitted information diagnose weak identification.
- [x] Add pilot cells for middle-category dominance, single-category
  dominance with an unused category, and skewed targeting; retain category
  counts, maximum proportion, and normalized entropy by model.
- [ ] Freeze model-specific category-support states using minimum counts,
  concentration/entropy, local facet support, and threshold information. A
  globally consecutive category range is not sufficient evidence of usable
  step information.
- [ ] Make external normalization compare the declared category map, retained
  category map, and free step dimension by scale/step-facet level before any
  element or Person tolerance. Category-dropping and `K` controls remain
  failure-policy evidence unless the fitted dimensions genuinely match.
- [x] Represent a standard free extreme JML Person primary result as typed
  low/high unbounded status rather than an optimizer-dependent finite value;
  preserve the finite iterate only as a numerical trace, keep MML/EAP finite,
  and exclude the boundary from ordinary SE/CI and finite ruler placement.
- [ ] Generalize the boundary proof to eligible constrained non-Person and
  interaction elements, add any named finite adjustment only outside the
  primary estimand, and make external Person comparisons stratify nonextreme
  and explicitly adjustment-matched rows.
- [ ] Record numerical convergence, identification, data/design readiness,
  inferential readiness, bias, RMSE, interval coverage where defined,
  terminal score, objective, condition indicators, and elapsed time by cell.
- [ ] Pair every FACETS core replicate with the same generated observations and
  truth record used by mfrmr. Judge truth recovery for each program separately
  before judging transformed mfrmr-minus-FACETS differences; agreement between
  two biased estimates is not validation.
- [ ] Use microcases, baseline cells, one-factor stresses, targeted interactions,
  and sensitivity cells instead of an unreviewed full Cartesian product. Freeze
  the selected cells and Monte Carlo precision rule before confirmation.
- [ ] Require disconnected or unidentified negative controls to fail closed.
  A negative control reported as numerically and inferentially ready is a
  blocker even if its optimizer converged.
- [ ] Use three execution tiers: a deterministic CRAN smoke tier, a release-
  blocking core tier outside CRAN, and an extended sensitivity tier that cannot
  hide a failed core cell.
- [ ] Retain per-replicate results outside the package, compact aggregate
  evidence in the repository, and a manifest linking both to the candidate.

### Interaction, bias-screening, and residual-PCA stress

- [x] Add one-seed zero-marginal Rater-by-Criterion checkerboards at 0.4 and
  1.0 logits and retain additive bias-screen and fitted-interaction results
  separately. The weak RSM bias screen missed its target in this seed; this is
  a calibration finding, not a power estimate.
- [ ] Calibrate null false-positive and non-null detection behavior over
  effect size, cell information, sample size, topology, category support,
  multiplicity method, and numerical-readiness state. Report Monte Carlo
  uncertainty and failed-replicate accounting; do not promote `p <= .05` and
  `|t| >= 2` as an automatic decision rule.
- [x] Add planted local response dependence and compare mfrmr residual PC1 to
  its residual-permutation cutoff and to FACETS raw-residual PC1 as descriptive
  sensitivity. Retain the weak-overlap discrepancy even though matched
  standardized residuals correlate above 0.996.
- [x] Exercise the residual-PCA route in the 400-Person target feasibility
  cells. Retain the case in which `psych` reports an undefined smoothed-
  correlation determinant/objective even though an exploratory object returns;
  do not reinterpret this as a valid PCA diagnostic.
- [ ] Capture residual-PCA condition messages, residual-matrix dimension/rank,
  pairwise support, and smoothing/repair state, then derive a fail-closed
  computability status before null/non-null calibration.
- [ ] Freeze the residual definition, missing-pair correlation/smoothing rule,
  permutation unit, quantile precision, and null/alternative seed grid. PCAR
  remains exploratory hypothesis generation and cannot name a latent
  dimension without an independently fitted alternative and consequence
  analysis.
- [ ] Build FACETS Table 14 bias controls with explicit `?B` terms only after
  centering, estimand, SE, degrees-of-freedom, and multiplicity conventions are
  definition-matched. Do not compare Table 14 mechanically with
  `estimate_bias()` merely because both use the word bias.

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
- [ ] Record the selected FACETS 4.5.0 executable/report identity using
  deterministic binary, RSM, and PCM microcases. Bind executable SHA-256, file
  metadata, report-header version, command/control/input/output hashes,
  parser/generator hashes, locale, and run date. A version discrepancy is
  reported without stopping unrelated runs; different versions are never
  silently pooled.
- [ ] Run the mandatory FACETS JML RSM/PCM stress core defined in
  `inst/validation/facets-jml-stress-plan-0.2.3.md`: ordinary connected
  recovery, element/group anchors, sparse/weak-link topology, and edge cases.
  Require complete replicate accounting and frozen truth, coverage,
  false-ready, and transformed-difference rules.
  - [x] Run a one-seed, 22-scenario-per-model calibration pilot with the local
    FACETS 4.5.0 executable; account for all 44 reports and preserve the result
    as non-confirmatory review evidence.
  - [x] Run nine extension scenarios per model for two-rater panels, severe
    category imbalance, checkerboard interactions, and residual local
    dependence; bind the diagnostic rerun to exact FACETS-manifest seeds.
    Preserve the result as draft.19 calibration evidence only.
  - [x] Run the draft.20 divergence audit on the completed 18-row extension
    and 44-row expanded pilot. Preserve its rank, retained-category, and
    extreme-score decomposition as diagnosis only; it rejects invalid
    comparison rows and does not validate a model.
  - [ ] Add the audit contract to the paired normalizer so unmatched category
    maps/step dimensions, rank-deficient designs, and unmatched extreme-score
    displays cannot enter parameter-agreement aggregates.
  - [ ] Add quantitative bridge-strength, articulation, component-balance, and
    local-information diagnostics. A single bridge must not inherit the same
    readiness meaning as a robustly crossed design merely because both graphs
    are technically connected.
- [ ] Treat FACETS fit and DFF/DIF evidence as separately promotable rows. They
  enter the public support envelope only after statistic definition, null/non-
  null generator, multiplicity, estimand, and acceptance rule match; attractive
  output or familiar labels are insufficient.
- [ ] Do not use FACETS JML person measures as an external target for MML EAP
  person scores. Compare model parameters or JML outputs only where estimands,
  constraints, and extreme-score handling match.
- [ ] Add a TAM/immer JML convention grid using identical generated rows,
  category maps, weights, facet design matrices, free-coordinate
  transformations, and truth. Preserve at least these identities separately:
  mfrmr uncorrected JML; TAM unadjusted, extreme-adjusted, and documented
  bias-reduced JML; immer unadjusted, extreme-adjusted, and bias-corrected JML.
  Do not choose or pool modes after seeing which agrees most closely.
- [ ] For every JML mode, report structural-parameter bias/RMSE, supported SE or
  interval coverage, extreme and nonextreme Person behavior, false-ready and
  failed-run rates, and the transformed between-program difference. A missing
  SE is an explicit unsupported cell, not zero uncertainty. Current mfrmr
  observation-information SEs remain exploratory until the coverage gate is
  passed; the grid does not imply a profile-likelihood Hessian.
- [ ] Stress the JML convention grid across balanced and unequal Person
  information, two-rater panels, sparse/weak links, planned and unplanned
  missingness, category imbalance, extreme scores, and increasing Persons with
  fixed per-Person observations. The last axis is the incidental-parameter
  control and must not be replaced by a large-N pooled summary.
- [ ] Add immer CML and CCML only as conditional Rasch-family structural-
  parameter references. Verify sufficient-statistic conditioning, design-
  matrix rank, constraint basis, category support, and missingness eligibility.
  Exclude Person estimates, bounded GPCM, latent-regression, and any quantity
  eliminated by conditioning. CML/CCML evidence cannot be relabelled as a
  native mfrmr capability.
- [ ] Add an immer HRM-generated local-dependence challenge after its latent
  true-rating, rater-severity/variability, prior, MCMC convergence, and label-
  switching contracts are frozen. Evaluate how the current additive mfrmr
  diagnostics fail or respond under this alternative. Do not include HRM rows
  in engine-equivalence tolerances and do not infer that HRM is preferred from
  one misspecified additive fit.
- [ ] Record CRAN and development TAM/immer identities as separate strata,
  including package version, source/repository identity, R version, dependency
  versions, function arguments/defaults, design-matrix hash, input/output hash,
  and normalizer version. A changed default is a new method-mode identity even
  if the package version is unchanged locally.
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
- [ ] Add a candidate-linked, machine-readable support-envelope registry with
  estimator, model, parameter/statistic, design conditions, maturity state,
  operational state, caveat, criterion ID, and evidence-manifest hash. Unknown
  combinations must resolve to `unsupported`, not inherit a nearby row.
- [ ] Add the FACETS batch audit: isolated synthetic run directories, one
  process by default, timeout and exit-code capture, exact expected-output
  inventory, parser failure tests, and a repository privacy/license scan.

### 0.2.3 Definition of Done

0.2.3 may become a release candidate only when:

- [ ] the M1 draft was reviewed and the M2 gate specification was frozen after
  pilot calibration but before confirmatory evidence;
- [ ] every numerical, recovery, sparse-design, dimensionality-challenge,
  information-criterion, ConQuest-core, pinned FACETS 4.5.0 JML-core,
  public-contract, and engineering blocker is `ok` for one exact candidate;
- [ ] no failed cell is hidden by aggregation and no unresolved external core
  discrepancy remains;
- [ ] every retained caveat appears in first-screen guidance, help, and the
  capability surface that exposes the affected result;
- [ ] package-controlled CRAN workload remains below ten minutes while the
  complete release-blocking evidence runs outside CRAN and is reproducible;
- [ ] a clean-room reviewer can reproduce the gate decision from the candidate
  manifest without access to private case-level data; and
- [ ] the machine-readable support envelope resolves every advertised model,
  estimator, statistic, and design row to exact evidence or an explicit caveat,
  exploratory, blocked, or unsupported state; and
- [ ] the release notes explicitly state that threshold anchors, frozen
  calibration, multiple scales, scale-specific PCM, native multidimensional
  estimation, and dimension-specific score production remain later work.

## 0.2.4: operational calibration

0.2.4 should make stable calibrations reusable without implying that every
model is suitable for high-stakes scoring. The first implementation target is
one observed score scale; multi-scale indexing remains deferred to 0.2.5.
Public implementation starts only after the 0.2.3 Definition of Done is met;
schema sketches may be prepared earlier, but they are not current API.

- [ ] Define a typed `mfrm_calibration` bundle containing model specification,
  parameter role and scope, identification constraints, element/group anchors,
  category map, scale namespace, training-data/schema fingerprints, provenance,
  source package/API versions, and content hash. Unknown schema versions,
  missing identities, and altered contents fail closed.
- [ ] Add single-scale threshold/step anchor support, distinguishing partially
  anchored ladders, fully fixed ladders, and starting values, with explicit
  sum-to-zero/origin, degree-of-freedom, and conflict checks.
- [ ] Add documented starting-value import and transformation contracts.
- [ ] Add scoring from a versioned frozen calibration, with explicit handling
  of unknown levels, missing categories, disconnected cases, and out-of-range
  scores; keep it distinct from 0.2.2 fitted-object posterior scoring.
- [ ] Propagate calibration identity into reports, exports, and replay
  manifests.
- [ ] Separate creation, validation, migration, and application APIs so a fit
  object, an arbitrary parameter table, and a validated frozen calibration
  cannot be substituted for one another by class coercion or column naming.
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
- [ ] Define a separate per-observation `ObservationModelId` for response
  family, active facets, sign/weight/offset, and permitted interactions. Do
  not overload `ScaleId` with both category-scale and likelihood-routing
  semantics; structural facet absence is not an ordinary missing value.
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

## 0.3.0: API, evidence, and ecosystem consolidation

0.3.0 is a consolidation release, not a container for whichever research
feature happens to finish first. Its entry condition is completion of the
0.2.3 evidence contract and stable 0.2.4/0.2.5 reduction cases. Its exit gates
are:

- [ ] Freeze versioned schemas for fits, diagnostics, comparisons,
  calibrations, support-envelope rows, and evidence manifests; publish explicit
  migration or rejection behavior for older objects.
- [ ] Define a compatibility and deprecation policy covering argument names,
  estimator aliases, print/report fields, serialized objects, and one full
  minor-release warning cycle where technically safe.
- [ ] Provide public, synthetic, end-to-end case studies for supported RSM/PCM
  and bounded-GPCM routes, including an intentionally unsupported design that
  demonstrates fail-closed behavior.
- [ ] Publish reproducible benchmark bundles and a performance envelope by
  sample size, response count, facet-level count, model, engine, memory, and
  runtime; performance evidence does not relax numerical gates.
- [ ] Obtain an independent methodological/code review of identification,
  parameter transformations, recovery, interval interpretation, external
  comparisons, and high-stakes caveats, with dispositions retained publicly.
- [ ] Establish contributor-facing validation instructions, known-answer data,
  generator/normalizer versioning, and a CI tier that detects evidence-schema
  drift without requiring proprietary software.

## Research tracks after core consolidation

These are separate research programs, not promises attached to 0.2.x or 0.3.0.

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

## 1.0.0: validated core stability contract

1.0.0 means that a deliberately bounded core is stable; it does not mean
feature parity with FACETS, TAM, ConQuest, or every MFRM formulation. Release is
authorized only when:

- the core estimands, identification constraints, object/calibration schemas,
  public names, and migration policy are declared stable;
- all supported core rows have independently rerun, versioned truth-recovery,
  interval, external-overlap, negative-control, and cross-platform evidence;
- the published support envelope states where evidence is absent or designs
  are unsupported, with unknown combinations failing closed;
- operational scoring has round-trip, stale-calibration, unknown-level,
  incompatible-scale, and provenance-tampering tests; and
- at least one external reviewer can reconstruct representative claims from
  public synthetic inputs and retained manifests without proprietary case data.

## Explicit icebox

The following remain outside committed release scope until a separate proposal
defines estimands, identification, reduction cases, computational cost, and
evidence gates: unrestricted GPCM; native multidimensional MFRM and subscores;
Bayesian/MCMC backends; posterior-predictive checks; multivariate G-theory;
mixture, unfolding, and rater-process families; automatic DIF/DFF decision
rules; and distributed/high-performance engines. An experimental branch or a
callable internal helper does not remove an item from the icebox.

## Feature maturity and common Definition of Done

Every public capability is assigned exactly one maturity state: `experimental`,
`validated`, `stable`, `deprecated`, or `unsupported`. Operational readiness
(`ready`, `caveated`, `blocked`, or `not_applicable`) is recorded separately;
maturity and readiness are not synonyms.

A capability may be promoted only when all applicable items are complete:

1. the estimand and user decision it informs are explicit;
2. identification, constraints, scale orientation, and reduction cases are
   specified and tested;
3. public API, object schema, errors, warnings, and migration behavior are
   documented;
4. truth-recovery, uncertainty/coverage where supported, numerical, and
   negative-control evidence pass prespecified rules;
5. matched external evidence is supplied where a defensible overlap exists,
   without treating external software as ground truth;
6. sparse, extreme, missing, disconnected, and malformed inputs have explicit
   outcomes and cannot become falsely ready;
7. tests, examples, reference documentation, support-envelope rows, and release
   notes agree;
8. runtime, memory, dependency, privacy, licensing, and reproducibility costs
   are acceptable for the declared execution tier; and
9. an independent review and candidate-linked evidence manifest are complete.

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
14. FACETS, ConQuest, TAM, and immer are independent comparators, not truth.
    Simulation truth, estimand matching, and between-program agreement are
    reported as separate questions.
15. External evidence binds the executable, version reported by the output,
    parser/generator identity, input/output hashes, and candidate. Version
    differences do not stop execution, but remain separate evidence strata;
    stale-output reuse is classified explicitly.
16. Estimator correction and extreme-score adjustment are part of method
    identity. Results from unadjusted, adjusted, bias-corrected, marginal, joint,
    and conditional likelihood routes are never silently pooled.
17. A hierarchical rater model or other local-dependence model is a competing
    model family, not an optimization backend for the current additive MFRM.
18. Internal metamorphic invariance is checked before external agreement. A
    row-order, label, filtering, weight, or serialization failure is an
    internal defect and cannot be reinterpreted as FACETS, TAM, or immer
    disagreement.
19. Optional validation capability is part of evidence identity. Dependency
    absence must fail closed and be distinguished from an evaluated
    statistical failure; official validation environments record exact
    capability versions without making every optional dependency a runtime
    installation requirement.
20. Reuse occurs only at the smallest complete comparison unit. A route-level
    fragment, unpublished temporary file, aggregate without a valid completion
    marker, or checkpoint whose package, runner, capability, manifest, or
    control identity differs is recomputed or rejected, never silently pooled.
